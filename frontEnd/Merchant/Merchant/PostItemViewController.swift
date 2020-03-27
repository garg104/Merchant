//
//  PostItemViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 3/8/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class PostItemViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var photosScrollView: UIScrollView!
    @IBOutlet weak var choosePhotosButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // add border to description textView
        descriptionTextView!.layer.borderWidth = 1
        descriptionTextView!.layer.borderColor = UIColor.black.cgColor
        
    }
    
    @IBAction func postItem(_ sender: UIButton, completion: @escaping (_ validCode: Int)->()) {
        
        // extract fields
        struct parameters: Encodable {
            var userID = 0
            var name = ""
            var desc = ""
            var price = ""
            var photos = 0
            var category = ""
            var isSold = false
            var university = "Purdue University"
        }
        
        let details = parameters(name: nameTextField.text!,
                                 desc: descriptionTextView.text!,
                                 price: priceTextField.text!)
        
        // make request
        AF.request(API.URL + "/postItem",
                   method: .post,
                   parameters: details,
                   encoder: URLEncodedFormParameterEncoder.default).response {response in
                    
                    let status = (response.response?.statusCode ?? 0)
                    
                    if (status != 0) {
                        switch status {
                        case 500: // error
                            completion(status)
                            break
                        case 201: // success
                            completion(status)
                            break
                        default:
                            completion(status)
                            break
                        }
                    }
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
