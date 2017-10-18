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
    case explore
}

enum CreateLocation {
    case cancel
    case create
}

class FaeMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MapView Data and Control
    var faeMapView: FaeMapView!
    var placeClusterManager: CCHMapClusterController!
//    var userClusterManager: CCHMapClusterController!
    var faeUserPins = [FaePinAnnotation]()
    var timerUserPin: Timer? // timer to renew update user pins
    var faePlacePins = [FaePinAnnotation]()
    var arrPlaceData = [PlacePin]()
    var timerLoadMessages: Timer?
    
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
    
    // Compass and Locating Self
    var btnCompass: FMCompass!
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
    let floatFilterHeight = 471 * screenHeightFactor // Map Filter height
    
    // Selected Place Control
    var selectedPlaceView: PlacePinAnnotationView?
    var selectedPlace: FaePinAnnotation?
    var uiviewPlaceBar = FMPlaceInfoBar()
    var swipingState: PlaceInfoBarState = .map {
        didSet {
            guard fullyLoaded else { return }
//            placeClusterManager.maxZoomLevelForClustering = swipingState == .multipleSearch ? 0 : Double.greatestFiniteMagnitude
        }
    }
    var boolSelecting = false
    var firstSelectPlace = true
    
    // Results from Search
    var btnTapToShowResultTbl: UIButton!
    var tblPlaceResult = FMPlacesTable()
    var placesFromSearch = [FaePinAnnotation]()
    
    // Name Card
    var uiviewNameCard: FMNameCardView!
    
    // MapView Offset Control
    var prevMapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var prevAltitude: CLLocationDistance = 0
    var prevBearing: Double = 0
    
    // Collecting Pin Control
    var uiviewCollectedList: AddPlaceToCollectionView!
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
    
    // Selecting Location Mode
    var imgPinOnMap: UIImageView!
    
    // Location Pin Control
    var locationPin: FaePinAnnotation?
    var uiviewLocationBar: LocationView!
    var locAnnoView: LocPinAnnotationView?
    var activityIndicator: UIActivityIndicatorView!
    var locationPinClusterManager: CCHMapClusterController!
    
    var mapMode: MapMode = .normal {
        didSet {
            guard fullyLoaded else { return }
            imgSearchIcon.isHidden = mapMode == .selecting
            btnLeftWindow.isHidden = mapMode == .selecting || mapMode == .explore || mapMode == .pinDetail
            imgExpbarShadow.isHidden = mapMode != .explore && mapMode != .pinDetail
            imgSchbarShadow.isHidden = mapMode == .explore || mapMode == .pinDetail
            btnCompass.isHidden = mapMode == .explore
            btnLocateSelf.isHidden = mapMode == .explore
            btnOpenChat.isHidden = mapMode == .explore
            btnFilterIcon.isHidden = mapMode == .explore
            btnDiscovery.isHidden = mapMode == .explore
            clctViewMap.isHidden = mapMode != .explore
            imgAddressIcon.isHidden = mapMode == .selecting || mapMode == .normal
            btnCancelSelect.isHidden = mapMode == .selecting || mapMode == .normal
            lblSearchContent.textColor = mapMode == .selecting ? UIColor._898989() : UIColor._182182182()
            if mapMode != .selecting { lblSearchContent.text = "Search Fae Map" }
            if mapMode == .selecting { btnDistIndicator.lblDistance.text = "Select" }
            else { btnDistIndicator.lblDistance.text = btnDistIndicator.strDistance }
            imgPinOnMap.isHidden = mapMode != .selecting
            btnDistIndicator.isUserInteractionEnabled = mapMode == .selecting
            btnMainMapSearch.isHidden = mapMode == .routing || mapMode == .selecting
            userStatus = mapMode == .routing || mapMode == .selecting ? 5 : 1
            if mapMode == .routing || mapMode == .selecting {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
            }
        }
    }
    
    var createLocation: CreateLocation = .cancel {
        didSet {
            guard fullyLoaded else { return }
            btnClearSearchRes.isHidden = createLocation == .cancel
            if createLocation == .cancel {
                lblSearchContent.textColor = UIColor._182182182()
                lblSearchContent.text = "Search Fae Map"
                uiviewLocationBar.hide()
                activityIndicator.stopAnimating()
                if locationPin != nil {
                    locationPinClusterManager.removeAnnotations([locationPin!], withCompletionHandler: nil)
                    if locAnnoView != nil {
                        locAnnoView?.hideButtons()
                        locAnnoView?.optionsReady = false
                        locAnnoView?.optionsOpened = false
                        locAnnoView?.optionsOpeing = false
                    }
                    locationPin = nil
                }
            }
        }
    }
    
    var boolCanUpdateUserPin = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    let FILTER_ENABLE = true
    var PLACE_ENABLE = true
    let USER_ENABLE = false
    var boolPreventUserPinOpen = false
    var AUTO_REFRESH = true
    var AUTO_CIRCLE_PINS = true
    var HIDE_AVATARS = false
    var fullyLoaded = false // indicate if all components are fully loaded
    
    // System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        isUserLoggedIn()
        getUserStatus()
        
        loadNameCard()
        loadMapFilter()
        loadMapView()
        loadButton()
        loadExploreBar()
        loadPlaceDetail()
        loadPlaceListView()
        loadDistanceComponents()
        loadSmallClctView()
        loadLocationView()
        
        timerSetup()
        updateSelfInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(firstUpdateLocation), name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
        
        fullyLoaded = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMapChat()
        renewSelfLocation()
        checkDisplayNameExisitency()
        updateGenderAge()
        updateTimerForAllPins()
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
        getFromURL("users/name_card", parameter: nil, authentication: headerAuthentication()) { status, result in
            guard status / 100 == 2 else { return }
            let rsltJSON = JSON(result!)
            if let _ = rsltJSON["nick_name"].string {
                sendWelcomeMessage()
            } else {
                self.loadFirstLoginVC()
                sendWelcomeMessage()
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
        userMiniAvatar = Key.shared.gender == "male" ? males[random] : females[random]
        userAvatarMap = "miniAvatar_\(userMiniAvatar)"
        LocalStorageManager.shared.saveInt("userMiniAvatar", value: userMiniAvatar)
        updateMiniAvatar.whereKey("mini_avatar", value: "\(userMiniAvatar - 1)")
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
        updateTimerForLoadRegionPlacePin()
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
            updateTimerForLoadRegionPlacePin()
        }
    }
}
