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
                if (senderVC.profilePicture != self.profilePicture.image) {
                    self.profilePicture.image = senderVC.profilePicture
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
        
        //display the profile picture
        profilePictureHandler()
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
    
    func profilePictureHandler() {
        self.profilePicture.image = UIImage(imageLiteralResourceName: "profile-avatar")
        
        //check for profile picture in the cache
        checkCacheForProfilePicture()
        
        //setting the destination for caching the file
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/profile_\(self.email).data")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        //making the server request
        AF.download(API.URL + "/user/picture/\(self.username)", method: .get, to: destination).responseString { response in
            if (response.response?.statusCode != 200) {
                //render default image
                self.profilePicture.image = self.base64ToUIImage(base64String: "")
            } else {
                //request successful
                if let encodedImageString = response.value {
                    //parsing the base64 encoded string into image data
                    self.profilePicture.image = self.base64ToUIImage(base64String: encodedImageString)
                } //end if
            } //end if
        } //request
    }
    
    func checkCacheForProfilePicture() {
        //checking for cached image data
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/profile_\(self.email).data")
        let filePath = fileURL.path
        let fileManager = FileManager.default
        
        //checking if the required file already exists in the cache
        if fileManager.fileExists(atPath: filePath) {
            do {
                //read the data from the cache
                let base64String = try String(contentsOf: fileURL, encoding: .utf8)
                self.profilePicture.image = self.base64ToUIImage(base64String: base64String)
            } catch {
                //File in cache is corrupted
                debugPrint("Chache Miss, making the request")
            } //end do-catch
        } //end if
    }
    
    func base64ToUIImage(base64String: String?) -> UIImage{
      if (base64String?.isEmpty)! {
          debugPrint("No picture found")
          return UIImage(imageLiteralResourceName: "profile-avatar")
      } else {
          // Separating the metadata from the base64 data
          let temp = base64String?.components(separatedBy: ",")
        if (temp!.count > 1) {
          let dataDecoded : Data = Data(base64Encoded: temp![1], options: .ignoreUnknownCharacters)!
          let decodedimage = UIImage(data: dataDecoded)
            if (decodedimage != nil) {
              return decodedimage!
            } else {
                return self.profilePicture.image!
            }
        } else {
            return self.profilePicture.image!
        }
      } //end if
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
    
    func deleteAllCache() {
        //checking for cached image data
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/")
        let filePath = fileURL.path
        let fileManager = FileManager.default
        debugPrint(filePath)
        
        //checking if the required file already exists in the cache
        if fileManager.fileExists(atPath: filePath) {
            do {
                //read the data from the cache
                try fileManager.removeItem(atPath: filePath)
                debugPrint("Cleared the cache")
            } catch {
                //File in cache is corrupted
                debugPrint("Couldn't clear the cache")
            } //end do-catch
        } //end if
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //do anything that needs to be done before logging out here
        if (segue.identifier == "profileToWelcome") {
            Authentication.logout()
            deleteAllCache()
        }
        
        if (segue.identifier == "toEditProfile") {
            let vc = segue.destination as! EditProfileViewController
            vc.oldUsername = usernameLabel.text!
            vc.oldFirstName = firstName
            vc.oldLastName = lastName
            vc.email = email
            vc.profilePicture = self.profilePicture.image
        }
        
        if (segue.identifier == "toResetPassword") {
            let vc = segue.destination as! ResetPasswordViewController
            vc.username = usernameLabel.text!
        }
        
        if (segue.identifier == "toSellHistory") {
            let navVC = segue.destination as! UINavigationController
            let sellVC = navVC.viewControllers[0] as! SellHistoryTableViewController
            sellVC.currentUser = username
        }
    }
}
