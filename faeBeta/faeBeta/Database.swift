//
//  Database.swift
//  faeBeta
//
//  Created by Yue on 12/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import RealmSwift

class FileObject: Object {
    dynamic var fileId = -999
    dynamic var picture: NSData? = nil
    dynamic var video: NSData? = nil
}

class SelfInformation: Object {
    dynamic var currentUserID = -999
    dynamic var avatar: NSData? = nil
}

class NewFaePin: Object {
    dynamic var pinType = -999
    dynamic var pinId = -999
}

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
