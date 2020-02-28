//
//  OTPViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/14/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class OTPViewController: UIViewController {
    
    @IBOutlet weak var resendOTP: UIButton!
    
    @IBOutlet weak var OTPTextField: UITextField!
    
    
    var firstName = ""
    var lastName = ""
    var email = ""
    var otp = ""
    
    @IBAction func OTPNext(_ sender: Any) {
        
        // check and validate the OTP.
        if (otp != OTPTextField.text!) {
            let alert = UIAlertController(title: "Incorrect Code", message: "Please enter the correct one time code sent to your email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }

    }
    
    @IBAction func resendOTP(_ sender: Any) {
        struct parameter: Encodable {
            var OTP: String
            var email: String
        }
        // generate the OTP to send to the backend
        let newOTP = String(Int.random(in: 1000 ... 9999))
        // check if the email is a valid school email
        let details = parameter(OTP: newOTP, email: email)
        //parameter.init(OTP: "1234", email: emailTextField.text!)
        // = generateOTP()
        // send the email and the OTP to the backend
        // send the OTP to the next page
        // database of universities
        
        AF.request("https://merchant307.herokuapp.com/user/validate", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).response { response in
            debugPrint(response)
        }
        
        //update otp
        otp = newOTP
        
        let alert = UIAlertController(title: "New Code Sent", message: "A new one time code has been sent to your email.", preferredStyle: .alert)
        alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(otp)
        resendOTP.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) //add forgotPasswordButton border
    }
    
   
    
    // pass the data to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        let vc = segue.destination as! CreateAccountViewController
        vc.firstName = self.firstName
        vc.lastName = self.lastName
        vc.email = self.email
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
