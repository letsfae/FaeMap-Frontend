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

enum MapMode {
    case normal
    case routing
    case pinDetail
    case selecting
}

class FaeMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var lblSearchContent: UILabel!
    var btnOpenChat: UIButton!
    var btnLeftWindow: UIButton!
    var btnMainMapSearch: UIButton!
    var btnDiscovery: UIButton!
    var btnLocateSelf: FMLocateSelf!
    var btnCompass: FMCompass!
    var boolCanUpdateSocialPin = true
    var readyUpdatePlacePin = true
    var boolCanUpdateUserPin = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    var faeMapView: FaeMapView!
    var faeUserPins = [FaePinAnnotation]()
    var faePlacePins = [FaePinAnnotation]()
    var lblUnreadCount: UILabel! // Unread Messages Label
    var mapPins = [MapPin]()
    var refreshPins = true
    var refreshPlaces = true
    var refreshUsers = true
    var stringFilterValue = "comment,chat_room,media" // Class global variable to control the filter
    var tempMarker: UIImageView! // temp marker, it is a UIImageView
    var timerLoadRegionPins: Timer! // timer to renew map pins
    var timerLoadRegionPlacePins: Timer! // timer to renew map places pin
    var timerUserPin: Timer? // timer to renew update user pins
    var prevBearing: Double = 0
    var mapClusterManager: CCHMapClusterController!
    let FILTER_ENABLE = true
    var PLACE_ENABLE = true
    let USER_ENABLE = false
    let floatFilterHeight = 471 * screenHeightFactor // Map Filter height
    var btnFilterIcon: FMFilterIcon! // Filter Button
    var uiviewFilterMenu: FMFilterMenu! // Filter Menu
    var sizeFrom: CGFloat = 0 // Pan gesture var
    var sizeTo: CGFloat = 0 // Pan gesture var
    var end: CGFloat = 0 // Pan gesture var
    var percent: Double = 0 // Pan gesture var
    var imgSchbarShadow: UIImageView!
    var selectedAnnView: PlacePinAnnotationView?
    var selectedAnn: FaePinAnnotation?
    var uiviewPlaceBar = FMPlaceInfoBar()
    var boolPreventUserPinOpen = false
    var btnClearSearchRes: UIButton!
    var uiviewNameCard: FMNameCardView!
    var mkOverLay = [MKOverlay]()
    var START_WAVE_ANIMATION = false
    var AUTO_REFRESH = true
    var AUTO_CIRCLE_PINS = true
    var HIDE_AVATARS = false
    
    var placeResultTbl = FMPlacesTable()
    var btnTapToShowResultTbl: UIButton!
    
    var swipingState: PlaceResultBarState = .map
    var prevMapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var prevAltitude: CLLocationDistance = 0
    
    var btnPlacePinActionOnSrchBar: FMPlaceActionBtn!
    var uiviewPlaceList: AddPlaceToCollectionView!
    var uiviewAfterAdded: AfterAddedToListView!
    var imgDistIndicator: FMDistIndicator!
    var uiviewChooseLocs: FMChooseLocs!
    
    var arrPlaceData = [PlacePin]()
    var tempFaePins = [FaePinAnnotation]()
    
    var startPointAddr: RouteAddress!
    var destinationAddr: RouteAddress!
    var addressAnnotations = [AddressAnnotation]()
    var mapMode: MapMode = .normal
    
    // System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        isUserLoggedIn()
        getUserStatus()
        
        loadNameCard()
        loadMapFilter()
        loadMapView()
        loadButton()
        loadPlaceDetail()
        loadPlaceListView()
        loadDistanceComponents()
        
        timerSetup()
        updateSelfInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(firstUpdateLocation), name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMapChat()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userAvatarAnimationRestart"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mapFilterAnimationRestart"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadUser&MapInfo"), object: nil)
        updateTimerForAllPins()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        renewSelfLocation()
        checkDisplayNameExisitency()
        updateGenderAge()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func getUserStatus() {
        guard let user_status = LocalStorageManager.shared.readByKey("userStatus") as? Int else { return }
        userStatus = user_status
    }
    
    func jumpToMyFaeMainPage() {
        let vc = MyFaeMainPageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateSelfInfo() {
        DispatchQueue.global(qos: .utility).async {
            let updateNickName = FaeUser()
            updateNickName.getSelfNamecard { (status: Int, message: Any?) in
                guard status / 100 == 2 else {
                    self.jumpToWelcomeView(animated: true)
                    return
                }
                let nickNameInfo = JSON(message!)
                if let str = nickNameInfo["nick_name"].string {
                    Key.shared.nickname = str
                }
            }
        }
    }
    
    func checkDisplayNameExisitency() {
        getFromURL("users/name_card", parameter: nil, authentication: headerAuthentication()) { status, result in
            guard status / 100 == 2 else { return }
            let rsltJSON = JSON(result!)
            if let _ = rsltJSON["nick_name"].string {
                // joshprint("[checkDisplayNameExisitency] display name: \(withNickName)")
            } else {
                // joshprint("[checkDisplayNameExisitency] display name did not setup")
                self.loadFirstLoginVC()
            }
        }
    }
    
    func isUserLoggedIn() {
        _ = LocalStorageManager.shared.readLogInfo()
        if Key.shared.is_Login == 0 {
            jumpToWelcomeView(animated: true)
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
    
    func timerSetup() {
        invalidateAllTimer()
        timerUserPin = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(updateUserPins), userInfo: nil, repeats: true)
        //        timerLoadRegionPlacePins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(loadCurrentRegionPlacePins), userInfo: nil, repeats: true)
    }
    
    func invalidateAllTimer() {
        if timerLoadRegionPins != nil {
            timerLoadRegionPins.invalidate()
        }
        timerUserPin?.invalidate()
        timerUserPin = nil
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
    
    func jumpToWelcomeView(animated: Bool) {
        let welcomeVC = WelcomeViewController()
        navigationController?.pushViewController(welcomeVC, animated: false)
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
