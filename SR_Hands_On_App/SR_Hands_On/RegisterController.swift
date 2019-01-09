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
            AppDelegate.appDelegate.showAlert(msg: "Employee ID Empty", info: "Please enter the id and proceed", but1: "Ok", but2: nil, icon: nil)
            return
        }
        else if (fName == nil || fName.isEmpty) {
            // First name empty
            AppDelegate.appDelegate.showAlert(msg: "First Name Empty", info: "Please enter the first name and proceed", but1: "Ok", but2: nil, icon: nil)
            return
        }
        else if (lName == nil || lName.isEmpty) {
            // Last name empty
            AppDelegate.appDelegate.showAlert(msg: "Last Name Empty", info: "Please enter the last name and proceed", but1: "Ok", but2: nil, icon: nil)
            return
        }
        else if (emailId == nil || emailId.isEmpty) {
            // Email ID empty
            AppDelegate.appDelegate.showAlert(msg: "Email ID Empty", info: "Please enter the infosys email id and proceed", but1: "Ok", but2: nil, icon: nil)
            return
        }
        
        // Create a dictionary for the trainee
        var traineeDict = NSMutableDictionary()
        traineeDict.setValue(empId, forKey: "empId")
        traineeDict.setValue("127.0.0.2", forKey: "ipAdd")
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
    
    
    
    func responseCompletedWithData(data: Data) {
        print("Response recieved from register service")
        print("Response: \(String.init(data: data, encoding: .ascii))")
        var respCode = String.init(data: data, encoding: .ascii)
        
        // Use the response flag and show some alert
        if respCode != nil && respCode! == "SUCCESS" {
            AppDelegate.appDelegate.showAlert(msg: "Registered Successfully", info: "Congratulations! You have been offcially registered as apple trainee", but1: "Ok", but2: nil, icon: nil)
        }
        else if respCode != nil && respCode! == "TRAINEE_EXISTS" {
            AppDelegate.appDelegate.showAlert(msg: "Trainee Already Exists", info: "Trainee with this employee number is already registered with us", but1: "Ok", but2: nil, icon: nil)
        }
        else if respCode != nil && respCode! == "INVALID_EMPID" {
            AppDelegate.appDelegate.showAlert(msg: "Invalid EmpID", info: "This employee id is not authorised to register as apple trainee", but1: "Ok", but2: nil, icon: nil)
        }
        else if respCode != nil && respCode! == "INVALID_NAME" {
            AppDelegate.appDelegate.showAlert(msg: "Invalid Name", info: "Please check your first and last name for any invalid characters and try again", but1: "Ok", but2: nil, icon: nil)
        }
        else if respCode != nil && respCode! == "INVALID_EMAIL" {
            AppDelegate.appDelegate.showAlert(msg: "Invalid EmailID", info: "The email id format does not match with infosys domain. Please give the correct email id", but1: "Ok", but2: nil, icon: nil)
        }
        else if respCode != nil && respCode! == "DATABASE_ERROR" {
            AppDelegate.appDelegate.showAlert(msg: "Connection Failed", info: "We are sorry for the inconvenience caused. Please visit us after sometime while we work on the issue", but1: "Ok", but2: nil, icon: nil)
        }
        
    }
}
