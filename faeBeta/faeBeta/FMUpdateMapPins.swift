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
import RealmSwift

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
    
    func updateTimerForLoadRegionPlacePin(radius: Int) {
        self.loadCurrentRegionPlacePins(radius: radius)
        if timerLoadRegionPlacePins != nil {
            timerLoadRegionPlacePins.invalidate()
        }
        timerLoadRegionPlacePins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(self.loadCurrentRegionPlacePins), userInfo: nil, repeats: true)
    }
    
    func loadCurrentRegionPlacePins(radius: Int) {
        clearMap(type: "place")
        let testYelp = YelpManager()
        let testQuery = YelpQuery()
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        testQuery.setLatitude(lat: Double(mapCenterCoordinate.latitude))
        testQuery.setLongitude(lon: Double(mapCenterCoordinate.longitude))
        testQuery.setCatagoryToPizza()
        testQuery.setRadius(radius: Int(Double(radius)))
        testQuery.setSortRule(sort: "distance")
        testYelp.query(request: testQuery, completion: { (results) in
            print("[YelpAPI - Testing]")
            for result in results {
                var pinData = [String: AnyObject]()
                var iconImage = UIImage()
                pinData["title"] = result.getName() as AnyObject?
                let categoryList = result.getCategory()
                if categoryList.contains("pizza") {
                    pinData["category"] = "pizza" as AnyObject?
                    iconImage = #imageLiteral(resourceName: "placePinPizza")
                }
                else if categoryList.contains("burger") {
                    pinData["category"] = "burger" as AnyObject?
                    iconImage = #imageLiteral(resourceName: "placePinBurger")
                }
                else if categoryList.contains("coffee") {
                    pinData["category"] = "coffee" as AnyObject?
                    iconImage = #imageLiteral(resourceName: "placePinCoffee")
                }
                else if categoryList.contains("dessert") {
                    pinData["category"] = "dessert" as AnyObject?
                    iconImage = #imageLiteral(resourceName: "placePinDesert")
                }
                pinData["latitude"] = result.getPosition().coordinate.latitude as AnyObject?
                pinData["longitude"] = result.getPosition().coordinate.longitude as AnyObject?
                pinData["street"] = result.getAddress1() as AnyObject?
                pinData["city"] = result.getAddress2() as AnyObject?
                pinData["imageURL"] = result.getImageURL() as AnyObject?
                let pinMap = GMSMarker()
                let icon = UIImageView(frame: CGRect.zero)
                icon.contentMode = .scaleAspectFit
                icon.image = iconImage
                pinMap.iconView = icon
                let delay: Double = Double(arc4random_uniform(200)) / 100
                pinMap.groundAnchor = CGPoint(x: 0.5, y: 1)
                pinMap.position = result.getPosition().coordinate
                pinMap.map = self.faeMapView
                self.mapPlacePinsDic.append(pinMap)
                UIView.animate(withDuration: 0.683, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                    icon.frame.size.width = 48
                    icon.frame.size.height = 54
                }, completion: {(done: Bool) in
                    if done {
                        pinMap.iconView = nil
                        pinMap.icon = iconImage
                    }
                })
            }
        })
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
        loadPinsByZoomLevel.whereKey("type", value: stringFilterValue)
        loadPinsByZoomLevel.whereKey("in_duration", value: "true")
        loadPinsByZoomLevel.getMapInformation{(status: Int, message: Any?) in
            if status/100 != 2 || message == nil {
                print("DEBUG: getMapInformation status/100 != 2")
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
                return
            }
            let mapInfoJSON = JSON(message!)

            self.mapPinsDic.removeAll()
            if mapInfoJSON.count <= 0 {
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
                return
            }
            for i in 0...(mapInfoJSON.count-1) {
                let pinMap = GMSMarker()
                pinMap.zIndex = 1
                var pinData = [String: AnyObject]()
                var pinId = -999
                var type = "comment"
                var typeDecimal = -999
                var status = ""
                var iconImage = UIImage()
                let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                icon.contentMode = .scaleAspectFit
                if let typeInfo = mapInfoJSON[i]["type"].string {
                    pinData["type"] = typeInfo as AnyObject?
                    if typeInfo == "comment" {
                        type = "comment"
                        typeDecimal = 0
                    }
                    else if typeInfo.contains("chat"){
                        type = "chat_room"
                        typeDecimal = 1
                    }
                    else if typeInfo == "media" {
                        type = "media"
                        typeDecimal = 2
                    }
                    pinMap.zIndex = 0
                    if let pinIdInfo = mapInfoJSON[i]["\(type)_id"].int {
                        pinId = pinIdInfo
                    }
                    if let createdTimeInfo = mapInfoJSON[i]["created_at"].string {
                        if createdTimeInfo.isNewPin() {
                            status = "new"
                        }
                        let realm = try! Realm()
                        let newPinRealm = realm.objects(NewFaePin.self).filter("pinId == \(pinId) AND pinType == \(typeDecimal)")
                        if newPinRealm.count >= 1 {
                            if newPinRealm.first != nil {
                                print("[checkPinStatus] newPin exists!")
                                status = "normal"
                            }
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
                    icon.image = iconImage
                    pinMap.iconView = icon
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
                        pinMap.icon = iconImage
                    }
                })
            }
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
        }
    }
    
    func pinIconSelector(type: String, status: String) -> UIImage {
        switch type {
        case "comment":
            if status == "hot" {
                return #imageLiteral(resourceName: "markerCommentHot")
            }
            else if status == "new" {
                return #imageLiteral(resourceName: "markerCommentNew")
            }
            else if status == "hot and read" {
                return #imageLiteral(resourceName: "markerCommentHotRead")
            }
            else if status == "read" {
                return #imageLiteral(resourceName: "markerCommentRead")
            }
            else {
                return #imageLiteral(resourceName: "commentPinMarker")
            }
        case "chat_room":
            if status == "hot" {
                return #imageLiteral(resourceName: "markerChatHot")
            }
            else if status == "new" {
                return #imageLiteral(resourceName: "markerChatNew")
            }
            else if status == "hot and read" {
                return #imageLiteral(resourceName: "markerChatHotRead")
            }
            else if status == "read" {
                return #imageLiteral(resourceName: "markerChatRead")
            }
            else {
                return #imageLiteral(resourceName: "chatPinMarker")
            }
        case "media":
            if status == "hot" {
                return #imageLiteral(resourceName: "markerMomentHot")
            }
            else if status == "new" {
                return #imageLiteral(resourceName: "markerMomentNew")
            }
            else if status == "hot and read" {
                return #imageLiteral(resourceName: "markerMomentHotRead")
            }
            else if status == "read" {
                return #imageLiteral(resourceName: "markerMomentRead")
            }
            else {
                return #imageLiteral(resourceName: "momentPinMarker")
            }
        default:
            return UIImage()
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
