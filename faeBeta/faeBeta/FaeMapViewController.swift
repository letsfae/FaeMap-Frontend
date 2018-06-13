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
import RealmSwift
import IVBezierPathRenderer

enum MapMode {
    case normal
    case routing
    case selecting
    case collection
}

enum FaeMode {
    case on
    case on_create
    case off
}

class FaeMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MapView Data and Control
    private var faeMapView: FaeMapView!
    var placeClusterManager: CCHMapClusterController!
    var userClusterManager: CCHMapClusterController!
    private var faeUserPins = [FaePinAnnotation]()
    private var timerUserPin: Timer? // timer to renew update user pins
    private var faePlacePins = [FaePinAnnotation]()
    private var setPlacePins = Set<Int>()
    private var arrPlaceData = [PlacePin]()
    private var timerLoadMessages: Timer?
    private var selfAnView: SelfAnnotationView?
    private var PLACE_ANIMATED = true
    private var placeAdderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "adder queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // General
    private var btnBackToExp: UIButton!
    
    // Search Bar
    private var uiviewSchbarShadow: UIView!
    private var imgSearchIcon: UIImageView!
    private var imgAddressIcon: UIImageView!
    private var btnLeftWindow: UIButton!
    private var btnCancelSelect: UIButton!
    private var lblSearchContent: UILabel!
    private var btnMainMapSearch: UIButton!
    private var btnClearSearchRes: UIButton!
    var btnDropUpMenu: UIButton!
    private var uiviewPinActionDisplay: FMPinActionDisplay! // indicate which action is being pressing to release
    
    // Explore Button
    private var uiviewExpbarShadow: UIView!
    private var lblExpContent: UILabel!
    
    // Compass and Locating Self
    var btnZoom: FMZoomButton!
    private var btnLocateSelf: FMLocateSelf!
    
    // Chat Button
    private var btnOpenChat: UIButton!
    private var lblUnreadCount: UILabel! // Unread Messages Label
    
    // Discovery Button
    private var btnDiscovery: UIButton!
    
    // Filter Hexagon and Menu
    private var btnFilterIcon: FMRefreshIcon! // Filter Button
    private var uiviewDropUpMenu: FMDropUpMenu! //
    private var sizeFrom: CGFloat = 0 // Pan gesture var
    private var sizeTo: CGFloat = 0 // Pan gesture var
    private var end: CGFloat = 0 // Pan gesture var
    private var percent: Double = 0 // Pan gesture var
    private let floatFilterHeight = 471 * screenHeightFactor + device_offset_bot // Map Filter height
    
    // Selected Place Control
    private var selectedPlaceAnno: PlacePinAnnotationView?
    private var selectedPlace: FaePinAnnotation?
    private var swipingState: PlaceInfoBarState = .map {
        didSet {
            guard fullyLoaded else { return }
            btnTapToShowResultTbl.alpha = swipingState == .multipleSearch ? 1 : 0
            btnTapToShowResultTbl.isHidden = swipingState != .multipleSearch
            tblPlaceResult.isHidden = swipingState != .multipleSearch
        }
    }
    private var boolSelecting = false
    private var firstSelectPlace = true
    
    // Place Pin Control
    private var placePinOPQueue: OperationQueue!
    
    // Results from Search
    private var btnTapToShowResultTbl: UIButton!
    private var tblPlaceResult = FMPlacesTable()
    private var placesFromSearch = [PlacePin]()
    private var locationsFromSearch = [LocationPin]()
    private var pinsFromSearch = [FaePinAnnotation]()
    
    // Name Card
    private var uiviewNameCard: FMNameCardView!
    
    // MapView Offset Control
    private var prevMapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var prevAltitude: CLLocationDistance = 0
    
    // Collecting Pin Control
    private var uiviewSavedList: AddPinToCollectionView!
    private var uiviewAfterAdded: AfterAddedToListView!
    
    // Routes Calculator
    private var arrRoutes = [MKOverlay]()
    private var tempFaePins = [FaePinAnnotation]()
    private var startPointAddr: RouteAddress!
    private var destinationAddr: RouteAddress!
    private var addressAnnotations = [AddressAnnotation]()
    private var btnDistIndicator: FMDistIndicator!
    private var uiviewChooseLocs: FMChooseLocs!
    private var routeAddress: RouteAddress!
    private var imgSelectLocIcon: UIImageView!
    private var isRoutingCancelled = false
    
    // Location Pin Control
    private var selectedLocation: FaePinAnnotation?
    private var selectedLocAnno: LocPinAnnotationView?
    private var uiviewLocationBar: FMLocationInfoBar!
    private var locationPinClusterManager: CCHMapClusterController!
    
    // Chat
    private let faeChat = FaeChat()
    private let faePush = FaePush()
    private var intFriendsRequested: Int = 0
    
    // Collections Managements
    var arrCtrlers = [UIViewController]()
    var boolFromMap = true
    private var boolNotiSent = false
    var boolCanUpdateUsers = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    private var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    private let FILTER_ENABLE = true
    private var PLACE_ENABLE = true
    private let USER_ENABLE = false
    private var boolPreventUserPinOpen = false
    private var AUTO_REFRESH = true
    private var AUTO_CIRCLE_PINS = true
    private var HIDE_AVATARS = false
    private var fullyLoaded = false // indicate if all components are fully loaded
    private var boolCanUpdatePlaces = true
    private var PLACE_INSTANT_SHOWUP = false
    private var PLACE_INSTANT_REMOVE = false
    private var LOC_INSTANT_SHOWUP = false
    private var LOC_INSTANT_REMOVE = false
    private var USE_TEST_PLACES = false
    
    private var unreadNotiToken: NotificationToken? = nil
    
    // Filter Menu Place Collection Interface to Show All Saved Pins
    private var completionCount = 0 {
        didSet {
            guard fullyLoaded else { return }
            guard desiredCount > 0 else { return }
            guard desiredCount == completionCount else { return }
            PLACE_INSTANT_SHOWUP = true
            tblPlaceResult.places = tblPlaceResult.updatePlacesArray(places: placesFromSearch, numbered: false)
            tblPlaceResult.loading(current: placesFromSearch[0])
            placeClusterManager.addAnnotations(self.pinsFromSearch, withCompletionHandler: {
                self.placeClusterManager.isForcedRefresh = false
                self.PLACE_INSTANT_SHOWUP = false
                self.goTo(annotation: nil, place: self.placesFromSearch[0], animated: false)
            })
            guard let first = pinsFromSearch.first else { return }
            //faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: first.coordinate, animated: true)
            let camera = faeMapView.camera
            camera.altitude = 100000
            camera.centerCoordinate = first.coordinate
            faeMapView.setCamera(camera, animated: true)
            placeClusterManager.maxZoomLevelForClustering = 0
        }
    }
    private var desiredCount = 0
    
    // Auxiliary
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Key.shared.FMVCtrler = self
        AUTO_REFRESH = Key.shared.autoRefresh
        AUTO_CIRCLE_PINS = Key.shared.autoCycle
        HIDE_AVATARS = Key.shared.hideAvatars
        
        isUserLoggedIn()
        getUserStatus()
        
        initUserDataFromServer()
        
        loadMapView()
        loadNameCard()
        loadMapFilter()
        loadButton()
        view.bringSubview(toFront: uiviewDropUpMenu)
        loadExploreBar()
        loadPlaceDetail()
        loadPlaceListView()
        loadDistanceComponents()
        loadLocInfoBar()
        loadActivityIndicator()
        
        timerSetup()
        updateSelfInfo()
        
        checkDisplayNameExisitency()
        loadUserSettingsFromCloud()
        
        NotificationCenter.default.addObserver(self, selector: #selector(firstUpdateLocation), name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
        
        fullyLoaded = true
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
    
    private func checkIfResultTableAppearred() {
        tblPlaceResult.isHidden = !tblPlaceResult.showed
        btnTapToShowResultTbl.isHidden = !(tblPlaceResult.showed && swipingState == .multipleSearch)
    }
    
    private var modeLocation: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            uiviewExpbarShadow.isHidden = modeLocation == .off
            uiviewSchbarShadow.isHidden = modeLocation != .off
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
    
    private var modeLocCreating: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            if modeLocCreating == .off {
                uiviewLocationBar.hide()
                uiviewLocationBar.activityIndicator.stopAnimating()
                if uiviewAfterAdded.frame.origin.y != screenHeight {
                    uiviewAfterAdded.hide()
                }
                if selectedLocation != nil {
                    locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: {
                        self.deselectAllLocAnnos()
                    })
                }
            }
        }
    }
    
    private var mapMode: MapMode = .normal {
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
            btnLeftWindow.isHidden = mapMode == .selecting
            lblSearchContent.textColor = mapMode == .selecting ? UIColor._898989() : UIColor._182182182()
            
            uiviewExpbarShadow.isHidden = mapMode != .collection
            uiviewSchbarShadow.isHidden = mapMode == .collection
            
            btnMainMapSearch.isHidden = mapMode == .routing || mapMode == .selecting
            Key.shared.onlineStatus = mapMode == .routing || mapMode == .selecting ? 5 : 1
            if mapMode == .routing || mapMode == .selecting {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
            }
            
            faeMapView.isDoubleTapOnMKAnnoViewEnabled = mapMode != .routing
            imgSelectLocIcon.isHidden = mapMode != .selecting
        }
    }
    
    private func getUserStatus() {
        guard let user_status = FaeCoreData.shared.readByKey("userStatus") as? Int else { return }
        Key.shared.onlineStatus = user_status
    }
    
    private func jumpToMyFaeMainPage() {
        let vc = MyFaeMainPageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateSelfInfo() {
        DispatchQueue.global(qos: .utility).async {
            let updateNickName = FaeUser()
            updateNickName.getSelfNamecard { (status: Int, message: Any?) in
                guard status / 100 == 2 else {
                    DispatchQueue.main.async {
                        self.jumpToWelcomeView(animated: false)
                    }
                    return
                }
                let nickNameInfo = JSON(message!)
                if let str = nickNameInfo["nick_name"].string {
                    Key.shared.nickname = str
                }
                if let intro = nickNameInfo["short_intro"].string {
                    Key.shared.introduction = intro
                }
            }
        }
    }
    
    private func checkDisplayNameExisitency() {
        faeMapView.showsUserLocation = false
        getFromURL("users/name_card", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
            guard status / 100 == 2 else { return }
            let rsltJSON = JSON(result!)
            if let _ = rsltJSON["nick_name"].string {
                DispatchQueue.main.async {
                    sendWelcomeMessage()
                }
                self.faeMapView.showsUserLocation = true
            } else {
                DispatchQueue.main.async {
                    self.loadFirstLoginVC()
                    sendWelcomeMessage()
                }
            }
        }
    }
    
    private func loadUserSettingsFromCloud() {
        FaeUser.shared.getUserSettings { (status, message) in
            guard status / 100 == 2 else { return }
            guard let results = message else { return }
            let resultsJSON = JSON(results)
            Key.shared.emailSubscribed = resultsJSON["email_subscription"].boolValue
            Key.shared.measurementUnits = resultsJSON["measurement_units"].stringValue
            Key.shared.showNameCardOption = resultsJSON["show_name_card_options"].boolValue
            Key.shared.shadowLocationEffect = resultsJSON["shadow_location_system_effect"].stringValue == "" ? "normal" : resultsJSON["shadow_location_system_effect"].stringValue
        }
    }
    
    private func isUserLoggedIn() {
        FaeCoreData.shared.readLogInfo()
        if Key.shared.is_Login == false {
            jumpToWelcomeView(animated: false)
        }
    }
    
    private func updateGenderAge() {
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
    
    private func timerSetup() {
        invalidateAllTimer()
        timerUserPin = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(updateUserPins), userInfo: nil, repeats: true)
        timerLoadMessages = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(syncMessagesFromServer), userInfo: nil, repeats: true)
    }
    
    private func invalidateAllTimer() {
        timerUserPin?.invalidate()
        timerUserPin = nil
        timerLoadMessages?.invalidate()
        timerLoadMessages = nil
    }
    
    private func loadFirstLoginVC() {
        updateGenderAge()
        let updateMiniAvatar = FaeUser()
        let males: [Int] = [1, 2, 3, 6, 7, 9, 14, 15, 16, 18]
        var females = [Int]()
        for i in males {
            females.append(i + 18)
        }
        let random = Int(Double.random(min: 0, max: Double(males.count - 1)))
        Key.shared.userMiniAvatar = Key.shared.gender == "male" ? males[random] : females[random]
        Key.shared.miniAvatar = "miniAvatar_\(Key.shared.userMiniAvatar)"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
        self.selfAnView?.changeAvatar()
        FaeCoreData.shared.save("userMiniAvatar", value: Key.shared.userMiniAvatar)
        updateMiniAvatar.whereKey("mini_avatar", value: "\(Key.shared.userMiniAvatar - 1)")
        updateMiniAvatar.updateAccountBasicInfo({ (status: Int, _: Any?) in
            if status / 100 == 2 {
                print("Successfully update miniavatar")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
                self.selfAnView?.changeAvatar()
            } else {
                print("Fail to update miniavatar")
            }
            self.faeMapView.showsUserLocation = true
            let firstTimeLoginVC = FirstTimeLoginViewController()
            firstTimeLoginVC.modalPresentationStyle = .overCurrentContext
            self.present(firstTimeLoginVC, animated: false, completion: nil)
        })
    }
    
    private func updateTimerForAllPins() {
        updateTimerForUserPin()
        updatePlacePins()
    }
    
    private func jumpToWelcomeView(animated: Bool) {
        if Key.shared.navOpenMode == .welcomeFirst {
            navigationController?.popToRootViewController(animated: animated)
        } else {
            let welcomeVC = WelcomeViewController()
            navigationController?.pushViewController(welcomeVC, animated: animated)
            navigationController?.viewControllers = [welcomeVC]
            Key.shared.navOpenMode = .welcomeFirst
        }
    }
    
    private func refreshMap(pins: Bool, users: Bool, places: Bool) {
        if users {
            updateTimerForUserPin()
        }
        if places {
            updatePlacePins()
        }
    }
    
    private func reAddUserPins(_ completion: (() -> ())? = nil) {
        for user in faeUserPins {
            user.isValid = true
        }
        userClusterManager.addAnnotations(faeUserPins, withCompletionHandler: {
            completion?()
        })
    }
    
    private func reAddPlacePins(_ completion: (() -> ())? = nil) {
        placeClusterManager.addAnnotations(faePlacePins, withCompletionHandler: {
            completion?()
        })
    }
    
    private func reAddLocPins(_ completion: (() -> ())? = nil) {
        guard let pin = selectedLocation else { return }
        locationPinClusterManager.addAnnotations([pin], withCompletionHandler: {
            completion?()
        })
    }
    
    private func removePlaceUserPins(_ placeComp: (() -> ())? = nil, _ userComp: (() -> ())? = nil) {
        removePlacePins({
            placeComp?()
        }, otherThan: self.selectedPlace)
        removeUserPins {
            userComp?()
        }
    }
    
    private func removePlacePins(_ completion: (() -> ())? = nil, otherThan pin: FaePinAnnotation? = nil) {
        //let placesNeedToRemove = faePlacePins.filter({ $0 != selectedPlace })
        
        if pin != nil {
            for i in 0..<faePlacePins.count {
                if faePlacePins[i] == pin {
                    faePlacePins.remove(at: i)
                    break
                }
            }
        }
        
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(faePlacePins) {
            self.placeClusterManager.isForcedRefresh = false
            completion?()
        }
    }
    
    private func removeUserPins(_ completion: (() -> ())? = nil) {
        for user in faeUserPins {
            user.isValid = false
        }
        userClusterManager.removeAnnotations(faeUserPins) {
            completion?()
        }
    }
    
    private func storeRealmCollectionFromServer() {
        let realm = try! Realm()
        var setDeletedCollection = Set(realm.filterMyCollections().map { $0.collection_id })
        FaeCollection.shared.getCollections {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                guard let collections = json.array else {
                    print("[loadCollectionData] fail to parse collections info")
                    return
                }
                let realm = try! Realm()
                for collection in collections {
                    let collection_id = collection["collection_id"].intValue
                    if let existCollection = realm.filterCollection(id: collection_id) {
                        if existCollection.last_updated_at != collection["last_updated_at"].stringValue {
                            self.storeRealmColItemsFromServer(colId: collection_id)
                        }
                    } else {
                        self.storeRealmColItemsFromServer(colId: collection_id)
                    }
                    setDeletedCollection.remove(collection_id)
                }
                for collectionId in setDeletedCollection {
                    if let coll = realm.filterCollection(id: collectionId) {
                        try! realm.write {
                            realm.delete(coll)
                        }
                    }
                }
            } else {
                print("[Get Collections] Fail to Get \(status) \(message!)")
            }
        }
    }
    
    private func storeRealmColItemsFromServer(colId: Int) {
        FaeCollection.shared.getOneCollection(String(colId), completion: { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let col = JSON(message!)

            let realm = try! Realm()
            let realmCol = RealmCollection(value: [col["collection_id"].intValue, col["name"].stringValue, col["user_id"].intValue, col["description"].stringValue, col["type"].stringValue, col["is_private"].boolValue, col["created_at"].stringValue, col["count"].intValue, col["last_updated_at"].stringValue])

            try! realm.write {
                realm.add(realmCol, update: true)
                realmCol.pins.removeAll()
            }

            for pin in col["pins"].arrayValue {
                let collectedPin = CollectedPin(value: ["\(Key.shared.user_id)_\(pin["pin_id"].intValue)", Key.shared.user_id, pin["pin_id"].intValue, pin["added_at"].stringValue])

                try! realm.write {
                    realm.add(collectedPin, update: true)
                    realmCol.pins.append(collectedPin)
                }
            }
            
//            print("Successfully get collections")
        })
    }
    
    private func cancelAllPinLoading() {
        placeAdderQueue.cancelAllOperations()
    }
    
    private func initUserDataFromServer() {
        storeRealmCollectionFromServer()
        ContactsViewController.loadFriendsList()
        ContactsViewController.loadReceivedFriendRequests()
        ContactsViewController.loadSentFriendRequests()
    }
    
    @objc private func syncMessagesFromServer() {
        //faeChat.getMessageFromServer()
        //self.faeChat.getMessageFromServer()
        faePush.getSync { (status, message) in
            if status / 2 == 100 {
                let messageJSON = JSON(message!)
                if let friend_request_count = messageJSON["friend_request"].int {
                    if friend_request_count > 0 {
                        //ContactsViewController.loadReceivedFriendRequests()
                    }
                }
                if let chat_unread_count = messageJSON["chat"].int {
                    if chat_unread_count > 0 {
                        self.faeChat.getMessageFromServer()
                    }
                }
            } else if status == 500 { // TODO: error code undecided
                
            } else if status == 401 { // Unauthorized
                self.invalidateAllTimer()
                // clean up user info
                showAlert(title: "Connection Lost", message: "Another device has logged on to Fae Map with this Account!", viewCtrler: self, handler: { _ in
                    FaeCoreData.shared.save("userTokenEncode", value: "session_lost")
                    let vcRoot = WelcomeViewController()
                    Key.shared.navOpenMode = .welcomeFirst
                    self.navigationController?.setViewControllers([vcRoot], animated: true)
                })
            }
        }
    }
    
    func useActivityIndicator(on: Bool) {
        if on {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
}

// MARK: - Setup Main Screen Item UI

extension FaeMapViewController {
    
    // MARK: -- Load Map
    private func loadMapView() {
        faeMapView = FaeMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        faeMapView.delegate = self
        view.addSubview(faeMapView)
        view.sendSubview(toBack: faeMapView)
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = true
        faeMapView.delegate = self
        faeMapView.showsUserLocation = true
        faeMapView.mapAction = self
        faeMapView.isSingleTapOnLocPinEnabled = true
        
        placeClusterManager = CCHMapClusterController(mapView: faeMapView)
        placeClusterManager.delegate = self
        placeClusterManager.cellSize = 100
        //placeClusterManager.minUniqueLocationsForClustering = 2
        placeClusterManager.clusterer = self
        placeClusterManager.animator = self
        placeClusterManager.marginFactor = 0.0
        //placeClusterManager.isDebuggingEnabled = true
        
        userClusterManager = CCHMapClusterController(mapView: faeMapView)
        userClusterManager.delegate = self
        userClusterManager.cellSize = 100
        userClusterManager.marginFactor = 0.0
        userClusterManager.isUserPinController = true
        
        locationPinClusterManager = CCHMapClusterController(mapView: faeMapView)
        locationPinClusterManager.delegate = self
        locationPinClusterManager.cellSize = 60
        locationPinClusterManager.animator = self
        locationPinClusterManager.clusterer = self
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        prevMapCenter = LocManager.shared.curtLoc.coordinate
        refreshMap(pins: false, users: true, places: true)
    }
    
    @objc private func firstUpdateLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        refreshMap(pins: false, users: true, places: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
    }
    
    // MARK: -- Load Map Main Screen Buttons
    private func loadButton() {
        uiviewSchbarShadow = UIView(frame: CGRect(x: 7, y: 23 + device_offset_top, width: screenWidth - 14, height: 48))
        uiviewSchbarShadow.layer.zPosition = 500
        view.addSubview(uiviewSchbarShadow)
        addShadow(view: uiviewSchbarShadow, opa: 0.5, offset: CGSize.zero, radius: 3)
        
        let uiviewSchbarSub = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth - 14, height: 48))
        uiviewSchbarSub.layer.cornerRadius = 2
        uiviewSchbarSub.backgroundColor = .white
        uiviewSchbarSub.clipsToBounds = true
        uiviewSchbarShadow.addSubview(uiviewSchbarSub)
        
        // Left window on main map to open account system
        btnLeftWindow = UIButton()
        btnLeftWindow.setImage(#imageLiteral(resourceName: "mapLeftMenu"), for: .normal)
        uiviewSchbarShadow.addSubview(btnLeftWindow)
        btnLeftWindow.addTarget(self, action: #selector(self.actionLeftWindowShow(_:)), for: .touchUpInside)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-1-[v0(48)]", options: [], views: btnLeftWindow)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-0-[v0(48)]", options: [], views: btnLeftWindow)
        
        btnCancelSelect = UIButton()
        btnCancelSelect.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        uiviewSchbarShadow.addSubview(btnCancelSelect)
        btnCancelSelect.addTarget(self, action: #selector(self.actionCancelSelecting), for: .touchUpInside)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-1-[v0(40.5)]", options: [], views: btnCancelSelect)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-0-[v0(48)]", options: [], views: btnCancelSelect)
        btnCancelSelect.isHidden = true
        
        imgSearchIcon = UIImageView()
        imgSearchIcon.image = #imageLiteral(resourceName: "Search")
        uiviewSchbarShadow.addSubview(imgSearchIcon)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-49-[v0(15)]", options: [], views: imgSearchIcon)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-17-[v0(15)]", options: [], views: imgSearchIcon)
        
        imgAddressIcon = UIImageView()
        imgAddressIcon.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        uiviewSchbarShadow.addSubview(imgAddressIcon)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-49-[v0(15)]", options: [], views: imgAddressIcon)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-17-[v0(15)]", options: [], views: imgAddressIcon)
        imgAddressIcon.isHidden = true
        
        lblSearchContent = UILabel()
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textAlignment = .left
        lblSearchContent.lineBreakMode = .byTruncatingTail
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = UIColor._182182182()
        uiviewSchbarShadow.addSubview(lblSearchContent)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-73-[v0]-103-|", options: [], views: lblSearchContent)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-13-[v0(25)]", options: [], views: lblSearchContent)
        
        // Open main map search
        btnMainMapSearch = UIButton()
        uiviewSchbarShadow.addSubview(btnMainMapSearch)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-73-[v0]-55-|", options: [], views: btnMainMapSearch)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnMainMapSearch)
        btnMainMapSearch.addTarget(self, action: #selector(self.actionMainScreenSearch(_:)), for: .touchUpInside)
        
        // Click to clear search results
        btnClearSearchRes = UIButton()
        btnClearSearchRes.setImage(#imageLiteral(resourceName: "main_clear_search_bar"), for: .normal)
        btnClearSearchRes.isHidden = true
        btnClearSearchRes.addTarget(self, action: #selector(self.actionClearSearchResults(_:)), for: .touchUpInside)
        uiviewSchbarShadow.addSubview(btnClearSearchRes)
        uiviewSchbarShadow.addConstraintsWithFormat("H:[v0(48)]-36-|", options: [], views: btnClearSearchRes)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnClearSearchRes)
        
        // Show drop up menu
        btnDropUpMenu = UIButton()
        btnDropUpMenu.setImage(#imageLiteral(resourceName: "main_drop_up_menu_gray"), for: .normal)
        btnDropUpMenu.setImage(#imageLiteral(resourceName: "main_drop_up_menu_red"), for: .selected)
        btnDropUpMenu.addTarget(self, action: #selector(self.actionShowMapActionsMenu(_:)), for: .touchUpInside)
        uiviewSchbarShadow.addSubview(btnDropUpMenu)
        uiviewSchbarShadow.addConstraintsWithFormat("H:[v0(46)]-2-|", options: [], views: btnDropUpMenu)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnDropUpMenu)
        
        // Click to take an action for place pin
        uiviewPinActionDisplay = FMPinActionDisplay()
        uiviewSchbarShadow.addSubview(uiviewPinActionDisplay)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewPinActionDisplay)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewPinActionDisplay)
        faeMapView.uiviewPinActionDisplay = uiviewPinActionDisplay
        
        // Click to back to zoom
        btnZoom = FMZoomButton()
        btnZoom.mapView = faeMapView
        view.addSubview(btnZoom)
        
        // Click to locate the current location
        btnLocateSelf = FMLocateSelf()
        btnLocateSelf.mapView = faeMapView
        view.addSubview(btnLocateSelf)
        btnLocateSelf.nameCard = uiviewNameCard
        
        // Open chat view
        btnOpenChat = UIButton(frame: CGRect(x: 12, y: screenHeight - 90 - device_offset_bot_main, width: 79, height: 79))
        btnOpenChat.setImage(#imageLiteral(resourceName: "mainScreenNoChat"), for: .normal)
        btnOpenChat.setImage(#imageLiteral(resourceName: "mainScreenHaveChat"), for: .selected)
        btnOpenChat.addTarget(self, action: #selector(self.actionChatWindowShow(_:)), for: .touchUpInside)
        view.addSubview(btnOpenChat)
        btnOpenChat.layer.zPosition = 500
        
        // Show the number of unread messages on main map
        lblUnreadCount = UILabel(frame: CGRect(x: 55, y: 1, width: 25, height: 22))
        lblUnreadCount.backgroundColor = UIColor.init(red: 102 / 255, green: 192 / 255, blue: 251 / 255, alpha: 1)
        lblUnreadCount.layer.cornerRadius = 11
        lblUnreadCount.layer.masksToBounds = true
        lblUnreadCount.layer.opacity = 0.9
        lblUnreadCount.text = "1"
        lblUnreadCount.textAlignment = .center
        lblUnreadCount.textColor = UIColor.white
        lblUnreadCount.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        btnOpenChat.addSubview(lblUnreadCount)
        
        // Create pin on main map
        btnDiscovery = UIButton(frame: CGRect(x: screenWidth - 91, y: screenHeight - 90 - device_offset_bot_main, width: 79, height: 79))
        btnDiscovery.setImage(UIImage(named: "mainScreenDiscovery"), for: .normal)
        view.addSubview(btnDiscovery)
        btnDiscovery.addTarget(self, action: #selector(self.actionOpenExplore(_:)), for: .touchUpInside)
        btnDiscovery.layer.zPosition = 500
    }
    
    private func loadExploreBar() {
        uiviewExpbarShadow = UIView(frame: CGRect(x: 7, y: 23 + device_offset_top, width: screenWidth - 14, height: 48))
        uiviewExpbarShadow.layer.zPosition = 500
        uiviewExpbarShadow.isHidden = true
        view.addSubview(uiviewExpbarShadow)
        addShadow(view: uiviewExpbarShadow, opa: 0.5, offset: CGSize.zero, radius: 3)
        
        let uiviewExpbarSub = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth - 14, height: 48))
        uiviewExpbarSub.layer.cornerRadius = 2
        uiviewExpbarSub.backgroundColor = .white
        uiviewExpbarSub.clipsToBounds = true
        uiviewExpbarShadow.addSubview(uiviewExpbarSub)
        
        // Left window on main map to open account system
        btnBackToExp = UIButton()
        btnBackToExp.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        uiviewExpbarShadow.addSubview(btnBackToExp)
        btnBackToExp.addTarget(self, action: #selector(self.actionBackTo(_:)), for: .touchUpInside)
        uiviewExpbarShadow.addConstraintsWithFormat("H:|-1-[v0(40.5)]", options: [], views: btnBackToExp)
        uiviewExpbarShadow.addConstraintsWithFormat("V:|-0-[v0(48)]", options: [], views: btnBackToExp)
        btnBackToExp.adjustsImageWhenDisabled = false
        
        lblExpContent = UILabel()
        lblExpContent.textAlignment = .center
        lblExpContent.numberOfLines = 1
        lblExpContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblExpContent.textColor = UIColor._898989()
        uiviewExpbarShadow.addSubview(lblExpContent)
        uiviewExpbarShadow.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblExpContent)
        uiviewExpbarShadow.addConstraintsWithFormat("V:|-12.5-[v0(25)]", options: [], views: lblExpContent)
    }
    
    private func loadActivityIndicator() {
        activityIndicator = createActivityIndicator(large: true)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.layer.zPosition = 1999
    }
    
    private func setTitle(type: String) {
        let title_0 = type
        let title_1 = " Around Me"
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        lblExpContent.attributedText = title_0_attr
    }
    
    private func setCollectionTitle(type: String) {
        let title_0 = type
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        lblExpContent.attributedText = title_0_attr
    }
}

// MARK: - Actions

extension FaeMapViewController {
    
    private func renewSelfLocation() {
        DispatchQueue.global(qos: .default).async {
            guard CLLocationManager.locationServicesEnabled() else { return }
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                break
            case .authorizedAlways, .authorizedWhenInUse:
                FaeMap.shared.whereKey("geo_latitude", value: "\(LocManager.shared.curtLat)")
                FaeMap.shared.whereKey("geo_longitude", value: "\(LocManager.shared.curtLong)")
                FaeMap.shared.renewCoordinate {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        // print("Successfully renew self position")
                    } else {
                        print("[renewSelfLocation] fail")
                    }
                }
            }
        }
    }
    
    @objc private func actionMainScreenSearch(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide() {
            self.faeMapView.mapGesture(isOn: true)
        }
        uiviewDropUpMenu.hide()
        let searchVC = MapSearchViewController()
        searchVC.faeMapView = self.faeMapView
        searchVC.delegate = self
        if let text = lblSearchContent.text {
            searchVC.strSearchedPlace = text
        } else {
            searchVC.strSearchedPlace = ""
        }
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    @objc private func actionClearSearchResults(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        if modeLocCreating == .on {
            modeLocCreating = .off
            return
        }
        PLACE_ENABLE = true
        
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textColor = UIColor._182182182()
        
        btnClearSearchRes.isHidden = true
        btnTapToShowResultTbl.alpha = 0
        btnLocateSelf.isHidden = false
        btnZoom.isHidden = false
        btnTapToShowResultTbl.center.y = 181 + device_offset_top
        btnTapToShowResultTbl.tag = 1
        btnTapToShowResultTbl.sendActions(for: .touchUpInside)
        
        tblPlaceResult.state = .map
        swipingState = .map
        tblPlaceResult.hide(animated: false)
        placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        
        tblPlaceResult.alpha = 0
        
        faeMapView.mapGesture(isOn: true)
        deselectAllPlaceAnnos()
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(pinsFromSearch) {
            self.pinsFromSearch.removeAll(keepingCapacity: true)
            self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: {
                self.placeClusterManager.isForcedRefresh = false
            })
        }
        userClusterManager.addAnnotations(faeUserPins, withCompletionHandler: nil)
    }
    
    @objc private func actionLeftWindowShow(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide() {
            self.faeMapView.mapGesture(isOn: true)
        }
        let leftMenuVC = SideMenuViewController()
        leftMenuVC.delegate = self
        leftMenuVC.displayName = Key.shared.nickname
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        present(leftMenuVC, animated: false, completion: nil)
    }
    
    @objc private func actionShowResultTbl(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        if sender.tag == 0 {
            sender.tag = 1
            tblPlaceResult.expand {
                let iphone_x_offset: CGFloat = 70
                self.btnTapToShowResultTbl.center.y = screenHeight - 164 * screenHeightFactor + 15 + 68 + device_offset_top - iphone_x_offset
            }
            btnZoom.isHidden = true
            btnLocateSelf.isHidden = true
            btnTapToShowResultTbl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        } else {
            sender.tag = 0
            tblPlaceResult.shrink {
                self.btnTapToShowResultTbl.center.y = 181 + device_offset_top
            }
            btnZoom.isHidden = false
            btnLocateSelf.isHidden = false
            btnTapToShowResultTbl.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func actionChatWindowShow(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide() {
            self.faeMapView.mapGesture(isOn: true)
        }
        UINavigationBar.appearance().shadowImage = imgNavBarDefaultShadow
        // check if the user's logged in the backendless
        //let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()! as! RecentViewController
        let chatVC = RecentViewController()
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func actionOpenExplore(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide {}
        let vcExp = ExploreViewController()
        navigationController?.pushViewController(vcExp, animated: true)
    }
    
    @objc private func actionCancelSelecting() {
        btnZoom.tapToSmallMode()
        mapMode = .routing
        uiviewChooseLocs.show()
    }
    
    @objc private func actionBackTo(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        switch mapMode {
        case .collection:
            placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
            tblPlaceResult.hide()
            btnTapToShowResultTbl.alpha = 0
            btnTapToShowResultTbl.tag = 1
            btnTapToShowResultTbl.sendActions(for: .touchUpInside)
            animateMainItems(show: false, animated: boolFromMap)
            if boolFromMap == false {
                boolFromMap = true
                navigationController?.setViewControllers(arrCtrlers, animated: false)
            }
            if let idxPath = uiviewDropUpMenu.selectedIndexPath {
                if let cell = uiviewDropUpMenu.tblPlaceLoc.cellForRow(at: idxPath) as? CollectionsListCell {
                    cell.imgIsIn.isHidden = true
                    uiviewDropUpMenu.selectedIndexPath = nil
                }
            }
        default:
            break
        }
        PLACE_ENABLE = true
        mapMode = .normal
        faeMapView.blockTap = false
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(pinsFromSearch, withCompletionHandler: {
            self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: {
                self.placeClusterManager.isForcedRefresh = false
            })
        })
        userClusterManager.addAnnotations(faeUserPins, withCompletionHandler: nil)
    }
}

extension FaeMapViewController: MKMapViewDelegate, CCHMapClusterControllerDelegate, CCHMapAnimator, CCHMapClusterer {
    
    // MARK: - Cluster Delegates
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, coordinateForAnnotations annotations: Set<AnyHashable>!, in mapRect: MKMapRect) -> IsSelectedCoordinate {
        for annotation in annotations {
            guard let pin = annotation as? FaePinAnnotation else { continue }
            if pin.isSelected {
                return IsSelectedCoordinate(isSelected: true, coordinate: pin.coordinate)
            }
        }
        guard let firstAnn = annotations.first as? FaePinAnnotation else {
            return IsSelectedCoordinate(isSelected: false, coordinate: CLLocationCoordinate2DMake(0, 0))
        }
        return IsSelectedCoordinate(isSelected: false, coordinate: firstAnn.coordinate)
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, didAddAnnotationViews annotationViews: [Any]!) {
        for annotationView in annotationViews {
            if let anView = annotationView as? PlacePinAnnotationView {
                anView.superview?.sendSubview(toBack: anView)
                if PLACE_INSTANT_SHOWUP { // immediatelly show up
                    anView.imgIcon.frame = CGRect(x: -8, y: -5, width: 56, height: 56)
                    anView.alpha = 1
                } else {
                    anView.alpha = 0
                    anView.imgIcon.frame = CGRect(x: 20, y: 46, width: 0, height: 0)
                    let delay: Double = Double(arc4random_uniform(50)) / 100 // Delay 0-1 seconds, randomly
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.75, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                            anView.imgIcon.frame = CGRect(x: -8, y: -5, width: 56, height: 56)
                            anView.alpha = 1
                        }, completion: nil)
                    }
                }
            } else if let anView = annotationView as? UserPinAnnotationView {
                anView.superview?.bringSubview(toFront: anView)
                anView.alpha = 0
                let delay: Double = Double(arc4random_uniform(50)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, delay: delay, animations: {
                        anView.alpha = 1
                    })
                }
            } else if let anView = annotationView as? LocPinAnnotationView {
                if LOC_INSTANT_SHOWUP {
                    anView.alpha = 1
                } else {
                    anView.alpha = 0
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, animations: {
                            anView.alpha = 1
                        })
                    }
                }
            } else if let anView = annotationView as? MKAnnotationView {
                anView.alpha = 0
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, animations: {
                        anView.alpha = 1
                    })
                }
            }
        }
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willRemoveAnnotations annotations: [Any]!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        if PLACE_INSTANT_REMOVE { // immediatelly remove
            for annotation in annotations {
                if let anno = annotation as? MKAnnotation {
                    if let anView = self.faeMapView.view(for: anno) {
                        anView.alpha = 0
                    }
                }
            }
            if completionHandler != nil { completionHandler() }
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            for annotation in annotations {
                if let anno = annotation as? MKAnnotation {
                    if let anView = self.faeMapView.view(for: anno) {
                        anView.alpha = 0
                    }
                }
            }
        }) { _ in
            if completionHandler != nil { completionHandler() }
        }
        
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willReuse mapClusterAnnotation: CCHMapClusterAnnotation!) {
        
        switch mapClusterController {
        case placeClusterManager:
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? PlacePinAnnotationView {
                var found = false
                for annotation in mapClusterAnnotation.annotations {
                    guard let pin = annotation as? FaePinAnnotation else { continue }
                    guard let sPlace = selectedPlace else { continue }
                    if faeBeta.coordinateEqual(pin.coordinate, sPlace.coordinate) {
                        found = true
                        anView.assignImage(pin.icon)
                    }
                }
                if !found {
                    let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
                    anView.assignImage(firstAnn.icon)
                }
                anView.superview?.bringSubview(toFront: anView)
            }
        case userClusterManager:
            let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? UserPinAnnotationView {
                anView.assignImage(firstAnn.avatar)
                anView.superview?.bringSubview(toFront: anView)
            }
        case locationPinClusterManager:
            break
        default:
            break
        }
        
        let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
        if firstAnn.type == .location {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? LocPinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        }
        if selectedPlaceAnno != nil {
            selectedPlaceAnno?.superview?.bringSubview(toFront: selectedPlaceAnno!)
            selectedPlaceAnno?.layer.zPosition = 199
        }
    }
    
    // MARK: - MapView Delegates
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard boolCanOpenPin else { return }
        
        if view is PlacePinAnnotationView {
            tapPlacePin(didSelect: view)
        } else if view is UserPinAnnotationView {
            guard boolPreventUserPinOpen == false else { return }
            tapUserPin(didSelect: view)
        } else if view is SelfAnnotationView {
            boolCanOpenPin = false
            faeMapView.mapGesture(isOn: false)
            uiviewNameCard.userId = Key.shared.user_id
            uiviewNameCard.show(avatar: UIImage(named: "miniAvatar_\(Key.shared.userMiniAvatar)") ?? UIImage())  {
                self.boolCanOpenPin = true
            }
            uiviewNameCard.boolSmallSize = false
            uiviewNameCard.btnProfile.isHidden = true
            guard let anView = view as? SelfAnnotationView else { return }
            anView.mapAvatar = Key.shared.userMiniAvatar
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let identifier = "self"
            var anView: SelfAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SelfAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
                selfAnView = anView
            } else {
                anView = SelfAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                selfAnView = anView
            }
            anView.changeAvatar()
            if Key.shared.onlineStatus == 5 {
                anView.invisibleOn()
            }
            return anView
        } else if annotation is CCHMapClusterAnnotation {
            guard let clusterAnn = annotation as? CCHMapClusterAnnotation else { return nil }
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == .place {
                return viewForPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == .user {
                return viewForUser(annotation: annotation, first: firstAnn)
            } else {
                return viewForLocation(annotation: annotation, first: firstAnn)
            }
        } else if annotation is AddressAnnotation {
            guard let addressAnno = annotation as? AddressAnnotation else { return nil }
            let identifier = addressAnno.isStartPoint ? "start_point" : "destination"
            var anView: AddressAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? AddressAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = AddressAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            anView.assignImage(addressAnno.isStartPoint ? #imageLiteral(resourceName: "icon_startpoint") : #imageLiteral(resourceName: "icon_destination"))
            return anView
        } else if annotation is FaePinAnnotation {
            guard let firstAnn = annotation as? FaePinAnnotation else { return nil }
            if firstAnn.type == .place {
                return viewForSelectedPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == .location {
                return viewForLocation(annotation: annotation, first: firstAnn)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        Key.shared.lastChosenLoc = mapView.centerCoordinate
        
        if AUTO_REFRESH {
            calculateDistanceOffset()
        }
        
        if swipingState == .multipleSearch && tblPlaceResult.altitude == 0 {
            tblPlaceResult.altitude = mapView.camera.altitude
            joshprint("[regionDidChangeAnimated] altitude changed")
        }
        
        if tblPlaceResult.tag > 0 && PLACE_ENABLE { tblPlaceResult.annotations = visiblePlaces() }
        
        if mapMode == .selecting {
            let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
            let mapCenterCoordinate = mapView.convert(mapCenter, toCoordinateFrom: nil)
            let location = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
            General.shared.getAddress(location: location) { (address) in
                guard let addr = address as? String else { return }
                DispatchQueue.main.async {
                    self.lblSearchContent.text = addr
                    self.routeAddress = RouteAddress(name: addr, coordinate: location.coordinate)
                }
            }
        }
    }
    
    func animateToCoordinate(type: Int, coordinate: CLLocationCoordinate2D, animated: Bool) {
        var offset: CGFloat = 0
        if type == 0 { // Map pin
            offset = 530 * screenHeightFactor - screenHeight / 2 // 488 530
        } else if type == 1 { // Map pin
            offset = 465 * screenHeightFactor - screenHeight / 2 // 458 500
        } else if type == 2 { // Place pin
            offset = 492 * screenHeightFactor - screenHeight / 2 // offset: 42
        }
        
        var curPoint = faeMapView.convert(coordinate, toPointTo: nil)
        curPoint.y -= offset
        let newCoordinate = faeMapView.convert(curPoint, toCoordinateFrom: nil)
        let point: MKMapPoint = MKMapPointForCoordinate(newCoordinate)
        var rect: MKMapRect = faeMapView.visibleMapRect
        rect.origin.x = point.x - rect.size.width * 0.5
        rect.origin.y = point.y - rect.size.height * 0.5
        
        faeMapView.setVisibleMapRect(rect, animated: animated)
    }
    
    private func deselectAllPlaceAnnos(full: Bool = true) {
        
        uiviewPinActionDisplay.hide()
        boolCanOpenPin = true
        
//        if let idx = selectedPlace?.class_2_icon_id {
//            if full {
//                selectedPlace?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
//                selectedPlace?.isSelected = false
//                guard let img = selectedPlace?.icon else { return }
//                selectedPlaceAnno?.assignImage(img)
//                selectedPlaceAnno?.hideButtons()
//                selectedPlaceAnno?.superview?.sendSubview(toBack: selectedPlaceAnno!)
//                selectedPlaceAnno?.zPos = 7
//                selectedPlaceAnno?.optionsReady = false
//                selectedPlaceAnno?.optionsOpened = false
//                selectedPlaceAnno = nil
//                selectedPlace = nil
//            } else {
//                selectedPlaceAnno?.hideButtons()
//                selectedPlaceAnno?.optionsOpened = false
//            }
//        }
        if full {
            selectedPlace?.icon = #imageLiteral(resourceName: "place_map_48")
            selectedPlace?.isSelected = false
            guard let img = selectedPlace?.icon else { return }
            selectedPlaceAnno?.assignImage(img)
            selectedPlaceAnno?.hideButtons()
            selectedPlaceAnno?.superview?.sendSubview(toBack: selectedPlaceAnno!)
            selectedPlaceAnno?.zPos = 7
            selectedPlaceAnno?.optionsReady = false
            selectedPlaceAnno?.optionsOpened = false
            selectedPlaceAnno = nil
            selectedPlace = nil
        } else {
            selectedPlaceAnno?.hideButtons()
            selectedPlaceAnno?.optionsOpened = false
        }
    }
    
    private func deselectAllLocAnnos() {
        uiviewLocationBar.hide()
        uiviewPinActionDisplay.hide()
        uiviewSavedList.arrListSavedThisPin.removeAll()
        uiviewAfterAdded.reset()
        boolCanOpenPin = true
        
        selectedLocAnno?.hideButtons()
        selectedLocAnno?.zPos = 8.0
        selectedLocAnno?.optionsReady = false
        selectedLocAnno?.optionsOpened = false
        selectedLocAnno?.removeFromSuperview()
        selectedLocAnno = nil
        selectedLocation = nil
    }
    
    private func calculateDistanceOffset() {
        DispatchQueue.global(qos: .userInitiated).async {
            let curtMapCenter = self.faeMapView.camera.centerCoordinate
            let point_a = MKMapPointForCoordinate(self.prevMapCenter)
            let point_b = MKMapPointForCoordinate(curtMapCenter)
            let distance = MKMetersBetweenMapPoints(point_a, point_b)
            guard distance >= self.screenWidthInMeters() else { return }
            self.prevMapCenter = curtMapCenter
            DispatchQueue.main.async {
                self.updatePlacePins()
                self.updateUserPins()
            }
        }
    }
    
    private func screenWidthInMeters() -> CLLocationDistance {
        let cgpoint_a = CGPoint(x: 0, y: 0)
        let cgpoint_b = CGPoint(x: screenWidth, y: 0)
        let coor_a = faeMapView.convert(cgpoint_a, toCoordinateFrom: nil)
        let coor_b = faeMapView.convert(cgpoint_b, toCoordinateFrom: nil)
        let point_a = MKMapPointForCoordinate(coor_a)
        let point_b = MKMapPointForCoordinate(coor_b)
        let distance = MKMetersBetweenMapPoints(point_a, point_b)
        return distance * 0.6
    }
    
    public func mapGesture(isOn: Bool) {
        faeMapView.mapGesture(isOn: isOn)
    }
    
    private func dismissMainBtns() {
        UIView.animate(withDuration: 0.2, animations: {
            if self.FILTER_ENABLE {
                self.btnFilterIcon.frame = CGRect(x: screenWidth / 2, y: screenHeight - 25 - device_offset_bot, width: 0, height: 0)
            }
            self.btnZoom.frame = CGRect(x: 51.5, y: 611.5 * screenWidthFactor, width: 0, height: 0)
            self.btnLocateSelf.frame = CGRect(x: 362.5 * screenWidthFactor, y: 611.5 * screenWidthFactor, width: 0, height: 0)
            self.btnOpenChat.frame = CGRect(x: 51.5, y: 685.5 * screenWidthFactor, width: 0, height: 0)
            self.lblUnreadCount.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.btnDiscovery.frame = CGRect(x: 362.5 * screenWidthFactor, y: 685.5 * screenWidthFactor, width: 0, height: 0)
        }, completion: nil)
    }
}

// MARK: -

extension FaeMapViewController: SideMenuDelegate, ButtonFinishClickedDelegate {
    
    // sideMenuDelegate
    func userInvisible(isOn: Bool) {
        if !isOn {
            renewSelfLocation()
            return
        }
        if Key.shared.onlineStatus == 5 {
            invisibleMode()
        } else {
            //            NotificationCenter.default.post(name: Notification.Name(rawValue: "userAvatarAnimationRestart"), object: nil)
        }
    }
    
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        self.navigationController?.pushViewController(moodAvatarVC, animated: true)
    }
    
    func jumpToCollections() {
        let vcCollections = CollectionsViewController()
        self.navigationController?.pushViewController(vcCollections, animated: true)
    }
    
    func jumpToContacts() {
        let vcContacts = ContactsViewController()
        self.navigationController?.pushViewController(vcContacts, animated: true)
    }
    
    // sideMenuDelegate
    func jumpToSettings() {
        let vcSettings = SettingsViewController()
        navigationController?.pushViewController(vcSettings, animated: true)
    }
    
    func jumpToFaeUserMainPage() {
        self.jumpToMyFaeMainPage()
    }
    
    func reloadSelfPosition() {
        self.boolCanOpenPin = true
        self.resetCompassRotation()
    }
    
    func switchMapMode() {
        guard let vc = self.navigationController?.viewControllers.first else { return }
        guard vc is InitialPageController else { return }
        guard let vcRoot = vc as? InitialPageController else { return }
        vcRoot.goToMapBoard()
        SideMenuViewController.boolMapBoardIsOn = true
    }
    
    func resetCompassRotation() {
        //        btnCompass.transform = btnCompass.savedTransform
        updateUnreadChatIndicator()
    }
    
    // ButtonFinishClickedDelegate
    func jumpToEnableNotification() {
        print("jumpToEnableNotification")
        let notificationType = UIApplication.shared.currentUserNotificationSettings
        if notificationType?.types == UIUserNotificationType() {
            let vc = EnableNotificationViewController()
            //            UIApplication.shared.keyWindow?.visibleViewController?
            present(vc, animated: true)
        }
    }
    // ButtonFinishClickedDelegate End
}

// MARK: - Drop Up Menu

extension FaeMapViewController: MapFilterMenuDelegate {
    
    private func loadMapFilter() {
        guard FILTER_ENABLE else { return }
        
        btnFilterIcon = FMRefreshIcon()
        btnFilterIcon.addTarget(self, action: #selector(self.actionFilterIcon(_:)), for: .touchUpInside)
        btnFilterIcon.layer.zPosition = 601
        view.addSubview(btnFilterIcon)
        view.bringSubview(toFront: btnFilterIcon)
        
        // new menu design
        uiviewDropUpMenu = FMDropUpMenu()
        uiviewDropUpMenu.layer.zPosition = 601
        uiviewDropUpMenu.delegate = self
        view.addSubview(uiviewDropUpMenu)
        let panGesture_menu = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
        panGesture_menu.require(toFail: uiviewDropUpMenu.swipeGes)
        uiviewDropUpMenu.addGestureRecognizer(panGesture_menu)
    }
    
    @objc private func actionFilterIcon(_ sender: UIButton) {
        PLACE_ENABLE = true
        if btnFilterIcon.isSpinning {
            btnFilterIcon.stopIconSpin()
            boolCanUpdatePlaces = true
            boolCanUpdateUsers = true
            return
        }
        guard boolCanUpdatePlaces && boolCanUpdateUsers else { return }
        btnFilterIcon.startIconSpin()
        removePlaceUserPins({
            self.faePlacePins.removeAll(keepingCapacity: true)
            self.setPlacePins.removeAll(keepingCapacity: true)
            if self.selectedPlace != nil {
                self.faePlacePins.append(self.selectedPlace!)
                self.setPlacePins.insert(self.selectedPlace!.id)
            }
            self.updatePlacePins()
        }) {
            self.faeUserPins.removeAll(keepingCapacity: true)
            self.updateTimerForUserPin()
        }
    }
    
    @objc private func actionShowMapActionsMenu(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            uiviewDropUpMenu.hide()
        } else {
            sender.isSelected = true
            uiviewDropUpMenu.show()
        }
    }
    
    // MapFilterMenuDelegate
    func autoReresh(isOn: Bool) {
        AUTO_REFRESH = isOn
        Key.shared.autoRefresh = isOn
        FaeCoreData.shared.save("autoRefresh", value: isOn)
    }
    
    // MapFilterMenuDelegate
    func autoCyclePins(isOn: Bool) {
        AUTO_CIRCLE_PINS = isOn
        placeClusterManager.canUpdate = isOn
        joshprint("[autoCyclePins]", placeClusterManager.canUpdate)
        Key.shared.autoCycle = isOn
        FaeCoreData.shared.save("autoCycle", value: isOn)
    }
    
    // MapFilterMenuDelegate
    func hideAvatars(isOn: Bool) {
        HIDE_AVATARS = isOn
        Key.shared.hideAvatars = isOn
        FaeCoreData.shared.save("hideAvatars", value: isOn)
        if isOn {
            timerUserPin?.invalidate()
            timerUserPin = nil
            for faeUser in faeUserPins {
                faeUser.isValid = false
            }
            userClusterManager.removeAnnotations(faeUserPins) {
                self.faeUserPins.removeAll()
            }
        } else {
            updateTimerForUserPin()
        }
    }
    
    // MapFilterMenuDelegate
    func showSavedPins(type: String, savedPinIds: [Int], isCollections: Bool, colName: String) {
        guard savedPinIds.count > 0 else {
            // 判断:
            showAlert(title: "There is no pin in this collection!", message: "", viewCtrler: self)
            return
        }
        if isCollections {
            mapMode = .collection
            setCollectionTitle(type: colName)
        }
        animateMainItems(show: true, animated: false)
        PLACE_ENABLE = false
        desiredCount = savedPinIds.count
        completionCount = 0
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(faePlacePins, withCompletionHandler: nil)
        placeClusterManager.removeAnnotations(pinsFromSearch, withCompletionHandler: {
            self.pinsFromSearch.removeAll()
            self.placesFromSearch.removeAll()
            self.locationsFromSearch.removeAll()
            for id in savedPinIds {
                FaeMap.shared.getPin(type: type, pinId: String(id), completion: { (status, message) in
                    guard status / 100 == 2 else { return }
                    guard message != nil else { return }
                    let resultJson = JSON(message!)
                    if type == "place" {
                        let pinData = PlacePin(json: resultJson)
                        self.placesFromSearch.append(pinData)
                        let pin = FaePinAnnotation(type: FaePinType(rawValue: type)!, cluster: self.placeClusterManager, data: pinData as AnyObject)
                        self.pinsFromSearch.append(pin)
                    } else if type == "location" {
                        let pinData = LocationPin(json: resultJson)
                        self.locationsFromSearch.append(pinData)
                        let pin = FaePinAnnotation(type: FaePinType(rawValue: type)!, cluster: self.locationPinClusterManager, data: pinData as AnyObject)
                        self.pinsFromSearch.append(pin)
                    }
                    self.completionCount += 1
                })
            }
        })
        for user in faeUserPins {
            user.isValid = false
        }
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
    }
    
    func animateMainScreenButtons(hide: Bool, animated: Bool) {
        if hide {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight + 10
                    self.btnLocateSelf.frame.origin.y = screenHeight + 10
                    self.btnOpenChat.frame.origin.y = screenHeight + 10
                    self.btnDiscovery.frame.origin.y = screenHeight + 10
                    self.btnFilterIcon.frame.origin.y = screenHeight + 10
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight + 10
                self.btnLocateSelf.frame.origin.y = screenHeight + 10
                self.btnOpenChat.frame.origin.y = screenHeight + 10
                self.btnDiscovery.frame.origin.y = screenHeight + 10
                self.btnFilterIcon.frame.origin.y = screenHeight + 10
            }
            faeMapView.cgfloatCompassOffset = 134
            faeMapView.layoutSubviews()
        } else {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnFilterIcon.center.y = screenHeight - 25 - device_offset_bot
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnFilterIcon.center.y = screenHeight - 25 - device_offset_bot
            }
            faeMapView.cgfloatCompassOffset = 215
            faeMapView.layoutSubviews()
        }
    }
    
    @objc private func panGesMenuDragging(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            uiviewNameCard.hide() {
                self.faeMapView.mapGesture(isOn: true)
            }
            let location = pan.location(in: view)
            if uiviewDropUpMenu.frame.origin.y == screenHeight {
                uiviewDropUpMenu.panCtrlParaSetting(showed: false)
            } else {
                uiviewDropUpMenu.panCtrlParaSetting(showed: true)
            }
            end = location.y
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: view)
            let location = pan.location(in: view)
            resumeTime = abs(Double(CGFloat(end - location.x) / velocity.x))
            if resumeTime > 0.3 {
                resumeTime = 0.3
            }
            if percent < -0.1 {
                // reload collection data
                if uiviewDropUpMenu.frame.origin.y < screenHeight {
                    uiviewDropUpMenu.loadCollectionData()
                }
                btnDropUpMenu.isSelected = false
                faeMapView.mapGesture(isOn: true)
                animateMainScreenButtons(hide: false, animated: true)
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewDropUpMenu.frame.origin.y = self.uiviewDropUpMenu.sizeTo
                }, completion: { _ in
                    self.uiviewDropUpMenu.smallMode()
                })
            } else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewDropUpMenu.frame.origin.y = self.uiviewDropUpMenu.sizeFrom
                })
            }
        } else {
            let location = pan.location(in: view)
            let translation = pan.translation(in: view)
            if uiviewDropUpMenu.frame.origin.y == uiviewDropUpMenu.old_origin_y {
                if translation.y < 0 { return }
                percent = Double(CGFloat(end - location.y) / uiviewDropUpMenu.frame.size.height)
                uiviewDropUpMenu.frame.origin.y += translation.y
                pan.setTranslation(CGPoint.zero, in: view)
            } else if uiviewDropUpMenu.frame.origin.y > uiviewDropUpMenu.old_origin_y {
                percent = Double(CGFloat(end - location.y) / uiviewDropUpMenu.frame.size.height)
                uiviewDropUpMenu.frame.origin.y += translation.y
                pan.setTranslation(CGPoint.zero, in: view)
            }
        }
    }
}

// MARK: - Name Card

extension FaeMapViewController: NameCardDelegate {
    private func loadNameCard() {
        uiviewNameCard = FMNameCardView()
        uiviewNameCard.delegate = self
        view.addSubview(uiviewNameCard)
        faeMapView.uiviewNameCard = uiviewNameCard
    }
    
    // MARK: NameCardDelegate
    func openAddFriendPage(userId: Int, status: FriendStatus) {
        let addFriendVC = AddFriendFromNameCardViewController()
        addFriendVC.delegate = uiviewNameCard
        addFriendVC.userId = userId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }
    
    func reportUser(id: Int) {
        let reportPinVC = ReportViewController()
        reportPinVC.reportType = 0
        present(reportPinVC, animated: true, completion: nil)
    }
    
    func openFaeUsrInfo() {
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = uiviewNameCard.userId
        uiviewNameCard.hide() {
            self.faeMapView.mapGesture(isOn: true)
        }
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    func chatUser(id: Int) {
        let vcChat = ChatViewController()
        vcChat.arrUserIDs.append("\(Key.shared.user_id)")
        vcChat.arrUserIDs.append("\(id)")
        vcChat.strChatId = "\(id)"
        let realm = try! Realm()
        if let _ = realm.filterUser(id: "\(id)") {
            navigationController?.pushViewController(vcChat, animated: true)
        } else {
            assert(false, "[Chat - check why this user is not in Realm]")
        }
    }
}

// MARK: - Search

extension FaeMapViewController: MapSearchDelegate {
    
    func jumpToLocation(region: MKCoordinateRegion) {
        faeMapView.setRegion(region, animated: true)
    }
    
    // MapSearchDelegate
    func jumpToOnePlace(searchText: String, place: PlacePin) {
        PLACE_ENABLE = false
        let pin = FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: place)
        pinsFromSearch.append(pin)
        updateUI(searchText: searchText)
        let camera = faeMapView.camera
        camera.centerCoordinate = place.coordinate
        faeMapView.setCamera(camera, animated: false)
        tblPlaceResult.load(for: place)
        removePlaceUserPins({
            self.placeClusterManager.addAnnotations([pin], withCompletionHandler: nil)
        }, nil)
    }
    
    // TODO YUE - DONE
    /*
     按搜索返回地图不显示category了就直接显示具体地点等其他results
     跟如果用户搜了乱码比如 ‘esjufah’ 一样，按搜索前显示无结果因为没有符合包括用户输入内容的任何东西，这时用户点search还是可以返回地图但是什么都没有
     
     以上是老板原话。我把你的return注释掉了，但存在问题，你试试搜索b，下面不会出来place数据，点击search，出现的页面，根据该页面修改一下？
     */
    func jumpToPlaces(searchText: String, places: [PlacePin]) {
        PLACE_ENABLE = false
        /*
         placesFromSearch = places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
         removePlaceUserPins({
         self.placeClusterManager.addAnnotations(self.placesFromSearch, withCompletionHandler: {
         if searchText == "fromEXP" {
         self.visibleClusterPins = self.visiblePlaces(full: true)
         self.arrExpPlace = places
         self.clctViewMap.reloadData()
         self.highlightPlace(0)
         }
         if let first = places.first {
         self.goTo(annotation: nil, place: first)
         }
         })
         self.zoomToFitAllAnnotations(annotations: self.placesFromSearch)
         }, nil)
         */
        updateUI(searchText: searchText)
        deselectAllPlaceAnnos()
        cancelAllPinLoading()
        btnTapToShowResultTbl.isHidden = places.count <= 1
        if let _ = places.first {
            swipingState = .multipleSearch
            tblPlaceResult.places = tblPlaceResult.updatePlacesArray(places: places)
            tblPlaceResult.loading(current: places[0])
            pinsFromSearch = tblPlaceResult.places.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0) }
            removePlaceUserPins({
                self.PLACE_INSTANT_SHOWUP = true
                self.placeClusterManager.addAnnotations(self.pinsFromSearch, withCompletionHandler: {
                    if let first = places.first {
                        self.goTo(annotation: nil, place: first, animated: true)
                    }
                    self.PLACE_INSTANT_SHOWUP = false
                })
                faeBeta.zoomToFitAllPlaces(mapView: self.faeMapView,
                                           places: self.tblPlaceResult.arrPlaces,
                                           edgePadding: UIEdgeInsetsMake(240, 40, 100, 40))
            }, nil)
            placeClusterManager.maxZoomLevelForClustering = 0
        } else {
            swipingState = .map
            tblPlaceResult.hide(animated: false)
            placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        }
    }
    
    // MapSearchDelegate End
    
    func updateUI(searchText: String) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        lblSearchContent.textColor = UIColor._898989()
    }
}

// MARK: - Place Bar & Table

extension FaeMapViewController: PlaceViewDelegate, FMPlaceTableDelegate {
    
    // FMPlaceTableDelegate
    func selectPlaceFromTable(_ placeData: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = placeData
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // FMPlaceTableDelegate
    func reloadPlacesOnMap(places: [PlacePin]) {
        self.PLACE_INSTANT_SHOWUP = true
        //self.placeClusterManager.marginFactor = 10000
        let camera = faeMapView.camera
        camera.altitude = tblPlaceResult.altitude
        faeMapView.setCamera(camera, animated: false)
        reloadPlacePinsOnMap(places: places) {
            self.goTo(annotation: nil, place: self.tblPlaceResult.getGroupLastSelectedPlace(), animated: true)
            self.PLACE_INSTANT_SHOWUP = false
        }
    }
    
    private func loadPlaceDetail() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapPlaceBar))
        tblPlaceResult.addGestureRecognizer(tapGesture)
        
        tblPlaceResult.tblDelegate = self
        tblPlaceResult.barDelegate = self
        view.addSubview(tblPlaceResult)
        
        btnTapToShowResultTbl = UIButton()
        btnTapToShowResultTbl.setImage(#imageLiteral(resourceName: "tapToShowResultTbl"), for: .normal)
        btnTapToShowResultTbl.frame.size = CGSize(width: 58, height: 30)
        btnTapToShowResultTbl.center.x = screenWidth / 2
        btnTapToShowResultTbl.center.y = 181 + device_offset_top
        view.addSubview(btnTapToShowResultTbl)
        btnTapToShowResultTbl.alpha = 0
        btnTapToShowResultTbl.addTarget(self, action: #selector(self.actionShowResultTbl(_:)), for: .touchUpInside)
    }
    
    @objc private func handleTapPlaceBar() {
        placePinAction(action: .detail, mode: .place)
    }
    
    // PlaceViewDelegate
    func goTo(annotation: CCHMapClusterAnnotation? = nil, place: PlacePin? = nil, animated: Bool = true) {
        
        func findAnnotation() {
            if let placeData = place {
                swipingState = .multipleSearch
                var desiredAnno: CCHMapClusterAnnotation!
                for anno in faeMapView.annotations {
                    guard let cluster = anno as? CCHMapClusterAnnotation else { continue }
                    guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { continue }
                    guard let placeInfo = firstAnn.pinInfo as? PlacePin else { continue }
                    if placeInfo == placeData {
                        desiredAnno = cluster
                        break
                    }
                }
                if animated {
                    faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: placeData.coordinate)
                }
                if desiredAnno != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.faeMapView.selectAnnotation(desiredAnno, animated: false)
                    }
                }
            }
        }
        
        deselectAllPlaceAnnos()
        if let anno = annotation {
            swipingState = .map
            boolPreventUserPinOpen = true
            faeMapView.selectAnnotation(anno, animated: false)
            boolPreventUserPinOpen = false
            if animated {
                faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: anno.coordinate)
            }
        }
        
        // If going to prev or next group
        if tblPlaceResult.goingToNextGroup {
            tblPlaceResult.configureCurrentPlaces(goingNext: true)
            self.PLACE_INSTANT_SHOWUP = true
            reloadPlacePinsOnMap(places: tblPlaceResult.places) {
                findAnnotation()
                self.tblPlaceResult.goingToNextGroup = false
                self.PLACE_INSTANT_SHOWUP = false
            }
            return
        } else if tblPlaceResult.goingToPrevGroup {
            self.PLACE_INSTANT_SHOWUP = true
            tblPlaceResult.configureCurrentPlaces(goingNext: false)
            reloadPlacePinsOnMap(places: tblPlaceResult.places) {
                findAnnotation()
                self.tblPlaceResult.goingToPrevGroup = false
                self.PLACE_INSTANT_SHOWUP = false
            }
            return
        } else {
            findAnnotation()
        }
        if let placePin = place { // 必须放在最末尾
            tblPlaceResult.loading(current: placePin)
        }
    }
}

// MARK: - Unread Chat Ctrl

extension FaeMapViewController {
    
    private func loadMapChat() {
        lblUnreadCount.isHidden = true
        updateUnreadChatIndicator()
        if Key.shared.user_id != -1 {
            //faeChat.updateFriendsList()
        }
        if faeChat.notificationRunLoop == nil {
            // each call will start a run loop, so only initialize one
            faeChat.observeMessageChange()
        }
    }
    
    private func updateUnreadChatIndicator() {
        let realm = try! Realm()
        let resultRealmRecents = realm.objects(RealmRecentMessage.self).filter("login_user_id == %@", String(Key.shared.user_id))
        unreadNotiToken = resultRealmRecents.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.setupUnreadNum(resultRealmRecents)
            case .update:
                self?.setupUnreadNum(resultRealmRecents)
            case .error:
                break
            }
        }
    }
    
    private func setupUnreadNum(_ currentRecents: Results<RealmRecentMessage>) {
        var unreadCount = 0
        for recent in currentRecents {
            unreadCount += recent.unread_count
        }
        lblUnreadCount.text = unreadCount > 99 ? "•••" : "\(unreadCount)"
        lblUnreadCount.frame.size.width = unreadCount / 10 >= 1 ? 28 : 22
        btnOpenChat.isSelected = unreadCount != 0
        lblUnreadCount.isHidden = unreadCount == 0
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
}

// MARK: - User Pin

extension FaeMapViewController {
    
    private func viewForUser(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "user"
        var anView: UserPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? UserPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = UserPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.avatar)
        return anView
    }
    
    private func tapUserPin(didSelect view: MKAnnotationView) {
        guard let clusterAnn = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return }
        guard firstAnn.id != -1 else { return }
        guard firstAnn.type == .user else { return }
        boolCanUpdateUsers = false
        boolCanOpenPin = false
        faeMapView.mapGesture(isOn: false)
        uiviewNameCard.userId = firstAnn.id
        uiviewNameCard.show(avatar: firstAnn.avatar) {
            self.boolCanOpenPin = true
        }
        guard let userPin = firstAnn.pinInfo as? UserPin else { return }
        uiviewNameCard.boolSmallSize = !userPin.showOptions
    }
    
    private func updateTimerForUserPin() {
        guard !HIDE_AVATARS else { return }
        updateUserPins()
        timerUserPin?.invalidate()
        timerUserPin = nil
        timerUserPin = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateUserPins), userInfo: nil, repeats: true)
    }
    
    @objc private func updateUserPins() {
        guard !HIDE_AVATARS else { return }
        guard boolCanUpdateUsers else { return }
        let coorDistance = cameraDiagonalDistance(mapView: faeMapView)
        boolCanUpdateUsers = false
        renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        let getMapUserInfo = FaeMap()
        getMapUserInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getMapUserInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getMapUserInfo.whereKey("radius", value: "\(coorDistance)")
        getMapUserInfo.whereKey("type", value: "user")
        getMapUserInfo.whereKey("max_count ", value: "100")
        //        getMapUserInfo.whereKey("user_updated_in", value: "180")
        getMapUserInfo.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("DEBUG: getMapUserInfo status/100 != 2")
                self.boolCanUpdateUsers = true
                return
            }
            let mapUserJSON = JSON(message!)
            guard let mapUserJsonArray = mapUserJSON.array else {
                print("[getMapUserInfo] fail to parse pin comments")
                self.boolCanUpdateUsers = true
                return
            }
            if mapUserJsonArray.count <= 0 {
                self.boolCanUpdateUsers = true
                return
            }
            var userPins = [FaePinAnnotation]()
            DispatchQueue.global(qos: .default).async {
                for userJson in mapUserJsonArray {
                    if userJson["user_id"].intValue == Key.shared.user_id {
                        continue
                    }
                    let userPin = UserPin(json: userJson)
                    var user: FaePinAnnotation? = FaePinAnnotation(type: .user, cluster: self.userClusterManager, data: userPin)
                    guard user != nil else { continue }
                    if self.faeUserPins.contains(user!) {
                        // joshprint("[updateUserPins] yes contains")
                        guard let index = self.faeUserPins.index(of: user!) else { continue }
                        self.faeUserPins[index].positions = (user?.positions)!
                        user = nil
                    } else {
                        // joshprint("[updateUserPins] no")
                        self.faeUserPins.append(user!)
                        userPins.append(user!)
                    }
                }
                guard userPins.count > 0 else {
                    self.boolCanUpdateUsers = true
                    return
                }
                DispatchQueue.main.async {
                    self.userClusterManager.addAnnotations(userPins, withCompletionHandler: nil)
                    for user in userPins {
                        user.isValid = true
                    }
                    self.boolCanUpdateUsers = true
                }
            }
        }
    }
}

// MARK: - Place Pin

extension FaeMapViewController: PlacePinAnnotationDelegate, AddPinToCollectionDelegate, AfterAddedToListDelegate {
    
    // AddPlacetoCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = uiviewSavedList.tableMode
        present(vc, animated: true)
    }
    
    // AfterAddedToListDelegate
    func undoCollect(colId: Int, mode: UndoMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.show()
        switch mode {
        case .save:
            uiviewSavedList.arrListSavedThisPin.append(colId)
        case .unsave:
            if uiviewSavedList.arrListSavedThisPin.contains(colId) {
                let arrListIds = uiviewSavedList.arrListSavedThisPin
                uiviewSavedList.arrListSavedThisPin = arrListIds.filter { $0 != colId }
            }
        }
        switch uiviewSavedList.tableMode {
        case .location:
            if uiviewSavedList.arrListSavedThisPin.count <= 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_loc"), object: nil)
            } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_loc"), object: nil)
            }
            break
        case .place:
            if uiviewSavedList.arrListSavedThisPin.count <= 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_place"), object: nil)
            } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_place"), object: nil)
            }
            break
        }
    }
    
    // AfterAddedToListDelegate
    func seeList() {
        // TODO VICKY
        uiviewAfterAdded.hide()
        if let pin = selectedLocation {
            locationPinClusterManager.removeAnnotations([pin], withCompletionHandler: {
                self.deselectAllLocAnnos()
            })
        }
        let vcList = CollectionsListDetailViewController()
        vcList.enterMode = uiviewSavedList.tableMode
        vcList.colId = uiviewAfterAdded.selectedCollection.collection_id
        //        vcList.colInfo = uiviewAfterAdded.selectedCollection
        //        vcList.arrColDetails = uiviewAfterAdded.selectedCollection
        vcList.featureDelegate = self
        navigationController?.pushViewController(vcList, animated: true)
    }
    
    private func loadPlaceListView() {
        uiviewSavedList = AddPinToCollectionView()
        //        uiviewSavedList.loadCollectionData()
        uiviewSavedList.delegate = self
        uiviewSavedList.tableMode = .place
        view.addSubview(uiviewSavedList)
        
        uiviewAfterAdded = AfterAddedToListView()
        uiviewAfterAdded.delegate = self
        view.addSubview(uiviewAfterAdded)
        
        uiviewSavedList.uiviewAfterAdded = uiviewAfterAdded
    }
    
    private func routingPlace(_ placeInfo: PlacePin) {
        let pin = FaePinAnnotation(type: .place, cluster: placeClusterManager, data: placeInfo)
        pin.animatable = false
        tempFaePins.append(pin)
        HIDE_AVATARS = true
        PLACE_ENABLE = false
        // remove place pins but don't delete them
        placeClusterManager.removeAnnotations(faePlacePins, withCompletionHandler: {
            self.placeClusterManager.isForcedRefresh = true
            self.placeClusterManager.manuallyCallRegionDidChange()
            self.placeClusterManager.isForcedRefresh = false
            self.locationPinClusterManager.addAnnotations([pin], withCompletionHandler: nil)
            self.routeCalculator(destination: pin.coordinate)
        })
        // stop user pins changing location and popping up
        for user in self.faeUserPins {
            user.isValid = false
        }
        // remove user pins but don't delete them
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: {
            self.userClusterManager.isForcedRefresh = true
            self.userClusterManager.manuallyCallRegionDidChange()
            self.userClusterManager.isForcedRefresh = false
        })
        startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
        if let placeInfo = selectedPlace?.pinInfo as? PlacePin {
            uiviewChooseLocs.updateDestination(name: placeInfo.name)
            destinationAddr = RouteAddress(name: placeInfo.name, coordinate: placeInfo.coordinate)
        }
    }
    
    private func routingLocation(pin: FaePinAnnotation) {
        guard let pin = self.selectedLocation else { return }
        uiviewLocationBar.hide()
        selectedLocAnno?.hideButtons()
        selectedLocAnno?.optionsToNormal()
        HIDE_AVATARS = true
        PLACE_ENABLE = false
        // remove place pins but don't delete them
        placeClusterManager.removeAnnotations(faePlacePins, withCompletionHandler: nil)
        placeClusterManager.removeAnnotations(pinsFromSearch, withCompletionHandler: {
            self.placeClusterManager.isForcedRefresh = true
            self.placeClusterManager.manuallyCallRegionDidChange()
            self.placeClusterManager.isForcedRefresh = false
            self.tempFaePins.removeAll()
            self.tempFaePins.append(pin)
            self.locationPinClusterManager.addAnnotations(self.tempFaePins, withCompletionHandler: nil)
            self.routeCalculator(destination: pin.coordinate)
        })
        // stop user pins changing location and popping up
        for user in self.faeUserPins {
            user.isValid = false
        }
        // remove user pins but don't delete them
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: {
            self.userClusterManager.isForcedRefresh = true
            self.userClusterManager.manuallyCallRegionDidChange()
            self.userClusterManager.isForcedRefresh = false
        })
        startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
        // destinationAddr has been set in FMLocationPin.swift when create a temporary location pin on map
    }
    
    // PlacePinAnnotationDelegate
    func placePinAction(action: PlacePinAction, mode: CollectionTableMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.hide()
        switch action {
        case .detail:
            switch mode {
            case .place:
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else {
                    return
                }
                let vc = PlaceDetailViewController()
                vc.place = placeData
                navigationController?.pushViewController(vc, animated: true)
            case .location:
                guard let anView = selectedLocAnno else { return }
                anView.optionsToNormal()
                let vc = LocDetailViewController()
                vc.locationId = anView.locationId
                vc.coordinate = selectedLocation?.coordinate
                vc.delegate = self
                vc.strLocName = uiviewLocationBar.lblName.text ?? "Invalid Name"
                vc.strLocAddr = uiviewLocationBar.lblAddr.text ?? "Invalid Address"
                vc.boolCreated = modeLocCreating == .on
                navigationController?.pushViewController(vc, animated: true)
            }
        case .collect:
            uiviewSavedList.show()
            selectedLocAnno?.optionsToNormal()
            uiviewSavedList.tableMode = mode
            uiviewSavedList.tblAddCollection.reloadData()
            switch mode {
            case .place:
                guard let placePin = selectedPlace else { return }
                uiviewSavedList.pinToSave = placePin
            case .location:
                guard let locPin = selectedLocation else { return }
                uiviewSavedList.pinToSave = locPin
            }
        case .route:
            if selectedLocation != nil {
                routingLocation(pin: selectedLocation!)
            }
            if let place = selectedPlace?.pinInfo as? PlacePin {
                routingPlace(place)
            }
        case .share:
            if modeLocCreating == .on {
                selectedLocAnno?.optionsToNormal()
                selectedLocAnno?.hideButtons()
                let vcShareCollection = NewChatShareController(friendListMode: .location)
                let coordinate = selectedLocation?.coordinate
                AddPinToCollectionView().mapScreenShot(coordinate: coordinate!) { (snapShotImage) in
                    vcShareCollection.locationDetail = "\(coordinate?.latitude ?? 0.0),\(coordinate?.longitude ?? 0.0),\(self.uiviewLocationBar.lblName.text ?? "Invalid Name"),\(self.uiviewLocationBar.lblAddr.text ?? "Invalid Address")"
                    vcShareCollection.locationSnapImage = snapShotImage
                    self.navigationController?.pushViewController(vcShareCollection, animated: true)
                }
            } else {
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else { return }
                selectedPlaceAnno?.hideButtons()
                let vcSharePlace = NewChatShareController(friendListMode: .place)
                vcSharePlace.placeDetail = placeData
                navigationController?.pushViewController(vcSharePlace, animated: true)
            }
        }
    }
    
    private func viewForPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "place"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.iconIndex = first.class_2_icon_id
        if swipingState == .multipleSearch {
            if let placePin = first.pinInfo as? PlacePin {
                let tag = tblPlaceResult.tblResults.tag
                if let lastSelected = tblPlaceResult.groupLastSelected[tag] {
                    if placePin == lastSelected {
                        let icon = UIImage(named: "place_map_\(anView.iconIndex)s") ?? #imageLiteral(resourceName: "place_map_48s")
                        anView.assignImage(icon)
                        tapPlacePin(didSelect: anView)
                    } else {
                        anView.assignImage(first.icon)
                    }
                } else {
                    anView.assignImage(first.icon)
                }
            } else {
                anView.assignImage(first.icon)
            }
        } else {
            anView.assignImage(first.icon)
        }
        if first.isSelected {
            let icon = UIImage(named: "place_map_\(anView.iconIndex)s") ?? #imageLiteral(resourceName: "place_map_48s")
            anView.assignImage(icon)
            anView.optionsReady = true
            anView.optionsOpened = false
            selectedPlaceAnno = anView
        }
        anView.delegate = self
        return anView
    }
    
    private func viewForSelectedPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "place_selected"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.icon)
        anView.delegate = self
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        return anView
    }
    
    private func visiblePlaces(full: Bool = false) -> [CCHMapClusterAnnotation] {
        var mapRect = faeMapView.visibleMapRect
        if !full {
            mapRect.origin.y += mapRect.size.height * 0.3
            mapRect.size.height = mapRect.size.height * 0.7
        }
        let visibleAnnos = faeMapView.annotations(in: mapRect)
        var places = [CCHMapClusterAnnotation]()
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let place = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
                guard faeMapView.view(for: place) is PlacePinAnnotationView else { continue }
                guard firstAnn.type == .place else { continue }
                places.append(place)
            } else {
                continue
            }
        }
        return places
    }
    
    private func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? PlacePinAnnotationView else { return }
        let idx = firstAnn.class_2_icon_id
        firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48s")
        firstAnn.isSelected = true
        anView.assignImage(firstAnn.icon)
        selectedPlace = firstAnn
        selectedPlaceAnno = anView
        faeMapView.selectedPlaceAnno = anView
        selectedPlaceAnno?.superview?.bringSubview(toFront: selectedPlaceAnno!)
        selectedPlaceAnno?.zPos = 199
        guard firstAnn.type == .place else { return }
        guard let placePin = firstAnn.pinInfo as? PlacePin else { return }
        if anView.optionsOpened {
            uiviewSavedList.arrListSavedThisPin.removeAll()
            FaeMap.shared.getPinSavedInfo(id: placePin.id, type: "place") { (ids) in
                let placeData = placePin
                placeData.arrListSavedThisPin = ids
                firstAnn.pinInfo = placeData as AnyObject
                self.uiviewSavedList.arrListSavedThisPin = ids
                anView.boolShowSavedNoti = ids.count > 0
            }
        }
        tblPlaceResult.show()
        tblPlaceResult.resetSubviews()
        tblPlaceResult.tag = 1
        mapView(faeMapView, regionDidChangeAnimated: false)
        if swipingState == .map {
            tblPlaceResult.loadingData(current: cluster)
        } else if swipingState == .multipleSearch {
            tblPlaceResult.loading(current: placePin)
        }
    }
    
    private func updatePlacePins() {
        let coorDistance = cameraDiagonalDistance(mapView: faeMapView)
        refreshPlacePins(radius: coorDistance)
    }
    
    private func refreshPlacePins(radius: Int) {
        func getDelay(prevTime: DispatchTime) -> Double {
            let standardInterval: Double = 1
            let nowTime = DispatchTime.now()
            let timeDiff = Double(nowTime.uptimeNanoseconds - prevTime.uptimeNanoseconds)
            var delay: Double = 0
            if timeDiff / Double(NSEC_PER_SEC) < standardInterval {
                delay = standardInterval - timeDiff / Double(NSEC_PER_SEC)
            } else {
                delay = timeDiff / Double(NSEC_PER_SEC) - standardInterval
            }
            return delay
        }
        
        func stopIconSpin(delay: Double) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.btnFilterIcon.stopIconSpin()
            })
        }
        let time_0 = DispatchTime.now()
        guard PLACE_ENABLE else {
            stopIconSpin(delay: getDelay(prevTime: time_0))
            return
        }
        guard boolCanUpdatePlaces else {
            stopIconSpin(delay: getDelay(prevTime: time_0))
            return
        }
        boolCanUpdatePlaces = false
        renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        
        // Add test data
        
        guard !USE_TEST_PLACES else {
            let places = generator(mapCenterCoordinate, 100, faePlacePins.count)
            let placePins = places.map( { FaePinAnnotation(type: .place, cluster: placeClusterManager, data: $0 as AnyObject) } )
            placeClusterManager.addAnnotations(placePins, withCompletionHandler: {
                self.faePlacePins += placePins
            })
            self.boolCanUpdatePlaces = true
            stopIconSpin(delay: getDelay(prevTime: time_0))
            return
        }
        
        FaeMap.shared.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        FaeMap.shared.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        FaeMap.shared.whereKey("radius", value: "\(radius)")
        FaeMap.shared.whereKey("type", value: "place")
        FaeMap.shared.whereKey("max_count", value: "200")
        FaeMap.shared.getMapInformation { (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
                self.boolCanUpdatePlaces = true
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
                self.boolCanUpdatePlaces = true
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
                self.boolCanUpdatePlaces = true
                return
            }
            self.placeAdderQueue.cancelAllOperations()
            let adder = PlacesAdder(cluster: self.placeClusterManager, arrPlaceJSON: mapPlaceJsonArray, idSet: self.setPlacePins)
            adder.completionBlock = {
                DispatchQueue.main.async {
                    if adder.isCancelled {
                        return
                    }
                    self.placeClusterManager.addAnnotations(adder.placePins, withCompletionHandler: {
                        self.setPlacePins = self.setPlacePins.union(Set(adder.ids))
                        self.faePlacePins += adder.placePins
                    })
                }
            }
            self.placeAdderQueue.addOperation(adder)
            self.boolCanUpdatePlaces = true
            stopIconSpin(delay: getDelay(prevTime: time_0))
        }
    }
    
    // MARK: - Reload Place Pins
    private func reloadPlacePinsOnMap(places: [PlacePin], completion: @escaping () -> Void) {
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(pinsFromSearch) {
            self.pinsFromSearch = places.map({ FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0 as AnyObject) })
            self.placeClusterManager.addAnnotations(self.pinsFromSearch, withCompletionHandler: {
                self.placeClusterManager.isForcedRefresh = false
                completion()
            })
        }
    }
}

// MARK: - Routing
extension FaeMapViewController: FMRouteCalculateDelegate, BoardsSearchDelegate {
    
    private func loadDistanceComponents() {
        btnDistIndicator = FMDistIndicator()
        view.addSubview(btnDistIndicator)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectLocationTap(_:)))
        btnDistIndicator.addGestureRecognizer(tapGesture)
        
        uiviewChooseLocs = FMChooseLocs()
        uiviewChooseLocs.delegate = self
        view.addSubview(uiviewChooseLocs)
        
        let tapStart = UITapGestureRecognizer(target: self, action: #selector(handleStartPointTap(_:)))
        let tapDestination = UITapGestureRecognizer(target: self, action: #selector(handleDestinationTap(_:)))
        uiviewChooseLocs.lblStartPoint.addGestureRecognizer(tapStart)
        uiviewChooseLocs.lblDestination.addGestureRecognizer(tapDestination)
        
        loadSelectLocIcon()
    }
    
    private func loadSelectLocIcon() {
        imgSelectLocIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 52))
        imgSelectLocIcon.image = #imageLiteral(resourceName: "icon_destination")
        imgSelectLocIcon.center.x = screenWidth / 2
        imgSelectLocIcon.center.y = screenHeight / 2 - 26
        imgSelectLocIcon.layer.zPosition = uiviewChooseLocs.layer.zPosition
        imgSelectLocIcon.isHidden = true
        view.addSubview(imgSelectLocIcon)
    }
    
    @objc private func handleStartPointTap(_ tap: UITapGestureRecognizer) {
        BoardsSearchViewController.boolToDestination = false
        routingHandleTap()
    }
    
    @objc private func handleDestinationTap(_ tap: UITapGestureRecognizer) {
        BoardsSearchViewController.boolToDestination = true
        routingHandleTap()
    }
    
    private func routingHandleTap() {
        let chooseLocsVC = BoardsSearchViewController()
        chooseLocsVC.enterMode = .location
        chooseLocsVC.delegate = self
        chooseLocsVC.boolCurtLocSelected = uiviewChooseLocs.lblStartPoint.text == "Current Location" || uiviewChooseLocs.lblDestination.text == "Current Location"
        chooseLocsVC.boolFromRouting = true
        navigationController?.pushViewController(chooseLocsVC, animated: false)
    }
    
    @objc private func handleSelectLocationTap(_ tap: UITapGestureRecognizer) {
        guard routeAddress != nil else { return }
        sendLocationBack(address: routeAddress)
    }
    
    // BoardsSearchDelegate
    func chooseLocationOnMap() {
        uiviewChooseLocs.hide(animated: false)
        mapMode = .selecting
        mapView(faeMapView, regionDidChangeAnimated: false)
    }
    
    // BoardsSearchDelegate
    func sendLocationBack(address: RouteAddress) {
        faeMapView.removeAnnotations(addressAnnotations)
        if BoardsSearchViewController.boolToDestination {
            destinationAddr = address
            uiviewChooseLocs.lblDestination.text = address.name
            if addressAnnotations.count > 0 {
                var index = 0
                var found = false
                for i in 0..<addressAnnotations.count {
                    if !addressAnnotations[i].isStartPoint {
                        index = i
                        found = true
                        break
                    }
                }
                if found { addressAnnotations.remove(at: index) }
            }
            if address.name != "Current Location" {
                let end = AddressAnnotation()
                end.isStartPoint = false
                end.coordinate = destinationAddr.coordinate
                addressAnnotations.append(end)
            }
        } else {
            startPointAddr = address
            uiviewChooseLocs.lblStartPoint.text = address.name
            
            if addressAnnotations.count > 0 {
                var index = 0
                var found = false
                for i in 0..<addressAnnotations.count {
                    if addressAnnotations[i].isStartPoint {
                        index = i
                        found = true
                        break
                    }
                }
                if found { addressAnnotations.remove(at: index) }
            }
            if address.name != "Current Location" {
                let start = AddressAnnotation()
                start.isStartPoint = true
                start.coordinate = startPointAddr.coordinate
                addressAnnotations.append(start)
            }
        }
        if startPointAddr.name == "Current Location" {
            routeCalculator(startPoint: LocManager.shared.curtLoc.coordinate, destination: destinationAddr.coordinate)
        } else if destinationAddr.name == "Current Location" {
            routeCalculator(startPoint: startPointAddr.coordinate, destination: LocManager.shared.curtLoc.coordinate)
        } else {
            routeCalculator(startPoint: startPointAddr.coordinate, destination: destinationAddr.coordinate)
        }
        faeMapView.addAnnotations(addressAnnotations)
    }
    
    private func showRouteCalculatorComponents(distance: CLLocationDistance) {
        mapMode = .routing
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
        
        btnDistIndicator.show()
        btnDistIndicator.updateDistance(distance: distance)
        
        tblPlaceResult.hide()
        uiviewChooseLocs.show()
        
        animateMainItems(show: true)
        selectedPlaceAnno?.hideButtons()
        selectedPlaceAnno = nil
        
        faeMapView.singleTap.isEnabled = false
        faeMapView.doubleTap.isEnabled = false
        faeMapView.longPress.isEnabled = false
    }
    
    // FMRouteCalculateDelegate
    func hideRouteCalculatorComponents() {
        mapMode = .normal
        HIDE_AVATARS = Key.shared.hideAvatars
        PLACE_ENABLE = true
        faeMapView.removeAnnotations(addressAnnotations)
        
        isRoutingCancelled = true
        
        // locPinCluster is used to manipulate place pin routing, too
        locationPinClusterManager.removeAnnotations(tempFaePins) {
            self.locationPinClusterManager.isForcedRefresh = true
            self.locationPinClusterManager.manuallyCallRegionDidChange()
            self.locationPinClusterManager.isForcedRefresh = false
            self.reAddUserPins()
            self.PLACE_INSTANT_SHOWUP = true
            if self.selectedPlace != nil {
                self.placeClusterManager.addAnnotations([self.selectedPlace!], withCompletionHandler: {
                    self.reAddPlacePins({
                        self.PLACE_INSTANT_SHOWUP = false
                    })
                })
            } else {
                self.reAddPlacePins({
                    self.PLACE_INSTANT_SHOWUP = false
                })
            }
            self.LOC_INSTANT_SHOWUP = true
            self.reAddLocPins({
                self.LOC_INSTANT_SHOWUP = false
            })
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
        
        removeAllRoutes()
        btnDistIndicator.hide()
        uiviewChooseLocs.hide()
        btnZoom.tapToSmallMode()
        animateMainItems(show: false)
        
        faeMapView.singleTap.isEnabled = true
        faeMapView.doubleTap.isEnabled = true
        faeMapView.longPress.isEnabled = true
    }
    
    private func animateMainItems(show: Bool, animated: Bool = true) {
        if show {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                    self.btnLocateSelf.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                    self.btnOpenChat.frame.origin.y = screenHeight + 10
                    self.btnDiscovery.frame.origin.y = screenHeight + 10
                    self.btnFilterIcon.frame.origin.y = screenHeight + 10
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                self.btnLocateSelf.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                self.btnOpenChat.frame.origin.y = screenHeight + 10
                self.btnDiscovery.frame.origin.y = screenHeight + 10
                self.btnFilterIcon.frame.origin.y = screenHeight + 10
            }
            faeMapView.cgfloatCompassOffset = 134
            faeMapView.layoutSubviews()
        } else {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnFilterIcon.center.y = screenHeight - 25 - device_offset_bot
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnFilterIcon.center.y = screenHeight - 25 - device_offset_bot
            }
            faeMapView.cgfloatCompassOffset = 215
            faeMapView.layoutSubviews()
        }
    }
    
    private func removeAllRoutes() {
        for route in arrRoutes {
            faeMapView.remove(route)
        }
        arrRoutes.removeAll()
    }
    
    private func routeCalculator(startPoint: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate, destination: CLLocationCoordinate2D) {
        
        removeAllRoutes()
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPoint, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        showRouteCalculatorComponents(distance: 0)
        btnDistIndicator.lblDistance.isHidden = true
        btnDistIndicator.activityIndicator.startAnimating()
        isRoutingCancelled = false
        doRouting(request)
    }
    
    private func doRouting(_ request: MKDirectionsRequest) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let cancelRouting = self?.isRoutingCancelled else {
                self?.btnDistIndicator.activityIndicator.stopAnimating()
                return
            }
            guard !cancelRouting else {
                self?.btnDistIndicator.activityIndicator.stopAnimating()
                return
            }
            MKDirections(request: request).calculate { [weak self] response, error in
                self?.btnDistIndicator.activityIndicator.stopAnimating()
                guard let cancelRouting = self?.isRoutingCancelled else { return }
                guard !cancelRouting else { return }
                guard let unwrappedResponse = response else {
                    showAlert(title: "Sorry! This route is too long to draw.", message: "please try again", viewCtrler: self)
                    return
                }
                var totalDistance: CLLocationDistance = 0
                for route in unwrappedResponse.routes {
                    self?.arrRoutes.append(route.polyline)
                    totalDistance += route.distance
                }
                totalDistance /= 1000
                if Key.shared.measurementUnits == "imperial" {
                    totalDistance *= 0.621371
                }
                if totalDistance > 3000 {
                    showAlert(title: "Sorry! This route is too long to draw.", message: "please try again", viewCtrler: self)
                    return
                }
                self?.showRouteCalculatorComponents(distance: totalDistance)
                // fit all route overlays
                if let first = self?.arrRoutes.first {
                    guard let rect = self?.arrRoutes.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)}) else { return }
                    self?.faeMapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 150, left: 50, bottom: 90, right: 50), animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
                    guard let cancelRouting = self?.isRoutingCancelled else { return }
                    guard !cancelRouting else { return }
                    guard let routes = self?.arrRoutes else { return }
                    self?.faeMapView.addOverlays(routes, level: MKOverlayLevel.aboveRoads)
                })
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = IVBezierPathRenderer(overlay: overlay)
        renderer.strokeColor = UIColor._206184231()
        renderer.lineWidth = 8
        renderer.lineCap = .round
        renderer.lineJoin = .round
        renderer.borderColor = UIColor._182150210()
        renderer.borderMultiplier = 1.5
        return renderer
    }
}

// MARK: - Invisible Mode

extension FaeMapViewController {
    
    private func invisibleMode() {
        let dimBackground = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dimBackground.backgroundColor = UIColor._107105105_a50()
        dimBackground.alpha = 0
        dimBackground.layer.zPosition = 999
        view.addSubview(dimBackground)
        dimBackground.addTarget(self, action: #selector(invisibleModeDimClicked(_:)), for: .touchUpInside)
        
        var offset: CGFloat = 155
        if screenHeight == 812 {
            offset = 230
        }
        let uiviewInvisible = UIView(frame: CGRect(x: 62, y: offset, w: 290, h: 380))
        uiviewInvisible.backgroundColor = .white
        uiviewInvisible.layer.cornerRadius = 16 * screenWidthFactor
        dimBackground.addSubview(uiviewInvisible)
        
        let lblTitle = UILabel(frame: CGRect(x: 73, y: 27, w: 144, h: 44))
        lblTitle.text = "You're now in\n Invisible Mode!"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        lblTitle.numberOfLines = 0
        lblTitle.textAlignment = NSTextAlignment.center
        lblTitle.textColor = UIColor(red: 89 / 255, green: 89.0 / 255, blue: 89.0 / 255, alpha: 1.0)
        uiviewInvisible.addSubview(lblTitle)
        
        let imgInvisible = UIImageView(frame: CGRect(x: 89, y: 87, w: 117, h: 139))
        imgInvisible.image = UIImage(named: "InvisibleMode")
        uiviewInvisible.addSubview(imgInvisible)
        
        let lblNote = UILabel(frame: CGRect(x: 41, y: 236, w: 209, h: 66))
        lblNote.numberOfLines = 0
        lblNote.text = "You are Hidden...\nNo one can see you and you\ncan't be discovered!"
        lblNote.textAlignment = NSTextAlignment.center
        lblNote.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1)
        lblNote.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        uiviewInvisible.addSubview(lblNote)
        
        let btnOkay = UIButton(frame: CGRect(x: 41, y: 315, w: 209, h: 40))
        btnOkay.setTitle("Got it!", for: .normal)
        btnOkay.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        btnOkay.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        btnOkay.layer.cornerRadius = 20 * screenWidthFactor
        btnOkay.addTarget(self, action: #selector(self.invisibleModeGotItClicked(_:)), for: .touchUpInside)
        uiviewInvisible.addSubview(btnOkay)
        
        UIView.animate(withDuration: 0.3) {
            dimBackground.alpha = 1
        }
    }
    
    @objc private func invisibleModeDimClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 0
        }, completion: { _ in
            sender.removeFromSuperview()
        })
    }
    
    @objc private func invisibleModeGotItClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.superview?.superview?.alpha = 0
        }, completion: { _ in
            sender.superview?.superview?.removeFromSuperview()
        })
    }
}

// MARK: - Guest Mode

extension FaeMapViewController {
    
    private func guestMode() {
        let uiViewGuestMode = UIView(frame: CGRect(x: 62, y: 155, w: 290, h: 380))
        uiViewGuestMode.backgroundColor = UIColor.white
        uiViewGuestMode.layer.cornerRadius = 16 * screenWidthFactor
        self.view.addSubview(uiViewGuestMode)
        
        let labelTitleGuest = UILabel(frame: CGRect(x: 73, y: 27, w: 144, h: 44))
        labelTitleGuest.text = "You are currently in\n Guest Mode!"
        labelTitleGuest.numberOfLines = 0
        labelTitleGuest.textAlignment = .center
        labelTitleGuest.textColor = UIColor._898989()
        labelTitleGuest.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        uiViewGuestMode.addSubview(labelTitleGuest)
        
        let imageAvatarGuest = UIImageView(frame: CGRect(x: 55, y: 101, w: 180, h: 139))
        imageAvatarGuest.image = UIImage(named: "GuestMode")
        uiViewGuestMode.addSubview(imageAvatarGuest)
        
        let buttonGuestLogIn = UIButton(frame: CGRect(x: 40, y: 263, w: 210, h: 40))
        buttonGuestLogIn.setTitle("Log In", for: .normal)
        buttonGuestLogIn.layer.cornerRadius = 20 * screenWidthFactor
        buttonGuestLogIn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        buttonGuestLogIn.backgroundColor = UIColor._2499090()
        buttonGuestLogIn.addTarget(self, action: #selector(buttonGuestLogInClicked(_:)), for: .touchUpInside)
        uiViewGuestMode.addSubview(buttonGuestLogIn)
        
        let buttonGuestCreateCount = UIButton(frame: CGRect(x: 40, y: 315, w: 210, h: 40))
        buttonGuestCreateCount.setTitle("Create a Fae Count", for: .normal)
        buttonGuestCreateCount.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        buttonGuestCreateCount.setTitleColor(UIColor._2499090(), for: .normal)
        // buttonGuestCreateCount.titleLabel?.textColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0) 改变不了button title的颜色
        buttonGuestCreateCount.layer.borderColor = UIColor._2499090().cgColor
        buttonGuestCreateCount.layer.cornerRadius = 20 * screenWidthFactor
        buttonGuestCreateCount.backgroundColor = UIColor.white
        buttonGuestCreateCount.layer.borderWidth = 2.5
        buttonGuestCreateCount.addTarget(self, action: #selector(buttonGuestCreateCountClicked(_:)), for: .touchUpInside)
        uiViewGuestMode.addSubview(buttonGuestCreateCount)
    }
    
    @objc private func buttonGuestLogInClicked(_ sender: UIButton) {
        print("guest log in")
    }
    
    @objc private func buttonGuestCreateCountClicked(_ sender: UIButton) {
        print("Create an account")
    }
}

// MARK: - Location Pin

extension FaeMapViewController: LocDetailDelegate {
    
    // MARK: - LocDetailDelegate
    func jumpToViewLocation(coordinate: CLLocationCoordinate2D, created: Bool) {
        if !created {
            createLocationPin(point: CGPoint.zero, position: coordinate)
            modeLocation = .on_create
        } else {
            selectedLocAnno?.hideButtons(animated: false)
            selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
            selectedLocAnno?.assignImage(#imageLiteral(resourceName: "icon_destination"))
            modeLocation = .on
        }
        removePlaceUserPins()
        animateMainItems(show: true, animated: boolFromMap)
        btnBackToExp.removeTarget(nil, action: nil, for: .touchUpInside)
        btnBackToExp.addTarget(self, action: #selector(actionBackToLocDetail), for: .touchUpInside)
    }
    
    @objc private func actionBackToLocDetail() {
        animateMainItems(show: false, animated: boolFromMap)
        reAddUserPins()
        reAddPlacePins()
        selectedLocation?.icon = #imageLiteral(resourceName: "icon_startpoint")
        selectedLocAnno?.assignImage(#imageLiteral(resourceName: "icon_startpoint"))
        if modeLocation == .on_create {
            modeLocCreating = .off
        }
        modeLocation = .off
        navigationController?.setViewControllers(arrCtrlers, animated: false)
    }
    
    private func tapLocationPin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? LocPinAnnotationView else { return }
        anView.assignImage(#imageLiteral(resourceName: "icon_destination"))
        selectedLocation = firstAnn
        selectedLocAnno = anView
        faeMapView.selectedLocAnno = anView
        selectedLocAnno?.zPos = 299
        guard firstAnn.type == .location else { return }
        guard let locationData = firstAnn.pinInfo as? LocationPin else { return }
        if anView.optionsOpened {
            let pinData = locationData
            if pinData.id == -1 {
                pinData.id = anView.locationId
            }
            uiviewSavedList.arrListSavedThisPin.removeAll()
            FaeMap.shared.getPinSavedInfo(id: pinData.id, type: "location") { (ids) in
                pinData.arrListSavedThisPin = ids
                firstAnn.pinInfo = pinData as AnyObject
                self.uiviewSavedList.arrListSavedThisPin = ids
                anView.boolShowSavedNoti = ids.count > 0
            }
        }
        if !anView.optionsReady {
            let cllocation = CLLocation(latitude: locationData.coordinate.latitude, longitude: locationData.coordinate.longitude)
            uiviewLocationBar.updateLocationInfo(location: cllocation) { (address_1, address_2) in
                self.selectedLocation?.address_1 = address_1
                self.selectedLocation?.address_2 = address_2
                self.uiviewChooseLocs.updateDestination(name: address_1)
                self.destinationAddr = RouteAddress(name: address_1, coordinate: cllocation.coordinate)
            }
        }
        mapView(faeMapView, regionDidChangeAnimated: false)
    }
    
    private func loadLocInfoBar() {
        uiviewLocationBar = FMLocationInfoBar()
        view.addSubview(uiviewLocationBar)
        uiviewLocationBar.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLocInfoBarTap))
        uiviewLocationBar.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleLocInfoBarTap() {
        placePinAction(action: .detail, mode: .location)
    }
    
    private func viewForLocation(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "location\(mapMode)"
        var anView: LocPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = LocPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        selectedLocAnno = anView
        anView.assignImage(first.icon)
        if first.isSelected {
            // when back from routing, re-select the location
            anView.assignImage(#imageLiteral(resourceName: "icon_destination"))
            anView.optionsReady = true
            anView.optionsOpened = false
        }
        anView.delegate = self
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        if let locationData = first.pinInfo as? LocationPin {
            anView.optionsReady = locationData.optionsReady
        }
        return anView
    }
    
    private func createLocationPin(point: CGPoint, position: CLLocationCoordinate2D? = nil) {
        guard modeLocation == .off else { return }
        modeLocCreating = .on
        uiviewAfterAdded.reset()
        var coordinate: CLLocationCoordinate2D!
        if position == nil {
            coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        } else {
            guard let coor = position else { return }
            coordinate = coor
        }
        let cllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        func createLoc() {
            tblPlaceResult.hide()
            selectedLocAnno?.hideButtons()
            selectedLocAnno?.optionsReady = false
            selectedLocAnno?.optionsOpened = false
            selectedLocAnno?.optionsOpeing = false
            selectedLocAnno?.removeFromSuperview()
            selectedLocAnno = nil
            deselectAllPlaceAnnos()
            let pinData = LocationPin(position: coordinate)
            pinData.optionsReady = true
            selectedLocation = FaePinAnnotation(type: .location, data: pinData as AnyObject)
            selectedLocation?.isSelected = true
            selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
            locationPinClusterManager.addAnnotations([self.selectedLocation!], withCompletionHandler: nil)
            uiviewLocationBar.updateLocationInfo(location: cllocation) { (address_1, address_2) in
                self.selectedLocation?.address_1 = address_1
                self.selectedLocation?.address_2 = address_2
                self.uiviewChooseLocs.updateDestination(name: address_1)
                self.destinationAddr = RouteAddress(name: address_1, coordinate: cllocation.coordinate)
            }
        }
        
        if selectedLocation != nil {
            locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: {
                self.selectedLocation = nil
                createLoc()
            })
        } else {
            createLoc()
        }
    }
}

// MARK: - MapAction Protocol
extension FaeMapViewController: MapAction {
    func iconStyleChange(action: Int, isPlace: Bool) {
        if isPlace {
            guard let anView = selectedPlaceAnno else { return }
            switch action {
            case 1:
                anView.action(anView.btnDetail, animated: true)
            case 2:
                anView.action(anView.btnCollect, animated: true)
            case 3:
                anView.action(anView.btnRoute, animated: true)
            case 4:
                anView.action(anView.btnShare, animated: true)
            default:
                anView.optionsToNormal()
                break
            }
        } else {
            guard let anView = selectedLocAnno else { return }
            switch action {
            case 1:
                anView.action(anView.btnDetail, animated: true)
            case 2:
                anView.action(anView.btnCollect, animated: true)
            case 3:
                anView.action(anView.btnRoute, animated: true)
            case 4:
                anView.action(anView.btnShare, animated: true)
            default:
                anView.optionsToNormal()
                break
            }
        }
        if action == 0 {
            uiviewPinActionDisplay.hide()
        } else {
            uiviewPinActionDisplay.changeStyle(action: PlacePinAction(rawValue: action)!, isPlace)
        }
    }
    
    func placePinTap(view: MKAnnotationView) {
        tapPlacePin(didSelect: view)
    }
    
    func userPinTap(view: MKAnnotationView) {
        tblPlaceResult.hide()
        tapUserPin(didSelect: view)
    }
    
    func locPinTap(view: MKAnnotationView) {
        tapLocationPin(didSelect: view)
    }
    
    func allPlacesDeselect(_ full: Bool) {
        deselectAllPlaceAnnos(full: full)
    }
    
    func singleElsewhereTap() {
        uiviewSavedList.hide()
        btnZoom.tapToSmallMode()
    }
    
    func singleElsewhereTapExceptInfobar() {
        faeMapView.mapGesture(isOn: true)
        if swipingState != .multipleSearch {
            tblPlaceResult.hide()
        }
        deselectAllPlaceAnnos(full: swipingState == .map)
    }
    
    func locPinCreating(point: CGPoint) {
        createLocationPin(point: point)
    }
    
    func locPinCreatingCancel() {
        if modeLocCreating == .on {
            if modeLocation == .off {
                modeLocCreating = .off
            }
        } else if modeLocCreating == .off {
            selectedLocAnno?.assignImage(#imageLiteral(resourceName: "icon_destination"))
            deselectAllLocAnnos()
        }
    }
    
    func singleTapAllTimeControl() {
        guard uiviewDropUpMenu != nil && mapMode == .normal else { return }
        uiviewDropUpMenu.hide()
        btnDropUpMenu.isSelected = false
    }
    
    func doubleElsewhereTap() {
        faeMapView.mapGesture(isOn: true)
    }
    
    func doubleTapAllTimeControl() {
        guard uiviewDropUpMenu != nil else { return }
        uiviewDropUpMenu.hide()
        btnDropUpMenu.isSelected = false
    }
    
    func longPressAllTimeCtrlWhenBegan() {
        guard uiviewDropUpMenu != nil else { return }
        uiviewDropUpMenu.hide()
        btnDropUpMenu.isSelected = false
    }
}
