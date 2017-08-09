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

class FaeMapViewController: UIViewController, UIGestureRecognizerDelegate, MapSearchDelegate {
    var count:Int = 0
    
    var lblSearchContent: UILabel!
    let nameCardAnchor = CGPoint(x: 0.5, y: 1.0) // Map Namecard
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
    var btnLocateSelf: FMLocateSelf!
    var btnCardShowSelf: UIButton! // Map Namecard
    var btnCompass: FMCompass!
    var btnCardClose: UIButton! // Map Namecard
    var btnWindBell: UIButton!
    var boolCanUpdateSocialPin = true
    var boolCanUpdatePlacePin = true
    var boolCanUpdateUserPin = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
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
    
    var btnClearSearchRes: UIButton!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.firstUpdateLocation), name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.view?.sendSubview(toBack: (navigationController?.navigationBar)!)
        print("chat view will disappear")
        //navigationController?.setNavigationBarHidden(true, animated: animated)
        loadTransparentNavBarItems()
        loadMapChat()
        reloadSelfPosAnimation()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "willEnterForeground"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        renewSelfLocation()
        checkDisplayNameExisitency()
        updateGenderAge()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[FaeMapViewController - viewWillDisappear]")
        //navigationController?.setNavigationBarHidden(true, animated: animated)
        //navigationController?.view?.bringSubview(toFront: (navigationController?.navigationBar)!)
        navigationController?.navigationBar.isTranslucent = false
        //navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
    
    func isUserLoggedIn() {
        let shareAPI = LocalStorageManager()
        _ = shareAPI.readLogInfo()
        if Key.shared.is_Login == 0 {
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
        navigationController?.pushViewController(welcomeVC, animated: true)
    }
    
    // MARK: -- Load Navigation Items
    fileprivate func loadTransparentNavBarItems() {
        navigationController?.navigationBar.tintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
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
}
