//
//  BuyDetailViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/8/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}

class BuyDetailViewController: UIViewController {
    
    var modelName = ""
    var currentUser = ""
    
    var itemTitle = ""
    var itemDescription = ""
    var itemPrice = ""
    var itemImage = ""
    var itemSeller = ""
    var itemId = ""
    var pictures: NSArray = []
    var imagesForView = [UIImage]()
    var itemInWishlist = false
    var imageHeight = CGRect()
    var imageWidth = CGRect()
    
    @IBOutlet weak var wishlistButton: UIBarButtonItem!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDescriptionTextView: UITextView!
    @IBOutlet weak var contactSellerButton: UIButton!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var viewProfileButton: UIButton!
    @IBOutlet weak var rewiewButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    @IBAction func addToWishlist(_ sender: Any) {
        //add or remove item to wishlist
        struct parameter: Encodable {
            var id: String
        }
        struct removeParams: Encodable {
            var itemID: String
        }
        let headers: HTTPHeaders = [
            "Authorization": Authentication.getAuthToken(),
            "Accept": "application/json"
        ]
        
        if (itemInWishlist) {
           //Removing the item from wish list
           let itemDetail = removeParams(itemID: self.itemId)
           AF.request(API.URL + "/items/removeFromWishlist/", method: .post, parameters: itemDetail, headers: headers).responseJSON { response in
               var title = "Error in wishlist"
               var message = "Item couldn't be removed from the wish list, try again"
               if (response.response?.statusCode == 200) {
                   title = "Item succesfully removed"
                   message = "Item has been successfully removed from the wishlist"
                   StateManager.updateWishlist = true;
                   self.itemInWishlist = false
                   self.updateWishlistStatus(exists: false)
               } //end if
               let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
               self.present(alert, animated: true)
           }
        } else {
            //Adding the item to wishlist
            let itemDetail = parameter(id: self.itemId)
            AF.request(API.URL + "/user/wishlist/", method: .post, parameters: itemDetail, headers: headers).responseJSON { response in
                var title = "Error in wishlist"
                var message = "Item couldn't be added to the wish list, try again"
                if (response.response?.statusCode == 200) {
                    title = "Item succesfully added"
                    message = "Item has been successfully added to the wishlist"
                    StateManager.updateWishlist = true;
                    self.updateWishlistStatus(exists: true)
                    self.itemInWishlist = true
                } //end if
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func unwindToBuyDetailViewController(segue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        itemInWishlist = itemExistsInWishlist()
        
        //imageScrollView.frame = self.view.frame
        
        modelName = UIDevice.modelName
        print("MODEL")
        print(modelName)
        
        navigationItem.title = itemTitle
        itemPriceLabel.text = itemPrice
        itemDescriptionTextView.text = itemDescription
        
        viewProfileButton.layer.borderColor = #colorLiteral(red: 0.3822624683, green: 0.7218602896, blue: 0.2237514853, alpha: 1) //add viewProfileButton border
        rewiewButton.layer.borderColor = #colorLiteral(red: 0.3822624683, green: 0.7218602896, blue: 0.2237514853, alpha: 1) //add rewiewButton border
        reportButton.layer.borderColor = #colorLiteral(red: 0.3822624683, green: 0.7218602896, blue: 0.2237514853, alpha: 1) //add reportButton border
        
        itemPicturesHandler()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contactSellerButton.titleLabel?.text = "Contact " + itemSeller
        
    }
    
    func itemExistsInWishlist() -> Bool {
        let headers: HTTPHeaders = [
            "Authorization": Authentication.getAuthToken(),
            "Accept": "application/json"
        ]
        var exists = false;
        debugPrint("requesting wishlist")
        AF.request(API.URL + "/user/wishlist/exists/\(self.itemId)", method: .get,
                   headers: headers).responseJSON { response in
            if (response.response?.statusCode == 200) {
                debugPrint("EXISTS IN WISHLIST")
                exists = true;
            } else {
                debugPrint("NOT EXISTS IN WISHLIST")
                exists = false;
            }//end if
            if (self.itemInWishlist != exists) {
                self.updateWishlistStatus(exists: exists)
                self.itemInWishlist = exists
            }
        }
        return exists;
    }
    
    func updateWishlistStatus(exists: Bool) {
        //toggling the title of the wishlist button
        if (!exists) {
            //wishlistButton.tintColor = #colorLiteral(red: 0.3822624683, green: 0.7218602896, blue: 0.2237514853, alpha: 1);
            wishlistButton.image = UIImage(systemName: "bookmark")
        } else {
            //wishlistButton.tintColor = .red;
            wishlistButton.image = UIImage(systemName: "bookmark.fill")
        }
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
            
            //imageView.frame = CGRect(x: xPosition, y: 0, width: 400, height: 300)
            if (modelName.contains("iPhone 11 Pro Max") ||
                modelName.contains("iPhone XS Max")) {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 400, height: 300)
            } else if (modelName.contains("iPhone 11 Pro") ||
                modelName.contains("iPhone XS") ||
                modelName.contains("iPhone X")) {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 370, height: 277)
            } else if (modelName.contains("iPhone 11") ||
                modelName.contains("iPhone XR")) {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 370, height: 277)
            } else if (modelName.contains("iPhone 7 Plus") ||
                modelName.contains("iPhone 8 Plus")) {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 300, height: 225)
            } else {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 280, height: 210)
            }
            
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
            
            //imageView.frame = CGRect(x: xPosition, y: 0, width: 400, height: 300)
            if (modelName.contains("iPhone 11 Pro Max") ||
                modelName.contains("iPhone XS Max")) {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 400, height: 300)
            } else if (modelName.contains("iPhone 11 Pro") ||
                modelName.contains("iPhone XS") ||
                modelName.contains("iPhone X")) {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 370, height: 277)
            } else if (modelName.contains("iPhone 11") ||
                modelName.contains("iPhone XR")) {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 370, height: 277)
            } else if (modelName.contains("iPhone 7 Plus") ||
                modelName.contains("iPhone 8 Plus")) {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 300, height: 225)
            } else {
                imageView.frame = CGRect(x: xPosition, y: 0, width: 280, height: 210)
            }
            
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "toReport") {
            let vc = segue.destination as! ReportUserViewController
            vc.currentUser = currentUser
            vc.userBeingReported = itemSeller
        }
        if (segue.identifier == "toReview") {
            let vc = segue.destination as! ReviewViewController
            vc.currentUser = currentUser
            vc.userBeingRated = itemSeller
        }
        if (segue.identifier == "toViewReviews") {
            let vc = segue.destination as! ViewReviewsViewController
            vc.itemSeller = self.itemSeller
            vc.currentUser = self.currentUser
        }
        if (segue.identifier == "toInitialConversation") {
            let vc = segue.destination as! InitialConversationViewController
            vc.currentUser = self.currentUser
            vc.userChattingWith = self.itemSeller
        }
    }
    func checkIfChatExists(<#parameters#>) -> <#return type#> {
        struct parameters: Encodable {
            var userSender = ""
            var userReceiver = ""
        }
        
        let details = parameters(userSender: self.currentUser,
                                 userReceiver: self.itemSeller)
        AF.request(API.URL + "/user/chatExists", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
            
            // deal with the request
            if (response.response?.statusCode != 200) {
                debugPrint("ERROR")
                let alert = UIAlertController(title: "Error!", message: "Message could not be sent", preferredStyle: .alert)
                
                
                // Create Confirm button with action handler
                let confirm = UIAlertAction(title: "OK",
                                            style: .default)
                
                // add actions to the alert
                alert.addAction(confirm)
                
                // display alert
                self.present(alert, animated: true)
            } else {
                

            }
            
        }.resume()
    }
    
    func getItems(completion: @escaping (_ validCode: Int)->()) {
            
            struct parameter: Encodable {
                var username = ""
            }
            let details = parameter(username: self.itemSeller)
            
            AF.request(API.URL + "/user/viewRating", method: .post, parameters: details, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
                var stars = 0
                if (response.response?.statusCode == 200) {
                    if let info = response.value {
                        let JSON = info as! NSDictionary
                        debugPrint(JSON)
                        stars =  JSON.value(forKey: "currentRating") as! Int
                        debugPrint("stars")
                        debugPrint(stars)
                        completion(stars)
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
                
                completion(stars)
                
            }.resume()
        }
    

}
