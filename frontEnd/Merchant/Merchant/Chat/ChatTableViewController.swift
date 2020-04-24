//
//  ChatTableViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 4/9/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire
import PusherSwift


class ChatTableViewController: UITableViewController {
    
    var currentUser = ""
    var users: [String] = []
    var previews: [String] = []
    var messages: [NSArray] = []
    var conversationIDs: [String] = []
    var messagesTransfer: [ConversationViewController.ChatMessage] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //if new conversation was started in the same session
        if (StateManager.newConversationStarted == true) {
            debugPrint("Refreshing")
            refreshFeed()
            StateManager.newConversationStarted = false
        }
    }
    
    
    func getConversations(completion: @escaping (_ validCode: Int)->()) {
        // #warning Incomplete implementation, return the number of sections
        
        AF.request(API.URL + "/user/conversations/\(currentUser)", method: .get).responseJSON { response in
            
            if (response.response?.statusCode == 200) {
                if let info = response.value {
                    let JSON = info as! NSDictionary
                    if (JSON.value(forKey: "reversed") != nil) { // make sure it is not empty
                        let conversations: NSArray =  JSON.value(forKey: "reversed") as! NSArray
                        for conversation in conversations {
                            let details = conversation as! NSDictionary
                            let temp = details.value(forKey: "lastMessage")! as! NSDictionary
                            let messages = details.value(forKey: "messages")! as! NSArray
                            print(messages)
                            self.users.append(details.value(forKey: "user")! as! String)
                            self.previews.append(temp["text"]! as! String)
                            self.messages.append(messages)
                            self.conversationIDs.append(details.value(forKey: "conversationID")! as! String)
                        }
                    }
                }
            } else {
                debugPrint("ERROR")
                let alert = UIAlertController(title: "Error!", message: "Something went wrong. Please restart the App", preferredStyle: .alert)
                
                
                // Create Confirm button with action handler
                let confirm = UIAlertAction(title: "OK",
                                            style: .default)
                
                // add actions to the alert
                alert.addAction(confirm)
                
                // display alert
                self.present(alert, animated: true)
                
            }
            print("conversattion IDs are \(self.conversationIDs)")
            completion(0)
            
        }.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        refreshFeed()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getConversations() { (validCode) in
            print("LOADING DATA")
            self.tableView.reloadData()
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //TODO
        //load in conversations for current user with both the user they are chatting with
        //and a preview (the last message sent)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        
        cell.usernameLabel.text = users[indexPath.row]
        cell.previewLabel.text = previews[indexPath.row]
        
        return cell
    }
    
    
    @IBAction func refreshFeed(_ sender: UIBarButtonItem) {
        // TODO implement refresh functionality
        self.users = []
        self.previews = []
        self.messages = []
        self.conversationIDs = []
        self.messagesTransfer = []
        
        
        getConversations() { (validCode) in
            self.tableView.reloadData()
        }
    }
    
    func refreshFeed() {
        // TODO implement refresh functionality
        self.users = []
        self.previews = []
        self.messages = []
        self.messagesTransfer = []
        self.conversationIDs = []
        
        
        getConversations() { (validCode) in
            self.tableView.reloadData()
        }
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    // This function enables swipe-to-delete
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // TODO: Aakarshit: remove the chat in the database
            let headers: HTTPHeaders = [
                "Authorization": Authentication.getAuthToken(),
                "Accept": "application/json"
            ]
            AF.request(API.URL + "/deleteConversation/\(self.conversationIDs[indexPath.row])", method: .delete, headers: headers).responseJSON { response in
        
                if (response.response?.statusCode == 200) {
                    self.users.remove(at: indexPath.row)
                    self.previews.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    debugPrint("Conversation has been deleted")
                } else {
                    debugPrint("Conversation couldn't be deleted")
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showConversation") {
            guard let itemDetailViewController = segue.destination as? ConversationViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? ChatTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItemIndex = indexPath.row
            itemDetailViewController.currentUser = currentUser
            
            
            
            for message in self.messages[selectedItemIndex] {
                let messageDictionary = message as! NSDictionary
                print(messageDictionary["text"]!)
                if (messageDictionary["sender"]! as! String == currentUser) {
                    self.messagesTransfer.append(ConversationViewController.ChatMessage(message: messageDictionary["text"]! as! String , isIncoming: false))
                } else {
                    self.messagesTransfer.append(ConversationViewController.ChatMessage(message: messageDictionary["text"]! as! String , isIncoming: true))
                }
            }
            itemDetailViewController.messages = self.messagesTransfer.reversed()
            itemDetailViewController.conversationID = self.conversationIDs[selectedItemIndex]
            itemDetailViewController.userChattingWith = self.users[selectedItemIndex]
        }
    }
    
    
}
