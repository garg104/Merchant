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
    var selectedAnnotation: MKPointAnnotation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        // Add gesture to mapView
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecognizer)
        
        mapView.mapType = MKMapType.standard

        // Do any additional setup after loading the view.
        // initialize cenetered location to WL, IN
        let purdueLocation = CLLocation(latitude: 40.4237, longitude: -86.9212)
        mapView.centerToLocation(purdueLocation)
        
        let PMU = Place(title: "PMU", coordinate: CLLocationCoordinate2D(latitude: 40.4247, longitude: -86.911), info: "Purdue Memorial Union")
    }
    
    @objc func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Custom pin"
        mapView.addAnnotation(annotation)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let latValStr : String = String(format: "%.02f", Float((view.annotation?.coordinate.latitude)!))
        let longValStr : String = String(format: "%.02f", Float((view.annotation?.coordinate.longitude)!))
        
        print("latitude:\(latValStr) & longitude\(longValStr)")

    }
    
    // when custom pin is selected
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Pin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let shareButton = UIButton(type: .roundedRect)
            annotationView?.rightCalloutAccessoryView = shareButton
        }
        else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
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
