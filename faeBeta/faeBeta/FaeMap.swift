//
//  FaeMap.swift
//  faeBeta
//
//  Created by blesssecret on 6/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FaeMap {
    
    static let shared = FaeMap()
    
    var keyValue = [String: String]()
    
    func whereKey(_ key: String, value: String) {
        keyValue[key] = value
    }
    
    func clearKeyValue() {
        keyValue = [String: String]()
    }
    
    //Map information
    func renewCoordinate(_ completion: @escaping (Int,Any?) -> Void) {
        postToURL("map/user", parameter: keyValue, authentication: Key.shared.headerAuthentication()) { (status:Int, message:Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getMapInformation(_ completion: @escaping (Int, Any?) -> Void) {
        getFromURL("map", parameter: keyValue, authentication: Key.shared.headerAuthentication()) {(status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func postPin(type: String?, completion: @escaping (Int, Any?) -> Void) {
        guard type != nil else { return }
        postToURL("\(type!)s", parameter: keyValue, authentication: Key.shared.headerAuthentication()) { (status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    
    // Get saved pins
    func getSavedPins(completion: @escaping (Int, Any?) -> Void) {
        getFromURL("pins/saved", parameter: keyValue, authentication: Key.shared.headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    
    // Get created pins
    func getCreatedPins(completion: @escaping (Int, Any?) -> Void) {
        getFromURL("pins/users", parameter: keyValue, authentication: Key.shared.headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // Get pin statistics
    func getPinStatistics(completion: @escaping (Int, Any?) -> Void) {
        getFromURL("pins/statistics", parameter: keyValue, authentication: Key.shared.headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    
    func getPin(type: String?, pinId: String?, completion: @escaping (Int, Any?) -> Void){
        guard type != nil && pinId != nil else { return }
        getFromURL("\(type!)s/\(pinId!)", parameter: keyValue, authentication: Key.shared.headerAuthentication()) { (status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func updateComment(_ commentId: String?, completion:@escaping (Int, Any?) -> Void) {
        guard commentId != nil else { return }
        postToURL("comments/"+commentId!, parameter: keyValue, authentication: Key.shared.headerAuthentication()) {(status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func updatePin(_ pinType: String?, pinId: String?, completion:@escaping (Int, Any?) -> Void) {
        guard pinId != nil && pinType != nil else { return }
        postToURL("\(pinType!)s/\(pinId!)", parameter: keyValue, authentication: Key.shared.headerAuthentication()) {(status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getUserAllPinWithType(type: String?, userId: String?, completion: @escaping (Int, Any?) -> Void) {
        guard type != nil && userId != nil else { return }
        getFromURL("\(type!)s/users/\(userId!)", parameter: keyValue, authentication: Key.shared.headerAuthentication()) { (status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func deletePin(type: String?, pinId: String?, completion:@escaping (Int, Any?) -> Void) {
        guard type != nil && pinId != nil else { return }
        deleteFromURL("\(type!)s/\(pinId!)", parameter: keyValue) { (status:Int, message:Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }

}
