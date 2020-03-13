//
//  PostItemViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 3/8/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class PostItemViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var editPriceTextField: UITextField!
    @IBOutlet weak var editDescriptionTextView: UITextView!
    @IBOutlet weak var photosScrollView: UIScrollView!
    @IBOutlet weak var choosePhotosButton: UIButton!
    
    var name = ""
    var price = ""    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // add border to description textView
        editDescriptionTextView!.layer.borderWidth = 1
        editDescriptionTextView!.layer.borderColor = UIColor.black.cgColor
        
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
