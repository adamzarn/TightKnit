//
//  LoginViewController.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailTextField.text = "alyssa.linnane@my.wheaton.edu"
        passwordTextField.text = "May121992"
        aiv.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        aiv.startAnimating()
        aiv.isHidden = false
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
            if let user = user {
                self.signedIn(user: user)
                self.appDelegate.email = user.email
                self.appDelegate.name = user.uid
                FirebaseClient.sharedInstance.getUserData(uid: user.uid, completion: { (userData, error) -> () in
                    if let userData = userData {
                        self.appDelegate.name = userData.value(forKey: "name") as! String?
                        let fabricsVC = self.storyboard?.instantiateViewController(withIdentifier: "FabricsViewController") as! FabricsViewController
                        self.present(fabricsVC, animated: true, completion: nil)
                        self.aiv.isHidden = true
                        self.aiv.stopAnimating()
                    } else {
                        print(error!)
                    }
                })
            } else {
                print("login unsuccessful")
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func signedIn(user: FIRUser?) {
        
        appDelegate.uid = user?.uid
        print("\(user?.email!) is signed in")
    }

    @IBAction func createProfileButtonPressed(_ sender: Any) {
        
        let createVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateProfileViewController") as! CreateProfileViewController
        self.present(createVC, animated: true, completion: nil)

    }
}
