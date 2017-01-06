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

extension FaeMapViewController: MainScreenSearchDelegate, PinDetailDelegate, PinMenuDelegate, LeftSlidingMenuDelegate {
    
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
    func animateToCamera(_ coordinate: CLLocationCoordinate2D, pinID: String) {
        print("DEBUG: Delegate pass pinID")
        print(pinID)
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
//        self.markerBackFromPinDetail.icon = UIImage(named: "commentPinMarker")
//        self.markerBackFromPinDetail.zIndex = 0
//        if let marker = self.mapPinsDic[pinID] {
////            self.markerBackFromPinDetail = marker
////            marker.icon = UIImage(named: "markerCommentPinHeavyShadow")
//            marker.zIndex = 2
//            self.pinIDFromOpenedPinCell = -999
//        }
//        else {
//            self.pinIDFromOpenedPinCell = pinID
//            let currentZoomLevel = faeMapView.camera.zoom
//            let powFactor: Double = Double(21 - currentZoomLevel)
//            let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
//            self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
//            self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
//        }
        self.faeMapView.animate(to: camera)
    }
    // PinDetailDelegate
    func animateToSelectedMarker(coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
    }
    // PinDetailDelegate
    func openPinDetailView(withType: String, pinID: String, coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
        timerUpdateSelfLocation.invalidate()
        self.clearMap(type: "user")
        if withType == "media" {
            let pinDetailVC = MomentPinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.pinIdSentBySegue = "\(pinID)"
            pinDetailVC.selectedMarkerPosition = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            pinDetailVC.delegate = self
            pinDetailVC.animated = false
            self.present(pinDetailVC, animated: false, completion: {
                self.canOpenAnotherPin = true
            })
        }
        else if withType == "comment" {
            let pinDetailVC = CommentPinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.pinIdSentBySegue = "\(pinID)"
            pinDetailVC.selectedMarkerPosition = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            pinDetailVC.delegate = self
            pinDetailVC.animated = false
            self.present(pinDetailVC, animated: false, completion: {
                self.canOpenAnotherPin = true
            })
        }
    }

    // PinMenuDelegate
    func sendPinGeoInfo(pinID: String, type: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 17)
        faeMapView.camera = camera
        animatePinWhenItIsCreated(pinID: pinID, type: type)
        let currentZoomLevel = faeMapView.camera.zoom
        let powFactor: Double = Double(21 - currentZoomLevel)
        let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
        self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
        self.renewSelfLocation()
    }
    // PinMenuDelegate
    func whenDismissPinMenu() {
        let currentZoomLevel = faeMapView.camera.zoom
        let powFactor: Double = Double(21 - currentZoomLevel)
        let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
        self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
        self.renewSelfLocation()
    }
    
    // LeftSlidingMenuDelegate
    func userInvisible(isOn: Bool) {
        if !isOn {
            self.faeMapView.isMyLocationEnabled = false
            self.renewSelfLocation()
            if userStatus != 5  {
                loadPositionAnimateImage()
                getSelfAccountInfo()
            }
            return
        }
        if userStatus == 5 {
            self.invisibleMode()
            self.faeMapView.isMyLocationEnabled = true
            if self.myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.isHidden = true
            }
            if self.myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.isHidden = true
            }
            if self.myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.isHidden = true
            }
            if self.myPositionIcon != nil {
                self.myPositionIcon.isHidden = true
            }
        }
    }
    // LeftSlidingMenuDelegate
    func jumpToMoodAvatar() {
        let moodAvatarVC = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "MoodAvatarViewController") as! MoodAvatarViewController
        moodAvatarVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(moodAvatarVC, animated: true)
    }
    // LeftSlidingMenuDelegate
    func logOutInLeftMenu() {
        self.jumpToWelcomeView(animated: true)
    }
    // LeftSlidingMenuDelegate
    func jumpToFaeUserMainPage() {
        self.jumpToMyFaeMainPage()
    }
}
