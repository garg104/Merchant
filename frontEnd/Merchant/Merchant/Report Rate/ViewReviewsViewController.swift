//
//  ViewReviewsViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/22/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class ViewReviewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var users: [String] = []// = ["dconver", "dconver1"]
    var comments: [String] = []// = ["great job this is a longer comment that should hopefully wrap around to two lines and automatically resize the cell", "shorter comment"]
    var ratings: [Int] = [] //= [3, 5]
    var avgRating = 0
    var itemSeller = "" //the user whose reviews are being looked at
    var currentUser = ""
    
    @IBOutlet weak var avgRatingLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avgStarRating: StaticRatingController!
    @IBOutlet weak var commentsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("initial avg rating")
        print(avgRating)
        //avgStarRating.numStars = avgRating
        
        getItems() { (validCode) in
            print("LOADING DATA")
            self.usernameLabel.text = self.itemSeller
            self.commentsTableView.dataSource = self
            self.commentsTableView.delegate = self
            print("average rating is \(self.avgRating)")
            
            //TODO
            //obtain average rating as an integer
            print("number of stars are \(self.avgStarRating.numStars)")
            
            if (self.users[0] == "No Reviews Yet") {
                self.avgRatingLabel.text = "-/5"
            } else {
                self.avgRatingLabel.text = String(self.avgRating) + "/5"
            }
            self.updateStars()
            self.commentsTableView.reloadData()
        }
        
        // Do any additional setup after loading the view.
        
        
        //TODO
        //populate users, comments, ratings arrays with the reviews info for username
        
        
    }
    
    func updateStars() {
        let myViews = self.avgStarRating.subviews.filter{$0 is UIButton}
        var starTag = 0
        for theView in myViews {
            if let theButton = theView as? UIButton {
                if (starTag < self.avgRating) {
                    theButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                } else {
                    theButton.setImage(UIImage(systemName: "star"), for: .normal)
                }
                starTag = starTag + 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        cell.usernameLabel.text = users[indexPath.row]
        cell.commentLabel.text = comments[indexPath.row]
        cell.starRating.numStars = ratings[indexPath.row]
        return cell
    }
    
    func getItems(completion: @escaping (_ validCode: Int)->()) {
        
        struct parameter: Encodable {
            var username = ""
        }
        // set parameters for logging in user
        //        print(username)
        let details = parameter(username: self.itemSeller)
        
        
        AF.request(API.URL + "/user/viewRating", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
            
            
            if (response.response?.statusCode == 200) {
                if let info = response.value {
                    let JSON = info as! NSDictionary
                    debugPrint(JSON)
                    self.avgRating =  JSON.value(forKey: "currentRating") as! Int
                    //self.avgStarRating.numStars = self.avgRating
                    debugPrint(self.avgRating)
//                    let userRatings : String =  JSON.value(forKey: "currentRating") as! String
                    let userRatings : NSArray =  JSON.value(forKey: "rating") as! NSArray
//                    debugPrint(userRatings)
                    for userRating in userRatings {
//                        print(userRating)
                        let temp = userRating as! NSDictionary
                        self.users.append(temp["username"]! as! String)
                        self.comments.append(temp["review"]! as! String)
                        self.ratings.append(Int(temp.value(forKey: "rating") as! String)!)
                    }
                }
            } else {
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
            
            if (self.users.count == 0) {
                self.users.append("No Reviews Yet")
                self.comments.append("")
                self.ratings.append(0)
            }
            
            completion(0)
            
        }.resume()
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
