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
        reloadMainScreenButtons()
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
        if userStatus == 5 {
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
//        let vcCollections = CollectionsBoardViewController()
        let vcCollections = CollectionsViewController()
        self.navigationController?.pushViewController(vcCollections, animated: true)
    }
    
    func jumpToContacts() {
        let vcContacts = ContactsViewController()
        self.navigationController?.pushViewController(vcContacts, animated: true)
    }
    
    // LeftSlidingMenuDelegate
    func logOutInLeftMenu() {
        self.jumpToWelcomeView(animated: true)
    }
    
    func jumpToFaeUserMainPage() {
        self.jumpToMyFaeMainPage()
    }
    
    func reloadSelfPosition() {
        self.boolCanOpenPin = true
        self.reloadMainScreenButtons()
    }
    
    func switchMapMode() {
        guard let vc = self.navigationController?.viewControllers.first else { return }
        guard vc is InitialPageController else { return }
        guard let vcRoot = vc as? InitialPageController else { return }
        vcRoot.goToMapBoard()
        LeftSlidingMenuViewController.boolMapBoardIsOn = true
    }
    
    fileprivate func reloadMainScreenButtons() {
        
        btnCompass.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            if self.FILTER_ENABLE {
                self.btnFilterIcon.frame = CGRect(x: screenWidth / 2 - 22, y: screenHeight - 47, width: 44, height: 44)
            }
            self.btnCompass.frame = CGRect(x: 22, y: 582 * screenWidthFactor, width: 59, height: 59)
            self.btnLocateSelf.frame = CGRect(x: 333 * screenWidthFactor, y: 582 * screenWidthFactor, width: 59, height: 59)
            self.btnOpenChat.frame = CGRect(x: 12, y: 646 * screenWidthFactor, width: 79, height: 79)
            self.lblUnreadCount.frame = CGRect(x: 55, y: 1, width: 0, height: 22)
            self.updateUnreadChatIndicator()
            self.btnDiscovery.frame = CGRect(x: 323 * screenWidthFactor, y: 646 * screenWidthFactor, width: 79, height: 79)
            let direction: CGFloat = CGFloat(self.prevBearing)
            let angle: CGFloat = ((360.0 - direction) * .pi / 180.0) as CGFloat
            self.btnCompass.transform = CGAffineTransform(rotationAngle: angle)
        }, completion: nil)
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
