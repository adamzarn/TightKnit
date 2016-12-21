//
//  MembersViewController.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var adminKey: String!
    var memberKeys: [String]!
    @IBOutlet weak var myTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FirebaseClient.sharedInstance.getAdminInfo(fabric: appDelegate.selectedFabricKey!, completion: { (key, name, error) -> () in
            if let key = key {
                self.adminKey = key
            } else {
                print("something went wrong")
            }
        })
        
        FirebaseClient.sharedInstance.getAllFabricMemberKeys(fabric: appDelegate.selectedFabricKey!, completion: { (memberKeys, error) -> () in
            if let memberKeys = memberKeys {
                self.memberKeys = memberKeys
                self.myTableView.reloadData()
            } else {
                print("something went wrong")
            }
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let memberKeys = memberKeys {
            return memberKeys.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MemberCell
        
        cell.aiv.startAnimating()
        cell.aiv.isHidden = false
        FirebaseClient.sharedInstance.getUserData(uid: memberKeys[indexPath.row], completion: { (userData, error) -> () in
            if let userData = userData {
                if self.memberKeys[indexPath.row] == self.adminKey {
                    cell.setUp(name: userData.value(forKey: "name") as! String, isAdmin: true)
                } else {
                    cell.setUp(name: userData.value(forKey: "name") as! String, isAdmin: false)
                }
            }
        })
        return cell
    }
    
    @IBAction func fabricButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

class MemberCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var adminLabel: UILabel!
    
    func setUp(name: String, isAdmin: Bool) {
        if isAdmin {
            adminLabel.text = "Administrator"
        } else {
            adminLabel.text = ""
        }
        nameLabel.text = name
        aiv.isHidden = true
        aiv.stopAnimating()
    
    }
    
    
}

