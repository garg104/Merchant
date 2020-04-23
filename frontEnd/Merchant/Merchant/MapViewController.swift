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
        // Center map on Purdue
        let purdueLocation = CLLocation(latitude: 40.4237, longitude: -86.9212)
        mapView.centerToLocation(purdueLocation)
        
        // create default places
        let PMU = Place(title: "PMU", address: "101 North Grant Street West Lafayette, IN 47906", coordinate: CLLocationCoordinate2D(latitude: 40.4247, longitude: -86.911))
        let engineeringFountain = Place(title: "Engineering Fountain", address: "610 Purdue Mall, West Lafayette, IN 47906", coordinate: CLLocationCoordinate2D(latitude: 40.4286, longitude: -86.9138))
        let harrys = Place(title: "Harry's Chocolate Shop", address: "329 W State St, West Lafayette, IN 47906", coordinate: CLLocationCoordinate2D(latitude: 40.4238, longitude: -86.9090))
        let corec = Place(title: "CoRec", address: "355 Martin Jischke Dr, West Lafayette, IN 47906", coordinate: CLLocationCoordinate2D(latitude: 40.4285, longitude: -86.9220))
                
        // add default places to map
        mapView.addAnnotation(PMU)
        mapView.addAnnotation(engineeringFountain)
        mapView.addAnnotation(harrys)
        mapView.addAnnotation(corec)
    }
    
    // gesture for users to add custom pins
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Place else { return nil }
        
        let identifier = "Place"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let shareButton = UIButton(type: .contactAdd)
            
            annotationView?.rightCalloutAccessoryView = shareButton
            annotationView?.leftCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    // share button is pressed
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let place = view.annotation as? Place else { return }
        
        let placeName = place.title
        let placeAddress = place.address
        
        if view.rightCalloutAccessoryView == control { // if share
            let ac = UIAlertController(title: placeName, message: "Would you like to select this location?", preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in self.share(place) }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
        else if view.leftCalloutAccessoryView == control { // if info
            let alert = UIAlertController(title: "Address", message: placeAddress, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yeet", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
//        view.image
        
    }
    
    func share(_ place: Place) {
        let placeName = place.title
        let placeAddress = place.address
        let placeCoords = place.coordinate
    
        // TODO: Aakarshit - please store coordinates (placeCoords.latitude and placeCoords.longitude) in the database however you see fit
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
