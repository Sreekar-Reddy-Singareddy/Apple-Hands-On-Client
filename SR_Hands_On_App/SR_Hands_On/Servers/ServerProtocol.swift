//
//  ServerProtocol.swift
//  SR_Hands_On
//
//  Created by Bros on 08/01/19.
//  Copyright © 2019 Singareddy. All rights reserved.
//

import Foundation

protocol ServerProtocol {
    
    // This method is called on delegate when the data is completely received
    func responseCompletedWithData (data: Data)
    
}
