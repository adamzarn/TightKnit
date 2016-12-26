//
//  ChatViewController.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/14/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageTextView: UITextView!
    
    var tabBarHeight = CGFloat(0.0)
    var navBarHeight = CGFloat(0.0)
    var keyboardHeight = CGFloat(0.0)
    let sendButton = UIButton()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let screenSize = UIScreen.main.bounds
    let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    var lastTotalHeight = 0
    var keyboardShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        FirebaseClient.sharedInstance.listenForNewMessages(completion: { (success) in
            if success {
                self.updateMessages()
            }
        })
        
        tabBarHeight = (self.tabBarController?.tabBar.frame.size.height)!
        navBarHeight = (self.navigationController?.navigationBar.frame.height)!
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        messageTextView.text = "Write Message"
        messageTextView.font = UIFont.systemFont(ofSize: 16.0)
        messageTextView.sizeToFit()
        messageTextView.frame.origin = CGPoint(x: 10, y: screenSize.height - tabBarHeight - messageTextView.frame.size.height - 5)
        messageTextView.frame.size.width = screenSize.width - 20
        messageTextView.textColor = .lightGray
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.layer.borderWidth = 1.0;
        messageTextView.layer.cornerRadius = 5.0;
        messageTextView.delegate = self
        messageTextView.isScrollEnabled = false
        
        let buttonSide = messageTextView.frame.size.height - 10
        
        sendButton.frame = CGRect(x: messageTextView.frame.size.width - buttonSide - 5, y: 5, width: buttonSide, height: buttonSide)
        sendButton.backgroundColor = UIColor(red: 81.0/255.0, green: 148.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        sendButton.layer.cornerRadius = buttonSide/2
        sendButton.addTarget(self, action: #selector(ChatViewController.sendButtonPressed), for: UIControlEvents.touchUpInside)
        sendButton.isEnabled = false
        messageTextView.addSubview(sendButton)
        
        scrollView.frame = CGRect(x: 0, y: navBarHeight + statusBarHeight, width: screenSize.width, height: screenSize.height - statusBarHeight - navBarHeight - tabBarHeight - 40)
        
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: buttonSide + 5)
        
        updateMessages()
        
    }
    
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        if keyboardShowing {
            self.messageTextView.resignFirstResponder()
        }
    }
    
    func updateMessages() {
        
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        FirebaseClient.sharedInstance.getAllMessages(fabric: appDelegate.selectedFabricKey!, completion: { (messages, error) -> () in
            if let messages = messages {
                
                var allMessages: [Message] = []
                for (_, value) in messages {
                    let messageData = value as! NSDictionary
                    let message = messageData.value(forKey: "message") as! String
                    let postedBy = messageData.value(forKey: "postedBy") as! String
                    let timestamp = messageData.value(forKey: "timestamp") as! String
                    let newMessage = Message(message: message, postedBy: postedBy, timestamp: timestamp)
                    allMessages.append(newMessage)
                }
                
                allMessages.sort { $0.timestamp < $1.timestamp }
                
                var totalHeight = 5
                for message in allMessages {
                    
                    let newTextView = UITextView()
                    let timeLabel = UILabel()
                    let nameLabel: UILabel?
                    newTextView.font = UIFont.systemFont(ofSize: 16.0)
                    newTextView.layer.cornerRadius = 5
                    newTextView.text = message.message
                    newTextView.isScrollEnabled = false
                    newTextView.isEditable = false
                    newTextView.frame.size.width = (self.screenSize.width - 20)*(3/4)
                    newTextView.sizeToFit()
                    let w = Int(newTextView.frame.size.width)
                    
                    var x = Int(self.screenSize.width) - w - 10
                    timeLabel.textAlignment = .right
                    newTextView.backgroundColor = UIColor(red: 76.0/255.0, green: 181.0/255.0, blue: 61.0/255.0, alpha: 1.0)
                    if self.appDelegate.name != message.postedBy {
                        timeLabel.textAlignment = .left
                        x = 10
                        newTextView.backgroundColor = .lightGray
                        nameLabel = UILabel()
                        nameLabel!.text = message.postedBy
                        nameLabel!.font = UIFont.systemFont(ofSize: 10)
                        nameLabel!.frame = CGRect(x: x, y: totalHeight, width: Int(self.screenSize.width) - 20, height: 15)
                        self.scrollView.addSubview(nameLabel!)
                        totalHeight += Int(nameLabel!.frame.size.height)
                    }
                    
                    let fixedWidth = newTextView.frame.size.width
                    newTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                    let newSize = newTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                    var newFrame = newTextView.frame
                    newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                    newTextView.frame = newFrame
                    
                    newTextView.frame.origin = CGPoint(x: x, y: totalHeight)
                    timeLabel.frame = CGRect(x: 10, y: totalHeight + Int(newFrame.size.height), width: Int(self.screenSize.width) - 20, height: 15)
                    
                    let ts = message.timestamp
                    let year = ts.substring(with: 2..<4)
                    let month = Int(ts.substring(with: 4..<6))
                    let day = Int(ts.substring(with: 6..<8))
                    var hour = Int(ts.substring(with: 9..<11))
                    let minute = ts.substring(with: 12..<14)
                    var suffix = "AM"
                    if hour! > 11 {
                        suffix = "PM"
                    }
                    if hour! > 12 {
                        hour = hour! - 12
                    }

                    timeLabel.text = "\(month!)/\(day!)/\(year) \(hour!):\(minute) \(suffix)"
                    
                    newTextView.textColor = .white
                    
                    timeLabel.font = UIFont.systemFont(ofSize: 10)
        
                    self.scrollView.addSubview(newTextView)
                    self.scrollView.addSubview(timeLabel)
                    
                    totalHeight += Int(newFrame.height) + Int(timeLabel.frame.size.height) + 10
                    self.lastTotalHeight = totalHeight

                }
                
                if totalHeight > Int(self.scrollView.frame.size.height) {
                    self.scrollView.contentSize = CGSize(width: self.screenSize.width, height: CGFloat(totalHeight))
                    let bottomOffset = CGPoint(x: 0, y: totalHeight - Int(self.scrollView.bounds.size.height))
                    self.scrollView.setContentOffset(bottomOffset, animated: false)
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
    
    @IBAction func fabricsButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func moveCursorToStart(textView: UITextView) {
        DispatchQueue.main.async {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        moveCursorToStart(textView: textView)
        return true
    }
    
    func applyPlaceholderStyle(textView: UITextView, placeholderText: String) {
        textView.textColor = .lightGray
        textView.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(textView: UITextView) {
        textView.textColor = .black
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != nil {
            sendButton.isEnabled = true
            textView.textColor = .black
        } else {
            sendButton.isEnabled = false
            textView.text = "Write Message"
            textView.textColor = .lightGray
            
        }
        
        messageTextView.sizeToFit()
        messageTextView.frame.size.width = screenSize.width - 20
        let textViewHeight = messageTextView.frame.size.height
        
        messageTextView.frame = CGRect(x: 10, y: screenSize.height - keyboardHeight - textViewHeight - 5, width: screenSize.width - 20, height: textViewHeight)
        
        scrollView.frame = CGRect(x: 0, y: navBarHeight + statusBarHeight, width: screenSize.width, height: screenSize.height - statusBarHeight - navBarHeight - keyboardHeight - textViewHeight)
        
        if lastTotalHeight > Int(self.scrollView.frame.size.height) {
            let bottomOffset = CGPoint(x: 0, y: lastTotalHeight - Int(self.scrollView.bounds.size.height))
            self.scrollView.setContentOffset(bottomOffset, animated: false)
        }

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            if textView.text == "Write Message" {
                if text.utf16.count == 0 {
                    return false
                }
                applyNonPlaceholderStyle(textView: textView)
                textView.text = ""
            }
            return true
        } else {
            applyPlaceholderStyle(textView: textView, placeholderText: "Write Message")
            moveCursorToStart(textView: textView)
            return false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write Message"
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    func getCurrentDateAndTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd HH:mm:ss:SSS"
        let stringDate = formatter.string(from: date)
        return stringDate
    }
    
    func resetTextView() {
        messageTextView.text = "Write Message"
        messageTextView.textColor = .lightGray
        messageTextView.font = UIFont.systemFont(ofSize: 16.0)
        messageTextView.sizeToFit()
        let textViewHeight = messageTextView.frame.size.height
        messageTextView.frame = CGRect(x: 10, y: screenSize.height-keyboardHeight-textViewHeight - 5, width: screenSize.width - 20, height: textViewHeight)
        scrollView.frame = CGRect(x: 0, y: navBarHeight + statusBarHeight, width: screenSize.width, height: screenSize.height - statusBarHeight - navBarHeight - keyboardHeight - textViewHeight)
    }
    
    func sendButtonPressed() {
        FirebaseClient.sharedInstance.postMessage(fabric: appDelegate.selectedFabricKey!, message: messageTextView.text!, name: appDelegate.name!, timestamp: getCurrentDateAndTime(), completion: { (success) in
            if success {
                self.updateMessages()
                self.sendButton.isEnabled = false
                self.moveCursorToStart(textView: self.messageTextView)
                self.resetTextView()
            }
        })
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func keyboardWillChange(_ notification: NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.height
        keyboardHeight = keyboardRectangle.height
        let textViewHeight = messageTextView.frame.size.height
        
        if notification.name == .UIKeyboardWillShow {
            keyboardShowing = true
            messageTextView.frame = CGRect(x: 10, y: screenSize.height-keyboardHeight-textViewHeight - 5, width: screenSize.width - 20, height: textViewHeight)
            scrollView.frame = CGRect(x: 0, y: navBarHeight! + statusBarHeight, width: screenSize.width, height: screenSize.height - statusBarHeight - navBarHeight! - keyboardHeight - textViewHeight)
        } else {
            keyboardShowing = false
            messageTextView.frame = CGRect(x: 10, y: screenSize.height-tabBarHeight!-textViewHeight - 5, width: screenSize.width - 20, height: textViewHeight)
            scrollView.frame = CGRect(x: 0, y: navBarHeight! + statusBarHeight, width: screenSize.width, height: screenSize.height - statusBarHeight - navBarHeight! - tabBarHeight! - textViewHeight)
        }
        if lastTotalHeight > Int(scrollView.frame.size.height) {
            let bottomOffset = CGPoint(x: 0, y: lastTotalHeight - Int(self.scrollView.bounds.size.height))
            self.scrollView.setContentOffset(bottomOffset, animated: false)
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

