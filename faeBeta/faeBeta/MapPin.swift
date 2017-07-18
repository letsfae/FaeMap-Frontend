//
//  MapPin.swift
//  faeBeta
//
//  Created by Yue on 2/28/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension MapPin: Equatable {
    static func ==(lhs: MapPin, rhs: MapPin) -> Bool {
        return lhs.pinId == rhs.pinId && lhs.type == rhs.type
    }
}

struct MapPin {
    var pinId: Int
    var userId: Int
    var type: String
    var status: String
    var position: CLLocationCoordinate2D

    init(json: JSON) {
        let tmp_type = json["type"].stringValue
        self.type = tmp_type
        self.pinId = json["pin_id"].intValue
        self.userId = json["pin_object"]["user_id"].intValue
        self.position = CLLocationCoordinate2D(latitude: json["pin_object"]["geolocation"]["latitude"].doubleValue,
                                               longitude: json["pin_object"]["geolocation"]["longitude"].doubleValue)
//        if json["pin_object"]["anonymous"].boolValue {
//            self.userId = -1
//        }
        self.status = "normal"
        if json["created_at"].stringValue.isNewPin() {
            self.status = "new"
            let realm = try! Realm()
            if realm.objects(NewFaePin.self).filter("pinId == \(self.pinId) AND pinType == '\(self.type)'").first != nil {
                print("[checkPinStatus] newPin exists!")
                self.status = "normal"
            }
        }
        if self.userId == user_id {
            self.status = "normal"
        }
        let likeCount = json["pin_object"]["liked_count"].intValue
        let commentCount = json["pin_object"]["comment_count"].intValue
        let read = json["pin_object"]["user_pin_operations"]["is_read"].boolValue
        if commentCount >= 10 || likeCount >= 15 {
            if read {
                self.status = "hotRead"
            } else {
                self.status = "hot"
            }
        } else if read {
            self.status = "read"
        }
    }
}
