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

struct MapPin {
    var pinId: Int
    let userId: Int
    var type: String
    var status: String
    let position: CLLocationCoordinate2D
    
    init(json: JSON) {
        let tmp_type = json["type"].stringValue
        self.type = tmp_type
        self.pinId = json["\(tmp_type)_id"].intValue
        self.userId = json["user_id"].intValue
        self.position = CLLocationCoordinate2D(latitude: json["geolocation"]["latitude"].doubleValue,
                                               longitude: json["geolocation"]["longitude"].doubleValue)
        self.status = "normal"
        if json["created_at"].stringValue.isNewPin() {
            self.status = "new"
            let realm = try! Realm()
            if realm.objects(NewFaePin.self).filter("pinId == \(self.pinId) AND pinType == '\(self.type)'").first != nil {
                print("[checkPinStatus] newPin exists!")
                self.status = "normal"
            }
        }
        if self.userId == Int(user_id) {
            self.status = "normal"
        }
        let likeCount = json["liked_count"].intValue
        let commentCount = json["comment_count"].intValue
        let readInfo = json["user_pin_operations"]["is_read"].boolValue
        if commentCount >= 10 || likeCount >= 15 {
            if readInfo {
                self.status = "hot and read"
            } else {
                self.status = "hot"
            }
        } else if readInfo {
            self.status = "read"
        }
    }
}
