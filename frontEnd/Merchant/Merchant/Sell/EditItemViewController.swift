//
//  EditItemViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 3/29/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import Alamofire

class EditItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    let pickerView = UIPickerView()
    
    func createPickerView() {
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
        photo1Button.setBackgroundImage(photo1, for: .normal)
        photo1Button.setTitleColor(.clear, for: .normal)
        removePhoto1Button.setTitleColor(.red, for: .normal)
        
        nameTextField.text! = name
        descriptionTextView.text! = desc
        priceTextField.text! = price
        
        // add border to description textView
        descriptionTextView!.layer.borderWidth = 1
        descriptionTextView!.layer.borderColor = UIColor.black.cgColor
        descriptionTextView!.isEditable = true
        
        createPickerView()
        
        ourGreen = photo1Button.currentTitleColor
        
        // hide remove buttons
        removePhoto1Button.setTitleColor(.clear, for: .normal)
        removePhoto2Button.setTitleColor(.clear, for: .normal)
        removePhoto3Button.setTitleColor(.clear, for: .normal)
        
        // setup price for currency format
        priceTextField.delegate = self
        priceTextField.placeholder = updateAmount()
        
        // create tapper for picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissPicker(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissPicker (_ sender: UITapGestureRecognizer) {
        pickerView.resignFirstResponder()
    }
    
    var amt: Int = 0
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int(string) {
            amt = amt * 10 + digit
            priceTextField.text = updateAmount()
        }
        
        if string == "" {
            amt = amt/10
            priceTextField.text = updateAmount()
        }
        
        return false
    }
    
    // function for currency format
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(amt/100) + Double(amt%100)/100
        return formatter.string(from: NSNumber(value: amount))
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
    var itemId = ""
    
    
    @IBAction func postItem(_ sender: UIButton) {
        if (nameTextField.text! == "") {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter a title", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        
        if (descriptionTextView.text == "") {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter a description", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        if (priceTextField.text == "") {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter a price", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        if (categoryTextField.text == "") {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter a price", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        // make upload request
        name = nameTextField.text!
        desc = descriptionTextView.text!
        price = priceTextField.text!
        photo1 = photo1Button.backgroundImage(for: .normal)
        photo2 = photo2Button.backgroundImage(for: .normal)
        photo3 = photo3Button.backgroundImage(for: .normal)
        category = categoryTextField.text!
        
        // TODO Aakarshit this is where the request needs to be made
        struct parameter: Encodable {
            var title: String
            var description: String
            var price: String
            var category: String
            var id: String
        }
        
        let details = parameter(title: nameTextField.text ?? name,
                                description: descriptionTextView.text ?? description,
                                price: priceTextField.text ?? price,
                                category: categoryTextField.text ?? category,
                                id: itemId)
        
        //include content type as multipart data to be recognised by multer
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "Accept": "application/json"
        ]
        
        
        //Request to the sever
        AF.upload(multipartFormData: {multipartFormData in
            if (self.photo1 != nil) {
                debugPrint("Adding one image")
                multipartFormData.append(self.photo1.jpegData(compressionQuality: 0.1)!, withName: "data", mimeType: "image/jpeg")
            } //end if
            if (self.photo2 != nil) {
                multipartFormData.append(self.photo2.jpegData(compressionQuality: 0.1)!, withName: "data", mimeType: "image/jpeg")
            } //end if
            if (self.photo3 != nil) {
                multipartFormData.append(self.photo3.jpegData(compressionQuality: 0.1)!, withName: "data", mimeType: "image/jpeg")
            } //end if
        }, to: API.URL + "/items/pictures/\(self.itemId)", headers: headers).responseJSON { response in
            //store the updated profile picture in cache
            if (response.response?.statusCode != 201) {
                let alert = UIAlertController(title: "Unsuccessful post", message: "Your post was unsuccessful. Please enter all fields and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            } else {
                //TODO: DREW make sure that we display a success message saying item has been posted
                debugPrint("IMAGE SUCCESS")
            }
        } //end response handler
        
        AF.request(API.URL + "/items/", method: .put, parameters: details, encoder:    URLEncodedFormParameterEncoder.default).response { response in
            debugPrint(response)
            
            let validationCode = response.response?.statusCode
            
            if (validationCode == 200) { //success
                debugPrint("SUCCESS!!!!")
                //                            self.performSegue(withIdentifier: "saveEditUnwind", sender: nil)
            }  else { //error in database check
                let alert = UIAlertController(title: "Error", message: "Item could not be updated. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
        
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
        // handles if camera exists on device (sim vs. device)
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            image.sourceType = UIImagePickerController.SourceType.camera
        }
        image.allowsEditing = false
        self.present(image, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // add it
            if flag == 1 {
                photo1 = image
                photo1Button.setBackgroundImage(image, for: .normal)
                photo1Button.setTitleColor(.clear, for: .normal)
                removePhoto1Button.setTitleColor(.red, for: .normal)
                
            }
            else if flag == 2 {
                photo2 = image
                photo2Button.setBackgroundImage(image, for: .normal)
                photo2Button.setTitleColor(.clear, for: .normal)
                removePhoto2Button.setTitleColor(.red, for: .normal)
                
            }
            else if flag == 3 {
                photo3 = image
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
