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
    dynamic var userName: String = ""
    dynamic var userNickName: String? = nil
    dynamic var userID: String = ""
    //Avatar has not been added to local storage yet
    dynamic var userSmallAvatar: NSData? = nil
    dynamic var smallAvatarEtag: String? = nil
    dynamic var userLargeAvatar: NSData? = nil
    dynamic var largeAvatarEtag: String? = nil
    override static func primaryKey() -> String? {
        return "userID"
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
    dynamic var userId = 0
    dynamic var avatar: NSData? = nil
    dynamic var etag = ""
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

