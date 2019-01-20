//
//  ServerProtocol.swift
//  SR_Hands_On
//
//  Created by Bros on 08/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Foundation

@objc protocol ServerProtocol {
    
    // This method is called on delegate when the data is completely received
    @objc optional func unknownDataReceived (data: Data!)
    
    // This method is called when the response received is of text/plain type
    @objc optional func plainTextCodeReceived (data: Data!)
    
    // This method is called when the response received is of application/json type
    @objc optional func jsonObjectReceived (data: Data!)
    
    // This method is called when the response received is of application/pdf type
    @objc optional func pdfFileReceived (data: Data!)
    
    // This method is called when the response received is of application/zip type
    @objc optional func zipFileReceived (data: Data!)
}
