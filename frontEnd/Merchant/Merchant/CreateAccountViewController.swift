//
//  CreateAccountViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/14/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    // data from the preovous viewController
    var firstName = ""
    var lastName = ""
    var email = ""
    
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
        } else {
            // check if the username is unique
            // find out a way to dynamically do it
            
            struct parameters: Encodable {
                var firstName = ""
                var lastName = ""
                var username = ""
                var password = ""
                var email = ""
            }
            
            let details = parameters(firstName: firstName, lastName: lastName, username: usernameTextField.text!, password: passwordTextField.text!, email: email)
            
            AF.request(API.URL + "/user/register", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).response { response in
                debugPrint(response)
            }
            
            print(firstName)
            print(lastName)
            print(email)
            print(usernameTextField.text!)
            print(passwordTextField.text!)
            print(confirmPasswordTextField.text!)
        }
        // send the data to the 
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        
        // adds underlines in the view
        addUnderlines()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
