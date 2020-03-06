//
//  ProfileViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 2/17/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var sellHistoryButton: UIButton!
    @IBOutlet weak var resetPasswordLabel: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    var firstName = ""
    var lastName = ""
    var name = ""
    var username = ""
    var email = ""
    
    @IBAction func unwindToProfileViewController(segue: UIStoryboardSegue) {
        
        if (segue.identifier == "saveEditUnwind") {
        
            if let senderVC = segue.source as? EditProfileViewController {
              
                // check the return values from editViewController and update accordingly
                if (senderVC.newFirstName != "") {
                    firstName = senderVC.newFirstName
                }
                if (senderVC.newLastName != "") {
                    lastName = senderVC.newLastName
                }
                if (senderVC.newUsername != "" && senderVC.newUsername != senderVC.oldUsername) {
                    username = senderVC.newUsername
                }
                
                // set the text in the labels
                usernameLabel.text = username
                nameLabel.text = firstName + " " + lastName
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //display user info
        usernameLabel.text = username
        nameLabel.text = name
        emailLabel.text = email
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //add border to profile picture
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.borderWidth = 3.0
        self.profilePicture.layer.borderColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        //round profile picture
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        //add underlines to buttons
        addOverlines()
    }
    
    func addOverlines() {
        //create underline for username and password textfields
        let underLine = CALayer()
        underLine.frame = CGRect(x: 0, y: 0, width: sellHistoryButton.frame.width, height: 0.5)
        underLine.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        let underLine2 = CALayer()
        underLine2.frame = CGRect(x: 0, y: 0, width: resetPasswordLabel.frame.width, height: 0.5)
        underLine2.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        let underLine3 = CALayer()
        underLine3.frame = CGRect(x: 0, y: 0, width: deleteAccountButton.frame.width, height: 0.5)
        underLine3.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        let underLine4 = CALayer()
        underLine4.frame = CGRect(x: 0, y: 0, width: deleteAccountButton.frame.width, height: 0.5)
        underLine4.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        resetPasswordLabel.layer.addSublayer(underLine2)
        deleteAccountButton.layer.addSublayer(underLine3)
        logoutButton.layer.addSublayer(underLine4)
    }
    

    @IBAction func deleteAccount(_ sender: UIButton) {
        // create alert
        let alert = UIAlertController(title: "Confirm Deletion!", message: "Please confirm if you wish to delete your account", preferredStyle: .alert)
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel,
                                   handler: { (action) -> Void in
            // add action if needed
        })
        
        // Create Confirm button with action handler
        let confirm = UIAlertAction(title: "Confirm",
                                    style: .default,
                                    handler: { (action) -> Void in
            self.deleteAccountHandler()
        })

        // add actions to the alert
        alert.addAction(confirm)
        alert.addAction(cancel)

        // display alert
        self.present(alert, animated: true)
        
    }
    
    func deleteAccountHandler() {
      struct parameter: Encodable {
          var username: String
      }
      let details = parameter(username: usernameLabel.text!)
      AF.request(API.URL + "/user/delete", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
          
          if (response.response?.statusCode != 200) {
              // for now very basic FALIURE MESSAGE. WILL NEED TO CHANGE.
              let alert = UIAlertController(title: "Could Not Delete Account", message: "Your account could not be deleted. Please try again.", preferredStyle: .alert)
              alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
              self.present(alert, animated: true)
          } else {
              let alert = UIAlertController(title: "Account Deleted", message: "Your account has successfully been deleted", preferredStyle: .alert)
              let okDeleteion = UIAlertAction( title: "Ok",
                                               style: .cancel,
                                               handler: { (action) -> Void in self.performSegue(withIdentifier: "unwindAfterDelete", sender: nil)})
              alert.addAction(okDeleteion)
              self.present(alert, animated: true)
          }
      }
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //do anything that needs to be done before logging out here
        
        if (segue.identifier == "toEditProfile") {
            let vc = segue.destination as! EditProfileViewController
            vc.oldUsername = usernameLabel.text!
            vc.oldFirstName = firstName
            vc.oldLastName = lastName
        }
        
        if (segue.identifier == "toResetPassword") {
            let vc = segue.destination as! ResetPasswordViewController
            vc.username = usernameLabel.text!
        }
        
    }
    

}
