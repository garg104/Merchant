//
//  MapViewController.swift
//  Merchant
//
//  Created by Drew Keirn on 4/6/20.
//  Copyright © 2020 CS307 Team 4. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var proposedButton: UIButton!
    @IBOutlet weak var shareLocationButton: UIButton!
    
    var currentUser = ""
    var conversationID = ""
    var receiver = ""
    var userChattingWith = ""
    var selectedAnnotation: MKPointAnnotation?
    var proposedPlace = Place(title: "Temporary place", address: "123 Sesame St", coordinate: CLLocationCoordinate2D(latitude: 40.4237, longitude: -86.9200))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        // Add gesture to mapView
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecognizer)
        
        mapView.mapType = MKMapType.standard
        
        debugPrint(conversationID)

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
        
        let tempTitle: String = userChattingWith + " wants to meet at : " + (proposedPlace.title)!
                
        proposedButton.setTitle(tempTitle, for: .normal)
    }
    
    @IBAction func shareLocationPressed(_ sender: Any) {
        //TODO change the fill of button!
        //if (currently sharing location) {
        //  shareLocationButton.setImage(UIImage(systemName: "location"), for: .normal)
        //} else {
        //  shareLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        //}
    }
    
    @IBAction func getSuggestedAddress(_ sender: Any) {
        let alert = UIAlertController(title: "Address", message: proposedPlace.address, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // gesture for users to add custom pins
    @objc func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation
        let place = Place(title: "Custom pin", address: "Not specified", coordinate: coordinate)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        annotation.title = "Custom pin"
        mapView.addAnnotation(place)
    }
    
    
    
    // when a pin is selected
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
    
    // when either info or share are pressed it goes here
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
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
//        view.image
        
    }
    
    // handler for when share button is pressed
    func share(_ place: Place) {
        let placeName = place.title
        let placeAddress = place.address
        let placeCoords = place.coordinate
    
        // TODO: Aakarshit - please store coordinates (placeCoords.latitude and placeCoords.longitude) in the database however you see fit
        
        let headers: HTTPHeaders = [
            "Authorization": Authentication.getAuthToken(),
            "Accept": "application/json"
        ]
        
        struct parameter: Encodable {
            var conversatioID: String
            var latitude: Double
            var longitude: Double
            var address: String
            var title: String
        }
        
        let params = parameter(conversatioID: conversationID,
                               latitude: placeCoords.latitude,
                               longitude: placeCoords.longitude,
                               address: placeAddress ?? "",
                               title: placeName ?? "")
        
        AF.request(API.URL + "/meetingLocation", method: .post,
                   parameters: params, headers: headers).responseJSON { response in
                if (response.response?.statusCode == 200) {
                   //the meeting location for the conversation has been saved
                } else {
                    debugPrint("ERROR")
                }
            }.resume()
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
