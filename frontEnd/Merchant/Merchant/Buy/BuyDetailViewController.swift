//
//  BuyDetailViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/8/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class BuyDetailViewController: UIViewController {
    
    var itemTitle = ""
    var itemDescription = ""
    var itemPrice = ""
    var itemImage = ""
    var itemSeller = ""
    var itemId = ""
    var pictures: NSArray = []
    var imagesForView = [UIImage]()
    
    var imageHeight = CGRect()
    var imageWidth = CGRect()
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDescriptionTextView: UITextView!
    @IBOutlet weak var contactSellerButton: UIButton!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //imageScrollView.frame = self.view.frame
        
        navigationItem.title = itemTitle
        itemPriceLabel.text = itemPrice
        itemDescriptionTextView.text = itemDescription
        
        itemPicturesHandler()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contactSellerButton.titleLabel?.text = "Contact " + itemSeller
        
    }
    
    func itemPicturesHandler() {
        //first, setting up the default image
        ///self.itemImageView.image = UIImage(imageLiteralResourceName: "no-image")
        imagesForView.append(UIImage(imageLiteralResourceName: "no-image"))
        
        //setting the destination for storing the downloaded file
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/items/item_\(self.itemId).data")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        //checking cache
        checkCacheForItemPicture()
        
        
        //making the server request
        AF.download(API.URL + "/items/picture/\(self.itemId)", method: .get, to: destination).responseJSON { response in
            if (response.response?.statusCode != 200) {
                //render default image
                ///self.itemImageView.image = self.base64ToUIImage(base64String: "")
                self.imagesForView.append(self.base64ToUIImage(base64String: "", index: 0))
            } else {
                //request successful
                if let res = response.value {
                    let resJson = res as! NSDictionary
                    let pictures : NSArray =  resJson.value(forKey: "files") as! NSArray
                    self.pictures = pictures
                    self.imagesForView = []
                    var index = 0
                    for picture in pictures {
                        let encodedImageString = picture as! String
                        ///self.itemImageView.image = self.base64ToUIImage(base64String: encodedImageString)
                        self.imagesForView.append(self.base64ToUIImage(base64String: encodedImageString, index: index))
                        print("INDEX")
                        print(index)
                        index = index + 1
                    }
                }
            } //end if
        } //request
        
        self.imageScrollView.subviews.forEach({ $0.removeFromSuperview() })
        for i in 0..<self.imagesForView.count {
            print("IMAGE SCROLL")
            let imageView = UIImageView()
            imageView.image = imagesForView[i]
            imageView.contentMode = .scaleAspectFit
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: 400, height: 300)
            
            self.imageScrollView.contentSize.width = 405 * CGFloat(i + 1) //self.imageScrollView.frame.width * CGFloat(i + 1)
            self.imageScrollView.addSubview(imageView)
            
        }
    }
    
    func checkCacheForItemPicture() {
        //checking for cached image data
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/items/item_\(self.itemId).data")
        let filePath = fileURL.path
        let fileManager = FileManager.default
        
        //checking if the required file already exists in the cache
        if fileManager.fileExists(atPath: filePath) {
            do {
                //read the data from the cache
                if let json = try JSONSerialization.jsonObject(with: Data(contentsOf: fileURL), options: []) as? [String: Any] {
                    // try to read out a string array
                    if let files = json["files"] as? [String] {
                        self.pictures = files as NSArray
                        self.imagesForView = []
                        var index = 0
                        for file in files {
                            ///self.itemImageView.image = self.base64ToUIImage(base64String: file)
                            self.imagesForView.append(self.base64ToUIImage(base64String: file, index: index))
                            print("CACHE INDEX")
                            print(index)
                            index = index + 1
                        }
                        debugPrint("Cache hit: successfully rendered image")
                    }
                }
            } catch {
                //File in cache is corrupted
                debugPrint("Chache Miss, making the request")
            } //end do-catch
        } //end if
        
        self.imageScrollView.subviews.forEach({ $0.removeFromSuperview() })
        for i in 0..<self.imagesForView.count {
            print("IMAGE SCROLL CACHE")
            let imageView = UIImageView()
            imageView.image = imagesForView[i]
            //imageView.contentMode = .scaleAspectFill
            let xPosition = self.view.frame.width * CGFloat(i)
            //imageView.frame = CGRect(x: xPosition, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            imageView.frame = CGRect(x: xPosition, y: 0, width: 400, height: 300)
            
            self.imageScrollView.contentSize.width = 405 * CGFloat(i + 1) //self.imageScrollView.frame.width * CGFloat(i + 1)
            self.imageScrollView.addSubview(imageView)
            
        }
        
    }
    
    
    func base64ToUIImage(base64String: String?, index: Int) -> UIImage{
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
            debugPrint("decoded image null")
            ///return self.itemImageView.image!
            return self.imagesForView[index]
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
