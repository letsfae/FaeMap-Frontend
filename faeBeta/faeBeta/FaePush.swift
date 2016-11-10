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
    func whereKey(key:String, value:String)->Void{
        keyValue[key]=value
    }
    func whereKeyInt(key:String, value:Int)->Void{
        keyValue[key]=value
    }
    func clearKeyValue()->Void{
        self.keyValue = [String:AnyObject]()
    }

    func getSync(completion:(Int,AnyObject?)->Void){
//        print(headerAuthentication())
        getFromURL("sync", parameter: nil, authentication: headerAuthentication()) {(status: Int, message: AnyObject?) in
//            print(message)
            //self.clearKeyValue()
            completion(status, message);
        }
    }
}
