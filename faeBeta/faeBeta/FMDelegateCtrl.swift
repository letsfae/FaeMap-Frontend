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
        updateTimerForAllPins()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    
    // PinDetailDelegate
    func dismissMarkerShadow(_ dismiss: Bool) {
        print("back from comment pin detail")
        updateTimerForAllPins()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    // PinDetailDelegate
    func animateToCamera(_ coordinate: CLLocationCoordinate2D, pinID: String) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
    }
    // PinDetailDelegate
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
    // PinDetailDelegate
    func disableSelfMarker(yes: Bool) {
        if yes {
//            self.selfMarker.map = nil
            self.subviewSelfMarker.isHidden = true
        } else {
            reloadSelfPosAnimation()
        }
    }

    // PinMenuDelegate
    func sendPinGeoInfo(pinID: String, type: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 17)
        faeMapView.camera = camera
        animatePinWhenItIsCreated(pinID: pinID, type: type)
        updateTimerForAllPins()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    // PinMenuDelegate
    func whenDismissPinMenu() {
        updateTimerForAllPins()
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
    // LeftSlidingMenuDelegate
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        self.present(moodAvatarVC, animated: true, completion: nil)
    }
    
    
    // LeftSlidingMenuDelegate
    func jumpToCollections() {
        
        let CollectionsBoardVC = CollectionsBoardViewController()
        
        //弹出的动画效果
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
 
        //        CollectionsBoardVC.modalPresentationStyle = .overCurrentContext
        self.present(CollectionsBoardVC, animated: false, completion: nil)
        

    
    }
    
    // LeftSlidingMenuDelegate
    func logOutInLeftMenu() {
        self.jumpToWelcomeView(animated: true)
    }
    // LeftSlidingMenuDelegate
    func jumpToFaeUserMainPage() {
        self.jumpToMyFaeMainPage()
    }
    // LeftSlidingMenuDelegate
    func reloadSelfPosition() {
        reloadSelfPosAnimation()
    }
}
