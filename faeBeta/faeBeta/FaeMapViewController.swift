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
//import CCHMapClusterController
import RealmSwift

enum MapMode {
    case normal
    case routing
    case pinDetail
    case selecting
    case explore
    case collection
    case allPlaces
}

enum FaeMode {
    case on
    case on_create
    case off
}

enum ModeSelectLocation {
    case on
    case off
}

enum RoutingMode {
    case fromMap
    case fromPinDetail
}

class FaeMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MapView Data and Control
    var faeMapView: FaeMapView!
    var placeClusterManager: CCHMapClusterController!
    var userClusterManager: CCHMapClusterController!
    var faeUserPins = [FaePinAnnotation]()
    var timerUserPin: Timer? // timer to renew update user pins
    var faePlacePins = [FaePinAnnotation]()
    var setPlacePins = Set<Int>()
    var arrPlaceData = [PlacePin]()
    var timerLoadMessages: Timer?
    var selfAnView: SelfAnnotationView?
    
    // General
    var btnBackToExp: UIButton!
    
    // Search Bar
    var imgSchbarShadow: UIImageView!
    var imgSearchIcon: UIImageView!
    var imgAddressIcon: UIImageView!
    var btnLeftWindow: UIButton!
    var btnCancelSelect: UIButton!
    var lblSearchContent: UILabel!
    var btnMainMapSearch: UIButton!
    var btnClearSearchRes: UIButton!
    var uiviewPinActionDisplay: FMPinActionDisplay! // indicate which action is being pressing to release
    
    // Explore Button
    var clctViewMap: UICollectionView!
    var imgExpbarShadow: UIImageView!
    var lblExpContent: UILabel!
    var arrExpPlace = [PlacePin]()
    var intCurtPage = 0
    var visibleClusterPins = [CCHMapClusterAnnotation]()
    
    // Compass and Locating Self
    var btnZoom: FMZoomButton!
    var btnLocateSelf: FMLocateSelf!
    
    // Chat Button
    var btnOpenChat: UIButton!
    var lblUnreadCount: UILabel! // Unread Messages Label
    
    // Discovery Button
    var btnDiscovery: UIButton!
    
    // Filter Hexagon and Menu
    var btnFilterIcon: FMFilterIcon! // Filter Button
    var uiviewFilterMenu: FMFilterMenu! // Filter Menu
    var sizeFrom: CGFloat = 0 // Pan gesture var
    var sizeTo: CGFloat = 0 // Pan gesture var
    var end: CGFloat = 0 // Pan gesture var
    var percent: Double = 0 // Pan gesture var
    let floatFilterHeight = 471 * screenHeightFactor + device_offset_bot // Map Filter height
    
    // Selected Place Control
    var selectedPlaceView: PlacePinAnnotationView?
    var selectedPlace: FaePinAnnotation?
    var uiviewPlaceBar = FMPlaceInfoBar()
    var swipingState: PlaceInfoBarState = .map {
        didSet {
            guard fullyLoaded else { return }
            btnTapToShowResultTbl.alpha = swipingState == .multipleSearch ? 1 : 0
        }
    }
    var boolSelecting = false
    var firstSelectPlace = true
    
    // Results from Search
    var btnTapToShowResultTbl: UIButton!
    var tblPlaceResult: FMPlacesTable!
    var placesFromSearch = [FaePinAnnotation]()
    
    // Name Card
    var uiviewNameCard: FMNameCardView!
    
    // MapView Offset Control
    var prevMapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var prevAltitude: CLLocationDistance = 0
    
    // Collecting Pin Control
    var uiviewSavedList: AddPinToCollectionView!
    var uiviewAfterAdded: AfterAddedToListView!
    
    // Routes Calculator
    var arrRoutes = [MKOverlay]()
    var tempFaePins = [FaePinAnnotation]()
    var startPointAddr: RouteAddress!
    var destinationAddr: RouteAddress!
    var addressAnnotations = [AddressAnnotation]()
    var btnDistIndicator: FMDistIndicator!
    var uiviewChooseLocs: FMChooseLocs!
    var routeAddress: RouteAddress!
    var routingMode: RoutingMode = .fromMap
    
    // Location Pin Control
    var selectedLocation: FaePinAnnotation?
    var uiviewLocationBar: FMLocationInfoBar!
    var locAnnoView: LocPinAnnotationView?
    var activityIndicator: UIActivityIndicatorView!
    var locationPinClusterManager: CCHMapClusterController!
    
    // Chat
    let faeChat = FaeChat()
    
    // Collections Managements
    var arrCtrlers = [UIViewController]()
    var boolFromMap = true
    
    var boolNotiSent = false
    
    var boolCanUpdateUsers = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    let FILTER_ENABLE = true
    var PLACE_ENABLE = true
    let USER_ENABLE = false
    var boolPreventUserPinOpen = false
    var AUTO_REFRESH = true
    var AUTO_CIRCLE_PINS = true
    var HIDE_AVATARS = false
    var fullyLoaded = false // indicate if all components are fully loaded
    var boolCanUpdatePlaces = true
    
    var unreadNotiToken: NotificationToken? = nil
    
    // Filter Menu Place Collection Interface to Show All Saved Pins
    var completionCount = 0 {
        didSet {
            guard fullyLoaded else { return }
            guard desiredCount > 0 else { return }
            self.placeClusterManager.addAnnotations(self.placesFromSearch, withCompletionHandler: nil)
            self.zoomToFitAllAnnotations(annotations: self.placesFromSearch)
        }
    }
    var desiredCount = 0
    
    // System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        storeRealmCollectionFromServer()
        
        Key.shared.FMVCtrler = self
        
        isUserLoggedIn()
        getUserStatus()
        
        loadNameCard()
        loadMapFilter()
        loadMapView()
        loadButton()
        view.bringSubview(toFront: uiviewFilterMenu)
        loadExploreBar()
        loadPlaceDetail()
        loadPlaceListView()
        loadDistanceComponents()
        loadSmallClctView()
        loadLocationView()
        
        timerSetup()
        updateSelfInfo()
        
        checkDisplayNameExisitency()
        
        NotificationCenter.default.addObserver(self, selector: #selector(firstUpdateLocation), name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
        
        fullyLoaded = true
        
//        let line = UIView(frame: CGRect(x: 0, y: screenHeight - 35, width: screenWidth, height: 1))
//        line.layer.borderColor = UIColor.black.cgColor
//        line.layer.borderWidth = 1
//        view.addSubview(line)
        
//        joshprint("id:", Key.shared.user_id)
    }
    
    deinit {
        unreadNotiToken?.invalidate()
        invalidateAllTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMapChat()
        renewSelfLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mapFilterAnimationRestart"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadUser&MapInfo"), object: nil)
        
        updateTimerForAllPins()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        Key.shared.selectedLoc = LocManager.shared.curtLoc.coordinate
    }
    
    // MARK: - Switches
    
    var modeLocation: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            imgExpbarShadow.isHidden = modeLocation == .off
            imgSchbarShadow.isHidden = modeLocation != .off
            if modeLocation != .off {
                Key.shared.onlineStatus = 5
                lblExpContent.attributedText = nil
                lblExpContent.text = "View Location"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
            } else {
                Key.shared.onlineStatus = 1
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
            }
        }
    }
    
    var modeLocCreating: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            if modeLocCreating == .off {
                uiviewLocationBar.hide()
                activityIndicator.stopAnimating()
                if selectedLocation != nil {
                    locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: {
                        self.deselectAllLocations()
                    })
                }
                if uiviewAfterAdded.frame.origin.y != screenHeight {
                    uiviewAfterAdded.hide()
                }
            }
        }
    }
    
    var modeExplore: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            
            btnLeftWindow.isHidden = modeExplore == .on
            placeClusterManager.maxZoomLevelForClustering = modeExplore == .on ? 0 : Double.greatestFiniteMagnitude
            imgSchbarShadow.isHidden = modeExplore == .on
            btnZoom.isHidden = modeExplore == .on
            btnLocateSelf.isHidden = modeExplore == .on
            btnOpenChat.isHidden = modeExplore == .on
            btnFilterIcon.isHidden = modeExplore == .on
            btnDiscovery.isHidden = modeExplore == .on
            
            clctViewMap.isHidden = modeExplore == .off
            imgExpbarShadow.isHidden = modeExplore == .off
        }
    }
    
    var modeAllPlaces: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            btnLeftWindow.isHidden = modeAllPlaces == .on
            imgExpbarShadow.isHidden = modeAllPlaces == .off
        }
    }
    
    var mapMode: MapMode = .normal {
        didSet {
            guard fullyLoaded else { return }
            
            imgAddressIcon.isHidden = mapMode == .normal
            btnCancelSelect.isHidden = mapMode == .normal
            
            if mapMode == .selecting {
                btnDistIndicator.lblDistance.text = "Select"
            } else {
                lblSearchContent.text = "Search Fae Map"
                btnDistIndicator.lblDistance.text = btnDistIndicator.strDistance
            }
            imgSearchIcon.isHidden = mapMode == .selecting
            btnDistIndicator.isUserInteractionEnabled = mapMode == .selecting
            btnLeftWindow.isHidden = mapMode == .selecting || mapMode == .pinDetail
            lblSearchContent.textColor = mapMode == .selecting ? UIColor._898989() : UIColor._182182182()
            
            imgExpbarShadow.isHidden = mapMode != .pinDetail && mapMode != .collection
            imgSchbarShadow.isHidden = mapMode == .pinDetail || mapMode == .collection
            
            btnMainMapSearch.isHidden = mapMode == .routing || mapMode == .selecting
            Key.shared.onlineStatus = mapMode == .routing || mapMode == .selecting ? 5 : 1
            if mapMode == .routing || mapMode == .selecting {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
            }
            
            if mapMode == .allPlaces {
                btnLeftWindow.isHidden = true
                imgExpbarShadow.isHidden = false
                return
            }
        }
    }
    
    func getUserStatus() {
        guard let user_status = LocalStorageManager.shared.readByKey("userStatus") as? Int else { return }
        Key.shared.onlineStatus = user_status
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
                    self.jumpToWelcomeView(animated: false)
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
        getFromURL("users/name_card", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
            guard status / 100 == 2 else { return }
            let rsltJSON = JSON(result!)
            if let _ = rsltJSON["nick_name"].string {
                DispatchQueue.main.async {
                    sendWelcomeMessage()
                }
            } else {
                DispatchQueue.main.async {
                    self.loadFirstLoginVC()
                    sendWelcomeMessage()
                }
            }
        }
    }
    
    func isUserLoggedIn() {
        _ = LocalStorageManager.shared.readLogInfo()
        if Key.shared.is_Login == 0 {
            jumpToWelcomeView(animated: false)
        }
    }
    
    func updateGenderAge() {
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
        timerLoadMessages = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMessages), userInfo: nil, repeats: true)
    }
    
    func invalidateAllTimer() {
        timerUserPin?.invalidate()
        timerUserPin = nil
        timerLoadMessages?.invalidate()
        timerLoadMessages = nil
    }
    
    func loadFirstLoginVC() {
        updateGenderAge()
        let firstTimeLoginVC = FirstTimeLoginViewController()
        firstTimeLoginVC.modalPresentationStyle = .overCurrentContext
        present(firstTimeLoginVC, animated: false, completion: nil)
        let updateMiniAvatar = FaeUser()
        let males: [Int] = [1, 2, 3, 6, 7, 9, 14, 15, 16, 18]
        var females = [Int]()
        for i in males {
            females.append(i + 18)
        }
        let random = Int(Double.random(min: 0, max: Double(males.count - 1)))
        Key.shared.userMiniAvatar = Key.shared.gender == "male" ? males[random] : females[random]
        Key.shared.miniAvatar = "miniAvatar_\(Key.shared.userMiniAvatar)"
        LocalStorageManager.shared.saveInt("userMiniAvatar", value: Key.shared.userMiniAvatar)
        updateMiniAvatar.whereKey("mini_avatar", value: "\(Key.shared.userMiniAvatar - 1)")
        updateMiniAvatar.updateAccountBasicInfo({ (status: Int, _: Any?) in
            if status / 100 == 2 {
                print("Successfully update miniavatar")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
            } else {
                print("Fail to update miniavatar")
            }
        })
    }
    
    func updateTimerForAllPins() {
        updateTimerForLoadRegionPin()
        updateTimerForUserPin()
        updatePlacePins()
    }
    
    func jumpToWelcomeView(animated: Bool) {
        if Key.shared.navOpenMode == .welcomeFirst {
            navigationController?.popToRootViewController(animated: animated)
        } else {
            let welcomeVC = WelcomeViewController()
            navigationController?.pushViewController(welcomeVC, animated: animated)
            navigationController?.viewControllers = [welcomeVC]
            Key.shared.navOpenMode = .welcomeFirst
        }
    }
    
    func refreshMap(pins: Bool, users: Bool, places: Bool) {
        if users {
            updateTimerForUserPin()
        }
        if pins {
            updateTimerForLoadRegionPin()
        }
        if places {
            updatePlacePins()
        }
    }
    
    func reAddPlacePins(_ completion: (() -> ())? = nil) {
        for user in faeUserPins {
            user.isValid = true
        }
        userClusterManager.addAnnotations(faeUserPins, withCompletionHandler: {
            completion?()
        })
    }
    
    func reAddUserPins(_ completion: (() -> ())? = nil) {
        for user in faeUserPins {
            user.isValid = true
        }
        placeClusterManager.addAnnotations(faePlacePins, withCompletionHandler: {
            completion?()
        })
    }
    
    func removePlaceUserPins(_ placeComp: (() -> ())? = nil, _ userComp: (() -> ())? = nil) {
        removePlacePins {
            placeComp?()
        }
        removeUserPins {
            userComp?()
        }
    }
    
    func removePlacePins(_ completion: (() -> ())? = nil) {
        //let placesNeedToRemove = faePlacePins.filter({ $0 != selectedPlace })
        placeClusterManager.removeAnnotations(faePlacePins) {
            completion?()
        }
    }
    
    func removeUserPins(_ completion: (() -> ())? = nil) {
        for user in faeUserPins {
            user.isValid = false
        }
        userClusterManager.removeAnnotations(faeUserPins) {
            completion?()
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func storeRealmCollectionFromServer() {
        FaeCollection.shared.getCollections {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let collections = JSON(message!)
                guard let colArray = collections.array else {
                    print("[loadCollectionData] fail to parse collections info")
                    return
                }
                
                let realm = try! Realm()
                if realm.objects(RealmCollection.self).count == colArray.count {
                    return
                }
                
                for col in colArray {
                    let realmCol = RealmCollection(collection_id: col["collection_id"].intValue, name: col["name"].stringValue, user_id: col["user_id"].intValue, desp: col["description"].stringValue, type: col["type"].stringValue, is_private: col["is_private"].boolValue, created_at: col["created_at"].stringValue, count: col["count"].intValue, last_updated_at: col["last_updated_at"].stringValue)
                    
                    try! realm.write {
                        realm.add(realmCol, update: true)
                    }
                }
                print("Successfully get collections")
            } else {
                print("[Get Collections] Fail to Get \(status) \(message!)")
            }
        }
    }
}
