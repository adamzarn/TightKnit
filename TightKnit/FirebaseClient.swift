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

    func createFabric(fabric: String, completion: @escaping (_ fabricKey: NSString?) -> ()) {
        
        let groupsRef = self.ref.child("Fabrics")
        let newGroupRef = groupsRef.childByAutoId()
    
        let nameRef = newGroupRef.child("name")
        nameRef.setValue(fabric)
        
        let adminRef = newGroupRef.child("administrator")
        adminRef.setValue(appDelegate.uid)
        
        let membersRef = newGroupRef.child("members").childByAutoId()
        membersRef.setValue(appDelegate.uid)
        
        completion(newGroupRef.key as NSString?)
    
    }
    
    func getFabricNames(uid: String, completion: @escaping (_ results: [String]?, _ error: String?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let userData = ((snapshot.value! as! NSDictionary)["Users"] as! NSDictionary)[uid] {
                var fabricNames = [] as [String]
                let fabrics = (userData as! NSDictionary)["fabrics"] as! NSDictionary
                var i = 1
                for (_, value) in fabrics {
                    
                    self.ref.observeSingleEvent(of: .value, with: { snapshot in
                        if let fabricData = ((snapshot.value! as! NSDictionary)["Fabrics"] as! NSDictionary)[value] {
                            let name = (fabricData as! NSDictionary)["name"]
                            fabricNames.append(name as! String)
                            
                            if i == fabrics.count {
                                print(fabricNames)
                                completion(fabricNames, nil)
                            } else {
                                i = i + 1
                            }
                            
                        }
                    })
                    
                }
                
            } else {
                completion([], "Could not retrieveData")
            }
        })
    }
    
    func addNewUser(uid: String, name: String, email: String) {
        
        let userRef = self.ref.child("Users/\(uid)")
        let newUser = User(uid: uid, name: name, email: email, fabrics: "")
        userRef.setValue(newUser.toAnyObject())
        
        appDelegate.uid = uid
        appDelegate.email = email
        appDelegate.name = name
        
    }
    
    func joinFabric(uid: String, fabricKey: String) {
        let fabricRef = self.ref.child("Users").child(uid).child("fabrics").childByAutoId()
        fabricRef.setValue(fabricKey)
    }
    
    func getUserData(uid: String, completion: @escaping (_ userData: NSDictionary?, _ error: String?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let userData = ((snapshot.value! as! NSDictionary)["Users"] as! NSDictionary)[uid] {

                completion(userData as? NSDictionary, nil)
            } else {
                completion(nil, "Could not retrieve data")
            }
        })
    }

    
    func logout(vc: UIViewController) {
    
        do {
            try FIRAuth.auth()?.signOut()
            let loginVC = vc.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                vc.present(loginVC, animated: false, completion: nil)
            print("successfully signed out")
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError)")
        }
        
    }

    static let sharedInstance = FirebaseClient()
    private override init() {
        super.init()
    }
}
