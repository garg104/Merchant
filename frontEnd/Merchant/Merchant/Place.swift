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
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
