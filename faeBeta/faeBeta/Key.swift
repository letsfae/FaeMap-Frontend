//
//  Key.swift
//  faeBeta
//
//  Created by blesssecret on 11/8/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

enum NavOpenMode {
    case mapFirst
    case welcomeFirst
}

class Key: NSObject { //  singleton class
    
    static let shared = Key()
    
    var joshDebug: Bool = true
    var vickyDebug: Bool = false
    var felixDebug: Bool = false
    
    private enum SERVERTYPE {
        case development
        case production
    }
    
    // change this to .production to switch to production mode
    private let server = SERVERTYPE.development
    
    var baseURL: String {
        get {
            return server == .development ? "https://dev.letsfae.com" : "https://api.letsfae.com"
        }
    }
    
    var fireBaseRef: String {
        get {
            return server == .development ? "Message-dev" : "Message-prod"
        }
    }
    
    let GoogleMapKey = "AIzaSyC7Wxy8L4VFaTdzC7vbD43ozVO_yUw4DTk"
    
    var hideNameCardOptions: Bool = false
    var disableGender: Bool = false
    var disableAge: Bool = false
    
    var version = "x.faeapp.v1"
    var headerAccept = "application/x.faeapp.v1+json"
    var headerContentType = "application/x-www-form-urlencoded"
    let headerClientVersion = "fae-ios-1.0.0"
    var headerDeviceID = ""
    var headerUserAgent = "iPhone"
    
    var userToken = ""
    var userTokenEncode = ""
    var session_id: Int = -1
    var user_id: Int = -1 {
        didSet {
            self.getUserInfo()
        }
    }
    var is_Login: Int = 0
    var userEmail = ""
    var userPassword = ""
    var navOpenMode: NavOpenMode = .mapFirst
    
    var username: String = ""
    var nickname: String?
    var shortIntro: String = ""
    var showGender = false
    var showAge = false
    var userAge: String = ""
    
    var userStatus: Int = -1
    
    var userFirstname: String = ""
    var userLastname: String = ""
    var userBirthday: String = "" // yyyy-MM-dd
    var userGender: Int = -1 // 0 means male 1 means female
    var gender: String = "male"
    var userMiniAvatar: Int = 0
    var userPhoneNumber: String?
    
    var userEmailVerified: Bool = false
    var userPhoneVerified: Bool = false
    
    var userAvatarMap = "miniAvatar_1" // new var by Yue Shen
    
    var arrayNameCard = [Int: UIImage]()
    
    let imageDefaultCover = UIImage(named: "defaultCover")
    let imageDefaultMale = UIImage(named: "defaultMen")
    let imageDefaultFemale = UIImage(named: "defaultWomen")
    let imageFaeAvatar = UIImage(named: "faeAvatar")
    
    var dblAltitude: Double = 500
    var selectedLoc: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    func getUserInfo() {
        getGenderAge()
    }
    
    func getGenderAge() {
        guard Key.shared.user_id > 0 else { return }
        let userNameCard = FaeUser()
        userNameCard.getUserCard("\(Key.shared.user_id)") { (status: Int, message: Any?) in
            DispatchQueue.main.async(execute: {
                guard status / 100 == 2 else { return }
                guard let unwrapMessage = message else {
                    print("[getUserCard] message is nil")
                    return
                }
                let profileInfo = JSON(unwrapMessage)
                Key.shared.disableGender = !profileInfo["show_gender"].boolValue
                Key.shared.gender = profileInfo["gender"].stringValue
                Key.shared.disableAge = profileInfo["show_age"].boolValue
                Key.shared.userAge = profileInfo["age"].stringValue
                joshprint("[getGenderAge] age gender updated")
            })
        }
    }
}
