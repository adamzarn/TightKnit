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
    
    var joinedFabrics: [Fabric] = []
    var allFabrics: [Fabric] = []
    var filteredFabrics: [Fabric] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        myTableView.tableHeaderView = searchController.searchBar
        
        self.loggedInAsButton.title = "Logged in as \(appDelegate.name!)"
        self.loggedInAsButton.isEnabled = false
        
        searchBar.showsCancelButton = false
        
        updateFabricList()
        
        FirebaseClient.sharedInstance.getAllFabrics { (fabrics, error) -> () in
            if let fabrics = fabrics {
                self.allFabrics = fabrics
                self.filteredFabrics = []
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
            } else {
                print(error!)
            }
        }

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.view.backgroundColor = .white
        
    }
    
    func updateFabricList() {
        FirebaseClient.sharedInstance.getFabricsOfUser(uid: appDelegate.uid!, completion: { (fabrics, error) -> () in
            if let fabrics = fabrics {
                self.joinedFabrics = fabrics
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
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredFabrics.count
        }
        if searchController.isActive && searchController.searchBar.text == "" {
            return allFabrics.count
        }
        return joinedFabrics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FabricCell
        cell.isUserInteractionEnabled = true
        cell.tag = indexPath.row
        cell.delegate = self
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            let cf = filteredFabrics[indexPath.row]
            
            var joined = false
            let joinedFabricKeys = joinedFabrics.map { $0.key }
            if joinedFabricKeys.contains(cf.key) {
                joined = true
            }
            
            cell.searchingSetUp(name: cf.name, admin: cf.adminName, joined: joined)
            
        } else {
            
            if searchController.isActive && searchController.searchBar.text == "" {
                let cf = allFabrics[indexPath.row]
                var joined = false
                let joinedFabricKeys = joinedFabrics.map { $0.key }
                if joinedFabricKeys.contains(cf.key) {
                    joined = true
                }

                cell.searchingSetUp(name: cf.name, admin: cf.adminName, joined: joined)
                
            } else {
                
                let cf = joinedFabrics[indexPath.row]
                cell.joinedSetUp(name: cf.name, admin: cf.adminName)
                
            }
        }
        
        return cell
        
    }
    
    func joinButtonPressed(index: Int) {
    
        searchBar.resignFirstResponder()
        searchController.isActive = false
        
        if searchController.searchBar.text == "" {
            FirebaseClient.sharedInstance.joinFabric(uid: self.appDelegate.uid!, fabricKey: allFabrics[index].key)
        } else {
            FirebaseClient.sharedInstance.joinFabric(uid: self.appDelegate.uid!, fabricKey: filteredFabrics[index].key)
        }
        
        updateFabricList()
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !searchController.isActive {
            appDelegate.selectedFabricKey = joinedFabrics[indexPath.row].key
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
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        myTableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        print(allFabrics.count)
        filteredFabrics = allFabrics.filter { fabric in
            return (fabric.name.lowercased().contains(searchText.lowercased()))
        }
        myTableView.reloadData()
        myTableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
}

class FabricCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    var delegate: FabricsViewController!
    
    func searchingSetUp(name: String, admin: String, joined: Bool) {
        nameLabel.text = name
        adminLabel.text = "Administrator: \(admin)"
        if joined {
            joinButton.setTitle("Joined", for: .normal)
            joinButton.isEnabled = false
        } else {
            joinButton.setTitle("Join", for: .normal)
            joinButton.isEnabled = true
        }
        
    }
    
    func joinedSetUp(name: String, admin: String) {
        nameLabel.text = name
        adminLabel.text = "Administrator: \(admin)"
        joinButton.setTitle("", for: .normal)
        joinButton.isEnabled = false
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        delegate.joinButtonPressed(index: self.tag)
        
    }
    
}

extension FabricsViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
