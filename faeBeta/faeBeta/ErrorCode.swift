//
//  ErrorCode.swift
//  faeBeta
//
//  Created by Yue Shen on 4/3/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

// MARK: - Error Code

enum ErrorType {
    case auth, map, collection, contact, chat, file
}

func handleErrorCode(_ type: ErrorType, _ code: String, _ completion: ((String) -> Void)? = nil, _ subType: String = "") {
    switch type {
    case .auth: //jichao
        switch code {
        case "500": break
        case "422-3": // sign up - email exists
            break
        case "401-1": // login - wrong password
            completion?("That’s not the Correct Password!\nPlease Check your Password!")
        case "401-2": // login - email not exits / not verified
            completion?("Oops… This Email has not\nbeen linked to an Account.")
        case "404-3": // (reset password - ) user not exits
            if subType == "login" {
                completion?("Oops… Can’t find any Accounts\nwith this Username!")
            } else if subType == "resetByPhone" {
                completion?("That isn't the phone number\n you previously verified!")
            }
        /*case "404-3": // verify reset code - user not exists
            break*/
        case "403-4": // verify reset code - timeout
            break
        case "403-5": // verify reset code - wrong code
            completion?("That's an Incorrect Code!\n Please Try Again!")
        case "404-14": // verify reset code - verfication not exists
            break
        case "422-2": // update account - user name already exists
            break
        /*case "403-5": // verify email - wrong code
            break*/
        case "404-15": // name card - not exists
            break
        case "400-3": // get profile - id is not numeric
            break
        case "404-4": // update namecard - tag not exists
            break
        case "400-10": // save namecard - already saved
            break
        case "400-9": // cancel save namecard - not saved
            break
        default: break
        }
    case .map: //joshua
        break
    case .collection: //vicky
        break
    case .contact: //jichao
        break
    case .chat: //jichao
        break
    case .file: //joshua
        break
    }
}
