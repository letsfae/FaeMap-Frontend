//
//  MBCommentStruct.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/5/18.
//  Copyright © 2017年 Yue. All rights reserved.
//
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
    var attributedText: NSAttributedString?
    let date: String
    var likeCount: Int
    var commentCount: Int
    let position: CLLocationCoordinate2D
    var address: String
    let anonymous: Bool
    var status: String
    var fileIdArray = [Int]()
    var isLiked: Bool
    var feelingArray = [Int]()
    var chatTitle: String
    var chatLastMesg: String
    
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
        
        self.feelingArray.removeAll()
        let feelings = json["pin_object"]["feeling_count"].arrayValue.map({Int($0.stringValue)})
        for idx in 0..<feelings.count {
            if feelings[idx] != nil && feelings[idx] != 0 {
                self.feelingArray.append(idx)
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
        
        self.chatTitle = ""
        self.chatLastMesg = ""
        if self.type == "chat_room" {
            self.chatTitle = json["pin_object"]["title"].stringValue
            self.chatLastMesg = json["pin_object"]["last_message"].stringValue
        }
        
        self.isLiked = json["pin_object"]["user_pin_operations"]["is_liked"].boolValue
        self.status = "normal"
        if commentCount >= 10 || likeCount >= 15 {
            self.status = "hot"
        }
    }
}
