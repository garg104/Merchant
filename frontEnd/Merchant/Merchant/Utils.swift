//
//  Utils.swift
//  Merchant
//
//  Created by Aakarshit Pandey on 04/04/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

extension UserDefaults {
    
    enum UserDefaultKeys: String {
        case isLoggedIn
        case authToken
        case currentUsername
        case deviceTokenID
    } //userDefaultKeys
    
    func setDeviceToken(tokenID: String) {
        set(tokenID, forKey: UserDefaultKeys.deviceTokenID.rawValue)
        synchronize()
    } //setIsLoggedIn
    
    func setIsLoggedIn(authStatus: Bool) {
        set(authStatus, forKey: UserDefaultKeys.isLoggedIn.rawValue)
        synchronize()
    } //setIsLoggedIn
    
    func setAuthToken(authToken: String) {
        set(authToken, forKey: UserDefaultKeys.authToken.rawValue)
        synchronize()
    }
    
    func setCurrentUser(username: String) {
        set(username, forKey: UserDefaultKeys.currentUsername.rawValue)
        synchronize()
    }
    
    func removeAuthToken() {
        removeObject(forKey: UserDefaultKeys.authToken.rawValue)
        synchronize()
    }
    
    func getUsername() -> String {
        return string(forKey: UserDefaultKeys.currentUsername.rawValue) ?? ""
    }
    
    func getDeviceToken() -> String {
        return string(forKey: UserDefaultKeys.deviceTokenID.rawValue) ?? ""
    }
    
    func getAuthToken() -> String {
        let token =  string(forKey: UserDefaultKeys.authToken.rawValue) ?? ""
        return "Bearer \(token)"
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultKeys.isLoggedIn.rawValue)
    } //isLoggedIn
} //UserDefaults

class StateManager {
    static var updateWishlist: Bool =  false
    
    static func getUpdatedDeviceToken() -> String {
        var deviceToken = ""
        InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                  debugPrint("Error fetching remote instance ID: \(error)")
                } else if let result = result {
                  debugPrint("Remote instance ID token: \(result.token)")
                    deviceToken = result.token
        //          self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
                }
        }
        return deviceToken
    }
    
    static func sendDeviceToken() {
        struct parameter: Encodable {
            var token: String
        }
        
        let headers: HTTPHeaders = [
            "Authorization": Authentication.getAuthToken(),
            "Accept": "application/json"
        ]
        
        let token = getUpdatedDeviceToken()
        
        UserDefaults.standard.setDeviceToken(tokenID: token)
        
        if (token.elementsEqual("")) {
            return
        }
        
        AF.request(API.URL + "/user/addDeviceToken", method: .post, parameters: parameter(token: token), encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseJSON { response in
            let status = (response.response?.statusCode ?? 0)
            if (status == 200) {
                debugPrint("Posted device token")
            } else {
                debugPrint("Failed to post device token")
            }
        }
    }
}

class Authentication {
    
    //Not in use right now
    enum AuthenticationKeys: String {
        case authToken = "com.merchant.keys.jwt"
    } //AuthenticationKeys
    
    static func login(authToken: String) {
        //storeAuthTokenInKeyChain(authToken: authToken)
        UserDefaults.standard.setIsLoggedIn(authStatus: true)
        UserDefaults.standard.setAuthToken(authToken: authToken)
    }
    
    static func isLoggedIn() -> Bool {
        //storeAuthTokenInKeyChain(authToken: authToken)
        return UserDefaults.standard.isLoggedIn()
    }
    
    static func logout() {
        //deleteAuthToken()
        UserDefaults.standard.removeAuthToken()
        UserDefaults.standard.setIsLoggedIn(authStatus: false)
    }
    
    static func setCurrentUser(username: String) {
        //deleteAuthToken()
        UserDefaults.standard.setCurrentUser(username: username)
    }
    
    static func getAuthToken() -> String {
        //getting the JWT token
        return UserDefaults.standard.getAuthToken()
    }
    
    static func getCurrentUser() -> String {
        //get the current user
        return UserDefaults.standard.getUsername()
    }
        
    //Not in use right now
    func storeAuthTokenInKeyChain(authToken: String) {
        let tag = AuthenticationKeys.authToken.rawValue.data(using: .utf8)
        let addJWT: [String: Any] = [kSecClass as String: kSecClassKey,
                                     kSecAttrApplicationTag as String: tag!,
                                     kSecValueRef as String: authToken]
        let status = SecItemAdd(addJWT as CFDictionary, nil)
        guard status == errSecSuccess else { debugPrint("Couldn't store JWT"); return }
    } //storeAuthTokenInKeyChain
    
    //Not in use right now
    func updateAuthTokenInKeyChain(authToken: String) {
        let tag = AuthenticationKeys.authToken.rawValue.data(using: .utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassKey, kSecAttrApplicationTag as String: tag!]
        let attributes: [String: Any] = [kSecValueRef as String: authToken]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else { debugPrint("Adding new"); storeAuthTokenInKeyChain(authToken: authToken); return }
        guard status == errSecSuccess else { debugPrint("couldn't update the keychain"); return }
        debugPrint("Done")
    }
    
    //Not in use right now
    func getAuthToken() -> String {
        let tag = AuthenticationKeys.authToken.rawValue.data(using: .utf8)
        let getJWT: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag!,
                                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                    kSecReturnRef as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getJWT as CFDictionary, &item)
        guard status == errSecSuccess else { debugPrint("Couldn't fetch JWT"); return ""}
        let key = item as! SecKey
        return key as! String
    } //getAuthToken
    
    //Not in use right now
    func deleteAuthToken() {
        let tag = AuthenticationKeys.authToken.rawValue.data(using: .utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassKey, kSecAttrApplicationTag as String: tag!]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { debugPrint("Couldn't delete"); return }
    }
} //Authentication

extension UIImageView {
    
    func loadImageFromItemID(itemID: String) {
        image = UIImage(imageLiteralResourceName: "no-image")
        accessibilityLabel = itemID
        
        //setting the destination for storing the downloaded file
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("com.merchant.turkeydaddy/pictures/items/item_\(itemID).data")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        //checking cache
        checkCacheForItemPicture(itemImageView: self, itemID: itemID)
        
        //making the server request
        AF.download(API.URL + "/items/picture/\(itemID)", method: .get, to: destination).responseJSON { response in
            if (response.response?.statusCode != 200) {
                //render default image
                if (self.accessibilityLabel == itemID) {
                    self.image = base64ToUIImage(base64String: "", itemImageView: self)
                }
            } else {
                //request successful
                if let res = response.value {
                    let resJson = res as! NSDictionary
                    let pictures : NSArray =  resJson.value(forKey: "files") as! NSArray
                    for picture in pictures {
                        let encodedImageString = picture as! String
                        if (self.accessibilityLabel == itemID) {
                            self.image = base64ToUIImage(base64String: encodedImageString, itemImageView: self)
                        } else {
                            debugPrint("ITEM ID NOT MATCHING: ", self.accessibilityLabel ?? "NONE", itemID)
                        }
                        break
                    }
                }
            } //end if
        }.resume() //request
    }
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
                        itemImageView.image = base64ToUIImage(base64String: file, itemImageView: itemImageView)
                        break
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
