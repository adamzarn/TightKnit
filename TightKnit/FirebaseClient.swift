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
        
        let adminKeyRef = newGroupRef.child("adminKey")
        adminKeyRef.setValue(appDelegate.uid)
        
        let adminNameRef = newGroupRef.child("adminName")
        adminNameRef.setValue(appDelegate.name)
        
        completion(newGroupRef.key as NSString?)
    
    }
    
    func listenForNewMessages(completion: @escaping (_ success: Bool) -> ()) {
        ref.observe(.value, with: { snapshot in
            completion(true)
        })
    }
    
    func postMessage(fabric: String, message: String, name: String, timestamp: String, completion: @escaping (_ success: Bool) -> ()) {
        let messagesRef = self.ref.child("Fabrics").child(fabric).child("messages").childByAutoId()
        messagesRef.child("timestamp").setValue(timestamp)
        messagesRef.child("message").setValue(message)
        messagesRef.child("postedBy").setValue(name)
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
    
    func getAllFabricMemberKeys(fabric: String, completion: @escaping (_ memberKeys: [String]?, _ error: NSString?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fabric = ((snapshot.value! as! NSDictionary)["Fabrics"] as! NSDictionary)[fabric] {
                let membersDict = (fabric as! NSDictionary)["members"] as! NSDictionary
                let memberKeys = membersDict.allValues
                completion(memberKeys as? [String], nil)
            } else {
                completion(nil, "Could not retrieve data")
            }
        })
    }
    
    func getAllFabrics(completion: @escaping (_ fabrics: [Fabric]?, _ error: NSString?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fabricsData = (snapshot.value! as! NSDictionary)["Fabrics"] {
                var fabricsArray: [Fabric] = []
                for (key, value) in fabricsData as! NSDictionary {
                    let info = value as! NSDictionary
                    let name = info.value(forKey: "name") as! String
                    let adminKey = info.value(forKey: "adminKey") as! String
                    let adminName = info.value(forKey: "adminName") as! String
                    let fabric = Fabric(key: key as! String, name: name, adminKey: adminKey, adminName: adminName)
                    fabricsArray.append(fabric)
                }
                completion(fabricsArray, nil)
            } else {
                completion(nil, "Could not retrieve data")
            }
        })
    }
    
    func getAdminKey(fabric: String, completion: @escaping (_ key: String?, _ error: NSString?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let fabricData = ((snapshot.value! as! NSDictionary)["Fabrics"] as! NSDictionary)[fabric] {
                let adminKey = (fabricData as! NSDictionary)["adminKey"]
                completion(adminKey as? String, nil)
            } else {
                completion(nil, "Could not retrieve data")
            }
        })
    }
    
    func getAdminName(adminKey: String, completion: @escaping (_ name: String?, _ error: NSString?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let adminInfo = ((snapshot.value! as! NSDictionary)["Users"] as! NSDictionary)[adminKey] {
                let adminName = (adminInfo as! NSDictionary)["adminName"]
                completion(adminName as? String, nil)
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
    
    func getFabricsOfUser(uid: String, completion: @escaping (_ fabrics: [Fabric]?, _ error: String?) -> ()) {
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let userData = ((snapshot.value! as! NSDictionary)["Users"] as! NSDictionary)[uid] {
                var fabricsArray: [Fabric] = []
                if let fabrics = (userData as! NSDictionary)["fabrics"] {
                    if (fabrics as! NSDictionary) != [:] {
                        self.ref.observeSingleEvent(of: .value, with: { snapshot in
                            for (_, value) in fabrics as! NSDictionary {
                                if let info = ((snapshot.value! as! NSDictionary)["Fabrics"] as! NSDictionary)[value] {
                                    let infoDict = info as! NSDictionary
                                    let key = value as! String
                                    let name = infoDict.value(forKey: "name") as! String
                                    let adminKey = infoDict.value(forKey: "adminKey") as! String
                                    let adminName = infoDict.value(forKey: "adminName") as! String
                                    let fabric = Fabric(key: key, name: name, adminKey: adminKey, adminName: adminName)
                                    fabricsArray.append(fabric)
                                }
                            }
                            completion(fabricsArray, nil)
                        })
                    }
                }
            } else {
                completion(nil, "Could not retrieve data")
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
