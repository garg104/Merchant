//
//  ProfileViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 2/17/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var sellHistoryButton: UIButton!
    @IBOutlet weak var resetPasswordLabel: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    var name = ""
    var username = ""
    var email = ""
    
    @IBAction func unwindToProfileViewController(segue: UIStoryboardSegue) {
        if let senderVC = segue.source as? EditProfileViewController {
            usernameLabel.text = senderVC.newUsername
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addOverlines()
        debugPrint("USERNAME PROF", username)
        //display username
        usernameLabel.text = username
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
        sellHistoryButton.layer.addSublayer(underLine)
        resetPasswordLabel.layer.addSublayer(underLine2)
        deleteAccountButton.layer.addSublayer(underLine3)
        logoutButton.layer.addSublayer(underLine4)
    }
    

    @IBAction func deleteAccount(_ sender: UIButton) {
        
        struct parameter: Encodable {
            var username: String
        }
        
        let details = parameter(username: "asdf")
        AF.request("https://merchant307.herokuapp.com/user/delete", method: .delete, parameters: details, encoder: URLEncodedFormParameterEncoder.default).response { response in
            debugPrint(response)
        }
    }
    
    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true) {
            // after complete
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // check if possible to convert image (prevent crash)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePicture.image = image
        }
        else {
            // Error message
        }
        
        // hide controller bc the user has chosen
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //do anything that needs to be done before logging out here
        
        if (segue.identifier == "toEditProfile") {
            let vc = segue.destination as! EditProfileViewController
            vc.oldUsername = usernameLabel.text!
        }
        
    }
    

}
