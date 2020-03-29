//
//  SellTableViewCell.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/14/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class SellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    var itemImage = ""
    var itemDescription = ""
    var username = ""
    var itemID = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func removeButton(_ sender: Any) {
        debugPrint("remove clicked")
        AF.request(API.URL + "/items/removeItem/", method: .post).responseJSON { response in
        
                if (response.response?.statusCode == 200) {
                   
                } else {
                    debugPrint("ERROR")
                }
                
                
            }
    }
    
    @IBAction func soldButton(_ sender: Any) {
        debugPrint("sold clicked")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
