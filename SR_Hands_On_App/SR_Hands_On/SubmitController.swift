//
//  SubmitController.swift
//  SR_Hands_On
//
//  Created by Bros on 10/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Cocoa

class SubmitController: NSViewController, NSTextFieldDelegate, ServerProtocol {
    
    // UI Bindings
    @objc dynamic var fileName: String!

    // UI Outlets
    @IBOutlet weak var checkFileButton: NSButton!
    
    var fMan = HandsOnUtilities.getFileManager()
    var mainParentWindow: NSWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkFileButton.isEnabled = false
    }
    
    override func viewDidAppear() {
        
        print("Submit Parent: \(self.parent)")
        print("First Window: \(self.view.window)")
    }
    
    // Checks if there is any file with the given name
    @IBAction func checkFile(_ sender: NSButton) {
        
        // Logic to check the file in default directory
        var fullFilePath = HandsOnUtilities.baseFilePath + self.fileName
        if fMan.fileExists(atPath: fullFilePath) {
            // File exists, so proceed to submit it
            var code = AppDelegate.appDelegate.showAlert(msg: "Confirm Submission", info: "Are you sure you want to submit \(self.fileName!)? Once submitted, you cannot do undo it", but1: "Confirm", but2: "Cancel", icon: NSImage.init(named: NSImage.Name("confirm")))
            if code == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
                // TODO: Logic to upload the file to the server
                uploadFile(fullFilePath: fullFilePath)
                self.view.window?.close()
                return
            }
        }
        else {
            // File does not exist, ask user to check the name
            AppDelegate.appDelegate.showAlert(msg: "File Not Found", info: "Unable to find \(self.fileName!) on Desktop. Please make sure your file name is correct and is present on Desktop", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("cancel")))
        }
    }
    
    // This method uploads the file to the server
    func uploadFile(fullFilePath: String) {
        print("Submitted!")
        // Convert the file into data
        var fileData = fMan.contents(atPath: fullFilePath)
        if fileData == nil {
            AppDelegate.appDelegate.showAlert(msg: "Upload Failed", info: "Please try again", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("cancel")))
            return
        }
        
        // Connect and send the data to sevrer
        var server = HandsOnUtilities.getMainServer()
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(
            url: "\(HandsOnUtilities.tomcatLocation)/\(HandsOnUtilities.submitFlag)/\(self.fileName!)",
            data: fileData!,
            httpMethod: "POST",
            connDelegate: server)
        server.connection.start()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        print("Text Change: \(self.fileName)")
        if self.fileName != nil && !self.fileName.isEmpty {
            // String value is not empty, but check for format
            var fileName = self.fileName
            var subStrings = fileName!.split(separator: ".")
            if subStrings.count == 2 {
                // This means format is valid
                if subStrings[1].lowercased() == "zip" {
                    // This means even the extension is correct
                    // Enable the button now
                    checkFileButton.isEnabled = true
                    return
                }
            }
        }
        // Something is incorrect in the string
        checkFileButton.isEnabled = false
    }
    
    func responseCompletedWithData(data: Data) {
        // This response contains nil, SUCCESS or FAILURE
        var code = String.init(data: data, encoding: .ascii)
        
        if code == "SUCCESS" {
            var code = AppDelegate.appDelegate.showAlert(msg: "Uploaded Success", info: "\(self.fileName!) was uploaded successfully. You can now quit the application", but1: "Quit", but2: nil, icon: NSImage.init(named: NSImage.Name("success")))
            if code == NSApplication.ModalResponse.alertFirstButtonReturn.rawValue {
                // Quit the application
                print("Quitting...")
                print("Alert Window: \(self.view.window)")
                self.mainParentWindow.close()
            }
        }
        else if code == "FAILURE" {
            AppDelegate.appDelegate.showAlert(msg: "Uploaded Failed", info: "\(self.fileName!) could not be uploaded due to technical issues. Kindly contact your invigilator for assistance", but1: "Ok", but2: nil, icon: NSImage.init(named: NSImage.Name("cancel")))
        }
    }
    
}