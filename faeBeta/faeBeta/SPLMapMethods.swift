//
//  SPLMapMethods.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

extension SelectLocationViewController: MKMapViewDelegate {
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        let camera = mapView.camera
        camera.altitude = Key.shared.dblAltitude
        camera.centerCoordinate = Key.shared.selectedLoc
        mapView.setCamera(camera, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = mapView.convert(mapCenter, toCoordinateFrom: nil)
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        faeSearchController.faeSearchBar.endEditing(true)
    }
}
