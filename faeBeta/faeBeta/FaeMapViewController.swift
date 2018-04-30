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
    var PLACE_ANIMATED = true
    var placeAdderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "adder queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
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
    var btnDropUpMenu: UIButton!
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
    var btnFilterIcon: FMRefreshIcon! // Filter Button
    var uiviewDropUpMenu: FMDropUpMenu! // 
    var sizeFrom: CGFloat = 0 // Pan gesture var
    var sizeTo: CGFloat = 0 // Pan gesture var
    var end: CGFloat = 0 // Pan gesture var
    var percent: Double = 0 // Pan gesture var
    let floatFilterHeight = 471 * screenHeightFactor + device_offset_bot // Map Filter height
    
    // Selected Place Control
    var selectedPlaceView: PlacePinAnnotationView?
    var selectedPlace: FaePinAnnotation?
    var swipingState: PlaceInfoBarState = .map {
        didSet {
            guard fullyLoaded else { return }
            btnTapToShowResultTbl.alpha = swipingState == .multipleSearch ? 1 : 0
            btnTapToShowResultTbl.isHidden = swipingState != .multipleSearch
            tblPlaceResult.isHidden = swipingState != .multipleSearch
        }
    }
    var boolSelecting = false
    var firstSelectPlace = true
    
    // Place Pin Control
    var placePinOPQueue: OperationQueue!
    
    // Results from Search
    var btnTapToShowResultTbl: UIButton!
    var tblPlaceResult = FMPlacesTable()
    var placesFromSearch = [PlacePin]()
    var locationsFromSearch = [LocationPin]()
    var pinsFromSearch = [FaePinAnnotation]()
    
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
    var activityIndicatorLocPin: UIActivityIndicatorView!
    var locationPinClusterManager: CCHMapClusterController!
    
    // Chat
    let faeChat = FaeChat()
    let faePush = FaePush()
    var intFriendsRequested: Int = 0
    
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
    var PLACE_INSTANT_SHOWUP = false
    
    var unreadNotiToken: NotificationToken? = nil
    
    // Filter Menu Place Collection Interface to Show All Saved Pins
    var completionCount = 0 {
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
    var desiredCount = 0
    
    // Auxiliary
    var activityIndicator: UIActivityIndicatorView!
    
    // System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Key.shared.FMVCtrler = self
        AUTO_REFRESH = Key.shared.autoRefresh
        AUTO_CIRCLE_PINS = Key.shared.autoCycle
        HIDE_AVATARS = Key.shared.hideAvatars
        
        isUserLoggedIn()
        getUserStatus()
        
        initUserDataFromServer()
        
        loadNameCard()
        loadMapFilter()
        loadMapView()
        loadButton()
        view.bringSubview(toFront: uiviewDropUpMenu)
        loadExploreBar()
        loadPlaceDetail()
        loadPlaceListView()
        loadDistanceComponents()
        loadSmallClctView()
        loadLocationView()
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
    
    func checkIfResultTableAppearred() {
        guard modePinDetail == .off else { return }
        tblPlaceResult.isHidden = !tblPlaceResult.showed
        btnTapToShowResultTbl.isHidden = !(tblPlaceResult.showed && swipingState == .multipleSearch)
    }
    
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
                activityIndicatorLocPin.stopAnimating()
                if uiviewAfterAdded.frame.origin.y != screenHeight {
                    uiviewAfterAdded.hide()
                }
                if selectedLocation != nil {
                    locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: {
                        self.deselectAllLocations()
                    })
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
            btnZoom.alpha = modeExplore == .on ? 0 : 1
            btnLocateSelf.alpha = modeExplore == .on ? 0 : 1
            btnOpenChat.isHidden = modeExplore == .on
            btnFilterIcon.isHidden = modeExplore == .on
            btnDiscovery.isHidden = modeExplore == .on
            
            faeMapView.isRotateEnabled = modeExplore == .off
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
    
    var modePinDetail: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            btnLeftWindow.isHidden = modePinDetail == .on
            imgSchbarShadow.isHidden = modePinDetail == .on
            imgExpbarShadow.isHidden = modePinDetail == .off
            
            tblPlaceResult.isHidden = modePinDetail == .on
            btnTapToShowResultTbl.isHidden = modePinDetail == .on
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
            btnLeftWindow.isHidden = mapMode == .selecting
            lblSearchContent.textColor = mapMode == .selecting ? UIColor._898989() : UIColor._182182182()
            
            imgExpbarShadow.isHidden = mapMode != .collection
            imgSchbarShadow.isHidden = mapMode == .collection
            
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
        guard let user_status = FaeCoreData.shared.readByKey("userStatus") as? Int else { return }
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
                if let intro = nickNameInfo["short_intro"].string {
                    Key.shared.introduction = intro
                }
            }
        }
    }
    
    func checkDisplayNameExisitency() {
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
    
    func loadUserSettingsFromCloud() {
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
    
    func isUserLoggedIn() {
        FaeCoreData.shared.readLogInfo()
        if Key.shared.is_Login == false {
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
        timerLoadMessages = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(syncMessagesFromServer), userInfo: nil, repeats: true)
    }
    
    func invalidateAllTimer() {
        timerUserPin?.invalidate()
        timerUserPin = nil
        timerLoadMessages?.invalidate()
        timerLoadMessages = nil
    }
    
    func loadFirstLoginVC() {
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
        removePlacePins({
            placeComp?()
        }, otherThan: self.selectedPlace)
        removeUserPins {
            userComp?()
        }
    }
    
    func removePlacePins(_ completion: (() -> ())? = nil, otherThan pin: FaePinAnnotation? = nil) {
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
    
    func storeRealmColItemsFromServer(colId: Int) {
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
    
    func cancelAllPinLoading() {
        placeAdderQueue.cancelAllOperations()
    }
    
    func initUserDataFromServer() {
        storeRealmCollectionFromServer()
        ContactsViewController.loadFriendsList()
        ContactsViewController.loadReceivedFriendRequests()
        ContactsViewController.loadSentFriendRequests()
    }
    
    @objc func syncMessagesFromServer() {
        //faeChat.getMessageFromServer()
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
                
            } else {
                
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
