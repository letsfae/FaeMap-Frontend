//
//  SPLActions.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension SelectLocationViewController {
    
    func actionCancelSelectLocation(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func actionSetLocationForComment(_ sender: UIButton) {
        if let searchText = faeSearchController.faeSearchBar.text {
            let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
            let mapCenterCoordinate = mapSelectLocation.projection.coordinate(for: mapCenter)
            delegate?.sendAddress(searchText)
            delegate?.sendGeoInfo("\(mapCenterCoordinate.latitude)", longitude: "\(mapCenterCoordinate.longitude)", zoom: mapSelectLocation.camera.zoom)
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    func actionSelfPosition(_ sender: UIButton!) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            currentLocation = locManager.location
        }
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: mapSelectLocation.camera.zoom)
        mapSelectLocation.camera = camera
    }
    
    func actionClearSearchBar(_ sender: UIButton) {
        faeSearchController.faeSearchBar.text = nil
        self.placeholder.removeAll()
        searchBarTableHideAnimation()
        self.tblSearchResults.reloadData()
    }
}
