//
//  SingleObjectGenerator.swift
//  SR_Hands_On
//
//  Created by Bros on 08/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Foundation

class HandsOnUtilities: NSObject {
    
    public static var tomcatIpAdd = "127.0.0.1"
    public static var tomcatPort = "8080"
    public static var tomcatLocation = "http://\(tomcatIpAdd):\(tomcatPort)/HandsNew/sr/"
    
    public static var loginFlag = "login"
    public static var registerFlag = "register"
    public static var exammodeFlag = "exammode"
    public static var traineeFlag = "trainee"
    public static var submitFlag = "submit"
    public static var refreshTimeFlag = "refresh_time"
    
    public static var insCode = "INS"
    public static var qprCode = "QPR"
    public static var supCode = "SUP"
    
    public static var empId = 0
    public static var examCode = 0
    
    public static var baseFilePath = "/Users/sreekar/Desktop/"
    
    // Single object of main server
    private static var mainServer = MainServer()
    
    // Single object of main file manager
    private static var mainFileManager = FileManager.default
    
    static func updateServerPath () {
        tomcatLocation = "http://\(tomcatIpAdd):\(tomcatPort)/HandsNew/sr/"
    }
    
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
        req.timeoutInterval = 10
        var conn = NSURLConnection.init(request: req, delegate: del) // TODO: Handle force unwrap
        print("Connection: \(conn)")
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
    
    // This method is used to get the IP Address of the machine
    // and upload it in the database while registering a new trainee.
    // Returns an array of addresses
    static func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }
}
