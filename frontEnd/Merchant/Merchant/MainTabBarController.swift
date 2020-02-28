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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        //initialize individual tab's view controllers
        let buyNavVC = self.viewControllers?[0] as! UINavigationController
        let sellNavVC = self.viewControllers?[1] as! UINavigationController
        let charNavVC = self.viewControllers?[2] as! UINavigationController
        let profNavVC = self.viewControllers?[3] as! UINavigationController
        
        //initialize profile view controller
        let profVC = profNavVC.viewControllers[0] as! ProfileViewController
        profVC.username = username

        
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
