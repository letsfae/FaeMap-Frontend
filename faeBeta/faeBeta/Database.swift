//
//  Database.swift
//  faeBeta
//
//  Created by Yue on 12/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import RealmSwift
import SwiftyJSON

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
let FOLLOWED: Int = 0b100 // I followed others
let FOLLOWED_BY: Int = 0b1000 // others followed me
let FRIEND_REQUESTED: Int = 0b10000 // I've sent request to others
let FRIEND_REQUESTED_BY: Int = 0b100000 // others have sent request to me
let BLOCKED: Int = 0b1000000 // I blocked others
let BLOCKED_BY: Int = 0b10000000 // others blocked me

//Bryan
class RealmUser: Object {
    @objc dynamic var loginUserID_id: String = ""
    @objc dynamic var login_user_id: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var user_name: String = ""
    @objc dynamic var display_name: String = ""
    @objc dynamic var relation: Int = 0
    @objc dynamic var age: String = ""
    @objc dynamic var show_age: Bool = true
    @objc dynamic var gender: String = ""
    @objc dynamic var show_gender: Bool = true
    @objc dynamic var short_intro: String = ""
    @objc dynamic var created_at: String = ""
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
    
    /*convenience required init(nameCard: JSON) {
        self.init()
        loginUserID_id =
    }*/
    
    static func getUpdated(_ user: [String], with relation: Int) {
        let user_id = user[0]
        let user_name = user[1]
        let display_name = user[2]
        let age = user[3]
        let show_age = age != ""
        let gender = user[4]
        let show_gender = gender != ""
        let created_at = user[5]
        let realm = try! Realm()
        if let userExist = realm.filterUser(id: user_id) {
            try! realm.write {
                userExist.user_name = user_name
                userExist.display_name = display_name
                userExist.relation = relation
                userExist.age = age
                userExist.show_age = show_age
                userExist.gender = gender
                userExist.show_gender = show_gender
                userExist.created_at = created_at
            }
        } else {
            let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", "\(Key.shared.user_id)", user_id, user_name, display_name, relation, age, show_age, gender, show_gender, "", created_at])
            try! realm.write {
                realm.add(realmUser)
            }
            General.shared.avatar(userid: Int(user_id)!) {_ in }
        }
    }
    
    static func formateTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        return dateFormatter.string(from: date)
    }
    
    static func formateTime(_ str: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: str) {
            dateFormatter.dateFormat = "yyyyMMddhhmmss"
            return dateFormatter.string(from: date)
        }
        return str
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

