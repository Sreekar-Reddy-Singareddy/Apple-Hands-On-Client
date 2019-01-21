//
//  RegisterController.swift
//  SR_Hands_On
//
//  Created by Bros on 08/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Cocoa

class RegisterController: NSViewController, ServerProtocol {

    var story: NSStoryboard!
    @objc dynamic var empId: NSNumber!
    @objc dynamic var fName: String!
    @objc dynamic var lName: String!
    @objc dynamic var emailId: String!
    
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
    
    @IBAction func register(_ sender: NSButton) {
        // Validate the fields
        if (empId == nil || empId == 0) {
            // Employee ID empty
            AppDelegate.appDelegate.showAlert(msg: "Employee ID Empty", info: "Please enter your employee id to continue", but1: "Ok", but2: nil, icon: NSImage.init(named: "missing_field"))
            return
        }
        else if (fName == nil || fName.isEmpty) {
            // First name empty
            AppDelegate.appDelegate.showAlert(msg: "First Name Empty", info: "Please enter the first name to continue", but1: "Ok", but2: nil, icon: NSImage.init(named: "missing_field"))
            return
        }
        else if (lName == nil || lName.isEmpty) {
            // Last name empty
            AppDelegate.appDelegate.showAlert(msg: "Last Name Empty", info: "Please enter the last name to continue", but1: "Ok", but2: nil, icon: NSImage.init(named: "missing_field"))
            return
        }
        else if (emailId == nil || emailId.isEmpty) {
            // Email ID empty
            AppDelegate.appDelegate.showAlert(msg: "Email ID Empty", info: "Please enter the infosys email id to continue", but1: "Ok", but2: nil, icon: NSImage.init(named: "missing_field"))
            return
        }
        
        // Create a dictionary for the trainee
        var traineeDict = NSMutableDictionary()
        traineeDict.setValue(empId, forKey: "empId")
        if HandsOnUtilities.currentUserIp.isEmpty {
            AppDelegate.appDelegate.showAlert(msg: "No Network", info: "Please connect to a network and try again", but1: "Ok", but2: nil, icon: NSImage.init(named: "connection_fail"))
            return
        }
        print("Ip Address in Register: \(HandsOnUtilities.currentUserIp)")
        traineeDict.setValue(HandsOnUtilities.currentUserIp, forKey: "ipAddress")
        traineeDict.setValue(fName, forKey: "firstName")
        traineeDict.setValue(lName, forKey: "lastName")
        traineeDict.setValue(emailId, forKey: "emailId")
        traineeDict.setValue("Apple_Team", forKey: "batch_code")
        
        // Convert the dict to data
        var reqData: Data!
        do {
            reqData = try JSONSerialization.data(withJSONObject: traineeDict, options: .prettyPrinted)
        }
        catch {
            print("JSON Error") // TODO: Handle the exceptions properly
        }
        
        // Configure server and connect
        var server = HandsOnUtilities.getMainServer()
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(
            url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.registerFlag)",
            data: reqData,
            httpMethod: "POST",
            connDelegate: server)
        server.connection.start()
    }
    
    func redirectToLogin () {
        var loginVc = story.instantiateController(withIdentifier: "LoginVC") as! LoginController
        self.view.window?.contentViewController = loginVc
        loginVc.empId = self.empId
    }
    
    func plainTextCodeReceived(data: Data) {
        print("Response recieved from register service")
        print("Response: \(String.init(data: data, encoding: .ascii))")
        var respCode = String.init(data: data, encoding: .ascii)
        
        // Use the response flag and show some alert
        if respCode != nil && respCode! == "SUCCESS" {
            _ = AppDelegate.appDelegate.showAlert(msg: "Registered Successfully", info: "Congratulations! You have been offcially registered as apple trainee", but1: "Ok", but2: nil, icon: NSImage.init(named: "success"))
            redirectToLogin()
        }
        else if respCode != nil && respCode! == "TRAINEE_EXISTS" {
            let code = AppDelegate.appDelegate.showAlert(msg: "Trainee Already Exists", info: "Trainee with this employee number is already registered with us", but1: "Login", but2: nil, icon: NSImage.init(named: "duplicate_trainee"))
            if code == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
                // Take the user to the login window
                redirectToLogin()
            }
            
        }
        else if respCode != nil && respCode! == "INVALID_EMPID" {
            AppDelegate.appDelegate.showAlert(msg: "Invalid EmpID", info: "Emp Id \(empId!) is not authorised to register as apple trainee", but1: "Ok", but2: nil, icon: NSImage.init(named: "red_alert"))
            empId = nil
        }
        else if respCode != nil && respCode! == "INVALID_NAME" {
            AppDelegate.appDelegate.showAlert(msg: "Invalid Name", info: "Please check your first and last name for any invalid characters and try again", but1: "Ok", but2: nil, icon: NSImage.init(named: "red_alert"))
        }
        else if respCode != nil && respCode! == "INVALID_EMAIL" {
            AppDelegate.appDelegate.showAlert(msg: "Invalid EmailID", info: "The email id format does not match with infosys domain. Please give the correct email id\nEx: john_alex@infosys.com", but1: "Ok", but2: nil, icon: NSImage.init(named: "red_alert"))
        }
        else if respCode != nil && respCode! == "DATABASE_ERROR" {
            AppDelegate.appDelegate.showAlert(msg: "Connection Failed", info: "We are sorry for the inconvenience caused. Please visit us after sometime while we work on the issue", but1: "Ok", but2: nil, icon: NSImage.init(named: "connection_fail"))
        }
        
    }
}
