//
//  Verification.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

func emailVerification(_ email : String)-> Bool{
    //should obey the structure of email
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
}
func passwordVerification(_ password:String)->Bool{
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

func passwordDoubleVerification(_ password1 : String, password2 : String)->Bool {
    return password1 == password2
}

func checkSignUp(_ firstName : String ,lastName : String , birthday : Date , gender: String )->Bool{
    return false
}

func checkLogIn(_ email:String , password:String)->Bool{
    return false
}


func timeToString(_ time : Date)->String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    let dateString = dateFormatter.string(from: time)
    //    print(dateString)
    return dateString
}
func stringToTime(_ str : String)->Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    let date = dateFormatter.date(from: str)
    return date!
}
