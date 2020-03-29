//
//  File.swift
//  Merchant
//
//  Created by Chirayu Garg on 3/28/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//


struct Item: Decodable {
    let _id: Int
    let title: String
    let price: String
    let category: String
    let userID: String
    let university: String
    let isSold: String
    let description: String
    let picture: [String]
    let DatePosted: String
    let __v: String
    
  enum CodingKeys: String, CodingKey {
    case _id
    case title
    case price
    case category
    case userID
    case university
    case isSold
    case description
    case picture
    case DatePosted
    case __v
  }
}



