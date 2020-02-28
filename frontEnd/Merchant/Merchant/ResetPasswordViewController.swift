//
//  ResetPasswordViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/28/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordConfirm: UITextField!
    var username = ""
    let passwordChecker = CreateAccountViewController()
    
    @IBAction func resetButton(_ sender: Any) {
        if (password.text == "" ||
            newPassword.text == "" ||
            newPasswordConfirm.text == "") {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter all the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else if (newPasswordConfirm.text != newPassword.text) {
            let alert = UIAlertController(title: "New Passwords Do Not Match", message: "Please make sure that both the passwords match", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            newPassword.text = ""
            newPasswordConfirm.text = ""
        } else if (!passwordChecker.passwordStrength(password: newPassword.text!)) {
            let alert = UIAlertController(title: "Password Not Strong", message: "Password length must be at least 6 characters and include a number, lowercase letter and uppercase letter.", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            newPassword.text = ""
            newPasswordConfirm.text = ""
        } else {
        
            struct parameter: Encodable {
                var username: String
                var password: String
                var newPassword: String
            }
                   
            // set parameters for logging in user
            let details = parameter(username: username, password: password.text!, newPassword: newPassword.text! )
                   
                   //request account validation from database
            AF.request(API.URL + "/user/resetPassword", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
                if (response.response?.statusCode == 404) {
                    // user not found
                    let alert = UIAlertController(title: "Invalid User", message: "User does not exist. Please enter a valid username.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    } else if (response.response?.statusCode == 200) {
                        // email sent
                        let alert = UIAlertController(title: "Password Reset", message: "Your password has been succesfully reset.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        //DO MOST WORK HERE @CHIRAYU
        
    }
    

}
