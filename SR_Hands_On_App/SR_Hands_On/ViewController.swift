//
//  ViewController.swift
//  SR_Hands_On
//
//  Created by apple on 28/12/18.
//  Copyright © 2018 Singareddy. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var story: NSStoryboard!
    var plistPath: String!
    var plistData:NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        story = NSStoryboard.init(name: NSStoryboard.Name("Main"), bundle: nil)
        
        // Take care of the plist here
        plistPath = HandsOnUtilities.getFileManager().currentDirectoryPath.appending("/handson.plist")
        
        // Check if it is there
        if !HandsOnUtilities.getFileManager().fileExists(atPath: plistPath) {
            // Not exists
            // Create new plist
            var fm = HandsOnUtilities.getFileManager()
            plistPath = fm.currentDirectoryPath.appending("/handson.plist")
            plistData = NSMutableDictionary.init()
            plistData.setValue(HandsOnUtilities.tomcatIpAdd, forKey: "server_ip")
            
            print("Data Written to Plist: ",plistData.write(toFile: plistPath, atomically: true))
        }
        else {
            // Exists
            plistData = NSMutableDictionary.init(contentsOfFile: plistPath)
            HandsOnUtilities.tomcatIpAdd = plistData.value(forKey: "server_ip") as! String
        }
    }
    
    @IBAction func login(_ sender: NSButton) {
        // Load login controller
        let loginController = story.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("LoginVC")) as! LoginController
        self.view.window?.title = "Login"
        self.view.window?.contentViewController = loginController
    }
    
    @IBAction func register(_ sender: NSButton) {
        // Load login controller
        let registerController = story.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("RegisterVC")) as! RegisterController
        self.view.window?.title = "Register"
        self.view.window?.contentViewController = registerController
    }
}

