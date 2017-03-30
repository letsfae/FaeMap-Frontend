//
//  PinComment.swift
//  faeBeta
//
//  Created by Yue on 2/26/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PinComment {
    
    let commentId: Int
    let userId: Int
    var displayName: String
    let content: String
    let date: String
    let numVoteCount: Int
    let voteType: String
    let isSticker: Bool
    let isImage: Bool
    let attributedText: NSAttributedString?
    var profileImage: UIImage
    let anonymous: Bool
    
    init(json: JSON) {
        self.commentId = json["pin_comment_id"].intValue
        self.userId = json["user_id"].intValue
        self.displayName = json["nick_name"].stringValue
        self.date = json["created_at"].stringValue.formatFaeDate()
        self.numVoteCount = json["vote_up_count"].intValue - json["vote_down_count"].intValue
        self.voteType = json["pin_comment_operations"]["vote"].stringValue
        self.profileImage = UIImage()
        self.anonymous = json["anonymous"].boolValue
        let contentJson = json["content"].stringValue
        if let stickerName = contentJson.getFaeStickerName() {
            self.content = stickerName
            self.isSticker = true
            self.isImage = false
            self.attributedText = nil
        } else if let imageName = contentJson.getFaeImageName() {
            self.attributedText = nil
            self.content = imageName
            self.isImage = true
            self.isSticker = false
        } else {
            self.attributedText = contentJson.formatPinCommentsContent()
            self.content = ""
            self.isSticker = false
            self.isImage = false
        }
    }
}
