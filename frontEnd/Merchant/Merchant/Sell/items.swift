//
//  items.swift
//  Merchant
//
//  Created by Chirayu Garg on 3/28/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import Foundation

struct Items: Decodable {
//  let count: Int
  let all: [Item]
  
  enum CodingKeys: String, CodingKey {
//    case count
    case all = "items"
  }
}
