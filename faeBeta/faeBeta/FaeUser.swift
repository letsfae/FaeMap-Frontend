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
 let utf8str = str.dataUsingEncoding(NSUTF8StringEncoding)
 
 // Base64 encode UTF 8 string
 // fromRaw(0) is equivalent to objc 'base64EncodedStringWithOptions:0'
 // Notice the unwrapping given the NSData! optional
 // NSString! returned (optional)
 let base64Encoded = utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
 print("Encoded:  \(base64Encoded)")
 print("FAE "+base64Encoded)
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
    func clearKeyValue()->Void{
        self.keyValue = [String:AnyObject]()
    }
    func checkEmailExistence(completion:(Int,AnyObject?)->Void){
        if let email = keyValue["email"] as? String{
            getFromURL("existence/email/"+email, parameter:keyValue, authentication: nil){ (status:Int, message:AnyObject?) in
                //print(self.keyValue)
                //                print("message")
                //                print(message)
                self.clearKeyValue()
                completion(status,message);
            }
        }
    }
    
    //MARK: This hasn't been tested
    func checkUserExistence(completion:(Int,AnyObject?)->Void){
        if let username = keyValue["username"] as? String{
            getFromURL("existence/email/"+username, parameter:keyValue, authentication: nil){ (status:Int, message:AnyObject?) in
                //print(self.keyValue)
                //                print("message")
                //                print(message)
                self.clearKeyValue()
                completion(status,message);
            }
        }
    }
    func saveAvatarInBackGround(completion:(Int,AnyObject?)->Void){
        
    }
    func signUpInBackground(completion:(Int,AnyObject?)->Void){
        //verfy keyValue[String:AnyObject]
        /*
         postToURL("users", keyValue: keyValue) { (status:Int?, message:String) in
         completion(status,message)
         self.clearKeyValue()
         }*/
        postToURL("users", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            if(status / 100 == 2 ) {
                //success
            }
            else{
                //fail
            }
            self.clearKeyValue()
            completion(status,message);
        }
    }
    func logInBackground(completion:(Int,AnyObject?)->Void){
        postToURL("authentication", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            print(status)
            print(message)
            if(status / 100 == 2 ){//success
                self.processToken(message!)
            }
            else{//failure
                
            }
            self.clearKeyValue()
            completion(status,message)
        }
    }
    /*{
     "session_id" = 5;
     token = YlCxL08K2ClsD7AeOpfV6SsF05yK2N;
     "user_id" = 10;
     }*/
    func processToken(message:AnyObject)->Void{
        // UTF 8 str from original
        // NSData! type returned (optional)
        let str = message["token"] as! String
        let session = message["session_id"] as! NSNumber
        let user = message["user_id"] as! NSNumber
        let authentication = user.stringValue+":"+str+":"+session.stringValue
        session_id = session
        user_id = user
        
        let utf8str = authentication.dataUsingEncoding(NSUTF8StringEncoding)
        print(authentication)
        // Base64 encode UTF 8 string
        // fromRaw(0) is equivalent to objc 'base64EncodedStringWithOptions:0'
        // Notice the unwrapping given the NSData! optional
        // NSString! returned (optional)
        let base64Encoded = utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        print("Encoded:  \(base64Encoded)")
        print("FAE "+base64Encoded)
        let encode = "FAE "+base64Encoded
        userToken = str
        userTokenEncode = encode
        is_Login = 1
        userEmail = keyValue["email"] as! String
        userPassword = keyValue["password"] as! String
        
        let shareAPI = LocalStorageManager()
        shareAPI.logInStorage()
        //        logOut()
        //        shareAPI.readLogInfo()
        //        logOut()
    }
    //    func signUpInBackground(status: Int , message:String)->()->Void{
    //
    //    }
    
    //    func logInWithEmail(status: Int , message:String)
    //    func emailVerificationCode(status: Int , message:String)->()->Void{
    //
    //    }
    //    func resetPassword()
    func logOut(){//clear the login token is enough
        
        let headerToken = headerAuthentication()//this code may set is_Login to 1
        userToken = ""
        userTokenEncode = ""
        session_id = -1
        user_id = -1
        is_Login = 0
        let shareAPI = LocalStorageManager()
        shareAPI.saveInt("is_Login", value: 0)
        deleteFromURL("authentication", parameter: [:], authentication: headerToken ) { (status:Int, message:AnyObject?) in
            if status / 100 == 2 {
                //success
            }
            else {
                
            }
            self.clearKeyValue()
        }
    }
    
    //Profile
    func getSelfProfile(completion:(Int,AnyObject?)->Void){
        getFromURL("users/profile", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:AnyObject?) in
            //print(self.keyValue)
            self.clearKeyValue()
            completion(status,message);
        }
    }
    
    func getOthersProfile(otherUser:String, completion:(Int,AnyObject?)->Void){
        getFromURL("users/"+otherUser+"/profile", parameter:keyValue, authentication: headerAuthentication()){ (status:Int, message:AnyObject?) in
            self.clearKeyValue()
            completion(status,message);
        }
    }
    
    func updateProfile(completion:(Int,AnyObject?)->Void){
        postToURL("/users/profile", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message:AnyObject?) in
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    
    
    
    // Change password
    func sendCodeToEmail(completion:(Int,AnyObject?)->Void){
        postToURL("reset_login/code", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            
            print(message)
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    func validateCode(completion:(Int,AnyObject?)->Void){
        putToURL("reset_login/code", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            
            print(message)
            self.clearKeyValue()
            completion(status,message)
        }
    }
    
    func changePassword(completion:(Int,AnyObject?)->Void){
        postToURL("reset_login/password", parameter: keyValue, authentication: nil) { (status:Int, message:AnyObject?) in
            
            print(message)
            self.clearKeyValue()
            completion(status,message)
        }
    }
    /*
    func getSelfStatus(completion:(Int,AnyObject?)->Void){
        getFromURL("users/status", parameter: <#T##[String : AnyObject]?#>, authentication: <#T##[String : AnyObject]?#>, completion: <#T##(Int, AnyObject?) -> Void#>)
    }*/
    
    
        
    
    
    
    
}
