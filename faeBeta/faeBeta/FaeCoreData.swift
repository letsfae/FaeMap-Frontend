//
//  FaeCoreData.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FaeCoreData: NSObject {
    
    static let shared = FaeCoreData()
    
    fileprivate let defaults = UserDefaults.standard
    
    func save(_ key: String, value: Any) {
        defaults.set(value, forKey: key)
    }
    
    func removeByKey(_ key: String) {
        defaults.removeObject(forKey: key)
    }
    func readByKey(_ key: String) -> AnyObject? {
        //        return self.defaults.objectForKey(key)?
        if let obj = self.defaults.object(forKey: key) {
            return obj as AnyObject?
        }
        return nil
    }
    func saveUsername() -> Bool {
        if Key.shared.username != "" {
            save("username", value: Key.shared.username)
            return true
        }
        return false
    }
    func readUsername() -> Bool {
        if Key.shared.username == "" {
            if let usernames = readByKey("username") {
                Key.shared.username = usernames as! String
                return true
            }
            // should we need to read from internet
            return false
        }
        return true
    }
    func saveEmail() {
        save("userEmail", value: Key.shared.userEmail)
    }
    func readEmail() -> Bool {
        if Key.shared.userEmail == "" {
            if let useremail = readByKey("userEmail") {
                Key.shared.userEmail = useremail as! String
                return true
            }
            // should we need to read from internet
            return false
        }
        return true
    }
    func savePhoneNumber() -> Bool {
        if Key.shared.userPhoneNumber != nil {
            save("userPhoneNumber", value: Key.shared.userPhoneNumber!)
            return true
        }
        return false
    }
    func readPhoneNumber() -> Bool {
        if Key.shared.userPhoneNumber == nil {
            if let userephonenumber = readByKey("userPhoneNumber") {
                Key.shared.userPhoneNumber = userephonenumber as? String
                return true
            }
            // should we need to read from internet
            return false
        }
        return true
    }
    
    func savePassword() -> Bool {
        if Key.shared.userPassword != "" {
            save("userPassword", value: Key.shared.userPassword)
            return true
        }
        return false
    }
    func readPassword() -> Bool {
        if Key.shared.userPassword == "" {
            if let userpassword = readByKey("userPassword") {
                Key.shared.userPassword = userpassword as! String
                return true
            }
            // should we need to read from internet
            return false
        }
        return true
    }
    func logInStorage() {
        save("userToken", value: Key.shared.userToken)
        save("userTokenEncode", value: Key.shared.userTokenEncode)
        save("session_id", value: Key.shared.session_id)
        save("user_id", value: Key.shared.user_id)
        save("is_Login", value: Key.shared.is_Login)
        save("userEmail", value: Key.shared.userEmail)
        save("userPassword", value: Key.shared.userPassword)
    }
    
    func getAccountStorage() {
        save("userEmail", value: Key.shared.userEmail)
        save("username", value: Key.shared.username)
        save("userNickname", value: Key.shared.nickname)
        save("userFirstname", value: Key.shared.userFirstname)
        save("userLastname", value: Key.shared.userLastname)
        save("userBirthday", value: Key.shared.userBirthday)
        save("userGender", value: Key.shared.userGender)
    }
    
    func readLogInfo() {
        _ = readUsername()
        Key.shared.headerUserAgent = UIDevice.current.modelName + " " + UIDevice.current.systemVersion
        print("model:", Key.shared.headerUserAgent)
        if Key.shared.is_Login {
            return
        }
        if let login = readByKey("is_Login") as? Int {
            if login == 0 {
                return
            } else {
                Key.shared.userToken = readByKey("userToken") as! String
                Key.shared.userTokenEncode = readByKey("userTokenEncode") as! String
                Key.shared.session_id = readByKey("session_id") as! Int
                Key.shared.user_id = readByKey("user_id") as! Int
//                Key.shared.is_Login = readByKey("is_Login") as! Bool
                Key.shared.userEmail = readByKey("userEmail") as! String
                Key.shared.nickname = readByKey("userNickname") as! String
                Key.shared.userPassword = readByKey("userPassword") as! String
                Key.shared.userFirstname = readByKey("userFirstname") as! String
                Key.shared.userLastname = readByKey("userLastname") as! String
                Key.shared.userBirthday = readByKey("userBirthday") as! String
                Key.shared.userGender = readByKey("userGender") as! Int
                if readByKey("userMiniAvatar") != nil {
                    Key.shared.userMiniAvatar = readByKey("userMiniAvatar") as! Int
                }
                if let autoRefresh = readByKey("autoRefresh") as? Bool {
                    Key.shared.autoRefresh = autoRefresh
                } else {
                    Key.shared.autoRefresh = true
                }
                if let autoCycle = readByKey("autoCycle") as? Bool {
                    Key.shared.autoCycle = autoCycle
                } else {
                    Key.shared.autoCycle = true
                }
                if let hideAvatars = readByKey("hideAvatars") as? Bool {
                    Key.shared.hideAvatars = hideAvatars
                } else {
                    Key.shared.hideAvatars = false
                }
                if let emailSubscribed = readByKey("emailSubscribed") as? Bool {
                    Key.shared.emailSubscribed = emailSubscribed
                } else {
                    Key.shared.emailSubscribed = true
                }
                if let showNameCardOption = readByKey("showNameCardOption") as? Bool {
                    Key.shared.showNameCardOption = showNameCardOption
                } else {
                    Key.shared.showNameCardOption = true
                }
                if let measurementUnits = readByKey("measurementUnits") as? String {
                    Key.shared.measurementUnits = measurementUnits
                } else {
                    Key.shared.measurementUnits = "imperial"
                }
                if let shadowLocationEffect = readByKey("shadowLocationEffect") as? String {
                    Key.shared.shadowLocationEffect = shadowLocationEffect
                } else {
                    Key.shared.shadowLocationEffect = "normal"
                }
            }
        }
    }
    func isFirstPushLaunch() -> Bool {
        let firstLaunchFlag = "FirstPushLaunchFlag"
        let isFirstLaunch = UserDefaults.standard.string(forKey: firstLaunchFlag) == nil
        if isFirstLaunch {
            UserDefaults.standard.set("false", forKey: firstLaunchFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
