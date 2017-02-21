//
//  Database.swift
//  faeBeta
//
//  Created by Yue on 12/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import RealmSwift

class Media: Object {
    dynamic var fileId = -999
    dynamic var picture: NSData? = nil
    dynamic var video: NSData? = nil
}

class MomengPin: Object {
    dynamic var mediaId = -999
    let medias = List<Media>()
}

class SelfInformation: Object {
    dynamic var currentUserID = -999
    dynamic var avatar: NSData? = nil
}

class NewPinList: Object {
    dynamic var userId = -999
    let pinList = List<FaePin>()
}

class PinList: Object {
    dynamic var userId = -999
    let pinList = List<NewFaePin>()
}

class FaePin: Object {
    dynamic var pinType = ""
    dynamic var pinId = ""
}

class NewFaePin: Object {
    dynamic var pinType = -999
    dynamic var pinId = -999
}

class OpenedPinListElem: Object {
    dynamic var pinType = ""
    dynamic var pinId = ""
    dynamic var pinContent = "" // content or place title
    dynamic var pinLat: Double = 0.0
    dynamic var pinLon: Double = 0.0
    dynamic var pinTime = "" // created time or place address
}

class OPinListElem: Object { // Opened Pin List Element
    dynamic var pinTypeId = ""
    dynamic var pinContent = "" // content or place title
    dynamic var pinLat: Double = 0.0
    dynamic var pinLon: Double = 0.0
    dynamic var pinTime = "" // created time or place address
    
    override static func primaryKey() -> String? {
        return "pinTypeId"
    }
}
