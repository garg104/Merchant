//
//  ReviewViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/18/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class ReviewViewController: UIViewController, UITextViewDelegate {
    
    var currentUser = ""
    var userBeingRated = ""
    
    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var commentsTextView: UITextView!
    
    @IBAction func submitReviewButton(_ sender: Any) {
        print(ratingStackView.numStars)
        postReview()
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
    
    func postReview() {
        // user 1 is the user who is rating the user.
        // user 2 is the user who is being rated.
        
        
        // TODO
        // REMEMBER TO PASS CURRENT USER IN THE SEGUE TO THIS CONTROLLER FROM THE PREVIOUS CONTROLLER. I HAVE MADE THE GLOBAL VARIABLE
        
        // USER 2 is the user beeeing rated. ENTER THEIR USERNAME IN THE DETAILS
        let userBeingRated = self.userBeingRated
        
        // NEW RATING IS THE RATING GIVEN BY USER1 TO USER2. GET IT FROM THE UI. THIS IS ALWAYS OUT OF 5 SO IT SHOULD BE SOMETHING BETWEEEN 1-5. ENTER IT BELOW
        let newRating = ratingStackView.numStars
        
        // REVIEW IS THE REVIEW GIVEN BY USER1 TO USER2. GET IT FROM THE UI. ENTER IT BELOW.
        var review = ""
        if (commentsTextView.text! == "") {
            //create alert
            let alert = UIAlertController(title: "Empty Comment", message: "Please enter a comment to go along with your rating.", preferredStyle: .alert)
            // Create Confirm button with action handler
            let confirm = UIAlertAction(title: "OK",
                                        style: .default)
            // add actions to the alert
            alert.addAction(confirm)
            // display alert
            self.present(alert, animated: true)
            return
        } else {
            review = commentsTextView.text!
        }
        
        
        // do not change the var names in the struct as these correspond to the ones in backend.
        struct parameters: Encodable {
            var user1 = ""
            var user2 = ""
            var newRating = 0
            var review = ""
        }
        
        let details = parameters(user1: currentUser, user2: userBeingRated, newRating: newRating, review: review)
        
        AF.request(API.URL + "/user/rating", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).response { response in
            
            // deal with the request
            if (response.response?.statusCode != 200) {
                debugPrint("ERROR")
                let alert = UIAlertController(title: "Error!", message: "Something went wrong. Please try again", preferredStyle: .alert)
                
                
                // Create Confirm button with action handler
                let confirm = UIAlertAction(title: "OK",
                                            style: .default)
                
                // add actions to the alert
                alert.addAction(confirm)
                
                // display alert
                self.present(alert, animated: true)
            }
            
            
        }.resume()
        self.performSegue(withIdentifier: "submitReviewUnwind", sender: nil)
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
