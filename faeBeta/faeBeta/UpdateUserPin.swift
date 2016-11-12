//
//  UpdateUserPin.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController {
    // Timer to update location (send self location to server)
    func updateSelfLocation() {
        if startUpdatingLocation && canDoNextUserUpdate {
            for everyUser in self.mapUserPinsDic {
                everyUser.map = nil
            }
            canDoNextUserUpdate = false
            let selfLocation = FaeMap()
            selfLocation.whereKey("geo_latitude", value: "\(currentLatitude)")
            selfLocation.whereKey("geo_longitude", value: "\(currentLongitude)")
            selfLocation.renewCoordinate {(status: Int, message: AnyObject?) in
                print("Successfully renew self position")
            }
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
