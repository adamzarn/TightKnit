//
//  User.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let email: String
    let name: String
    
    init(uid: String, name: String, email: String) {
        self.uid = uid
        self.email = email
        self.name = name
    }
    
    func toAnyObject() -> AnyObject {
        return ["name": name, "email": email] as AnyObject
    }
    
}
