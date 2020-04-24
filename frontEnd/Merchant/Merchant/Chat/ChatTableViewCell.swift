//
//  ChatTableViewCell.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/22/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit


class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
