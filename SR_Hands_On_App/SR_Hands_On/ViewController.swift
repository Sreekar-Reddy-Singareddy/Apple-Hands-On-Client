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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        story = NSStoryboard.init(name: NSStoryboard.Name("Main"), bundle: nil)
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

