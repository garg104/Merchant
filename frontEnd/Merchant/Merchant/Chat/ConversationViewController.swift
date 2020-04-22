//
//  ConversationViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/21/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

struct ChatMessage {
    let message: String
    let isIncoming: Bool
}

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var conversationTableView: UITableView!
    
    let messages = [
        ChatMessage(message: "Hello", isIncoming: true),
        ChatMessage(message: "Hey!", isIncoming: false),
        ChatMessage(message: "What's up?", isIncoming: true),
        ChatMessage(message: "This is a longer message that should wrap down to multiple lines", isIncoming: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.conversationTableView.delegate = self
        self.conversationTableView.dataSource = self
        
        conversationTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "messageCell")
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
