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
import PusherSwift
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var proposedButton: UIButton!
    @IBOutlet weak var shareLocationButton: UIButton!
    
    var pusher: Pusher!
    var currentUser = ""
    var conversationID = ""
    var receiver = ""
    var userChattingWith = ""
    var selectedAnnotation: MKPointAnnotation?
    var proposedPlace = Place(title: "Not chosen", address: "Not chosen", coordinate: CLLocationCoordinate2D(latitude: 40.4237, longitude: -86.9200))
    var locationManager = CLLocationManager()
    var currLocation: Place!

    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           AF.request(API.URL + "/meetingLocation/\(conversationID)", method: .get).responseJSON { response in
               if (response.response?.statusCode == 200) {
                   if let res = response.value {
                       let responseJSON = res as! NSDictionary
                       let location : NSDictionary =  responseJSON.value(forKey: "location") as! NSDictionary
                       self.addPointToMapAndRecenter(location: location, current: false)
                   } //end if
               } //end if
           }.resume()
       }
    
    
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
        
        
        
        //fetching any existing meeting location
        AF.request(API.URL + "/meetingLocation/\(conversationID)", method: .get).responseJSON { response in
            if (response.response?.statusCode == 200) {
                if let res = response.value {
                    let responseJSON = res as! NSDictionary
                    let location : NSDictionary =  responseJSON.value(forKey: "location") as! NSDictionary
                    self.addPointToMapAndRecenter(location: location, current: false)
                } //end if
            } //end if
        }.resume()
        
        // listen for changing map locations
        let options = PusherClientOptions(
            host: .cluster("us2")
        )
        
        pusher = Pusher(
            key: "0abb5543b425a847ea81",
            options: options
        )
        pusher.connect()
        
        
        // subscribe to channel
        let channelName = userChattingWith + "-" + currentUser + "-maps"
        print(channelName)
        let channel = pusher.subscribe(channelName)
        
        // bind a callback to handle an event
        let _ = channel.bind(eventName: "map-location", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let location = data["location"] as? NSDictionary {
                    //getting the function response parameters
                    self.addPointToMapAndRecenter(location: location, current: false)
                } //end if
            } //end if
        })
        
        
        // subscribe to channel
        let channelNameCurrent = userChattingWith + "-" + currentUser + "-maps-current"
        print(channelName)
        let channelCurrent = pusher.subscribe(channelNameCurrent)
        
        // bind a callback to handle an event
        let _ = channelCurrent.bind(eventName: "map-location-current", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let location = data["location"] as? NSDictionary {
                    //getting the function response parameters
                    self.addPointToMapAndRecenter(location: location, current: true)
                } //end if
            } //end if
        })
        
        // get user's current location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // locationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let title = currentUser + "'s Current Location"
        currLocation = Place(title: title, address: "Not specified", coordinate: locValue)
    }
    
    @IBAction func shareLocationPressed(_ sender: Any) {
        //TODO change the fill of button
        mapView.addAnnotation(currLocation)
        
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
        let place = Place(title: "Custom pin", address: "Unknown address", coordinate: coordinate)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        annotation.title = "Custom pin"
        mapView.addAnnotation(place)
        mapView.centerToLocation(CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
    }
    
    //function to take the response from web service center the point
    func addPointToMapAndRecenter(location: NSDictionary, current: Bool) {
        //getting the function response parameters
        let latitude : NSNumber =  location.value(forKey: "latitude") as! NSNumber
        let longitude : NSNumber =  location.value(forKey: "longitude") as! NSNumber
        let title : String =  location.value(forKey: "title") as! String
        let address : String =  location.value(forKey: "address") as! String
        
        // update suggested
        proposedPlace = Place(title: title, address: address, coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)))
        
        // change button text
        let tempTitle: String = userChattingWith + "'s suggestion: " + title
        proposedButton.setTitle(tempTitle, for: .normal)

        //make the map coordinate
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(truncating: latitude)), longitude: CLLocationDegrees(Double(truncating: longitude)))

        // Add annotation
        var place: Place
        if (current == true) {
            place = Place(title: "\(title)",
                address: "\(address)", coordinate: coordinate)
        } else {
            place = Place(title: "\(self.userChattingWith)'s suggestion: \(title)",
            address: "\(address)", coordinate: coordinate)
        }
    
        //adding annotation
        self.mapView.addAnnotation(place)
        
        let newLocation = CLLocation(latitude: CLLocationDegrees(truncating: latitude), longitude: CLLocationDegrees(truncating: longitude))
        
        //cantering the map to that point
        self.mapView.centerToLocation(newLocation)
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
            var id: String
            var latitude: Double
            var longitude: Double
            var address: String
            var title: String
            var receiverUsername: String
        }
        
        let params = parameter(id: conversationID,
                               latitude: placeCoords.latitude,
                               longitude: placeCoords.longitude,
                               address: placeAddress ?? "",
                               title: placeName ?? "",
                               receiverUsername: self.userChattingWith)
        
        debugPrint("PARAMS", params)
        
        AF.request(API.URL + "/meetingLocations", method: .post,
                   parameters: params, headers: headers).responseJSON { response in
                if (response.response?.statusCode == 200) {
                   //the meeting location for the conversation has been saved
                    let alert = UIAlertController(title: "Meeting Location", message: "Your suggested meeting location has been shared with \(self.userChattingWith)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    debugPrint("ERROR")
                    let alert = UIAlertController(title: "Meeting Location", message: "Your suggested meeting location couldn't be shared. Try Again!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }.resume()
    }
    
    // handler for when share button is pressed
    func shareCurrentLocation(_ place: Place) {
        let placeName = place.title
        let placeAddress = place.address
        let placeCoords = place.coordinate
    
        // TODO: Aakarshit - please store coordinates (placeCoords.latitude and placeCoords.longitude) in the database however you see fit
        
        let headers: HTTPHeaders = [
            "Authorization": Authentication.getAuthToken(),
            "Accept": "application/json"
        ]
        
        struct parameter: Encodable {
            var latitude: Double
            var longitude: Double
            var address: String
            var title: String
            var receiverUsername: String
        }
        
        let params = parameter(latitude: placeCoords.latitude,
                               longitude: placeCoords.longitude,
                               address: placeAddress ?? "",
                               title: "\(userChattingWith)'s current location",
                               receiverUsername: self.userChattingWith)
        
        debugPrint("PARAMS", params)
        
        AF.request(API.URL + "/sendCurrentLocation", method: .post,
                   parameters: params, headers: headers).responseJSON { response in
                if (response.response?.statusCode == 200) {
                   //the meeting location for the conversation has been saved
                    let alert = UIAlertController(title: "Meeting Location", message: "Your current location has been shared with \(self.userChattingWith)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    debugPrint("ERROR")
                    let alert = UIAlertController(title: "Meeting Location", message: "Your current location couldn't be shared. Try Again!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
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
