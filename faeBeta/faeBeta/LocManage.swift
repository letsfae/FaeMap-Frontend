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
        if curtLoc != nil {
            return curtLoc.coordinate.latitude
        }
        return 34.0205378
    }
    
    var curtLong: CLLocationDegrees {
        if curtLoc != nil {
            return curtLoc.coordinate.longitude
        }
        return -118.2854081
    }
    
    func jumpToLocationEnable() {
        print("[LocManager] jumpToLocationEnable")
        let vc = EnableLocationViewController()
        UIApplication.shared.keyWindow?.visibleViewController?.present(vc, animated: true, completion: nil)
    }
    
    func updateCurtLoc() {
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if CLLocationManager.locationServicesEnabled() {
            locManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        curtLoc = locManager.location
//        print("curtLoc \(curtLoc)")
//        print("curtLat \(curtLat)")
//        print("curtLon \(curtLong)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
//            print("didChangeAuthorizationStatus .notDetermined")
            locManager.requestAlwaysAuthorization()
            break
        case .denied:
//            print("didChangeAuthorizationStatus .denied")
            self.jumpToLocationEnable()
            break
        case .restricted:
//            print("didChangeAuthorizationStatus .restricted")
            break
        case .authorizedAlways:
//            print("didChangeAuthorizationStatus .authorizedAlways")
            break
        case .authorizedWhenInUse:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager FailWithError] \(error)")
    }
}
