//
//  PostItemViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 3/5/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class PostItemViewController: UIViewController {
    @IBOutlet var Description: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Description!.layer.borderWidth = 1
        Description!.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
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
