//
//  FaeMap.swift
//  faeBeta
//
//  Created by blesssecret on 6/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FaeMap: NSObject {
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
            completion(status,message)
        }
    }
    
    func getMapInformation(_ completion: @escaping (Int, Any?) -> Void) {
        getFromURL("map", parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // ChatPin
    func postChatPin(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("chat_rooms", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getChatPin(_ chatId: String?, completion: @escaping (Int, Any?) -> Void){
        if let chatId = chatId{
            getFromURL("chat_rooms/"+chatId, parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }

    }
    
    // Moment
    func postMoment(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("medias", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getMoment(_ momentId: String?, completion: @escaping (Int, Any?) -> Void){
        if momentId != nil{
            getFromURL("medias/"+momentId!, parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
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
