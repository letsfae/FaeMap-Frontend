//
//  Key.swift
//  faeBeta
//
//  Created by blesssecret on 11/8/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

let faePlaceInfoCache = NSCache<AnyObject, AnyObject>()
let placeInfoBarImageCache = NSCache<AnyObject, AnyObject>()
let faeLocationCache = NSCache<AnyObject, AnyObject>()
let faeLocationInfoCache = NSCache<AnyObject, AnyObject>()

enum NavOpenMode {
    case mapFirst
    case welcomeFirst
}

enum ServerType {
    case development
    case production
}

enum ContentType {
    case json
    case data
    case normal
}

class Key: NSObject { //  singleton class
    
    static let shared = Key()
    
    // change this to .production to switch to production mode
    private let server = ServerType.development
    
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
    
    // MARK: - Settings -> My Information
    var hideNameCardOptions: Bool = false
    var disableGender: Bool = false
    var disableAge: Bool = false
    
    // MARK: - API Authorizations
    
    // guest
    var userTokenEncode_guest = ""
    var is_guest: Bool = false
    
    // none-guest
    var userToken = ""
    var userTokenEncode = ""
    var session_id: Int = -1
    var user_id: Int = -1 {
        didSet {
            self.getUserInfo()
        }
    }
    
    func isFirstUse() -> Bool {
        return Key.shared.userTokenEncode == ""
    }
    var is_Login: Bool = false
    var fully_login: Bool = false
    
    // MARK: - User Personal Info
    var userEmail = ""
    var userPassword = ""
    var navOpenMode: NavOpenMode = .mapFirst
    
    var username: String = ""
    var nickname: String = ""
    var introduction: String = ""
    var age: String = ""
    
    var onlineStatus: Int = -1
    
    var userFirstname: String = ""
    var userLastname: String = ""
    var userBirthday: String = "" // yyyy-MM-dd
    var userGender: Int = -1 // 0 means male 1 means female
    var gender: String = "male"
    var userMiniAvatar: Int = 0
    var userPhoneNumber: String?
    
    var userEmailVerified: Bool = false
    var userPhoneVerified: Bool = false
    
    var miniAvatar = "miniAvatar_1" // new var by Yue Shen
    
    let defaultCover = UIImage(named: "defaultCover")
    let defaultMale = UIImage(named: "defaultMen")
    let defaultFemale = UIImage(named: "defaultWomen")
    let faeAvatar = UIImage(named: "faeAvatar")
    let defaultPlace = UIImage(named: "default_place")
    
    // MARK: - Location Seaerch
    var selectedLoc: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var selectedLoc_map: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var selectedLoc_board: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var selectedSearchedCity_map: String?
    var selectedSearchedCity_board: String?
    var selectedSearchedCity_chat: String?
    
    // MARK: - Temporary Variables
    var initialCtrler: InitialPageController?
    var FMVCtrler: FaeMapViewController?
    var mapHeadTitle: String = ""
    var selectedTypeIdx_explore: IndexPath = IndexPath(row: 0, section: 0) // Explore
    var lastCategory_explore: String = "Random" // Explore
    var lastChosenLoc: CLLocationCoordinate2D?
    
    // MARK: - Map Search
    var radius_map: Int = 0
    var searchContent_map: String = ""
    var searchSource_map: String = ""
    
    var radius_chat: Int = 0
    var searchContent_chat: String = ""
    var searchSource_chat: String = ""
    
    var radius_board: Int = 0
    var searchContent_board: String = ""
    var searchSource_board: String = ""
    
    func getUserInfo() {
        getGenderAge()
    }
    
    func getGenderAge() {
        guard Key.shared.user_id > 0 else { return }
        FaeUser.shared.getUserCard("\(Key.shared.user_id)") { (status, message) in
            DispatchQueue.main.async(execute: {
                guard status / 100 == 2 else { return }
                guard let unwrapMessage = message else {
                    print("[getUserCard] message is nil")
                    return
                }
                let profileInfo = JSON(unwrapMessage)
                Key.shared.disableGender = !profileInfo["show_gender"].boolValue
                Key.shared.gender = profileInfo["gender"].stringValue
                Key.shared.disableAge = !profileInfo["show_age"].boolValue
                Key.shared.age = profileInfo["age"].stringValue
            })
        }
    }
    
    // MARK: - User Settings
    var autoRefresh: Bool = true
    var autoCycle: Bool = true
    var hideAvatars: Bool = false
    
    var emailSubscribed: Bool = true
    var showNameCardOption: Bool = true
    var measurementUnits: String = "imperial" // metric
    var shadowLocationEffect: String = "normal" // min, max
    var otherSettings: String = ""
    
    // MARK: - API Fetching Headers
    var version = "x.faeapp.v1"
    var headerAccept = "application/x.faeapp.v1+json"
    var headerContentType = "application/x-www-form-urlencoded"
    let headerClientVersion = "fae-ios-1.0.0"
    var headerDeviceID = ""
    var headerUserAgent = "iPhone"
    
    func header(auth: Bool, type: ContentType) -> [String: String] {
        var header = [
            "User-Agent": Key.shared.headerUserAgent,
            "Fae-Client-Version": Key.shared.headerClientVersion,
            "Device-ID" : Key.shared.headerDeviceID,
            "Accept": Key.shared.headerAccept,
        ]
        if auth {
            if Key.shared.is_guest {
                header["Authorization"] = Key.shared.userTokenEncode_guest
            } else {
                if Key.shared.userTokenEncode != "" {
                    header["Authorization"] = Key.shared.userTokenEncode
                }
                else if Key.shared.is_Login && Key.shared.userTokenEncode != "" {
                    header["Authorization"] = Key.shared.userTokenEncode
                }
                else if let encode = FaeCoreData.shared.readByKey("userTokenEncode") as? String {
                    Key.shared.userTokenEncode = encode
                    header["Authorization"] = Key.shared.userTokenEncode
                }
            }
        }
        switch type {
        case .normal:
            header["Content-Type"] = "application/x-www-form-urlencoded"
        case .data:
            header["Content-Type"] = "application/form-data"
        case .json:
            header["Content-Type"] = "application/json"
        }
        return header
    }
    
    func headerAuthentication() -> [String: String] {
        if Key.shared.userTokenEncode != "" {
            return ["Authorization": Key.shared.userTokenEncode]
        }
        if Key.shared.is_Login && Key.shared.userTokenEncode != "" {
            return ["Authorization": Key.shared.userTokenEncode]
        }
        if let encode = FaeCoreData.shared.readByKey("userTokenEncode") as? String {
            Key.shared.userTokenEncode = encode
            return ["Authorization": Key.shared.userTokenEncode]
        }
        return [:]
    }
}
