//
//  SPLMapMethods.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension SelectLocationViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = mapView.projection.coordinate(for: mapCenter)
        GMSGeocoder().reverseGeocodeCoordinate(mapCenterCoordinate, completionHandler: {
            (response, error) -> Void in
            if let fullAddress = response?.firstResult()?.lines {
                var addressToSearchBar = ""
                for line in fullAddress {
                    if line == "" {
                        continue
                    }
                    else if fullAddress.index(of: line) == fullAddress.count-1 {
                        addressToSearchBar += line + ""
                    }
                    else {
                        addressToSearchBar += line + ", "
                    }
                }
                self.faeSearchController.faeSearchBar.text = addressToSearchBar
            }
            self.latitudeForPin = mapCenterCoordinate.latitude
            self.longitudeForPin = mapCenterCoordinate.longitude
        })
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        faeSearchController.faeSearchBar.endEditing(true)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        faeSearchController.faeSearchBar.endEditing(true)
    }
}
