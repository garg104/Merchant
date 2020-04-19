//
//  RatingController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/18/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class RatingController: UIStackView {
    
    var numStars = 0;
    var emptyStarPic = "star"
    var filledStarPic = "star.fill"

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let myViews = self.subviews.filter{$0 is UIButton}
        var starTag = 1
        for theView in myViews {
            if let theButton = theView as? UIButton {
                theButton.setImage(UIImage(systemName: emptyStarPic), for: .normal)
                theButton.addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
                theButton.tag = starTag
                starTag = starTag + 1
            }
        }
    }
    
    @objc func pressed(sender: UIButton) {
        numStars = sender.tag
        let myViews = self.subviews.filter{$0 is UIButton}
        for theView in myViews {
            if let theButton = theView as? UIButton {
                if theButton.tag > sender.tag {
                    theButton.setImage(UIImage(systemName: emptyStarPic), for: .normal)
                } else {
                    theButton.setImage(UIImage(systemName: filledStarPic), for: .normal)
                }
            }
        }
    }
    

}
