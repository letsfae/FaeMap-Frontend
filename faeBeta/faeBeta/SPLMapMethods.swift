//
//  SPLMapMethods.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit

extension SelectLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = mapView.convert(mapCenter, toCoordinateFrom: nil)
        let location = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
        General.shared.getAddress(location: location) { (address) in
            guard let addr = address as? String else { return }
            DispatchQueue.main.async {
                self.faeSearchController.faeSearchBar.text = addr
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        guard faeSearchController != nil else { return }
        guard faeSearchController.faeSearchBar != nil else { return }
        faeSearchController.faeSearchBar.endEditing(true)
    }
}
