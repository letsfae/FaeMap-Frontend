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

extension FaeMapViewController: MainScreenSearchDelegate, CommentPinDetailDelegate, PinMenuDelegate {
    
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
    
    // CommentPinDetailDelegate
    func dismissMarkerShadow(_ dismiss: Bool) {
        print("back from comment pin detail")
        if dismiss {
            self.markerBackFromCommentDetail.icon = UIImage(named: "comment_pin_marker")
            self.markerBackFromCommentDetail.zIndex = 0
        }
        else {
            self.markerBackFromCommentDetail.map = nil
        }
    }
    
    // CommentPinDetailDelegate
    func animateToCameraFromCommentPinDetailView(_ coordinate: CLLocationCoordinate2D, commentID: Int) {
        print("DEBUG: Delegate pass commentID")
        print(commentID)
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.markerBackFromCommentDetail.icon = UIImage(named: "comment_pin_marker")
        self.markerBackFromCommentDetail.zIndex = 0
        if let marker = self.mapCommentPinsDic[commentID] {
            self.markerBackFromCommentDetail = marker
            marker.icon = UIImage(named: "markerCommentPinHeavyShadow")
            marker.zIndex = 2
            self.commentIDFromOpenedPinCell = -999
        }
        else {
            self.commentIDFromOpenedPinCell = commentID
            let currentZoomLevel = faeMapView.camera.zoom
            let powFactor: Double = Double(21 - currentZoomLevel)
            let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
            self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
            self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
        }
        self.faeMapView.animate(to: camera)
    }
    
    // PinMenuDelegate
    // Back from pin menu view controller
    func sendPinGeoInfo(commentID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 17)
        faeMapView.camera = camera
        animatePinWhenItIsCreated(commentID)
    }
}
