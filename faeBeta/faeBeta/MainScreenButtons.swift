//
//  MainScreenButtons.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController: CreatePinViewControllerDelegate {
    // MARK: -- Load Map Main Screen Buttons
    func loadButton() {
        // Left window on main map to open account system
        buttonLeftTop = UIButton()
        buttonLeftTop.setImage(UIImage(named: "leftTopButton"), forState: .Normal)
        self.view.addSubview(buttonLeftTop)
        buttonLeftTop.addTarget(self, action: #selector(FaeMapViewController.animationMoreShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:|-15-[v0(30)]", options: [], views: buttonLeftTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonLeftTop)
        buttonLeftTop.layer.zPosition = 500
        
        // Open main map search
        buttonMainScreenSearch = UIButton()
        buttonMainScreenSearch.setImage(UIImage(named: "middleTopButton"), forState: .Normal)
        self.view.addSubview(buttonMainScreenSearch)
        buttonMainScreenSearch.addTarget(self, action: #selector(FaeMapViewController.jumpToMainScreenSearch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(29)]", options: [], views: buttonMainScreenSearch)
        self.view.addConstraintsWithFormat("V:|-24-[v0(32)]", options: [], views: buttonMainScreenSearch)
        NSLayoutConstraint(item: buttonMainScreenSearch, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        buttonMainScreenSearch.layer.zPosition = 500
        
        /* This is not for 11.01 Dev Version
        // Wind bell
        buttonRightTop = UIButton()
        buttonRightTop.setImage(UIImage(named: "rightTopButton"), forState: .Normal)
        self.view.addSubview(buttonRightTop)
        buttonRightTop.addTarget(self, action: #selector(FaeMapViewController.animationWindBellShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(26)]-16-|", options: [], views: buttonRightTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonRightTop)
        */
        
        // Click to back to north
        buttonToNorth = UIButton()
        view.addSubview(buttonToNorth)
        buttonToNorth.setImage(UIImage(named: "compass_new"), forState: .Normal)
        buttonToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addConstraintsWithFormat("H:|-22-[v0(59)]", options: [], views: buttonToNorth)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonToNorth)
        buttonToNorth.layer.zPosition = 500
        
        // Click to locate the current location
        buttonSelfPosition = UIButton()
        view.addSubview(buttonSelfPosition)
        buttonSelfPosition.setImage(UIImage(named: "self_position"), forState: .Normal)
        buttonSelfPosition.addTarget(self, action: #selector(FaeMapViewController.actionSelfPosition(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: buttonSelfPosition)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonSelfPosition)
        buttonSelfPosition.layer.zPosition = 500
        
        // Open chat view
        buttonChatOnMap = UIButton()
        buttonChatOnMap.setImage(UIImage(named: "chat_map"), forState: .Normal)
        buttonChatOnMap.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonChatOnMap)
        view.addConstraintsWithFormat("H:|-12-[v0(79)]", options: [], views: buttonChatOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonChatOnMap)
        buttonChatOnMap.layer.zPosition = 500
        
        // Show the number of unread messages on main map
        labelUnreadMessages = UILabel(frame: CGRectMake(55, 1, 25, 22))
        labelUnreadMessages.backgroundColor = UIColor.init(red: 102/255, green: 192/255, blue: 251/255, alpha: 1)
        labelUnreadMessages.layer.cornerRadius = 11
        labelUnreadMessages.layer.masksToBounds = true
        labelUnreadMessages.layer.opacity = 0.9
        labelUnreadMessages.text = "1"
        labelUnreadMessages.textAlignment = .Center
        labelUnreadMessages.textColor = UIColor.whiteColor()
        labelUnreadMessages.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        buttonChatOnMap.addSubview(labelUnreadMessages)
        
        // Create pin on main map
        buttonPinOnMap = UIButton(frame: CGRectMake(323, 646, 79, 79))
        buttonPinOnMap.setImage(UIImage(named: "set_pin_on_map"), forState: .Normal)
        view.addSubview(buttonPinOnMap)
        buttonPinOnMap.addTarget(self, action: #selector(FaeMapViewController.actionCreatePin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addConstraintsWithFormat("H:[v0(79)]-12-|", options: [], views: buttonPinOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonPinOnMap)
        buttonPinOnMap.layer.zPosition = 500
    }
    
    //MARK: Actions for these buttons
    func actionSelfPosition(sender: UIButton!) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            currentLocation = locManager.location
        }
        if currentLocation != nil {
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
            faeMapView.camera = camera
            if userStatus != 5  {
                loadPositionAnimateImage()
                getSelfAccountInfo()
            }
        }
    }
    
    func actionTrueNorth(sender: UIButton!) {
        faeMapView.animateToBearing(0)
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        originPointForRefresh = mapCenterCoordinate
        updateSelfLocation()
    }
    
    // Jump to create pin view controller
    func actionCreatePin(sender: UIButton!) {
        let createPinVC = CreatePinViewController()
        createPinVC.modalPresentationStyle = .OverCurrentContext
        createPinVC.currentLatitude = self.currentLatitude
        createPinVC.currentLongitude = self.currentLongitude
        createPinVC.delegate = self
        self.presentViewController(createPinVC, animated: false, completion: nil)
    }
    
    // Back from create pin view controller
    func sendCommentGeoInfo(commentID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 17)
        faeMapView.camera = camera
        animatePinWhenItIsCreated(commentID)
    }
    
    // Animation for pin logo
    func animatePinWhenItIsCreated(commentID: String) {
        tempMarker = UIImageView(frame: CGRectMake(0, 0, 167, 178))
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2-25.5)
        tempMarker.center = mapCenter
        tempMarker.image = UIImage(named: "commentMarkerWhenCreated")
        self.view.addSubview(tempMarker)
        markerMask = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        self.view.addSubview(markerMask)
        UIView.animateWithDuration(0.783, delay: 0.15, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.tempMarker.frame.size.width = 48
            self.tempMarker.frame.size.height = 51
            self.tempMarker.center = mapCenter
            }, completion: { (done: Bool) in
                if done {
                    self.loadMarkerWithCommentID(commentID, tempMaker: self.tempMarker)
                }
        })
    }
    
    func removeTempMarker() {
        tempMarker.removeFromSuperview()
        markerMask.removeFromSuperview()
    }
    
    func loadMarkerWithCommentID(commentID: String, tempMaker: UIImageView) {
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "200")
        loadPinsByZoomLevel.whereKey("type", value: "comment")
        loadPinsByZoomLevel.getMapInformation{(status:Int, message:AnyObject?) in
            let mapInfoJSON = JSON(message!)
            if mapInfoJSON.count > 0 {
                for i in 0...(mapInfoJSON.count-1) {
                    let pinShowOnMap = GMSMarker()
                    pinShowOnMap.zIndex = 1
                    var pinData = [String: AnyObject]()
                    if let commentIDInfo = mapInfoJSON[i]["comment_id"].int {
                        if commentID != "\(commentIDInfo)" {
                            continue
                        }
                        pinData["comment_id"] = commentIDInfo
                    }
                    if let typeInfo = mapInfoJSON[i]["type"].string {
                        pinData["type"] = typeInfo
                        if typeInfo == "comment" {
                            pinShowOnMap.icon = UIImage(named: "comment_pin_marker")
                            pinShowOnMap.zIndex = 0
                        }
                    }
                    if let userIDInfo = mapInfoJSON[i]["user_id"].int {
                        pinData["user_id"] = userIDInfo
                    }
                    if let createdTimeInfo = mapInfoJSON[i]["created_at"].string {
                        pinData["created_at"] = createdTimeInfo
                    }
                    if let contentInfo = mapInfoJSON[i]["content"].string {
                        pinData["content"] = contentInfo
                    }
                    if let latitudeInfo = mapInfoJSON[i]["geolocation"]["latitude"].double {
                        pinData["latitude"] = latitudeInfo
                        pinShowOnMap.position.latitude = latitudeInfo
                    }
                    if let longitudeInfo = mapInfoJSON[i]["geolocation"]["longitude"].double {
                        pinData["longitude"] = longitudeInfo
                        pinShowOnMap.position.longitude = longitudeInfo
                    }
                    if let isLiked = mapInfoJSON[i]["user_pin_operations"]["is_liked"].bool {
                        pinData["is_liked"] = isLiked
                    }
                    if let likedTimestamp = mapInfoJSON[i]["user_pin_operations"]["liked_timestamp"].string {
                        pinData["liked_timestamp"] = likedTimestamp
                    }
                    if let isSaved = mapInfoJSON[i]["user_pin_operations"]["is_saved"].bool {
                        pinData["is_saved"] = isSaved
                    }
                    if let savedTimestamp = mapInfoJSON[i]["user_pin_operations"]["saved_timestamp"].string {
                        pinData["saved_timestamp"] = savedTimestamp
                    }
                    
                    pinShowOnMap.userData = pinData
                    pinShowOnMap.appearAnimation = kGMSMarkerAnimationNone
                    pinShowOnMap.map = self.faeMapView
                    NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.removeTempMarker), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    func jumpToMainScreenSearch(sender: UIButton) {
        let mainScreenSearchVC = MainScreenSearchViewController()
        mainScreenSearchVC.modalPresentationStyle = .OverCurrentContext
        mainScreenSearchVC.delegate = self
        self.presentViewController(mainScreenSearchVC, animated: false, completion: nil)
    }
}
