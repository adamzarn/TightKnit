//
//  FabricsViewController.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class FabricsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var loggedInAsButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var fabricNames: [String] = []
    var fabricKeys: [String] = []
    var allFabricKeys: [String] = []
    var filteredFabrics: [String] = []
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        self.loggedInAsButton.title = "Logged in as \(appDelegate.name!)"
        self.loggedInAsButton.isEnabled = false
        
        searchBar.showsCancelButton = false
        
        FirebaseClient.sharedInstance.getFabrics(uid: appDelegate.uid!, completion: { (keys, names, error) -> () in
            if let keys = keys, let names = names {
                self.fabricKeys = keys
                self.fabricNames = names
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
        if searching {
            return allFabricKeys.count
        }
        return fabricNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.accessoryType = .none
        cell.isUserInteractionEnabled = true
        if searching {
            FirebaseClient.sharedInstance.getFabricName(key: allFabricKeys[indexPath.row], completion: { (name, error) -> () in
                if let name = name {
                    cell.textLabel?.text = name
                } else {
                    print(error!)
                }
            })
            FirebaseClient.sharedInstance.getAdminName(key: allFabricKeys[indexPath.row], completion: { (name, error) -> () in
                if let name = name {
                    cell.detailTextLabel?.text = "Administrator: \(name)"
                } else {
                    print(error!)
                }
            })
            if fabricKeys.contains(allFabricKeys[indexPath.row]) {
                cell.accessoryType = .checkmark
                cell.isUserInteractionEnabled = false
            }
        } else {
            cell.textLabel?.text = fabricNames[indexPath.row]
            FirebaseClient.sharedInstance.getAdminName(key: fabricKeys[indexPath.row], completion: { (name, error) -> () in
                if let name = name {
                    cell.detailTextLabel?.text = "Administrator: \(name)"
                } else {
                    print(error!)
                }
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            searching = false
            searchBar?.resignFirstResponder()
            FirebaseClient.sharedInstance.joinFabric(uid: self.appDelegate.uid!, fabricKey: allFabricKeys[indexPath.row])
            updateFabricList()
        } else {
            searching = false
            appDelegate.selectedFabricKey = fabricKeys[indexPath.row]
            performSegue(withIdentifier: "fabricSelected", sender: self)
        }
        myTableView.deselectRow(at: indexPath, animated: false)
    
    }
    
    @IBAction func createFabric(_ sender: Any) {
        
        let alert = UIAlertController(title: "Create Fabric", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default, handler: { (_) in
            
            let textField = alert.textFields![0]
            
            FirebaseClient.sharedInstance.createFabric(fabric: textField.text!, completion: { (fabricKey) -> () in
                FirebaseClient.sharedInstance.joinFabric(uid: self.appDelegate.uid!, fabricKey: fabricKey as! String)
                self.updateFabricList()
            })
            
        }))
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Fabric Name"
        })
            
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func updateFabricList() {
        FirebaseClient.sharedInstance.getFabrics(uid: self.appDelegate.uid!, completion: { (keys, names, error) -> () in
            if let keys = keys, let names = names {
                self.fabricKeys = keys
                self.fabricNames = names
                self.myTableView.reloadData()
            } else {
                print(error!)
            }
        })
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        FirebaseClient.sharedInstance.logout(vc: self)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        self.searchBar = searchBar
        searching = true
        FirebaseClient.sharedInstance.getAllFabricKeys { (results, error) -> () in
            if let results = results {
                self.allFabricKeys = results as [String]
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
            } else {
                print(error!)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searching = false
        myTableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredFabrics = filteredFabrics.filter { fabric in
            return (fabric.lowercased().contains(searchText.lowercased()))
        }
        myTableView.reloadData()
        myTableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
}

extension FabricsViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
