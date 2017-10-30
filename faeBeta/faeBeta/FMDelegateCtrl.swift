//
//  FMDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension FaeMapViewController: LeftSlidingMenuDelegate, ButtonFinishClickedDelegate {
    
    // PinDetailDelegate
    func backToMainMap() {
        timerSetup()
        renewSelfLocation()
        resetCompassRotation()
        deselectAllAnnotations()
    }
    func animateToCamera(_ coordinate: CLLocationCoordinate2D) {
        // animate to place pin coordinate
        animateToCoordinate(type: 2, coordinate: coordinate, animated: false)
    }
    func changeIconImage() {
        /*
        let annotation = PinDetailViewController.pinAnnotation
        _ = "\(PinDetailViewController.pinTypeEnum)"
        let status = PinDetailViewController.pinStatus
        let mapPin = annotation?.pinInfo as! MapPin
        var mapPin_new = mapPin
        mapPin_new.status = status
        annotation?.pinInfo = mapPin_new as AnyObject
         */
    }
    func reloadMapPins(_ coordinate: CLLocationCoordinate2D, pinID: String, annotation: FaePinAnnotation) {
        /*
        placeClusterManager.removeAnnotations([annotation]) {
            self.placeClusterManager.addAnnotations([annotation], withCompletionHandler: nil)
        }
        
        let offset = 530 * screenHeightFactor - screenHeight / 2
        var curPoint = faeMapView.convert(coordinate, toPointTo: nil)
        curPoint.y -= offset
        let newCoor = faeMapView.convert(curPoint, toCoordinateFrom: nil)
        let camera = faeMapView.camera
        camera.centerCoordinate = newCoor
        faeMapView.setCamera(camera, animated: false)
         */
    }
    
    /*
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
    }
    func whenDismissPinMenu() {
        timerSetup()
        renewSelfLocation()
        // send noti here to start filter spinning and arrow
    }
    */
    
    // LeftSlidingMenuDelegate
    func userInvisible(isOn: Bool) {
        if !isOn {
            renewSelfLocation()
            return
        }
        if Key.shared.userStatus == 5 {
            invisibleMode()
        } else {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "userAvatarAnimationRestart"), object: nil)
        }
    }
    
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        self.navigationController?.pushViewController(moodAvatarVC, animated: true)
    }
    
    func jumpToCollections() {
        let vcCollections = CollectionsViewController()
        vcCollections.faeMapCtrler = self
        self.navigationController?.pushViewController(vcCollections, animated: true)
    }
    
    func jumpToContacts() {
        let vcContacts = ContactsViewController()
        self.navigationController?.pushViewController(vcContacts, animated: true)
    }
    
    // LeftSlidingMenuDelegate
    func jumpToSettings() {
        let vcSettings = SettingsViewController()
        navigationController?.pushViewController(vcSettings, animated: true)
    }
    
    func jumpToFaeUserMainPage() {
        self.jumpToMyFaeMainPage()
    }
    
    func reloadSelfPosition() {
        self.boolCanOpenPin = true
        self.resetCompassRotation()
    }
    
    func switchMapMode() {
        guard let vc = self.navigationController?.viewControllers.first else { return }
        guard vc is InitialPageController else { return }
        guard let vcRoot = vc as? InitialPageController else { return }
        vcRoot.goToMapBoard()
        LeftSlidingMenuViewController.boolMapBoardIsOn = true
    }
    
    func resetCompassRotation() {
//        btnCompass.transform = btnCompass.savedTransform
        updateUnreadChatIndicator()
    }
    
    // ButtonFinishClickedDelegate
    func jumpToEnableNotification() {
        print("jumpToEnableNotification")
        let notificationType = UIApplication.shared.currentUserNotificationSettings
        if notificationType?.types == UIUserNotificationType() {
            let vc = EnableNotificationViewController()
            //            UIApplication.shared.keyWindow?.visibleViewController?
            present(vc, animated: true)
        }
    }
    // ButtonFinishClickedDelegate End
}
