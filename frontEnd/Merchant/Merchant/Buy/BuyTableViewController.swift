//
//  BuyTableViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/6/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class BuyTableViewController: UITableViewController {
    
    var currentUser = ""
    
    //data structures for simple testing (replace with JSON array)    
    var images: [String] = []
    var titles: [String] = []
    var usernames: [String] = []
    var prices: [String] = []
    var descriptions: [String] = []
    var itemIDs: [String] = []
    
    func getItems(completion: @escaping (_ validCode: Int)->()) {
        // #warning Incomplete implementation, return the number of sections
        
        struct parameters: Encodable {
            var username = ""
        }
                
        AF.request(API.URL + "/items/allItems/", method: .get).responseJSON { response in
    
            if (response.response?.statusCode == 200) {
                if let info = response.value {
                    let JSON = info as! NSDictionary
                    let items : NSArray =  JSON.value(forKey: "items") as! NSArray
                    for item in items {
                        // make sure that the user does not see the objects they are selling
                        let temp = item as! NSDictionary
                        if (self.currentUser != temp["username"] as! String) {
                            print(item)
                            self.titles.append(temp["title"]! as! String)
                            self.prices.append(temp["price"]! as! String)
                            self.usernames.append(temp["username"] as! String)
                            self.descriptions.append(temp["description"]! as! String)
                            self.itemIDs.append(temp["_id"]! as! String)
                        }
                        
                    }
                }
            } else {
                debugPrint("ERROR")
            }
            
            completion(0)
            
        }.resume()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getItems() { (validCode) in
            self.tableView.reloadData()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let searchController = UISearchController(searchResultsController: nil) // Search Controller
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.searchBar.scopeButtonTitles = ["Item", "User"]
        
    }
    
    func updateData() {
           images = []
           titles = []
           usernames = []
           prices = []
           descriptions = []
           itemIDs = []
           
           getItems() { (validCode) in
               self.tableView.reloadData()
           }
           
       }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! BuyTableViewCell
        
        // Configure the cell...
        cell.itemTitleLabel.text = titles[indexPath.row]
        cell.itemPriceLabel.text = prices[indexPath.row]
        cell.userNameLabel.text = usernames[indexPath.row]
        cell.itemDescription = descriptions[indexPath.row]
        cell.itemID = itemIDs[indexPath.row]
        itemPicturesHandler(itemImageView: cell.itemImageView, itemID: cell.itemID)
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showBuyDetail") {
            guard let itemDetailViewController = segue.destination as? BuyDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? BuyTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItemIndex = indexPath.row
            itemDetailViewController.itemTitle = selectedItemCell.itemTitleLabel.text!
            itemDetailViewController.itemDescription = selectedItemCell.itemDescription
            itemDetailViewController.itemPrice = selectedItemCell.itemPriceLabel.text!
            itemDetailViewController.itemSeller = selectedItemCell.userNameLabel.text!
            itemDetailViewController.itemId = selectedItemCell.itemID
        }
        
    }
    
    //Image rendering funtions
    func itemPicturesHandler(itemImageView: UIImageView, itemID: String) {
        //first, setting up the default image
        itemImageView.image = UIImage(imageLiteralResourceName: "no-image")
        
        //setting the destination for storing the downloaded file
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/items/item_\(itemID).data")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        //checking cache
        checkCacheForItemPicture(itemImageView: itemImageView, itemID: itemID)
        
        //making the server request
        AF.download(API.URL + "/items/picture/\(itemID)", method: .get, to: destination).responseJSON { response in
            if (response.response?.statusCode != 200) {
                //render default image
                itemImageView.image = self.base64ToUIImage(base64String: "", itemImageView: itemImageView)
            } else {
                //request successful
                if let res = response.value {
                    let resJson = res as! NSDictionary
                    let pictures : NSArray =  resJson.value(forKey: "files") as! NSArray
                    for picture in pictures {
                        let encodedImageString = picture as! String
                        itemImageView.image = self.base64ToUIImage(base64String: encodedImageString, itemImageView: itemImageView)
                    }
                }
            } //end if
        } //request
    }
    
    func checkCacheForItemPicture(itemImageView: UIImageView, itemID: String) {
        //checking for cached image data
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/items/item_\(itemID).data")
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
                            itemImageView.image = self.base64ToUIImage(base64String: file, itemImageView: itemImageView)
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
    
    func base64ToUIImage(base64String: String?, itemImageView: UIImageView) -> UIImage{
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
            return itemImageView.image!
        }
      } //end if
    }
}
