//
//  ConfigureController.swift
//  SR_Hands_On
//
//  Created by Sreekar on 18/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Cocoa

class ConfigureController: NSViewController, ServerProtocol {

    @IBOutlet weak var connectionStatus: NSButton!
    @IBOutlet weak var connLoader: NSProgressIndicator!
    @IBOutlet weak var statusLabel: NSTextField!
    
    @objc dynamic var ipOne: NSNumber!
    @objc dynamic var ipTwo: NSNumber!
    @objc dynamic var ipThree: NSNumber!
    @objc dynamic var ipFour: NSNumber!
    
    var server = HandsOnUtilities.getMainServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Configure controller loaded")
    }
    
    @IBAction func testConn(_ sender: NSButton) {
        print("Testing Connection...")
        connLoader.isHidden = false
        connectionStatus.isHidden = true; statusLabel.isHidden = true
        connLoader.startAnimation(self)
        
        // Form the IP Address and update it in the utilities
        HandsOnUtilities.tomcatIpAdd = "\(ipOne!).\(ipTwo!).\(ipThree!).\(ipFour!)"
        HandsOnUtilities.updateServerPath()
        print("IP Add: \(HandsOnUtilities.tomcatIpAdd)")
        print("Path  : \(HandsOnUtilities.tomcatLocation)")
        
        // Start the connection
        server.delegate = self
        server.connection = HandsOnUtilities.getConnectionObj(
            url: "\(HandsOnUtilities.tomcatLocation)/test",
            data: nil,
            httpMethod: "GET", connDelegate: server)
        server.connection.start()
    }
    
    func plainTextCodeReceived(data: Data) {
        print("Plain text recieved inside configure controller")
        var code = String.init(data: data, encoding: .ascii)
        if code != nil && code == "TEST_OK" {
            statusLabel.stringValue = "Connected Successfully"
            connectionStatus.image = NSImage.init(named: "success")
        }
        else {
            statusLabel.stringValue = "Connection Failed"
            connectionStatus.image = NSImage.init(named: "cancel")
        }
        statusLabel.isHidden = false
        connectionStatus.isHidden = false
        connLoader.stopAnimation(self)
    }
}
