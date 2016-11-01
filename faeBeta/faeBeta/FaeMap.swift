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
    func whereKey(key:String, value:String)->Void{
        keyValue[key]=value
    }
    func clearKeyValue()->Void{
        self.keyValue = [String:AnyObject]()
    }
    //Map information
    func renewCoordinate(completion:(Int,AnyObject?)->Void){
        postToURL("map/user", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    func getMapInformation(completion:(Int, AnyObject?)->Void) {
        getFromURL("map", parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: AnyObject?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }

    // Comments
    
    func postComment(completion:(Int, AnyObject?)->Void) {
        postToURL("comments", parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: AnyObject?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func updateComment(commentId: String?, completion:(Int, AnyObject?) -> Void) {
        if commentId != nil{
            postToURL("comments/"+commentId!, parameter: keyValue, authentication: headerAuthentication()) {(status: Int, message: AnyObject?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func getComment(commentId:String?, completion:(Int,AnyObject?)->Void){
        if commentId != nil{
            getFromURL("comments/"+commentId!, parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
                self.clearKeyValue()
                completion(status,message)
            }
        }
    }
    
    func getUserAllComments(userId:String?, completion:(Int,AnyObject?)->Void){
        if userId != nil{
            //            print(userTokenEncode)
            getFromURL("comments/users/"+userId!, parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
                self.clearKeyValue()
                completion(status,message)
            }
        }
    }
    
    func deleteCommentById(commentId: String?, completion:(Int, AnyObject?) -> Void) {
        if commentId != nil{
            deleteFromURL("comments/"+commentId!, parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
                //                print("delete comment by id")
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }

}
