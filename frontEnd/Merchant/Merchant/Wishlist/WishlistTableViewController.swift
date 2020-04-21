//
//  WishlistTableViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/11/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

extension WishlistTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}

extension WishlistTableViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar,
      selectedScopeButtonIndexDidChange selectedScope: Int) {
    let category = searchCategories[selectedScope]
    print("CATEGORY:")
    print(category)
    filterContentForSearchText(searchBar.text!)
  }
}

class WishlistTableViewController: UITableViewController {
    
    var currentUser = ""
    
    //data structures
    var images: [String] = []
    var titles: [String] = []
    var usernames: [String] = []
    var prices: [String] = []
    var descriptions: [String] = []
    var itemCategories: [Int] = []
    var itemIDs: [String] = []
    
    var filterCategories = ["None", "Electronics", "School supplies", "Furniture"]
    var catFilterIndex = 0
    var priceFilterIndex = 0
    var searchCategories = ["Item", "User"]
    var searched: [Int] = []
    var searchCat = 0
    
    // Search Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    //check for empty search bar
    var isSearchBarEmpty: Bool {
        print("SCOPE INDEX")
        print(searchController.searchBar.selectedScopeButtonIndex)
        searchCat = searchController.searchBar.selectedScopeButtonIndex
        //let searchBarScopeIsFiltering =
          //searchController.searchBar.selectedScopeButtonIndex != 0
        //return searchController.isActive &&
            /*(!self.isSearchBarEmpty || searchBarScopeIsFiltering)*/
        
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //check for if filtering
    var isSearching: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        updateData()
    }
    
    func getItems(completion: @escaping (_ validCode: Int)->()) {
        // #warning Incomplete implementation, return the number of sections
        
        struct parameters: Encodable {
            var username = ""
        }
          
        let headers: HTTPHeaders = [
            "Authorization": Authentication.getAuthToken(),
            "Accept": "application/json"
        ]
        AF.request(API.URL + "/user/wishlist/", method: .get, headers: headers).responseJSON { response in
    
            if (response.response?.statusCode == 200) {
                if let info = response.value {
                    let JSON = info as! NSDictionary
                    let items : NSArray =  JSON.value(forKey: "wishlist") as! NSArray
                    for item in items {
                        // make sure that the user does not see the objects they are selling
                        let temp = item as! NSDictionary
                        
                        if (self.catFilterIndex == 0) {
                            if (self.currentUser != temp["username"] as! String) {
                                print(item)
                                self.titles.append(temp["title"]! as! String)
                                self.prices.append(temp["price"]! as! String)
                                self.usernames.append(temp["username"] as! String)
                                self.descriptions.append(temp["description"]! as! String)
                                self.itemIDs.append(temp["_id"]! as! String)
                                self.itemCategories.append(Int(temp["category"] as! String)!)
                            }
                        } else if (self.catFilterIndex == 1) {
                            print(self.filterCategories[self.catFilterIndex])
                            if (self.currentUser != temp["username"] as! String) {
                                if (Int(temp["category"] as! String)! == self.catFilterIndex) {
                                    self.titles.append(temp["title"]! as! String)
                                    self.prices.append(temp["price"]! as! String)
                                    self.usernames.append(temp["username"] as! String)
                                    self.descriptions.append(temp["description"]! as! String)
                                    self.itemIDs.append(temp["_id"]! as! String)
                                    self.itemCategories.append(Int(temp["category"] as! String)!)
                                }
                            }
                        } else if (self.catFilterIndex == 2) {
                            print(self.filterCategories[self.catFilterIndex])
                            if (self.currentUser != temp["username"] as! String) {
                                if (Int(temp["category"] as! String)! == self.catFilterIndex) {
                                    self.titles.append(temp["title"]! as! String)
                                    self.prices.append(temp["price"]! as! String)
                                    self.usernames.append(temp["username"] as! String)
                                    self.descriptions.append(temp["description"]! as! String)
                                    self.itemIDs.append(temp["_id"]! as! String)
                                    self.itemCategories.append(Int(temp["category"] as! String)!)
                                }
                            }
                        } else if (self.catFilterIndex == 3) {
                            print(self.filterCategories[self.catFilterIndex])
                            if (self.currentUser != temp["username"] as! String) {
                                if (Int(temp["category"] as! String)! == self.catFilterIndex) {
                                    self.titles.append(temp["title"]! as! String)
                                    self.prices.append(temp["price"]! as! String)
                                    self.usernames.append(temp["username"] as! String)
                                    self.descriptions.append(temp["description"]! as! String)
                                    self.itemIDs.append(temp["_id"]! as! String)
                                    self.itemCategories.append(Int(temp["category"] as! String)!)
                                }
                            }
                        }
                        
                    }
                }
            } else {
                debugPrint("ERROR")
            }
            
            completion(0)
            
        }.resume()
    }
    
    @IBAction func unwindToWishlistTableViewController(segue: UIStoryboardSegue) {
        if (segue.identifier == "applyWishFilters") {
            print("unwindAfterApply")
            print("catFilterIndex")
            print(catFilterIndex)
            print("priceFilterIndex")
            print(priceFilterIndex)
            updateData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (StateManager.updateWishlist) {
            updateData()
            StateManager.updateWishlist = false
        } //end if
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
        
        //search controller initilization
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.searchBar.scopeButtonTitles = searchCategories
        searchController.searchBar.delegate = self
        
        //setup search controller components
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "What are you looking for?"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    //search filtering function
    func filterContentForSearchText(_ searchText: String) {
        
        searched = []
        
        if (searchCat == 0) {
            //filtered = titles.filter{ $0.lowercased().contains(searchText.lowercased())}
            
            var index = 0;
            for item in titles { //finding indexes with matching titles
                if (item.lowercased().contains(searchText.lowercased())) {
                    searched.append(index)
                }
                index = index + 1;
            }
            
            
        } else if (searchCat == 1) {
            //filtered = usernames.filter{ $0.lowercased().contains(searchText.lowercased())}
            
            var index = 0;
            for item in usernames { //find indexes with matching usernames
                if (item.lowercased().contains(searchText.lowercased())) {
                    searched.append(index)
                }
                index = index + 1;
            }
            
        }
        tableView.reloadData()
    }
    
    func updateData() {
        
        titles = []
        usernames = []
        prices = []
        descriptions = []
        itemCategories = []
        itemIDs = []
        
        var titlesTemp: [String] = []
        var usernamesTemp: [String] = []
        var pricesTemp: [String] = []
        var descriptionsTemp: [String] = []
        var itemCategoriesTemp: [Int] = []
        var itemIDsTemp: [String] = []
           
        getItems() { (validCode) in
            var sortedIndices: [Int] = []
            if (self.priceFilterIndex == 1) {
                sortedIndices = self.sortLowToHigh()
            } else if (self.priceFilterIndex == 2) {
                sortedIndices = self.sortHighToLow()
            }
            
            print(self.images)
            
            if (self.priceFilterIndex != 0 && (self.titles.count - 1 > 0)) {
                for i in 0...(self.titles.count - 1) {
                    titlesTemp.append(self.titles[sortedIndices[i]])
                    usernamesTemp.append(self.usernames[sortedIndices[i]])
                    pricesTemp.append(self.prices[sortedIndices[i]])
                    descriptionsTemp.append(self.descriptions[sortedIndices[i]])
                    itemCategoriesTemp.append(self.itemCategories[sortedIndices[i]])
                    itemIDsTemp.append(self.itemIDs[sortedIndices[i]])
                }
                self.titles = titlesTemp
                self.usernames = usernamesTemp
                self.prices = pricesTemp
                self.descriptions = descriptionsTemp
                self.itemCategories = itemCategoriesTemp
                self.itemIDs = itemIDsTemp
            }
            
            self.tableView.reloadData()
        }
           
    }
    
    func sortLowToHigh() -> [Int] {
        
        var priceSorted: [Double] = []
        var sortIndices: [Int] = []
        
        var unsortedIndex = 0
        for item in prices {
            let start = item.index(item.startIndex, offsetBy: 1)
            let end = item.endIndex
            let range = start..<end
            print(item[range])
            let noCommas = item[range].replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range: nil)
            let currPrice = Double(noCommas)!
            
            if (priceSorted.count == 0) {
                priceSorted.append(currPrice)
                sortIndices.append(unsortedIndex)
            } else {
                var sortedIndex = 0
                for sortItem in priceSorted {
                    if (currPrice > sortItem) {
                        sortedIndex = sortedIndex + 1
                        if (sortedIndex == priceSorted.count) { //at end or array
                            priceSorted.append(currPrice)
                            sortIndices.append(unsortedIndex)
                            break
                        }
                        continue
                    } else {
                        priceSorted.insert(currPrice, at: sortedIndex)
                        sortIndices.insert(unsortedIndex, at: sortedIndex)
                        break
                    }
                    
                }
            }
            unsortedIndex = unsortedIndex + 1;
        }
        print("LowHighSORTED")
        print(priceSorted)
        print(sortIndices)
        return sortIndices
    }
    
    func sortHighToLow() -> [Int] {
        var priceSorted: [Double] = []
        var sortIndices: [Int] = []
        
        var unsortedIndex = 0
        for item in prices {
            let start = item.index(item.startIndex, offsetBy: 1)
            let end = item.endIndex
            let range = start..<end
            print("CURRENT PRICE")
            print(item[range])
            let noCommas = item[range].replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range: nil)
            let currPrice = Double(noCommas)!
            
            if (priceSorted.count == 0) {
                priceSorted.append(currPrice)
                sortIndices.append(unsortedIndex)
            } else {
                var sortedIndex = 0
                for sortItem in priceSorted {
                    if (currPrice < sortItem) {
                        sortedIndex = sortedIndex + 1
                        if (sortedIndex == priceSorted.count) { //at end or array
                            priceSorted.append(currPrice)
                            sortIndices.append(unsortedIndex)
                            break
                        }
                        continue
                    } else {
                        priceSorted.insert(currPrice, at: sortedIndex)
                        sortIndices.insert(unsortedIndex, at: sortedIndex)
                        break
                    }
                    
                }
            }
            unsortedIndex = unsortedIndex + 1;
        }
        print("HighLowSORTED")
        print(priceSorted)
        print(sortIndices)
        return sortIndices
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (isSearching) {
            return searched.count
        }
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishItemCell", for: indexPath) as! WishlistTableViewCell
        
        // Configure the cell...
        if (isSearching) {
            //display search results
            cell.itemTitleLabel.text = titles[searched[indexPath.row]]
            cell.itemPriceLabel.text = prices[searched[indexPath.row]]
            cell.userNameLabel.text = usernames[searched[indexPath.row]]
            cell.itemDescription = descriptions[searched[indexPath.row]]
            cell.itemCategory = itemCategories[searched[indexPath.row]]
            cell.itemID = itemIDs[searched[indexPath.row]]
            cell.itemImageView.loadImageFromItemID(itemID: cell.itemID)
//            itemPicturesHandler(itemImageView: cell.itemImageView, itemID: cell.itemID)
        } else {
            cell.itemTitleLabel.text = titles[indexPath.row]
            cell.itemPriceLabel.text = prices[indexPath.row]
            cell.userNameLabel.text = usernames[indexPath.row]
            cell.itemDescription = descriptions[indexPath.row]
            cell.itemCategory = itemCategories[indexPath.row]
            cell.itemID = itemIDs[indexPath.row]
            cell.itemImageView.loadImageFromItemID(itemID: cell.itemID)
//            itemPicturesHandler(itemImageView: cell.itemImageView, itemID: cell.itemID)
        }
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
        
        if (segue.identifier == "showWishDetail") {
            guard let itemDetailViewController = segue.destination as? BuyDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? WishlistTableViewCell else {
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
        
        if (segue.identifier == "showWishFilters") {
            let vc = segue.destination as! WishFilterViewController
            print("showWishFilters")
            print("catFilterIndex")
            print(catFilterIndex)
            print("priceFilterIndex")
            print(priceFilterIndex)
            vc.catFilterIndex = catFilterIndex
            vc.priceFilterIndex = priceFilterIndex
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
                        //debugPrint("Cache hit: successfully rendered image")
                    }
                }
            } catch {
                //File in cache is corrupted
                //debugPrint("Chache Miss, making the request")
            } //end do-catch
        } //end if
    }
    
    func base64ToUIImage(base64String: String?, itemImageView: UIImageView) -> UIImage{
      if (base64String?.isEmpty)! {
          //debugPrint("No picture found")
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
