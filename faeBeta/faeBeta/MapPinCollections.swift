//
//  MapPinCollections.swift
//  faeBeta
//
//  Created by Yue on 5/26/17.
//  Copyright © 2017 fae. All rights reserved.
//


import Foundation
import SwiftyJSON
import RealmSwift

extension MapPinCollections: Equatable {
    static func ==(lhs: MapPinCollections, rhs: MapPinCollections) -> Bool {
        return lhs.pinId == rhs.pinId && lhs.type == rhs.type
    }
}

struct MapPinCollections {
    var pinId: Int
    var type: String
    var userId: Int
    var position: CLLocationCoordinate2D
    var date: String
    var content: String
    var anonymous: Bool
    var nickName: String
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    var fileIds = [Int]()
    var avatar = UIImage()
    var images = [UIImage]()
    
    init(json: JSON) {
        self.pinId = json["pin_id"].intValue
        self.type = json["type"].stringValue
        self.userId = json["pin_object"]["user_id"].intValue
        self.position = CLLocationCoordinate2D(latitude: json["pin_object"]["geolocation"]["latitude"].doubleValue,
                                               longitude: json["pin_object"]["geolocation"]["longitude"].doubleValue)
        self.date = json["created_at"].stringValue
        if self.type == "media" {
            self.content = json["pin_object"]["description"].stringValue
        } else {
            self.content = json["pin_object"]["content"].stringValue
        }
        self.anonymous = json["pin_object"]["anonymous"].boolValue
        self.nickName = json["pin_object"]["nick_name"].stringValue
        self.likeCount = json["pin_object"]["liked_count"].intValue
        self.commentCount = json["pin_object"]["comment_count"].intValue
        self.isLiked = json["pin_object"]["user_pin_operations"]["is_liked"].boolValue
        let fileIDsRaw = json["pin_object"]["file_ids"].arrayValue.map({Int($0.stringValue)})
        for id in fileIDsRaw {
            if id != nil {
                self.fileIds.append(id!)
            }
        }
    }
}
