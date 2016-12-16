//
//  FaeUser.swift
//  faeBeta
//
//  Created by blesssecret on 5/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
/*
 // after login all the information will be store in here.
 // UTF 8 str from original
 // NSData! type returned (optional)
 
 // Base64 encode UTF 8 string
 // fromRaw(0) is equivalent to objc 'base64EncodedStringWithOptions:0'
 // Notice the unwrapping given the NSData! optional
 // NSString! returned (optional)
 */
class FaeUser : NSObject {
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
    
    /* faeuser sign up function
     Required parameters: password, email, user_name, first_name, last_name, birthday, gender
     Optional parameters: nil
     */
    func signUpInBackground(_ completion:@escaping (Int,Any?)->Void){
        postToURL("users", parameter: keyValue, authentication: nil) { (status:Int, message:Any?) in
            if(status / 100 == 2 ) {
                //success
                self.saveUserSignUpInfo()
            }
            else{
                //fail
            }
            //self.clearKeyValue()
            completion(status,message);
        }
    }
    
    func saveUserSignUpInfo(){
        let shareAPI = LocalStorageManager()
        userEmail = keyValue["email"]as! String
        userPassword = keyValue["password"]as! String
        userFirstname = keyValue["first_name"]as? String
        userLastname = keyValue["last_name"]as? String
        userBirthday = keyValue["birthday"]as? String
        let gender = keyValue["gender"]as! String
        if gender == "male" {
            userGender = 0
        }else {
            userGender = 1
        }
        shareAPI.saveString("userEmail", value: userEmail)
        shareAPI.saveString("userPassword", value: userPassword)
        shareAPI.saveString("userFirstname", value: userFirstname!)
        shareAPI.saveString("userLastname", value: userLastname!)
        shareAPI.saveString("userBirthday", value: userBirthday!)
        shareAPI.saveInt("userGender", value: userGender!)
    }
    
    
    /* faeuser log in function
     Required parameters: password, email, user_name
     Optional parameters: device_id, is_mobile
     */
    
    func logInBackground(_ completion:@escaping (Int,Any?)->Void){
        postToURL("authentication", parameter: keyValue, authentication: nil) { (status:Int, message:Any?) in
            if(status / 100 == 2 ){//success
                self.processToken(message!)
                self.getSelfProfile{(status:Int, message:Any?) in
                    if let message = (message as? NSDictionary) {
                        if (message["email"]) != nil{
                            //userEmail
                            userEmail = message["email"] as? String
                            username = message["user_name"] as? String
                            userFirstname = message["first_name"] as? String
                            userLastname = message["last_name"] as? String
                            userGender = message["gender"] as? Int
                            userBirthday = message["birthday"] as? String
                            userPhoneNumber = message["phone"] as? String
                            let shareAPI = LocalStorageManager()
                            _ = shareAPI.getAccountStorage()
                        }
                    }
                }
                //get account info
            }
            else{//failure
            }
            self.clearKeyValue()
            completion(status,message)
            
            // WARNING: this code should be deleted afterward, it's here just to test chat function
            postToURL("chats", parameter: ["receiver_id": "1" as AnyObject, "message": "Hi there, I just registered. Let's chat!" as AnyObject, "type": "text" as AnyObject], authentication: headerAuthentication(), completion: { (statusCode, result) in
            })
        }
    }
    
    // process return information after logging in
    func processToken(_ message:Any)->Void{
        if let message = message as? NSDictionary {
            let str = message["token"] as! String
            let session = message["session_id"] as! NSNumber
            let user = message["user_id"] as! NSNumber
            let authentication = user.stringValue+":"+str+":"+session.stringValue
            session_id = session
            user_id = user
            
            let utf8str = authentication.data(using: String.Encoding.utf8)
            print(authentication)
            let base64Encoded = utf8str!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            print("Encoded:  \(base64Encoded)")
            print("FAE "+base64Encoded)
            let encode = "FAE "+base64Encoded
            userToken = str
            userTokenEncode = encode
            is_Login = 1
            userEmail = keyValue["email"] != nil ? keyValue["email"] as! String : ""
            userPassword = keyValue["password"] as! String
            
            let shareAPI = LocalStorageManager()
            _ = shareAPI.logInStorage()
        }
    }
    
    
    /* faeuser log out function
     Required parameters: nil
     Optional parameters: nil
     */
    func logOut(_ completion:@escaping (Int,Any?) -> Void) {//clear the login token is enough
        let headerToken = headerAuthentication()//this code may set is_Login to 1
        self.clearLogInInfo()
        deleteFromURL("authentication", parameter: [:], authentication: headerToken ) { (status:Int, message:Any?) in
            
            if status / 100 == 2 {
                //success
            }
            else {
                
            }
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func clearLogInInfo(){
        userToken = ""
        userTokenEncode = ""
        session_id = -1
        user_id = -1
        is_Login = 0
        let shareAPI = LocalStorageManager()
        shareAPI.saveInt("is_Login", value: 0)
    }
    
    
    /* faeuser check email exist function
     Required parameters: email
     Optional parameters: nil
     */
    func checkEmailExistence(_ completion:@escaping (Int,Any?)->Void){
        if let email = keyValue["email"] as? String{
            getFromURL("existence/email/"+email, parameter:keyValue, authentication: nil){ (status:Int, message:Any?) in
                //self.clearKeyValue()
                completion(status,message);
            }
        }
    }
    
    /* faeuser check username exist function
     Required parameters: username
     Optional parameters: nil
     */
    func checkUserExistence(_ completion:@escaping (Int,Any?)->Void){
        if let username = keyValue["user_name"] as? String{
            getFromURL("existence/user_name/"+username, parameter:keyValue, authentication: nil){ (status:Int, message:Any?) in

//                print(message)
                //self.clearKeyValue()
                completion(status,message);
            }
        }
    }
    
    /******************* send validate code to email, validate code, change password ******************/
    /* faeuser send code to email function
     Required parameters: email
     Optional parameters: nil
     */
    func sendCodeToEmail(_ completion:@escaping (Int,Any?)->Void){
        postToURL("reset_login/code", parameter: keyValue, authentication: nil) { (status:Int, message:Any?) in
//            print(message)
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    /* faeuser verify code sent to email function
     Required parameters: email, code
     Optional parameters: nil
     */
    func validateCode(_ completion:@escaping (Int,Any?)->Void){
        postToURL("reset_login/code/verify", parameter: keyValue, authentication: nil) { (status:Int, message:Any?) in
            
//            print(message)
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    /* faeuser change password function
     Required parameters: email, code, password
     Optional parameters: nil
     */
    func changePassword(_ completion:@escaping (Int,Any?)->Void){
        postToURL("reset_login/password", parameter: keyValue, authentication: nil) { (status:Int, message:Any?) in
            
//            print(message)
            if let password = self.keyValue["password"]{
                userPassword = password as? String
                let shareAPI = LocalStorageManager()
                _ = shareAPI.savePassword()
            }
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    /* faeuser get account information function
     Required parameters: nil
     Optional parameters: nil
     */
    func getAccountBasicInfo(_ completion:@escaping (Int,Any?)->Void){
        getFromURL("users/account", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:Any?) in
            self.clearKeyValue()
            if(status/100==2){
                //get successfully
                if let mess = message as? NSDictionary{
                    if (mess["email"]) != nil{
                        if let useremail = mess["email"] as? String{
                            userEmail = useremail
                        }
                        if let emailV = mess["email_verified"] as? Bool{
                            userEmailVerified = emailV
                        }
                        else{
                            userEmailVerified = false
                        }
                        if let userna = mess["user_name"] as? String{
                            username = userna
                        }
                        userFirstname = mess["first_name"] as? String
                        userLastname = mess["last_name"] as? String
                        userGender = mess["gender"] as? Int
                        userBirthday = mess["birthday"] as? String
                        userPhoneNumber = mess["phone"] as? String
                        if let phoneV = mess["phone_verified"] as? Bool {
                            userPhoneVerified = phoneV
                        }
                        else{
                            userPhoneVerified = false
                        }
                        let shareAPI = LocalStorageManager()
                        _ = shareAPI.getAccountStorage()
                    }
                }
                
            }
            completion(status,message);
        }
    }
    
    /* faeuser update account information function
     Required parameters: nil
     Optional parameters: first_name, last_name, user_name, birthday, gender
     */
    func updateAccountBasicInfo(_ completion:@escaping (Int,Any?)->Void){// update local storage
        postToURL("users/account", parameter: keyValue, authentication: headerAuthentication(), completion: {(status: Int, message:Any?) in
            if(status/100 == 2){
                if let firstname = self.keyValue["first_name"]{
                    userFirstname = firstname as? String
                    //                    print("firstName")
                    //                    print(userFirstname)
                }
                if let lastname = self.keyValue["last_name"]{
                    userLastname = lastname as? String
                    //                    print("lastName")
                    //                    print(userLastname)
                }
                if let usernamess = self.keyValue["user_name"]{
                    username = usernamess as? String
                    //                    print("username")
                    //                    print(username)
                }
                if let birthday = self.keyValue["birthday"]{
                    userBirthday = birthday as? String
                    //                    print("birthday")
                    //                    print(userBirthday)
                }
                if let usergender = self.keyValue["gender"]{
                    if usergender as! String == "male" {
                        userGender = 0
                    } else {
                        userGender = 1
                    }
                    //                    print("gender")
                    //                    print(userGender)
                }
                let shareAPI = LocalStorageManager()
                _ = shareAPI.getAccountStorage()
                
            }
            completion(status,message)
            self.clearKeyValue()
        })
    }
    
    
    /* faeuser verify password function
     Required parameters: password
     Optional parameters: nil
     */
    func verifyPassword(_ completion:@escaping (Int,Any?)->Void){
        postToURL("users/account/password/verify", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            completion(status,message)
        }
    }
    
    /* faeuser update password function
     Required parameters: old_password, new_password
     Optional parameters: nil
     */
    func updatePassword(_ completion:@escaping (Int,Any?)->Void){
        postToURL("users/account/password", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            if(status/100==2){
                //changed successfully
                if let newPassword = self.keyValue["new_password"]{
                    userPassword = newPassword as! String
                    let shareAPI = LocalStorageManager()
                    _ = shareAPI.savePassword()
                }
            }
            completion(status,message)
        }
    }
    
    
    
    
    /* faeuser update email function
     Required parameters: email
     Optional parameters: nil
     */
    func updateEmail(_ completion:@escaping (Int,Any?)->Void){
        postToURL("users/account/email", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            completion(status,message)
        }
    }
    
    /* faeuser verify email function
     Required parameters: email, code
     Optional parameters: nil
     */
    func verifyEmail(_ completion:@escaping (Int,Any?)->Void){
        print(headerAuthentication())
        postToURL("users/account/email/verify", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            if(status/100==2){
                
                if let newEmail = self.keyValue["email"]{
                    userEmail = newEmail as! String
                    let shareAPI = LocalStorageManager()
                    _ = shareAPI.saveEmail()
                    print("new email")
                    print(userEmail)
                }
            }
            completion(status,message)
        }
    }
    
    /* faeuser update phone number function
     Required parameters: phone
     Optional parameters: nil
     */
    func updatePhoneNumber(_ completion:@escaping (Int,Any?)->Void){
        postToURL("users/account/phone", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            completion(status,message)
        }
    }
    
    
    /* faeuser verify phone number function
     Required parameters: phone, code
     Optional parameters: nil
     */
    func verifyPhoneNumber(_ completion:@escaping (Int,Any?)->Void){
        postToURL("users/account/phone/verify", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            if(status/100==2){
                if let newPhoneNumber = self.keyValue["phone"]{
                    userPhoneNumber = newPhoneNumber as? String
                    let shareAPI = LocalStorageManager()
                    _ = shareAPI.savePhoneNumber()
                    print("new phone number")
//                    print(userPhoneNumber)
                }
            }
            completion(status,message)
        }
    }
    
    func getSelfProfile(_ completion:@escaping (Int,Any?)->Void){
        getFromURL("users/profile", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:Any?) in
            //print(self.keyValue)
            //self.clearKeyValue()
            //print(message)
            completion(status,message);
        }
    }
    
    func getOthersProfile(_ otherUser:String, completion:@escaping (Int,Any?)->Void){
        getFromURL("users/"+otherUser+"/profile", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:Any?) in
            //self.clearKeyValue()
            completion(status, message);
        }
    }
    
    func updateProfile(_ completion:@escaping (Int, Any?) -> Void){
        postToURL("/users/profile", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            //self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getNamecardOfSpecificUser(_ otherUser: String, completion:@escaping (Int, Any?) -> Void){
        getFromURL("users/"+otherUser+"/name_card", parameter: keyValue, authentication: headerAuthentication()){ (status:Int, message:Any?) in
            completion(status, message);
        }
    }
    
    func getSelfNamecard(_ completion:@escaping (Int, Any?) -> Void){
        getFromURL("users/name_card", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:Any?) in
            completion(status, message);
        }
    }

    func updateNameCard(_ completion:@escaping (Int,Any?)->Void){
        postToURL("/users/name_card", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            //self.clearKeyValue()
            completion(status,message)
        }
    }

    
    
    func getAllTags(_ completion:@escaping (Int,Any?)->Void){
        getFromURL("users/name_card/tags", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:Any?) in
            completion(status,message);
        }
    }

    
    func getSelfStatus(_ completion:@escaping (Int,Any?)->Void){//解包 //local storage
        getFromURL("users/status", parameter: nil, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            completion(status,message)
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
        postToURL("users/status", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            completion(status,message)
        }
    }
    
    
    func getSynchronization(_ completion:@escaping (Int,Any?)->Void){
        getFromURL("sync", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:Any?) in
            completion(status,message)
        }
    }
  
}
