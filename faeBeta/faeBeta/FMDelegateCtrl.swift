//
//  FMDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift
import SwiftyJSON

extension FaeMapViewController: MainScreenSearchDelegate, PinDetailDelegate, PinMenuDelegate, LeftSlidingMenuDelegate {
    
    // MainScreenSearchDelegate
    func animateToCameraFromMainScreenSearch(_ coordinate: CLLocationCoordinate2D) {
        let camera = faeMapView.camera
        camera.centerCoordinate = coordinate
        faeMapView.setCamera(camera, animated: true)
        updateTimerForUserPin()
        timerSetup()
        // send noti here to start filter spinning
        reloadSelfPosAnimation()
    }
    
    // PinDetailDelegate
    func backToMainMap() {
        //        updateTimerForUserPin()
        timerSetup()
        renewSelfLocation()
        // send noti here to start filter spinning and arrow
        reloadSelfPosAnimation()
        self.reloadMainScreenButtons()
        deselectAllAnnotations()
    }
    func animateToCamera(_ coordinate: CLLocationCoordinate2D) {
        // animate to place pin coordinate
        animateToCoordinate(type: 2, coordinate: coordinate, animated: false)
    }
    func changeIconImage() {
        let annotation = PinDetailViewController.pinAnnotation
        _ = "\(PinDetailViewController.pinTypeEnum)"
        let status = PinDetailViewController.pinStatus
        let mapPin = annotation?.pinInfo as! MapPin
        var mapPin_new = mapPin
        mapPin_new.status = status
        annotation?.pinInfo = mapPin_new as AnyObject
    }
    func reloadMapPins(_ coordinate: CLLocationCoordinate2D, pinID: String, annotation: FaePinAnnotation) {
        
        mapClusterManager.removeAnnotations([annotation]) {
            self.mapClusterManager.addAnnotations([annotation], withCompletionHandler: nil)
        }
        
        let offset = 530 * screenHeightFactor - screenHeight / 2
        var curPoint = faeMapView.convert(coordinate, toPointTo: nil)
        curPoint.y -= offset
        let newCoor = faeMapView.convert(curPoint, toCoordinateFrom: nil)
        let camera = faeMapView.camera
        camera.centerCoordinate = newCoor
        faeMapView.setCamera(camera, animated: false)
    }
    func goTo(nextPin: Bool) {
        /*
        var tmpMarkers = [GMSMarker]()
        for marker in placeMarkers {
            if marker.map != nil {
                tmpMarkers.append(marker)
            }
        }
        if let index = tmpMarkers.index(of: PinDetailViewController.pinAnnotation) {
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
            PinDetailViewController.pinAnnotation = tmpMarkers[i]
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
        */
    }
    
    // PinMenuDelegate
    func sendPinGeoInfo(pinID: String, type: String) {
        let camera = faeMapView.camera
        camera.centerCoordinate = Key.shared.selectedLoc
        camera.altitude = Key.shared.dblAltitude
        faeMapView.setCamera(camera, animated: false)
        animatePinWhenItIsCreated(pinID: pinID, type: type)
        timerSetup()
        renewSelfLocation()
        // send noti here to start filter spinning and arrow
        reloadSelfPosAnimation()
    }
    func whenDismissPinMenu() {
        timerSetup()
        renewSelfLocation()
        // send noti here to start filter spinning and arrow
        reloadSelfPosAnimation()
    }
    
    // LeftSlidingMenuDelegate
    func userInvisible(isOn: Bool) {
        if !isOn {
            self.renewSelfLocation()
            reloadSelfPosAnimation()
            return
        }
        if userStatus == 5 {
            self.invisibleMode()
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
    
    func jumpToContacts() {
        let vcContacts = ContactsViewController()
        self.navigationController?.pushViewController(vcContacts, animated: true)
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
        self.boolCanOpenPin = true
        self.reloadMainScreenButtons()
        reloadSelfPosAnimation()
    }
    
    func switchMapMode() {
        if let vc = self.navigationController?.viewControllers.first {
            if vc is InitialPageController {
                if let vcRoot = vc as? InitialPageController {
                    vcRoot.goToMapBoard()
                    LeftSlidingMenuViewController.boolMapBoardIsOn = true
                }
            }
        }
    }
    
    fileprivate func reloadMainScreenButtons() {
        
        btnCompass.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            if self.FILTER_ENABLE {
                self.btnFilterIcon.frame = CGRect(x: screenWidth / 2 - 22, y: screenHeight - 47, width: 44, height: 44)
            }
            self.btnCompass.frame = CGRect(x: 22, y: 582 * screenWidthFactor, width: 59, height: 59)
            self.btnSelfCenter.frame = CGRect(x: 333 * screenWidthFactor, y: 582 * screenWidthFactor, width: 59, height: 59)
            self.btnOpenChat.frame = CGRect(x: 12, y: 646 * screenWidthFactor, width: 79, height: 79)
            self.lblUnreadCount.frame = CGRect(x: 55, y: 1, width: 0, height: 22)
            self.updateUnreadChatIndicator()
            self.btnDiscovery.frame = CGRect(x: 323 * screenWidthFactor, y: 646 * screenWidthFactor, width: 79, height: 79)
            let direction: CGFloat = CGFloat(self.prevBearing)
            let angle: CGFloat = ((360.0 - direction) * .pi / 180.0) as CGFloat
            self.btnCompass.transform = CGAffineTransform(rotationAngle: angle)
        }, completion: { _ in
            
        })
    }
}
