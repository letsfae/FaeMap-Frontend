//
//  LocalStorageManager.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class LocalStorageManager: NSObject {
    private let defaults = NSUserDefaults.standardUserDefaults()
    func saveString(key:String,value:String){
        self.defaults.setObject(value, forKey: key)
    }
    func saveInt(key:String,value:Int){
        self.defaults.setObject(value, forKey: key)
    }
    func saveNumber(key:String,value:NSNumber){
        self.defaults.setObject(value, forKey: key)
    }
    func readByKey(key:String)->AnyObject? {
//        return self.defaults.objectForKey(key)?
        if let obj = self.defaults.objectForKey(key) {
            return obj
        }
        return nil
    }
    func logInStorage()->Bool{
        if(userToken==nil || userTokenEncode==nil || session_id == nil || user_id==nil || is_Login == 0){
            return false
        }
        saveString("userToken", value: userToken)
        saveString("userTokenEncode", value: userTokenEncode)
        saveNumber("session_id", value: session_id)
        saveNumber("user_id", value: user_id)
        saveInt("is_Login", value: is_Login)
        return true
    }
    func readLogInfo()->Bool{
//        if is_Login == nil {
//            if let login = readByKey("is_Login") as? Int{
//                if login == 0 {
//                    return false
//                }
//                else{
//                    userToken = readByKey("userToken") as? String
//                    userTokenEncode = readByKey("userTokenEncode")as? String
//                    session_id = readByKey("session_id")as? NSNumber
//                    user_id = readByKey("user_id")as? NSNumber
//                    is_Login = readByKey("is_Login")as? Int
//                    return true
//                }
//            }
//            return false
//        }
        if is_Login == 1 {
            return true
        }
        if let login = readByKey("is_Login") as? Int{
            if login == 0 {
                return false
            }
            else{
                userToken = readByKey("userToken") as! String
                userTokenEncode = readByKey("userTokenEncode")as! String
                session_id = readByKey("session_id")as! NSNumber
                user_id = readByKey("user_id")as! NSNumber
                is_Login = readByKey("is_Login")as! Int
            }
        }
        return false
    }
    func isFirstPushLaunch() -> Bool {
        let firstLaunchFlag = "FirstPushLaunchFlag"
        let isFirstLaunch = NSUserDefaults.standardUserDefaults().stringForKey(firstLaunchFlag) == nil
        if (isFirstLaunch) {
            NSUserDefaults.standardUserDefaults().setObject("false", forKey: firstLaunchFlag)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        return isFirstLaunch
    }
}

