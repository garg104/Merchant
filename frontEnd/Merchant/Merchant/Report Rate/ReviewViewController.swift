//
//  ReviewViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/18/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var commentsTextView: UITextView!
    
    @IBAction func submitReviewButton(_ sender: Any) {
        print(ratingStackView.numStars)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.commentsTextView.delegate = self
    }
    
    //dismiss keyboard on return
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
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
