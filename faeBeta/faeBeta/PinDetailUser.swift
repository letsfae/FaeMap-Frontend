//
//  PinDetailUser.swift
//  faeBeta
//
//  Created by Yue on 2/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON

extension PinDetailUser: Equatable {
    static func ==(lhs: PinDetailUser, rhs: PinDetailUser) -> Bool {
        return lhs.userId == rhs.userId
    }
}

struct PinDetailUser {
    
    var userId: Int
    var displayName: String
    var userName: String
    let showAge: Bool
    let showGender: Bool
    let age: String
    let gender: String
    var profileImage: UIImage
    
    init(json: JSON) {
        self.userId = 0
        self.displayName = json["nick_name"].stringValue
        self.userName = json["user_name"].stringValue
        self.showGender = json["show_gender"].boolValue
        self.gender = json["gender"].stringValue
        self.showAge = json["show_age"].boolValue
        self.age = json["age"].stringValue
        self.profileImage = UIImage()
    }
}
