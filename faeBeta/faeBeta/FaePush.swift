//
//  FaePush.swift
//  faeBeta
//
//  Created by blesssecret on 11/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

class FaePush: NSObject {
    var keyValue = [String:AnyObject]()
    override init (){
        //local storage
        //        self.isLogin = false
        //        self.userToken = ""
    }
    func whereKey(_ key:String, value:String)->Void{
        keyValue[key]=value as AnyObject?
    }
    func whereKeyInt(_ key:String, value:Int)->Void{
        keyValue[key]=value as AnyObject?
    }
    func clearKeyValue()->Void{
        self.keyValue = [String:AnyObject]()
    }

    func getSync(_ completion:@escaping (Int,Any?)->Void){
//        print(headerAuthentication())
        getFromURL("sync", parameter: nil, authentication: headerAuthentication()) {(status: Int, message: Any?) in
//            print(message)
            //self.clearKeyValue()
            completion(status, message);
        }
    }
}
