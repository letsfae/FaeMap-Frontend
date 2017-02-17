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

extension FaeMapViewController {
    
    // MARK: -- Load Map
    func loadMapView() {
        let kMapStyle = "[{\"featureType\": \"poi.business\",\"stylers\": [{ \"visibility\": \"off\" }]}]"
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
        self.faeMapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        faeMapView.delegate = self
        faeMapView.preferredFrameRate = kGMSFrameRateMaximum
        faeMapView.isIndoorEnabled = false
        faeMapView.isBuildingsEnabled = false
        faeMapView.settings.tiltGestures = false

        self.view = faeMapView
        do {
            // Set the map style by passing a valid JSON string.
            faeMapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
        }

        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        
        // Default is true, if true, panGesture could not be detected
        self.faeMapView.settings.consumesGesturesInView = false
    }
    
    // MARK: -- Load Map Main Screen Buttons
    func loadButton() {
        // Left window on main map to open account system
        buttonLeftTop = UIButton()
        buttonLeftTop.setImage(UIImage(named: "mainScreenMore"), for: UIControlState())
        self.view.addSubview(buttonLeftTop)
        buttonLeftTop.addTarget(self, action: #selector(self.animationMoreShow(_:)), for: UIControlEvents.touchUpInside)
        self.view.addConstraintsWithFormat("H:|-15-[v0(30)]", options: [], views: buttonLeftTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonLeftTop)
        buttonLeftTop.layer.zPosition = 500
        
        // Open main map search
        buttonMainScreenSearch = UIButton()
        buttonMainScreenSearch.setImage(UIImage(named: "mainScreenFaeLogo"), for: UIControlState())
        self.view.addSubview(buttonMainScreenSearch)
        buttonMainScreenSearch.addTarget(self, action: #selector(FaeMapViewController.jumpToMainScreenSearch(_:)), for: UIControlEvents.touchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(33)]", options: [], views: buttonMainScreenSearch)
        self.view.addConstraintsWithFormat("V:|-22-[v0(36)]", options: [], views: buttonMainScreenSearch)
        NSLayoutConstraint(item: buttonMainScreenSearch, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        buttonMainScreenSearch.layer.zPosition = 500
        
        // Wind bell
        buttonRightTop = UIButton()
        buttonRightTop.setImage(UIImage(named: "mainScreenWindBell"), for: UIControlState())
        self.view.addSubview(buttonRightTop)
        buttonRightTop.addTarget(self, action: #selector(self.animationWindBellShow(_:)), for: UIControlEvents.touchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(26)]-16-|", options: [], views: buttonRightTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonRightTop)
        
        // Click to back to north
        buttonToNorth = UIButton()
        view.addSubview(buttonToNorth)
        buttonToNorth.setImage(UIImage(named: "mainScreenNorth"), for: UIControlState())
        buttonToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), for: UIControlEvents.touchUpInside)
        view.addConstraintsWithFormat("H:|-22-[v0(59)]", options: [], views: buttonToNorth)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonToNorth)
        buttonToNorth.layer.zPosition = 500
        
        // Click to locate the current location
        buttonSelfPosition = UIButton()
        view.addSubview(buttonSelfPosition)
        buttonSelfPosition.setImage(UIImage(named: "mainScreenSelfPosition"), for: UIControlState())
        buttonSelfPosition.addTarget(self, action: #selector(FaeMapViewController.actionSelfPosition(_:)), for: UIControlEvents.touchUpInside)
        view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: buttonSelfPosition)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonSelfPosition)
        buttonSelfPosition.layer.zPosition = 500
        
        // Open chat view
        buttonChatOnMap = UIButton()
        buttonChatOnMap.setImage(UIImage(named: "mainScreenNoChat"), for: UIControlState())
        buttonChatOnMap.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(buttonChatOnMap)
        view.addConstraintsWithFormat("H:|-12-[v0(79)]", options: [], views: buttonChatOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonChatOnMap)
        buttonChatOnMap.layer.zPosition = 500
        
        // Show the number of unread messages on main map
        labelUnreadMessages = UILabel(frame: CGRect(x: 55, y: 1, width: 25, height: 22))
        labelUnreadMessages.backgroundColor = UIColor.init(red: 102/255, green: 192/255, blue: 251/255, alpha: 1)
        labelUnreadMessages.layer.cornerRadius = 11
        labelUnreadMessages.layer.masksToBounds = true
        labelUnreadMessages.layer.opacity = 0.9
        labelUnreadMessages.text = "1"
        labelUnreadMessages.textAlignment = .center
        labelUnreadMessages.textColor = UIColor.white
        labelUnreadMessages.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        buttonChatOnMap.addSubview(labelUnreadMessages)
        
        // Create pin on main map
        buttonPinOnMap = UIButton(frame: CGRect(x: 323, y: 646, width: 79, height: 79))
        buttonPinOnMap.setImage(UIImage(named: "mainScreenPinMap"), for: UIControlState())
        view.addSubview(buttonPinOnMap)
        buttonPinOnMap.addTarget(self, action: #selector(FaeMapViewController.actionCreatePin(_:)), for: UIControlEvents.touchUpInside)
        view.addConstraintsWithFormat("H:[v0(79)]-12-|", options: [], views: buttonPinOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonPinOnMap)
        buttonPinOnMap.layer.zPosition = 500
    }
    
    // Animation for pin logo
    func animatePinWhenItIsCreated(pinID: String, type: String) {
        tempMarker = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 128))
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2-25.5)
        tempMarker.center = mapCenter
        if type == "comment" {
            tempMarker.image = UIImage(named: "commentMarkerWhenCreated")
        }
        else if type == "media" {
            tempMarker.image = UIImage(named: "momentMarkerWhenCreated")
        }
        else if type == "chat_room"{
            tempMarker.image = UIImage(named: "chatMarkerWhenCreated")
        }
        self.view.addSubview(tempMarker)
        markerMask = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(markerMask)
        UIView.animate(withDuration: 0.783, delay: 0.15, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.tempMarker.frame.size.width = 48
            self.tempMarker.frame.size.height = 51
            self.tempMarker.center = mapCenter
            }, completion: { (done: Bool) in
                if done {
                    self.markerMask.removeFromSuperview()
                    self.loadMarkerWithpinID(pinID: pinID, type: type, tempMaker: self.tempMarker)
                }
        })
    }
    
    func removeTempMarker() {
        print("[removeTempMarker] func called")
        tempMarker.removeFromSuperview()
    }
    
    func loadMarkerWithpinID(pinID: String, type: String, tempMaker: UIImageView) {
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "200")
        loadPinsByZoomLevel.whereKey("type", value: type)
        loadPinsByZoomLevel.whereKey("in_duration", value: "true")
        loadPinsByZoomLevel.getMapInformation{(status: Int, message: Any?) in
            let mapInfoJSON = JSON(message!)
            if mapInfoJSON.count > 0 {
                for i in 0...(mapInfoJSON.count-1) {
                    let pinShowOnMap = GMSMarker()
                    pinShowOnMap.zIndex = 1
                    var pinData = [String: AnyObject]()
                    var type = "comment"
                    var status = ""
                    var iconImage = UIImage()
                    if let typeInfo = mapInfoJSON[i]["type"].string {
                        pinData["type"] = typeInfo as AnyObject?
                        if typeInfo == "comment" {
                            type = "comment"
                        }
                        else if typeInfo.contains("chat"){
                            type = "chat_room"
                        }
                        else if typeInfo == "media" {
                            type = "media"
                        }
                        pinShowOnMap.zIndex = 0
                        if let createdTimeInfo = mapInfoJSON[i]["created_at"].string {
                            if createdTimeInfo.isNewPin() {
                                status = "new"
                            }
                        }
                        if let likeCount = mapInfoJSON[i]["liked_count"].int {
                            if likeCount >= 15 {
                                status = "hot"
                            }
                        }
                        if let commentCount = mapInfoJSON[i]["comment_count"].int {
                            if commentCount >= 10 {
                                status = "hot"
                            }
                        }
                        if let readInfo = mapInfoJSON[i]["user_pin_operations"]["is_read"].bool {
                            if readInfo && status == "hot" {
                                status = "hot and read"
                            }
                            else if readInfo {
                                status = "read"
                            }
                        }
                        pinData["status"] = status as AnyObject?
                        iconImage = self.pinIconSelector(type: type, status: status)
                        pinShowOnMap.icon = iconImage
                    }
                    if let pinIDInfo = mapInfoJSON[i]["\(type)_id"].int {
                        if pinID != "\(pinIDInfo)" {
                            print("[loadMarkerWithpinID] not found pinID")
                            continue
                        }
                        pinData["\(type)_id"] = pinIDInfo as AnyObject?
                        print("[loadMarkerWithpinID] found pinID")
                    }
                    if let userIDInfo = mapInfoJSON[i]["user_id"].int {
                        pinData["user_id"] = userIDInfo as AnyObject?
                    }
                    if let createdTimeInfo = mapInfoJSON[i]["created_at"].string {
                        pinData["created_at"] = createdTimeInfo as AnyObject?
                    }
                    if let latitudeInfo = mapInfoJSON[i]["geolocation"]["latitude"].double {
                        pinData["latitude"] = latitudeInfo as AnyObject?
                        pinShowOnMap.position.latitude = latitudeInfo
                    }
                    if let longitudeInfo = mapInfoJSON[i]["geolocation"]["longitude"].double {
                        pinData["longitude"] = longitudeInfo as AnyObject?
                        pinShowOnMap.position.longitude = longitudeInfo
                    }
                    pinShowOnMap.userData = pinData
                    pinShowOnMap.groundAnchor = CGPoint(x: 0.5, y: 1)
                    pinShowOnMap.appearAnimation = kGMSMarkerAnimationNone
                    pinShowOnMap.map = self.faeMapView
                    self.mapPinsArray.append(pinShowOnMap)
                    Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.removeTempMarker), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    func jumpToMainScreenSearch(_ sender: UIButton) {
        let mainScreenSearchVC = MainScreenSearchViewController()
        mainScreenSearchVC.modalPresentationStyle = .overCurrentContext
        mainScreenSearchVC.delegate = self
        self.present(mainScreenSearchVC, animated: false, completion: nil)
    }
}
