//
//  FMDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

extension FaeMapViewController: MainScreenSearchDelegate, PinDetailDelegate, PinMenuDelegate {
    
    // MainScreenSearchDelegate
    func animateToCameraFromMainScreenSearch(_ coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
        let currentZoomLevel = faeMapView.camera.zoom
        let powFactor: Double = Double(21 - currentZoomLevel)
        let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
        self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
        self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
    }
    
    // PinDetailDelegate
    func dismissMarkerShadow(_ dismiss: Bool) {
        print("back from comment pin detail")
        let currentZoomLevel = faeMapView.camera.zoom
        let powFactor: Double = Double(21 - currentZoomLevel)
        let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
        self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
        self.renewSelfLocation()
        if dismiss {
//            self.markerBackFromPinDetail.icon = UIImage(named: "commentPinMarker")
//            self.markerBackFromPinDetail.zIndex = 0
        }
        else {
            self.markerBackFromPinDetail.map = nil
        }
    }
    
    // PinDetailDelegate
    func animateToCamera(_ coordinate: CLLocationCoordinate2D, pinID: Int) {
        print("DEBUG: Delegate pass pinID")
        print(pinID)
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
//        self.markerBackFromPinDetail.icon = UIImage(named: "commentPinMarker")
//        self.markerBackFromPinDetail.zIndex = 0
        if let marker = self.mapPinsDic[pinID] {
//            self.markerBackFromPinDetail = marker
//            marker.icon = UIImage(named: "markerCommentPinHeavyShadow")
            marker.zIndex = 2
            self.pinIDFromOpenedPinCell = -999
        }
        else {
            self.pinIDFromOpenedPinCell = pinID
            let currentZoomLevel = faeMapView.camera.zoom
            let powFactor: Double = Double(21 - currentZoomLevel)
            let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
            self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
            self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
        }
        self.faeMapView.animate(to: camera)
    }
    // PinDetailDelegate
    func animateToSelectedMarker(coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
    }
    
    // PinMenuDelegate
    // Back from pin menu view controller
    func sendPinGeoInfo(pinID: String, type: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 17)
        faeMapView.camera = camera
        animatePinWhenItIsCreated(pinID: pinID, type: type)
    }
}
