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
import Alamofire

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
    var faeMapView: FaeMapView!
    
    var placeClusterManager: CCHMapClusterController!
    private var faePlacePins = [FaePinAnnotation]()
    private var setPlacePins = Set<Int>()
    
    var userClusterManager: CCHMapClusterController!
    private var faeUserPins = [FaePinAnnotation]()
    private var setUserPins = Set<Int>()
    private var timerUserPin: Timer? // timer to renew update user pins
    private var userPinFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "userPinFetchQueue_map"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var timerLoadMessages: Timer?
    private var selfAnView: SelfAnnotationView?
    private var PLACE_ANIMATED = true
    private var placePinFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "placePinFetchQueue_map"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // General
    private var btnBackFromCollection: UIButton!
    
    // Search Bar
    private var uiviewSchbarShadow: UIView!
    private var imgSearchIcon: UIImageView!
    private var imgAddressIcon: UIImageView!
    private var btnLeftWindow: UIButton!
    private var btnCancelSelect: UIButton!
    private var lblSearchContent: UILabel!
    private var btnSearch: UIButton!
    private var btnClearSearchRes: UIButton!
    var btnDropUpMenu: UIButton!
    private var uiviewPinActionDisplay: FMPinActionDisplay! // indicate which action is being pressing to release
    
    // Explore Button
    private var uiviewCollectionbarShadow: UIView!
    private var lblCollectionTitle: UILabel!
    
    // Compass and Locating Self
    var btnZoom: FMZoomButton!
    private var btnLocateSelf: FMLocateSelf!
    
    // Chat Button
    private var btnOpenChat: UIButton!
    private var lblUnreadCount: UILabel! // Unread Messages Label
    
    // Discovery Button
    private var btnDiscovery: UIButton!
    
    // Refresh Hexagon and Menu
    private var btnRefreshIcon: FMRefreshIcon! // Filter Button
    private var uiviewDropUpMenu: FMDropUpMenu! //
    private var sizeFrom: CGFloat = 0 // Pan gesture var
    private var sizeTo: CGFloat = 0 // Pan gesture var
    private var end: CGFloat = 0 // Pan gesture var
    private var percent: Double = 0 // Pan gesture var
    private let floatFilterHeight = 471 * screenHeightFactor + device_offset_bot // Map Filter height
    
    // Selected Place Control
    private var selectedPlaceAnno: PlacePinAnnotationView?
    private var selectedPlace: FaePinAnnotation?
    
    private var boolSelecting = false
    private var firstSelectPlace = true
    
    // User Pin Control
    private let userPinAdderQueue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)
    private var userPinAdderJob: DispatchWorkItem = DispatchWorkItem(block: {})
    private var userPinRequests = [Int: DataRequest]()
    private var rawUserJSONs = [JSON]()
    private var numberOfAreasWithNoUserPin = 48
    private var userFetchesCount = 0 {
        didSet {
            guard userFetchesCount == 24 else { return }
            doneFetchingAreaUserData()
        }
    }
    private var userFetchesCountWhenMapPanning = 0 {
        didSet {
            guard userFetchesCountWhenMapPanning == numberOfAreasWithNoUserPin else { return }
            doneFetchingAreaUserData()
        }
    }
    
    // Place Pin Control
    private var place_debug: Bool = false
    private var isFirstPlacesFetching: Bool = true
    private var isForcedRefresh: Bool = false
    private var isMapWillChange: Bool = false
    private var placeFetchThrottler = Throttler(name: "[placeFetchThrottler]", seconds: 0.5)
    private var placePinRequests = [Int: DataRequest]()
    private var rawPlaceJSONs = [JSON]()
    private var placeFetchesCount = 0 {
        didSet {
            guard placeFetchesCount == 1 else { return }
            doneFetchingAreaPlaceData()
        }
    }
    private var numberOfAreasWithNoPlacePin = 48
    private var placeFetchesCountWhenMapPanning = 0 {
        didSet {
            guard placeFetchesCountWhenMapPanning == numberOfAreasWithNoPlacePin else { return }
            doneFetchingAreaPlaceData()
        }
    }
    private var time_start: DispatchTime!
    private var date_start: Date!
    var point_centers = [CGPoint]()
    var coordinates_place = [CLLocationCoordinate2D]()
    var coordinates_user = [CLLocationCoordinate2D]()
    
    // Results from Search
    private var btnTapToShowResultTbl: FMTableExpandButton!
    private var tblPlaceResult = FMPlacesTable()
    private var placesFromSearch = [PlacePin]()
    private var locationsFromSearch = [LocationPin]()
    private var pinsFromSearch = [FaePinAnnotation]()
    private var strSearchedText: String = ""
    private var searchState: PlaceInfoBarState = .map {
        didSet {
            guard fullyLoaded else { return }
            btnTapToShowResultTbl.alpha = searchState == .multipleSearch ? 1 : 0
            btnTapToShowResultTbl.isHidden = searchState != .multipleSearch
            tblPlaceResult.isHidden = searchState != .multipleSearch
            placeClusterManager.isFullMapRectEnabled = searchState == .multipleSearch
            placeClusterManager.isClusteringDisabled = searchState == .multipleSearch
        }
    }
    private var tempSearchCoordinate: CLLocationCoordinate2D?
    private var tempSearchRadius: Int?
    private var searchRequest: DataRequest?
    
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
    private var startPointAddr: RouteAddress!
    private var destinationAddr: RouteAddress!
    private var addressAnnotations = [AddressAnnotation]()
    private var btnDistIndicator: FMDistIndicator!
    private var uiviewChooseLocs: FMChooseLocs!
    private var routeAddress: RouteAddress!
    private var imgSelectLocIcon: UIImageView!
    private var isRoutingCancelled = false
    private var pinToRoute: FaePinAnnotation!
    private var pinsToRoute = [FaePinAnnotation]()
    private var isLoadingMapCenterCityInfoDisabled: Bool = false
    private var isGeoCoding: Bool = false
    
    // Location Pin Control
    private var selectedLocation: FaePinAnnotation?
    private var selectedLocAnno: LocPinAnnotationView?
    private var uiviewLocationBar: FMLocationInfoBar!
    private var locationPinClusterManager: CCHMapClusterController!
    
    // Guest Mode
    private var uiviewGuestMode: GuestModeView!
    
    // Chat
    private let faeChat = FaeChat()
    private let faePush = FaePush()
    private var intFriendsRequested: Int = 0
    private var unreadNotiToken: NotificationToken? = nil
    
    // Collections Managements
    private var placesFromCollection = [PlacePin]()
    private var locationsFromCollection = [LocationPin]()
    private var pinsFromCollection = [FaePinAnnotation]()
    private var currentCollection: RealmCollection?
    private var isPinsFromCollectionLoading: Bool = false
    private var isCollectionLoadingFailed: Bool = false
    private var isPlaceCollection: Bool = true
    private var desiredCountOfPinsFromCollection = 0
    private var completionCountOfPlacePinsFromCollection = 0 {
        didSet {
            guard fullyLoaded else { return }
            guard !isCollectionLoadingFailed else { return }
            guard desiredCountOfPinsFromCollection > 0 else { return }
            guard desiredCountOfPinsFromCollection == completionCountOfPlacePinsFromCollection else {
                return
            }
            isPinsFromCollectionLoading = false
            jumpToPlaces(searchText: "", places: placesFromCollection)
        }
    }
    
    private var completionCountOfLocationPinsFromCollection = 0 {
        didSet {
            guard fullyLoaded else { return }
            guard !isCollectionLoadingFailed else { return }
            guard desiredCountOfPinsFromCollection > 0 else { return }
            guard desiredCountOfPinsFromCollection == completionCountOfLocationPinsFromCollection else {
                return
            }
            isPinsFromCollectionLoading = false
            showLocations(locations: locationsFromCollection)
        }
    }
    
    var arrCtrlers = [UIViewController]()
    var boolFromMap = true
    private var boolNotiSent = false
    var boolCanUpdateUsers = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    private var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    private let FILTER_ENABLE = true
    private var PLACE_FETCH_ENABLE = true
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
    private var PLACES_RELOADED = true
    
    // Debug Use
    private var lblZoomLevelInfo: FaeLabel!
    private var lblRadiusInfo: FaeLabel!
    
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
        loadTopBar()
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
        initScreenPointCenters()
    }
    
    deinit {
        unreadNotiToken?.invalidate()
        invalidateAllTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMapChat()
        General.shared.renewSelfLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mapFilterAnimationRestart"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadUser&MapInfo"), object: nil)
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
        btnTapToShowResultTbl.isHidden = !(tblPlaceResult.showed && searchState == .multipleSearch)
    }
    
    private var modeLocation: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            uiviewCollectionbarShadow.isHidden = modeLocation == .off
            uiviewSchbarShadow.isHidden = modeLocation != .off
            if modeLocation != .off || Key.shared.is_guest {
                Key.shared.onlineStatus = 5
                lblCollectionTitle.attributedText = nil
                lblCollectionTitle.text = "View Location"
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
                        self.locationPinClusterManager.isForcedRefresh = true
                        self.locationPinClusterManager.manuallyCallRegionDidChange()
                        self.locationPinClusterManager.isForcedRefresh = false
                        self.deselectAllLocAnnos()
                    })
                }
            }
        }
    }
    
    private var modeCollection: FaeMode = .off {
        didSet {
            uiviewCollectionbarShadow.isHidden = modeCollection != .on
            uiviewSchbarShadow.isHidden = modeCollection == .on
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
                if modeCollection != .on && searchState != .multipleSearch {
                    lblSearchContent.text = "Search Fae Map"
                    lblSearchContent.textColor = mapMode == .selecting ? UIColor._898989() : UIColor._182182182()
                }
                btnDistIndicator.lblDistance.text = btnDistIndicator.strDistance
            }
            imgSearchIcon.isHidden = mapMode == .selecting
            btnDistIndicator.isUserInteractionEnabled = mapMode == .selecting
            btnLeftWindow.isHidden = mapMode == .selecting
            
            btnSearch.isHidden = mapMode == .routing || mapMode == .selecting
            Key.shared.onlineStatus = mapMode == .routing || mapMode == .selecting ? 5 : 1
            if mapMode == .routing || mapMode == .selecting || Key.shared.is_guest {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
            }
            
            faeMapView.isDoubleTapOnMKAnnoViewEnabled = mapMode != .routing
            imgSelectLocIcon.isHidden = mapMode != .selecting
        }
    }
    
    private func getUserStatus() {
        guard !Key.shared.is_guest else {
            Key.shared.onlineStatus = 5
            return
        }
        guard let user_status = FaeCoreData.shared.readByKey("userStatus") as? Int else { return }
        Key.shared.onlineStatus = user_status
    }

    private func updateSelfInfo() {
        guard !Key.shared.is_guest else { return }
        DispatchQueue.global(qos: .utility).async {
            let updateNickName = FaeUser()
            updateNickName.getSelfNamecard { [unowned self] (status: Int, message: Any?) in
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
        guard !Key.shared.is_guest else { return }
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
        guard !Key.shared.is_guest else { return }
        FaeUser.shared.getUserSettings { (status, message) in
            guard status / 100 == 2 else { return }
            guard let results = message else { return }
            let resultsJSON = JSON(results)
            Key.shared.emailSubscribed = resultsJSON["email_subscription"].boolValue
            Key.shared.measurementUnits = resultsJSON["measurement_units"].stringValue
            Key.shared.showNameCardOption = resultsJSON["show_name_card_options"].boolValue
            Key.shared.shadowLocationEffect = resultsJSON["shadow_location_system_effect"].stringValue == "" ? "normal" : resultsJSON["shadow_location_system_effect"].stringValue
            Key.shared.otherSettings = resultsJSON["others"].stringValue
        }
    }
    
    private func isUserLoggedIn() {
        guard !Key.shared.is_guest else { return }
        FaeCoreData.shared.readLogInfo()
        if Key.shared.is_Login == false {
            jumpToWelcomeView(animated: false)
        }
    }
    
    private func updateGenderAge() {
        guard !Key.shared.is_guest else { return }
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
        timerUserPin = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(fetchUserPins), userInfo: nil, repeats: true)
        guard !Key.shared.is_guest else { return }
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
        updateMiniAvatar.updateAccountBasicInfo({ [unowned self] (status: Int, _: Any?) in
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
        fetchPlacePins()
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
            fetchPlacePins()
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
    
    private func addUserAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        userClusterManager.isForcedRefresh = forced
        userClusterManager.addAnnotations(annos) {
            if forced {
                self.userClusterManager.manuallyCallRegionDidChange()
                self.userClusterManager.isForcedRefresh = false
            }
            completion?()
        }
    }
    
    private func addPlaceAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        PLACE_INSTANT_SHOWUP = instantly
        placeClusterManager.isForcedRefresh = forced
        placeClusterManager.addAnnotations(annos) {
            self.placeClusterManager.manuallyCallRegionDidChange()
            self.placeClusterManager.isForcedRefresh = false
            self.PLACE_INSTANT_SHOWUP = false
            completion?()
        }
    }
    
    private func removePlaceAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        PLACE_INSTANT_REMOVE = instantly
        placeClusterManager.isForcedRefresh = forced
        placeClusterManager.removeAnnotations(annos) {
            self.placeClusterManager.manuallyCallRegionDidChange()
            self.placeClusterManager.isForcedRefresh = false
            self.PLACE_INSTANT_REMOVE = false
            completion?()
        }
    }
    
    private func addLocationAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        LOC_INSTANT_SHOWUP = instantly
        locationPinClusterManager.isForcedRefresh = forced
        locationPinClusterManager.addAnnotations(annos) {
            self.locationPinClusterManager.manuallyCallRegionDidChange()
            self.locationPinClusterManager.isForcedRefresh = false
            self.LOC_INSTANT_SHOWUP = false
            completion?()
        }
    }
    
    private func removeLocationAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        LOC_INSTANT_REMOVE = instantly
        locationPinClusterManager.isForcedRefresh = forced
        locationPinClusterManager.removeAnnotations(annos) {
            self.locationPinClusterManager.manuallyCallRegionDidChange()
            self.locationPinClusterManager.isForcedRefresh = false
            self.LOC_INSTANT_REMOVE = false
            completion?()
        }
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
    
    // MARK: - RealmCollection Data Fetch
    private func storeRealmCollectionFromServer() {
        let realm = try! Realm()
        var setDeletedCollection = Set(realm.filterMyCollections().map { $0.collection_id })
        FaeCollection.shared.getCollections { [unowned self] (status: Int, message: Any?) in
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
                let collectedPin = CollectedPin(value: ["\(Key.shared.user_id)_\(colId)_\(pin["pin_id"].intValue)", Key.shared.user_id, colId, pin["pin_id"].intValue, pin["added_at"].stringValue])

                try! realm.write {
                    realm.add(collectedPin, update: true)
                    realmCol.pins.append(collectedPin)
                }
            }
        })
    }
    
    private func initUserDataFromServer() {
        guard !Key.shared.is_guest else { return }
        storeRealmCollectionFromServer()
        ContactsViewController.loadFriendsList()
        ContactsViewController.loadReceivedFriendRequests()
        ContactsViewController.loadSentFriendRequests()
    }
    
    @objc private func syncMessagesFromServer() {
        //faeChat.getMessageFromServer()
        //self.faeChat.getMessageFromServer()
        guard !Key.shared.is_guest else { return }
        faePush.getSync { [unowned self] (status, message) in
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
        faeMapView.showsBuildings = true
        if #available(iOS 11.0, *) {
            let scaleView = MKScaleView(mapView: faeMapView)
            scaleView.scaleVisibility = .visible
            scaleView.frame.origin.y = 150 + device_offset_top
            view.addSubview(scaleView)
        } else {
            // Fallback on earlier versions
        }
        
        lblZoomLevelInfo = FaeLabel(CGRect(x: 3, y: 90 + device_offset_top, width: screenWidth, height: 20), .left, .medium, 20, .black)
        lblZoomLevelInfo.backgroundColor = .white
        view.addSubview(lblZoomLevelInfo)
        lblRadiusInfo = FaeLabel(CGRect(x: 3, y: 120 + device_offset_top, width: screenWidth / 2, height: 20), .left, .medium, 20, .black)
        lblRadiusInfo.backgroundColor = .white
        view.addSubview(lblRadiusInfo)
        
        placeClusterManager = CCHMapClusterController(mapView: faeMapView)
        placeClusterManager.delegate = self
        placeClusterManager.cellSize = Double(screenWidth / 5)
        //placeClusterManager.minUniqueLocationsForClustering = 2
        placeClusterManager.clusterer = self
        placeClusterManager.animator = self
        placeClusterManager.marginFactor = 1
        placeClusterManager.isDebuggingEnabled = false
        
        userClusterManager = CCHMapClusterController(mapView: faeMapView)
        userClusterManager.delegate = self
        userClusterManager.cellSize = 100
        userClusterManager.marginFactor = 0.0
        userClusterManager.animator = self
        userClusterManager.clusterer = self
        userClusterManager.forPlacePin = false
        
        locationPinClusterManager = CCHMapClusterController(mapView: faeMapView)
        locationPinClusterManager.delegate = self
        locationPinClusterManager.cellSize = 60
        locationPinClusterManager.animator = self
        locationPinClusterManager.clusterer = self
        locationPinClusterManager.forPlacePin = false
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        prevMapCenter = LocManager.shared.curtLoc.coordinate
    }
    
    @objc private func firstUpdateLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.refreshMap(pins: false, users: true, places: true)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
    }
    
    // MARK: -- Load Map Main Screen Buttons
    private func loadTopBar() {
        uiviewSchbarShadow = UIView(frame: CGRect(x: 8, y: 23 + device_offset_top, width: screenWidth - 16, height: 48))
        uiviewSchbarShadow.layer.zPosition = 500
        view.addSubview(uiviewSchbarShadow)
        addShadow(view: uiviewSchbarShadow, opa: 0.5, offset: CGSize.zero, radius: 3)
        
        let uiviewSchbarSub = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: 48))
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
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-48-[v0(15)]", options: [], views: imgSearchIcon)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-17-[v0(15)]", options: [], views: imgSearchIcon)
        
        imgAddressIcon = UIImageView()
        imgAddressIcon.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        uiviewSchbarShadow.addSubview(imgAddressIcon)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-48-[v0(15)]", options: [], views: imgAddressIcon)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-17-[v0(15)]", options: [], views: imgAddressIcon)
        imgAddressIcon.isHidden = true
        
        lblSearchContent = UILabel()
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textAlignment = .left
        lblSearchContent.lineBreakMode = .byTruncatingTail
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = UIColor._182182182()
        uiviewSchbarShadow.addSubview(lblSearchContent)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-72-[v0]-55-|", options: [], views: lblSearchContent)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-12.5-[v0(25)]", options: [], views: lblSearchContent)
        
        // Open main map search
        btnSearch = UIButton()
        uiviewSchbarShadow.addSubview(btnSearch)
        uiviewSchbarShadow.addConstraintsWithFormat("H:|-72-[v0]-55-|", options: [], views: btnSearch)
        uiviewSchbarShadow.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnSearch)
        btnSearch.addTarget(self, action: #selector(self.actionGotoSearch(_:)), for: .touchUpInside)
        
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
        btnZoom.disableMapViewDidChange = { [weak self] (disabled) in
            guard let `self` = self else { return }
            self.isLoadingMapCenterCityInfoDisabled = disabled
            if !disabled {
                self.mapView(self.faeMapView, regionDidChangeAnimated: true)
            }
        }
        btnZoom.enableClusterManager = { [weak self] (enabled, isForcedRefresh) in
            guard let `self` = self else { return }
            self.placeClusterManager.canUpdate = enabled
            if let shouldRefresh = isForcedRefresh {
                self.placeClusterManager.isForcedRefresh = shouldRefresh
                self.placeClusterManager.manuallyCallRegionDidChange()
                self.placeClusterManager.isForcedRefresh = false
                self.userClusterManager.isForcedRefresh = true
                self.userClusterManager.manuallyCallRegionDidChange()
                self.userClusterManager.isForcedRefresh = false
            }
        }
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
        uiviewCollectionbarShadow = UIView(frame: CGRect(x: 7, y: 23 + device_offset_top, width: screenWidth - 14, height: 48))
        uiviewCollectionbarShadow.layer.zPosition = 500
        uiviewCollectionbarShadow.isHidden = true
        view.addSubview(uiviewCollectionbarShadow)
        addShadow(view: uiviewCollectionbarShadow, opa: 0.5, offset: CGSize.zero, radius: 3)
        
        let uiviewCollectionBarSub = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth - 14, height: 48))
        uiviewCollectionBarSub.layer.cornerRadius = 2
        uiviewCollectionBarSub.backgroundColor = .white
        uiviewCollectionBarSub.clipsToBounds = true
        uiviewCollectionbarShadow.addSubview(uiviewCollectionBarSub)
        
        // Left window on main map to open account system
        btnBackFromCollection = UIButton()
        btnBackFromCollection.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        uiviewCollectionbarShadow.addSubview(btnBackFromCollection)
        btnBackFromCollection.addTarget(self, action: #selector(self.actionCancelShowingCollection(_:)), for: .touchUpInside)
        uiviewCollectionbarShadow.addConstraintsWithFormat("H:|-1-[v0(40.5)]", options: [], views: btnBackFromCollection)
        uiviewCollectionbarShadow.addConstraintsWithFormat("V:|-0-[v0(48)]", options: [], views: btnBackFromCollection)
        btnBackFromCollection.adjustsImageWhenDisabled = false
        
        lblCollectionTitle = UILabel()
        lblCollectionTitle.textAlignment = .center
        lblCollectionTitle.numberOfLines = 1
        lblCollectionTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblCollectionTitle.textColor = UIColor._898989()
        uiviewCollectionbarShadow.addSubview(lblCollectionTitle)
        uiviewCollectionbarShadow.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblCollectionTitle)
        uiviewCollectionbarShadow.addConstraintsWithFormat("V:|-12.5-[v0(25)]", options: [], views: lblCollectionTitle)
    }
    
    private func loadActivityIndicator() {
        activityIndicator = createActivityIndicator(large: true)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.layer.zPosition = 1999
    }
    
    private func setCollectionTitle(type: String) {
        let title_0 = type
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        lblCollectionTitle.attributedText = title_0_attr
    }
}

// MARK: - Actions

extension FaeMapViewController {
    
    @objc private func actionGotoSearch(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide() {
            self.faeMapView.mapGesture(isOn: true)
        }
        uiviewDropUpMenu.hide()
        tempSearchCoordinate = nil
        tempSearchRadius = nil
        let searchVC = MapSearchViewController()
        searchVC.faeMapView = self.faeMapView
        searchVC.delegate = self
        searchVC.previousVC = .map
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
        PLACE_FETCH_ENABLE = true
        
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textColor = UIColor._182182182()
        
        btnClearSearchRes.isHidden = true
        btnLocateSelf.isHidden = false
        btnZoom.isHidden = false

        tblPlaceResult.searchState = .map
        searchState = .map
        tblPlaceResult.hide(animated: false)
        showOrHideTableResultsExpandingIndicator()
        placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        
        faeMapView.mapGesture(isOn: true)
        deselectAllPlaceAnnos()
//        showOrHideRefreshIcon(show: true, animated: true)
        removePlaceAnnotations(with: pinsFromSearch, forced: true, instantly: true) {
            self.pinsFromSearch.removeAll(keepingCapacity: true)
            self.addPlaceAnnotations(with: self.faePlacePins, forced: true, instantly: true) {
                self.mapView(self.faeMapView, regionDidChangeAnimated: false)
            }
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
        guard tblPlaceResult.currentGroupOfPlaces.count > 0 else { return }
        guard tblPlaceResult.canExpandOrShrink() else { return }
        btnZoom.tapToSmallMode()
        if sender.tag == 0 {
            sender.tag = 1
            tblPlaceResult.expand {
                self.btnTapToShowResultTbl.center.y = self.btnTapToShowResultTbl.after
            }
            btnZoom.isHidden = true
            btnLocateSelf.isHidden = true
            btnTapToShowResultTbl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            uiviewDropUpMenu.hide()
        } else {
            sender.tag = 0
            tblPlaceResult.shrink {
                self.btnTapToShowResultTbl.center.y = self.btnTapToShowResultTbl.before
            }
            btnZoom.isHidden = false
            btnLocateSelf.isHidden = false
            btnTapToShowResultTbl.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func actionChatWindowShow(_ sender: UIButton) {
        guard !Key.shared.is_guest else {
            loadGuestMode()
            return
        }
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide() {
            self.faeMapView.mapGesture(isOn: true)
        }
        UINavigationBar.appearance().shadowImage = imgNavBarDefaultShadow
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
    
    @objc private func actionCancelShowingCollection(_ sender: UIButton) {
        guard !isPinsFromCollectionLoading else {
            joshprint("wanna cancel")
            return }
        btnZoom.tapToSmallMode()
        uiviewDropUpMenu.hide()
        uiviewLocationBar.hide()
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
        currentCollection = nil
        modeCollection = .off
        if searchState == .multipleSearch {
            removeLocationAnnotations(with: pinsFromCollection, forced: true, instantly: false)
            removePlaceAnnotations(with: pinsFromCollection, forced: true, instantly: false) {
                self.pinsFromCollection.removeAll()
                self.jumpToPlaces(searchText: self.strSearchedText, places: self.placesFromSearch)
            }
        } else {
            PLACE_FETCH_ENABLE = true
            placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
            tblPlaceResult.hide()
            showOrHideTableResultsExpandingIndicator()
            deselectAllPlaceAnnos()
            deselectAllLocAnnos()
            removeLocationAnnotations(with: pinsFromCollection, forced: true, instantly: false)
            removePlaceAnnotations(with: pinsFromCollection, forced: true, instantly: false) {
                self.addPlaceAnnotations(with: self.faePlacePins, forced: true, instantly: false)
            }
            userClusterManager.addAnnotations(faeUserPins, withCompletionHandler: nil)
        }
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
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willReuse mapClusterAnnotation: CCHMapClusterAnnotation!, fullAnnotationSet annotations: Set<AnyHashable>!, findSelectedPin found: Bool) {
        switch mapClusterController {
        case placeClusterManager:
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? PlacePinAnnotationView {
                var pinFound = false
                if found {
                    for annotation in annotations {
                        guard let pin = annotation as? FaePinAnnotation else { continue }
                        guard let sPlace = selectedPlace else { continue }
                        if faeBeta.coordinateEqual(pin.coordinate, sPlace.coordinate) {
                            pinFound = true
                            let icon = UIImage(named: "place_map_\(pin.category_icon_id)s") ?? #imageLiteral(resourceName: "place_map_48s")
                            anView.assignImage(icon)
                        }
                    }
                    if !pinFound {
                        if let representative = mapClusterAnnotation.representative as? FaePinAnnotation {
                            anView.assignImage(representative.icon)
                        } else if let firstAnn = mapClusterAnnotation.annotations.first as? FaePinAnnotation {
                            anView.assignImage(firstAnn.icon)
                        }
                    }
                } else {
                    if let firstAnn = mapClusterAnnotation.annotations.first as? FaePinAnnotation {
                        anView.assignImage(firstAnn.icon)
                    }
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
                if firstAnn.isSelected {
                    anView.assignImage(#imageLiteral(resourceName: "icon_destination"))
                } else {
                    anView.assignImage(firstAnn.icon)
                }
            }
        }
        if selectedPlaceAnno != nil {
            selectedPlaceAnno?.superview?.bringSubview(toFront: selectedPlaceAnno!)
            selectedPlaceAnno?.layer.zPosition = 199
        }
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, didAddAnnotationViews annotationViews: [Any]!) {
        for annotationView in annotationViews {
            if let anView = annotationView as? PlacePinAnnotationView {
                anView.superview?.sendSubview(toBack: anView)
                if PLACE_INSTANT_SHOWUP || searchState == .multipleSearch || place_debug { // immediatelly show up
                    anView.imgIcon.frame = CGRect(x: -8, y: -5, width: 56, height: 56)
                    anView.alpha = 1
                } else {
                    anView.alpha = 0
                    anView.imgIcon.frame = CGRect(x: 20, y: 46, width: 0, height: 0)
                    let delay: Double = Double.random(min: 0, max: 0.5)// Delay 0-1 seconds, randomly
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
        
        if (mapClusterController == placeClusterManager && PLACE_INSTANT_REMOVE) || (mapClusterController == locationPinClusterManager && LOC_INSTANT_REMOVE) || searchState == .multipleSearch { // immediatelly remove
            for annotation in annotations {
                if let anno = annotation as? MKAnnotation {
                    if let anView = self.faeMapView.view(for: anno) {
                        anView.alpha = 0
                    }
                }
            }
            if completionHandler != nil { completionHandler() }
        } else {
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
            guard !Key.shared.is_guest else {
                return
            }
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
            if Key.shared.onlineStatus == 5 || Key.shared.is_guest {
                anView.invisibleOn()
            }
            return anView
        } else if annotation is CCHMapClusterAnnotation {
            guard let clusterAnn = annotation as? CCHMapClusterAnnotation else { return nil }
            guard var firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == .place {
                if let sPlace = selectedPlace {
                    if faeBeta.coordinateEqual(clusterAnn.coordinate, sPlace.coordinate) {
                        firstAnn = sPlace
                    }
                }
                clusterAnn.representative = firstAnn
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        guard fullyLoaded else { return }
        joshprint("[regionWillChangeAnimated]")
        isMapWillChange = true
        cancelPlacePinsFetch()
        placeFetchThrottler.cancelCurrentJob()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard fullyLoaded else { return }
        joshprint("[regionDidChangeAnimated]")
        isMapWillChange = false
        let level = getZoomLevel(longitudeCenter: mapView.region.center.longitude, longitudeDelta: mapView.region.span.longitudeDelta, width: mapView.bounds.size.width)
        var width = "Zoom Level: \(Double(round(1000*level)/1000))".width(withConstrainedWidth: 20, font: FaeFont(fontType: .medium, size: 20))
        lblZoomLevelInfo.text = "Zoom Level: \(Double(round(1000*level)/1000))"
        lblZoomLevelInfo.frame.size.width = width
        let radius = cameraDistance(mapView: mapView)
        width = "Radius: \(radius/2)".width(withConstrainedWidth: 20, font: FaeFont(fontType: .medium, size: 20))
        lblRadiusInfo.text = "Radius: \(radius/2)"
        lblRadiusInfo.frame.size.width = width
        if level <= 5 {
            PLACE_FETCH_ENABLE = false
            let pinsToAdd = faePlacePins + pinsFromSearch + pinsFromCollection
            removePlaceAnnotations(with: pinsToAdd, forced: true, instantly: true) {
                self.PLACES_RELOADED = false
            }
        } else {
            if PLACES_RELOADED == false {
                PLACES_RELOADED = true
                PLACE_FETCH_ENABLE = true
                let pinsToAdd = faePlacePins + pinsFromSearch + pinsFromCollection
                addPlaceAnnotations(with: pinsToAdd, forced: true, instantly: false) {
                    
                }
            }
        }
        Key.shared.lastChosenLoc = mapView.centerCoordinate
        
        if AUTO_REFRESH {
            if !isLoadingMapCenterCityInfoDisabled {
                fetchAreaPlaceDataWhenRegionDidChange()
            }
        }
        
        if searchState == .multipleSearch {
            if tblPlaceResult.altitude == 0 {
                tblPlaceResult.altitude = mapView.camera.altitude
            }
            tempSearchCoordinate = mapView.centerCoordinate
            tempSearchRadius = cameraDistance(mapView: mapView)
            print("[regionDidChangeAnimated] temp coordinate & radius is set")
        }
        
        reloadPlaceTableAnnotations()
        
        if mapMode == .selecting {
            guard !isGeoCoding else { return }
            guard !isLoadingMapCenterCityInfoDisabled else { return }
            isGeoCoding = true
            btnDistIndicator.indicatorStartAnimating(isOn: true)
            let mapCenterCoordinate = mapView.centerCoordinate
            let location = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                General.shared.getAddress(location: location) { [unowned self] (status, address) in
                    guard status != 400 else {
                        DispatchQueue.main.async {
                            self.lblSearchContent.text = "Querying for location too fast!"
                            self.lblSearchContent.textColor = UIColor._898989()
                        }
                        self.btnDistIndicator.indicatorStartAnimating(isOn: false)
                        self.isGeoCoding = false
                        return
                    }
                    guard let addr = address as? String else {
                        self.btnDistIndicator.indicatorStartAnimating(isOn: false)
                        self.isGeoCoding = false
                        return
                    }
                    DispatchQueue.main.async {
                        self.lblSearchContent.text = addr
                        self.lblSearchContent.textColor = UIColor._898989()
                        self.routeAddress = RouteAddress(name: addr, coordinate: location.coordinate)
                        self.btnDistIndicator.indicatorStartAnimating(isOn: false)
                        self.isGeoCoding = false
                    }
                }
            }
        }
    }
    
    func reloadPlaceTableAnnotations() {
        if tblPlaceResult.tag > 0 && PLACE_FETCH_ENABLE { tblPlaceResult.visibleAnnotations = visiblePlaces(full: true) }
        if selectedPlaceAnno != nil {
            if modeCollection == .on {
                
            } else {
                if searchState == .map {
                    tblPlaceResult.loadingData(current: tblPlaceResult.curtAnnotation)
                } else if searchState == .multipleSearch {
                    
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
        if let idx = selectedPlace?.category_icon_id {
            selectedPlace?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
            selectedPlace?.isSelected = false
            guard let img = selectedPlace?.icon else { return }
            selectedPlaceAnno?.assignImage(img)
            selectedPlaceAnno?.hideButtons()
            selectedPlaceAnno?.superview?.sendSubview(toBack: selectedPlaceAnno!)
            selectedPlaceAnno?.zPos = 7
            selectedPlaceAnno?.optionsReady = false
            selectedPlaceAnno?.optionsOpened = false
            selectedPlaceAnno?.isSelected_fae = false
            selectedPlaceAnno = nil
            if searchState == .map {
                selectedPlace = nil
            }
        }
    }
    
    private func deselectAllLocAnnos() {
        uiviewPinActionDisplay.hide()
        uiviewSavedList.arrListSavedThisPin.removeAll()
        uiviewAfterAdded.reset()
        boolCanOpenPin = true
        selectedLocation?.isSelected = false
        selectedLocAnno?.assignImage(#imageLiteral(resourceName: "icon_startpoint"))
        selectedLocAnno?.hideButtons()
        selectedLocAnno?.zPos = 8.0
        selectedLocAnno?.optionsReady = false
        selectedLocAnno?.optionsOpened = false
        selectedLocAnno = nil
        selectedLocation = nil
        // get back to previous state if user has done a search
        if searchState == .multipleSearch {
            tblPlaceResult.show()
            showOrHideTableResultsExpandingIndicator(show: true, animated: true)
        }
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
                self.fetchPlacePins()
                self.fetchUserPins()
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
                self.btnRefreshIcon.frame = CGRect(x: screenWidth / 2, y: screenHeight - 25 - device_offset_bot, width: 0, height: 0)
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
            General.shared.renewSelfLocation()
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
    
    func jumpToSettings() {
        let vcSettings = SettingsViewController()
        navigationController?.pushViewController(vcSettings, animated: true)
    }
    
    func jumpToLogin() {
        Key.shared.navOpenMode = .welcomeFirst
        let viewCtrlers = [WelcomeViewController(), LogInViewController()]
        self.navigationController?.setViewControllers(viewCtrlers, animated: true)
    }
    
    func jumpToSignup() {
        Key.shared.navOpenMode = .welcomeFirst
        let viewCtrlers = [WelcomeViewController(), RegisterNameViewController()]
        self.navigationController?.setViewControllers(viewCtrlers, animated: true)
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
        updateUnreadChatIndicator()
    }
    
    // ButtonFinishClickedDelegate
    func jumpToEnableNotification() {
        print("jumpToEnableNotification")
        let notificationType = UIApplication.shared.currentUserNotificationSettings
        if notificationType?.types == UIUserNotificationType() {
            let vc = EnableNotificationViewController()
            present(vc, animated: true)
        }
    }
    // ButtonFinishClickedDelegate End
}

// MARK: - Drop Up Menu

extension FaeMapViewController: MapFilterMenuDelegate {
    
    private func loadMapFilter() {
        guard FILTER_ENABLE else { return }
        btnRefreshIcon = FMRefreshIcon()
        btnRefreshIcon.addTarget(self, action: #selector(self.actionRefreshIcon(_:)), for: .touchUpInside)
        btnRefreshIcon.layer.zPosition = 601
        view.addSubview(btnRefreshIcon)
        view.bringSubview(toFront: btnRefreshIcon)
        
        // new menu design
        uiviewDropUpMenu = FMDropUpMenu()
        uiviewDropUpMenu.layer.zPosition = 601
        uiviewDropUpMenu.delegate = self
        uiviewDropUpMenu.collectionBtnBlock = { [unowned self] in
            self.loadGuestMode()
        }
        view.addSubview(uiviewDropUpMenu)
        let panGesture_menu = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
        panGesture_menu.require(toFail: uiviewDropUpMenu.swipeGes)
        uiviewDropUpMenu.addGestureRecognizer(panGesture_menu)
    }
    
    @objc private func actionRefreshIcon(_ sender: UIButton) {
        if searchState == .map {
            cancelPlacePinsFetch()
            guard searchState == .map else { return }
            if btnRefreshIcon.isSpinning {
                btnRefreshIcon.stopIconSpin()
                boolCanUpdatePlaces = true
                boolCanUpdateUsers = true
                return
            }
            guard boolCanUpdatePlaces && boolCanUpdateUsers else { return }
            btnRefreshIcon.startIconSpin()
            removePlaceUserPins({
                self.faePlacePins.removeAll(keepingCapacity: true)
                self.setPlacePins.removeAll(keepingCapacity: true)
                if self.selectedPlace != nil {
                    self.faePlacePins.append(self.selectedPlace!)
                    self.setPlacePins.insert(self.selectedPlace!.id)
                }
                self.isForcedRefresh = true
                self.fetchPlacePins()
            }) {
                self.faeUserPins.removeAll(keepingCapacity: true)
                self.setUserPins.removeAll(keepingCapacity: true)
                self.updateTimerForUserPin()
            }
        } else if searchState == .multipleSearch {
            btnRefreshIcon.isUserInteractionEnabled = false
            btnRefreshIcon.startIconSpin()
            guard let searchText = lblSearchContent.text else {
                self.stopIconSpin(delay: 0)
                btnRefreshIcon.isUserInteractionEnabled = true
                return
            }
            Key.shared.radius_map = Int(faeMapView.region.span.latitudeDelta * 111045)
            self.isForcedRefresh = true
            continueSearching(searchText: searchText, zoomToFit: false)
        }
    }
    
    @objc private func actionShowMapActionsMenu(_ sender: UIButton) {
        guard !Key.shared.is_guest else {
            loadGuestMode()
            return
        }
        if sender.isSelected {
            sender.isSelected = false
            uiviewDropUpMenu.hide()
        } else {
            sender.isSelected = true
            uiviewDropUpMenu.show()
            if btnTapToShowResultTbl.tag == 1 {
                btnTapToShowResultTbl.sendActions(for: .touchUpInside)
            }
        }
    }
    
    private func showOrHideRefreshIcon(show: Bool, animated: Bool = true) {
        if animated {
            if show {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnRefreshIcon.center.y = screenHeight - 25 - device_offset_bot
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnRefreshIcon.frame.origin.y = screenHeight + 10
                }, completion: nil)
            }
        } else {
            if show {
                self.btnRefreshIcon.center.y = screenHeight - 25 - device_offset_bot
            } else {
                self.btnRefreshIcon.frame.origin.y = screenHeight + 10
            }
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
    func showPinsFromCollection(type: String, savedPinIds: [Int], colInfo: RealmCollection) {
        guard !isPinsFromCollectionLoading else {
            joshprint("too fast, not yet")
            return
        }
        if let collection = currentCollection {
            if collection.collection_id == colInfo.collection_id && collection.type == colInfo.type {
                joshprint("same collection")
                return
            }
        }
        guard savedPinIds.count > 0 else {
            showAlert(title: "There is no pin in this collection!", message: "", viewCtrler: self)
            return
        }
        currentCollection = colInfo
        if colInfo.type == "location" {
            isPlaceCollection = false
        }
        modeCollection = .on
        isPinsFromCollectionLoading = true
        PLACE_FETCH_ENABLE = false
        cancelPlacePinsFetch()
        setCollectionTitle(type: colInfo.name)
        animateMainItems(show: true, animated: false)
        desiredCountOfPinsFromCollection = savedPinIds.count
        completionCountOfPlacePinsFromCollection = 0
        completionCountOfLocationPinsFromCollection = 0
        func getPinsByIds() {
            self.pinsFromCollection.removeAll()
            self.placesFromCollection.removeAll()
            self.locationsFromCollection.removeAll()
            for id in savedPinIds {
                FaeMap.shared.getPin(type: type, pinId: String(id), completion: { [unowned self] (status, message) in
                    guard status / 100 == 2 else {
                        self.isPinsFromCollectionLoading = false
                        self.isCollectionLoadingFailed = true
                        return
                    }
                    guard message != nil else {
                        self.isPinsFromCollectionLoading = false
                        self.isCollectionLoadingFailed = true
                        return
                    }
                    let resultJson = JSON(message!)
                    if type == "place" {
                        let pinData = PlacePin(json: resultJson)
                        self.placesFromCollection.append(pinData)
                        self.completionCountOfPlacePinsFromCollection += 1
                    } else if type == "location" {
                        let pinData = LocationPin(json: resultJson)
                        self.locationsFromCollection.append(pinData)
                        self.completionCountOfLocationPinsFromCollection += 1
                        //let pin = FaePinAnnotation(type: FaePinType(rawValue: type)!, cluster: self.locationPinClusterManager, data: pinData as AnyObject)
                        //self.pinsFromCollection.append(pin)
                    }
                })
            }
        }
        
        switch type {
        case "place":
            removeLocationAnnotations(with: pinsFromCollection, forced: true, instantly: false)
            removePlaceAnnotations(with: pinsFromCollection, forced: true, instantly: false) {
                self.removePlaceAnnotations(with: self.faePlacePins, forced: true, instantly: false)
                self.removePlaceAnnotations(with: self.pinsFromCollection, forced: true, instantly: false, {
                    getPinsByIds()
                })
            }
        case "location":
            tblPlaceResult.hide()
            showOrHideTableResultsExpandingIndicator(show: false, animated: true)
            removePlaceAnnotations(with: pinsFromCollection, forced: true, instantly: false)
            removeLocationAnnotations(with: pinsFromCollection, forced: true, instantly: false) {
                self.removePlaceAnnotations(with: self.faePlacePins, forced: true, instantly: false)
                self.removePlaceAnnotations(with: self.pinsFromCollection, forced: true, instantly: false, {
                    getPinsByIds()
                })
            }
        default:
            break
        }
        
        for user in faeUserPins {
            user.isValid = false
        }
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
    }
    
    func animateMainScreenButtons(hide: Bool, animated: Bool) {
        guard searchState == .map else { return }
        if hide {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight + 10
                    self.btnLocateSelf.frame.origin.y = screenHeight + 10
                    self.btnOpenChat.frame.origin.y = screenHeight + 10
                    self.btnDiscovery.frame.origin.y = screenHeight + 10
                    self.btnRefreshIcon.frame.origin.y = screenHeight + 10
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight + 10
                self.btnLocateSelf.frame.origin.y = screenHeight + 10
                self.btnOpenChat.frame.origin.y = screenHeight + 10
                self.btnDiscovery.frame.origin.y = screenHeight + 10
                self.btnRefreshIcon.frame.origin.y = screenHeight + 10
            }
            faeMapView.compassOffset = 134
            faeMapView.layoutSubviews()
        } else {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnRefreshIcon.center.y = screenHeight - 25 - device_offset_bot
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnRefreshIcon.center.y = screenHeight - 25 - device_offset_bot
            }
            faeMapView.compassOffset = 215
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
        guard !Key.shared.is_guest else {
            loadGuestMode()
            return
        }
        let addFriendVC = AddFriendFromNameCardViewController()
        addFriendVC.delegate = uiviewNameCard
        addFriendVC.userId = userId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }
    
    func reportUser(id: Int) {
        guard !Key.shared.is_guest else {
            loadGuestMode()
            return
        }
        let reportPinVC = ReportViewController()
        reportPinVC.reportType = 0
        present(reportPinVC, animated: true, completion: nil)
    }
    
    func openFaeUsrInfo() {
        guard !Key.shared.is_guest else {
            loadGuestMode()
            return
        }
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = uiviewNameCard.userId
        uiviewNameCard.hide() {
            self.faeMapView.mapGesture(isOn: true)
        }
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    func chatUser(id: Int) {
        guard !Key.shared.is_guest else {
            loadGuestMode()
            return
        }
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
    
    // MapSearchDelegate
    
    func continueSearching(searchText: String, zoomToFit: Bool) {
        PLACE_FETCH_ENABLE = false
        cancelPlacePinsFetch()
        updateUI(searchText: searchText)
        deselectAllPlaceAnnos()
        deselectAllLocAnnos()
        //showOrHideRefreshIcon(show: false, animated: false)
        tblPlaceResult.changeState(isLoading: true, isNoResult: nil)
        let pinsToRemove = faePlacePins + pinsFromSearch + pinsFromCollection
        removePlaceAnnotations(with: pinsToRemove, forced: true, instantly: false) { [unowned self] in
            self.btnRefreshIcon.isUserInteractionEnabled = true
            self.searchState = .multipleSearch
            // search and show results
            var locationToSearch = self.faeMapView.centerCoordinate
            var radiusToSearch = Key.shared.radius_map
            if let locToSearch = LocManager.shared.locToSearch_map {
                locationToSearch = locToSearch
            }
            if let locToSearch = self.tempSearchCoordinate {
                locationToSearch = locToSearch
            } else {
                print("[continueSearching] temp coordinate is nil")
            }
            if let rToSearch = self.tempSearchRadius {
                radiusToSearch = rToSearch
            }
            let searchAgent = FaeSearch()
            searchAgent.whereKey("content", value: searchText)
            searchAgent.whereKey("source", value: Key.shared.searchSource_map)
            searchAgent.whereKey("type", value: "place")
            searchAgent.whereKey("size", value: "20")
            searchAgent.whereKey("radius", value: "\(radiusToSearch)")
            searchAgent.whereKey("offset", value: "0")
            searchAgent.whereKey("sort", value: [["_score": "desc"], ["geo_location": "asc"]])
            searchAgent.whereKey("location", value: ["latitude": locationToSearch.latitude,
                                                     "longitude": locationToSearch.longitude])
            self.searchRequest?.cancel()
            self.searchRequest = searchAgent.search { [unowned self] (status: Int, message: Any?) in
                joshprint("map searched places fetched")
                guard status / 100 == 2 else {
                    if status == -999 { // cancelled
                        self.tblPlaceResult.changeState(isLoading: true, isNoResult: nil)
                    } else {
                        self.tblPlaceResult.changeState(isLoading: false, isNoResult: true)
                    }
                    return
                }
                guard message != nil else {
                    self.tblPlaceResult.changeState(isLoading: true, isNoResult: nil)
                    return
                }
                let placeInfoJSON = JSON(message!)
                guard let placeInfoJsonArray = placeInfoJSON.array else {
                    self.tblPlaceResult.changeState(isLoading: false, isNoResult: true)
                    return
                }
                let searchedPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
                guard searchedPlaces.count > 0 else {
                    self.tblPlaceResult.changeState(isLoading: false, isNoResult: true)
                    return
                }
                self.tblPlaceResult.dataOffset = searchedPlaces.count
                self.tblPlaceResult.currentGroupOfPlaces = self.tblPlaceResult.updatePlacesArray(places: searchedPlaces)
                self.tblPlaceResult.loading(current: searchedPlaces[0])
                self.pinsFromSearch = self.tblPlaceResult.currentGroupOfPlaces.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0) }
                self.placeClusterManager.maxZoomLevelForClustering = 0
                self.addPlaceAnnotations(with: self.pinsFromSearch, forced: self.isForcedRefresh, instantly: true, {
                    self.isForcedRefresh = false
                    if zoomToFit {
                        if let first = searchedPlaces.first {
                            self.goTo(annotation: nil, place: first, animated: true)
                        }
                    }
                })
                if zoomToFit {
                    faeBeta.zoomToFitAllPlaces(mapView: self.faeMapView,
                                               places: self.tblPlaceResult.currentGroupOfPlaces,
                                               edgePadding: UIEdgeInsetsMake(240, 40, 100, 40))
                }
                self.tblPlaceResult.changeState(isLoading: false, isNoResult: false)
                self.stopIconSpin(delay: 0)
            }
        }
    }
    
    func jumpToPlaces(searchText: String, places: [PlacePin]) {
        PLACE_FETCH_ENABLE = false
        cancelPlacePinsFetch()
        var isNumbered = true
        if modeCollection == .on {
            placesFromCollection = places
            isNumbered = false
        } else {
            strSearchedText = searchText
            updateUI(searchText: searchText)
            placesFromSearch = places
            searchState = .multipleSearch
        }
        deselectAllPlaceAnnos()
        deselectAllLocAnnos()
        //showOrHideRefreshIcon(show: false, animated: false)
        if let first = places.first {
            tblPlaceResult.dataOffset = places.count
            tblPlaceResult.changeState(isLoading: false, isNoResult: false)
            tblPlaceResult.currentGroupOfPlaces = tblPlaceResult.updatePlacesArray(places: places, numbered: isNumbered)
            tblPlaceResult.loading(current: places[0])
            let pinsToAdd = tblPlaceResult.currentGroupOfPlaces.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0) }
            let pinsToRemove = faePlacePins + pinsFromSearch + pinsFromCollection
            removePlaceAnnotations(with: pinsToRemove, forced: true, instantly: true) {
                if self.modeCollection == .on {
                    self.pinsFromCollection = pinsToAdd
                } else {
                    self.pinsFromSearch = pinsToAdd
                }
                self.addPlaceAnnotations(with: pinsToAdd, forced: true, instantly: true, {
                    self.showOrHideTableResultsExpandingIndicator(show: true, animated: true)
                    self.goTo(annotation: nil, place: first, animated: true)
                })
                faeBeta.zoomToFitAllPlaces(mapView: self.faeMapView,
                                           places: self.tblPlaceResult.currentGroupOfPlaces,
                                           edgePadding: UIEdgeInsetsMake(240, 40, 100, 40))
            }
            removeUserPins()
            placeClusterManager.isClusteringDisabled = true
        } else {
            searchState = .map
            tblPlaceResult.changeState(isLoading: false, isNoResult: true)
            showOrHideTableResultsExpandingIndicator()
            placeClusterManager.isClusteringDisabled = false
        }
    }
    
    func showLocations(locations: [LocationPin]) {
        guard let _ = locations.first else { return }
        PLACE_FETCH_ENABLE = false
        cancelPlacePinsFetch()
        locationsFromCollection = locations
        deselectAllPlaceAnnos()
        deselectAllLocAnnos()
        //showOrHideRefreshIcon(show: false, animated: false)
        let pinsToAdd = locations.map { FaePinAnnotation(type: .location, cluster: self.locationPinClusterManager, data: $0) }
        pinsFromCollection = pinsToAdd
        removePlaceUserPins({
            self.addLocationAnnotations(with: pinsToAdd, forced: true, instantly: false)
            faeBeta.zoomToFitAllLocations(mapView: self.faeMapView,
                                          locations: locations,
                                          edgePadding: UIEdgeInsetsMake(240, 40, 100, 40))
        }, nil)
        locationPinClusterManager.maxZoomLevelForClustering = 0
    }
    
    func selectLocation(location: CLLocation) {
        createLocPin(location)
        let camera = faeMapView.camera
        camera.centerCoordinate = location.coordinate
        camera.altitude = 15000
        faeMapView.setCamera(camera, animated: false)
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
    func reloadPlacesOnMap(places: [PlacePin], animated: Bool) {
        //self.placeClusterManager.marginFactor = 10000
        let camera = faeMapView.camera
        camera.altitude = tblPlaceResult.altitude
        faeMapView.setCamera(camera, animated: false)
        reloadPlacePinsOnMap(places: places) {
            self.goTo(annotation: nil, place: places[0], animated: animated)
        }
    }
    
    private func loadPlaceDetail() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapPlaceBar))
        //tblPlaceResult.addGestureRecognizer(tapGesture)
        tblPlaceResult.addGestureToImgBack_1(tapGesture)
        
        tblPlaceResult.tblDelegate = self
        tblPlaceResult.barDelegate = self
        tblPlaceResult.currentVC = .map
        view.addSubview(tblPlaceResult)
        tblPlaceResult.reloadVisibleAnnotations = { [unowned self] in
            self.reloadPlaceTableAnnotations()
        }
        
        btnTapToShowResultTbl = FMTableExpandButton()
        btnTapToShowResultTbl.setImage(#imageLiteral(resourceName: "tapToShowResultTbl"), for: .normal)
        btnTapToShowResultTbl.frame.size = CGSize(width: 58, height: 30)
        btnTapToShowResultTbl.center.x = screenWidth / 2
        btnTapToShowResultTbl.center.y = btnTapToShowResultTbl.before
        view.addSubview(btnTapToShowResultTbl)
        btnTapToShowResultTbl.alpha = 0
        btnTapToShowResultTbl.addTarget(self, action: #selector(self.actionShowResultTbl(_:)), for: .touchUpInside)
    }
    
    private func showOrHideTableResultsExpandingIndicator(show: Bool = false, animated: Bool = false) {
        if animated {
            if show {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.btnTapToShowResultTbl.alpha = 1
                }, completion: nil)
            } else {
                btnTapToShowResultTbl.tag = 1
                btnTapToShowResultTbl.sendActions(for: .touchUpInside)
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.btnTapToShowResultTbl.alpha = 0
                }, completion: nil)
            }
        } else {
            if show {
                btnTapToShowResultTbl.alpha = 1
            } else {
                btnTapToShowResultTbl.alpha = 0
                btnTapToShowResultTbl.tag = 1
                btnTapToShowResultTbl.sendActions(for: .touchUpInside)
            }
        }
    }
    
    @objc private func handleTapPlaceBar() {
        placePinAction(action: .detail, mode: .place)
    }
    
    // PlaceViewDelegate
    func goTo(annotation: CCHMapClusterAnnotation? = nil, place: PlacePin? = nil, animated: Bool = true) {
        func findAnnotation() {
            if let placeData = place {
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
                } else {
                    let camera = faeMapView.camera
                    camera.centerCoordinate = placeData.coordinate
                    faeMapView.setCamera(camera, animated: false)
                }
                if desiredAnno != nil {
                    //joshprint("[goto] anno found")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.faeMapView.selectAnnotation(desiredAnno, animated: false)
                    }
                } else {
                    //joshprint("![goto] anno not found")
                }
            }
        }
        
        deselectAllPlaceAnnos()
        if let anno = annotation {
            searchState = .map
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
            reloadPlacePinsOnMap(places: tblPlaceResult.currentGroupOfPlaces) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    findAnnotation()
                })
            }
        } else if tblPlaceResult.goingToPrevGroup {
            tblPlaceResult.configureCurrentPlaces(goingNext: false)
            reloadPlacePinsOnMap(places: tblPlaceResult.currentGroupOfPlaces) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    findAnnotation()
                })
            }
        } else {
            findAnnotation()
            if let placePin = place { // 必须放在最末尾
                tblPlaceResult.loading(current: placePin, isSwitchingPage: !tblPlaceResult.isShrinked)
            }
        }
    }
}

// MARK: - Unread Chat Ctrl

extension FaeMapViewController {
    
    private func reloadMapChat() {
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
        unreadNotiToken = resultRealmRecents.observe { [unowned self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.setupUnreadNum(resultRealmRecents)
            case .update:
                self.setupUnreadNum(resultRealmRecents)
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
        fetchUserPins()
        timerUserPin?.invalidate()
        timerUserPin = nil
        timerUserPin = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.fetchUserPins), userInfo: nil, repeats: true)
    }
    
    @objc private func fetchUserPins() {
        guard !HIDE_AVATARS else { return }
        guard boolCanUpdateUsers else { return }
//        let coorDistance = cameraDiagonalDistance(mapView: faeMapView)
        let coorDistance = Int(faeMapView.region.span.latitudeDelta * 222090)
        boolCanUpdateUsers = false
        General.shared.renewSelfLocation()
        let locToFetch = faeMapView.centerCoordinate
        let userAgent = FaeMap()
        userAgent.whereKey("geo_latitude", value: "\(locToFetch.latitude)")
        userAgent.whereKey("geo_longitude", value: "\(locToFetch.longitude)")
        userAgent.whereKey("radius", value: "\(coorDistance)")
        userAgent.whereKey("type", value: "user")
        userAgent.whereKey("max_count ", value: "100")
        userAgent.whereKey("user_updated_in", value: "180")
        userAgent.getMapPins { [unowned self] (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                joshprint("DEBUG: getMapUserInfo status/100 != 2")
                self.boolCanUpdateUsers = true
                return
            }
            let mapUserJSON = JSON(message!)
            guard let mapUserJsonArray = mapUserJSON.array else {
                joshprint("[getMapUserInfo] fail to parse pin comments")
                self.boolCanUpdateUsers = true
                return
            }
            guard mapUserJsonArray.count > 0 else {
                self.boolCanUpdateUsers = true
                return
            }
            /*
            self.userPinFetchQueue.cancelAllOperations()
            let fetcher = UserPinFetcher(cluster: self.userClusterManager, arrJSON: mapUserJsonArray, idSet: self.setUserPins, originals: self.faeUserPins)
            fetcher.completionBlock = {
                DispatchQueue.main.async { [unowned self] in
                    if fetcher.isCancelled {
                        return
                    }
                    guard self.modeCollection == .off else { return }
                    guard self.searchState == .map else { return }
                    
                    self.addUserAnnotations(with: fetcher.userPins, forced: false, instantly: false, {
                        self.setUserPins = self.setUserPins.union(Set(fetcher.ids))
                        self.faeUserPins += fetcher.userPins
                    })
                    
                    for user in fetcher.userPins {
                        user.isValid = true
                    }
                }
            }
            self.userPinFetchQueue.addOperation(fetcher)
            self.boolCanUpdateUsers = true
            */
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
    
    func fetchAreaUserDataWhenRegionDidChange() {
        date_start = Date()
        if !HIDE_AVATARS {
            userFetchesCountWhenMapPanning = 0
            numberOfAreasWithNoUserPin = 0
            rawUserJSONs.removeAll()
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now()) {
                for i in 0...23 {
                    self.fetchUserDataInCertainMapRect(number: i)
                }
            }
        }
    }
    
    func startFetchingAreaUserData() {
        guard !HIDE_AVATARS else {
            return
        }
        guard boolCanUpdateUsers else {
            return
        }
        boolCanUpdateUsers = false
        userFetchesCount = 0
        General.shared.renewSelfLocation()
        rawUserJSONs.removeAll()
        coordinates_user.removeAll(keepingCapacity: true)
        var count = 0
        for point in point_centers {
            let coordinate = faeMapView.convert(point, toCoordinateFrom: nil)
            coordinates_user.append(coordinate)
            fetchPlacePinsPartly(center: coordinate, number: count)
            count += 1
        }
    }
    
    func doneFetchingAreaUserData() {
        var userPins = [FaePinAnnotation]()
        userPinAdderJob.cancel()
        userPinAdderJob = DispatchWorkItem() { [unowned self] in
            for userJson in self.rawUserJSONs {
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
                joshprint("[user done]", Date().timeIntervalSince(self.date_start))
                return
            }
            DispatchQueue.main.async {
                self.userClusterManager.addAnnotations(userPins, withCompletionHandler: {
                    joshprint("[user done]", Date().timeIntervalSince(self.date_start))
                })
                for user in userPins {
                    user.isValid = true
                }
                self.boolCanUpdateUsers = true
            }
        }
        userPinAdderQueue.async(execute: userPinAdderJob)
    }
    
    func fetchUserPinsPartly(center: CLLocationCoordinate2D, number: Int) {
        let radius = calculateRadius(mapView: faeMapView)
        let userAgent = FaeMap()
        userAgent.whereKey("geo_latitude", value: "\(center.latitude)")
        userAgent.whereKey("geo_longitude", value: "\(center.longitude)")
        userAgent.whereKey("radius", value: "\(radius)")
        userAgent.whereKey("type", value: "user")
        userAgent.whereKey("max_count", value: "15")
//        userAgent.whereKey("user_updated_in", value: "180")
        if let request = userPinRequests[number] {
            request.cancel()
            userPinRequests[number] = nil
        }
        userPinRequests[number] = userAgent.getMapPins { [unowned self] (status, message) in
            //joshprint("No.\(number) user pins fetched")
            guard status / 100 == 2 else {
                self.userFetchesCount += 1
                self.userFetchesCountWhenMapPanning += 1
                return
            }
            guard message != nil else {
                self.userFetchesCount += 1
                self.userFetchesCountWhenMapPanning += 1
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                self.userFetchesCount += 1
                self.userFetchesCountWhenMapPanning += 1
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                self.userFetchesCount += 1
                self.userFetchesCountWhenMapPanning += 1
                return
            }
            self.rawUserJSONs += mapPlaceJsonArray
            self.userFetchesCount += 1
            self.userFetchesCountWhenMapPanning += 1
        }
    }
    
    func fetchUserDataInCertainMapRect(number: Int) {
        var mapRect = faeMapView.visibleMapRect
        let map_width = mapRect.size.width
        let map_height = mapRect.size.height
        mapRect.origin.x += Double(number % 3) * (map_width / 3)
        mapRect.origin.y += Double(number / 3) * (map_height / 8)
        mapRect.size.width = map_width / 3
        mapRect.size.height = map_height / 8
        let annos = faeMapView.annotations(in: mapRect)
        var annoCount = annos.count
        for anno in annos {
            if anno is MKUserLocation {
                annoCount -= 1
            } else if anno is CCHMapClusterAnnotation {
                if let clusterAnn = anno as? CCHMapClusterAnnotation {
                    if let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation {
                        if firstAnn.type == .place {
                            annoCount -= 1
                        }
                    }
                }
            }
        }
        guard annoCount == 0 else { return }
        numberOfAreasWithNoUserPin += 1
        //joshprint("no user annos found in area \(number)");
        guard point_centers.count == 24 else { return }
        let coordinate = faeMapView.convert(point_centers[number], toCoordinateFrom: nil)
        fetchUserPinsPartly(center: coordinate, number: number)
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
        pinToRoute = FaePinAnnotation(type: .place, cluster: placeClusterManager, data: placeInfo)
        pinToRoute.animatable = false
        pinsToRoute = [pinToRoute]
        HIDE_AVATARS = true
        PLACE_FETCH_ENABLE = false
        cancelPlacePinsFetch()
        // remove place pins but don't delete them
        var pinsToRemove = [FaePinAnnotation]()
        if modeCollection == .off {
            if searchState == .multipleSearch {
                pinsToRemove = pinsFromSearch
            } else {
                pinsToRemove = faePlacePins
            }
        } else {
            pinsToRemove = pinsFromCollection
        }
        removeLocationAnnotations(with: pinsToRemove, forced: true, instantly: false)
        removePlaceAnnotations(with: pinsToRemove, forced: true, instantly: false) {
            self.addPlaceAnnotations(with: self.pinsToRoute, forced: true, instantly: false)
            self.routeCalculator(destination: self.pinToRoute.coordinate)
        }
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
    
    private func routingLocation(_ locationInfo: LocationPin) {
        pinToRoute = FaePinAnnotation(type: .location, cluster: locationPinClusterManager, data: locationInfo)
        pinsToRoute = [pinToRoute]
        uiviewLocationBar.hide()
        selectedLocAnno?.hideButtons(animated: false)
        selectedLocAnno?.optionsToNormal()
        HIDE_AVATARS = true
        PLACE_FETCH_ENABLE = false
        cancelPlacePinsFetch()
        // remove place pins but don't delete them
        var pinsToRemove = [FaePinAnnotation]()
        if modeCollection == .off {
            if searchState == .multipleSearch {
                pinsToRemove = pinsFromSearch
            } else {
                pinsToRemove = faePlacePins
            }
        } else {
            pinsToRemove = pinsFromCollection
        }
        removeLocationAnnotations(with: pinsToRemove, forced: true, instantly: false) {
            self.removePlaceAnnotations(with: pinsToRemove, forced: true, instantly: false) {
                if self.modeCollection == .on {
                    self.addLocationAnnotations(with: self.pinsToRoute, forced: true, instantly: false)
                }
                self.routeCalculator(destination: self.pinToRoute.coordinate)
            }
        }
        
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
            guard !Key.shared.is_guest else {
                loadGuestMode()
                return
            }
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
            if let location = selectedLocation?.pinInfo as? LocationPin {
                routingLocation(location)
            }
            if let place = selectedPlace?.pinInfo as? PlacePin {
                routingPlace(place)
            }
        case .share:
            guard !Key.shared.is_guest else {
                loadGuestMode()
                return
            }
            if modeLocCreating == .on {
                selectedLocAnno?.optionsToNormal()
                selectedLocAnno?.hideButtons()
                let vcShareCollection = NewChatShareController(friendListMode: .location)
                let coordinate = selectedLocation?.coordinate
                AddPinToCollectionView().mapScreenShot(coordinate: coordinate!) { [unowned self] (snapShotImage) in
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
        anView.iconIndex = first.category_icon_id
        anView.assignImage(first.icon)
        if first.isSelected {
            let icon = UIImage(named: "place_map_\(anView.iconIndex)s") ?? #imageLiteral(resourceName: "place_map_48s")
            anView.assignImage(icon)
            anView.optionsReady = true
            anView.optionsOpened = false
            selectedPlaceAnno = anView
            anView.superview?.bringSubview(toFront: anView)
            anView.zPos = 199
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
        guard var firstAnn = cluster.representative as? FaePinAnnotation else { return }
        guard let anView = view as? PlacePinAnnotationView else { return }
        if let sPlace = selectedPlace {
            if faeBeta.coordinateEqual(cluster.coordinate, sPlace.coordinate) {
                firstAnn = sPlace
            }
        }
        let idx = firstAnn.category_icon_id
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
            FaeMap.shared.getPinSavedInfo(id: placePin.id, type: "place") { [unowned self] (ids) in
                let placeData = placePin
                placeData.arrListSavedThisPin = ids
                firstAnn.pinInfo = placeData as AnyObject
                self.uiviewSavedList.arrListSavedThisPin = ids
                anView.boolShowSavedNoti = ids.count > 0
            }
        }
        tblPlaceResult.show()
        tblPlaceResult.changeState(isLoading: false, isNoResult: false, shouldShrink: false)
        tblPlaceResult.resetSubviews()
        tblPlaceResult.tag = 1
        tblPlaceResult.curtAnnotation = cluster
        reloadPlaceTableAnnotations()
        if modeCollection == .on {
            tblPlaceResult.loading(current: placePin, isSwitchingPage: !tblPlaceResult.isShrinked)
        } else {
            if searchState == .map {
                
            } else if searchState == .multipleSearch {
                tblPlaceResult.loading(current: placePin, isSwitchingPage: !tblPlaceResult.isShrinked)
            }
        }
    }
    
    private func cancelPlacePinsFetch() {
        FaeMap.shared.placePinsRequest?.cancel()
        for (_, request) in placePinRequests {
            request.cancel()
        }
        for (_, request) in userPinRequests {
            request.cancel()
        }
        placePinFetchQueue.cancelAllOperations()
    }
    
    private func fetchPlacePins() {
        startFetchingAreaPlaceData()
    }
    
    func stopIconSpin(delay: Double) {
        boolCanUpdatePlaces = true
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.btnRefreshIcon.stopIconSpin()
        })
    }
    
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
    
    func initScreenPointCenters() {
        for i in [1,3,5,7,9,11,13,15] {
            for j in [1,3,5] {
                let point = CGPoint(x: screenWidth / 6 * CGFloat(j), y: screenHeight / 16 * CGFloat(i))
                point_centers.append(point)
            }
        }
        mapView(faeMapView, regionDidChangeAnimated: false)
    }
    
    func startFetchingAreaPlaceData() {
        time_start = DispatchTime.now()
        date_start = Date()
        guard PLACE_FETCH_ENABLE else {
            stopIconSpin(delay: getDelay(prevTime: time_start))
            return
        }
        
        guard boolCanUpdatePlaces else {
            stopIconSpin(delay: getDelay(prevTime: time_start))
            return
        }
        boolCanUpdatePlaces = false
        placeFetchesCount = 0
        General.shared.renewSelfLocation()
        rawPlaceJSONs.removeAll()
        coordinates_place.removeAll(keepingCapacity: true)
//        var count = 0
//        for point in point_centers {
//            let coordinate = faeMapView.convert(point, toCoordinateFrom: nil)
//            coordinates_place.append(coordinate)
//            fetchPlacePinsPartly(center: coordinate, number: count)
//            count += 1
//        }
        fetchPlacePinsPartly(center: faeMapView.centerCoordinate, number: 0)
    }
    
    func doneFetchingAreaPlaceData() {
        self.placePinFetchQueue.cancelAllOperations()
        let fetcher = PlacePinFetcher(cluster: placeClusterManager, arrPlaceJSON: rawPlaceJSONs, idSet: setPlacePins)
        fetcher.completionBlock = {
            DispatchQueue.main.async { [unowned self] in
                self.stopIconSpin(delay: 0)
                if fetcher.isCancelled {
                    //joshprint("[fetchPlacePins] operation cancelled")
                    return
                }
                guard self.isMapWillChange == false else { return }
                guard self.PLACE_FETCH_ENABLE else { return }
                guard self.modeCollection == .off else { return }
                guard self.searchState == .map else { return }
                guard fetcher.placePins.count > 0 else { return }
                //joshprint("[fetchPlacePins] fetched")
                if self.isFirstPlacesFetching {
                    self.isForcedRefresh = true
                    self.isFirstPlacesFetching = false
                    joshprint("[isFirstPlacesFetching]")
                }
                self.placeClusterManager.isVisibleAnnotationRemovingBlocked = true
                self.addPlaceAnnotations(with: fetcher.placePins, forced: self.isForcedRefresh, instantly: false, {
                    self.isForcedRefresh = false
                    self.placeClusterManager.isVisibleAnnotationRemovingBlocked = false
                    self.setPlacePins = self.setPlacePins.union(Set(fetcher.ids))
                    self.faePlacePins += fetcher.placePins
                    self.reloadPlaceTableAnnotations()
                    //joshprint("[place done]", Date().timeIntervalSince(self.date_start))
                })
            }
        }
        self.placePinFetchQueue.addOperation(fetcher)
    }
    
    func fetchAreaPlaceDataWhenRegionDidChange() {
        date_start = Date()
        if PLACE_FETCH_ENABLE || !HIDE_AVATARS {
            General.shared.renewSelfLocation()
        }
        if PLACE_FETCH_ENABLE {
            self.startFetchingAreaPlaceData()
//            placeFetchesCountWhenMapPanning = 0
//            numberOfAreasWithNoPlacePin = 0
//            rawPlaceJSONs.removeAll()
//            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now()) {
//                for i in 0...23 {
//                    self.fetchPlaceDataInCertainMapRect(number: i)
//                }
//            }
        }
    }
    
    func fetchPlacePinsPartly(center: CLLocationCoordinate2D, number: Int) {
        let radius = cameraDistance(mapView: faeMapView)
        let placeAgent = FaeMap()
        placeAgent.whereKey("geo_latitude", value: "\(center.latitude)")
        placeAgent.whereKey("geo_longitude", value: "\(center.longitude)")
        placeAgent.whereKey("radius", value: "\(radius/2)")
        placeAgent.whereKey("type", value: "place")
        placeAgent.whereKey("max_count", value: "100")
        //joshprint("[fetching radius]", radius)
        if let request = placePinRequests[number] {
            request.cancel()
            placePinRequests[number] = nil
        }
        placePinRequests[number] = placeAgent.getMapPins { [unowned self] (status, message) in
            //joshprint("No.\(number) place pins fetched")
            guard status / 100 == 2 else {
                self.placeFetchesCount += 1
                self.placeFetchesCountWhenMapPanning += 1
                return
            }
            guard message != nil else {
                self.placeFetchesCount += 1
                self.placeFetchesCountWhenMapPanning += 1
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                self.placeFetchesCount += 1
                self.placeFetchesCountWhenMapPanning += 1
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                self.placeFetchesCount += 1
                self.placeFetchesCountWhenMapPanning += 1
                return
            }
            self.rawPlaceJSONs += mapPlaceJsonArray
            self.placeFetchesCount += 1
            self.placeFetchesCountWhenMapPanning += 1
        }
    }
    
    func fetchPlaceDataInCertainMapRect(number: Int) {
        var mapRect = faeMapView.visibleMapRect
        let map_width = mapRect.size.width
        let map_height = mapRect.size.height
        mapRect.origin.x += Double(number % 3) * (map_width / 3)
        mapRect.origin.y += Double(number / 3) * (map_height / 8)
        mapRect.size.width = map_width / 3
        mapRect.size.height = map_height / 8
        let annos = faeMapView.annotations(in: mapRect)
        var annoCount = annos.count
        for anno in annos {
            if anno is MKUserLocation {
                annoCount -= 1
            } else if anno is CCHMapClusterAnnotation {
                if let clusterAnn = anno as? CCHMapClusterAnnotation {
                    if let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation {
                        if firstAnn.type == .place {
                            annoCount -= 1
                        }
                    }
                }
            }
        }
        guard annoCount == 0 else { return }
        numberOfAreasWithNoPlacePin += 1
        //joshprint("no place annos found in area \(number)");
        guard point_centers.count == 24 else { return }
        let coordinate = faeMapView.convert(point_centers[number], toCoordinateFrom: nil)
        fetchPlacePinsPartly(center: coordinate, number: number)
    }
    
    /*
    private func fetchPlacePinWithTestData() {
        guard USE_TEST_PLACES else { return }
        let places = generator(locToRefresh, 100, faePlacePins.count)
        let placePins = places.map( { FaePinAnnotation(type: .place, cluster: placeClusterManager, data: $0 as AnyObject) } )
        placeClusterManager.addAnnotations(placePins, withCompletionHandler: {
            self.faePlacePins += placePins
        })
        self.boolCanUpdatePlaces = true
        stopIconSpin(delay: getDelay(prevTime: time_0))
    }
     */
    
    // MARK: - Reload Place Pins
    private func reloadPlacePinsOnMap(places: [PlacePin], completion: @escaping () -> Void) {
        var pinsToReAdd = [FaePinAnnotation]()
        if modeCollection == .off {
            pinsToReAdd = pinsFromSearch
        } else {
            pinsToReAdd = pinsFromCollection
        }
        removePlaceAnnotations(with: pinsToReAdd, forced: true, instantly: true) {
            pinsToReAdd = places.map({ FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0 as AnyObject) })
            if self.modeCollection == .off {
                self.pinsFromSearch = pinsToReAdd
            } else {
                self.pinsFromCollection = pinsToReAdd
            }
            self.addPlaceAnnotations(with: pinsToReAdd, forced: true, instantly: true) {
                completion()
            }
        }
    }
}

// MARK: - Routing
extension FaeMapViewController: FMRouteCalculateDelegate, SelectLocationDelegate {
    
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
        GeneralLocationSearchViewController.boolToDestination = false
        routingHandleTap()
    }
    
    @objc private func handleDestinationTap(_ tap: UITapGestureRecognizer) {
        GeneralLocationSearchViewController.boolToDestination = true
        routingHandleTap()
    }
    
    private func routingHandleTap() {
        let chooseLocsVC = GeneralLocationSearchViewController()
        chooseLocsVC.delegate = self
        chooseLocsVC.boolCurtLocSelected = uiviewChooseLocs.lblStartPoint.text == "Current Location" || uiviewChooseLocs.lblDestination.text == "Current Location"
        chooseLocsVC.boolFromRouting = true
        navigationController?.pushViewController(chooseLocsVC, animated: false)
    }
    
    @objc private func handleSelectLocationTap(_ tap: UITapGestureRecognizer) {
        guard routeAddress != nil else { return }
        sendLocationBack(address: routeAddress)
    }
    
    // SelectLocationDelegate
    func chooseLocationOnMap() {
        uiviewChooseLocs.hide(animated: false)
        mapMode = .selecting
        mapView(faeMapView, regionDidChangeAnimated: false)
    }
    
    // SelectLocationDelegate
    func sendLocationBack(address: RouteAddress) {
        faeMapView.removeAnnotations(addressAnnotations)
        if GeneralLocationSearchViewController.boolToDestination {
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
        showOrHideTableResultsExpandingIndicator()
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
        PLACE_FETCH_ENABLE = true
        faeMapView.removeAnnotations(addressAnnotations)
        isRoutingCancelled = true
        
        var isReAddUsersEnabled = false
        var isInCollectionOrSearch = true
        var pinsToReAdd = [FaePinAnnotation]()
        if modeCollection == .off {
            if searchState == .multipleSearch {
                pinsToReAdd = pinsFromSearch
            } else {
                pinsToReAdd = faePlacePins
                isReAddUsersEnabled = true
                isInCollectionOrSearch = false
            }
        } else {
            pinsToReAdd = pinsFromCollection
        }
        if isReAddUsersEnabled {
            self.reAddUserPins()
        }
        
        func addPins() {
            if isPlaceCollection {
                addPlaceAnnotations(with: pinsToReAdd, forced: true, instantly: true)
                if isInCollectionOrSearch {
                    tblPlaceResult.show()
                    showOrHideTableResultsExpandingIndicator(show: true, animated: true)
                }
            } else {
                addLocationAnnotations(with: pinsToReAdd, forced: true, instantly: true)
            }
        }
        
        if pinToRoute.type == .place {
            removePlaceAnnotations(with: pinsToRoute, forced: true, instantly: false) {
                addPins()
            }
        } else if pinToRoute.type == .location {
            removeLocationAnnotations(with: pinsToRoute, forced: true, instantly: false) {
                addPins()
            }
        }
        
        if !Key.shared.is_guest {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
        }
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
                    self.btnRefreshIcon.frame.origin.y = screenHeight + 10
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                self.btnLocateSelf.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                self.btnOpenChat.frame.origin.y = screenHeight + 10
                self.btnDiscovery.frame.origin.y = screenHeight + 10
                self.btnRefreshIcon.frame.origin.y = screenHeight + 10
            }
            faeMapView.compassOffset = 134
            faeMapView.layoutSubviews()
        } else {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnRefreshIcon.center.y = screenHeight - 25 - device_offset_bot
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnRefreshIcon.center.y = screenHeight - 25 - device_offset_bot
            }
            faeMapView.compassOffset = 215
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            guard !self.isRoutingCancelled else {
                self.btnDistIndicator.activityIndicator.stopAnimating()
                return
            }
            MKDirections(request: request).calculate { [unowned self] response, error in
                self.btnDistIndicator.activityIndicator.stopAnimating()
                guard !self.isRoutingCancelled else { return }
                guard let unwrappedResponse = response else {
                    showAlert(title: "Sorry! This route is too long to draw.", message: "please try again", viewCtrler: self)
                    return
                }
                var totalDistance: CLLocationDistance = 0
                for route in unwrappedResponse.routes {
                    self.arrRoutes.append(route.polyline)
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
                self.showRouteCalculatorComponents(distance: totalDistance)
                // fit all route overlays
                if let first = self.arrRoutes.first {
                    let rect = self.arrRoutes.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
                    self.faeMapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 150 + device_offset_top, left: 75, bottom: 90 + device_offset_bot, right: 75), animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                    guard !self.isRoutingCancelled else { return }
                    self.faeMapView.addOverlays(self.arrRoutes, level: MKOverlayLevel.aboveRoads)
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

// MARK: - Location Pin

extension FaeMapViewController {
    
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
        firstAnn.isSelected = true
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
            FaeMap.shared.getPinSavedInfo(id: pinData.id, type: "location") { [unowned self] (ids) in
                pinData.arrListSavedThisPin = ids
                firstAnn.pinInfo = pinData as AnyObject
                self.uiviewSavedList.arrListSavedThisPin = ids
                anView.boolShowSavedNoti = ids.count > 0
            }
        }
        if !anView.optionsReady {
            let cllocation = CLLocation(latitude: locationData.coordinate.latitude, longitude: locationData.coordinate.longitude)
            uiviewLocationBar.updateLocationInfo(location: cllocation) { [unowned self] (address_1, address_2) in
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
    
    private func createLocationPin(point: CGPoint) {
        let coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        createLocPin(location)
    }
    
    private func createLocationPin(location: CLLocation) {
        createLocPin(location)
    }
    
    private func createLocationPin(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        createLocPin(location)
    }
    
    private func createLocPin(_ location: CLLocation) {
        guard modeLocation == .off else { return }
        modeLocCreating = .on
        uiviewAfterAdded.reset()
        
        func createLoc() {
            tblPlaceResult.hide()
            showOrHideTableResultsExpandingIndicator()
            selectedLocAnno?.hideButtons()
            selectedLocAnno?.optionsReady = false
            selectedLocAnno?.optionsOpened = false
            selectedLocAnno?.optionsOpeing = false
            selectedLocAnno?.removeFromSuperview()
            selectedLocAnno = nil
            deselectAllPlaceAnnos()
            let pinData = LocationPin(position: location.coordinate)
            pinData.optionsReady = true
            selectedLocation = FaePinAnnotation(type: .location, data: pinData as AnyObject)
            selectedLocation?.isSelected = true
            selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
            locationPinClusterManager.addAnnotations([self.selectedLocation!], withCompletionHandler: nil)
            uiviewLocationBar.updateLocationInfo(location: location) { (address_1, address_2) in
                self.selectedLocation?.address_1 = address_1
                self.selectedLocation?.address_2 = address_2
                self.uiviewChooseLocs.updateDestination(name: address_1)
                self.destinationAddr = RouteAddress(name: address_1, coordinate: location.coordinate)
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
        showOrHideTableResultsExpandingIndicator()
        tapUserPin(didSelect: view)
    }
    
    func locPinTap(view: MKAnnotationView) {
        tapLocationPin(didSelect: view)
        uiviewLocationBar.show()
        tblPlaceResult.hide()
        showOrHideTableResultsExpandingIndicator(show: false, animated: true)
    }
    
    func allPlacesDeselect(_ full: Bool) {
        deselectAllPlaceAnnos(full: full)
    }
    
    func allLocationsDeselect() {
        deselectAllLocAnnos()
    }
    
    func singleElsewhereTap() {
        uiviewSavedList.hide()
        btnZoom.tapToSmallMode()
    }
    
    func singleElsewhereTapExceptInfobar() {
        faeMapView.mapGesture(isOn: true)
        if searchState != .multipleSearch && modeCollection == .off {
            tblPlaceResult.hide()
            showOrHideTableResultsExpandingIndicator()
        }
        uiviewLocationBar.hide()
        deselectAllPlaceAnnos(full: searchState == .map)
//        deselectAllLocAnnos()
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

extension FaeMapViewController {
    
    private func loadGuestMode() {
        uiviewGuestMode = GuestModeView()
        view.addSubview(uiviewGuestMode)
        uiviewGuestMode.show()
        uiviewGuestMode.dismissGuestMode = { [unowned self] in
            self.removeGuestMode()
        }
        uiviewGuestMode.guestLogin = { [unowned self] in
            Key.shared.navOpenMode = .welcomeFirst
            let viewCtrlers = [WelcomeViewController(), LogInViewController()]
            self.navigationController?.setViewControllers(viewCtrlers, animated: true)
        }
        uiviewGuestMode.guestRegister = { [unowned self] in
            Key.shared.navOpenMode = .welcomeFirst
            let viewCtrlers = [WelcomeViewController(), RegisterNameViewController()]
            self.navigationController?.setViewControllers(viewCtrlers, animated: true)
        }
    }
    
    private func removeGuestMode() {
        guard uiviewGuestMode != nil else { return }
        uiviewGuestMode.hide {
            self.uiviewGuestMode.removeFromSuperview()
        }
    }
    
}
