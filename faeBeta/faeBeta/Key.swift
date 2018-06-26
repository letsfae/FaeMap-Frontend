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
    
    var joshDebug: Bool = false
    var vickyDebug: Bool = true
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
    let defaultPlace = UIImage(named: "default_place")
    
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
    
    var categories: [String: Int] = ["Art Gallery": 34, "Concert Hall": 25, "Country Dance Club": 155, "Performing Arts Venue": 28, "Dance Studio": 155, "Indie Theater": 154, "Opera House": 154, "Theater": 28, "Public Art": 34, "Outdoor Sculpture": 87, "Street Art": 34, "Art Studio": 59, "Amphitheater": 92, "Aquarium": 99, "Arcade": 26, "Bowling Alley": 110, "Casino": 101, "Circus": 144, "Comedy Club": 154, "Exhibit": 92, "General Entertainment": 92, "Go Kart Track": 127, "Karaoke Box": 100, "Laser Tag": 151, "Pachinko Parlor": 26, "Movie Theater": 95, "Drive-in Theater": 95, "Indie Movie Theater": 95, "Multiplex": 95, "Museum": 27, "Art Museum": 34, "Erotic Museum": 216, "History Museum": 283, "Planetarium": 333, "Science Museum": 86, "Music Venue": 68, "Jazz Club": 156, "Piano Bar": 157, "Rock Club": 80, "Pool Hall": 128, "Racecourse": 127, "Racetrack": 127, "Roller Rink": 153, "Salsa Club": 155, "Samba School": 155, "Stadium": 158, "Baseball Stadium": 60, "Basketball Stadium": 112, "Cricket Ground": 182, "Football Stadium": 94, "Hockey Arena": 109, "Rugby Stadium": 94, "Soccer Stadium": 61, "Tennis Stadium": 107, "Track Stadium": 158, "Theme Park": 92, "Theme Park Ride / Attraction": 18, "Tour Provider": 92, "Zoo": 115, "Zoo Exhibit": 115, "Water Park": 11, "Nightlife Spot": 106, "Night Market": 287, "Nightclub": 106, "Strip Club": 106, "Other Nightlife": 106, "Gaming Cafe": 26, "Internet Cafe": 137, "Afghan Restaurant": 5, "African Restaurant": 5, "Ethiopian Restaurant": 5, "American Restaurant": 5, "New American Restaurant": 5, "Asian Restaurant": 5, "Burmese Restaurant": 5, "Cambodian Restaurant": 5, "Chinese Restaurant": 159, "Anhui Restaurant": 5, "Beijing Restaurant": 48, "Cantonese Restaurant": 48, "Cha Chaan Teng": 5, "Chinese Aristocrat Restaurant": 136, "Chinese Breakfast Place": 48, "Dim Sum Restaurant": 48, "Dongbei Restaurant": 5, "Fujian Restaurant": 5, "Guizhou Restaurant": 5, "Hainan Restaurant": 5, "Hakka Restaurant": 5, "Henan Restaurant": 5, "Hong Kong Restaurant": 5, "Huaiyang Restaurant": 5, "Hubei Restaurant": 5, "Hunan Restaurant": 5, "Imperial Restaurant": 5, "Jiangsu Restaurant": 5, "Jiangxi Restaurant": 5, "Macanese Restaurant": 5, "Manchu Restaurant": 5, "Peking Duck Restaurant": 170, "Shaanxi Restaurant": 5, "Shandong Restaurant": 5, "Shanghai Restaurant": 48, "Shanxi Restaurant": 5, "Szechuan Restaurant": 5, "Taiwanese Restaurant": 48, "Tianjin Restaurant": 5, "Xinjiang Restaurant": 5, "Yunnan Restaurant": 159, "Zhejiang Restaurant": 5, "Filipino Restaurant": 5, "Himalayan Restaurant": 5, "Hotpot Restaurant": 104, "Indonesian Restaurant": 5, "Acehnese Restaurant": 5, "Balinese Restaurant": 5, "Betawinese Restaurant": 5, "Indonesian Meatball Place": 175, "Javanese Restaurant": 5, "Manadonese Restaurant": 5, "Padangnese Restaurant": 5, "Sundanese Restaurant": 5, "Japanese Restaurant": 10, "Donburi Restaurant": 159, "Japanese Curry Restaurant": 335, "Kaiseki Restaurant": 5, "Kushikatsu Restaurant": 160, "Monjayaki Restaurant": 171, "Nabe Restaurant": 169, "Okonomiyaki Restaurant": 171, "Ramen Restaurant": 45, "Shabu-Shabu Restaurant": 104, "Soba Restaurant": 45, "Sukiyaki Restaurant": 104, "Sushi Restaurant": 10, "Takoyaki Place": 175, "Tempura Restaurant": 5, "Tonkatsu Restaurant": 5, "Udon Restaurant": 45, "Unagi Restaurant": 159, "Wagashi Place": 161, "Yakitori Restaurant": 160, "Yoshoku Restaurant": 5, "Korean Restaurant": 5, "Bossam / Jokbal Restaurant": 5, "Bunsik Restaurant": 5, "Gukbap Restaurant": 169, "Janguh Restaurant": 5, "Samgyetang Restaurant": 169, "Malay Restaurant": 5, "Mongolian Restaurant": 5, "Noodle House": 45, "Satay Restaurant": 160, "Thai Restaurant": 5, "Som Tum Restaurant": 74, "Tibetan Restaurant": 5, "Vietnamese Restaurant": 5, "Australian Restaurant": 5, "Austrian Restaurant": 5, "BBQ Joint": 64, "Bagel Shop": 162, "Bakery": 13, "Belgian Restaurant": 5, "Breakfast Spot": 51, "Buffet": 5, "Burger Joint": 40, "Cafeteria": 5, "Caf̩é": 19, "Cajun / Creole Restaurant": 5, "Caribbean Restaurant": 5, "Cuban Restaurant": 5, "Caucasian Restaurant": 5, "Comfort Food Restaurant": 5, "Creperie": 163, "Czech Restaurant": 5, "Deli / Bodega": 55, "Dessert Shop": 161, "Cupcake Shop": 53, "Frozen Yogurt Shop": 43, "Ice Cream Shop": 16, "Pastry Shop": 172, "Pie Shop": 164, "Diner": 5, "Donut Shop": 12, "Dumpling Restaurant": 176, "Dutch Restaurant": 5, "Eastern European Restaurant": 5, "Belarusian Restaurant": 5, "Bosnian Restaurant": 5, "Bulgarian Restaurant": 5, "Romanian Restaurant": 5, "Tatar Restaurant": 5, "English Restaurant": 5, "Falafel Restaurant": 175, "Fast Food Restaurant": 69, "Fish & Chips Shop": 165, "Fondue Restaurant": 334, "Food Court": 5, "Food Stand": 288, "Food Truck": 39, "French Restaurant": 5, "Alsatian Restaurant": 5, "Auvergne Restaurant": 5, "Basque Restaurant": 5, "Brasserie": 5, "Breton Restaurant": 5, "Burgundian Restaurant": 5, "Catalan Restaurant": 5, "Ch'ti Restaurant": 5, "Corsican Restaurant": 5, "Estaminet": 82, "Labour Canteen": 5, "Lyonese Bouchon": 5, "Norman Restaurant": 5, "Proven̤al Restaurant": 5, "Savoyard Restaurant": 5, "Southwestern French Restaurant": 5, "Fried Chicken Joint": 89, "Friterie": 69, "German Restaurant": 5, "Apple Wine Pub": 14, "Bavarian Restaurant": 5, "Bratwurst Joint": 160, "Currywurst Joint": 160, "Franconian Restaurant": 5, "German Pop-Up Restaurant": 5, "Palatine Restaurant": 5, "Rhenisch Restaurant": 5, "Schnitzel Restaurant": 36, "Silesian Restaurant": 5, "Swabian Restaurant": 5, "Gluten-Free Restaurant": 5, "Greek Restaurant": 5, "Bougatsa Shop": 164, "Cretan Restaurant": 5, "Fish Taverna": 226, "Grilled Meat Restaurant": 270, "Kafenio": 19, "Magirio": 5, "Meze Restaurant": 5, "Modern Greek Restaurant": 5, "Ouzeri": 5, "Patsa Restaurant": 169, "Souvlaki Shop": 160, "Taverna": 5, "Tsipouro Restaurant": 5, "Halal Restaurant": 5, "Hawaiian Restaurant": 5, "Hot Dog Joint": 17, "Hungarian Restaurant": 5, "Indian Restaurant": 5, "Andhra Restaurant": 5, "Awadhi Restaurant": 5, "Bengali Restaurant": 5, "Chaat Place": 5, "Chettinad Restaurant": 5, "Dhaba": 5, "Dosa Place": 163, "Goan Restaurant": 5, "Gujarati Restaurant": 5, "Hyderabadi Restaurant": 5, "Indian Chinese Restaurant": 5, "Indian Sweet Shop": 5, "Irani Cafe": 5, "Jain Restaurant": 5, "Karnataka Restaurant": 5, "Kerala Restaurant": 5, "Maharashtrian Restaurant": 5, "Mughlai Restaurant": 5, "Multicuisine Indian Restaurant": 5, "North Indian Restaurant": 5, "Northeast Indian Restaurant": 5, "Parsi Restaurant": 5, "Punjabi Restaurant": 5, "Rajasthani Restaurant": 5, "South Indian Restaurant": 5, "Udupi Restaurant": 5, "Italian Restaurant": 5, "Abruzzo Restaurant": 5, "Agriturismo": 149, "Aosta Restaurant": 5, "Basilicata Restaurant": 5, "Calabria Restaurant": 5, "Campanian Restaurant": 5, "Emilia Restaurant": 5, "Friuli Restaurant": 5, "Ligurian Restaurant": 5, "Lombard Restaurant": 5, "Malga": 5, "Marche Restaurant": 5, "Molise Restaurant": 5, "Piadineria": 163, "Piedmontese Restaurant": 5, "Puglia Restaurant": 5, "Romagna Restaurant": 5, "Roman Restaurant": 5, "Sardinian Restaurant": 5, "Sicilian Restaurant": 5, "South Tyrolean Restaurant": 5, "Trattoria / Osteria": 5, "Trentino Restaurant": 5, "Tuscan Restaurant": 5, "Umbrian Restaurant": 5, "Veneto Restaurant": 5, "Jewish Restaurant": 5, "Kosher Restaurant": 5, "Kebab Restaurant": 160, "Latin American Restaurant": 5, "Arepa Restaurant": 55, "Empanada Restaurant": 173, "Salvadoran Restaurant": 5, "South American Restaurant": 5, "Argentinian Restaurant": 5, "Brazilian Restaurant": 5, "Acai House": 166, "Baiano Restaurant": 5, "Central Brazilian Restaurant": 5, "Churrascaria": 36, "Empada House": 167, "Goiano Restaurant": 5, "Mineiro Restaurant": 5, "Northeastern Brazilian Restaurant": 5, "Northern Brazilian Restaurant": 5, "Pastelaria": 172, "Southeastern Brazilian Restaurant": 5, "Southern Brazilian Restaurant": 5, "Tapiocaria": 5, "Colombian Restaurant": 5, "Peruvian Restaurant": 5, "Venezuelan Restaurant": 5, "Mac & Cheese Joint": 168, "Mediterranean Restaurant": 5, "Moroccan Restaurant": 5, "Mexican Restaurant": 83, "Botanero": 5, "Burrito Place": 71, "Taco Place": 83, "Tex-Mex Restaurant": 5, "Yucatecan Restaurant": 5, "Middle Eastern Restaurant": 5, "Israeli Restaurant": 5, "Kurdish Restaurant": 5, "Lebanese Restaurant": 5, "Persian Restaurant": 5, "Ash and Haleem Place": 169, "Dizi Place": 169, "Gilaki Restaurant": 5, "Jegaraki": 160, "Tabbakhi": 5, "Modern European Restaurant": 5, "Molecular Gastronomy Restaurant": 5, "Pakistani Restaurant": 5, "Pet Caf̩é": 38, "Pizza Place": 57, "Polish Restaurant": 5, "Portuguese Restaurant": 5, "Poutine Place": 69, "Restaurant": 5, "Russian Restaurant": 5, "Blini House": 163, "Pelmeni House": 176, "Salad Place": 74, "Sandwich Place": 55, "Scandinavian Restaurant": 5, "Scottish Restaurant": 5, "Seafood Restaurant ": 24, "Slovak Restaurant": 5, "Snack Place": 69, "Soup Place": 169, "Southern / Soul Food Restaurant": 5, "Spanish Restaurant": 5, "Paella Restaurant": 3, "Tapas Restaurant": 5, "Sri Lankan Restaurant": 5, "Steakhouse": 36, "Swiss Restaurant": 5, "Theme Restaurant": 5, "Truck Stop": 5, "Turkish Restaurant": 5, "Borek Place": 174, "Cigkofte Place": 175, "Doner Restaurant": 83, "Gozleme Place": 174, "Kofte Place": 175, "Kokore̤ Restaurant": 5, "Kumpir Restaurant": 5, "Kumru Restaurant": 55, "Manti Place": 176, "Meyhane": 5, "Pide Place": 57, "Pilavcı": 5, "Söğüş Place": 5, "Tantuni Restaurant": 71, "Turkish Coffeehouse": 19, "Turkish Home Cooking Restaurant": 5, "Çöp Şiş Place": 160, "Ukrainian Restaurant": 5, "Varenyky Restaurant": 176, "West-Ukrainian Restaurant": 5, "Vegetarian / Vegan Restaurant": 78, "Wings Joint": 177, "Bubble Tea Shop": 133, "Bistro": 5, "Coffee Shop": 19, "Gastropub": 82, "Irish Pub": 82, "Juice Bar": 67, "Tea Room": 102, "Bar": 14, "Beach Bar": 14, "Beer Bar": 82, "Beer Garden": 82, "Champagne Bar": 82, "Cocktail Bar": 14, "Dive Bar": 14, "Gay Bar": 14, "Hookah Bar": 85, "Hotel Bar": 14, "Karaoke Bar": 100, "Pub": 82, "Sake Bar": 79, "Speakeasy": 82, "Sports Bar": 14, "Tiki Bar": 14, "Whisky Bar": 82, "Wine Bar": 2, "Brewery": 77, "Lounge": 14, "Historic Site": 145, "Memorial Site": 298, "Bay": 54, "Beach": 54, "Nudist Beach": 54, "Surf Spot": 54, "Bike Trail": 31, "Botanical Garden": 56, "Bridge": 178, "Campground": 97, "Canal Lock": 179, "Canal": 179, "Castle": 180, "Cave": 181, "Dog Run": 182, "Farm": 149, "Field": 182, "Forest": 96, "Fountain": 76, "Garden": 56, "Harbor / Marina": 105, "Island": 183, "Lake": 84, "Lighthouse": 184, "Mountain Hut": 185, "Mountain": 32, "National Park": 96, "Nature Preserve": 96, "Other Great Outdoors": 32, "Palace": 180, "Park": 30, "Pedestrian Plaza": 186, "Plaza": 186, "Reservoir": 84, "River": 187, "Rock Climbing Spot": 188, "Scenic Lookout": 189, "Sculpture Garden": 87, "Skydiving Drop Zone": 190, "Stables": 115, "Summer Camp": 191, "Trail": 42, "Tree": 96, "Vineyard": 2, "Volcano": 192, "Waterfall": 37, "Waterfront": 193, "Well": 194, "Disc Golf ": 195, "Mini Golf": 108, "Athletics & Sports": 47, "Badminton Court": 196, "Baseball Field": 60, "Basketball Court": 112, "Bowling Green": 110, "Curling Ice": 197, "Golf Course": 108, "Golf Driving Range": 108, "Gym / Fitness Center": 6, "Boxing Gym": 198, "Climbing Gym": 188, "Cycle Studio": 31, "Gym Pool": 11, "Gymnastics Gym": 199, "Gym": 6, "Martial Arts Dojo": 72, "Outdoor Gym": 199, "Pilates Studio": 317, "Track": 200, "Weight Loss Center": 6, "Yoga Studio": 317, "Hockey Field": 109, "Hockey Rink": 109, "Paintball Field": 201, "Rugby Pitch": 94, "Skate Park": 8, "Skating Rink": 113, "Soccer Field": 61, "Sports Club": 47, "Squash Court": 203, "Tennis Court": 107, "Volleyball Court": 129, "Dive Spot": 202, "Pool": 11, "Bathing Area": 242, "Fishing Spot": 205, "Gun Range": 204, "Hot Spring": 206, "Indoor Play Area": 259, "Playground": 259, "Rafting": 208, "Recreation Center": 1, "Ski Area": 143, "Apres Ski Bar": 14, "Ski Chairlift": 73, "Ski Chalet": 185, "Ski Lodge": 185, "Ski Trail": 42, "Adult Boutique": 216, "Antique Shop": 210, "Arts & Crafts Store": 59, "Auto Dealership": 62, "Automotive Shop": 62, "Baby Store": 313, "Batik Shop": 218, "Betting Shop": 33, "Big Box Store": 217, "Bike Shop": 31, "Board Shop": 8, "Bookstore": 282, "Bridal Shop": 91, "Camera Store": 66, "Candy Store": 35, "Carpet Store": 218, "Chocolate Shop": 336, "Clothing Store": 75, "Accessories Store": 211, "Boutique": 75, "Kids Store": 209, "Lingerie Store": 213, "Men's Store": 212, "Shoe Store": 214, "Women's Store": 215, "Comic Shop": 9, "Convenience Store": 7, "Cosmetics Shop": 46, "Costume Shop": 219, "Department Store": 4, "Discount Store": 220, "Dive Shop": 202, "Drugstore": 29, "Electronics Store": 221, "Fabric Shop": 218, "Fireworks Store": 222, "Fishing Store": 205, "Flea Market": 287, "Floating Market": 33, "Flower Shop": 52, "Food & Drinks Shop": 21, "Beer Store": 82, "Butcher": 223, "Cheese Shop": 224, "Dairy Store": 225, "Farmers Market": 7, "Fish Market": 226, "Food Service": 5, "Gourmet Shop": 5, "Grocery Store": 21, "Health Food Store": 21, "Kuruyemişçi": 7, "Liquor Store": 82, "Organic Grocery": 21, "Sausage Shop": 263, "Street Food Gathering": 39, "Supermarket": 21, "Turşucu": 7, "Wine Shop": 2, "Frame Store": 33, "Fruits & Vegetable Store": 78, "Furniture / Home Store": 257, "Lighting Store": 227, "Gift Shop": 63, "Gun Shop": 204, "Hardware Store": 142, "Herbs & Spices Store": 7, "Hobby Shop": 135, "Hunting Supply": 204, "Jewelry Store": 15, "Kitchen Supply Store": 228, "Knitting Store": 229, "Laundromat": 140, "Leather Goods Store": 4, "Lottery Retailer": 125, "Luggage Store": 230, "Marijuana Dispensary": 85, "Market": 33, "Mattress Store": 218, "Medical Supply Store": 29, "Miscellaneous Shop": 33, "Mobile Phone Shop": 231, "Mobility Store": 33, "Motorcycle Shop": 232, "Motorsports Shop": 233, "Music Store": 68, "Newsstand": 234, "Optical Shop": 235, "Other Repair Shop": 142, "Outdoor Supply Store": 191, "Outlet Mall": 4, "Outlet Store": 4, "Paper / Office Supplies Store": 81, "Pawn Shop": 33, "Perfume Shop": 93, "Pet Store": 38, "Pharmacy": 29, "Pop-Up Shop": 33, "Print Shop": 236, "Record Shop": 150, "Shipping Store": 132, "Shopping Mall": 4, "Shopping Plaza": 4, "Ski Shop": 143, "Smoke Shop": 49, "Smoothie Shop": 67, "Souvenir Shop": 63, "Sporting Goods Shop": 47, "Stationery Store": 237, "Supplement Shop": 29, "Tailor Shop": 229, "Thrift / Vintage Store": 33, "Toy / Game Store": 135, "Used Bookstore": 282, "Vape Store": 49, "Video Game Store": 337, "Video Store": 238, "Warehouse Store": 217, "Watch Shop": 239, "ATM": 122, "Astrologer": 240, "Auto Garage": 314, "Auto Workshop": 118, "Bank": 130, "Bath House": 242, "Business Services": 338, "Car Wash": 119, "Check Cashing Service": 131, "Child Care Service": 207, "Daycare": 207, "Construction & Landscaping": 266, "Credit Union": 131, "Currency Exchange": 241, "Design Studio": 59, "Dry Cleaner": 140, "EV Charging Station": 120, "Entertainment Services": 44, "Event Services": 294, "Film Studio": 243, "Financial / Legal Services": 131, "Garden Center": 56, "Gas Station": 121, "Health & Beauty Services": 46, "Home Services": 328, "IT Services": 137, "Insurance Office": 44, "Laundry Service": 140, "Lawyer": 244, "Locksmith": 245, "Massage Studio": 23, "Nail Salon": 246, "Pet Service": 38, "Photography Lab": 66, "Photography Studio": 66, "Piercing Parlor": 248, "Public Bathroom": 247, "Real Estate Office": 250, "Recording Studio": 251, "Recycling Facility": 252, "Rental Service": 44, "Salon / Barbershop": 50, "Sauna / Steam Room": 253, "Shoe Repair": 254, "Spa": 23, "Storage Facility": 148, "Tanning Salon": 255, "Tattoo Parlor": 249, "Travel Agency": 256, "Airport": 58, "Airport Food Court": 5, "Airport Gate": 58, "Airport Lounge": 70, "Airport Service": 58, "Airport Terminal": 58, "Airport Tram": 90, "Baggage Claim": 230, "Plane": 58, "Baggage Locker": 260, "Bike Rental / Bike Share": 31, "Boat Rental": 261, "Boat or Ferry": 261, "Border Crossing": 262, "Bus Station": 134, "Bus Line": 134, "Bus Stop": 134, "Cable Car": 264, "Cruise": 261, "Duty-Free Shop": 4, "General Travel": 256, "Heliport": 265, "Hotel": 41, "Bed & Breakfast": 41, "Boarding House": 267, "Hostel": 267, "Hotel Pool": 11, "Motel": 41, "Resort": 268, "Roof Deck": 269, "Vacation Rental": 268, "Intersection": 271, "Light Rail Station": 90, "Metro Station": 90, "Moving Target": 146, "Pier": 272, "Port": 105, "RV Park": 273, "Rental Car Location": 274, "Rest Area": 275, "Road": 276, "Taxi Stand": 277, "Taxi": 277, "Toll Booth": 262, "Toll Plaza": 262, "Tourist Information Center": 278, "Train Station": 103, "Platform": 103, "Train": 103, "Tram Station": 90, "Transportation Service": 279, "Travel Lounge": 70, "Tunnel": 280, "College & University": 22, "College Academic Building": 281, "College Arts Building": 281, "College Communications Building": 281, "College Engineering Building": 281, "College History Building": 281, "College Math Building": 281, "College Science Building": 281, "College Technology Building": 281, "College Administrative Building": 281, "College Auditorium": 285, "College Bookstore": 282, "College Cafeteria": 5, "College Classroom": 281, "College Gym": 6, "College Lab": 86, "College Library": 9, "College Quad": 182, "College Rec Center": 1, "College Residence Hall": 267, "College Stadium": 158, "College Baseball Diamond": 60, "College Basketball Court": 112, "College Cricket Pitch": 182, "College Football Field": 94, "College Hockey Rink": 109, "College Soccer Field": 61, "College Tennis Court": 107, "College Track": 200, "College Theater": 154, "Community College": 22, "Fraternity House": 284, "General College & University": 281, "Law School": 281, "Medical School": 281, "Sorority House": 284, "Student Center": 281, "Trade School": 281, "University": 22, "Animal Shelter": 309, "Auditorium": 285, "Ballroom": 155, "Building": 286, "Business Center": 286, "Club House": 1, "Community Center": 1, "Convention Center": 289, "Meeting Room": 290, "Cultural Center": 291, "Distillery": 292, "Distribution Center": 299, "Event Space": 293, "Outdoor Event Space": 294, "Factory": 295, "Fair": 296, "Cemetery": 141, "Funeral Home": 141, "Government Building": 147, "Capitol Building": 147, "City Hall": 147, "Courthouse": 297, "Embassy / Consulate": 147, "Fire Station": 114, "Monument / Landmark": 298, "Police Station": 116, "Town Hall": 147, "Industrial Estate": 295, "Laboratory": 300, "Library": 9, "Medical Center": 117, "Acupuncturist": 301, "Alternative Healer": 304, "Chiropractor": 302, "Dentist's Office": 126, "Doctor's Office": 303, "Emergency Room": 326, "Eye Doctor": 305, "Hospital": 117, "Hospital Ward": 117, "Maternity Clinic": 303, "Medical Lab": 300, "Mental Health Office": 306, "Nutritionist": 307, "Physical Therapist": 303, "Rehab Center": 117, "Urgent Care Center": 117, "Veterinarian": 308, "Military Base": 310, "Non-Profit": 286, "Observatory": 152, "Office": 286, "Advertising Agency": 44, "Campaign Office": 44, "Conference Room": 290, "Corporate Amenity": 286, "Corporate Cafeteria": 5, "Corporate Coffee Shop": 19, "Coworking Space": 286, "Tech Startup": 286, "Parking": 123, "Post Office": 132, "Power Plant": 295, "Prison": 311, "Radio Station": 312, "Recruiting Agency": 44, "Research Station": 286, "School": 281, "Adult Education Center": 281, "Circus School": 281, "Cooking School": 281, "Driving School": 315, "Elementary School": 281, "Flight School": 281, "High School": 281, "Language School": 281, "Middle School": 281, "Music School": 68, "Nursery School": 258, "Preschool": 258, "Private School": 281, "Religious School": 281, "Swim School": 11, "Social Club": 316, "Spiritual Center": 88, "Buddhist Temple": 136, "Cemevi": 88, "Church": 98, "Confucian Temple": 136, "Hindu Temple": 318, "Kingdom Hall": 88, "Monastery": 98, "Mosque": 319, "Prayer Room": 88, "Shrine": 320, "Synagogue": 321, "Temple": 88, "Terreiro": 88, "TV Station": 322, "Voting Booth": 323, "Warehouse": 148, "Waste Facility": 324, "Wedding Hall": 91, "Winery": 2, "Residence": 325, "Assisted Living": 329, "Home (Private)": 65, "Housing Development": 327, "Residential Building (Apartment / Condo)": 325, "Trailer Park": 273, "Event": 293, "Christmas Market": 287, "Conference": 290, "Convention": 289, "Festival": 296, "Line / Queue": 293, "Music Festival": 330, "Other Event": 294, "Parade": 296, "Stoop Sale": 287, "Street Fair": 287, "States & Municipalities": 331, "City": 331, "County": 331, "Country": 331, "Neighborhood": 331, "State": 331, "Town": 331, "Village": 331]
}
