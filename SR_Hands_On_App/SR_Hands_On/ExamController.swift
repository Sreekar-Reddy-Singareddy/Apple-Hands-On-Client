//
//  ExamController.swift
//  SR_Hands_On
//
//  Created by Bros on 09/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Cocoa
import Quartz

class ExamController: NSViewController, ServerProtocol {
    
    var fileType:String!
    var examCode:Int!
    var empId: NSNumber!
    var endsAt: Date!
    var startedAt: Date!
    var timeLeft: TimeInterval!
    var timer: Timer!
    var timeCompFormatter: DateComponentsFormatter!
    var startMode:String!
    
    let server = HandsOnUtilities.getMainServer()
    
    @IBOutlet weak var pdfViewer: PDFView!
    @IBOutlet weak var pdfViewPop: NSPopUpButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var traineeName: NSTextField!
    @IBOutlet weak var examTime: NSTextField!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var startLabel: NSTextField!
    @IBOutlet weak var thumbs: PDFThumbnailView!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var submitButton: NSButton!
    @IBOutlet weak var timerIcon: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView(examView: false)
        thumbs.pdfView = pdfViewer
    }
    
    override func viewDidAppear() {
        print("Exam: \(self)")
        print("Exam Window: \(self.view.window)")
        // Fetch the trainee's details for welcome label
        var dict = NSMutableDictionary()
        dict.setValue(empId, forKey: "empId")
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(
            url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.traineeFlag)",
            data: HandsOnUtilities.getDataFromDict(dataDict: dict),
            httpMethod: "POST",
            connDelegate: server)
        server.connection.start()
    }
    
    @IBAction func pdfViewType(_ sender: NSPopUpButton) {
        if sender.selectedItem?.tag == 1 {
            pdfViewer.displayMode = PDFDisplayMode.singlePageContinuous
        }
        else if sender.selectedItem?.tag == 2 {
            pdfViewer.displayMode = PDFDisplayMode.singlePage
        }
        else if sender.selectedItem?.tag == 3 {
            pdfViewer.displayMode = PDFDisplayMode.twoUp
        }
    }
    
    @IBAction func logout(_ sender: NSButton) {
        AppDelegate.appDelegate.showAlert(msg: "Confirm Logout", info: "Are you sure you want to logout?", but1: "Yes", but2: "No", icon: nil)
        self.view.window?.close()
    }
    
    @IBAction func refreshTime(_ sender: NSButton) {
        refreshTime()
    }
    
    // This method fetched the main assessment file
    @IBAction func next(_ sender: NSButton) {
        // Display alert to the user
        if startMode == "VALID" {
            let code = AppDelegate.appDelegate.showAlert(msg: "Launch the assessment?", info: "Once you launch, your assessment time starts running. You have 3 hrs to complete the assessment", but1: "Launch", but2: "Cancel", icon: NSImage.init(named: "confirm_action"))
            if code == NSApplication.ModalResponse.alertSecondButtonReturn.rawValue {
                return
            }
        }
        
        print("Inside next method")
        downloadButton.isHidden = false
        // Set the file type as 'Quesion Paper'
        fileType = HandsOnUtilities.qprCode
        
        // Download the question paper
        var reqData = createExamInfo(fileType: fileType) // TODO: Handle this nil
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(
            url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.exammodeFlag)",
            data: reqData,
            httpMethod: "POST",
            connDelegate: server)
        server.connection.start()
    }

    // This method downloads the suppliedfiles.zip, if any
    @IBAction func download(_ sender: NSButton) {
        // Change the file type to 'Supplied Files'
        fileType = HandsOnUtilities.supCode
        
        // Download the question paper
        var reqData = createExamInfo(fileType: fileType) // TODO: Handle this nil
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(
            url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.exammodeFlag)",
            data: reqData,
            httpMethod: "POST",
            connDelegate: server)
        server.connection.start()
    }
    
    // This method starts the exam by displaying instructions and then QP
    @IBAction func start(_ sender: NSButton) {
        print("Inside start method")
        setView(examView: true)
        // Set the file type as 'Instructions'
        fileType = HandsOnUtilities.insCode
        downloadButton.isHidden = true // Hide download until QP is displayed
        
        // Download the instructions from the server
        var reqData = createExamInfo(fileType: fileType) // TODO: Handle this nil
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(
            url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.exammodeFlag)",
            data: reqData,
            httpMethod: "POST",
            connDelegate: server)
        server.connection.start()
        
    }
    
    // Before presenting the sheet
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        var submitController = segue.destinationController as! SubmitController
        submitController.mainParentWindow = self.view.window
        submitController.empId = self.empId
    }
    
    // Creates dictionary of exam information details
    func createExamInfo(fileType: String) -> Data? {
        // Data containing the examcode and file types
        var dataDict = NSMutableDictionary()
        dataDict.setValue(examCode, forKey: "examCode") // TODO: Exam code get some where dynamically
        dataDict.setValue(fileType, forKey: "fileType")
        dataDict.setValue(empId, forKey: "empId")
        return HandsOnUtilities.getDataFromDict(dataDict: dataDict)
    }
    
    // This method refreshes the time remaining for the trainee
    // Once reached 0, this method forcibly closes the application
    // Whenever the trainee wants to refresh the timer, this method
    // will be called internally
    func refreshTime () {
        // Database entries from 'EXAM_STATUS' will be used to refresh the time
        // Inputs needed are 'exam_code', 'emp_id'
        var timeDict = NSMutableDictionary()
        timeDict.setValue(empId, forKey: "empId")
        timeDict.setValue(examCode, forKey: "examCode")
        
        // Create a connection
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(
            url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.refreshTimeFlag)",
            data: HandsOnUtilities.getDataFromDict(dataDict: timeDict),
            httpMethod: "POST", connDelegate: server)
        server.connection.start()
        if timer != nil {
            timer.invalidate()
        }
    }
    
    // This method is called by the timer every 1 sec
    // It reduces the timer by 1 sec and updates the label
    @objc func updateTimer(timer: Timer) {
        if timeLeft <= 0 {
            self.view.window?.close()
        }
        else if Int.init(timeLeft) == 7200 {
            AppDelegate.appDelegate.deliverNotification(title: "1 hour elapsed", infoText: "You only have 2 hours left", icon: NSImage.init(named: "exam_time_green"))
        }
        else if Int.init(timeLeft) == 3600 {
            AppDelegate.appDelegate.deliverNotification(title: "2 hours elapsed", infoText: "You only have 1 hour left", icon: NSImage.init(named: "exam_time_org"))
        }
        else if Int.init(timeLeft) == 900 {
            AppDelegate.appDelegate.deliverNotification(title: "Time's running", infoText: "You have last 15 minutes", icon: NSImage.init(named: "exam_time_red"))
        }
        else if timeLeft > 0 && timeLeft < 900 {
            // Change the image to RED
            timerIcon.image = NSImage.init(named: "exam_time_red")
        }
        else if timeLeft > 900 && timeLeft <= 3600 {
            // Change the image to ORANGE
            timerIcon.image = NSImage.init(named: "exam_time_org")
        }
        else if timeLeft > 3600 {
            // Change the image to GREEN
            timerIcon.image = NSImage.init(named: "exam_time_green")
        }
        timeCompFormatter = DateComponentsFormatter.init()
        timeCompFormatter.allowedUnits = [.hour, .minute, .second]
        timeCompFormatter.unitsStyle = .positional
        examTime.stringValue = timeCompFormatter.string(from: timeLeft)!
        timeLeft -= 1
        print("New Time: \(timeCompFormatter.string(from: timeLeft)!)")
    }
    
    // Decides which views need to hidden and when
    func setView(examView: Bool) {
        startButton.isHidden = examView
        startLabel.isHidden = examView
        downloadButton.isHidden = !examView
        pdfViewer.isHidden = !examView
        thumbs.isHidden = !examView
        pdfViewPop.isHidden = !examView
        nextButton.isHidden = !examView
        submitButton.isHidden = !examView
        timerIcon.isHidden = !examView
        examTime.isHidden = !examView
    }
    
    // This method is called when JSON data is received
    func jsonObjectReceived(data: Data) {
        print("JSON Data received: \(String.init(data: data, encoding: .ascii))")
        do {
            var jsonDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String, Any?>
            // This dictionary contains the start time, end time, emp id of the trainee
            if jsonDict["empId"] != nil {
                // Contains some data
                // Convert the values into Date types in swift
                var f = DateFormatter.init()
                f.dateFormat = "MMM dd, yyyy hh:mm:ss a"
                startedAt = f.date(from: jsonDict["startedAt"] as! String)
                endsAt = f.date(from: jsonDict["endsAt"] as! String)
                var timeStamp = f.date(from: jsonDict["timeStamp"] as! String) // Get this from backend
                print("END TIME: \(endsAt)")
                
                // Get the interval between current time and end time
                if #available(OSX 10.12, *) {
                    var di = DateInterval.init(start: timeStamp!, end: endsAt)
                    timeLeft = di.duration
                    print("Time Left in Seconds: \(timeLeft)")
                }
                
                // Start a timer to reduce the time by 1sec each time
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
                timer.fire()
            }
        }
        catch {
            print("JSON Exception")
        }
    }
    
    func plainTextCodeReceived(data: Data) {
        print("Plain text received")
        // Get the error code into a string
        // Checking if any errors have occured
        var errorCode = String.init(data: data, encoding: .ascii)
        if (errorCode != nil && errorCode == "INVALID_EXAMCODE") {
            AppDelegate.appDelegate.showAlert(msg: "Invalid Examcode", info: "Please enter a valid exam code in order to take the assessment.", but1: "Ok", but2: nil, icon: NSImage.init(named: "red_alert"))
            return
        }
        else if (errorCode != nil && errorCode == "NO_SUPPLIED_FILES") {
            // If there are no supplied files provided for this assessment,
            // there wouldn't be any downloadables. Works mostly for FA2, FA3 & FA4
            AppDelegate.appDelegate.showAlert(msg: "No Downloadables", info: "This assessment does not provide any supplied code. You must create new project in Xcode to work", but1: "Ok", but2: nil, icon: NSImage.init(named: "missing_file"))
            return
        }
        else if (errorCode != nil && errorCode == "INVALID_EXAM_DETAILS") {
            // This means the exam details are invalid
            // 1. Exam code could be invalid
            // 2. Exam date could be invalid
            // 3. Even if above two are valid, the time limit could be invalid
            AppDelegate.appDelegate.showAlert(msg: "No Assessment Present", info: "There is no assessment scheduled currently. Check whether the exam date and time are correct", but1: "Ok", but2: nil, icon: NSImage.init(named: "red_alert"))
            
        }
        else if (errorCode != nil && errorCode!.starts(with: "Name:")) {
            // Set the trainee's name here
            var name = errorCode!.substring(from: String.Index.init(encodedOffset: 5))
            traineeName.stringValue = "Hello, \(name.capitalized)!"
        }
    }
    
    func pdfFileReceived (data: Data) {
        print("PDF file received")
        var pdfDoc = PDFDocument.init(data: data) // TODO: Handle this nil value
        if (fileType == HandsOnUtilities.insCode || fileType == HandsOnUtilities.qprCode) && pdfDoc != nil {
            print("PDF there \(fileType)")
            // Display the pdf
            // Any condition fail means that, this is some other type of file (.zip)
            pdfViewer.document = pdfDoc!
            // Change the button icon based on the file downloaded
            if (fileType == HandsOnUtilities.insCode) {
                nextButton.isHidden = false
                submitButton.isHidden = true
                timerIcon.isHidden = true
                examTime.isHidden = true
            }
            else if fileType == HandsOnUtilities.qprCode {
                // Present a segue here
                let popVC = storyboard?.instantiateController(withIdentifier: "PopVC") as! PopController
//                self.present(popVC, asPopoverRelativeTo: popVC.view.bounds, of: downloadButton, preferredEdge: .minY, behavior: .transient)
                print("Presented as popover \(popVC)")
                
                // Fetch the time left fot the trainee
                refreshTime()
                nextButton.isHidden = true
                submitButton.isHidden = false
                timerIcon.isHidden = false
                examTime.isHidden = false
            }
            return
        }
    }
    
    
    func zipFileReceived(data: Data) {
        if fileType == HandsOnUtilities.supCode {
            // Convert the data into a zip file and save it on desktop
            var fileManager = FileManager.default
            var fileResult = fileManager.createFile(atPath: "\(HandsOnUtilities.baseFilePath)supplied_files.zip", contents: data, attributes: nil)
            if fileResult {
                AppDelegate.appDelegate.showAlert(msg: "Download Success", info: "Your supplied code files have been downloaded to the Desktop as 'supplied_files.zip'", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("success")))
                return
            }
            else {
                AppDelegate.appDelegate.showAlert(msg: "Failed to Download", info: "Your supplied code files could not be downloaded. Kindly check with your invigilator", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("red_alert")))
                return
            }
        }
    }
    
}
