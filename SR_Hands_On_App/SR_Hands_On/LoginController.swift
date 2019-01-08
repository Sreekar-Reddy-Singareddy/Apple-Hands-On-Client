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
                AppDelegate.appDelegate.showAlert(msg: "Employee ID Empty", info: "Please enter your employee in order to login", but1: "Ok", but2: nil, icon: nil)
                return
            }
            
            var dataDict = NSMutableDictionary()
            dataDict.setValue(empId, forKey: "empId") // TODO: Check for the nil value here
            dataDict.setValue("", forKey: "firstName")
            dataDict.setValue("", forKey: "lastName")
            dataDict.setValue("", forKey: "emailId")
            dataDict.setValue("", forKey: "batchCode")
            resData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
        }
        catch {
            print("Cannot convert to data")
        }
        
        // Configure the server
        var server = HandsOnUtilities.getMainServer()
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.loginFlag)", data: resData, httpMethod: "POST", delegate: server)
        server.connection.start()
    }
    
    func responseCompletedWithData(data: Data) {
        print("Data Details: \(data.count)")
        print("Converted Data: \(String.init(data: data, encoding: .ascii))")
        var respCode = String.init(data: data, encoding: .ascii)
        
        // Use the code and decide what to do
        if respCode != nil && respCode! == "VALID" {
            AppDelegate.appDelegate.showAlert(msg: "Login Successful", info: "Congratulations! You can now use HandsOn app to take assessments", but1: "Ok", but2: nil, icon: nil)
        }
        else if respCode != nil && respCode! == "INVALID" {
            var code = AppDelegate.appDelegate.showAlert(msg: "Login Failed", info: "\(empId.stringValue) is not registered as apple trainee. Please register and try again", but1: "Register", but2: "Cancel", icon: nil)
            print("Code: \(code)")
            if code == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
                let registerController = story.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("RegisterVC")) as! RegisterController
                self.view.window?.title = "Register"
                self.view.window?.contentViewController = registerController
            }
        }
    }
    
}
