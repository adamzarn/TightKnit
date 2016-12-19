//
//  ChatViewController.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageTextField: UITextField!

    var count = 1
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let screenSize = UIScreen.main.bounds
    let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.height
        
        messageTextField.frame = CGRect(x: 0, y: screenSize.height-tabBarHeight!-30, width: screenSize.width, height: 30)
        
        scrollView.frame = CGRect(x: 0, y: navBarHeight! + statusBarHeight, width: screenSize.width, height: screenSize.height - statusBarHeight - navBarHeight! - tabBarHeight! - 30)
        
        scrollView.contentSize = CGSize(width: screenSize.width, height: 2*screenSize.height)
        
        updateMessages()
        
    }
    
    func updateMessages() {
        FirebaseClient.sharedInstance.getAllMessages(fabric: appDelegate.selectedFabricKey!, completion: { (messages, error) -> () in
            if let messages = messages {
                let keys = messages.allKeys as! [String]
                let sortedKeys = keys.sorted {
                    $0 < $1
                }
                
                var i = 0
                for key in sortedKeys {
                    let half = Int(self.screenSize.width/2)
                    let messageInfo = messages[key] as! [String:String]

                    var left = 1
                    if self.appDelegate.name == messageInfo["postedBy"] {
                        left = 0
                    }
                    
                    let x = half - (half*left) + 10
                    let width = half - 20
                    
                    let newTextView = UITextView(frame: CGRect(x: x, y: 25 + (100*i), width: width, height: 50))
                    let nameLabel = UILabel(frame: CGRect(x: x, y: 5 + (100*i), width: width, height: 20))
                    let timeLabel = UILabel(frame: CGRect(x: x, y: 80 + (100*i), width: width, height: 20))
                    
                    newTextView.text = messageInfo["message"]
                    nameLabel.text = messageInfo["postedBy"]
                    let year = key.substring(to: 4)
                    let month = key.substring(with: 4..<6)
                    let day = key.substring(with: 6..<8)
                    let time = key.substring(with: 9..<14)
                    timeLabel.text = "\(month)/\(day)/\(year) \(time)"
            
                    newTextView.backgroundColor = .gray
                    newTextView.textColor = .white
                    nameLabel.font = UIFont.systemFont(ofSize: 10)
                    timeLabel.textAlignment = .right
                    timeLabel.font = UIFont.systemFont(ofSize: 10)
        
                    self.scrollView.addSubview(newTextView)
                    self.scrollView.addSubview(nameLabel)
                    self.scrollView.addSubview(timeLabel)
                    
                    i += 1

                }
                
            } else {
                print("what")
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.messageTextField.delegate = self
    }
    
    @IBAction func fabricsButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func getCurrentDateAndTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd hh:mm:ss:SSSS"
        let stringDate = formatter.string(from: date)
        return stringDate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        FirebaseClient.sharedInstance.postMessage(fabric: appDelegate.selectedFabricKey!, message: messageTextField.text!, name: appDelegate.name!, timestamp: getCurrentDateAndTime(), completion: { (success) in
            if success {
                self.updateMessages()
                textField.text = ""
            }
        })
        
        return true
    }
    
    func keyboardWillChange(_ notification: NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.height
        let keyboardHeight = keyboardRectangle.height
        let textFieldHeight = messageTextField.frame.size.height
        
        if notification.name == .UIKeyboardWillShow {
            messageTextField.frame = CGRect(x: 0, y: screenSize.height-keyboardHeight-textFieldHeight, width: screenSize.width, height: textFieldHeight)
            scrollView.frame = CGRect(x: 0, y: navBarHeight! + statusBarHeight, width: screenSize.width, height: screenSize.height - statusBarHeight - navBarHeight! - keyboardHeight - textFieldHeight)
        } else {
            messageTextField.frame = CGRect(x: 0, y: screenSize.height-tabBarHeight!-textFieldHeight, width: screenSize.width, height: textFieldHeight)
            scrollView.frame = CGRect(x: 0, y: navBarHeight! + statusBarHeight, width: screenSize.width, height: screenSize.height - statusBarHeight - navBarHeight! - tabBarHeight! - textFieldHeight)
        }
        
    }

}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

