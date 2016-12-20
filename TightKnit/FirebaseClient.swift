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
        
        completion(newGroupRef.key as NSString?)
    
    }
    
    func listenForNewMessages(completion: @escaping (_ success: Bool) -> ()) {
        ref.observe(.value, with: { snapshot in
            completion(true)
        })
    }
    
    func postMessage(fabric: String, message: String, name: String, timestamp: String, completion: @escaping (_ success: Bool) -> ()) {
        let messagesRef = self.ref.child("Fabrics").child(fabric).child("messages")
        messagesRef.child(timestamp).child("message").setValue(message)
        messagesRef.child(timestamp).child("postedBy").setValue(name)
        completion(true)
    }
    
    
    func getAllMessages(fabric: String, completion: @escaping (_ results: NSDictionary?, _ error: NSString?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fabric = ((snapshot.value! as! NSDictionary)["Fabrics"] as! NSDictionary)[fabric] {
                let messages = (fabric as! NSDictionary)["messages"]
                completion(messages as? NSDictionary, nil)
            } else {
                completion(nil, "Could not retrieve data")
            }
        })
    }
    
    func getAllFabricKeys(completion: @escaping (_ results: [String]?, _ error: NSString?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fabricsData = (snapshot.value! as! NSDictionary)["Fabrics"] {
                let fabricKeys = (fabricsData as! NSDictionary).allKeys as! [String]
                completion(fabricKeys, nil)
            } else {
                completion(nil, "Could not retrieve data")
            }
        })
    }
    
    func getAdminName(key: String, completion: @escaping (_ name: String?, _ error: NSString?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fabric = ((snapshot.value! as! NSDictionary)["Fabrics"] as! NSDictionary)[key] {
                let adminKey = (fabric as! NSDictionary)["administrator"]
                self.ref.observeSingleEvent(of: .value, with: { snapshot in
                    if let adminInfo = ((snapshot.value! as! NSDictionary)["Users"] as! NSDictionary)[adminKey!] {
                        let adminName = (adminInfo as! NSDictionary)["name"]
                        completion(adminName as? String,nil)
                    }
                })
            } else {
                completion(nil, "Could not retrieve data")
            }
        })
    }
    
    func getFabricName(key: String, completion: @escaping (_ name: String?, _ error: NSString?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fabric = ((snapshot.value! as! NSDictionary)["Fabrics"] as! NSDictionary)[key] {
                let fabricName = (fabric as! NSDictionary)["name"]
                completion(fabricName as! String?,nil)
            } else {
                completion(nil, "Could not retrieve data")
            }
        })
    }
    
    func getFabrics(uid: String, completion: @escaping (_ keys: [String]?, _ names: [String]?, _ error: String?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let userData = ((snapshot.value! as! NSDictionary)["Users"] as! NSDictionary)[uid] {
                var keys = [] as [String]
                var names = [] as [String]
                if let fabrics = (userData as! NSDictionary)["fabrics"] {
                    if (fabrics as! NSDictionary) != [:] {
                        var i = 1
                        for (_, value) in fabrics as! NSDictionary {
                            self.ref.observeSingleEvent(of: .value, with: { snapshot in
                                if let fabricData = ((snapshot.value! as! NSDictionary)["Fabrics"] as! NSDictionary)[value] {
                                    let key = value
                                    let name = (fabricData as! NSDictionary)["name"]
                                    keys.append(key as! String)
                                    names.append(name as! String)
                                    if i == (fabrics as! NSDictionary).count {
                                        completion(keys, names, nil)
                                    } else {
                                        i = i + 1
                                    }
                                }
                            })
                        }
                    }
                } else {
                    completion([] as [String], [] as [String], nil)
                }
            } else {
                completion(nil, nil, "Could not retrieve data")
            }
        })
    }
    
    func addNewUser(uid: String, name: String, email: String) {
        
        let userRef = self.ref.child("Users/\(uid)")
        let newUser = User(uid: uid, name: name, email: email)
        userRef.setValue(newUser.toAnyObject())
        
        appDelegate.uid = uid
        appDelegate.email = email
        appDelegate.name = name
        
    }
    
    func joinFabric(uid: String, fabricKey: String) {
        
        let fabricRef = self.ref.child("Users").child(uid).child("fabrics").childByAutoId()
        fabricRef.setValue(fabricKey)
        
        let membersRef = self.ref.child("Fabrics").child(fabricKey).child("members").childByAutoId()
        membersRef.setValue(appDelegate.uid)
        
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
