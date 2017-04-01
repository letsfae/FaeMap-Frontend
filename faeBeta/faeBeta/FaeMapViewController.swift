//
//  FaeMapViewController.swift
//  Using GoogleMaps
//
//  Created by Yue on 5/31/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftyJSON
import RealmSwift

class FaeMapViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    // MARK: -- Common Used Vars and Constants
    let navigationBarHeight : CGFloat = 20
    
    // MARK: -- Map main screen Objects
    var faeMapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    
    var buttonLeftTop: UIButton!
    var buttonMainScreenSearch: UIButton!
    var buttonRightTop: UIButton!
    var buttonToNorth: UIButton!
    var buttonSelfPosition: UIButton!
    var buttonChatOnMap: UIButton!
    var buttonPinOnMap: UIButton!
    var buttonPinOnMapInside: UIButton!
    var buttonCancelSelectLocation: UIButton!
    
    // MARK: -- Location
    let locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    var didLoadFirstLoad = false
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    
    // Unread Messages Label
    var labelUnreadMessages: UILabel!
    
    // MARK: -- More Button Vars
    var uiviewMoreButton: UIView!
    var dimBackgroundMoreButton: UIButton!
    
    // MARK: -- WindBell Vars
    var uiviewWindBell: UIView!
    var dimBackgroundWindBell: UIButton!
    
    // MARK: -- Map Chat
    var mapChatSubview: UIButton!
    var mapChatWindow: UIView!
    var labelMapChat: UILabel!
    var mapChatTable = UITableView()
    
    // More table view
    let tableViewWeight : CGFloat = 290
    var buttonImagePicker : UIButton!
    var buttonMoreLeft : UIButton!
    var buttonMoreRight : UIButton!
    var imagePicker : UIImagePickerController! // MARK: new var Wenye
    var imageViewAvatarMore : UIImageView!
    var imageViewBackgroundMore : UIImageView!
    var labelMoreName : UILabel!
    var tableviewMore = UITableView()
    var viewHeaderForMore : UIView!
    
    // Windbell table view
    var labelWindbellTableTitle: UILabel!
    var tableviewWindbell = UITableView()
    
    let storageForOpenedPinList = UserDefaults.standard// Local Storage for storing opened pin id, for opened pin list use
    var buttonCloseUserPinSubview: UIButton! // button to close user pin view
    var canDoNextUserUpdate = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var canLoadMapPin = true // if can load map pin when zoom level is valid for updating
    var canOpenAnotherPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    var mapPinsArray = [GMSMarker]() // Map Pin Array
    var mapPins = [MapPin]()
    var mapUserPinsDic = [GMSMarker]() // Map User Pin
    var userPins = [UserPin]()
    var placeMarkers = [GMSMarker]()
    var mapPlaces = [PlacePin]()
    var placeNames = [Double]()
    var markerMask: UIView! // mask to prevent UI action
    var pinIDFromOpenedPinCell = -999 // Determine if this pinID should change to heavy shadow style
    var pinIdToPassBySegue: String = "" // segue to Comment Pin Popup Window
    var previousPosition: CLLocationCoordinate2D!
    var previousZoomLevel: Float = 0 // previous zoom level to check if map should reload pins
    var tempMarker: UIImageView! // temp marker, it is a UIImageView
    var timerLoadRegionPins: Timer! // timer to renew map pins
    var timerUpdateSelfLocation: Timer! // timer to renew update user pins
    var timerLoadRegionPlacePins: Timer! // timer to renew map places pin
    
    // Map Namecard
    var buttonChat: UIButton!
    var buttonClosingOptionsInNameCard: UIButton!
    var buttonEmoji: UIButton!
    var buttonFakeTransparentClosingView: UIButton!
    var buttonFavorite: UIButton!
    var buttonOptions: UIButton!
    var buttonShowSelfOnMap: UIButton!
    var editNameCard: UIButton!
    var imageAvatarNameCard: UIImageView!
    var imageBackground: UIImageView!
    var imageCover: UIImageView!
    var imageGenderMen: UIImageView!
    var imageOneLine: UIImageView!
    var labelDisplayName: UILabel!
    var labelNameTag: UILabel!
    var labelShortIntro: UILabel!
    var nameCardMoreOptions: UIImageView!
    var reportNameCard: UIButton!
    var shareNameCard: UIButton!
    var uiViewNameCard: UIView!
    var labelUserAge: UILabel!
    var uiviewUserGender: UIView!
    var imageUserGender: UIImageView!
    var lblUserAge: UILabel!
    var avatarBaseView: UIView!
    let startFrame = CGRect(x: screenWidth / 2, y: 451, width: 0, height: 0)
    let nameCardAnchor = CGPoint(x: screenWidth / 2, y: 451)
    
    // Map Filter
    let filterMenuHeight = 542 * screenHeightFactor
    
    // Filter Button
    var btnMapFilter: UIButton!
    var polygonOutside: UIImageView!
    var polygonInside: UIImageView!
    var mapFilterArrow: UIImageView!
    
    // Filter Menu
    var uiviewFilterMenu: UIView!
    var btnDraggingMenu: UIButton!
    
    // Filter Item
    var btnMFilterShowAll: MFilterButton!
    var btnMFilterDistance: MFilterButton!
    var btnMFilterPeople: MFilterButton!
    
    var btnMFilterTypeAll: MFilterButton!
    var btnMFilterComments: MFilterButton!
    var btnMFilterChats: MFilterButton!
    var btnMFilterStories: MFilterButton!
    
    var btnMFilterStatusAll: MFilterButton!
    var btnMFilterHot: MFilterButton!
    var btnMFilterNew: MFilterButton!
    var btnMFilterUnread: MFilterButton!
    var btnMFilterRead: MFilterButton!
    
    var btnMFilterPlacesAll: MFilterButton!
    var btnMFilterRestr: MFilterButton!
    var btnMFilterCafe: MFilterButton!
    var btnMFilterDessert: MFilterButton!
    var btnMFilterCinema: MFilterButton!
    var btnMFilterBeauty: MFilterButton!
    var btnMFilterSports: MFilterButton!
    var btnMFilterGallery: MFilterButton!
    
    var btnMFilterMyPins: MFilterButton!
    var btnMFilterSavedPins: MFilterButton!
    var btnMFilterSavedPlaces: MFilterButton!
    var btnMFilterSavedLoc: MFilterButton!
    
    // Pan gesture var
    var sizeFrom: CGFloat = 0
    var sizeTo: CGFloat = 0
    var spaceFilter: CGFloat = 0
    var spaceMenu: CGFloat = 0
    var end: CGFloat = 0
    var percent: Double = 0
    
    // Filter data processing
    var filterPinTypeDic = [String: MFilterButton]()
    var filterPinStatusDic = [String: MFilterButton]()
    var filterPlaceDic = [String: MFilterButton]()
    
    // Filter Slider
    var filterSlider: UISlider!
    var lblFilterDist: UILabel!
    
    // Filter btn inside circles
    var filterCircle_1: UIImageView!
    var filterCircle_2: UIImageView!
    var filterCircle_3: UIImageView!
    var filterCircle_4: UIImageView!
    
    // Class global variable to control the filter
    var stringFilterValue = "comment,chat_room,media"
    
    // Yelp API
    let yelpManager = YelpManager()
    let yelpQuery = YelpQuery()
    
    // If below can be refreshed
    var refreshPins = true
    var refreshUsers = true
    var refreshPlaces = true
//    var refreshPlacesAll = true
    
    // Self Position Marker: 02-17-2016 Yue Shen
    var selfMarker = GMSMarker()
    var subviewSelfMarker: UIView!
    var selfMarkerIcon: UIImageView!
    var myPositionCircle_1: UIImageView!
    var myPositionCircle_2: UIImageView!
    var myPositionCircle_3: UIImageView!
    
    var canDoNextMapPinUpdate = true
    var canDoNextPlacePinUpdate = true
    
    var placeBurger = #imageLiteral(resourceName: "placePinBurger")
    var placePizza = #imageLiteral(resourceName: "placePinPizza")
    var placeDessert = #imageLiteral(resourceName: "placePinDesert")
    var placeCinema = #imageLiteral(resourceName: "placePinCinema")
    var placeArt = #imageLiteral(resourceName: "placePinArt")
    var placeSport = #imageLiteral(resourceName: "placePinSport")
    var placeCoffee = #imageLiteral(resourceName: "placePinCoffee")
    var placeBoba = #imageLiteral(resourceName: "placePinBoba")
    var placeBeauty = #imageLiteral(resourceName: "placePinBoutique")
    var placeFoodtruck = #imageLiteral(resourceName: "placePinFoodtruck")
    
    var previousZoom: Float = 13.8
    
    // System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        isUserLoggedIn()
        getUserStatus()
        loadMapView()
        setupClusterManager()
        loadTransparentNavBarItems()
        loadButton()
        loadNameCard()
        timerSetup()
        openedPinListSetup()
        updateSelfInfo()
        loadMFilterSlider()
        loadMapFilter()
        filterAndYelpSetup()
        loadSelfMarkerSubview()
        reloadSelfMarker()
        didLoadFirstLoad = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locManager.requestAlwaysAuthorization()
        checkLocationEnablibity()
        self.loadTransparentNavBarItems()
        self.loadMapChat()
        buttonFakeTransparentClosingView.alpha = 0
        reloadSelfPosAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        NotificationCenter.default.addObserver(self, selector: #selector(self.isFirstTimeLogin(_:)), name: NSNotification.Name(rawValue: "isFirstLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.returnFromLoginSignup(_:)), name: NSNotification.Name(rawValue: "returnFromLoginSignup"), object: nil)
        checkFirstLoginInRealm()
        let updateGenderAge = FaeUser()
        updateGenderAge.whereKey("show_gender", value: "true")
        updateGenderAge.whereKey("show_age", value: "true")
        updateGenderAge.updateNameCard { (status, message) in
            if status / 100 == 2 {
                print("[showGenderAge] Successfully update namecard")
            } else {
                print("[showGenderAge] Fail to update namecard")
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func returnFromLoginSignup(_ notification: NSNotification) {
        print("[returnFromLoginSignup] yes it is")
        refreshMap(pins: true, users: true, places: false)
    }
    
    func isUserLoggedIn() {
        let shareAPI = LocalStorageManager()
        _ = shareAPI.readLogInfo()
        if is_Login == 0 {
            self.jumpToWelcomeView(animated: false)
        }
    }
    
    fileprivate func openedPinListSetup() {
        let emptyArrayList = [String]()
        self.storageForOpenedPinList.set(emptyArrayList, forKey: "openedPinList")
    }
    
    fileprivate func filterAndYelpSetup() {
        checkFilterShowAll(btnMFilterShowAll)
        yelpQuery.setCatagoryToAll()
    }
    
    func timerSetup() {
        invalidateAllTimer()
        timerUpdateSelfLocation = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateSelfLocation), userInfo: nil, repeats: true)
        timerLoadRegionPins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(self.loadCurrentRegionPins), userInfo: nil, repeats: true)
        timerLoadRegionPlacePins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(self.loadCurrentRegionPlacePins), userInfo: nil, repeats: true)
    }
    
    func invalidateAllTimer() {
        if timerLoadRegionPins != nil {
            timerLoadRegionPins.invalidate()
        }
        if timerUpdateSelfLocation != nil {
            timerUpdateSelfLocation.invalidate()
        }
        if timerLoadRegionPlacePins != nil {
            timerLoadRegionPlacePins.invalidate()
        }
    }
    
    func isFirstTimeLogin(_ notification: NSNotification) {
        print("[isFirstTimeLogin] yes it is")
        loadFirstLoginVC()
        if let gender = userUserGender {
            if gender == "female" {
                let updateMiniAvatar = FaeUser()
                self.selfMarkerIcon.image = UIImage(named: "miniAvatar_19")
                updateMiniAvatar.whereKey("mini_avatar", value: "18")
                updateMiniAvatar.updateAccountBasicInfo({(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        print("Successfully update miniavatar")
                    }
                    else {
                        print("Fail to update miniavatar")
                    }
                })
            }
        }
    }
    
    fileprivate func loadFirstLoginVC() {
        let firstTimeLoginVC = FirstTimeLoginViewController()
        firstTimeLoginVC.modalPresentationStyle = .overCurrentContext
        self.present(firstTimeLoginVC, animated: false, completion: nil)
    }
    
    fileprivate func checkFirstLoginInRealm() {
        if user_id != nil {
            let realm = try! Realm()
            if let userRealm = realm.objects(FaeUserRealm.self).filter("userId == \(Int(user_id))").first {
                if !userRealm.firstUpdate {
                    print("[checkFirstLoginInRealm] yes it is")
                    loadFirstLoginVC()
                }
            }
        }
    }
    
    // Check if location is enabled
    fileprivate func checkLocationEnablibity() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            print("Not Authorised")
            self.locManager.requestAlwaysAuthorization()
        }
        
        else if CLLocationManager.authorizationStatus() == .denied {
            jumpToLocationEnable()
        }
    }
    
    func updateTimerForAllPins() {
        self.updateTimerForLoadRegionPin()
        self.updateTimerForUserPin()
        self.updateTimerForLoadRegionPlacePin()
    }
    
    // Testing back from background
    func appBackFromBackground() {
        checkLocationEnablibity()
        if faeMapView != nil {
            updateTimerForAllPins()
            renewSelfLocation()
            reloadSelfPosAnimation()
        }
    }
    
    func reloadSelfPosAnimation() {
        if userStatus != 5  {
            subviewSelfMarker.isHidden = false
            reloadSelfMarker()
            getSelfAccountInfo()
        } else {
            subviewSelfMarker.isHidden = true
            faeMapView.isMyLocationEnabled = true
        }
    }
    
    func jumpToLocationEnable() {
        let locEnableVC: UIViewController = UIStoryboard(name: "EnableLocationAndNotification", bundle: nil) .instantiateViewController(withIdentifier: "EnableLocationViewController") as! EnableLocationViewController
        self.present(locEnableVC, animated: true, completion: nil)
    }
    
    func jumpToWelcomeView(animated: Bool) {
        let welcomeVC = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "NavigationWelcomeViewController") as! NavigationWelcomeViewController
        self.present(welcomeVC, animated: animated, completion: nil)
    }
    
    // To get opened pin list, but it is a general func
    func readByKey(_ key: String) -> AnyObject? {
        if let obj = self.storageForOpenedPinList.object(forKey: key) {
            return obj as AnyObject?
        }
        return nil
    }
    
    // MARK: -- Load Navigation Items
    fileprivate func loadTransparentNavBarItems() {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func refreshMap(pins: Bool, users: Bool, places: Bool) {
        if users {
            self.updateTimerForUserPin()
        }
        if pins {
            self.updateTimerForLoadRegionPin()
        }
        if places {
            self.updateTimerForLoadRegionPlacePin()
        }
    }
    
    // MARK: -- Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if didLoadFirstLoad {
            self.didLoadFirstLoad = false
            self.currentLocation = locManager.location
            self.currentLatitude = currentLocation.coordinate.latitude
            self.currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 13.8)
            self.faeMapView.camera = camera
            let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
            let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
            self.previousPosition = mapCenterCoordinate
            reloadSelfPosAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.refreshMap(pins: true, users: true, places: true)
            })
        }
        
        // userStatus == 5, invisible
        if userStatus == 5 {
            return
        }
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let points = self.faeMapView.projection.point(for: position)
//            self.selfMarker.position = position
            self.subviewSelfMarker.center = points
        }
    }
}
