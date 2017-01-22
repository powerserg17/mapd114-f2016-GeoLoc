//
//  LocationPin.swift
//  GeoLoc
//
//  Created by serhiipianykh on 2016-12-07.
//  Copyright © 2016 WiseIT. All rights reserved.
//

import Foundation
import MapKit
import FirebaseDatabase

//Implementing MKAnnotation, so I can use objects of this class to create annotations straight away
class UserLocationPin: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    //In case if it's needed to be initialized from code
    init(title: String, latitude: Double, longitude: Double) {
        self.title = title
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        print(title)
    }
    
    //Initialize from Firebase data received on change (snapshot)
    init(snap: FIRDataSnapshot) {
        self.title = snap.key
        let snapValue = snap.value as! [String:AnyObject]
        let latitude = snapValue["latitude"] as! Double
        let longitude = snapValue["longitude"] as! Double
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        print(latitude)
    }
}