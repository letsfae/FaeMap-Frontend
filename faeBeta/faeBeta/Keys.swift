//
//  Keys.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

private enum SERVERTYPE {
    case development
    case production
}

// change this to .production to switch to production mode
private let server = SERVERTYPE.development

var baseURL: String {
    get {
        return server == .development ? "https://dev.letsfae.com" : "https://api.letsfae.com"
    }
}

var fireBaseRef: String {
    get {
        return server == .development ? "Message-dev" : "Message-prod"
    }
}

var version = "x.faeapp.v1"
var headerAccept = "application/x.faeapp.v1+json"
var headerContentType = "application/x-www-form-urlencoded"
let headerClientVersion : String = "fae-ios-1.0.0"
var headerDeviceID : String = ""
var headerUserAgent : String = "iPhone"

var userToken : String!
var userTokenEncode : String!
var session_id : Int = -1
var user_id : Int = -1
var is_Login : Int = 0
var userEmail : String!
var userPassword : String!
let GoogleMapKey = "AIzaSyC7Wxy8L4VFaTdzC7vbD43ozVO_yUw4DTk"

var username : String?
//new add global var
var nickname : String?
var shortIntro : String?
var showGender = false
var showAge = false
var userAge : Int?

var userStatus: Int = -999
var userStatusMessage : String?

var userFirstname : String?
var userLastname : String?
var userBirthday : String? // yyyy-MM-dd
var userGender : Int? // 0 means male 1 means female
var userUserGender : String?
var userUserName : String = "Fae User"
var userMiniAvatar : Int = 0

var userPhoneNumber : String?

var userEmailVerified : Bool = false
var userPhoneVerified : Bool = false

var userAvatarMap = "miniAvatar_1" // new var by Yue Shen

var arrayNameCard = [Int:UIImage]()
//var arrayNameCard : [Int: UIImage]!

func headerAuthentication()->[String : AnyObject] {
    if userTokenEncode != nil && userTokenEncode != "" {
        return ["Authorization":userTokenEncode as AnyObject]
    }
    if is_Login == 1 && userTokenEncode != nil {
        return ["Authorization":userTokenEncode as AnyObject]
    }
    let shareAPI = LocalStorageManager()
    if let encode=shareAPI.readByKey("userTokenEncode") as? String {
        userTokenEncode = encode 
        return ["Authorization":userTokenEncode as AnyObject]
    }
    return [:]
}
