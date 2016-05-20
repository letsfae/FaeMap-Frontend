//
//  FaeUser.swift
//  faeBeta
//
//  Created by blesssecret on 5/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
// after login all the information will be store in here.
class FaeUser : FaeObject {
    var isLogin : Bool!
    var userToken : String!
    var userEmail : String!//require
    var userPassword : String!//require
    var firstName : String!
    var lastName  : String!
    var gender : String!
//    func signUpInBackground(status: Int , message:String)->()->Void{
//        
//    }
    
//    func logInWithEmail(status: Int , message:String)
    func emailVerificationCode(status: Int , message:String)->()->Void{
        
    }
//    func resetPassword()
    func logOut(){//clear the login token is enough
        
    }
}