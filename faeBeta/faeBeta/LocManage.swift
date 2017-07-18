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
    
    func jumpToLocationEnable() {
        print("[LocManager] jumpToLocationEnable")
        let vc = EnableLocationViewController()
        UIApplication.shared.keyWindow?.visibleViewController?.present(vc, animated: true, completion: nil)
    }
    
    func updateCurtLoc() {
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locManager.requestAlwaysAuthorization()
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("Not Authorised")
            locManager.requestAlwaysAuthorization()
            break
        case .denied:
            self.jumpToLocationEnable()
            break
        case .restricted:
            print("Not allowed to use location service")
            break
        case .authorizedAlways:
            curtLoc = locManager.location
            break
        case .authorizedWhenInUse:
            break
        }
        
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        print("didChangeAuthorizationStatus ++++")
//        switch status {
//        case .notDetermined:
//            locManager.requestWhenInUseAuthorization()
//            break
//        case .authorizedAlways:
//            //            print(".Authorized")
//            self.dismiss(animated: true, completion: nil)
//            break
//        case .denied:
//            print(".Denied")
//            //            jumpToLocationEnable()
//            break
//        default:
//            print("Unhandled authorization status")
//            break
//            
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager FailWithError] \(error)")
    }
}
