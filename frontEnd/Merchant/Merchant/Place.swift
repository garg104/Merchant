//
//  Pin.swift
//  Merchant
//
//  Created by Drew Keirn on 4/22/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import MapKit

class Place: NSObject, MKAnnotation {
    var title: String?
    var address: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.address = address
        self.coordinate = coordinate
    }
}
