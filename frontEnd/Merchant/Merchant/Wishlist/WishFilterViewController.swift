//
//  WishFilterViewController.swift
//  Merchant
//
//  Created by Domenic Conversa on 4/12/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit

class WishFilterViewController: UIViewController {

    var priceFilterIndex = 0;
    var catFilterIndex = 0;

    @IBOutlet weak var priceFilterSegControl: UISegmentedControl!
    @IBOutlet weak var categoryFilterSegControl: UISegmentedControl!
    
    @IBAction func priceFilter(_ sender: Any) {
        priceFilterIndex = priceFilterSegControl.selectedSegmentIndex
    }
    @IBAction func categoryFilter(_ sender: Any) {
        catFilterIndex = categoryFilterSegControl.selectedSegmentIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        priceFilterSegControl.selectedSegmentIndex = priceFilterIndex
        categoryFilterSegControl.selectedSegmentIndex = catFilterIndex
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "applyWishFilters") {
            print("applyWishFilters")
            print("catFilterIndex")
            print(catFilterIndex)
            print("priceFilterIndex")
            print(priceFilterIndex)
            let vc = segue.destination as! WishlistTableViewController
            vc.catFilterIndex = catFilterIndex
            vc.priceFilterIndex = priceFilterIndex
        }
    }

}
