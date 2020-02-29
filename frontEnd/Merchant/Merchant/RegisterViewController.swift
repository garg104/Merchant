//
//  RegisterViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/12/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire


class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var otp = ""
    
    
    @IBAction func nextToOTP(_ sender: Any) {
        if (firstNameTextField.text == "" ||
            lastNameTextField.text == "" ||
            emailTextField.text == "") {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter all the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            print("the email is \(emailTextField.text!)")
            let email = emailTextField.text!
            
            if (!email.contains("@")) {
                let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid university email.", preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            } else {
            
                let lastAt = email.lastIndex(of: "@")!
                let ending = email[lastAt...]
                debugPrint(ending)
                
                if (ending != "@purdue.edu") {
                    let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid university email.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else {
                
                    struct parameter: Encodable {
                        var OTP: String
                        var email: String
                    }
                    // generate the OTP to send to the backend
                    otp = String(Int.random(in: 1000 ... 9999))
                    // check if the email is a valid school email
                    let details = parameter(OTP: otp, email: emailTextField.text!)
                    //parameter.init(OTP: "1234", email: emailTextField.text!)
                    // = generateOTP()
                    // send the email and the OTP to the backend
                    // send the OTP to the next page
                    // database of universities
                    
                    AF.request(API.URL + "/user/validate", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).response { response in
                        debugPrint(response)
                    }
                }
            }
        
        }
        
    }
    
    func generateOTP () {
        
    }
    
    // pass the data to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if (segue.identifier == "nextToOTP") {
            let vc = segue.destination as! OTPViewController
            vc.firstName = firstNameTextField.text!
            vc.lastName = lastNameTextField.text!
            vc.email = emailTextField.text!
            vc.otp = otp
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //add underlines to the textfields
        addUnderlines()
    }
    
    func addUnderlines() {
        //create underline for username and password textfields
        let underLine = CALayer()
        underLine.frame = CGRect(x: 0, y: firstNameTextField.frame.height - 2, width: firstNameTextField.frame.width, height: 2)
        underLine.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        let underLine2 = CALayer()
        underLine2.frame = CGRect(x: 0, y: lastNameTextField.frame.height - 2, width: lastNameTextField.frame.width, height: 2)
        underLine2.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        let underLine3 = CALayer()
        underLine3.frame = CGRect(x: 0, y: emailTextField.frame.height - 2, width: emailTextField.frame.width, height: 2)
        underLine3.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        firstNameTextField.borderStyle = .none
        firstNameTextField.layer.addSublayer(underLine)
        lastNameTextField.borderStyle = .none
        lastNameTextField.layer.addSublayer(underLine2)
        emailTextField.borderStyle = .none
        emailTextField.layer.addSublayer(underLine3)
    }


}
