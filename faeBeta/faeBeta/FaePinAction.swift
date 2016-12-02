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
    func commentThisPin(_ type: String?, commentId: String?, completion: @escaping (Int, Any?) -> Void) {
        postToURL("pins/"+type!+"/"+commentId!+"/comments", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // Like this pin
    func likeThisPin(_ type: String?, commentId: String?, completion: @escaping (Int, Any?) -> Void) {
        postToURL("pins/"+type!+"/"+commentId!+"/like", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // Unlike this pin
    func unlikeThisPin(_ type: String?, commentID: String?, completion: @escaping (Int, Any?) -> Void) {
        if commentID != nil{
            deleteFromURL("pins/"+type!+"/"+commentID!+"/like", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Save this pin
    func saveThisPin(_ type: String?, commentId: String?, completion: @escaping (Int, Any?) -> Void) {
        postToURL("pins/"+type!+"/"+commentId!+"/save", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // Get pin's attribute
    func getPinAttribute(_ type: String?, commentId: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && commentId != nil {
            getFromURL("pins/"+type!+"/"+commentId!+"/attribute", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Get pin's comments
    func getPinComments(_ type: String?, commentId: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && commentId != nil {
            getFromURL("pins/"+type!+"/"+commentId!+"/comments", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func votePinComments(pinCommentId: String?, completion: @escaping (Int, Any?) -> Void) {
        if pinCommentId != nil {
            postToURL("pins/comments/\(pinCommentId!)/vote", parameter: keyValue, authentication: headerAuthentication(), completion: { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            })
        }
    }
    
    
    
    
//    func deleteCommentById(commentId:String?, completion:(Int,AnyObject?)->Void){
//        if commentId != nil{
//            deleteFromURL("comments/"+commentId!, parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
//                //                print("delete comment by id")
//                self.clearKeyValue()
//                completion(status,message)
//            }
//        }
//    }
}
