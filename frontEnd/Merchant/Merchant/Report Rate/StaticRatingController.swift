//
//  StaticRatingController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/22/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class StaticRatingController: UIStackView {

    var numStars = 0;
    var emptyStarPic = "star"
    var filledStarPic = "star.fill"

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let myViews = self.subviews.filter{$0 is UIButton}
        var starTag = 0
        for theView in myViews {
            if let theButton = theView as? UIButton {
                if (starTag < numStars) {
                    theButton.setImage(UIImage(systemName: filledStarPic), for: .normal)
                } else {
                    theButton.setImage(UIImage(systemName: emptyStarPic), for: .normal)
                }
                starTag = starTag + 1
            }
        }
    }
}
