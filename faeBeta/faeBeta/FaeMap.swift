//
//  FaeMap.swift
//  faeBeta
//
//  Created by blesssecret on 6/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FaeMap {
    
    var keyValue = [String:AnyObject]()
    func whereKey(_ key: String, value: String?) -> Void {
        keyValue[key] = value as AnyObject?
    }
    func clearKeyValue() -> Void {
        self.keyValue = [String: AnyObject]()
    }
    //Map information
    func renewCoordinate(_ completion: @escaping (Int,Any?) -> Void) {
        postToURL("map/user", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getMapInformation(_ completion: @escaping (Int, Any?) -> Void) {
        getFromURL("map", parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func postPin(type: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil {
            postToURL("\(type!)s", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func getPin(type: String?, pinId: String?, completion: @escaping (Int, Any?) -> Void){
        if type != nil && pinId != nil {
            getFromURL("\(type!)s/\(pinId!)", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func updateComment(_ commentId: String?, completion:@escaping (Int, Any?) -> Void) {
        if commentId != nil {
            postToURL("comments/"+commentId!, parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func updatePin(_ pinType: String?, pinId: String?, completion:@escaping (Int, Any?) -> Void) {
        if pinId != nil && pinType != nil {
            postToURL("\(pinType!)s/\(pinId!)", parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func getUserAllPinWithType(type: String?, userId: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && userId != nil {
            getFromURL("\(type!)s/users/\(userId!)", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func deletePin(type: String?, pinId: String?, completion:@escaping (Int, Any?) -> Void) {
        if type != nil && pinId != nil {
            deleteFromURL("\(type!)s/\(pinId!)", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }

}
