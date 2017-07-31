//
//  FaeMapViewController.swift
//
//  Created by Yue on 5/31/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import MapKit
import CCHMapClusterController

class FaeMapViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    var lblSearchContent: UILabel!
    let locManager = CLLocationManager() // location manage
    let nameCardAnchor = CGPoint(x: screenWidth / 2, y: 451 * screenHeightFactor) // Map Namecard
    let startFrame = CGRect(x: 414 / 2, y: 451, w: 0, h: 0) // Map Namecard
    let storageForOpenedPinList = UserDefaults.standard // Local Storage for storing opened pin id, for opened pin list use
    var imgAvatarShadow: UIImageView! // Map Namecard
    var btnCardChat: UIButton! // Map Namecard
    var btnOpenChat: UIButton!
    var btnCardCloseOptions: UIButton! // Map Namecard
    var btnCardProfile: UIButton! // Map Namecard
    var btnCardFav: UIButton! // Map Namecard
    var btnLeftWindow: UIButton!
    var btnMainMapSearch: UIButton!
    var btnCardOptions: UIButton! // Map Namecard
    var btnDiscovery: UIButton!
    var btnSelfCenter: UIButton!
    var btnCardShowSelf: UIButton! // Map Namecard
    var btnCompass: UIButton!
    var btnCardClose: UIButton! // Map Namecard
    var btnWindBell: UIButton!
    var boolCanUpdateSocialPin = true
    var boolCanUpdatePlacePin = true
    var boolCanUpdateUserPin = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    var curLoc2D = CLLocationCoordinate2DMake(34.0205378, -118.2854081) // location manage
    var boolIsFirstLoad = true // location manage
    var btnEditNameCard: UIButton! // Map Namecard
    
    var faeMapView: MKMapView!
    var faeUserPins = [FaePinAnnotation]()
    var faePlacePins = [FaePinAnnotation]()
    var imgCardAvatar: UIImageView! // Map Namecard
    var imgCardBack: UIImageView! // Map Namecard
    var imgCardCover: UIImageView! // Map Namecard
    var imgCardLine: UIImageView! // Map Namecard
    var uiviewCardPrivacy: FaeGenderView! // Map Namecard Gender & Age
    var lblNickName: UILabel! // Map Namecard
    var lblShortIntro: UILabel! // Map Namecard
    var lblUnreadCount: UILabel! // Unread Messages Label
    var lblDistanceDisplay: UILabel!
    var mapPins = [MapPin]()
    var markerMask: UIView! // mask to prevent UI action
    var nameCardMoreOptions: UIImageView! // Map Namecard
    
    var previousZoom: Float = 13.8
    var refreshPins = true
    var refreshPlaces = true
    var refreshUsers = true
    var reportNameCard: UIButton! // Map Namecard
    var shareNameCard: UIButton! // Map Namecard
    var stringFilterValue = "comment,chat_room,media" // Class global variable to control the filter
    var tempMarker: UIImageView! // temp marker, it is a UIImageView
    var timerLoadRegionPins: Timer! // timer to renew map pins
    var timerLoadRegionPlacePins: Timer! // timer to renew map places pin
    var timerUpdateSelfLocation: Timer! // timer to renew update user pins
    var uiviewDistanceRadius: UIView!
    var prevBearing: Double = 0
    var intPinDistance: Int = 65
    var aroundUsrId: Int = -1
    
    var mapClusterManager: CCHMapClusterController!
    
    let FILTER_ENABLE = true
    let PLACE_ENABLE = true
    let USER_ENABLE = false
    
    let floatFilterHeight = 471 * screenHeightFactor // Map Filter height
    
    var btnFilterIcon: MapFilterIcon! // Filter Button
    var uiviewFilterMenu: MapFilterMenu! // Filter Menu
    
    var sizeFrom: CGFloat = 0 // Pan gesture var
    var sizeTo: CGFloat = 0 // Pan gesture var
    var spaceFilter: CGFloat = 0 // Pan gesture var
    var spaceMenu: CGFloat = 0 // Pan gesture var
    var end: CGFloat = 0 // Pan gesture var
    var percent: Double = 0 // Pan gesture var
    
    var imgSchbarShadow: UIImageView!
    
    var selectedAnnView: PlacePinAnnotationView?
    var selectedAnn: FaePinAnnotation?
    
    var placeResultBar = PlaceResultView()
    
    var preventUserPinOpen = false
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
        loadButton()
        loadMapFilter()
        loadPlaceDetail()
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
        // send noti here to start filter icon spinning
        checkDisplayNameExisitency()
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromLoginSignup(_:)), name: NSNotification.Name(rawValue: "returnFromLoginSignup"), object: nil)
        updateGenderAge()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[FaeMapViewController - viewWillDisappear]")
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func checkDisplayNameExisitency() {
        getFromURL("users/name_card", parameter: nil, authentication: headerAuthentication()) { status, result in
            guard status / 100 == 2 else { return }
            let rsltJSON = JSON(result!)
            if let withNickName = rsltJSON["nick_name"].string {
                joshprint("[checkDisplayNameExisitency] display name: \(withNickName)")
            } else {
                joshprint("[checkDisplayNameExisitency] display name did not setup")
                self.loadFirstLoginVC()
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
    
    func reloadSelfPosAnimation() {
        if userStatus != 5 {
            
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
        navigationController?.navigationBar.tintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1)
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
        guard boolIsFirstLoad else { return }
        boolIsFirstLoad = false
        DispatchQueue.global(qos: .default).async {
            self.curLoc2D = CLLocationCoordinate2DMake(LocManager.shared.curtLat, LocManager.shared.curtLong)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.curLoc2D, 3000, 3000)
            DispatchQueue.main.async(execute: {
                self.faeMapView.setRegion(coordinateRegion, animated: false)
                self.reloadSelfPosAnimation()
                self.refreshMap(pins: true, users: true, places: true)
            })
        }
    }
}
