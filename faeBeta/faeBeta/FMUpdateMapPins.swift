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

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

extension FaeMapViewController {
    
    func updateTimerForLoadRegionPin() {
        self.loadCurrentRegionPins()
        if timerLoadRegionPins != nil {
            timerLoadRegionPins.invalidate()
        }
        timerLoadRegionPins = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.loadCurrentRegionPins), userInfo: nil, repeats: true)
    }
    
    // MARK: -- Load Pins based on the Current Region Camera
    func loadCurrentRegionPins() {
        clearMap(type: "pin", animated: false)
        let coorDistance = cameraDiagonalDistance()
        if self.canDoNextMapPinUpdate {
            self.canDoNextMapPinUpdate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.refreshMapPins(radius: coorDistance, completion: { (results) in
                    self.pinMapPinsOnMap(results: results)
                    self.canDoNextMapPinUpdate = true
                })
            })
        }
    }
    
    fileprivate func refreshMapPins(radius: Int, completion: @escaping ([MapPin]) -> ()) {
        self.mapPinsMarkers.removeAll()
        self.mapPins.removeAll()
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "\(radius)")
        loadPinsByZoomLevel.whereKey("type", value: stringFilterValue)
        loadPinsByZoomLevel.whereKey("in_duration", value: "true")
        loadPinsByZoomLevel.getMapInformation{(status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadCurrentRegionPins] status/100 != 2")
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
                completion(self.mapPins)
                return
            }
            let mapInfoJSON = JSON(message!)
            guard let mapPinJsonArray = mapInfoJSON.array else {
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
                print("[loadCurrentRegionPins] fail to parse pin comments")
                completion(self.mapPins)
                return
            }
            if mapPinJsonArray.count <= 0 {
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
                completion(self.mapPins)
                return
            }
            self.processMapPins(results: mapPinJsonArray)
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.stopMapFilterSpin), userInfo: nil, repeats: false)
            completion(self.mapPins)
        }
    }
    
    fileprivate func processMapPins(results: [JSON]) {
        for result in results {
            let mapPin = MapPin(json: result)
            if self.mapPins.contains(mapPin) {
                continue
            } else {
                self.mapPins.append(mapPin)
            }
        }
    }
    
    fileprivate func pinMapPinsOnMap(results: [MapPin]) {
        for mapPin in results {
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
            self.mapPinsMarkers.append(pinMap)
            let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
            UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                icon.frame = CGRect(x: 6, y: 10, width: 48, height: 51)
            }, completion: {(done: Bool) in
                if done {
                    pinMap.iconView = nil
                    pinMap.icon = iconImage
                }
            })
        }
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
    
    fileprivate func loadMarkerWithpinID(pinID: String, type: String, tempMaker: UIImageView) {
        let loadPin = FaeMap()
        loadPin.getPin(type: type, pinId: pinID) {(status: Int, message: Any?) in
            if status/100 != 2 || message == nil {
                print("[loadMarkerWithpinID] status/100 != 2")
                return
            }
            guard let mapInfo = message else {
                print("[loadMarkerWithpinID] fail to parse pin info")
                return
            }
            let mapPinJson = JSON(mapInfo)
            var mapPin = MapPin(json: mapPinJson)
            mapPin.pinId = Int(pinID)!
            mapPin.type = type
            mapPin.userId = mapPinJson["user_id"].intValue
            mapPin.status = "normal"
            mapPin.position.latitude = mapPinJson["geolocation"]["latitude"].doubleValue
            mapPin.position.longitude = mapPinJson["geolocation"]["longitude"].doubleValue
            self.mapPins.append(mapPin)
            let pinMap = GMSMarker()
            pinMap.icon = self.pinIconSelector(type: type, status: mapPin.status)
            pinMap.position = mapPin.position
            pinMap.userData = [0: mapPin]
            pinMap.groundAnchor = CGPoint(x: 0.5, y: 1)
            pinMap.zIndex = 1
            pinMap.appearAnimation = GMSMarkerAnimation.none
            pinMap.map = self.faeMapView
            self.mapPinsMarkers.append(pinMap)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                self.tempMarker.removeFromSuperview()
            })
        }
    }
    
    func cameraDiagonalDistance() -> Int {
        let region = faeMapView.projection.visibleRegion()
        let farLeft = region.farLeft
        let nearLeft = region.nearRight
        let distance = GMSGeometryDistance(farLeft, nearLeft)
        return Int(distance*4)
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
}
