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
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    
    
}

