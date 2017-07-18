//
//  LocManage.swift
//  faeBeta
//
//  Created by Yue on 7/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

class LocManage: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocManage()
    var curtLoc: CLLocation!
    var locManager: CLLocationManager!
    
    var curtLat: CLLocationDegrees {
        return curtLoc.coordinate.latitude
    }
    
    var curtLong: CLLocationDegrees {
        return curtLoc.coordinate.longitude
    }
    
    func updateCurtLoc() {
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        curtLoc = locManager.location
        print("curtLoc \(curtLoc)")
        print("curtLat \(curtLat)")
        print("curtLon \(curtLong)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager FailWithError] \(error)")
    }
}
