//
//  MessageTableViewCell.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/22/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
    
    var leftAlign: NSLayoutConstraint!
    var rightAlign: NSLayoutConstraint!
    
    var isIncoming: Bool! {
        didSet {
            bubbleBackgroundView.backgroundColor = isIncoming ? .white : #colorLiteral(red: 0.3822624683, green: 0.7218602896, blue: 0.2237514853, alpha: 1)
            messageLabel.textColor = isIncoming ? .black : .white
            
            if isIncoming {
                leftAlign.isActive = true
                rightAlign.isActive = false
            } else {
                leftAlign.isActive = false
                rightAlign.isActive = true
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bubbleBackgroundView.backgroundColor = .white
        bubbleBackgroundView.layer.cornerRadius = 12
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleBackgroundView)
        
        addSubview(messageLabel)
        messageLabel.numberOfLines = 0
        
        //label constraints
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
        
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16)
        ]
        NSLayoutConstraint.activate(constraints)
        
        leftAlign = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        rightAlign = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
