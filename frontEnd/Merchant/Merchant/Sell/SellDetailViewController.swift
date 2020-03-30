//
//  SellDetailViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/28/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class SellDetailViewController: UIViewController {
    
    var itemTitle = ""
    var itemDescription = ""
    var itemPrice = ""
    var itemImage: UIImage!
    var itemSeller = ""
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDescriptionTextView: UITextView!

    @IBAction func unwindToSellDetailViewController(segue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional stup after loading the view.
        navigationItem.title = itemTitle
        itemPriceLabel.text = itemPrice
        itemDescriptionTextView.text = itemDescription
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "detailToEdit") {
            let vc = segue.destination as! EditItemViewController
            //Here you can pass values from this detail view controller to the edit one
            //examples
            vc.name = itemTitle
            vc.nameTextField.text! = itemTitle
            vc.desc = itemDescription
            vc.descriptionTextView.text! = itemDescription
            vc.price = itemPrice
            vc.priceTextField.text! = itemPrice
            vc.photo1 = itemImage
            vc.photo1Button.setBackgroundImage(itemImage, for: .normal)
            vc.photo1Button.setTitleColor(.clear, for: .normal)
            vc.removePhoto1Button.setTitleColor(.red, for: .normal)

        }
        
    }
}
