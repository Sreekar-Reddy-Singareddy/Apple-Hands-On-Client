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
        print("Response Type: \(response.mimeType!)")
        self.response = response
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        // Append the data as it downloads
        respData.append(data)
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        // TODO: Tell the user about the failed connection
        print("Connection Failed: \(error.localizedDescription)")
        delegate.plainTextCodeReceived!(data: nil)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        // Connection completed. Notify the delegate. Clean the data.
        print("Response: \(response)")
        redirectResponseOnMimeType()
    }
    
    // This method redirects the received data to the appropriate
    // delegate method based on the MIME TYPE of the response data
    func redirectResponseOnMimeType () {
        if response == nil {
            return
        }
        var type = response.mimeType!
        if type == "text/plain" {
            // Call method for handling text messages
            delegate.plainTextCodeReceived!(data: respData)
        }
        else if type == "application/pdf" {
            // Call method for handling only PDFs
            delegate.pdfFileReceived!(data: respData)
        }
        else if type == "application/zip" {
            // Call method for handling only ZIPs
            delegate.zipFileReceived!(data: respData)
        }
        else if type == "application/json" {
            // Call method for handling only JSON objects
            delegate.jsonObjectReceived!(data: respData)
        }
        else {
            // Call method for handling any other unknown data
            delegate.unknownDataReceived!(data: respData)
        }
        // Once a delegate method is called, we do not need this data anymore
        // Discard the data and clean the respData object for next connections
        respData.removeAll()
    }
}
