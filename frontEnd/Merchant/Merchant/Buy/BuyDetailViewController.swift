//
//  BuyDetailViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/8/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class BuyDetailViewController: UIViewController {
    
    var itemTitle = ""
    var itemDescription = "test description"
    var itemPrice = ""
    var itemImage = ""
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDescriptionTextView: UITextView!
    @IBOutlet weak var contactSellerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = itemTitle
        itemPriceLabel.text = itemPrice
        itemDescriptionTextView.text = itemDescription
        
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
