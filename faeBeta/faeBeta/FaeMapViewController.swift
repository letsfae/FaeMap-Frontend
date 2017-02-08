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

class FaeMapViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    // MARK: -- Common Used Vars and Constants
    let navigationBarHeight : CGFloat = 20
    
    // MARK: -- Map main screen Objects
    var faeMapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    
    var buttonLeftTop: UIButton!
    var buttonMainScreenSearch: UIButton!
    var buttonRightTop: UIButton!
    var buttonToNorth: UIButton!
    var buttonSelfPosition: UIButton!
    var buttonChatOnMap: UIButton!
    var buttonPinOnMap: UIButton!
    var buttonPinOnMapInside: UIButton!
    var buttonCancelSelectLocation: UIButton!
    
    // MARK: -- Location
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLocation: CLLocation!
    var currentLongitude: CLLocationDegrees = -118.2854081
    var didLoadFirstLoad = false
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    var startUpdatingLocation = false
    
    // Unread Messages Label
    var labelUnreadMessages: UILabel!
    
    // MARK: -- My Position Marker
    var myPosMarker = GMSMarker()
    var myPositionIcon: UIButton!
    var myPositionOutsideMarker_1: UIImageView!
    var myPositionOutsideMarker_2: UIImageView!
    var myPositionOutsideMarker_3: UIImageView!
    var myPositionIconFirstLoaded = true
    
    // MARK: -- More Button Vars
    var uiviewMoreButton: UIView!
    var dimBackgroundMoreButton: UIButton!
    
    // MARK: -- WindBell Vars
    var uiviewWindBell: UIView!
    var dimBackgroundWindBell: UIButton!
    
    // MARK: -- Map Chat
    var mapChatSubview: UIButton!
    var mapChatWindow: UIView!
    var labelMapChat: UILabel!
    var mapChatTable = UITableView()
    
    // More table view
    let tableViewWeight : CGFloat = 290
    var buttonImagePicker : UIButton!
    var buttonMoreLeft : UIButton!
    var buttonMoreRight : UIButton!
    var imagePicker : UIImagePickerController! // MARK: new var Wenye
    var imageViewAvatarMore : UIImageView!
    var imageViewBackgroundMore : UIImageView!
    var labelMoreName : UILabel!
    var tableviewMore = UITableView()
    var viewHeaderForMore : UIView!
    
    // Windbell table view
    var labelWindbellTableTitle: UILabel!
    var tableviewWindbell = UITableView()
    
    // Wang Yanxiang
    var openUserPinActive = false
    // end of WYX
    //
    let storageForOpenedPinList = UserDefaults.standard// Local Storage for storing opened pin id, for opened pin list use
    var buttonCloseUserPinSubview: UIButton! // button to close user pin view
    var canDoNextUserUpdate = true // Prevent updating user on map more than once, or, prevent user pin change its ramdom place if clicking on it
    var canLoadMapPin = true // if can load map pin when zoom level is valid for updating
    var canOpenAnotherPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    var mapPinsArray = [GMSMarker]() // Map Comment Pin Array
    var mapPinsDic = [Int: GMSMarker]() // Map Comment Pin Dictionary
    var mapUserPinsDic = [GMSMarker]() // Map User Pin
    var markerBackFromPinDetail = GMSMarker() // Marker saved for back from comment pin detail view
    var markerMask: UIView! // mask to prevent UI action
    var pinIDFromOpenedPinCell = -999 // Determine if this pinID should change to heavy shadow style
    var pinIdToPassBySegue: String = "" // segue to Comment Pin Popup Window
    var previousPosition: CLLocationCoordinate2D!
    var previousZoomLevel: Float = 0 // previous zoom level to check if map should reload pins
    var tempMarker: UIImageView! // temp marker, it is a UIImageView
    var timerLoadRegionPins: Timer! // timer to renew map pins
    var timerUpdateSelfLocation: Timer! // timer to renew update user pins
    
    // Map Namecard
    var buttonChat: UIButton!
    var buttonClosingOptionsInNameCard: UIButton!
    var buttonEmoji: UIButton!
    var buttonFakeTransparentClosingView: UIButton!
    var buttonFavorite: UIButton!
    var buttonOptions: UIButton!
    var buttonShowSelfOnMap: UIButton!
    var editNameCard: UIButton!
    var imageAvatarNameCard: UIImageView!
    var imageBackground: UIImageView!
    var imageCover: UIImageView!
    var imageGenderMen: UIImageView!
    var imageOneLine: UIImageView!
    var labelDisplayName: UILabel!
    var labelNameTag: UILabel!
    var labelShortIntro: UILabel!
    var nameCardMoreOptions: UIImageView!
    var reportNameCard: UIButton!
    var shareNameCard: UIButton!
    var uiViewNameCard: UIView!
    var labelUserAge: UILabel!
    var uiviewUserGender: UIView!
    var imageUserGender: UIImageView!
    
    // Map Filter
    
    let filterMenuHeight = 542 * screenHeightFactor
    
    // Filter Button
    var btnMapFilter: UIButton!
    var polygonOutside: UIImageView!
    var polygonInside: UIImageView!
    var mapFilterArrow: UIImageView!
    
    // Filter Menu
    var uiviewFilterMenu: UIView!
    var btnDraggingMenu: UIButton!
    
    // Filter Item
    var btnMFilterShowAll: MFilterButton!
    var btnMFilterDistance: MFilterButton!
    var btnMFilterPeople: MFilterButton!
    
    var btnMFilterTypeAll: MFilterButton!
    var btnMFilterComments: MFilterButton!
    var btnMFilterChats: MFilterButton!
    var btnMFilterStories: MFilterButton!
    
    var btnMFilterStatusAll: MFilterButton!
    var btnMFilterHot: MFilterButton!
    var btnMFilterNew: MFilterButton!
    var btnMFilterUnread: MFilterButton!
    var btnMFilterRead: MFilterButton!
    
    var btnMFilterPlacesAll: MFilterButton!
    var btnMFilterRestr: MFilterButton!
    var btnMFilterCafe: MFilterButton!
    var btnMFilterDesert: MFilterButton!
    var btnMFilterCinema: MFilterButton!
    var btnMFilterBeauty: MFilterButton!
    var btnMFilterSports: MFilterButton!
    var btnMFilterGallery: MFilterButton!
    
    var btnMFilterMyPins: MFilterButton!
    var btnMFilterSavedPins: MFilterButton!
    var btnMFilterSavedPlaces: MFilterButton!
    var btnMFilterSavedLoc: MFilterButton!
    
    // Pan gesture var
    var sizeFrom: CGFloat = 0
    var sizeTo: CGFloat = 0
    var spaceFilter: CGFloat = 0
    var spaceMenu: CGFloat = 0
    var end: CGFloat = 0
    var percent: Double = 0
    
    // Filter data processing
    var filterPinTypeDic = [String: MFilterButton]()
    var filterPinStatusDic = [String: MFilterButton]()
    var filterPlaceDic = [String: MFilterButton]()
    
    // Filter Slider
    var filterSlider: UISlider!
    var lblFilterDist: UILabel!
    
    // Filter btn inside circles
    var filterCircle_1: UIImageView!
    var filterCircle_2: UIImageView!
    var filterCircle_3: UIImageView!
    var filterCircle_4: UIImageView!
    
    // Class global variable to control the filter
    var stringFilterValue = "comment,chat_room,media"
    
    // System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        let shareAPI = LocalStorageManager()
        _ = shareAPI.readLogInfo()
        if is_Login == 0 {
            self.jumpToWelcomeView(animated: false)
        }
        self.navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        myPositionIconFirstLoaded = true
        getUserStatus()
        loadMapView()
        setupClusterManager()
        loadTransparentNavBarItems()
        loadButton()
        loadNameCard()
        loadPositionAnimateImage()
        timerUpdateSelfLocation = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateSelfLocation), userInfo: nil, repeats: true)
        timerLoadRegionPins = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(self.loadCurrentRegionPins), userInfo: nil, repeats: true)
        let emptyArrayList = [String]()
        self.storageForOpenedPinList.set(emptyArrayList, forKey: "openedPinList")
        didLoadFirstLoad = true
        updateSelfInfo()
        
        loadMFilterSlider()
        loadMapFilter()
        checkFilterShowAll(btnMFilterShowAll)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locManager.requestAlwaysAuthorization()
        checkLocationEnablibity()
        self.loadTransparentNavBarItems()
        self.loadMapChat()
        if userStatus != 5  {
            loadPositionAnimateImage()
        }
        getSelfAccountInfo()
        buttonFakeTransparentClosingView.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        renewSelfLocation()
        
        animateMapFilterArrow()
        filterCircleAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.isFirstTimeLogin(_:)), name: NSNotification.Name(rawValue: "isFirstLogin"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func isFirstTimeLogin(_ notification: NSNotification) {
        print("[isFirstTimeLogin] yes it is")
        let firstTimeLoginVC = FirstTimeLoginViewController()
        firstTimeLoginVC.modalPresentationStyle = .overCurrentContext
        self.present(firstTimeLoginVC, animated: false, completion: nil)
    }
    
    // Check if location is enabled
    func checkLocationEnablibity() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            print("Not Authorised")
            self.locManager.requestAlwaysAuthorization()
        }
        
        else if CLLocationManager.authorizationStatus() == .denied {
            jumpToLocationEnable()
        }
    }
    
    // Testing back from background
    func appBackFromBackground() {
        checkLocationEnablibity()
        if faeMapView != nil {
            let currentZoomLevel = faeMapView.camera.zoom
            let powFactor: Double = Double(21 - currentZoomLevel)
            let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
            self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
            self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
            self.renewSelfLocation()
            reloadSelfPosAnimation()
        }
    }
    
    func reloadSelfPosAnimation() {
        if userStatus != 5  {
            loadPositionAnimateImage()
            getSelfAccountInfo()
        }
    }
    
    func jumpToLocationEnable() {
        let locEnableVC: UIViewController = UIStoryboard(name: "EnableLocationAndNotification", bundle: nil) .instantiateViewController(withIdentifier: "EnableLocationViewController") as! EnableLocationViewController
        self.present(locEnableVC, animated: true, completion: nil)
    }
    
    func jumpToWelcomeView(animated: Bool){
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
    func loadTransparentNavBarItems() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func refreshMap(pins: Bool, users: Bool, places: Bool) {
        let currentZoomLevel = faeMapView.camera.zoom
        let powFactor: Double = Double(21 - currentZoomLevel)
        let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
        if users {
            self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
        }
        if pins {
            self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
        }
        if places {
            
        }
    }
    
    // MARK: -- Map Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if didLoadFirstLoad {
            self.didLoadFirstLoad = false
            self.currentLocation = locManager.location
            self.currentLatitude = currentLocation.coordinate.latitude
            self.currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
            self.faeMapView.camera = camera
            self.startUpdatingLocation = true
            let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
            let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
            self.previousPosition = mapCenterCoordinate
            
            refreshMap(pins: true, users: true, places: true)
            
            let testYelp = YelpManager()
            let testQuery = YelpQuery()
            testQuery.setLatitude(lat: Double(currentLatitude))
            testQuery.setLongitude(lon: Double(currentLongitude))
            testQuery.setCatagoryToCafe()
            testQuery.setRadius(radius: 4000)
            testQuery.setSortRule(sort: "best_match")
            testYelp.query(request: testQuery, completion: { (results) in
                print("[YelpAPI - Testing]")
                for result in results {
                    print(result.getName())
                    print(result.getCategory())
                    print(result.getCategory().contains("coffee"))
                }
            })
        }
        
        // userStatus == 5, invisible
        if userStatus == 5 {
            return
        }
        
        if let location = locations.last {
            if myPositionOutsideMarker_3 != nil {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                let position = CLLocationCoordinate2DMake(latitude, longitude)
                let selfPositionToPoint = faeMapView.projection.point(for: position)
                myPositionOutsideMarker_3.center = selfPositionToPoint
                myPositionOutsideMarker_2.center = selfPositionToPoint
                myPositionOutsideMarker_1.center = selfPositionToPoint
                myPositionIcon.center = selfPositionToPoint
                self.myPositionIcon.isHidden = false
                self.myPositionOutsideMarker_1.isHidden = false
                self.myPositionOutsideMarker_2.isHidden = false
                self.myPositionOutsideMarker_3.isHidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Testing move to background, with timer
    func testingJumpToBackground() {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            print("This is run on the background queue")
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(FaeMapViewController.printsth), userInfo: nil, repeats: false)
            DispatchQueue.main.async(execute: { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
            })
        })
    }
    
    func printsth() {
        print("timer awake!")
    }
    ////////////////////////////////
}
