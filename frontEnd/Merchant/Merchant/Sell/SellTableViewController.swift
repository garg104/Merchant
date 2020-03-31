//
//  SellTableViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 3/14/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class SellTableViewController: UITableViewController {
    
    var currentUser = ""
    let cellView = SellTableViewCell()
    
    //data structures for simple testing (replace with JSON array)
    var images: [String] = []
    var titles: [String] = []
    var usernames: [String] = []
    var prices: [String] = []
    var descriptions: [String] = []
    var categories: [Int] = []
    var itemIDs: [String] = []
    
    var filterCategories = ["None", "Electronics", "School supplies", "Furniture"]
    
    
    @IBAction func refreshButton(_ sender: Any) {
        updateData()
    }
    
    func getItems(completion: @escaping (_ validCode: Int)->()) {
        // #warning Incomplete implementation, return the number of sections
        
        struct parameters: Encodable {
            var username = ""
        }
                
        AF.request(API.URL + "/items/userSellingCurrent/\(currentUser)", method: .get).responseJSON { response in
    
            if (response.response?.statusCode == 200) {
                if let info = response.value {
                    let JSON = info as! NSDictionary
                    let items : NSArray =  JSON.value(forKey: "items") as! NSArray
                    for item in items {
                        print(item)
                        let temp = item as! NSDictionary
                        self.titles.append(temp["title"]! as! String)
                        self.prices.append(temp["price"]! as! String)
                        self.descriptions.append(temp["description"]! as! String)
                        self.itemIDs.append(temp["_id"]! as! String)
                        self.categories.append(Int(temp["category"] as! String)!)
                    }
                }
            } else {
                debugPrint("ERROR")
            }
            
            completion(0)
            
        }.resume()
    }
    
    @IBAction func unwindToSellTableViewController(segue: UIStoryboardSegue) {
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

    }
    
    func updateData() {
        images = []
        titles = []
        usernames = []
        prices = []
        descriptions = []
        itemIDs = []
        categories = []
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "sellCell", for: indexPath) as! SellTableViewCell

        // Configure the cell...
        
        cell.itemTitleLabel.text = titles[indexPath.row]
        cell.itemPriceLabel.text = prices[indexPath.row]
        cell.itemDescription = descriptions[indexPath.row]
        cell.itemID = itemIDs[indexPath.row]
        cell.username = currentUser

        return cell
    }
    
    
    @IBAction func removeButton(_ sender: Any) {
        debugPrint("remove clicked")
        
        guard let cell = (sender as AnyObject).superview?.superview as? SellTableViewCell else {
            return // or fatalError() or whatever
        }

        let indexPath = tableView.indexPath(for: cell)
        
        print("ITEM ID")
        print()
        
        // create alert
        let alert = UIAlertController(title: "Please Confirm", message: "Are you sure you want to remove the Item from sale?", preferredStyle: .alert)
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel,
                                   handler: { (action) -> Void in
            // add action if needed
        })
        
        // Create Confirm button with action handler
        let confirm = UIAlertAction(title: "Confirm",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        self.cellView.removeItemHandler(
                                            itemID: self.itemIDs[indexPath!.row],
                                            username: self.currentUser ) { (validCode) in
                                                self.updateData()
                                        }
                                        
        })

        // add actions to the alert
        alert.addAction(confirm)
        alert.addAction(cancel)

        // display alert
        self.present(alert, animated: true)
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
            print(itemIDs[indexPath.row])
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
        
        if (segue.identifier == "toPostItem") {
            let vc = segue.destination as! PostItemViewController
            vc.currentUser = self.currentUser
        }
        
        if (segue.identifier == "showSellDetail") {
            guard let itemDetailViewController = segue.destination as? SellDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? SellTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItemIndex = indexPath.row
            //_ = indexPath.row
            
            itemDetailViewController.itemTitle = selectedItemCell.itemTitleLabel.text!
            itemDetailViewController.itemDescription = selectedItemCell.itemDescription
            itemDetailViewController.itemPrice = prices[selectedItemIndex]
            itemDetailViewController.itemId = selectedItemCell.itemID
            itemDetailViewController.category = filterCategories[categories[selectedItemIndex]]
        }
        
    }
    

}



