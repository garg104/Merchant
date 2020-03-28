//
//  SellTableViewCell.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/14/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class SellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    var itemImage = ""
    var itemDescription = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
