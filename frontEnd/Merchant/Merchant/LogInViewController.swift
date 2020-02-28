//
//  LogInViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/12/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    
    @IBAction func loginClicked(_ sender: Any) {
        
        //show alert if textfields are empty
        if (usernameTextField.text == "" ||
            passwordTextField.text == "") {
            
            let alert = UIAlertController(title: "Empty Field", message: "Please enter all the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
        }
        
        validateFields() { (validCode) in
            let validationCode = validCode
            
            debugPrint("VALIDATION CODE:", validationCode)
            
            if (validationCode == 0) { //success
                debugPrint("SUCCESS!!!!")
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            } else if (validationCode == 1) { //username invalid
                let alert = UIAlertController(title: "Invalid Username", message: "Please enter a valid username", preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            } else if (validationCode == 2) { //password invalid
                let alert = UIAlertController(title: "Incorrect Password", message: "Please enter the correct password", preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            } else { //error in database check
                let alert = UIAlertController(title: "Error", message: "Error while logging in, please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addUnderlines() //add underlines to textfields
        forgotPasswordButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) //add forgotPasswordButton border
        
    }
    
    //function to validate user logging in
    private func validateFields(completion: @escaping (_ validCode: Int)->()) {
        
        var validationCode = -1;
        
        //set parameter for database request
        struct parameter: Encodable {
            var username: String
            var password: String
        }
        
        // set parameters for logging in user
        let details = parameter(username: usernameTextField.text!, password: passwordTextField.text!)
        
        //request account validation from database
        AF.request("https://merchant307.herokuapp.com/user/login", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
            
            //obtain status code returned from request
            let status = (response.response?.statusCode ?? 0)
            
            if (status != 0) {
                switch status {
                case 404:
                    debugPrint("Username couldn't be found")
                    validationCode = 1 //username not found
                    completion(validationCode)
                    break
                case 401:
                    debugPrint("Passwords don't match")
                    validationCode = 2 //incorrect password
                    completion(validationCode)
                    break
                case 200:
                    debugPrint("Login Successful")
                    validationCode = 0 //success
                    completion(validationCode)
                    break
                default:
                    debugPrint("Login Successful")
                    validationCode = 0 //success
                    completion(validationCode)
                    break
                }
            }
            debugPrint(response)
            
        }.resume()
    }
    
    private func addUnderlines() {
        //create underline for username and password textfields
        let underLine = CALayer()
        underLine.frame = CGRect(x: 0, y: usernameTextField.frame.height - 2, width: usernameTextField.frame.width, height: 2)
        underLine.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        let underLine2 = CALayer()
        underLine2.frame = CGRect(x: 0, y: usernameTextField.frame.height - 2, width: usernameTextField.frame.width, height: 2)
        underLine2.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        usernameTextField.borderStyle = .none
        usernameTextField.layer.addSublayer(underLine)
        passwordTextField.borderStyle = .none
        passwordTextField.layer.addSublayer(underLine2)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "toTabBar") {
            let vc = segue.destination as! MainTabBarController
            vc.username = usernameTextField.text!
        }
        
    }
    

}
