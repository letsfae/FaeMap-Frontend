//
//  UpdateMapPins.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController {
    func updateTimerForSelfLoc(radius: Int) {
        self.updateSelfLocation(radius: radius)
        if timerUpdateSelfLocation != nil {
            timerUpdateSelfLocation.invalidate()
        }
        timerUpdateSelfLocation = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(FaeMapViewController.updateSelfLocation), userInfo: nil, repeats: true)
    }
    
    func updateTimerForLoadRegionPin(radius: Int) {
        self.loadCurrentRegionPins(radius: radius)
        if timerLoadRegionPins != nil {
            timerLoadRegionPins.invalidate()
        }
        timerLoadRegionPins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(FaeMapViewController.loadCurrentRegionPins), userInfo: nil, repeats: true)
    }
    
    // MARK: -- Load Pins based on the Current Region Camera
    func loadCurrentRegionPins(radius: Int) {
        self.faeMapView.clear()
        self.updateTimerForSelfLoc(radius: radius)
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "500000")
        loadPinsByZoomLevel.whereKey("type", value: "comment")
        loadPinsByZoomLevel.whereKey("in_duration", value: "true")
        loadPinsByZoomLevel.getMapInformation{(status:Int, message: Any?) in
            let mapInfoJSON = JSON(message!)
            for eachTimer in self.NSTimerDisplayMarkerArray {
                eachTimer.invalidate()
            }
            self.NSTimerDisplayMarkerArray.removeAll()
            self.mapCommentPinsDic.removeAll()
            if mapInfoJSON.count > 0 {
                for i in 0...(mapInfoJSON.count-1) {
                    let pinShowOnMap = GMSMarker()
                    pinShowOnMap.zIndex = 1
                    var pinData = [String: AnyObject]()
                    if let typeInfo = mapInfoJSON[i]["type"].string {
                        pinData["type"] = typeInfo as AnyObject?
                        if typeInfo == "comment" {
                            pinShowOnMap.icon = UIImage(named: "comment_pin_marker")
                            pinShowOnMap.zIndex = 0
                        }
                    }
                    if let commentIDInfo = mapInfoJSON[i]["comment_id"].int {
                        pinData["comment_id"] = commentIDInfo as AnyObject?
                        self.mapCommentPinsDic[commentIDInfo] = pinShowOnMap
                        if self.commentIDFromOpenedPinCell == commentIDInfo {
                            print("TESTing far away from")
                            self.markerBackFromCommentDetail = pinShowOnMap
                            pinShowOnMap.icon = UIImage(named: "markerCommentPinHeavyShadow")
                            pinShowOnMap.zIndex = 2
                        }
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
                    let delay: Double = Double(arc4random_uniform(300)) / 100
                    let infoDict: [String: AnyObject] = ["argumentInt": pinShowOnMap]
                    let timer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(FaeMapViewController.editTimerToDisplayMarker(_:)), userInfo: infoDict, repeats: false)
                    self.NSTimerDisplayMarkerArray.append(timer)
                }
            }
        }
    }
    
    func editTimerToDisplayMarker(_ timer: Timer) {
        if let userInfo = timer.userInfo as? Dictionary<String, AnyObject> {
            let marker = userInfo["argumentInt"] as! GMSMarker
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.groundAnchor = CGPoint(x: 0.5, y: 1)
            marker.map = self.faeMapView
        }
    }
    
    // Timer to update location (send self location to server)
    func updateSelfLocation(radius: Int) {
        if startUpdatingLocation && canDoNextUserUpdate {
            for everyUser in self.mapUserPinsDic {
                everyUser.map = nil
            }
            canDoNextUserUpdate = false
            self.renewSelfLocation()
            let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
            let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
            let getMapUserInfo = FaeMap()
            getMapUserInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
            getMapUserInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
            getMapUserInfo.whereKey("radius", value: "500000")
            getMapUserInfo.whereKey("type", value: "user")
            getMapUserInfo.getMapInformation {(status: Int, message: Any?) in
                let mapUserInfoJSON = JSON(message!)
                if mapUserInfoJSON.count > 0 {
                    for i in 0...(mapUserInfoJSON.count-1) {
                        var userID = -999
                        let pinShowOnMap = GMSMarker()
                        var pinData = [String: AnyObject]()
                        if let userIDInfo = mapUserInfoJSON[i]["user_id"].int {
                            pinData["user_id"] = userIDInfo as AnyObject?
                            userID = userIDInfo
                            if userID == user_id.intValue {
                                continue
                            }
                        }
                        if let typeInfo = mapUserInfoJSON[i]["type"].string {
                            pinData["type"] = typeInfo as AnyObject?
                        }
                        if let createdTimeInfo = mapUserInfoJSON[i]["created_at"].string {
                            pinData["created_at"] = createdTimeInfo as AnyObject?
                        }
                        if mapUserInfoJSON[i]["geolocation"].count == 5 {
                            var latitude: CLLocationDegrees = -999.9
                            var longitude: CLLocationDegrees = -999.9
                            let random = Int(arc4random_uniform(5))
                            if let latitudeInfo = mapUserInfoJSON[i]["geolocation"][random]["latitude"].double {
                                latitude = latitudeInfo
                                pinData["latitude"] = latitudeInfo as AnyObject?
                                if let longitudeInfo = mapUserInfoJSON[i]["geolocation"][random]["longitude"].double {
                                    longitude = longitudeInfo
                                    pinData["longitude"] = longitudeInfo as AnyObject?
                                    let point = CLLocationCoordinate2DMake(latitude, longitude)
                                    let getMiniAvatar = FaeUser()
                                    getMiniAvatar.getOthersProfile("\(userID)") {(status, message) in
                                        let userProfile = JSON(message!)
                                        if let miniAvatar = userProfile["mini_avatar"].int {
                                            self.mapUserPinsDic.append(pinShowOnMap)
                                            pinShowOnMap.position = point
                                            pinShowOnMap.userData = pinData
                                            pinShowOnMap.icon = UIImage(named: "mapAvatar_\(miniAvatar+1)")
                                            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
                                            fadeAnimation.fromValue = 0.0
                                            fadeAnimation.toValue = 1.0
                                            fadeAnimation.duration = 1
                                            pinShowOnMap.layer.add(fadeAnimation, forKey: "Opacity")
                                            pinShowOnMap.zIndex = 1
                                            pinShowOnMap.map = self.faeMapView
                                            self.canDoNextUserUpdate = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
