//
//  SellHistoryTableViewCell.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/15/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class SellHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    //let table = SellTableViewController()

    var itemImage = ""
    var itemDescription = ""
    var username = ""
    var itemID = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        debugPrint("delete clicked")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
