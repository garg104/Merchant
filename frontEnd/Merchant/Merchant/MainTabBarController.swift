//
//  MainTabBarController.swift
//  Merchant
//
//  Created by Domenic Conversa on 2/27/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class MainTabBarController: UITabBarController {

    var username = ""
    var firstName = ""
    var lastName = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //initialize individual tab's view controllers
        let buyNavVC = self.viewControllers?[0] as! UINavigationController
        let sellNavVC = self.viewControllers?[1] as! UINavigationController
        let charNavVC = self.viewControllers?[2] as! UINavigationController
        let profNavVC = self.viewControllers?[3] as! UINavigationController
        
        
        obtainUserInfo() { (finished) in
            //initialize profile view controller with current user's data
            let profVC = profNavVC.viewControllers[0] as! ProfileViewController
            profVC.username = self.username
            profVC.email = self.email
            profVC.firstName = self.firstName
            profVC.lastName = self.lastName
            let fullName = self.firstName + " " + self.lastName
            profVC.name = fullName
            
            //send current username to BuyTableViewController
            let buyVC = buyNavVC.viewControllers[0] as! BuyTableViewController
            buyVC.currentUser = self.username
            
            //send current username to SellTableViewController
            let sellVC = sellNavVC.viewControllers[0] as! SellTableViewController
            sellVC.currentUser = self.username
            
        }
    }
    
    func obtainUserInfo(completion: @escaping (_ finished: Int)->()) {
        //set parameter for database request
        struct parameter: Encodable {
            var username: String
        }
        
        // set parameters for logging in user
        let details = parameter(username: username)
        
        //request account validation from database
        AF.request(API.URL + "/user/info", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
            
            //obtain status code returned from request
            let status = (response.response?.statusCode ?? 0)
            
            if (status != 0) {
                switch status {
                case 200:
                    if let info = response.value {
                        let JSON = info as! NSDictionary
//                        debugPrint("JSON:", JSON)
                        self.email = JSON["email"]! as! String
//                        debugPrint("NEW EMAIL:", self.email)
                        self.firstName = JSON["firstName"]! as! String
                        self.lastName = JSON["lastName"]! as! String
//                        debugPrint("NEW NAME:", self.firstName, self.lastName)
                    }
                    completion(1)
                    break
                default:
                    debugPrint("ERROR in getting user data from username")
                    completion(0)
                    break
                }
            }
//            debugPrint(response)
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
