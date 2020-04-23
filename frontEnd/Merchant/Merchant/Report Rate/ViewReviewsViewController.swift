//
//  ViewReviewsViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/22/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class ViewReviewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var users: [String] = ["dconver", "dconver1"]
    var comments: [String] = ["great job this is a longer comment that should hopefully wrap around to two lines and automatically resize the cell", "shorter comment"]
    var ratings: [Int] = [3, 5]
    var avgRating = 0
    var username = "" //the user whose reviews are being looked at
    
    @IBOutlet weak var avgRatingLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avgStarRating: RatingController!
    @IBOutlet weak var commentsTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.usernameLabel.text = username
        
        self.commentsTableView.dataSource = self
        self.commentsTableView.delegate = self
        
        //TODO
        //obtain average rating as an integer
        self.avgRating = 3 //change to equal real average
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
