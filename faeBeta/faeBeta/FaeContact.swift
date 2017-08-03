//
//  FaeContact.swift
//  FaeContacts
//
//  Created by Justin He and Sophie on 6/21/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class FaeContact {
    
    var keyValue = [String:AnyObject]()
    func whereKey(_ key: String, value: String?) -> Void {
        keyValue[key] = value as AnyObject?
    }
    func clearKeyValue() -> Void {
        self.keyValue = [String: AnyObject]()
    }
    
    // Contacts Information
    func sendFriendRequest(friendId: String, boolResend: String = "false", _ completion: @escaping (Int,Any?) -> Void) {
        self.whereKey("requested_user_id", value: friendId)
        self.whereKey("resend", value: boolResend)
        postToURL("friends/request", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func acceptFriendRequest(requestId: String, _ completion: @escaping (Int, Any?) -> Void) {
        self.whereKey("friend_request_id", value: requestId)
        postToURL("friends/accept", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func ignoreFriendRequest(requestId: String, _ completion: @escaping (Int, Any?) -> Void) {
        self.whereKey("friend_request_id", value: requestId)
        postToURL("friends/ignore", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func withdrawFriendRequest(requestId: String, _ completion: @escaping (Int, Any?) -> Void) {
        self.whereKey("friend_request_id", value: requestId)
        postToURL("friends/withdraw", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func blockPerson(userId: String, _ completion: @escaping (Int, Any?) -> Void) {
        self.whereKey("user_id", value: userId)
        postToURL("blocks", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func deleteFriend(requestId: String, _ completion: @escaping (Int, Any?) -> Void) {
        deleteFromURL("friends/" + requestId, parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
        
    func unblockPerson(userId: String, _ completion: @escaping (Int, Any?) -> Void) {
        deleteFromURL("blocks/" + userId, parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getFriendRequests(_ completion: @escaping (Int,Any?) -> Void) {
        getFromURL("friends/request", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getFriendRequestsSent(_ completion: @escaping (Int,Any?) -> Void) {
        getFromURL("friends/request_sent", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getFriends(_ completion: @escaping (Int,Any?) -> Void) {
        getFromURL("friends", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?)
            in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    
}
