//
//  AppDelegate.swift
//  SR_Hands_On
//
//  Created by apple on 28/12/18.
//  Copyright © 2018 Singareddy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    public static var appDelegate = NSApplication.shared.delegate as! AppDelegate
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Once the app finished launching, set the user name in HandsOnUtilties
        // The username will the currently logged in user
        if #available(OSX 10.12, *) {
            print("#####",HandsOnUtilities.getFileManager().homeDirectoryForCurrentUser.pathComponents[2])
            HandsOnUtilities.currentUser = HandsOnUtilities.getFileManager().homeDirectoryForCurrentUser.pathComponents[2]
        } else {
            // Fallback on earlier versions
        }
        HandsOnUtilities.updateStaticVariables()
        print("Current User: \(HandsOnUtilities.baseFilePath)")
        HandsOnUtilities.getIFAddresses()
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
    
    @IBAction func refreshInternet(_ sender: NSMenuItem) {
        // Once loaded, get the IP address of the machine
        var addresses = HandsOnUtilities.getIFAddresses()
        if addresses.count >= 2 {
            // Internet connected
            HandsOnUtilities.currentUserIp = addresses[1]
            AppDelegate.appDelegate.showAlert(msg: "Connected", info: "You are now connected to internet as \(HandsOnUtilities.currentUserIp)", but1: "Ok", but2: nil, icon: NSImage.init(named: "success"))
        }
        else {
            // Internet not connected
            HandsOnUtilities.currentUserIp = ""
            AppDelegate.appDelegate.showAlert(msg: "No Network", info: "Please connect to a network and try again. Press Command+R to refresh the connection", but1: "Ok", but2: nil, icon: NSImage.init(named: "connection_fail"))
        }
    }
    
    func deliverNotification (title: String, infoText: String, icon:NSImage?) {
        var notCenter = NSUserNotificationCenter.default
        var notification = NSUserNotification.init()
        notification.title = title
        notification.informativeText = infoText
        notification.hasActionButton = true
        notification.actionButtonTitle = "Noted"
        notification.contentImage = icon
        notCenter.delegate = self
        notCenter.scheduleNotification(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

}

