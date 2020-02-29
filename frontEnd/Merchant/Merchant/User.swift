//
//  User.swift
//  Merchant
//
//  Created by Chirayu Garg on 2/29/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import Foundation

struct Constants {
    // ...

    struct UserDefaults {
        static let currentUser = "currentUser"
    }
}

class User: Codable {
    private static var _current: User?
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }

    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            if let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
            }
        }

        _current = user
    }

}

