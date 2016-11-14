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

    // Comments
    func postComment(_ completion:@escaping (Int, Any?) -> Void) {
        postToURL("comments", parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func updateComment(_ commentId: String?, completion:@escaping (Int, Any?) -> Void) {
        if commentId != nil{
            postToURL("comments/"+commentId!, parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func getComment(_ commentId: String?, completion: @escaping (Int, Any?) -> Void){
        if commentId != nil{
            getFromURL("comments/"+commentId!, parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func getUserAllComments(_ userId:String?, completion: @escaping (Int, Any?) -> Void) {
        if userId != nil{
            //            print(userTokenEncode)
            getFromURL("comments/users/"+userId!, parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func deleteCommentById(_ commentId: String?, completion:@escaping (Int, Any?) -> Void) {
        if commentId != nil{
            deleteFromURL("comments/"+commentId!, parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
                //                print("delete comment by id")
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }

}
