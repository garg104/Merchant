//
//  MapViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 4/6/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    //var selectedAnnotation: MKPointAnnotation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        // Do any additional setup after loading the view.
        // initialize location to WL IN
        let purdueCoords = CLLocation(latitude: 40.4237, longitude: -86.9212)
        mapView.centerToLocation(purdueCoords)
    }
    
    func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Custom pin"
        mapView.addAnnotation(annotation)
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

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
