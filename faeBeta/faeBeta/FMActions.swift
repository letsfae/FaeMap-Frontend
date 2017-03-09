//
//  FMActions.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension FaeMapViewController {
    
    func renewSelfLocation() {
        if currentLocation != nil {
            let selfLocation = FaeMap()
            selfLocation.whereKey("geo_latitude", value: "\(currentLatitude)")
            selfLocation.whereKey("geo_longitude", value: "\(currentLongitude)")
            selfLocation.renewCoordinate {(status: Int, message: Any?) in
                if status/100 == 2 {
                    print("Successfully renew self position")
                }
                else {
                    print("fail to renew self position")
                }
            }
        }
    }
    
    func actionTrueNorth(_ sender: UIButton!) {
        self.faeMapView.animate(toBearing: 0)
    }
    
    // Jump to pin menu view controller
    func actionCreatePin(_ sender: UIButton!) {
        invalidateAllTimer()
        faeMapView.clear()
        let pinMenuVC = PinMenuViewController()
        pinMenuVC.modalPresentationStyle = .overCurrentContext
        pinMenuVC.currentLatitude = self.currentLatitude
        pinMenuVC.currentLongitude = self.currentLongitude
        pinMenuVC.delegate = self
        self.present(pinMenuVC, animated: false, completion: nil)
    }
    
    // MARK: Actions for these buttons
    func actionSelfPosition(_ sender: UIButton!) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
            currentLocation = locManager.location
        }
        if currentLocation != nil {
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            self.renewSelfLocation()
            // let curZoomLevel = faeMapView.camera.zoom
            let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 15)
            faeMapView.camera = camera
            reloadSelfPosAnimation()
        }
    }
}
