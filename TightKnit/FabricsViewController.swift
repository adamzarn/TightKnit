//
//  FabricsViewController.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class FabricsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var loggedInAsButton: UIBarButtonItem!
    
    var fabricNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loggedInAsButton.title = "Logged in as \(appDelegate.name!)"
        self.loggedInAsButton.isEnabled = false
        
        FirebaseClient.sharedInstance.getFabricNames(uid: appDelegate.uid!, completion: { (results, error) -> () in
            if let results = results {
                self.fabricNames = results
                self.myTableView.reloadData()
            } else {
                print(error!)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fabricNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = fabricNames[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "fabricSelected", sender: self)
        
    }
    
    @IBAction func createFabric(_ sender: Any) {
        
        let alert = UIAlertController(title: "Create Fabric", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default, handler: { (_) in
            
            let textField = alert.textFields![0]
            
            FirebaseClient.sharedInstance.createFabric(fabric: textField.text!, completion: { (fabricKey) -> () in
                
                FirebaseClient.sharedInstance.joinFabric(uid: self.appDelegate.uid!, fabricKey: fabricKey as! String)
                
                FirebaseClient.sharedInstance.getFabricNames(uid: self.appDelegate.uid!, completion: { (results, error) -> () in
                    if let results = results {
                        self.fabricNames = results
                        self.myTableView.reloadData()
                    } else {
                        print(error!)
                    }
                })
            
            })
            
        }))
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Fabric Name"
        })
            
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        FirebaseClient.sharedInstance.logout(vc: self)
    }
    
}
