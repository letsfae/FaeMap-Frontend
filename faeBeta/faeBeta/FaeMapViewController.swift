//
//  FaeMapViewController.swift
//  Using GoogleMaps
//
//  Created by Yue on 5/31/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import MapKit
import CCHMapClusterController

let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height
let screenWidthFactor: CGFloat = UIScreen.main.bounds.width / 414
let screenHeightFactor: CGFloat = UIScreen.main.bounds.height / 736

class FaeMapViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate {
    
    let floatFilterHeight = 542 * screenHeightFactor // Map Filter height
    let locManager = CLLocationManager() // location manage
    let nameCardAnchor = CGPoint(x: screenWidth / 2, y: 451 * screenHeightFactor) // Map Namecard
    let startFrame = CGRect(x: 414 / 2, y: 451, w: 0, h: 0) // Map Namecard
    let storageForOpenedPinList = UserDefaults.standard // Local Storage for storing opened pin id, for opened pin list use
    let yelpManager = YelpManager() // Yelp API
    let yelpQuery = YelpQuery() // Yelp API
    var uiviewAvatarShadow: UIView! // Map Namecard
    var btnCardChat: UIButton! // Map Namecard
    var btnChatOnMap: UIButton!
    var btnCardCloseOptions: UIButton! // Map Namecard
    var btnDraggingMenu: UIButton! // Filter Menu
    var btnCardProfile: UIButton! // Map Namecard
    var btnCardFav: UIButton! // Map Namecard
    var btnLeftWindow: UIButton!
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
    var btnMainMapSearch: UIButton!
    var btnMapFilter: UIButton! // Filter Button
    var btnCardOptions: UIButton! // Map Namecard
    var btnPinOnMap: UIButton!
    var btnSelfLocation: UIButton!
    var btnCardShowSelf: UIButton! // Map Namecard
    var btnToNorth: UIButton!
    var btnCardClose: UIButton! // Map Namecard
    var btnWindBell: UIButton!
    var boolCanUpdateSocialPin = true
    var boolCanUpdatePlacePin = true
    var boolCanUpdateUserPin = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    var curLoc2D = CLLocationCoordinate2DMake(34.0205378, -118.2854081) // location manage
    var boolIsFirstLoad = true // location manage
    var btnEditNameCard: UIButton! // Map Namecard
    var end: CGFloat = 0 // Pan gesture var
    var faeMapView: MKMapView!
    var faeUserPins = [FaePinAnnotation]()
    var filterCircle_1: UIImageView! // Filter btn inside circles
    var filterCircle_2: UIImageView! // Filter btn inside circles
    var filterCircle_3: UIImageView! // Filter btn inside circles
    var filterCircle_4: UIImageView! // Filter btn inside circles
    var filterPinStatusDic = [String: MFilterButton]() // Filter data processing
    var filterPinTypeDic = [String: MFilterButton]() // Filter data processing
    var filterPlaceDic = [String: MFilterButton]() // Filter data processing
    var filterSlider: UISlider! // Filter Slider
    var imgCardAvatar: UIImageView! // Map Namecard
    var imgCardBack: UIImageView! // Map Namecard
    var imgCardCover: UIImageView! // Map Namecard
    var imgCardLine: UIImageView! // Map Namecard
    var uiviewCardPrivacy: FaeGenderView! // Map Namecard Gender & Age
    var lblNickName: UILabel! // Map Namecard
    var lblShortIntro: UILabel! // Map Namecard
    var labelUnreadMessages: UILabel! // Unread Messages Label
    var lblDistanceDisplay: UILabel!
    var lblFilterDist: UILabel! // Filter Slider
    var mapFilterArrow: UIImageView! // Filter Button
    var mapPins = [MapPin]()
    var markerMask: UIView! // mask to prevent UI action
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
    var tempMarker: UIImageView! // temp marker, it is a UIImageView
    var timerLoadRegionPins: Timer! // timer to renew map pins
    var timerLoadRegionPlacePins: Timer! // timer to renew map places pin
    var timerUpdateSelfLocation: Timer! // timer to renew update user pins
    var uiviewCardShadow: UIView! // Map Namecard
    var uiviewDistanceRadius: UIView!
    var uiviewFilterMenu: UIView! // Filter Menu
    var prevBearing: Double = 0
    var intPinDistance: Int = 65
    
    var mapClusterManager: CCHMapClusterController!
    
    // MARK: - For Compass Rotation
    var rotationGesture: UIRotationGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    var pinchGesture: UIPinchGestureRecognizer!
    var displayLink: CADisplayLink!
    var mapChangedFromUserInteraction = false
    // The moment the user let go of the map.
    var startRotateOut = TimeInterval(0)
    
    // After that, if there is still momentum left, the velocity is > 0.
    // The velocity of the rotation gesture in radians per second.
    var remainingVelocityAfterUserInteractionEnded = CGFloat(0)
    
    // We need some values from the last frame
    var prevHeading = CLLocationDirection()
    var prevRotationInRadian = CGFloat(0)
    var prevTime = TimeInterval(0)
    
    // The momentum gets slower ower time
    var currentlyRemainingVelocity = CGFloat(0)
    
    // As soon as this optional is set the initial mode is determined.
    // If it's true than the map is in rotation mode,
    // if false, the map is in 3D position adjust mode.
    var initialMapGestureModeIsRotation: Bool?
    
    var FILTER_ENABLE = false
    var COMPASS_ROTATION_ENABLE = false
    
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
        loadMFilterSlider()
        loadMapFilter()
        loadButton()
        filterAndYelpSetup()
//        loadGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locManager.requestAlwaysAuthorization()
        loadTransparentNavBarItems()
        loadMapChat()
        btnCardClose.alpha = 0
        reloadSelfPosAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        checkDisplayNameExisitency()
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromLoginSignup(_:)), name: NSNotification.Name(rawValue: "returnFromLoginSignup"), object: nil)
        updateGenderAge()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[FaeMapViewController - viewWillDisappear]")
        navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func checkDisplayNameExisitency() {
        getFromURL("users/name_card", parameter: nil, authentication: headerAuthentication()) { status, result in
            if status / 100 == 2 {
                let rsltJSON = JSON(result!)
                if let withNickName = rsltJSON["nick_name"].string {
                    joshprint("[checkDisplayNameExisitency] display name: \(withNickName)")
                } else {
                    joshprint("[checkDisplayNameExisitency] display name did not setup")
                    self.loadFirstLoginVC()
                }
            }
        }
    }
    
    func returnFromLoginSignup(_ notification: NSNotification) {
        print("[returnFromLoginSignup] yes it is")
        refreshMap(pins: true, users: true, places: true)
    }
    
    func isUserLoggedIn() {
        let shareAPI = LocalStorageManager()
        _ = shareAPI.readLogInfo()
        if is_Login == 0 {
            jumpToWelcomeView(animated: false)
        }
    }
    
    fileprivate func updateGenderAge() {
        let updateGenderAge = FaeUser()
        updateGenderAge.whereKey("show_gender", value: "true")
        updateGenderAge.whereKey("show_age", value: "true")
        updateGenderAge.updateNameCard { status, _ in
            if status / 100 == 2 {
                // print("[showGenderAge] Successfully update namecard")
            } else {
                print("[showGenderAge] Fail to update namecard")
            }
        }
    }
    
    fileprivate func openedPinListSetup() {
        let emptyArrayList = [String]()
        storageForOpenedPinList.set(emptyArrayList, forKey: "openedPinList")
    }
    
    fileprivate func filterAndYelpSetup() {
        if FILTER_ENABLE {
            checkFilterShowAll(btnMFilterShowAll)
        }
        yelpQuery.setCatagoryToAll()
    }
    
    func timerSetup() {
        invalidateAllTimer()
        timerUpdateSelfLocation = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(updateSelfLocation), userInfo: nil, repeats: true)
        timerLoadRegionPins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(loadCurrentRegionPins), userInfo: nil, repeats: true)
//        timerLoadRegionPlacePins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(loadCurrentRegionPlacePins), userInfo: nil, repeats: true)
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
    
    fileprivate func loadFirstLoginVC() {
        let firstTimeLoginVC = FirstTimeLoginViewController()
        firstTimeLoginVC.modalPresentationStyle = .overCurrentContext
        present(firstTimeLoginVC, animated: false, completion: nil)
    }
    
    func updateTimerForAllPins() {
        updateTimerForLoadRegionPin()
        updateTimerForUserPin()
        updateTimerForLoadRegionPlacePin()
    }
    
    // Testing back from background
    func appBackFromBackground() {
        if faeMapView != nil {
            updateTimerForAllPins()
            renewSelfLocation()
            reloadSelfPosAnimation()
        }
    }
    
    func reloadSelfPosAnimation() {
        if userStatus != 5 {
            getSelfAccountInfo()
        } else {
            faeMapView.showsUserLocation = true
        }
    }
    
    func jumpToWelcomeView(animated: Bool) {
        let welcomeVC = WelcomeViewController()
        self.navigationController?.pushViewController(welcomeVC, animated: true)
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
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func refreshMap(pins: Bool, users: Bool, places: Bool) {
        if users {
            updateTimerForUserPin()
        }
        if pins {
            updateTimerForLoadRegionPin()
        }
        if places {
            updateTimerForLoadRegionPlacePin()
        }
    }
    
    // MARK: -- Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.global(qos: .default).async {
            if self.boolIsFirstLoad {
                self.boolIsFirstLoad = false
//                self.curLoc = manager.location
//                self.curLat = self.curLoc.coordinate.latitude
//                self.curLon = self.curLoc.coordinate.longitude
                self.curLoc2D = CLLocationCoordinate2DMake(LocManage.shared.curtLat, LocManage.shared.curtLong)
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.curLoc2D, 3000, 3000)
                DispatchQueue.main.async(execute: {
                    self.faeMapView.setRegion(coordinateRegion, animated: false)
                    self.reloadSelfPosAnimation()
                    self.refreshMap(pins: true, users: true, places: true)
                })
            }
            
            if let location = locations.last {
                let points = self.faeMapView.convert(location.coordinate, toPointTo: nil)
//                self.curLoc = location
//                self.curLoc2D = location.coordinate
//                self.curLat = location.coordinate.latitude
//                self.curLon = location.coordinate.longitude
                DispatchQueue.main.async(execute: {
                    if self.FILTER_ENABLE {
                        self.uiviewDistanceRadius.center = points
                    }
                })
            }
        }
    }
}
