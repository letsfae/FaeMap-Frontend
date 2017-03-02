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
    
    func updateTimerForLoadRegionPlacePin(radius: Int, all: Bool) {
        self.loadCurrentRegionPlacePins(radius: radius, all: all)
        if timerLoadRegionPlacePins != nil {
            timerLoadRegionPlacePins.invalidate()
        }
        timerLoadRegionPlacePins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(self.loadCurrentRegionPlacePins), userInfo: nil, repeats: true)
    }
    
    func loadCurrentRegionPlacePins(radius: Int, all: Bool) {
        return
        clearMap(type: "place")
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        yelpQuery.setLatitude(lat: Double(mapCenterCoordinate.latitude))
        yelpQuery.setLongitude(lon: Double(mapCenterCoordinate.longitude))
        yelpQuery.setRadius(radius: Int(Double(radius)))
        yelpQuery.setSortRule(sort: "best_match")
        
        // All type
        var resultArray = [YelpResult]()
        var resultName = [String]()
        
        func checkPlaceExist(_ result: YelpResult) -> Bool {
            if resultName.contains(result.getName()) {
                return true
            }
            return false
        }
        
        if !all {
            yelpQuery.setResultLimit(count: 10)
            self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                for result in results {
                    if checkPlaceExist(result) {
                        continue
                    }
                    resultName.append(result.getName())
                    resultArray.append(result)
                }
                self.pinPlacesOnMap(results: resultArray)
//                self.calculateZoomLevel(results: resultArray)
            })
        }
        else {
            yelpQuery.setResultLimit(count: 4)
            yelpQuery.setCatagoryToRestaurant()
            yelpManager.query(request: yelpQuery, completion: { (results) in
                for result in results {
                    if checkPlaceExist(result) {
                        continue
                    }
                    resultName.append(result.getName())
                    resultArray.append(result)
                }
                self.yelpQuery.setResultLimit(count: 2)
                self.yelpQuery.setCatagoryToDessert()
                self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                    for result in results {
                        if checkPlaceExist(result) {
                            continue
                        }
                        resultName.append(result.getName())
                        resultArray.append(result)
                    }
                    self.yelpQuery.setCatagoryToCafe()
                    self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                        for result in results {
                            if checkPlaceExist(result) {
                                continue
                            }
                            resultName.append(result.getName())
                            resultArray.append(result)
                        }
                        self.yelpQuery.setCatagoryToCinema()
                        self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                            for result in results {
                                if checkPlaceExist(result) {
                                    continue
                                }
                                resultName.append(result.getName())
                                resultArray.append(result)
                            }
                            self.yelpQuery.setCatagoryToSport()
                            self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                                for result in results {
                                    if checkPlaceExist(result) {
                                        continue
                                    }
                                    resultName.append(result.getName())
                                    resultArray.append(result)
                                }
                                self.yelpQuery.setCatagoryToBeauty()
                                self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                                    for result in results {
                                        if checkPlaceExist(result) {
                                            continue
                                        }
                                        resultName.append(result.getName())
                                        resultArray.append(result)
                                    }
                                    self.yelpQuery.setCatagoryToArt()
                                    self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                                        for result in results {
                                            if checkPlaceExist(result) {
                                                continue
                                            }
                                            resultName.append(result.getName())
                                            resultArray.append(result)
                                        }
                                        self.yelpQuery.setCatagoryToJuice()
                                        self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                                            for result in results {
                                                if checkPlaceExist(result) {
                                                    continue
                                                }
                                                resultName.append(result.getName())
                                                resultArray.append(result)
                                            }
                                            self.pinPlacesOnMap(results: resultArray)
//                                            self.calculateZoomLevel(results: resultArray)
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        }
    }
    
    // MARK: -- Load Pins based on the Current Region Camera
    func loadCurrentRegionPins(radius: Int) {
        clearMap(type: "pin")
        self.mapPinsArray.removeAll()
        self.mapPins.removeAll()
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
            guard let mapPinJsonArray = mapInfoJSON.array else {
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
                print("[getPinComments] fail to parse pin comments")
                return
            }
            if mapPinJsonArray.count <= 0 {
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
                return
            }
            self.mapPins = mapPinJsonArray.map{MapPin(json: $0)}
            for mapPin in self.mapPins {
                let pinMap = GMSMarker()
                
                var iconImage = UIImage()
                let iconSub = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 61))
                let icon = UIImageView(frame: CGRect(x: 30, y: 61, width: 0, height: 0))
                iconSub.addSubview(icon)
                icon.contentMode = .scaleAspectFit
                iconImage = self.pinIconSelector(type: mapPin.type, status: mapPin.status)
                icon.image = iconImage
                icon.layer.anchorPoint = CGPoint(x: 30, y: 61)
                pinMap.position = mapPin.position
                pinMap.iconView = iconSub
                pinMap.userData = [0: mapPin]
                pinMap.groundAnchor = CGPoint(x: 0.5, y: 1)
                pinMap.zIndex = 1
                pinMap.map = self.faeMapView
                self.mapPinsArray.append(pinMap)
                let delay: Double = Double(arc4random_uniform(300)) / 100 // Delay 0-3 seconds, randomly
                UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                    icon.frame = CGRect(x: 6, y: 10, width: 48, height: 51)
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
    
    // Timer to update location (send self location to server)
    func updateSelfLocation(radius: Int) {
        if didLoadFirstLoad || !canDoNextUserUpdate {
            return
        }
        userPins.removeAll()
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
//        getMapUserInfo.whereKey("user_updated_in", value: "30")
        getMapUserInfo.getMapInformation {(status: Int, message: Any?) in
            
            if status/100 != 2 || message == nil {
                print("DEBUG: getMapUserInfo status/100 != 2")
                
                return
            }
            let mapUserJSON = JSON(message!)
            guard let mapUserJsonArray = mapUserJSON.array else {
                print("[getMapUserInfo] fail to parse pin comments")
                return
            }
            if mapUserJsonArray.count <= 0 {
                return
            }
            self.userPins = mapUserJsonArray.map{UserPin(json: $0)}
            let mapUserInfoJSON = JSON(message!)
            if mapUserInfoJSON.count <= 0 {
                return
            }
            var count = 0
            for userPin in self.userPins {
                if count > 5 {
                    break
                } else if userPin.userId == Int(user_id) {
                    continue
                }
                count += 1
                let pinUser = GMSMarker()
                pinUser.position = userPin.position
                let getMiniAvatar = FaeUser()
                getMiniAvatar.getOthersProfile("\(userPin.userId)") {(status, message) in
                    if status/100 != 2 || message == nil{
                        print("DEBUG: getOthersProfile status/100 != 2")
                        return
                    }
                    let userProfile = JSON(message!)
                    let miniAvatar = userProfile["mini_avatar"].intValue
                    self.mapUserPinsDic.append(pinUser)
                    pinUser.userData = [1: userPin]
                    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                    let iconImage = UIImage(named: "mapAvatar_\(miniAvatar+1)")
                    icon.image = iconImage
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
                    }, completion: {(finished) in
                        pinUser.iconView = nil
                        pinUser.icon = iconImage
                    })
                }
            }
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
    
    fileprivate func calculateZoomLevel(results: [YelpResult]) {
        var latArr = [Double]()
        var lonArr = [Double]()
        for result in results {
            latArr.append(result.getPosition().latitude)
            lonArr.append(result.getPosition().longitude)
        }
        
        let minLat = latArr.min()!
        let maxLat = latArr.max()!
        let minLon = lonArr.min()!
        let maxLon = lonArr.max()!
        let northWestCor = CLLocationCoordinate2DMake(maxLat, minLon)
        let southEastCor = CLLocationCoordinate2DMake(minLat, maxLon)
        let geoBounds = GMSCoordinateBounds(coordinate: northWestCor, coordinate: southEastCor)
        let cameraUpdate = GMSCameraUpdate.fit(geoBounds, withPadding: 25.0)
        faeMapView.animate(with: cameraUpdate)
    }
    
    fileprivate func pinPlacesOnMap(results: [YelpResult]) {
        for result in results {
            var pinData = [String: AnyObject]()
            var iconImage = UIImage()
            pinData["title"] = result.getName() as AnyObject?
            let categoryList = result.getCategory()
            pinData["type"] = "place" as AnyObject?
            pinData["category"] = self.placesPinCheckCategory(categoryList: categoryList) as AnyObject?
            iconImage = self.placesPinIconImage(categoryList: categoryList)
            pinData["latitude"] = result.getPosition().latitude as AnyObject?
            pinData["longitude"] = result.getPosition().longitude as AnyObject?
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
            pinMap.position = result.getPosition()
            pinMap.userData = pinData
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
    }
    
    fileprivate func placesPinCheckCategory(categoryList: [String]) -> String {
        if categoryList.contains("burgers") {
            return "burgers"
        }
        else if categoryList.contains("pizza") {
            return "pizza"
        }
        else if categoryList.contains("coffee") {
            return "coffee"
        }
        else if categoryList.contains("desserts") {
            return "desserts"
        }
        else if categoryList.contains("icecream") {
            return "desserts"
        }
        else if categoryList.contains("movietheaters") {
            return "movietheaters"
        }
        else if categoryList.contains("museums") {
            return "museums"
        }
        else if categoryList.contains("galleries") {
            return "museums"
        }
        else if categoryList.contains("beautysvc") {
            return "beautysvc"
        }
        else if categoryList.contains("spas") {
            return "beautysvc"
        }
        else if categoryList.contains("barbers") {
            return "beautysvc"
        }
        else if categoryList.contains("skincare") {
            return "beautysvc"
        }
        else if categoryList.contains("massage") {
            return "beautysvc"
        }
        else if categoryList.contains("playgrounds") {
            return "playgrounds"
        }
        else if categoryList.contains("countryclubs") {
            return "playgrounds"
        }
        else if categoryList.contains("sports_clubs") {
            return "playgrounds"
        }
        else if categoryList.contains("bubbletea") {
            return "juicebars"
        }
        else if categoryList.contains("juicebars") {
            return "juicebars"
        }
        return ""
    }
    
    fileprivate func placesPinIconImage(categoryList: [String]) -> UIImage {
        var iconImage = UIImage()
        if categoryList.contains("burgers") {
            iconImage = #imageLiteral(resourceName: "placePinBurger")
        }
        else if categoryList.contains("pizza") {
            iconImage = #imageLiteral(resourceName: "placePinPizza")
        }
        else if categoryList.contains("coffee") {
            iconImage = #imageLiteral(resourceName: "placePinCoffee")
        }
        else if categoryList.contains("desserts") {
            iconImage = #imageLiteral(resourceName: "placePinDesert")
        }
        else if categoryList.contains("icecream") {
            iconImage = #imageLiteral(resourceName: "placePinDesert")
        }
        else if categoryList.contains("movietheaters") {
            iconImage = #imageLiteral(resourceName: "placePinCinema")
        }
        else if categoryList.contains("museums") {
            iconImage = #imageLiteral(resourceName: "placePinArt")
        }
        else if categoryList.contains("galleries") {
            iconImage = #imageLiteral(resourceName: "placePinArt")
        }
        else if categoryList.contains("spas") {
            iconImage = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if categoryList.contains("barbers") {
            iconImage = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if categoryList.contains("skincare") {
            iconImage = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if categoryList.contains("massage") {
            iconImage = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if categoryList.contains("playgrounds") {
            iconImage = #imageLiteral(resourceName: "placePinSport")
        }
        else if categoryList.contains("countryclubs") {
            iconImage = #imageLiteral(resourceName: "placePinSport")
        }
        else if categoryList.contains("sports_clubs") {
            iconImage = #imageLiteral(resourceName: "placePinSport")
        }
        else if categoryList.contains("bubbletea") {
            iconImage = #imageLiteral(resourceName: "placePinBoba")
        }
        else if categoryList.contains("juicebars") {
            iconImage = #imageLiteral(resourceName: "placePinBoba")
        }
        return iconImage
    }
}
