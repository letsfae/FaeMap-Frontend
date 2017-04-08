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
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
        updateTimerForUserPin()
        timerSetup()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    
    // PinDetailDelegate
    func dismissMarkerShadow(_ dismiss: Bool) {
        print("back from comment pin detail")
        updateTimerForUserPin()
        timerSetup()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    func animateToCamera(_ coordinate: CLLocationCoordinate2D, pinID: String) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
    }
    func changeIconImage(marker: GMSMarker, type: String, status: String) {
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
    func disableSelfMarker(yes: Bool) {
        if yes {
            self.subviewSelfMarker.isHidden = true
        } else {
            reloadSelfPosAnimation()
        }
    }
    func reloadMapPins(_ coordinate: CLLocationCoordinate2D, zoom: Float, pinID: String, marker: GMSMarker) {
        let offset = 0.00148 * pow(2, Double(17 - zoom))
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude+offset,
                                          longitude: coordinate.longitude, zoom: zoom)
        faeMapView.camera = camera
        marker.position = coordinate
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
        self.present(moodAvatarVC, animated: true, completion: nil)
    }
    func jumpToCollections() {
        
        let collectionsBoardVC = CollectionsBoardViewController()
 
        collectionsBoardVC.modalPresentationStyle = .overCurrentContext
        self.present(collectionsBoardVC, animated: false, completion: nil)
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
        reloadSelfPosAnimation()
    }
}
