//
//  Verification.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

func emailVerification(email : String)-> Bool{
    //should obey the structure of email
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluateWithObject(email)
}
func passwordVerification(password:String)->Bool{
    //the rules of password，规则太复杂
    var uppercase = 0
    var symbol = 0
    var digit = 0
    for i in password.characters {
        if(i <= "9" && i >= "0") {
            digit = 1
        } else if (i <= "z" && i >= "a") {
            
        } else if (i <= "Z" && i >= "A") {
            uppercase = 1
        } else {
            symbol = 1
        }
        if(uppercase + digit + symbol >= 2)  {
            return true
        }
    }
    return false
}

func passwordDoubleVerification(password1 : String, password2 : String)->Bool {
    return password1 == password2
}

func checkSignUp(firstName : String ,lastName : String , birthday : NSDate , gender: String )->Bool{
    return false
}

func checkLogIn(email:String , password:String)->Bool{
    return false
}


func timeToString(time : NSDate)->String {
    return "null"
}
