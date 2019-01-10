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
        self.view.window?.close()
    }
    
    // This method fetched the main assessment file
    @IBAction func next(_ sender: NSButton) {
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
        (segue.destinationController as! SubmitController).mainParentWindow = self.view.window
    }
    
    // Creates dictionary of exam information details
    func createExamInfo(fileType: String) -> Data? {
        // Data containing the examcode and file types
        var dataDict = NSMutableDictionary()
        dataDict.setValue(examCode, forKey: "examCode") // TODO: Exam code get some where dynamically
        dataDict.setValue(fileType, forKey: "fileType")
        return HandsOnUtilities.getDataFromDict(dataDict: dataDict)
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
        examTime.isHidden = !examView
    }
    
    // This method downloads the data from the server
    // data - downloaded data of the needed file
    func responseCompletedWithData(data: Data) {
        print("Inside exam controller with data! \(data)")
        // Get the error code into a string
        // Checking if any errors have occured
        var errorCode = String.init(data: data, encoding: .ascii)
        if (errorCode != nil && errorCode == "INVALID_EXAMCODE") {
            AppDelegate.appDelegate.showAlert(msg: "Invalid Examcode", info: "Please enter a valid exam code in order to take the assessment.", but1: "Ok", but2: nil, icon: nil)
            return
        }
        else if (errorCode != nil && errorCode == "NO_SUPPLIED_FILES") {
            AppDelegate.appDelegate.showAlert(msg: "No Downloadables", info: "This assessment does not provide any supplied code. You must create new project in Xcode to work", but1: "Ok", but2: nil, icon: nil)
            return
        }
        else if (errorCode != nil && errorCode!.starts(with: "Name:")) {
            // Set the trainee's name here
            var name = errorCode!.substring(from: String.Index.init(encodedOffset: 5))
            traineeName.stringValue = name.capitalized
        }
        
        var pdfDoc = PDFDocument.init(data: data) // TODO: Handle this nil value
        if (fileType == HandsOnUtilities.insCode || fileType == HandsOnUtilities.qprCode) && pdfDoc != nil {
            // Display the pdf
            // Any condition fail means that, this is some other type of file (.zip)
            pdfViewer.document = pdfDoc!
            // Change the button icon based on the file downloaded
            if (fileType == HandsOnUtilities.insCode) {
                nextButton.isHidden = false
                submitButton.isHidden = true
            }
            else if fileType == HandsOnUtilities.qprCode || fileType == HandsOnUtilities.supCode {
                nextButton.isHidden = true
                submitButton.isHidden = false
            }
            return
        }
        else if fileType == HandsOnUtilities.supCode {
            // Convert the data into a zip file and save it on desktop
            var fileManager = FileManager.default
            var fileResult = fileManager.createFile(atPath: "/Users/bros/Desktop/supplied_files.zip", contents: data, attributes: nil)
            if fileResult {
                // TODO: Logic to tell the file is downloaded
                AppDelegate.appDelegate.showAlert(msg: "Download Success", info: "Your supplied code files have been downloaded to the Desktop", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("success")))
                return
            }
            else {
                // TODO: Logic to tell the file is not downloaded
                AppDelegate.appDelegate.showAlert(msg: "Failed to Download", info: "Your supplied code files could not be downloaded. Kindly check with your invigilator", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("cancel")))
                return
            }
        }
    }
    
}
