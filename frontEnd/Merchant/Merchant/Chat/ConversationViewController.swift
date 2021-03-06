//
//  ConversationViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/21/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire
import PusherSwift

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var dockHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var conversationTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    struct ChatMessage {
        let message: String
        let isIncoming: Bool
    }
    
    var conversationID = ""
    var currentUser = ""
    var userChattingWith = ""
    var keyboardHeight = 0
    var messages: [ChatMessage] = []
    var pusher: Pusher!

    
    override func viewDidLoad() {
        
        print("Conversattion ID is \(self.conversationID)")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.messageTextField.delegate = self
        self.conversationTableView.delegate = self
        self.conversationTableView.dataSource = self
        
        //add tap gesture recognizer to tableview to stop editing
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        self.conversationTableView.addGestureRecognizer(tapGesture)
        
        //initialize tableview
        conversationTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "messageCell")
        
        //get keyboard height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //set title to be username of user chatting with
        navigationItem.title = userChattingWith
        
        //scroll to bottom of coversation
        scrollToBottom()
        
        //TODO
        //load in conversation between currentUser and userChattingWith into messages array
        
        // listen for messages
        let options = PusherClientOptions(
            host: .cluster("us2")
        )
        
        pusher = Pusher(
            key: "0abb5543b425a847ea81",
            options: options
        )
        pusher.connect()
        
        
        // subscribe to channel
        let channelName = currentUser + "-" + userChattingWith
        print(channelName)
        let channel = pusher.subscribe(channelName)
        
        // bind a callback to handle an event
        let _ = channel.bind(eventName: "my-event", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    print(message)
                    self.messages.append(ConversationViewController.ChatMessage(message: message, isIncoming: true))
                    self.conversationTableView.reloadData()
                    self.scrollToBottom()
                }
            }
        })
        
    }
    
    override func viewWillLayoutSubviews() {
        scrollToBottom()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        //send the message
//        self.messageTextField.endEditing(true)
        if (messageTextField.text != "" && self.conversationID != "") {
            // nothing should happen if message is empty or conversation ID doesn not exist
            

            
            self.messages.append(ConversationViewController.ChatMessage(message: self.messageTextField.text ?? "", isIncoming: false))
            
            struct parameters: Encodable {
                var userSender = ""
                var userReceiver = ""
                var message = ""
                var conversationID = ""
            }
            
            let details = parameters(userSender: self.currentUser, userReceiver: self.userChattingWith, message: messageTextField.text ?? "", conversationID: self.conversationID)
            
            print("sending to channel \(self.userChattingWith)-\(self.currentUser)")
            
            self.messageTextField.text = ""
            
            AF.request(API.URL + "/user/message", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).response { response in
                
                // deal with the request
                if (response.response?.statusCode != 200) {
                    debugPrint("ERROR")
                    let alert = UIAlertController(title: "Error!", message: "Message could not be sent", preferredStyle: .alert)
                    
                    
                    // Create Confirm button with action handler
                    let confirm = UIAlertAction(title: "OK",
                                                style: .default)
                    
                    // add actions to the alert
                    alert.addAction(confirm)
                    
                    // display alert
                    self.present(alert, animated: true)
                } else {
                    

                }
                
                
            }.resume()
            
            
        } else {
            debugPrint("empty message or conversation ID")
        }
    }
    
    func scrollToBottom() {
        if (messages.count > 0) {
            self.conversationTableView.reloadData()
            let indexPath = NSIndexPath(row: self.messages.count-1, section: 0)
            self.conversationTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func tableViewTapped() {
        self.messageTextField.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
              keyboardHeight = Int(keyboardRect.height)
            print(keyboardHeight)
        }
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            print("Animation")
            print(self.keyboardHeight)
            self.dockHeightConstraint.constant = CGFloat(self.keyboardHeight) + 20
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        scrollToBottom()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //move dock up
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            print("Animation")
            print(self.keyboardHeight)
            self.dockHeightConstraint.constant = CGFloat(self.keyboardHeight) + 20
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        scrollToBottom()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //move dock back down
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.dockHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        scrollToBottom()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
        cell.backgroundColor = .clear
        cell.messageLabel.text = messages[indexPath.row].message
        cell.isIncoming = messages[indexPath.row].isIncoming
        
        return cell
    }
    

     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         if (segue.identifier == "toMapView") {
            let vc = segue.destination as! MapViewController
            vc.conversationID = self.conversationID
            vc.receiver = self.userChattingWith
            vc.currentUser = self.currentUser
            vc.userChattingWith = self.userChattingWith
         }
         
     }

}
