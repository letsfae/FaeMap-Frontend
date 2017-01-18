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
        timerUpdateSelfLocation = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateSelfLocation), userInfo: nil, repeats: true)
    }
    
    func updateTimerForLoadRegionPin(radius: Int) {
        self.loadCurrentRegionPins(radius: radius)
        if timerLoadRegionPins != nil {
            timerLoadRegionPins.invalidate()
        }
        timerLoadRegionPins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(self.loadCurrentRegionPins), userInfo: nil, repeats: true)
    }
    
    // MARK: -- Load Pins based on the Current Region Camera
    func loadCurrentRegionPins(radius: Int) {
        clearMap(type: "pin")
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "500000")
        loadPinsByZoomLevel.whereKey("type", value: "comment,chat_room,media")
        loadPinsByZoomLevel.whereKey("in_duration", value: "true")
        loadPinsByZoomLevel.getMapInformation{(status:Int, message: Any?) in
            if status/100 != 2 || message == nil {
                print("DEBUG: getMapInformation status/100 != 2")
                return
            }
            let mapInfoJSON = JSON(message!)

            self.mapPinsDic.removeAll()
            if mapInfoJSON.count <= 0 {
                return
            }
            for i in 0...(mapInfoJSON.count-1) {
                let pinMap = GMSMarker()
                pinMap.zIndex = 1
                var pinData = [String: AnyObject]()
                var type = "comment"
                let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                icon.contentMode = .scaleAspectFit
                if let typeInfo = mapInfoJSON[i]["type"].string {
                    pinData["type"] = typeInfo as AnyObject?
                    if typeInfo == "comment" {
                        icon.image = #imageLiteral(resourceName: "commentPinMarker")
                        pinMap.iconView = icon
                        type = "comment"
                    }
                    else if typeInfo.contains("chat"){
                        pinMap.icon = UIImage(named: "chatPinMarker")
                        pinMap.zIndex = 0
                        type = "chat_room"
                    }
                    else if typeInfo == "media" {
                        icon.image = #imageLiteral(resourceName: "momentPinMarker")
                        pinMap.iconView = icon
                        type = "media"
                    }
                    pinMap.zIndex = 0
                }
                if let pinIDInfo = mapInfoJSON[i]["\(type)_id"].int {
                    pinData["\(type)_id"] = pinIDInfo as AnyObject?
                    self.mapPinsDic[pinIDInfo] = pinMap
                    /*
                    if self.pinIDFromOpenedPinCell == pinIDInfo {
                        self.markerBackFromPinDetail = pinMap
                        pinMap.icon = UIImage(named: "")
                        pinMap.zIndex = 2
                    }
                     */
                }
                if let userIDInfo = mapInfoJSON[i]["user_id"].int {
                    pinData["user_id"] = userIDInfo as AnyObject?
                }
                if let createdTimeInfo = mapInfoJSON[i]["created_at"].string {
                    pinData["created_at"] = createdTimeInfo as AnyObject?
                }
                if let latitudeInfo = mapInfoJSON[i]["geolocation"]["latitude"].double {
                    pinMap.position.latitude = latitudeInfo
                }
                else {
                    print("DEBUG: Cannot get geoInfo: Latitude")
                    return
                }
                if let longitudeInfo = mapInfoJSON[i]["geolocation"]["longitude"].double {
                    pinMap.position.longitude = longitudeInfo
                }
                else {
                    print("DEBUG: Cannot get geoInfo: Longitude")
                    return
                }
                pinMap.userData = pinData
                // Delay 0-3 seconds, randomly
                let delay: Double = Double(arc4random_uniform(200)) / 100
                pinMap.groundAnchor = CGPoint(x: 0.5, y: 1)
                pinMap.map = self.faeMapView
                self.mapPinsArray.append(pinMap)
                UIView.animate(withDuration: 0.683, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                    icon.frame.size.width = 48
                    icon.frame.size.height = 51
                }, completion: {(done: Bool) in
                    if done {
                        pinMap.iconView = nil
                        if type == "comment" {
                            pinMap.icon = #imageLiteral(resourceName: "commentPinMarker")
                        }
                        else if type == "media" {
                            pinMap.icon = #imageLiteral(resourceName: "momentPinMarker")
                        }
                    }
                })
            }
        }
    }
    
    // Timer to update location (send self location to server)
    func updateSelfLocation(radius: Int) {
        if !startUpdatingLocation || !canDoNextUserUpdate {
            return
        }
        clearMap(type: "user")
        canDoNextUserUpdate = false
        self.renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let getMapUserInfo = FaeMap()
        getMapUserInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getMapUserInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getMapUserInfo.whereKey("radius", value: "500000")
        getMapUserInfo.whereKey("type", value: "user")
        getMapUserInfo.whereKey("user_updated_in", value: "30")
        getMapUserInfo.getMapInformation {(status: Int, message: Any?) in
            if status/100 != 2 || message == nil {
                print("DEBUG: getMapUserInfo status/100 != 2")
                return
            }
            let mapUserInfoJSON = JSON(message!)
            if mapUserInfoJSON.count <= 0 {
                return
            }
            for i in 0...(mapUserInfoJSON.count-1) {
                var userIDinGetMapUser = -999
                let pinUser = GMSMarker()
                var pinData = [String: AnyObject]()
                if let userIDInfo = mapUserInfoJSON[i]["user_id"].int {
                    pinData["user_id"] = userIDInfo as AnyObject?
                    userIDinGetMapUser = userIDInfo
                    if userIDinGetMapUser == user_id.intValue {
                        continue
                    }
                }
                else {
                    print("DEBUG: Cannot get user_id")
                    return
                }
                if let typeInfo = mapUserInfoJSON[i]["type"].string {
                    pinData["type"] = typeInfo as AnyObject?
                }
                if let createdTimeInfo = mapUserInfoJSON[i]["created_at"].string {
                    pinData["created_at"] = createdTimeInfo as AnyObject?
                }
                if mapUserInfoJSON[i]["geolocation"].count == 5 {
                    let random = Int(arc4random_uniform(5))
                    if let latitudeInfo = mapUserInfoJSON[i]["geolocation"][random]["latitude"].double {
                        pinUser.position.latitude = latitudeInfo
                    }
                    else {
                        print("DEBUG: Cannot get geoInfo: Latitude")
                        return
                    }
                    if let longitudeInfo = mapUserInfoJSON[i]["geolocation"][random]["longitude"].double {
                        pinUser.position.longitude = longitudeInfo
                    }
                    else {
                        print("DEBUG: Cannot get geoInfo: Longitude")
                        return
                    }
                    let getMiniAvatar = FaeUser()
                    getMiniAvatar.getOthersProfile("\(userIDinGetMapUser)") {(status, message) in
                        if status/100 != 2 || message == nil{
                            print("DEBUG: getOthersProfile status/100 != 2")
                            return
                        }
                        let userProfile = JSON(message!)
                        if let miniAvatar = userProfile["mini_avatar"].int {
                            self.mapUserPinsDic.append(pinUser)
                            pinUser.userData = pinData
                            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                            icon.image = UIImage(named: "miniAvatar_\(miniAvatar+1)")
                            icon.contentMode = .scaleAspectFit
                            icon.alpha = 0
                            pinUser.iconView = icon
                            pinUser.zIndex = 1
                            pinUser.map = self.faeMapView
                            self.canDoNextUserUpdate = true
                            // Delay 0-1 seconds, randomly
                            let delay: Double = Double(arc4random_uniform(100)) / 100
                            UIView.animate(withDuration: 1, delay: delay, animations: {
                                icon.alpha = 1
                            })
                        }
                    }
                }
            }
        }
    }
}
