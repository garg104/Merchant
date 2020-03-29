//
//  PostItemViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 3/8/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class PostItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // these next four functions are for the pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns number of elements in pickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    // gets selected element from row number
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    // populates categoryTextField with selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
        categoryTextField.text = selectedCategory
    }
    
    var selectedCategory : String?
    var categories = ["Electronics", "School supplies", "Furniture"]
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        categoryTextField.inputView = pickerView
    }

    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var photosLabel: UILabel!
    @IBOutlet weak var photo1Button: UIButton!
    @IBOutlet weak var photo2Button: UIButton!
    @IBOutlet weak var photo3Button: UIButton!
    @IBOutlet weak var removePhoto1Button: UIButton!
    @IBOutlet weak var removePhoto2Button: UIButton!
    @IBOutlet weak var removePhoto3Button: UIButton!
    
    
    var ourGreen = UIColor .green
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // add border to description textView
        descriptionTextView!.layer.borderWidth = 1
        descriptionTextView!.layer.borderColor = UIColor.black.cgColor
        
        createPickerView()
        
        ourGreen = photo1Button.currentTitleColor
        
        // hide remove buttons
        removePhoto1Button.setTitleColor(.clear, for: .normal)
        removePhoto2Button.setTitleColor(.clear, for: .normal)
        removePhoto3Button.setTitleColor(.clear, for: .normal)

    }
    
    var name = ""
    var desc = ""
    var price = ""
    var photo1: UIImage!
    var photo2: UIImage!
    var photo3: UIImage!
    var category = ""
    var isSold = false;
    var university = "Purdue University"
    
    
    @IBAction func postItem(_ sender: UIButton, completion: @escaping (_ validCode: Int)->()) {
        // make upload request
        name = nameTextField.text!
        desc = descriptionTextView.text!
        price = priceTextField.text!
        photo1 = photo1Button.backgroundImage(for: .normal)
        photo2 = photo2Button.backgroundImage(for: .normal)
        photo3 = photo3Button.backgroundImage(for: .normal)
        category = categoryTextField.text!
        
        // TODO Aakarshit this is where the request needs to be made
    
    }
    
    var flag = 0
    
    @IBAction func photo1Select(_ sender: Any) {
        // choose photos from camera roll
        flag = 1
        photoSelect()
    }
    
    @IBAction func photo2Select(_ sender: Any) {
        flag = 2
        photoSelect()
    }
    
    @IBAction func photo3Select(_ sender: Any) {
        flag = 3
        photoSelect()
    }
    
    func photoSelect () {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // add it
            if flag == 1 {
                photo1Button.setBackgroundImage(image, for: .normal)
                photo1Button.setTitleColor(.clear, for: .normal)
                removePhoto1Button.setTitleColor(.red, for: .normal)
                
            }
            else if flag == 2 {
                photo2Button.setBackgroundImage(image, for: .normal)
                photo2Button.setTitleColor(.clear, for: .normal)
                removePhoto2Button.setTitleColor(.red, for: .normal)

            }
            else if flag == 3 {
                photo3Button.setBackgroundImage(image, for: .normal)
                photo3Button.setTitleColor(.clear, for: .normal)
                removePhoto3Button.setTitleColor(.red, for: .normal)
            }
        }
        else {
            // Error message
        }
        
        // hide controller when finished
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func removePhoto1(_ sender: Any) {
        photo1Button.setBackgroundImage(nil, for: .normal)
        photo1Button.setTitleColor(ourGreen, for: .normal)
        removePhoto1Button.setTitleColor(.clear, for: .normal)
    }
    
    @IBAction func removePhoto2(_ sender: UIButton) {
        photo2Button.setBackgroundImage(nil, for: .normal)
        photo2Button.setTitleColor(ourGreen, for: .normal)
        removePhoto2Button.setTitleColor(.clear, for: .normal)

    }
    
    @IBAction func removePhoto3(_ sender: UIButton) {
        photo3Button.setBackgroundImage(nil, for: .normal)
        photo3Button.setTitleColor(ourGreen, for: .normal)
        removePhoto3Button.setTitleColor(.clear, for: .normal)
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
