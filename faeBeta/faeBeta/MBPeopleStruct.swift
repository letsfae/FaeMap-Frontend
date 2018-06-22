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

extension BoardPeopleStruct: Equatable {
    static func ==(lhs: BoardPeopleStruct, rhs: BoardPeopleStruct) -> Bool {
        return lhs.userId == rhs.userId
    }
}

struct BoardPeopleStruct {
    let userId: Int
    let userName : String
    let displayName: String
    let shortIntro: String
    let gender: String
    let age: String
    let position: CLLocation
    let distance: Double
    
    init(json: JSON) {
        userId = json["user_id"].intValue
        userName = json["user_name"].stringValue
        displayName = json["user_nick_name"].stringValue
        shortIntro = json["short_intro"].stringValue
        gender = json["user_gender"].stringValue
        age = json["user_age"].stringValue
        
        position = CLLocation(latitude: json["geolocation"][0]["latitude"].doubleValue,
                              longitude: json["geolocation"][0]["longitude"].doubleValue)

        let location: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate
        let curtPos = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        distance = curtPos.distance(from: position) / 1000
    }
}
