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
    func updateTimerForSelfLoc() {
        self.updateSelfLocation()
        if timerUpdateSelfLocation != nil {
            timerUpdateSelfLocation.invalidate()
        }
        timerUpdateSelfLocation = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(FaeMapViewController.updateSelfLocation), userInfo: nil, repeats: true)
    }
    
    func updateTimerForLoadRegionPin() {
        self.loadCurrentRegionPins()
        if timerLoadRegionPins != nil {
            timerLoadRegionPins.invalidate()
        }
        timerLoadRegionPins = NSTimer.scheduledTimerWithTimeInterval(600, target: self, selector: #selector(FaeMapViewController.loadCurrentRegionPins), userInfo: nil, repeats: true)
    }
    
    // MARK: -- Load Pins based on the Current Region Camera
    func loadCurrentRegionPins() {
        self.faeMapView.clear()
        self.updateTimerForSelfLoc()
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "5000")
        loadPinsByZoomLevel.whereKey("type", value: "comment")
        loadPinsByZoomLevel.whereKey("in_duration", value: "true")
        loadPinsByZoomLevel.getMapInformation{(status:Int, message:AnyObject?) in
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
                        pinData["type"] = typeInfo
                        if typeInfo == "comment" {
                            pinShowOnMap.icon = UIImage(named: "comment_pin_marker")
                            pinShowOnMap.zIndex = 0
                        }
                    }
                    if let commentIDInfo = mapInfoJSON[i]["comment_id"].int {
                        pinData["comment_id"] = commentIDInfo
                        self.mapCommentPinsDic[commentIDInfo] = pinShowOnMap
                        if self.commentIDFromOpenedPinCell == commentIDInfo {
                            print("TESTing far away from")
                            self.markerBackFromCommentDetail = pinShowOnMap
                            pinShowOnMap.icon = UIImage(named: "markerCommentPinHeavyShadow")
                            pinShowOnMap.zIndex = 2
                        }
                    }
                    if let userIDInfo = mapInfoJSON[i]["user_id"].int {
                        pinData["user_id"] = userIDInfo
                    }
                    if let createdTimeInfo = mapInfoJSON[i]["created_at"].string {
                        pinData["created_at"] = createdTimeInfo
                    }
                    if let latitudeInfo = mapInfoJSON[i]["geolocation"]["latitude"].double {
                        pinData["latitude"] = latitudeInfo
                        pinShowOnMap.position.latitude = latitudeInfo
                    }
                    if let longitudeInfo = mapInfoJSON[i]["geolocation"]["longitude"].double {
                        pinData["longitude"] = longitudeInfo
                        pinShowOnMap.position.longitude = longitudeInfo
                    }
                    pinShowOnMap.userData = pinData
                    let delay: Double = Double(arc4random_uniform(300)) / 100
                    let infoDict: [String: AnyObject] = ["argumentInt": pinShowOnMap]
                    let timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(delay), target: self, selector: #selector(FaeMapViewController.editTimerToDisplayMarker(_:)), userInfo: infoDict, repeats: false)
                    self.NSTimerDisplayMarkerArray.append(timer)
                }
            }
        }
    }
    
    func editTimerToDisplayMarker(timer: NSTimer) {
        if let userInfo = timer.userInfo as? Dictionary<String, AnyObject> {
            let marker = userInfo["argumentInt"] as! GMSMarker
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.groundAnchor = CGPointMake(0.5, 1)
            marker.map = self.faeMapView
        }
    }
    
    // Timer to update location (send self location to server)
    func updateSelfLocation() {
        if startUpdatingLocation && canDoNextUserUpdate {
            for everyUser in self.mapUserPinsDic {
                everyUser.map = nil
            }
            canDoNextUserUpdate = false
            self.renewSelfLocation()
            let getMapUserInfo = FaeMap()
            getMapUserInfo.whereKey("geo_latitude", value: "\(currentLatitude)")
            getMapUserInfo.whereKey("geo_longitude", value: "\(currentLongitude)")
            getMapUserInfo.whereKey("radius", value: "500000")
            getMapUserInfo.whereKey("type", value: "user")
            getMapUserInfo.getMapInformation {(status: Int, message: AnyObject?) in
                let mapUserInfoJSON = JSON(message!)
                if mapUserInfoJSON.count > 0 {
                    for i in 0...(mapUserInfoJSON.count-1) {
                        var userID = -999
                        let pinShowOnMap = GMSMarker()
                        var pinData = [String: AnyObject]()
                        if let userIDInfo = mapUserInfoJSON[i]["user_id"].int {
                            pinData["user_id"] = userIDInfo
                            userID = userIDInfo
                            if userID == user_id {
                                continue
                            }
                        }
                        if let typeInfo = mapUserInfoJSON[i]["type"].string {
                            pinData["type"] = typeInfo
                        }
                        if let createdTimeInfo = mapUserInfoJSON[i]["created_at"].string {
                            pinData["created_at"] = createdTimeInfo
                        }
                        if mapUserInfoJSON[i]["geolocation"].count == 5 {
                            var latitude: CLLocationDegrees = -999.9
                            var longitude: CLLocationDegrees = -999.9
                            let random = Int(arc4random_uniform(5))
                            if let latitudeInfo = mapUserInfoJSON[i]["geolocation"][random]["latitude"].double {
                                latitude = latitudeInfo
                                pinData["latitude"] = latitudeInfo
                                if let longitudeInfo = mapUserInfoJSON[i]["geolocation"][random]["longitude"].double {
                                    longitude = longitudeInfo
                                    pinData["longitude"] = longitudeInfo
                                    let point = CLLocationCoordinate2DMake(latitude, longitude)
                                    let getMiniAvatar = FaeUser()
                                    getMiniAvatar.getOthersProfile("\(userID)") {(status, message) in
                                        let userProfile = JSON(message!)
                                        if let miniAvatar = userProfile["mini_avatar"].int {
                                            self.mapUserPinsDic.append(pinShowOnMap)
                                            pinShowOnMap.position = point
                                            pinShowOnMap.userData = pinData
                                            pinShowOnMap.icon = UIImage(named: "avatar_\(miniAvatar+1)")
                                            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
                                            fadeAnimation.fromValue = 0.0
                                            fadeAnimation.toValue = 1.0
                                            fadeAnimation.duration = 1
                                            pinShowOnMap.layer.addAnimation(fadeAnimation, forKey: "Opacity")
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
