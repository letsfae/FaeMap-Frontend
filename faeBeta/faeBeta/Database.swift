//
//  Database.swift
//  faeBeta
//
//  Created by Yue on 12/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import RealmSwift

enum UserRelation: Int {
    case no_relation = 0
    case myself = 0b1
    case is_friend = 0b10
    case followed = 0b100
    case followed_by = 0b1000
    case friend_requested = 0b10000
    case friend_requested_by = 0b100000
    case blocked = 0b1000000
    case blocked_by = 0b10000000
}

let NO_RELATION: Int = 0
let MYSELF: Int = 0b1
let IS_FRIEND: Int = 0b10
let FOLLOWED: Int = 0b100
let FOLLOWED_BY: Int = 0b1000
let FRIEND_REQUESTED: Int = 0b10000
let FRIEND_REQUESTED_BY: Int = 0b100000
let BLOCKED: Int = 0b1000000
let BLOCKED_BY: Int = 0b10000000

//Bryan
class RealmUser: Object {
    @objc dynamic var loginUserID_id: String = ""
    @objc dynamic var login_user_id: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var user_name: String = ""
    @objc dynamic var display_name: String = ""
    @objc dynamic var relation: Int = 0
    @objc dynamic var age: String = ""
    @objc dynamic var gender: String = ""
    @objc dynamic var created_at: String = ""
    @objc dynamic var short_intro: String = ""
    //let message = LinkingObjects(fromType: RealmMessage_v2.self, property: "members")
    var message: RealmMessage_v2? {
        return realm?.objects(RealmMessage_v2.self).filter("login_user_id = %@ AND members.@count = 2 AND %@ IN members", self.login_user_id, self).last
    }
    var avatar: UserImage? {
        return realm?.objects(UserImage.self).filter("user_id == %@", self.id).first
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        let current = object as! RealmUser
        if current.user_name != self.user_name { return false }
        if current.display_name != self.display_name { return false }
        if current.relation != self.relation { return false }
        if current.age != self.age { return false }
        if current.gender != self.gender { return false }
        if self.created_at != "" {
            if current.created_at != self.created_at { return false }
        }
        // TODO short intro
        return true
    }
    
    func modified(_ current: RealmUser) -> Bool {
        if current.user_name != self.user_name { return true }
        if current.display_name != self.display_name { return true }
        if current.relation != self.relation { return true }
        if current.age != self.age { return true }
        if current.gender != self.gender { return true }
        return false
    }
    
    override static func primaryKey() -> String? {
        return "loginUserID_id"
    }
}
//ENDBryan

class FileObject: Object {
    @objc dynamic var fileId = -999
    @objc dynamic var picture: NSData? = nil
    @objc dynamic var video: NSData? = nil
}

class SelfInformation: Object {
    @objc dynamic var currentUserID = -999
    @objc dynamic var avatar: NSData? = nil
}

class UserImage: Object {
    @objc dynamic var user_id: String = ""
    @objc dynamic var userSmallAvatar: NSData? = nil
    @objc dynamic var smallAvatarEtag: String? = nil
    @objc dynamic var userLargeAvatar: NSData? = nil
    @objc dynamic var largeAvatarEtag: String? = nil
    @objc dynamic var userCoverPhoto: NSData? = nil
    @objc dynamic var coverPhotoEtag: String? = nil
    override static func primaryKey() -> String? {
        return "user_id"
    }
}

class NewFaePin: Object {
    @objc dynamic var pinType = ""
    @objc dynamic var pinId = -999
}

// ready to be deleted
class OPinListElem: Object { // Opened Pin List Element
    @objc dynamic var pinTypeId = ""
    @objc dynamic var pinContent = "" // content or place title
    @objc dynamic var pinLat: Double = 0.0
    @objc dynamic var pinLon: Double = 0.0
    @objc dynamic var pinTime = "" // created time or place address
    
    // for place pin
    @objc dynamic var street = ""
    @objc dynamic var city = ""
    @objc dynamic var category = ""
    @objc dynamic var imageURL = ""
    
    override static func primaryKey() -> String? {
        return "pinTypeId"
    }
}

class FaeUserRealm: Object {
    @objc dynamic var userId = 0
    @objc dynamic var firstUpdate = false
    
    override static func primaryKey() -> String? {
        return "userId"
    }
}

