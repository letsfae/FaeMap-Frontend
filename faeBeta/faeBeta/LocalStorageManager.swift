//
//  LocalStorageManager.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class LocalStorageManager: NSObject {
    fileprivate let defaults = UserDefaults.standard
    func saveString(_ key:String,value:String){
        self.defaults.set(value, forKey: key)
    }
    func saveInt(_ key:String,value:Int){
        self.defaults.set(value, forKey: key)
    }
    func saveNumber(_ key:String,value:NSNumber){
        self.defaults.set(value, forKey: key)
    }
    
    func readByKey(_ key:String)->AnyObject? {
        //        return self.defaults.objectForKey(key)?
        if let obj = self.defaults.object(forKey: key) {
            return obj as AnyObject?
        }
        return nil
    }
    func saveUsername()->Bool{
        if username != nil {
            saveString("username", value: username!)
            return true
        }
        return false
    }
    func readUsername()->Bool{
        if(username == nil){
            if let usernames = readByKey("username"){
                username = usernames as? String
                return true
            }
            //should we need to read from internet
            return false
        }
        return true
    }
    func saveEmail()->Bool{
        if userEmail != nil {
            saveString("userEmail", value: userEmail!)
            return true
        }
        return false
    }
    func readEmail()->Bool{
        if(userEmail == nil){
            if let useremail = readByKey("userEmail"){
                userEmail = useremail as! String
                return true
            }
            //should we need to read from internet
            return false
        }
        return true
    }
    func savePhoneNumber()->Bool{
        if userPhoneNumber != nil {
            saveString("userPhoneNumber", value: userPhoneNumber!)
            return true
        }
        return false
    }
    func readPhoneNumber()->Bool{
        if(userPhoneNumber == nil){
            if let userephonenumber = readByKey("userPhoneNumber"){
                userPhoneNumber = userephonenumber as? String
                return true
            }
            //should we need to read from internet
            return false
        }
        return true
    }
    
    func savePassword()->Bool{
        if userPassword != nil {
            saveString("userPassword", value: userPassword!)
            return true
        }
        return false
    }
    func readPassword()->Bool{
        if(userPassword == nil){
            if let userpassword = readByKey("userPassword"){
                userPassword = userpassword as! String
                return true
            }
            //should we need to read from internet
            return false
        }
        return true
    }
    func logInStorage()->Bool{
        if(userToken==nil || userTokenEncode==nil || session_id == -1 || user_id == -1 || userEmail == nil || userPassword == nil || is_Login == 0){
            return false
        }
        saveString("userToken", value: userToken)
        saveString("userTokenEncode", value: userTokenEncode)
        saveInt("session_id", value: session_id)
        saveInt("user_id", value: user_id)
        saveInt("is_Login", value: is_Login)
        saveString("userEmail", value: userEmail)
        saveString("userPassword", value: userPassword)
        return true
    }
    
    func getAccountStorage() ->Bool{
        if userEmail != nil{
            saveString("userEmail", value: userEmail)
        }
        else{
            saveString("userEmail", value: "")
        }
        
        if username != nil{
            saveString("username", value: username!)
        }
        else{
            saveString("username", value: "")
        }
        
        if userFirstname != nil{
            saveString("userFirstname", value: userFirstname!)
        }
        else{
            saveString("userFirstname", value: "")
        }
        
        if userLastname != nil{
            saveString("userLastname", value: userLastname!)
        }
        else{
            saveString("userLastname", value: "")
        }
        
        if userBirthday != nil{
            saveString("userBirthday", value: userBirthday!)
        }
        else{
            saveString("userBirthday", value: "")
        }
        
        if userGender != nil{
            saveInt("userGender", value: userGender!)
        }
        else{
            saveInt("userGender", value: 3)
        }
        return true
    }
    
    func readLogInfo() -> Bool {
        _ = readUsername()
        if is_Login == 1 {
            return true
        }
        if let login = readByKey("is_Login") as? Int {
            if login == 0 {
                return false
            }
            else{
                userToken = readByKey("userToken") as! String
                userTokenEncode = readByKey("userTokenEncode") as! String
                session_id = readByKey("session_id") as! Int
                user_id = readByKey("user_id") as! Int
                is_Login = readByKey("is_Login") as! Int
                userEmail = readByKey("userEmail") as! String
                userPassword = readByKey("userPassword") as! String
                userFirstname = readByKey("userFirstname") as? String
                userLastname = readByKey("userLastname") as? String
                userBirthday = readByKey("userBirthday") as? String
                userGender = readByKey("userGender") as? Int
            }
        }
        return false
    }
    func isFirstPushLaunch() -> Bool {
        let firstLaunchFlag = "FirstPushLaunchFlag"
        let isFirstLaunch = UserDefaults.standard.string(forKey: firstLaunchFlag) == nil
        if (isFirstLaunch) {
            UserDefaults.standard.set("false", forKey: firstLaunchFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}

