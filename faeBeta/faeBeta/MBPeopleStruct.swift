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
    let usrName: String
    let shortIntro: String
    let gender: String
    let age: Int
    let position: CLLocationCoordinate2D
    let distance: String
    
    init(json: JSON) {
        userId = json["user_id"].intValue
        usrName = json["name"].stringValue
        shortIntro = json["short_intro"].stringValue
        gender = json["gender"].stringValue
        age = json["age"].intValue
        position = CLLocationCoordinate2D(latitude: json["geolocation"]["latitude"].doubleValue,
                                          longitude: json["geolocation"]["longitude"].doubleValue)
        distance = ""
    }
}
