//
//  EditProfileViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/27/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class EditProfileViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var editUsernameTextField: UITextField!
    @IBOutlet weak var editFirstNameTextField: UITextField!
    @IBOutlet weak var editLastNameTextField: UITextField!
    
    var oldUsername = ""
    var newUsername = ""
    var oldFirstName = ""
    var newFirstName = ""
    var oldLastName = ""
    var newLastName = ""
    var email = ""
    var profilePicture: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.editUsernameTextField.delegate = self
        self.editFirstNameTextField.delegate = self
        self.editLastNameTextField.delegate = self
        
        //adjust view for typing
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //populate textfields with current info
        editUsernameTextField.text = oldUsername
        editFirstNameTextField.text = oldFirstName
        editLastNameTextField.text = oldLastName
        profilePictureImageView.image = profilePicture
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //add border to profile picture
        self.profilePictureImageView.clipsToBounds = true
        self.profilePictureImageView.layer.borderWidth = 3.0
        self.profilePictureImageView.layer.borderColor = UIColor.init(red: 118/255, green: 181/255, blue: 77/255, alpha: 1.0).cgColor
        //round profile picture
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        //add underlines to textfields
        addUnderlines()
    }
    
    func addUnderlines() {
        //create underline for username and password textfields
        let underLine = CALayer()
        underLine.frame = CGRect(x: 0, y: editUsernameTextField.frame.height - 2, width: editUsernameTextField.frame.width, height: 2)
        underLine.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        let underLine2 = CALayer()
        underLine2.frame = CGRect(x: 0, y: editFirstNameTextField.frame.height - 2, width: editFirstNameTextField.frame.width, height: 2)
        underLine2.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        let underLine3 = CALayer()
        underLine3.frame = CGRect(x: 0, y: editLastNameTextField.frame.height - 2, width: editLastNameTextField.frame.width, height: 2)
        underLine3.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        editUsernameTextField.borderStyle = .none
        editUsernameTextField.layer.addSublayer(underLine)
        editFirstNameTextField.borderStyle = .none
        editFirstNameTextField.layer.addSublayer(underLine2)
        editLastNameTextField.borderStyle = .none
        editLastNameTextField.layer.addSublayer(underLine3)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        /*guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue*/
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 50
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    let image = UIImagePickerController()
    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera() }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // MAKE SURE IT WORKS ON DEVICE PROPERLY
        image.delegate = self
        self.present(alert, animated: true)
        self.present(image, animated: true) {
            // after complete
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // check if possible to convert image (prevent crash)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePictureImageView.image = image
            self.profilePicture = image
            let imgJPG: NSData = self.profilePicture.jpegData(compressionQuality: 0.5)! as NSData
            debugPrint("Size of Image: \(imgJPG.length) bytes")
            debugPrint(imgJPG.description)
        }
        else {
            // Error message
        }
        
        // hide controller bc the user has chosen
        self.dismiss(animated: true, completion: nil)
    }
    
    func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            image.sourceType = .camera
            image.allowsEditing = true
            self.present(image, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true, completion: nil)
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        newUsername = editUsernameTextField.text!
        newLastName = editLastNameTextField.text!
        newFirstName = editFirstNameTextField.text!
       
        if (newUsername == "") {
            // display an alert
            let alert = UIAlertController(title: "Empty Field", message: "Please enter a username.", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
       
        struct parameter: Encodable {
            var username: String
            var lastName: String
            var firstName: String
            var newUsername: String
        }
       
        let details = parameter(username: oldUsername,
                                lastName: newLastName,
                                firstName: newFirstName,
                                newUsername: newUsername)

        
        if (self.profilePicture != nil) {
            //uploading the profile picture
            
            //include content type as multipart data to be recognised by multer
            let headers: HTTPHeaders = [
                "Content-type": "multipart/form-data",
                "Accept": "application/json"
            ]
            
            //upload request to the backend
            AF.upload(multipartFormData: {multipartFormData in
                multipartFormData.append(self.profilePicture.jpegData(compressionQuality: 0.1)!, withName: "data", fileName: "\(self.oldUsername).jpg", mimeType: "image/jpeg")
            }, to: API.URL + "/user/picture", headers: headers).responseJSON { response in
                //store the updated profile picture in cache
                self.storeNewProfilePictureInCache()
            } //end response handler
        } //end if

       
        AF.request(API.URL + "/user/updateProfile", method: .put, parameters: details, encoder:    URLEncodedFormParameterEncoder.default).response { response in
            debugPrint(response)
            
            let validationCode = response.response?.statusCode
            
            if (validationCode == 200) { //success
                debugPrint("SUCCESS!!!!")
                self.performSegue(withIdentifier: "saveEditUnwind", sender: nil)
//                let alert = UIAlertController(title: "Profile Updated", message: "", preferredStyle: .alert)
//                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
//                self.present(alert, animated: true)
//                success = 1
            } else if (validationCode == 409) { //username invalid
                let alert = UIAlertController(title: "Username already taken", message: "Please enter an username which has not been taken already.", preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            } else { //error in database check
                let alert = UIAlertController(title: "Error", message: "Profile could not be updated. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func storeNewProfilePictureInCache() {
        //storing the new file in cache
        
        //convert the image to string data
        var imageBase64 =  self.profilePicture.jpegData(compressionQuality: 0.1)?.base64EncodedString()
        
        //get the directory location
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/profile_\(self.email).data")
    
        //if there is error in getting the data, abort cache updation
        if (imageBase64 == nil) {
            return
        }
        
        //append the metadata to the image file
        imageBase64 = "data:image/jpeg;base64," + (imageBase64 ?? "")
        
        //write the file data to the cache
        do {
            try imageBase64?.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            return
        }
    }
    
    
    
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//
//        //update oldUsername to have newUsername
//
//
//
//    }
    

}
