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
    dynamic var loginUserID_id: String = ""
    dynamic var login_user_id: String = ""
    dynamic var id: String = ""
    dynamic var user_name: String = ""
    dynamic var display_name: String = ""
    dynamic var is_friend: Bool = false
    dynamic var age: String = ""
    dynamic var gender: String = ""
    //let message = LinkingObjects(fromType: RealmMessage_v2.self, property: "members")
    var message: RealmMessage_v2? {
        return realm?.objects(RealmMessage_v2.self).filter("login_user_id = %@ AND members.@count = 2 AND %@ IN members", self.login_user_id, self).first
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
    dynamic var fileId = -999
    dynamic var picture: NSData? = nil
    dynamic var video: NSData? = nil
}

class SelfInformation: Object {
    dynamic var currentUserID = -999
    dynamic var avatar: NSData? = nil
}

class UserAvatar: Object {
    dynamic var user_id: String = ""
    dynamic var userSmallAvatar: NSData? = nil
    dynamic var smallAvatarEtag: String? = nil
    dynamic var userLargeAvatar: NSData? = nil
    dynamic var largeAvatarEtag: String? = nil
    override static func primaryKey() -> String? {
        return "user_id"
    }
}

class NewFaePin: Object {
    dynamic var pinType = ""
    dynamic var pinId = -999
}

// ready to be deleted
class OPinListElem: Object { // Opened Pin List Element
    dynamic var pinTypeId = ""
    dynamic var pinContent = "" // content or place title
    dynamic var pinLat: Double = 0.0
    dynamic var pinLon: Double = 0.0
    dynamic var pinTime = "" // created time or place address
    
    // for place pin
    dynamic var street = ""
    dynamic var city = ""
    dynamic var category = ""
    dynamic var imageURL = ""
    
    override static func primaryKey() -> String? {
        return "pinTypeId"
    }
}

class FaeUserRealm: Object {
    dynamic var userId = 0
    dynamic var firstUpdate = false
    
    override static func primaryKey() -> String? {
        return "userId"
    }
}

