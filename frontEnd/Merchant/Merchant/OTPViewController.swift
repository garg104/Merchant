//
//  OTPViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/14/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class OTPViewController: UIViewController {
    
    var firstName = ""
    var lastName = ""
    var email = ""
    
    @IBAction func OTPNext(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(firstName)
        // Do any additional setup after loading the view.
        // check and validate the OTP.
        
    }
    
    // pass the data to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        let vc = segue.destination as! CreateAccountViewController
        vc.firstName = self.firstName
        vc.lastName = self.lastName
        vc.email = self.lastName
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
