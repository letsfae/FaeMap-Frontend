//
//  LocManage.swift
//  faeBeta
//
//  Created by Yue on 7/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

class LocManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocManager()

    var locManager: CLLocationManager!
    var curtLoc = CLLocation(latitude: 34.020554, longitude: -118.285447)
    var curtLat: CLLocationDegrees {
        return curtLoc.coordinate.latitude
    }
    var curtLong: CLLocationDegrees {
        return curtLoc.coordinate.longitude
    }
    var boolFirstLoad = true
    
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
        guard let location = manager.location else { return }
        curtLoc = location
        guard boolFirstLoad else { return }
        boolFirstLoad = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
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
