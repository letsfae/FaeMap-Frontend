//
//  FaePinAction.swift
//  faeBeta
//
//  Created by Yue on 9/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

class FaePinAction : NSObject {
    var keyValue = [String:AnyObject]()
    
    func whereKey(_ key:String, value:String) -> Void {
        keyValue[key] = value as AnyObject?
    }
    
    func clearKeyValue()->Void{
        self.keyValue = [String: AnyObject]()
    }
    
    // Comment this pin
    func commentThisPin(_ type: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        postToURL("pins/"+type!+"/"+pinID!+"/comments", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // Like this pin
    func likeThisPin(_ type: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        postToURL("pins/"+type!+"/"+pinID!+"/like", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // Unlike this pin
    func unlikeThisPin(_ type: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if pinID != nil{
            deleteFromURL("pins/"+type!+"/"+pinID!+"/like", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Save this pin
    func saveThisPin(_ type: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && pinID != nil {
            postToURL("pins/\(type!)/\(pinID!)/save", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Unsave this pin
    func unsaveThisPin(_ type: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && pinID != nil {
            deleteFromURL("pins/\(type!)/\(pinID!)/save", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Have read this pin
    func haveReadThisPin(_ type: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && pinID != nil {
            postToURL("pins/\(type!)/\(pinID!)/read", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Get pin's attribute
    func getPinAttribute(_ type: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && pinID != nil {
            getFromURL("pins/"+type!+"/"+pinID!+"/attribute", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Get pin's comments
    func getPinComments(_ type: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && pinID != nil {
            getFromURL("pins/"+type!+"/"+pinID!+"/comments", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func votePinComments(pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if pinID != nil {
            postToURL("pins/comments/\(pinID!)/vote", parameter: keyValue, authentication: headerAuthentication(), completion: { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            })
        }
    }
    
    func deletePinById(type: String?, pinId: String?, completion:@escaping (Int, Any?) -> Void) {
        if type != nil && pinId != nil{
            deleteFromURL("\(type!)s/\(pinId!)", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
}
