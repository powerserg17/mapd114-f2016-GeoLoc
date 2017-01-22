//
//  MapController.swift
//  GeoLoc
//
//  Created by serhiipianykh on 2016-12-07.
//  Copyright © 2016 WiseIT. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    //getting user email that has been used to login
    let username = FIRAuth.auth()?.currentUser?.email
    
    var name : String = ""
    
    //setting link too database root
    let rootRef = FIRDatabase.database().reference()
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this is neccessary because I cannot use '.' character as the name(title) of the database object, so I just remove it from email
        name = (username?.stringByReplacingOccurrencesOfString(".", withString: ""))!
        //setting location manager:
        self.locationManager.delegate = self
        //best accuracy
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //requesting location updates always, even when app is not using
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        //starting listening to location updates
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        let usersRef = rootRef.child("users")
        //setting observer for usersRef, so every time "users" updates following code will run
        usersRef.observeEventType(.Value) { (snap: FIRDataSnapshot) in
            //array for locations
            var updatedPins: [UserLocationPin] = []
            //for every object in "users" create object and append it to array
            for item in snap.children {
                let userloc = UserLocationPin.init(snap: item as! FIRDataSnapshot)
                updatedPins.append(userloc)
            }
            //calling method to update pins on map
            self.refreshMapAnnotations(updatedPins)
        }
        
        // Do any additional setup after loading the view.
        
    }
    
    //when button pressed camera goes to user's location
    @IBAction func goToMyLocation(sender: AnyObject) {
        centerMapOnLocation(self.locationManager.location!)
    }
    
    //setting regionRadius and setting region to location passed
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func refreshMapAnnotations(pins:[UserLocationPin]) {
        //cleaning all annotations(pins) from map
        self.mapView.removeAnnotations(mapView.annotations)
        //adding new pins from array
        for pin in pins {
            self.mapView.addAnnotation(pin)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //when location is updated
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //getting last received location
        let location = locations.last;
        
        //creating object for user location
        let userPin = UserLocationPin.init(title: name,latitude: (location?.coordinate.latitude)!,longitude: (location?.coordinate.longitude)!)
        let usersRef = rootRef.child("users")
        let itemRef = usersRef.child(userPin.title!)
        //adding location to database
        itemRef.setValue(["latitude": userPin.coordinate.latitude, "longitude": userPin.coordinate.longitude])
        
    }
    
    //if something wrong with location
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error occured: " + error.localizedDescription)
    }
   
    //when pressing "<back" in navbar: remove location from database, destroy observers, signout
    override func viewWillDisappear(animated: Bool) {
        let usersRef = rootRef.child("users")
        let itemRef = usersRef.child(name)
        do {
            itemRef.removeValue()
            usersRef.removeAllObservers()
            try FIRAuth.auth()?.signOut()
        } catch let logOutError {
            print(logOutError)
        }
        
    }
    
    
    
    
}
