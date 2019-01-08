//
//  AppDelegate.swift
//  SR_Hands_On
//
//  Created by apple on 28/12/18.
//  Copyright © 2018 Singareddy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    public static var appDelegate = NSApplication.shared.delegate as! AppDelegate
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // This method handles the alerts of this view
    func showAlert (msg: String, info: String, but1: String?, but2: String?, icon: NSImage?) -> Int {
        var alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = info
        if (but1 != nil) {
            alert.addButton(withTitle: but1!)
        }
        if (but2 != nil) {
            alert.addButton(withTitle: but2!)
        }
        if (icon != nil) {
            alert.icon = icon!
        }
        return alert.runModal().rawValue
    }

}

