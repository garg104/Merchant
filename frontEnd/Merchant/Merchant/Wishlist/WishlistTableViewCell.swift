//
//  WishlistTableViewCell.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/11/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class WishlistTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    var itemDescription = ""
    var itemID = ""
    var itemCategory = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
