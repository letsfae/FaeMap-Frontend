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
    func whereKey(key:String, value:String)->Void{
        keyValue[key]=value
    }
    func whereKeyInt(key:String, value:Int)->Void{
        keyValue[key]=value
    }
    func clearKeyValue()->Void{
        self.keyValue = [String:AnyObject]()
    }
    
    /* faeuser sign up function
     Required parameters: password, email, user_name, first_name, last_name, birthday, gender
     Optional parameters: nil
     */
    func signUpInBackground(completion:(Int,AnyObject?)->Void){
        postToURL("users", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
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
    
    func logInBackground(completion:(Int,AnyObject?)->Void){
        postToURL("authentication", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            if(status / 100 == 2 ){//success
                self.processToken(message!)
                self.getSelfProfile{(status:Int, message:AnyObject?) in
                    if message != nil{
                        if (message!["email"]) != nil{
                            //userEmail
                            userEmail = message!["email"] as? String
                            username = message!["user_name"] as? String
                            userFirstname = message!["first_name"] as? String
                            userLastname = message!["last_name"] as? String
                            userGender = message!["gender"] as? Int
                            userBirthday = message!["birthday"] as? String
                            userPhoneNumber = message!["phone"] as? String
                            let shareAPI = LocalStorageManager()
                            shareAPI.getAccountStorage()
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
            postToURL("chats", parameter: ["receiver_id": "1", "message": "Hi there, I just registered. Let's chat!", "type": "text"], authentication: headerAuthentication(), completion: { (statusCode, result) in
            })
        }
    }
    
    // process return information after logging in
    func processToken(message:AnyObject)->Void{
        let str = message["token"] as! String
        let session = message["session_id"] as! NSNumber
        let user = message["user_id"] as! NSNumber
        let authentication = user.stringValue+":"+str+":"+session.stringValue
        session_id = session
        user_id = user
        
        let utf8str = authentication.dataUsingEncoding(NSUTF8StringEncoding)
        print(authentication)
        let base64Encoded = utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        print("Encoded:  \(base64Encoded)")
        print("FAE "+base64Encoded)
        let encode = "FAE "+base64Encoded
        userToken = str
        userTokenEncode = encode
        is_Login = 1
        userEmail = keyValue["email"] != nil ? keyValue["email"] as! String : ""
        userPassword = keyValue["password"] as! String
        
        let shareAPI = LocalStorageManager()
        shareAPI.logInStorage()
    }
    
    
    /* faeuser log out function
     Required parameters: nil
     Optional parameters: nil
     */
    func logOut(completion:(Int,AnyObject?)->Void){//clear the login token is enough
        let headerToken = headerAuthentication()//this code may set is_Login to 1
        self.clearLogInInfo()
        deleteFromURL("authentication", parameter: [:], authentication: headerToken ) { (status:Int, message:AnyObject?) in
            
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
    func checkEmailExistence(completion:(Int,AnyObject?)->Void){
        if let email = keyValue["email"] as? String{
            getFromURL("existence/email/"+email, parameter:keyValue, authentication: nil){ (status:Int, message:AnyObject?) in
                //self.clearKeyValue()
                completion(status,message);
            }
        }
    }
    
    /* faeuser check username exist function
     Required parameters: username
     Optional parameters: nil
     */
    func checkUserExistence(completion:(Int,AnyObject?)->Void){
        if let username = keyValue["user_name"] as? String{
            getFromURL("existence/user_name/"+username, parameter:keyValue, authentication: nil){ (status:Int, message:AnyObject?) in
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
    func sendCodeToEmail(completion:(Int,AnyObject?)->Void){
        postToURL("reset_login/code", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            print(message)
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    /* faeuser verify code sent to email function
     Required parameters: email, code
     Optional parameters: nil
     */
    func validateCode(completion:(Int,AnyObject?)->Void){
        postToURL("reset_login/code/verify", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            
            print(message)
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    /* faeuser change password function
     Required parameters: email, code, password
     Optional parameters: nil
     */
    func changePassword(completion:(Int,AnyObject?)->Void){
        postToURL("reset_login/password", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            
            print(message)
            if let password = self.keyValue["password"]{
                userPassword = password as? String
                let shareAPI = LocalStorageManager()
                shareAPI.savePassword()
            }
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    /* faeuser get account information function
     Required parameters: nil
     Optional parameters: nil
     */
    func getAccountBasicInfo(completion:(Int,AnyObject?)->Void){
        getFromURL("users/account", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:AnyObject?) in
            self.clearKeyValue()
            if(status/100==2){
                //get successfully
                print(message!)
                let mess = message!
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
                    shareAPI.getAccountStorage()
                }
                
            }
            completion(status,message);
        }
    }
    
    /* faeuser update account information function
     Required parameters: nil
     Optional parameters: first_name, last_name, user_name, birthday, gender
     */
    func updateAccountBasicInfo(completion:(Int,AnyObject?)->Void){// update local storage
        postToURL("users/account", parameter: keyValue, authentication: headerAuthentication(), completion: {(status: Int, message:AnyObject?) in
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
                shareAPI.getAccountStorage()
                
            }
            completion(status,message)
            self.clearKeyValue()
        })
    }
    
    
    /* faeuser verify password function
     Required parameters: password
     Optional parameters: nil
     */
    func verifyPassword(completion:(Int,AnyObject?)->Void){
        postToURL("users/account/password/verify", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            completion(status,message)
        }
    }
    
    /* faeuser update password function
     Required parameters: old_password, new_password
     Optional parameters: nil
     */
    func updatePassword(completion:(Int,AnyObject?)->Void){
        postToURL("users/account/password", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            if(status/100==2){
                //changed successfully
                if let newPassword = self.keyValue["new_password"]{
                    userPassword = newPassword as! String
                    let shareAPI = LocalStorageManager()
                    shareAPI.savePassword()
                }
            }
            completion(status,message)
        }
    }
    
    
    
    
    /* faeuser update email function
     Required parameters: email
     Optional parameters: nil
     */
    func updateEmail(completion:(Int,AnyObject?)->Void){
        postToURL("users/account/email", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            completion(status,message)
        }
    }
    
    /* faeuser verify email function
     Required parameters: email, code
     Optional parameters: nil
     */
    func verifyEmail(completion:(Int,AnyObject?)->Void){
        print(headerAuthentication())
        postToURL("users/account/email/verify", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            if(status/100==2){
                
                if let newEmail = self.keyValue["email"]{
                    userEmail = newEmail as! String
                    let shareAPI = LocalStorageManager()
                    shareAPI.saveEmail()
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
    func updatePhoneNumber(completion:(Int,AnyObject?)->Void){
        postToURL("users/account/phone", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            completion(status,message)
        }
    }
    
    
    /* faeuser verify phone number function
     Required parameters: phone, code
     Optional parameters: nil
     */
    func verifyPhoneNumber(completion:(Int,AnyObject?)->Void){
        postToURL("users/account/phone/verify", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            if(status/100==2){
                if let newPhoneNumber = self.keyValue["phone"]{
                    userPhoneNumber = newPhoneNumber as? String
                    let shareAPI = LocalStorageManager()
                    shareAPI.savePhoneNumber()
                    print("new phone number")
                    print(userPhoneNumber)
                }
            }
            completion(status,message)
        }
    }
    
    func getSelfProfile(completion:(Int,AnyObject?)->Void){
        getFromURL("users/profile", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:AnyObject?) in
            //print(self.keyValue)
            //self.clearKeyValue()
            //print(message)
            completion(status,message);
        }
    }
    
    func getOthersProfile(otherUser:String, completion:(Int,AnyObject?)->Void){
        getFromURL("users/"+otherUser+"/profile", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:AnyObject?) in
            //self.clearKeyValue()
            completion(status, message);
        }
    }
    
    func updateProfile(completion:(Int, AnyObject?) -> Void){
        postToURL("/users/profile", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            //self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func getNamecardOfSpecificUser(otherUser: String, completion:(Int, AnyObject?) -> Void){
        getFromURL("users/"+otherUser+"/name_card", parameter: keyValue, authentication: headerAuthentication()){ (status:Int, message:AnyObject?) in
            completion(status, message);
        }
    }
    
    func getSelfNamecard(completion:(Int, AnyObject?) -> Void){
        getFromURL("users/name_card", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:AnyObject?) in
            completion(status, message);
        }
    }

    func updateNameCard(completion:(Int,AnyObject?)->Void){
        postToURL("/users/name_card", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            //self.clearKeyValue()
            completion(status,message)
        }
    }

    
    
    func getAllTags(completion:(Int,AnyObject?)->Void){
        getFromURL("users/name_card/tags", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:AnyObject?) in
            completion(status,message);
        }
    }

    
    func getSelfStatus(completion:(Int,AnyObject?)->Void){//解包 //local storage
        getFromURL("users/status", parameter: nil, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
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
    func setSelfStatus(completion: (Int, AnyObject?) -> Void) {
        /*
         * not working for the commented codes
        if keyValue["status"] != nil {
            userStatus = keyValue["status"] as? Int
            print("DEBUG: user status")
            print(userStatus)
        } else {
            completion(-400, "no status number found")
        }
        if keyValue["message"] != nil {
            userStatusMessage = keyValue["message"] as? String
        } else {
            completion(-400, "no message found")
        }
        */
        postToURL("users/status", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            completion(status,message)
        }
    }
    
    
    func getSynchronization(completion:(Int,AnyObject?)->Void){
        getFromURL("sync", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            completion(status,message)
        }
    }
  
}
