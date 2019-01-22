//
//  LoginController.swift
//  SR_Hands_On
//
//  Created by Bros on 08/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Cocoa

class LoginController: NSViewController, ServerProtocol {
    
    var story: NSStoryboard!
    @objc dynamic var empId: NSNumber!
    @objc dynamic var examCode: String!
    var examCodeNum: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        story = NSStoryboard.init(name: NSStoryboard.Name("Main"), bundle: nil)
    }
    
    @IBAction func back(_ sender: NSButton) {
        // Go back to the main window
        let mainController = story.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("MainVC")) as! ViewController
        self.view.window?.title = "Apple HandsOn"
        self.view.window?.contentViewController = mainController
    }
    
    @IBAction func login(_ sender: NSButton) {
        // Get the emp id of the trainee and send it to server to verify
        var resData: Data!
        do {
            // Check for the empty or nil
            if empId == nil || empId! == 0 {
                AppDelegate.appDelegate.showAlert(msg: "Employee ID Empty", info: "Please enter your employee ID in order to login", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("missing_field")))
                return
            }
            if examCode == nil || examCode.isEmpty {
                AppDelegate.appDelegate.showAlert(msg: "Exam Code Empty", info: "Please enter the exam code to authenticate and take the assessment", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("missing_field")))
                return
            }
            examCodeNum = Int(examCode)
            if examCode.count != 8 || examCodeNum == nil {
                AppDelegate.appDelegate.showAlert(msg: "Incorrect Code Format", info: "Please enter the correct format exam code to proceed. Code must contain only 8 digits", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("red_alert")))
                examCode = nil
                return
            }
            
            var dataDict = NSMutableDictionary()
            dataDict.setValue(empId, forKey: "empId") // TODO: Check for the nil value here
            dataDict.setValue(examCodeNum, forKey: "examCode") // TODO: Any alternative?
            print("IP Address: \(HandsOnUtilities.currentUserIp)")
            if HandsOnUtilities.currentUserIp.isEmpty {
                AppDelegate.appDelegate.showAlert(msg: "No Network", info: "Please connect to a network and try again. Press Command+R to refresh once connected.", but1: "Ok", but2: nil, icon: NSImage.init(named: "connection_fail"))
                return
            }
            dataDict.setValue(HandsOnUtilities.currentUserIp, forKey: "ipAddress")
            resData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
        }
        catch {
            print("Cannot convert to data")
        }
        
        // Configure the server
        var server = HandsOnUtilities.getMainServer()
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.loginFlag)", data: resData, httpMethod: "POST", connDelegate: server)
        server.connection.start()
    }
    
    func plainTextCodeReceived(data: Data) {
        print("Data Details: \(data.count)")
        print("Converted Data: \(String.init(data: data, encoding: .ascii))")
        var respCode = String.init(data: data, encoding: .ascii)
        
        // Use the code and decide what to do
        if respCode != nil && (respCode! == "VALID" || respCode! == "RESUME_EXAM") {
            // Trainee will now be taken to exam screen
            var examController = story.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ExamVC")) as! ExamController
            self.view.window?.title = "Exam Mode"
            self.view.window?.contentViewController = examController
            HandsOnUtilities.empId = empId.intValue
            HandsOnUtilities.examCode = self.examCodeNum
            examController.examCode = self.examCodeNum // TODO: Remove them
            examController.empId = empId // TODO: Remove them
            examController.startMode = respCode!
        }
        else if respCode != nil && respCode! == "NO_EXAM_TODAY" {
            var code = AppDelegate.appDelegate.showAlert(msg: "Login Failed", info: "There are no assessments scheduled at this time, for the given code", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("red_alert")))
            examCode = nil
        }
        else if respCode != nil && respCode! == "EXAM_FINISHED" {
            var code = AppDelegate.appDelegate.showAlert(msg: "Assessment Ended", info: "Your assessment has already ended. You cannot retake or resubmit the assessment", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("red_alert")))
            examCode = nil
            self.view.window?.close()
        }
        else if respCode != nil && respCode! == "INVALID_IP" {
            var code = AppDelegate.appDelegate.showAlert(msg: "Unauthorised Login", info: "You are not authorised to login from this iMac. Kindly use your designated iMac", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("red_alert")))
            examCode = nil
            self.view.window?.close()
        }
        else if respCode != nil && respCode! == "NO_TRAINEE" {
            var code = AppDelegate.appDelegate.showAlert(msg: "Login Failed", info: "You are not a registered apple trainee yet. Please register to take the assessment", but1: "Register", but2: "Cancel", icon: NSImage.init(named: NSImage.Name("red_alert")))
            print("Code: \(code)")
            if code == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
                let registerController = story.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("RegisterVC")) as! RegisterController
                self.view.window?.title = "Register"
                self.view.window?.contentViewController = registerController
            }
            else {
                empId = nil
                examCode = nil
            }
        }
    }
    
}
