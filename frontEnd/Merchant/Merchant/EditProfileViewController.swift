//
//  EditProfileViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/27/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var editUsernameTextField: UITextField!
    var oldUsername = ""
    var newUsername = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        editUsernameTextField.text = oldUsername
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        //update oldUsername to have newUsername
        newUsername = editUsernameTextField.text!
        
        
    }
    

}
