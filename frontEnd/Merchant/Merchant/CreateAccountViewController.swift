//
//  CreateAccountViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/14/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userAgreementsButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    // data from the preovous viewController
    var firstName = ""
    var lastName = ""
    var email = ""
    
    var createAccountAllowed = false
    
    // executes when the button is clicked
    @IBAction func createAccount(_ sender: Any) {
        
        // make sure all the fields were entered
        if (usernameTextField.text == "" ||
            passwordTextField.text == "" ||
            confirmPasswordTextField.text == "") {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter all the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else if (passwordTextField.text != confirmPasswordTextField.text) {
            // check if the passwords are same
            let alert = UIAlertController(title: "Passwords Do Not Match", message: "Please make sure that both the passwords match", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            passwordTextField.text = ""
            confirmPasswordTextField.text = ""
        } else if (!passwordStrength(password: passwordTextField.text!)){
            //password strength checker
            let alert = UIAlertController(title: "Password Not Strong", message: "Password length must be at least 6 characters and include a number, lowercase letter and uppercase letter.", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            passwordTextField.text = ""
            confirmPasswordTextField.text = ""
        } else {
            // check if the username is unique
            // find out a way to dynamically do it
            
            validateFields() { (validCode) in
                
                if (validCode == 201) { //success
                    debugPrint("SUCCESS!!!!")
                    self.performSegue(withIdentifier: "toTabBarFromRegister", sender: nil)
                } else if (validCode == 409) { //username already exists
                    let alert = UIAlertController(title: "Username Already Exists", message: "Please enter different username.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else if (validCode == 500) { //password invalid
                    let alert = UIAlertController(title: "Error", message: "Error while creating account, please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else { //error in database check
                    let alert = UIAlertController(title: "Error", message: "Error while creating account, please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            }
            
//            print(firstName)
//            print(lastName)
//            print(email)
//            print(usernameTextField.text!)
//            print(passwordTextField.text!)
//            print(confirmPasswordTextField.text!)
        }
    }
    
    @IBAction func unwindToCreateAccountViewController(segue: UIStoryboardSegue) {
        
        if (segue.identifier == "declineUnwind") {
            createAccountAllowed = false
            createAccountButton.isEnabled = createAccountAllowed
        }
        
        if (segue.identifier == "acceptUnwind") {
            createAccountAllowed = true
            createAccountButton.isEnabled = createAccountAllowed
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userAgreementsButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) //add agreements border
        createAccountButton.isEnabled = createAccountAllowed
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //add underlines to the textfields
        addUnderlines()
    }
    
    private func validateFields(completion: @escaping (_ validCode: Int)->()) {
        
        struct parameters: Encodable {
            var firstName = ""
            var lastName = ""
            var username = ""
            var password = ""
            var email = ""
            var university = "Purdue University"
        }
        
        let details = parameters(firstName: firstName, lastName: lastName, username: usernameTextField.text!, password: passwordTextField.text!, email: email)
        
        AF.request(API.URL + "/user/register", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).response { response in
            
            //obtain status code returned from request
            let status = (response.response?.statusCode ?? 0)
            
            if (status != 0) {
                switch status {
                case 409: //username exists already
                    completion(status)
                    break
                case 500: //error
                    completion(status)
                    break
                case 201: //success
                    completion(status)
                    break
                default:
                    completion(status)
                    break
                }
            }
            
        }.resume()
            
    }
    
    func passwordStrength(password: String) ->Bool {
        
        if ((password.range(of: "[a-z]", options: .regularExpression) != nil) &&
            (password.range(of: "[A-Z]", options: .regularExpression) != nil) &&
            (password.range(of: "[0-9]", options: .regularExpression) != nil) &&
            (password.count >= 6)) {
            debugPrint("password strong")
            return true
        } else {
            return false
        }
    }
    
    func addUnderlines() {
        //create underline for username and password textfields
        let underLine = CALayer()
        underLine.frame = CGRect(x: 0, y: usernameTextField.frame.height - 2, width: usernameTextField.frame.width, height: 2)
        underLine.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        let underLine2 = CALayer()
        underLine2.frame = CGRect(x: 0, y: usernameTextField.frame.height - 2, width: usernameTextField.frame.width, height: 2)
        underLine2.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        let underLine3 = CALayer()
        underLine3.frame = CGRect(x: 0, y: usernameTextField.frame.height - 2, width: usernameTextField.frame.width, height: 2)
        underLine3.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        usernameTextField.borderStyle = .none
        usernameTextField.layer.addSublayer(underLine)
        passwordTextField.borderStyle = .none
        passwordTextField.layer.addSublayer(underLine2)
        confirmPasswordTextField.borderStyle = .none
        confirmPasswordTextField.layer.addSublayer(underLine3)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "toTabBarFromRegister") {
            let vc = segue.destination as! MainTabBarController
            vc.username = usernameTextField.text!
            vc.firstName = self.firstName
            vc.lastName = self.lastName
            vc.email = self.email
        }
        
    }
    

}
