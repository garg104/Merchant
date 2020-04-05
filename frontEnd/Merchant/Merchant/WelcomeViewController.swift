//
//  ViewController.swift
//  Merchant
//
//  Created by Chirayu Garg on 2/11/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    
    //segue to return to welcomViewController
    @IBAction func unwindToWelcomeViewController(segue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        if (Authentication.isLoggedIn()) {
            self.performSegue(withIdentifier: "welcomeToFeed", sender: nil)
            //Add the segue to feed here
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    // MARK: - Navigation

       // In a storyboard-based application, you will often want to do a little preparation before navigation
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           // Get the new view controller using segue.destination.
           // Pass the selected object to the new view controller.
           if (segue.identifier == "welcomeToFeed") {
                let vc = segue.destination as! MainTabBarController
                let currentUsername = Authentication.getCurrentUser()
                vc.username = currentUsername
           }
       }

    
    
}

