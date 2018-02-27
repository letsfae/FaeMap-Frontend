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
    let userName : String
    let displayName: String
    let shortIntro: String
    let gender: String
    let age: String
    let position: CLLocation
    var distance: String
    let dis: Double
    
    init(json: JSON, centerLoc: CLLocationCoordinate2D? = nil) {
        userId = json["user_id"].intValue
        userName = json["user_name"].stringValue
        displayName = json["user_nick_name"].stringValue
        shortIntro = json["short_intro"].stringValue
        gender = json["user_gender"].stringValue
        age = json["user_age"].stringValue
        
        position = CLLocation(latitude: json["geolocation"][0]["latitude"].doubleValue,
                              longitude: json["geolocation"][0]["longitude"].doubleValue)

        var location: CLLocationCoordinate2D!
        if let loc = centerLoc {
            location = loc
        } else {
            location = LocManager.shared.curtLoc.coordinate
        }
        
        let curtPos = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
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
