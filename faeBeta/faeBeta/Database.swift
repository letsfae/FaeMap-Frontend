//
//  Database.swift
//  faeBeta
//
//  Created by Yue on 12/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import RealmSwift

//Bryan
class RealmUser: Object {
    @objc dynamic var loginUserID_id: String = ""
    @objc dynamic var login_user_id: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var user_name: String = ""
    @objc dynamic var display_name: String = ""
    @objc dynamic var is_friend: Bool = false
    @objc dynamic var age: String = ""
    @objc dynamic var gender: String = ""
    //let message = LinkingObjects(fromType: RealmMessage_v2.self, property: "members")
    var message: RealmMessage_v2? {
        return realm?.objects(RealmMessage_v2.self).filter("login_user_id = %@ AND members.@count = 2 AND %@ IN members", self.login_user_id, self).last
    }
    var avatar: UserAvatar? {
        return realm?.objects(UserAvatar.self).filter("user_id == %@", self.id).first
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

class UserAvatar: Object {
    @objc dynamic var user_id: String = ""
    @objc dynamic var userSmallAvatar: NSData? = nil
    @objc dynamic var smallAvatarEtag: String? = nil
    @objc dynamic var userLargeAvatar: NSData? = nil
    @objc dynamic var largeAvatarEtag: String? = nil
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

