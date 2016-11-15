//
//  CreateProfileViewController.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class CreateProfileViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func createButtonPressed(_ sender: Any) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
            if let user = user {
                self.signedIn(user: user)
                let fabricsVC = self.storyboard?.instantiateViewController(withIdentifier: "FabricsViewController") as! FabricsViewController
                self.present(fabricsVC, animated: true, completion: nil)
            } else {
                print("profile creation unsuccessful")
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func signedIn(user: FIRUser?) {
        FirebaseClient.sharedInstance.addNewUser(uid: (user?.uid)!, name: nameTextField.text!, email: emailTextField.text!)
        print("\(user?.email!) is signed in")
    }
    
}
