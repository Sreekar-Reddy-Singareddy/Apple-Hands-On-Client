//
//  File.swift
//  SR_Hands_On
//
//  Created by Bros on 08/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Foundation

class MainServer: NSObject, NSURLConnectionDataDelegate {
    
    var delegate: ServerProtocol!
    var connection: NSURLConnection!
    var respData = Data()
    var response : URLResponse!
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        // The response is set for the use of delegate if needed
        self.response = response
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        // Append the data as it downloads
        respData.append(data)
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        // TODO: Tell the user about the failed connection
        print("Connection Failed: \(error.localizedDescription)")
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        // Connection completed. Notify the delegate. Clean the data.
        delegate.responseCompletedWithData(data: respData)
        respData.removeAll()
    }
}
