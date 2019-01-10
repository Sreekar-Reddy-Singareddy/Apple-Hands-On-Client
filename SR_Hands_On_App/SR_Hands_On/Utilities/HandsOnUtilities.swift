//
//  SingleObjectGenerator.swift
//  SR_Hands_On
//
//  Created by Bros on 08/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Foundation

class HandsOnUtilities: NSObject {
    
    public static var tomcatIpAdd = "192.168.43.103"
    public static var tomcatPort = "8080"
    public static var tomcatLocation = "http://\(tomcatIpAdd):\(tomcatPort)/srhandson/"
    
    public static var loginFlag = "login"
    public static var registerFlag = "register"
    public static var exammodeFlag = "exammode"
    public static var traineeFlag = "trainee"
    public static var submitFlag = "submit"
    
    public static var insCode = "INS"
    public static var qprCode = "QPR"
    public static var supCode = "SUP"
    
    public static var baseFilePath = "/Users/bros/Desktop/"
    
    // Single object of main server
    private static var mainServer = MainServer()
    
    // Single object of main file manager
    private static var mainFileManager = FileManager.default
    
    
    static func getMainServer () -> MainServer{
        return mainServer
    }
    
    static func getFileManager() -> FileManager {
        return mainFileManager
    }
    
    // This method creates a connection object and returns it
    static func getConnectionObj (url: String, data: Data?, httpMethod method: String, connDelegate del: Any) -> NSURLConnection {
        var urlObj = URL.init(string: url)
        var req = URLRequest.init(url: urlObj!) // TODO: Handle force unwrap
        req.httpMethod = method
        if (data != nil) {
            req.httpBodyStream = InputStream.init(data: data!)
        }
        var conn = NSURLConnection.init(request: req, delegate: del) // TODO: Handle force unwrap
        return conn!
    }
    
    static func getDataFromDict (dataDict: NSMutableDictionary) -> Data? {
        var data: Data!
        do {
            data = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
            print("JSON: \(data)")
            return data
        }
        catch {
            print("JSON Conversion Error")
            return nil
        }
    }
}
