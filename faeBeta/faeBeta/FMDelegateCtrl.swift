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
import RealmSwift
import SwiftyJSON

extension FaeMapViewController: MainScreenSearchDelegate, PinDetailDelegate, PinMenuDelegate, LeftSlidingMenuDelegate {
    
    // MainScreenSearchDelegate
    func animateToCameraFromMainScreenSearch(_ coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: faeMapView.camera.zoom)
        self.faeMapView.animate(to: camera)
        updateTimerForUserPin()
        timerSetup()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    
    // PinDetailDelegate
    func backToMainMap() {
        //        updateTimerForUserPin()
        timerSetup()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
        self.reloadMainScreenButtons()
        resumeAllUserPinTimers()
    }
    func animateToCamera(_ coordinate: CLLocationCoordinate2D, pinID: String) {
        let offset = 0.00148 * pow(2, Double(17 - faeMapView.camera.zoom)) // 0.00148 Los Angeles, 0.00117 Canada
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude + offset,
                                              longitude: coordinate.longitude, zoom: faeMapView.camera.zoom)
        faeMapView.camera = camera
    }
    func changeIconImage() {
        let marker = PinDetailViewController.pinMarker
        let type = "\(PinDetailViewController.pinTypeEnum)"
        let status = PinDetailViewController.pinStatus
        guard let userData = marker.userData as? [Int: AnyObject] else {
            return
        }
        guard let mapPin = userData.values.first as? MapPin else {
            return
        }
        var mapPin_new = mapPin
        mapPin_new.status = status
        marker.userData = [0: mapPin_new]
        marker.icon = pinIconSelector(type: type, status: status)
    }
    func reloadMapPins(_ coordinate: CLLocationCoordinate2D, zoom: Float, pinID: String, marker: GMSMarker) {
        
        marker.map = nil
        marker.position = coordinate
        marker.map = faeMapView
        
        let offset = 530 * screenHeightFactor - screenHeight / 2
        var curPoint = faeMapView.projection.point(for: coordinate)
        curPoint.y -= offset
        let newCoor = faeMapView.projection.coordinate(for: curPoint)
        let camera = GMSCameraPosition.camera(withTarget: newCoor, zoom: zoom, bearing: faeMapView.camera.bearing, viewingAngle: faeMapView.camera.viewingAngle)
        
        faeMapView.camera = camera
    }
    func goTo(nextPin: Bool) {
        var tmpMarkers = [GMSMarker]()
        for marker in placeMarkers {
            if marker.map != nil {
                tmpMarkers.append(marker)
            }
        }
        if let index = tmpMarkers.index(of: PinDetailViewController.pinMarker) {
            var i = index
            if nextPin {
                if index == tmpMarkers.count - 1 {
                    i = 0
                } else {
                    i += 1
                }
            } else {
                if index == 0 {
                    i = tmpMarkers.count - 1
                } else {
                    i -= 1
                }
            }
            PinDetailViewController.pinMarker = tmpMarkers[i]
            if tmpMarkers[i].userData == nil {
                return
            }
            guard let userData = tmpMarkers[i].userData as? [Int: AnyObject] else {
                return
            }
            guard let placePin = userData.values.first as? PlacePin else {
                return
            }
            openPlacePin(marker: tmpMarkers[i], placePin: placePin, animated: false)
        }
    }
    
    // PinMenuDelegate
    func sendPinGeoInfo(pinID: String, type: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Float) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        faeMapView.camera = camera
        animatePinWhenItIsCreated(pinID: pinID, type: type)
        timerSetup()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    func whenDismissPinMenu() {
        timerSetup()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    
    // LeftSlidingMenuDelegate
    func userInvisible(isOn: Bool) {
        if !isOn {
            self.faeMapView.isMyLocationEnabled = false
            self.renewSelfLocation()
            reloadSelfPosAnimation()
            self.subviewSelfMarker.isHidden = false
            return
        }
        if userStatus == 5 {
            self.invisibleMode()
            self.faeMapView.isMyLocationEnabled = true
            self.subviewSelfMarker.isHidden = true
        }
    }
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        self.navigationController?.pushViewController(moodAvatarVC, animated: true)
    }
    func jumpToCollections() {
        let vcCollections = CollectionsBoardViewController()
        self.navigationController?.pushViewController(vcCollections, animated: true)
    }
    func logOutInLeftMenu() {
        self.jumpToWelcomeView(animated: true)
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    func jumpToFaeUserMainPage() {
        self.jumpToMyFaeMainPage()
    }
    func reloadSelfPosition() {
        self.canOpenAnotherPin = true
        self.reloadMainScreenButtons()
        reloadSelfPosAnimation()
    }
    
    fileprivate func reloadMainScreenButtons() {
        
        btnToNorth.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.btnMapFilter.frame = CGRect(x: screenWidth / 2 - 22, y: screenHeight - 47, width: 44, height: 44)
            self.btnToNorth.frame = CGRect(x: 22, y: 582 * screenWidthFactor, width: 59, height: 59)
            self.btnSelfLocation.frame = CGRect(x: 333 * screenWidthFactor, y: 582 * screenWidthFactor, width: 59, height: 59)
            self.btnChatOnMap.frame = CGRect(x: 12, y: 646 * screenWidthFactor, width: 79, height: 79)
            self.labelUnreadMessages.frame = CGRect(x: 55, y: 1, width: 0, height: 22)
            self.updateUnreadChatIndicator()
            self.btnPinOnMap.frame = CGRect(x: 323 * screenWidthFactor, y: 646 * screenWidthFactor, width: 79, height: 79)
            let direction: CGFloat = CGFloat(self.prevBearing)
            let angle: CGFloat = ((360.0 - direction) * .pi / 180.0) as CGFloat
            self.btnToNorth.transform = CGAffineTransform(rotationAngle: angle)
        }, completion: { _ in
            
        })
    }
}
