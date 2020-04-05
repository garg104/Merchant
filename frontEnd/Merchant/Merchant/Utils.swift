//
//  Utils.swift
//  Merchant
//
//  Created by Aakarshit Pandey on 04/04/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum UserDefaultKeys: String {
        case isLoggedIn
        case authToken
        case currentUsername
    } //userDefaultKeys
    
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
    
    func getAuthToken() -> String {
        let token =  string(forKey: UserDefaultKeys.authToken.rawValue) ?? ""
        return "Bearer \(token)"
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultKeys.isLoggedIn.rawValue)
    } //isLoggedIn
} //UserDefaults

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
