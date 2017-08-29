//
//  FaeUser.swift
//  faeBeta
//
//  Created by blesssecret on 5/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import SwiftyJSON
/*
 // after login all the information will be store in here.
 // UTF 8 str from original
 // NSData! type returned (optional)
 
 // Base64 encode UTF 8 string
 // fromRaw(0) is equivalent to objc 'base64EncodedStringWithOptions:0'
 // Notice the unwrapping given the NSData! optional
 // NSString! returned (optional)
 */
class FaeUser: NSObject {
    
    var keyValue = [String: AnyObject]()
    
    override init() {
        
    }
    
    func whereKey(_ key: String, value: String) {
        keyValue[key] = value as AnyObject?
    }
    
    func clearKeyValue() {
        keyValue = [String: AnyObject]()
    }
    
    /* faeuser sign up function
     Required parameters: password, email, user_name, first_name, last_name, birthday, gender
     Optional parameters: nil
     */
    func signUpInBackground(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("users", parameter: keyValue, authentication: nil) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                // success
                self.saveUserSignUpInfo()
            } else {
                // fail
            }
            // self.clearKeyValue()
            completion(status, message)
        }
    }
    
    fileprivate func saveUserSignUpInfo() {
        let keyValueJSON = JSON(keyValue)
        userEmail = keyValueJSON["email"].stringValue
        userPassword = keyValueJSON["password"].stringValue
        userFirstname = keyValueJSON["first_name"].stringValue
        userLastname = keyValueJSON["last_name"].stringValue
        userBirthday = keyValueJSON["birthday"].stringValue
        let gender = keyValueJSON["gender"].stringValue
        if gender == "male" {
            userGender = 0
        } else {
            userGender = 1
        }
        LocalStorageManager.shared.saveString("userEmail", value: userEmail)
        LocalStorageManager.shared.saveString("userPassword", value: userPassword)
        LocalStorageManager.shared.saveString("userFirstname", value: userFirstname)
        LocalStorageManager.shared.saveString("userLastname", value: userLastname)
        LocalStorageManager.shared.saveString("userBirthday", value: userBirthday)
        LocalStorageManager.shared.saveInt("userGender", value: userGender)
    }
    
    /* faeuser log in function
     Required parameters: password, email or user_name
     Optional parameters: device_id, is_mobile
     */
    
    func logInBackground(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("authentication", parameter: keyValue, authentication: nil) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.processToken(message!)
                self.getSelfProfile { (_: Int, message: Any?) in
                    guard let userInfo = message else {
                        print("[logInBackground] get log in info fail")
                        return
                    }
                    let userInfoJSON = JSON(userInfo)
                    userEmail = userInfoJSON["email"].stringValue
                    username = userInfoJSON["user_name"].stringValue
                    userFirstname = userInfoJSON["first_name"].stringValue
                    userLastname = userInfoJSON["last_name"].stringValue
                    let gender = userInfoJSON["gender"].stringValue
                    if gender == "male" {
                        userGender = 0
                    } else {
                        userGender = 1
                    }
                    userBirthday = userInfoJSON["birthday"].stringValue
                    userPhoneNumber = userInfoJSON["phone"].stringValue
                    LocalStorageManager.shared.getAccountStorage()
                }
            } else {
                
            }
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // process return information after logging in
    func processToken(_ message: Any) {
        let messageJSON = JSON(message)
        
        let str = messageJSON["token"].stringValue
        let session = messageJSON["session_id"].intValue
        let user = messageJSON["user_id"].intValue
        let authentication = "\(user):\(str):\(session)"
        session_id = session
        Key.shared.user_id = user
        
        let utf8str = authentication.data(using: String.Encoding.utf8)
        print(authentication)
        let base64Encoded = utf8str!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        print("Encoded:  \(base64Encoded)")
        print("FAE " + base64Encoded)
        let encode = "FAE " + base64Encoded
        userToken = str
        userTokenEncode = encode
        Key.shared.is_Login = 1
        userEmail = keyValue["email"] != nil ? keyValue["email"] as! String : ""
        userPassword = keyValue["password"] as! String
        
        LocalStorageManager.shared.logInStorage()
    }
    
    /* faeuser log out function
     Required parameters: nil
     Optional parameters: nil
     */
    func logOut(_ completion: @escaping (Int, Any?) -> Void) { // clear the login token is enough
        let headerToken = headerAuthentication() //this code may set is_Login to 1
        clearLogInInfo()
        deleteFromURL("authentication", parameter: [:], authentication: headerToken) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                // success
            } else {
                
            }
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func clearLogInInfo() {
        userToken = ""
        userTokenEncode = ""
        session_id = -1
        Key.shared.user_id = -1
        Key.shared.is_Login = 0
        userStatus = 1
        LocalStorageManager.shared.saveInt("is_Login", value: 0)
    }
    
    /* faeuser check email exist function
     Required parameters: email
     Optional parameters: nil
     */
    func checkEmailExistence(_ completion: @escaping (Int, Any?) -> Void) {
        if let email = keyValue["email"] as? String {
            getFromURL("existence/email/" + email, parameter: keyValue, authentication: nil) { (status: Int, message: Any?) in
                // self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    /* faeuser check username exist function
     Required parameters: username
     Optional parameters: nil
     */
    func checkUserExistence(_ completion: @escaping (Int, Any?) -> Void) {
        if let username = keyValue["user_name"] as? String {
            getFromURL("existence/user_name/" + username, parameter: keyValue, authentication: nil) { (status: Int, message: Any?) in
                completion(status, message)
            }
        }
    }
    
    /******************* send validate code to email, validate code, change password ******************/
    /* faeuser send code to email function
     Required parameters: email
     Optional parameters: nil
     */
    func sendCodeToEmail(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("reset_login/code", parameter: keyValue, authentication: nil) { (status: Int, message: Any?) in
            //            print(message)
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    /* faeuser verify code sent to email function
     Required parameters: email, code
     Optional parameters: nil
     */
    func validateCode(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("reset_login/code/verify", parameter: keyValue, authentication: nil) { (status: Int, message: Any?) in
            
            //            print(message)
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    /* faeuser change password function
     Required parameters: email, code, password
     Optional parameters: nil
     */
    func changePassword(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("reset_login/password", parameter: keyValue, authentication: nil) { (status: Int, message: Any?) in
            
            if let password = self.keyValue["password"]?.string {
                userPassword = password
                print("[changePassword]", userPassword)
                _ = LocalStorageManager.shared.savePassword()
            }
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    /* faeuser get account information function
     Required parameters: nil
     Optional parameters: nil
     */
    func getAccountBasicInfo(_ completion: @escaping (Int, Any?) -> Void) {
        getFromURL("users/account", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            self.clearKeyValue()
            if status / 100 == 2 {
                guard let userInfo = message else {
                    print("[logInBackground] get log in info fail")
                    return
                }
                let userInfoJSON = JSON(userInfo)
                userEmail = userInfoJSON["email"].stringValue
                userEmailVerified = userInfoJSON["email_verified"].boolValue
                username = userInfoJSON["user_name"].stringValue
                userFirstname = userInfoJSON["first_name"].stringValue
                userLastname = userInfoJSON["last_name"].stringValue
                let gender = userInfoJSON["gender"].stringValue
                if gender == "male" {
                    userGender = 0
                } else {
                    userGender = 1
                }
                userBirthday = userInfoJSON["birthday"].stringValue
                userPhoneNumber = userInfoJSON["phone"].stringValue
                userPhoneVerified = userInfoJSON["phone_verified"].boolValue
                LocalStorageManager.shared.getAccountStorage()
            }
            completion(status, message)
        }
    }
    
    /* faeuser update account information function
     Required parameters: nil
     Optional parameters: first_name, last_name, user_name, birthday, gender
     */
    func updateAccountBasicInfo(_ completion: @escaping (Int, Any?) -> Void) { // update local storage
        postToURL("users/account", parameter: keyValue, authentication: headerAuthentication(), completion: { (status: Int, message: Any?) in
            if status / 100 == 2 {
                guard let userInfo = message else {
                    print("[logInBackground] get log in info fail")
                    return
                }
                let userInfoJSON = JSON(userInfo)
                username = userInfoJSON["user_name"].stringValue
                userFirstname = userInfoJSON["first_name"].stringValue
                userLastname = userInfoJSON["last_name"].stringValue
                let gender = userInfoJSON["gender"].stringValue
                if gender == "male" {
                    userGender = 0
                } else {
                    userGender = 1
                }
                userBirthday = userInfoJSON["birthday"].stringValue
                LocalStorageManager.shared.getAccountStorage()
            }
            completion(status, message)
            self.clearKeyValue()
        })
    }
    
    /* faeuser verify password function
     Required parameters: password
     Optional parameters: nil
     */
    func verifyPassword(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("users/account/password/verify", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            completion(status, message)
        }
    }
    
    /* faeuser update password function
     Required parameters: old_password, new_password
     Optional parameters: nil
     */
    func updatePassword(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("users/account/password", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                // changed successfully
                if let newPassword = self.keyValue["new_password"] {
                    userPassword = newPassword as! String
                    _ = LocalStorageManager.shared.savePassword()
                }
            }
            completion(status, message)
        }
    }
    
    /* faeuser update email function
     Required parameters: email
     Optional parameters: nil
     */
    func updateEmail(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("users/account/email", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            completion(status, message)
        }
    }
    
    /* faeuser verify email function
     Required parameters: email, code
     Optional parameters: nil
     */
    func verifyEmail(_ completion: @escaping (Int, Any?) -> Void) {
        print(headerAuthentication())
        postToURL("users/account/email/verify", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                
                if let newEmail = self.keyValue["email"] {
                    userEmail = newEmail as! String
                    LocalStorageManager.shared.saveEmail()
                    print("new email")
                    print(userEmail)
                }
            }
            completion(status, message)
        }
    }
    
    /* faeuser update phone number function
     Required parameters: phone
     Optional parameters: nil
     */
    func updatePhoneNumber(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("users/account/phone", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            completion(status, message)
        }
    }
    
    /* faeuser verify phone number function
     Required parameters: phone, code
     Optional parameters: nil
     */
    func verifyPhoneNumber(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("users/account/phone/verify", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                if let newPhoneNumber = self.keyValue["phone"] {
                    userPhoneNumber = newPhoneNumber as? String
                    _ = LocalStorageManager.shared.savePhoneNumber()
                    print("new phone number")
                    //                    print(userPhoneNumber)
                }
            }
            completion(status, message)
        }
    }
    
    func getSelfProfile(_ completion: @escaping (Int, Any?) -> Void) {
        getFromURL("users/profile", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            // print(self.keyValue)
            // self.clearKeyValue()
            // print(message)
            completion(status, message)
        }
    }
    
    func getOthersProfile(_ otherUser: String, completion: @escaping (Int, Any?) -> Void) {
        getFromURL("users/\(otherUser)/profile", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            // self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func updateProfile(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("/users/profile", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            // self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getUserCard(_ otherUser: String, completion: @escaping (Int, Any?) -> Void) {
        getFromURL("users/\(otherUser)/name_card", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            completion(status, message)
        }
    }
    
    func getSelfNamecard(_ completion: @escaping (Int, Any?) -> Void) {
        getFromURL("users/name_card", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            completion(status, message)
        }
    }
    
    func updateNameCard(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("/users/name_card", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            // self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getAllTags(_ completion: @escaping (Int, Any?) -> Void) {
        getFromURL("users/name_card/tags", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            completion(status, message)
        }
    }
    
    func getSelfStatus(_ completion: @escaping (Int, Any?) -> Void) { // 解包 //local storage
        getFromURL("users/status", parameter: nil, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            completion(status, message)
        }
    }
    
    /*
     * status: 0:offline
     *         1:online
     *         2:no distrub
     *         3:busy
     *         4:away
     *         5:invisible
     */
    func setSelfStatus(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("users/status", parameter: keyValue, authentication: headerAuthentication()) { (status: Int, message: Any?) in
            completion(status, message)
        }
    }
    
}
