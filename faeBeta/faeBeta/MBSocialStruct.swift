//
//  MBCommentStruct.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/5/18.
//  Copyright © 2017年 Yue. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

extension MBSocialStruct: Equatable {
    static func ==(lhs: MBSocialStruct, rhs: MBSocialStruct) -> Bool {
        return lhs.pinId == rhs.pinId && lhs.type == rhs.type
    }
}

struct MBSocialStruct {
    let pinId: Int
    let type: String
    var userId: Int
    let displayName: String
    var contentJson: String
    let attributedText: NSAttributedString?
    let date: String
    let likeCount: Int
    let commentCount: Int
    let position: CLLocationCoordinate2D
    var address: String
    let anonymous: Bool
    var status: String
    var fileIdArray = [Int]()
    
    init(json: JSON) {
        self.pinId = json["pin_id"].intValue
        self.type = json["type"].stringValue
        self.date = json["created_at"].stringValue.formatFaeDate()
        self.userId = json["pin_object"]["user_id"].intValue
        self.displayName = json["pin_object"]["nick_name"].stringValue
        
        self.contentJson = ""
        if type == "comment" {
            self.contentJson = json["pin_object"]["content"].stringValue
        } else if type == "media" {
            self.contentJson = json["pin_object"]["description"].stringValue
            
            self.fileIdArray.removeAll()
            let fileIDs = json["pin_object"]["file_ids"].arrayValue.map({Int($0.stringValue)})
            for fileID in fileIDs {
                if fileID != nil {
                    self.fileIdArray.append(fileID!)
                }
            }
        }

        self.attributedText = contentJson.formatPinCommentsContent()
        self.anonymous = json["pin_object"]["anonymous"].boolValue
        if anonymous {
            self.userId = -1
        }
        self.likeCount = json["pin_object"]["liked_count"].intValue
        self.commentCount = json["pin_object"]["comment_count"].intValue
        self.position = CLLocationCoordinate2D(latitude: json["pin_object"]["geolocation"]["latitude"].doubleValue,
                                               longitude: json["pin_object"]["geolocation"]["longitude"].doubleValue)
        self.address = ""
        self.status = "normal"
        if commentCount >= 10 || likeCount >= 15 {
            self.status = "hot"
        }
    }
}

//struct MapPin {
//    var pinId: Int
//    var userId: Int
//    var type: String
//    var status: String
//    var position: CLLocationCoordinate2D
//    
//    init(json: JSON) {
//        let tmp_type = json["type"].stringValue
//        self.type = tmp_type
//        self.pinId = json["pin_id"].intValue
//        self.userId = json["pin_object"]["user_id"].intValue
//        self.position = CLLocationCoordinate2D(latitude: json["pin_object"]["geolocation"]["latitude"].doubleValue,
//                                               longitude: json["pin_object"]["geolocation"]["longitude"].doubleValue)
//        //        if json["pin_object"]["anonymous"].boolValue {
//        //            self.userId = -1
//        //        }
//        self.status = "normal"
//        if json["created_at"].stringValue.isNewPin() {
//            self.status = "new"
//            let realm = try! Realm()
//            if realm.objects(NewFaePin.self).filter("pinId == \(self.pinId) AND pinType == '\(self.type)'").first != nil {
//                print("[checkPinStatus] newPin exists!")
//                self.status = "normal"
//            }
//        }
//        if self.userId == Int(user_id) {
//            self.status = "normal"
//        }
//        let likeCount = json["pin_object"]["liked_count"].intValue
//        let commentCount = json["pin_object"]["comment_count"].intValue
//        let readInfo = json["pin_object"]["user_pin_operations"]["is_read"].boolValue
//        if commentCount >= 10 || likeCount >= 15 {
//            if readInfo {
//                self.status = "hot and read"
//            } else {
//                self.status = "hot"
//            }
//        } else if readInfo {
//            self.status = "read"
//        }
//    }
//}

