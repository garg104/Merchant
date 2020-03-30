//
//  BuyTableViewCell.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/6/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class BuyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    var itemDescription = ""
    var itemID = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        debugPrint("itemID: \(itemID)")
        itemPicturesHandler()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func itemPicturesHandler() {
        //first, setting up the default image
        self.itemImageView.image = UIImage(imageLiteralResourceName: "no-image")
        
        //setting the destination for storing the downloaded file
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/items/item_\(self.itemID).data")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        //checking cache
        checkCacheForItemPicture()
        
        //making the server request
        debugPrint("making request")
        AF.download(API.URL + "/items/picture/\(self.itemID)", method: .get, to: destination).responseJSON { response in
            if (response.response?.statusCode != 200) {
                //render default image
                self.itemImageView.image = self.base64ToUIImage(base64String: "")
            } else {
                //request successful
                if let res = response.value {
                    let resJson = res as! NSDictionary
                    let pictures : NSArray =  resJson.value(forKey: "files") as! NSArray
                    for picture in pictures {
                        let encodedImageString = picture as! String
                        self.itemImageView.image = self.base64ToUIImage(base64String: encodedImageString)
                    }
                }
            } //end if
        } //request
    }
    
    func checkCacheForItemPicture() {
        //checking for cached image data
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/items/item_\(self.itemID).data")
        let filePath = fileURL.path
        let fileManager = FileManager.default
        
        //checking if the required file already exists in the cache
        if fileManager.fileExists(atPath: filePath) {
            do {
                //read the data from the cache
                if let json = try JSONSerialization.jsonObject(with: Data(contentsOf: fileURL), options: []) as? [String: Any] {
                    // try to read out a string array
                    if let files = json["files"] as? [String] {
                        for file in files {
                            self.itemImageView.image = self.base64ToUIImage(base64String: file)
                        }
                        debugPrint("Cache hit: successfully rendered image")
                    }
                }
            } catch {
                //File in cache is corrupted
                debugPrint("Chache Miss, making the request")
            } //end do-catch
        } //end if
    }
    
    func base64ToUIImage(base64String: String?) -> UIImage{
      if (base64String?.isEmpty)! {
          debugPrint("No picture found")
          return UIImage(imageLiteralResourceName: "no-image")
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
    
    

}
