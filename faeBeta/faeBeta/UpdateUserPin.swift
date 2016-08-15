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
        if startUpdatingLocation {
            let selfLocation = FaeMap()
            selfLocation.whereKey("geo_latitude", value: "\(currentLatitude)")
            selfLocation.whereKey("geo_longitude", value: "\(currentLongitude)")
            selfLocation.renewCoordinate {(status:Int,message:AnyObject?) in
                print("Update Self Location Status Code:")
                print(status)
            }
            let getMapUserInfo = FaeMap()
            getMapUserInfo.whereKey("geo_latitude", value: "\(currentLatitude)")
            getMapUserInfo.whereKey("geo_longitude", value: "\(currentLongitude)")
            getMapUserInfo.whereKey("radius", value: "500000")
            getMapUserInfo.whereKey("type", value: "user")
            getMapUserInfo.getMapInformation {(status:Int,message:AnyObject?) in
                print("获取图上User数据：")
                print(message)
                let mapUserInfoJSON = JSON(message!)
                if mapUserInfoJSON.count > 0 {
                    for i in 0...(mapUserInfoJSON.count-1) {
                        var userID = -999
                        let pinShowOnMap = GMSMarker()
                        var pinData = [String: AnyObject]()
                        print("DEBUG: ENTER USER PIN EDIT")
                        if let typeInfo = mapUserInfoJSON[i]["type"].string {
                            print("type:")
                            print(typeInfo)
                            pinData["type"] = typeInfo
                            if typeInfo == "user" {
                                pinShowOnMap.icon = UIImage(named: "userHolmes")
                            }
                        }
                        if let userIDInfo = mapUserInfoJSON[i]["user_id"].int {
                            print("user id:")
                            print(userIDInfo)
                            pinData["user_id"] = userIDInfo
                            userID = userIDInfo
                            
                        }
                        if let createdTimeInfo = mapUserInfoJSON[i]["created_at"].string {
                            print("created at:")
                            print(createdTimeInfo)
                            pinData["created_at"] = createdTimeInfo
                        }
                        if mapUserInfoJSON[i]["geolocation"].count == 5 {
                            print("DEBUG ENTER GEO EDIT")
                            var latitude: CLLocationDegrees = -999.9
                            var longitude: CLLocationDegrees = -999.9
                            let random = Int(arc4random_uniform(5))
                            if let latitudeInfo = mapUserInfoJSON[i]["geolocation"][random]["latitude"].double {
                                print("latitude info printed")
                                print(latitudeInfo)
                                latitude = latitudeInfo
                                pinData["latitude"] = latitudeInfo
                                if let longitudeInfo = mapUserInfoJSON[i]["geolocation"][random]["longitude"].double {
                                    print("longitude info printed")
                                    print(longitudeInfo)
                                    longitude = longitudeInfo
                                    pinData["longitude"] = longitudeInfo
                                    let point = CLLocationCoordinate2DMake(latitude, longitude)
                                    if let userMarker = self.mapUserPinsDic[userID] {
                                        userMarker.map = nil
                                        self.mapUserPinsDic[userID] = pinShowOnMap
                                        pinShowOnMap.position = point
                                        pinShowOnMap.userData = pinData
                                        pinShowOnMap.appearAnimation = kGMSMarkerAnimationPop
                                        pinShowOnMap.map = self.faeMapView
                                    }
                                    else {
                                        self.mapUserPinsDic[userID] = pinShowOnMap
                                        pinShowOnMap.position = point
                                        pinShowOnMap.userData = pinData
                                        pinShowOnMap.appearAnimation = kGMSMarkerAnimationPop
                                        pinShowOnMap.map = self.faeMapView
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