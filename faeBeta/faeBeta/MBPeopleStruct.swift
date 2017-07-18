//
//  MBPeopleStruct.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/6/5.
//  Copyright © 2017年 Yue. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

extension MBPeopleStruct: Equatable {
    static func ==(lhs: MBPeopleStruct, rhs: MBPeopleStruct) -> Bool {
        return lhs.userId == rhs.userId
    }
}

struct MBPeopleStruct {
    let userId: Int
    let displayName: String
    let shortIntro: String
    let gender: String
    let age: String
    let position: CLLocation
    var distance: String
//    var curtLatitude: CLLocationDegrees = 34.0205378
//    var curtLongitude: CLLocationDegrees = -118.2854081
    let dis: Double
    
    init(json: JSON) {
        userId = json["user_id"].intValue
        displayName = json["user_nick_name"].stringValue
        shortIntro = json["short_intro"].stringValue
        gender = json["user_gender"].stringValue
        age = json["user_age"].stringValue
        
        position = CLLocation(latitude: json["geolocation"][0]["latitude"].doubleValue,
                              longitude: json["geolocation"][0]["longitude"].doubleValue)
        
//        let mbVC = MapBoardViewController()
//        mbVC.updateCurtLoc()
//        curtLatitude = mbVC.currentLatitude
//        curtLongitude = mbVC.currentLongitude
//        
//        position = CLLocation(latitude: json["geolocation"][0]["latitude"].doubleValue,
//                                          longitude: json["geolocation"][0]["longitude"].doubleValue)
        let curtPos = CLLocation(latitude: LocManage.shared.curtLat, longitude: LocManage.shared.curtLong)
        
        dis = curtPos.distance(from: position) / 1000
        if dis < 0.1 {
            distance = "< 0.1 km"
        } else if dis > 999 {
            distance = "> 999 km"
        } else {
            distance = String(format: "%.1f", dis) + " km"
        }
    }
}
