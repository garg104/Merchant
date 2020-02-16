//
//  LogInViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/12/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addUnderlines() //add underlines to textfields
        forgotPasswordButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) //add forgotPasswordButton border
        
    }
    
    func addUnderlines() {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
