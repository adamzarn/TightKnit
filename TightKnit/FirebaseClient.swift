//
//  FirebaseClient.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class FirebaseClient: NSObject {
    
    let ref = FIRDatabase.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func createFabric(fabric: String) {
        
        let groupsRef = self.ref.child("Fabrics")
        let newGroupRef = groupsRef.childByAutoId()
        
        let nameRef = newGroupRef.child("name")
        nameRef.setValue(fabric)
        
        let adminRef = newGroupRef.child("administrator")
        adminRef.setValue(appDelegate.userID)
        
        let membersRef = newGroupRef.child("members")
        membersRef.setValue(1)
    
    }
    
    func addNewUser(uid: String, name: String, email: String) {
        
        let userRef = self.ref.child("Users/\(uid)")
        let newUser = User(uid: uid, name: name, email: email)
        userRef.setValue(newUser.toAnyObject())
        
        appDelegate.userID = uid
        appDelegate.email = email
        appDelegate.name = name
        
    }
    
    
    
    static let sharedInstance = FirebaseClient()
    private override init() {
        super.init()
    }
}
