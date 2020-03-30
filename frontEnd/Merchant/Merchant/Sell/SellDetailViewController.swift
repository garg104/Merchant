//
//  SellDetailViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/28/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class SellDetailViewController: UIViewController {
    
    var itemTitle = ""
    var itemDescription = ""
    var itemPrice = ""
    var itemImage = ""
    var itemSeller = ""
    var itemId = ""
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDescriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = itemTitle
        itemPriceLabel.text = itemPrice
        itemDescriptionTextView.text = itemDescription
        
        itemPicturesHandler()
    }
    
    func itemPicturesHandler() {
        //setting the destination for caching the file
//        let destination: DownloadRequest.Destination = { _, _ in
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/profile_\(self.email).data")
//            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
//        }
//
        //making the server request
        AF.download(API.URL + "/items/picture/\(self.itemId)", method: .get).responseString { response in
            if (response.response?.statusCode != 200) {
                //render default image
                self.itemImageView.image = self.base64ToUIImage(base64String: "")
            } else {
                //request successful
                if let encodedImageString = response.value {
                    //parsing the base64 encoded string into image data
                    self.itemImageView.image = self.base64ToUIImage(base64String: encodedImageString)
                } //end if
            } //end if
        } //request
    }
    
    
    func base64ToUIImage(base64String: String?) -> UIImage{
      if (base64String?.isEmpty)! {
          debugPrint("No picture found")
          return UIImage(imageLiteralResourceName: "profile-avatar")
      } else {
          // Separating the metadata from the base64 data
          let temp = base64String?.components(separatedBy: ",")
          let dataDecoded : Data = Data(base64Encoded: temp![1], options: .ignoreUnknownCharacters)!
          let decodedimage = UIImage(data: dataDecoded)
        if (decodedimage != nil) {
          return decodedimage!
        } else {
            return self.itemImageView.image!
        }
      } //end if
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
