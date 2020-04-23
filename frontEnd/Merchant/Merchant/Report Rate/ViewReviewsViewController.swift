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
    @IBOutlet weak var avgStarRating: RatingController!
    @IBOutlet weak var commentsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getItems() { (validCode) in
            print("LOADING DATA")
//            self.tableView.reloadData()
        }
        
        // Do any additional setup after loading the view.
        self.usernameLabel.text = self.itemSeller
        
        self.commentsTableView.dataSource = self
        self.commentsTableView.delegate = self
        
        //TODO
        //obtain average rating as an integer
//        self.avgRating = 3 //change to equal real average
        self.avgStarRating.numStars = self.avgRating
        self.avgRatingLabel.text = String(self.avgRating) + "/5"
        
        //TODO
        //populate users, comments, ratings arrays with the reviews info for username
        
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
        // #warning Incomplete implementation, return the number of sections
        
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
                    debugPrint(self.avgRating)
//                    let userRatings : String =  JSON.value(forKey: "currentRating") as! String
                    let userRatings : NSArray =  JSON.value(forKey: "rating") as! NSArray
                    debugPrint(userRatings)
                    for userRating in userRatings {
                        print(userRating)
                        let temp = userRating as! NSDictionary
                        self.users.append(temp["userID"]! as! String)
                        self.comments.append(temp["review"]! as! String)
                        self.ratings.append(temp["rating"]! as! Int)
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
