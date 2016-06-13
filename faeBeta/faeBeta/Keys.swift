//
//  Keys.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

var userToken : String!
var userTokenEncode : String!
var session_id : NSNumber!
var user_id : NSNumber!
var is_Login : Int = 0
let GoogleMapKey = "AIzaSyC7Wxy8L4VFaTdzC7vbD43ozVO_yUw4DTk"

func headerAuthentication()->[String : AnyObject] {
    if userTokenEncode != nil && userTokenEncode != "" {
        return ["Authorization":userTokenEncode]
    }
    if is_Login == 1 && userTokenEncode != nil {
        return ["Authorization":userTokenEncode]
    }
    let shareAPI = LocalStorageManager()
    if let encode=shareAPI.readByKey("userTokenEncode") as? String {
        userTokenEncode = encode 
        return ["Authorization":userTokenEncode]
    }
    return [:]
}
