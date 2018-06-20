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
let favCategoryCache = NSCache<AnyObject, AnyObject>()
var catDict = [String : Int]()

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
    
    var joshDebug: Bool = true
    var vickyDebug: Bool = false
    var felixDebug: Bool = false
    
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
    
    // MARK: - Location Seaerch
    var selectedLoc: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var selectedLoc_map: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var selectedLoc_board: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var selectedSearchedCity: String?
    
    // MARK: - Temporary Variables
    var initialCtrler: InitialPageController?
    var FMVCtrler: FaeMapViewController?
    var mapHeadTitle: String = ""
    var selectedTypeIdx: IndexPath = IndexPath(row: 0, section: 0) // Explore
    var lastCategory: String = "Random" // Explore
    var lastChosenLoc: CLLocationCoordinate2D?
    
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
    
    var categories: [String: Int] = ["Concert Hall": 25, "Arcade": 26, "Museum": 27, "Art Museum": 34, "Science Museum": 86, "Performing Arts Venue": 28, "Indie Theater": 28, "Theater": 28, "Music Venue": 68, "Art Gallery": 34, "Baseball Stadium": 60, "Rock Club": 80, "Bars": 14, "Wine Bar": 2, "Sake Bar": 79, "Dive Bar": 14, "Sports Bar": 14, "Beer Bar": 14, "Gastropub": 14, "Irish Pub": 14, "Hookah Bar": 85, "Whisky Bar": 14, "Cocktail Bar": 14, "Hotel Bar": 14, "Beer Garden": 20, "Speakeasy": 14, "Restaurant": 5, "Italian Restaurant": 3, "French Restaurant": 5, "Korean Restaurant": 5, "Seafood Restaurant": 24, "Middle Eastern Restaurant": 5, "Japanese Restaurant": 10, "Sushi Restaurant": 10, "Southern / Soul Food Restaurant": 5, "Filipino Restaurant": 5, "Kosher Restaurant": 5, "South American Restaurant": 5, "Vegetarian / Vegan Restaurant": 78, "Halal Restaurant": 5, "Caribbean Restaurant": 5, "New American Restaurant": 5, "Peruvian Restaurant": 5, "Cajun / Creole Restaurant": 5, "Asian Restaurant": 5, "Chinese Restaurant": 48, "Falafel Restaurant": 5, "Ethiopian Restaurant": 5, "Latin American Restaurant": 5, "Mexican Restaurant": 5, "Thai Restaurant": 5, "Fast Food": 69, "Mediterranean Restaurant": 5, "Indonesian Restaurant": 5, "Vietnamese Restaurant": 5, "Ramen": 45, "American Restaurant": 5, "Hawaiian Restaurant": 5, "Brewery": 77, "Sandwich Place": 55, "Food Court": 5, "Snack Place": 5, "Burrito Place": 71, "Steakhouse": 36, "Buffet": 5, "Bagel Shop": 12, "Hot Dog Joint": 17, "Ice Cream Shop": 16, "Bakery": 13, "Salad Place": 74, "Coffee Shop": 19, "Donut Shop": 12, "Street Food Gathering": 39, "Food Truck": 39, "Burger Joint": 40, "Fried Chicken Joint": 89, "Frozen Yogurt Shop": 43, "Noodle House": 45, "Breakfast": 51, "Dessert Shop": 53, "Deli / Bodega": 55, "Dinner": 5, "Pizza Place": 57, "Taco Place": 83, "Juice Bar": 67, "BBQ Joint": 64, "Athletics & Sports": 1, "Gyms / Fitness Center": 6, "Gyms": 6, "Climbing Gym": 6, "Cycle Studio": 31, "Pilates Studio": 88, "Gymnastics Gym": 6, "Pool": 11, "Martial Arts Dojo": 72, "Soccer Field": 61, "Playground": 73, "Skate Park": 8, "Theme Park": 18, "Parks": 30, "Scenic Lookout": 32, "Plaza": 76, "Canal": 37, "Trail": 42, "Lake": 84, "Beach": 54, "Garden": 56, "Outdoor Sculpture": 87, "Shopping": 4, "Shoppint Mall": 4, "Bookstore": 9, "Jewelry Store": 15, "Flower Shop": 52, "Women's Store": 91, "Leather Goods Store": 4, "Accessories Store": 4, "Clothing Store": 75, "Gourmet Shop": 5, "Music Store": 68, "Organic Grocery": 7, "Spa": 23, "Beer Store": 20, "Grocery Store": 21, "Pharmacy": 29, "Cosmetics Shop": 46, "Convenience Store": 33, "Candy Store": 35, "Moving Target": 39, "Farmers Market": 7, "Liquor Store": 82, "Pet Store": 38, "Wine Shop": 2, "Furniture / Home Store": 70, "Sporting Goods Shop": 47, "Smoke Shop": 49, "Business Service": 44, "Supermarket": 21, "Massage Studio": 23, "Antique Shop": 33, "Market": 33, "Construction & Landscaping": 65, "Paper / Office Supplies Store": 81, "Arts & Crafts Store": 59, "Photography Studio": 66, "Gift Shop": 63, "Health & Beauty Service": 50, "Hotels": 41, "Metro Station": 90, "Light Rail Station": 90, "Airport": 58, "Rental Car Location": 62, "College Classroom": 22, "College Bookstore": 9, "Building": 65, "Library": 9]
}
