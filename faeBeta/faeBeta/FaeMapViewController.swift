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
    
    let filterMenuHeight = 542 * screenHeightFactor // Map Filter height
    let locManager = CLLocationManager() // location manage
    let nameCardAnchor = CGPoint(x: screenWidth / 2, y: 451) // Map Namecard
    let navigationBarHeight: CGFloat = 20
    let startFrame = CGRect(x: screenWidth / 2, y: 451, width: 0, height: 0) // Map Namecard
    let storageForOpenedPinList = UserDefaults.standard// Local Storage for storing opened pin id, for opened pin list use
    let yelpManager = YelpManager() // Yelp API
    let yelpQuery = YelpQuery() // Yelp API
    var avatarBaseView: UIView! // Map Namecard
    var btnDraggingMenu: UIButton! // Filter Menu
    var btnMFilterBeauty: MFilterButton! // Filter Item
    var btnMFilterCafe: MFilterButton! // Filter Item
    var btnMFilterChats: MFilterButton! // Filter Item
    var btnMFilterCinema: MFilterButton! // Filter Item
    var btnMFilterComments: MFilterButton! // Filter Item
    var btnMFilterDessert: MFilterButton! // Filter Item
    var btnMFilterDistance: MFilterButton! // Filter Item
    var btnMFilterGallery: MFilterButton! // Filter Item
    var btnMFilterHot: MFilterButton! // Filter Item
    var btnMFilterMyPins: MFilterButton! // Filter Item
    var btnMFilterNew: MFilterButton! // Filter Item
    var btnMFilterPeople: MFilterButton! // Filter Item
    var btnMFilterPlacesAll: MFilterButton! // Filter Item
    var btnMFilterRead: MFilterButton! // Filter Item
    var btnMFilterRestr: MFilterButton! // Filter Item
    var btnMFilterSavedLoc: MFilterButton! // Filter Item
    var btnMFilterSavedPins: MFilterButton! // Filter Item
    var btnMFilterSavedPlaces: MFilterButton! // Filter Item
    var btnMFilterShowAll: MFilterButton! // Filter Item
    var btnMFilterSports: MFilterButton! // Filter Item
    var btnMFilterStatusAll: MFilterButton! // Filter Item
    var btnMFilterStories: MFilterButton! // Filter Item
    var btnMFilterTypeAll: MFilterButton! // Filter Item
    var btnMFilterUnread: MFilterButton! // Filter Item
    var btnMapFilter: UIButton! // Filter Button
    var buttonCancelSelectLocation: UIButton!
    var buttonChat: UIButton! // Map Namecard
    var buttonChatOnMap: UIButton!
    var buttonClosingOptionsInNameCard: UIButton! // Map Namecard
    var buttonEmoji: UIButton! // Map Namecard
    var buttonFakeTransparentClosingView: UIButton! // Map Namecard
    var buttonFavorite: UIButton! // Map Namecard
    var buttonLeftTop: UIButton!
    var buttonMainScreenSearch: UIButton!
    var buttonOptions: UIButton! // Map Namecard
    var buttonPinOnMap: UIButton!
    var buttonPinOnMapInside: UIButton!
    var buttonRightTop: UIButton!
    var buttonSelfPosition: UIButton!
    var buttonShowSelfOnMap: UIButton! // Map Namecard
    var buttonToNorth: UIButton!
    var canDoNextMapPinUpdate = true
    var canDoNextPlacePinUpdate = true
    var canDoNextUserUpdate = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var canOpenAnotherPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    var currentLatitude: CLLocationDegrees = 34.0205378 // location manage
    var currentLocation2D = CLLocationCoordinate2DMake(34.0205378, -118.2854081) // location manage
    var currentLocation: CLLocation! // location manage
    var currentLongitude: CLLocationDegrees = -118.2854081 // location manage
    var didLoadFirstLoad = false // location manage
    var editNameCard: UIButton! // Map Namecard
    var end: CGFloat = 0 // Pan gesture var
    var faeMapView: GMSMapView!
    var filterCircle_1: UIImageView! // Filter btn inside circles
    var filterCircle_2: UIImageView! // Filter btn inside circles
    var filterCircle_3: UIImageView! // Filter btn inside circles
    var filterCircle_4: UIImageView! // Filter btn inside circles
    var filterPinStatusDic = [String: MFilterButton]() // Filter data processing
    var filterPinTypeDic = [String: MFilterButton]() // Filter data processing
    var filterPlaceDic = [String: MFilterButton]() // Filter data processing
    var filterSlider: UISlider! // Filter Slider
    var imageAvatarNameCard: UIImageView! // Map Namecard
    var imageBackground: UIImageView! // Map Namecard
    var imageCover: UIImageView! // Map Namecard
    var imageOneLine: UIImageView! // Map Namecard
    var imageUserGender: UIImageView! // Map Namecard
    var labelDisplayName: UILabel! // Map Namecard
    var labelShortIntro: UILabel! // Map Namecard
    var labelUnreadMessages: UILabel! // Unread Messages Label
    var lblDistanceDisplay: UILabel!
    var lblFilterDist: UILabel! // Filter Slider
    var lblUserAge: UILabel! // Map Namecard
    var mapFilterArrow: UIImageView! // Filter Button
    var mapPins = [MapPin]()
    var mapPinsMarkers = [GMSMarker]() // Map Pin Array
    var mapUserPinsDic = [GMSMarker]() // Map User Pin
    var markerMask: UIView! // mask to prevent UI action
    var myPositionCircle_1: UIImageView! // Self Position Marker
    var myPositionCircle_2: UIImageView! // Self Position Marker
    var myPositionCircle_3: UIImageView! // Self Position Marker
    var nameCardMoreOptions: UIImageView! // Map Namecard
    var percent: Double = 0 // Pan gesture var
    var placeArt = #imageLiteral(resourceName: "placePinArt")
    var placeBeauty = #imageLiteral(resourceName: "placePinBoutique")
    var placeBoba = #imageLiteral(resourceName: "placePinBoba")
    var placeBurger = #imageLiteral(resourceName: "placePinBurger")
    var placeCinema = #imageLiteral(resourceName: "placePinCinema")
    var placeCoffee = #imageLiteral(resourceName: "placePinCoffee")
    var placeDessert = #imageLiteral(resourceName: "placePinDesert")
    var placeFoodtruck = #imageLiteral(resourceName: "placePinFoodtruck")
    var placeMarkers = [GMSMarker]()
    var placeNames = [Double]()
    var placePins = [PlacePin]()
    var placePizza = #imageLiteral(resourceName: "placePinPizza")
    var placeSport = #imageLiteral(resourceName: "placePinSport")
    var polygonInside: UIImageView! // Filter Button
    var polygonOutside: UIImageView! // Filter Button
    var previousZoom: Float = 13.8
    var refreshPins = true
    var refreshPlaces = true
    var refreshUsers = true
    var reportNameCard: UIButton! // Map Namecard
    var selfMarkerIcon: UIButton! // Self Position Marker
    var shareNameCard: UIButton! // Map Namecard
    var sizeFrom: CGFloat = 0 // Pan gesture var
    var sizeTo: CGFloat = 0 // Pan gesture var
    var spaceFilter: CGFloat = 0 // Pan gesture var
    var spaceMenu: CGFloat = 0 // Pan gesture var
    var stringFilterValue = "comment,chat_room,media" // Class global variable to control the filter
    var subviewSelfMarker: UIView! // Self Position Marker
    var tempMarker: UIImageView! // temp marker, it is a UIImageView
    var timerLoadRegionPins: Timer! // timer to renew map pins
    var timerLoadRegionPlacePins: Timer! // timer to renew map places pin
    var timerUpdateSelfLocation: Timer! // timer to renew update user pins
    var uiViewNameCard: UIView! // Map Namecard
    var uiviewDistanceRadius: UIView!
    var uiviewFilterMenu: UIView! // Filter Menu
    var uiviewUserGender: UIView! // Map Namecard
    var userPins = [UserPin]()
    
    // System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        isUserLoggedIn()
        getUserStatus()
        loadMapView()
        loadTransparentNavBarItems()
        loadNameCard()
        timerSetup()
        openedPinListSetup()
        updateSelfInfo()
        loadSelfMarkerSubview()
        reloadSelfMarker()
        loadButton()
        loadMFilterSlider()
        loadMapFilter()
        filterAndYelpSetup()
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
                self.selfMarkerIcon.setImage(UIImage(named: "miniAvatar_19"), for: .normal)
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
            self.currentLocation2D = CLLocationCoordinate2DMake(currentLatitude, currentLongitude)
            let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 13.8)
            self.faeMapView.camera = camera
            reloadSelfPosAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                self.refreshMap(pins: true, users: true, places: true)
            })
        }
        
        if let location = locations.last {
            let points = self.faeMapView.projection.point(for: location.coordinate)
            self.subviewSelfMarker.center = points
            self.uiviewDistanceRadius.center = points
            self.currentLocation = location
            self.currentLocation2D = location.coordinate
            self.currentLatitude = location.coordinate.latitude
            self.currentLongitude = location.coordinate.longitude
        }
    }
}
