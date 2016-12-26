//
//  Fabric.swift
//  TightKnit
//
//  Created by Adam Zarn on 12/22/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

struct Fabric {
    let key: String
    let name: String
    let adminKey: String
    let adminName: String
    
    init(key: String, name: String, adminKey: String, adminName: String) {
        self.key = key
        self.name = name
        self.adminKey = adminKey
        self.adminName = adminName
    }
    
}

struct Message {
    let message: String
    let postedBy: String
    let timestamp: String
    
    init(message: String, postedBy: String, timestamp: String) {
        self.message = message
        self.postedBy = postedBy
        self.timestamp = timestamp
    }
    
}
