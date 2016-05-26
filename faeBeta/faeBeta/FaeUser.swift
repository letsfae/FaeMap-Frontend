//
//  FaeUser.swift
//  faeBeta
//
//  Created by blesssecret on 5/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
// after login all the information will be store in here.
class FaeUser : NSObject {
    var isLogin : Bool!
    var userToken : String!
    var userEmail : String!//require
    var userPassword : String!//require
    var firstName : String!
    var lastName  : String!
    var gender : String!
    
    var keyValue = [String:AnyObject]()
    
    func whereKey(key:String, value:String)->Void{
        keyValue[key]=value
    }
    func clearKeyValue()->Void{
        self.keyValue = [String:AnyObject]()
    }
    func signUpInBackground(completion:(Int?,String?)->Void){
        //verfy keyValue[String:AnyObject]
        postToURL("users", keyValue: keyValue) { (status:Int?, message:String) in
            print("signUp")
            print(status)
            print(message)
            completion(status,message)
            self.clearKeyValue()
        }
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
        userToken = ""
        isLogin = false
    }
}