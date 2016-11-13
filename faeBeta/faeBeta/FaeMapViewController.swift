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

class FaeMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, MainScreenSearchViewControllerDelegate {
    
    // MARK: -- Common Used Vars and Constants
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let navigationBarHeight : CGFloat = 20
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    // MARK: -- Map main screen Objects
    var faeMapView: GMSMapView!
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
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    var willAppearFirstLoad = false
    var startUpdatingLocation = false
    
    // Unread Messages Label
    var labelUnreadMessages: UILabel!
    
    // MARK: -- My Position Marker
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
    var mapChatClose: UIButton!
    var labelMapChat: UILabel!
    var mapChatTable = UITableView()
    
    // More table view
    var tableviewMore = UITableView()
    let cellTableViewMore = "celltableviewmore1"
    var viewHeaderForMore : UIView!
    var imageViewBackgroundMore : UIImageView!
    var buttonMoreLeft : UIButton!
    var buttonMoreRight : UIButton!
    var imageViewAvatarMore : UIImageView!
    var labelMoreName : UILabel!
    let tableViewWeight : CGFloat = 290
    var imagePicker : UIImagePickerController! // MARK: new var Wenye
    var buttonImagePicker : UIButton!
    
    // Windbell table view
    var labelWindbellTableTitle: UILabel!
    var tableviewWindbell = UITableView()
    
    // Open User Pin View
    var uiviewDialog : UIView!
    var uiviewCard : UIView!
    var uiviewFunction : UIView!
    var uiviewTag : UIView!
    var buttonFollow : UIButton!
    var buttonShare : UIButton!
    var buttonKeep : UIButton!
    var buttonReport : UIButton!
    var collectionViewPhotos : UICollectionView!
    var cellPhotos = "cellPhotos"
    var imageViewLeft : UIImageView!
    var imageViewRight : UIImageView!
    var imageViewGender : UIImageView!
    var imageview : UIImageView!
    var imageviewNamecardAvatar : UIImageView!
    var imageviewNamecardGender : UIImageView!
    var imageviewUserPinBackground : UIImageView!
    var labelNamecardName : UILabel!
    var labelNamecardDescription : UILabel!
    var labelNamecardAge : UILabel!
    var viewLine : UIView!
    var viewLine2 : UIView!
    var collectionPhotos : UICollectionView!
    var buttonChat : UIButton!
    var buttonMore : UIButton!
    var tagName = [String]()
    var tagButtonSet = [UIButton]()
    var selectedButtonSet = [UIButton]()
    var tagLength = [CGFloat]()
    var tagColor = [UIColor]()
    var tagTitle = [NSMutableAttributedString]()
    let exlength : CGFloat = 8
    let selectedInterval : CGFloat = 11
    let maxLength : CGFloat = 320
    let lineInterval : CGFloat = 25.7
    let intervalInLine : CGFloat = 13.8
    let tagHeight : CGFloat = 18
    var openUserPinActive = false
    var currentViewingUserId = 1
    
    //
    var mapUserPinsDic = [GMSMarker]() // Map User Pin
    var mapCommentPinsDic = [Int: GMSMarker]() // Map Comment Pin
    var commentIdToPassBySegue: Int = -999 // segue to Comment Pin Popup Window
    var tempMarker: UIImageView! // temp marker, it is a UIImageView
    var markerMask: UIView! // mask to prevent UI action
    var NSTimerDisplayMarkerArray = [NSTimer]()
    var markerBackFromCommentDetail = GMSMarker() // Marker saved for back from comment pin detail view
    private let storageForOpenedPinList = NSUserDefaults.standardUserDefaults()// Local Storage for storing opened pin id, for opened pin list use
    var canDoNextUserUpdate = true // Prevent updating user on map more than once
    var commentIDFromOpenedPinCell = -999 // Determine if this pinID should change to heavy shadow style
    var canOpenAnotherPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    var buttonCloseUserPinSubview: UIButton! // button to close user pin view
    var timerUpdateSelfLocation: NSTimer! // timer to renew update user pins
    var timerLoadRegionPins: NSTimer! // timer to renew map pins
    var previousZoomLevel: Float = 0 // previous zoom level to check if map should reload pins
    var previousPosition: CLLocationCoordinate2D!
    
    // System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        let shareAPI = LocalStorageManager()
        shareAPI.readLogInfo()
        if is_Login == 0 {
            self.jumpToWelcomeView(false)
        }
        self.navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1 )
        myPositionIconFirstLoaded = true
        getUserStatus()
        loadMapView()
        loadTransparentNavBarItems()
        loadButton()
        loadMore()
        loadNamecard()
        loadPositionAnimateImage()
        timerUpdateSelfLocation = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(FaeMapViewController.updateSelfLocation), userInfo: nil, repeats: true)
        timerLoadRegionPins = NSTimer.scheduledTimerWithTimeInterval(600, target: self, selector: #selector(FaeMapViewController.loadCurrentRegionPins), userInfo: nil, repeats: true)
        let emptyArrayList = [Int]()
        self.storageForOpenedPinList.setObject(emptyArrayList, forKey: "openedPinList")
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(self.appBackFromBackground), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locManager.requestAlwaysAuthorization()
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined){
            print("Not Authorised")
            self.locManager.requestAlwaysAuthorization()
        }
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied){
            jumpToLocationEnable()
        }
        willAppearFirstLoad = true
        getSelfAccountInfo()
        self.buttonLeftTop.hidden = false
        self.buttonMainScreenSearch.hidden = false
        // self.buttonRightTop.hidden = false // -> Not for 11.01 Dev
        self.loadTransparentNavBarItems()
        self.loadMapChat()
        self.actionSelfPosition(self.buttonSelfPosition)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        renewSelfLocation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.buttonLeftTop.hidden = true
        self.buttonMainScreenSearch.hidden = true
//        self.buttonRightTop.hidden = true // -> Not for 11.01 Dev
        // Need a Comment Clearance??????
        self.navigationController?.navigationBar.translucent = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapToCommentPinDetail" {
            if let commentPinDetailVC = segue.destinationViewController as? CommentPinViewController {
                commentPinDetailVC.commentIdSentBySegue = commentIdToPassBySegue
                commentPinDetailVC.delegate = self
            }
        }
    }
    
    // Testing back from background
    func appBackFromBackground() {
        print("App back from background!")
        self.actionSelfPosition(self.buttonSelfPosition)
        self.updateTimerForLoadRegionPin()
        self.renewSelfLocation()
    }
    
    // Testing move to background, with timer
    func testingJumpToBackground() {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(FaeMapViewController.printsth), userInfo: nil, repeats: false)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
            })
        })
    }
    
    func printsth() {
        print("timer awake!")
    }
    ////////////////////////////////
    
    func jumpToLocationEnable() {
        let locEnableVC: UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("EnableLocationViewController")as! EnableLocationViewController
        self.presentViewController(locEnableVC, animated: true, completion: nil)
    }
    
    func jumpToWelcomeView(animated: Bool){
        let welcomeVC = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NavigationWelcomeViewController")as! NavigationWelcomeViewController
        self.presentViewController(welcomeVC, animated: animated, completion: nil)
    }
    
    func jumpToCommentPinDetail() {
        self.performSegueWithIdentifier("mapToCommentPinDetail", sender: self)
    }
    
    // To get opened pin list, but it is a general func
    func readByKey(key: String) -> AnyObject? {
        if let obj = self.storageForOpenedPinList.objectForKey(key) {
            return obj
        }
        return nil
    }
    
    // MARK: -- Load Navigation Items
    func loadTransparentNavBarItems() {
        self.navigationController?.navigationBar.hidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.navigationController?.navigationBar.translucent = true
    }
    
    // MARK: -- Load Map
    func loadMapView() {
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        self.faeMapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        faeMapView.delegate = self
        self.view = faeMapView
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        
        // Default is true, if true, panGesture could not be detected
        self.faeMapView.settings.consumesGesturesInView = false
    }
    
    // MARK: -- Map Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if willAppearFirstLoad {
            self.currentLocation = locManager.location
            self.currentLatitude = currentLocation.coordinate.latitude
            self.currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
            self.faeMapView.camera = camera
            self.willAppearFirstLoad = false
            self.startUpdatingLocation = true
            let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
            let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
            self.previousPosition = mapCenterCoordinate
            self.updateTimerForSelfLoc()
        }
        
        if userStatus == 5 {
            return
        }
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let selfPositionToPoint = faeMapView.projection.pointForCoordinate(position)
            myPositionOutsideMarker_3.center = selfPositionToPoint
            myPositionOutsideMarker_2.center = selfPositionToPoint
            myPositionOutsideMarker_1.center = selfPositionToPoint
            myPositionIcon.center = selfPositionToPoint
        }
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if openUserPinActive {
            self.hideOpenUserPinAnimation()
            openUserPinActive = false
        }
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        print("Cur-Zoom Level: \(mapView.camera.zoom)")
        print("Pre-Zoom Level: \(previousZoomLevel)")
        let directionMap = position.bearing
        let direction: CGFloat = CGFloat(directionMap)
        let angle:CGFloat = ((360.0 - direction) * 3.14/180.0) as CGFloat
        buttonToNorth.transform = CGAffineTransformMakeRotation(angle)
        if userStatus == 5 {
            self.faeMapView.myLocationEnabled = true
            if myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.hidden = true
            }
            if myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.hidden = true
            }
            if myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.hidden = true
            }
            if myPositionIcon != nil {
                self.myPositionIcon.hidden = true
            }
            return
        }
        if self.myPositionOutsideMarker_1 != nil {
            self.myPositionOutsideMarker_1.hidden = false
        }
        if self.myPositionOutsideMarker_2 != nil {
            self.myPositionOutsideMarker_2.hidden = false
        }
        if self.myPositionOutsideMarker_3 != nil {
            self.myPositionOutsideMarker_3.hidden = false
        }
        if self.myPositionIcon != nil {
            self.myPositionIcon.hidden = false
        }
        if startUpdatingLocation {
            currentLocation = locManager.location
            self.currentLatitude = currentLocation.coordinate.latitude
            self.currentLongitude = currentLocation.coordinate.longitude
            let position = CLLocationCoordinate2DMake(self.currentLatitude, self.currentLongitude)
            let selfPositionToPoint = faeMapView.projection.pointForCoordinate(position)
            myPositionOutsideMarker_3.center = selfPositionToPoint
            myPositionOutsideMarker_2.center = selfPositionToPoint
            myPositionOutsideMarker_1.center = selfPositionToPoint
            myPositionIcon.center = selfPositionToPoint
        }
        
        if mapView.camera.zoom < 13 {
            mapView.clear()
        }
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        let currentPosition = mapCenterCoordinate
        let curPosition = previousPosition
        self.previousPosition = currentPosition
        
        let currentZoomLevel = mapView.camera.zoom
        let preZoomLevel = previousZoomLevel
        self.previousZoomLevel = currentZoomLevel
        
        if currentZoomLevel >= 13 {
            if abs(currentZoomLevel-preZoomLevel) > 1 {
                print("DEBUG: Zoom level diff > 1")
                self.updateTimerForLoadRegionPin()
                self.updateTimerForSelfLoc()
                return
            }
            if curPosition != nil {
                if abs(currentPosition.latitude-curPosition.latitude) <= 0.03 {
                    return
                }
                if abs(currentPosition.longitude-curPosition.longitude) <= 0.03 {
                    return
                }
                print("DEBUG: Position diff > 0.03")
                mapView.clear()
                self.updateTimerForLoadRegionPin()
                self.updateTimerForSelfLoc()
            }
        }
        else {
            timerUpdateSelfLocation.invalidate()
            timerLoadRegionPins.invalidate()
            mapView.clear()
        }
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        self.renewSelfLocation()
        let latitude = marker.position.latitude
        let longitude = marker.position.longitude
        let camera = GMSCameraPosition.cameraWithLatitude(latitude+0.001, longitude: longitude, zoom: 17)
        mapView.animateToCameraPosition (camera)
        let pinLoc = JSON(marker.userData!)
        if let type = pinLoc["type"].string {
            if type == "user" {
                if let userid = pinLoc["user_id"].int {
                    self.currentViewingUserId = userid
                    loadUserPinInformation("\(userid)")
                }
                self.showOpenUserPinAnimation(latitude, longi: longitude)
                return true
            }
            if type == "comment" {
                if self.canOpenAnotherPin == false {
                    return true
                }
                self.canOpenAnotherPin = false
                var pinComment = JSON(marker.userData!)
                if let commentIDGet = pinComment["comment_id"].int {
                    commentIdToPassBySegue = commentIDGet
                    var openedPinListArray = [Int]()
                    openedPinListArray.append(commentIDGet)
                    marker.icon = UIImage(named: "markerCommentPinHeavyShadow")
                    marker.zIndex = 2
                    if let listArray = readByKey("openedPinList") {
                        openedPinListArray.removeAll()
                        openedPinListArray = listArray as! [Int]
                        if openedPinListArray.contains(commentIDGet) == false {
                            openedPinListArray.append(commentIDGet)
                        }
                        self.storageForOpenedPinList.setObject(openedPinListArray, forKey: "openedPinList")
                    }
                    self.storageForOpenedPinList.setObject(openedPinListArray, forKey: "openedPinList")
                }
                self.markerBackFromCommentDetail = marker
                self.jumpToCommentPinDetail()
                return true
            }
        }
        return true
    }
    
    // MARK: -- Animations
    
    func loadPositionAnimateImage() {
        if myPositionIconFirstLoaded {
            myPositionIconFirstLoaded = false
        }
        else {
            if myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.removeFromSuperview()
            }
            if myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.removeFromSuperview()
            }
            if myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.removeFromSuperview()
            }
            if myPositionIcon != nil {
                self.myPositionIcon.removeFromSuperview()
            }
        }
        if userStatus == 5 {
            self.faeMapView.myLocationEnabled = true
            if myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.hidden = true
            }
            if myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.hidden = true
            }
            if myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.hidden = true
            }
            if myPositionIcon != nil {
                self.myPositionIcon.hidden = true
            }
            return
        }
        else {
            self.faeMapView.myLocationEnabled = false
            if self.myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.hidden = false
            }
            if self.myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.hidden = false
            }
            if self.myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.hidden = false
            }
            if self.myPositionIcon != nil {
                self.myPositionIcon.hidden = false
            }
        }
        myPositionOutsideMarker_1 = UIImageView(frame: CGRectMake(screenWidth/2-12, screenHeight/2-12, 24, 24))
        myPositionOutsideMarker_2 = UIImageView(frame: CGRectMake(screenWidth/2-12, screenHeight/2-12, 24, 24))
        myPositionOutsideMarker_3 = UIImageView(frame: CGRectMake(screenWidth/2-12, screenHeight/2-12, 24, 24))
        self.view.addSubview(myPositionOutsideMarker_1)
        myPositionOutsideMarker_1.layer.zPosition = 0
        self.view.addSubview(myPositionOutsideMarker_2)
        myPositionOutsideMarker_2.layer.zPosition = 0
        self.view.addSubview(myPositionOutsideMarker_3)
        myPositionOutsideMarker_3.layer.zPosition = 0
        myPositionIcon = UIButton(frame: CGRectMake(screenWidth/2-12, screenHeight/2-20, 35, 35))
        //        myPositionIcon.addTarget(self, action: #selector(FaeMapViewController.showOpenUserPinAnimation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(myPositionIcon)
        myPositionIcon.layer.zPosition = 0
        myPositionAnimation()
    }
    
    func myPositionAnimation() {
        UIView.animateWithDuration(2.4, delay: 0, options: [.Repeat, .CurveEaseIn], animations: ({
            if self.myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.alpha = 0.0
                self.myPositionOutsideMarker_1.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
            }
        }), completion: nil)
        
        UIView.animateWithDuration(1.5, delay: 1.5, options: [.Repeat, .CurveEaseIn], animations: ({
            if self.myPositionOutsideMarker_1 != nil {
                
            }
        }), completion: nil)

        UIView.animateWithDuration(2.4, delay: 0.8, options: [.Repeat, .CurveEaseIn], animations: ({
            if self.myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.alpha = 0.0
                self.myPositionOutsideMarker_2.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
            }
        }), completion: nil)

        UIView.animateWithDuration(1.5, delay: 2.3, options: [.Repeat, .CurveEaseIn], animations: ({
            if self.myPositionOutsideMarker_2 != nil {
                
            }
        }), completion: nil)

        UIView.animateWithDuration(2.4, delay: 1.6, options: [.Repeat, .CurveEaseIn], animations: ({
            if self.myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.alpha = 0.0
                self.myPositionOutsideMarker_3.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
            }
        }), completion: nil)

        UIView.animateWithDuration(1.5, delay: 3.1, options: [.Repeat, .CurveEaseIn], animations: ({
            if self.myPositionOutsideMarker_3 != nil {
                
            }
        }), completion: nil)
    }
    
    func getSelfAccountInfo() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({(status: Int, message: AnyObject?) in
            let selfUserInfoJSON = JSON(message!)
            if let firstName = selfUserInfoJSON["first_name"].string {
                userFirstname = firstName
            }
            if let lastName = selfUserInfoJSON["last_name"].string {
                userLastname = lastName
            }
            if let birthday = selfUserInfoJSON["birthday"].string {
                userBirthday = birthday
            }
            if let gender = selfUserInfoJSON["gender"].string {
                userUserGender = gender
            }
            if let userName = selfUserInfoJSON["user_name"].string {
                userUserName = userName
            }
            if let miniAvatar = selfUserInfoJSON["mini_avatar"].int {
                if userStatus == 5 {
                    return 
                }
                userMiniAvatar = miniAvatar
                self.myPositionOutsideMarker_1.image = UIImage(named: "myPosition_outside")
                self.myPositionOutsideMarker_2.image = UIImage(named: "myPosition_outside")
                self.myPositionOutsideMarker_3.image = UIImage(named: "myPosition_outside")
                if let miniAvatar = userMiniAvatar {
                    self.myPositionIcon.setImage(UIImage(named: "avatar_\(miniAvatar+1)"), forState: .Normal)
                }
                else {
                    self.myPositionIcon.setImage(UIImage(named: "avatar_1"), forState: .Normal)
                }
            }
        })
    }
    
    func animateToCameraFromMainScreenSearch(coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 17)
        self.faeMapView.animateToCameraPosition(camera)
        self.updateTimerForLoadRegionPin()
    }
    
    func animateToCameraFromCommentPinDetailView(coordinate: CLLocationCoordinate2D, commentID: Int) {
        print("DEBUG: Delegate pass commentID")
        print(commentID)
        let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 17)
        self.markerBackFromCommentDetail.icon = UIImage(named: "comment_pin_marker")
        self.markerBackFromCommentDetail.zIndex = 0
        if let marker = self.mapCommentPinsDic[commentID] {
            self.markerBackFromCommentDetail = marker
            marker.icon = UIImage(named: "markerCommentPinHeavyShadow")
            marker.zIndex = 2
            self.commentIDFromOpenedPinCell = -999
        }
        else {
            self.commentIDFromOpenedPinCell = commentID
            self.updateTimerForLoadRegionPin()
        }
        self.faeMapView.animateToCameraPosition(camera)
    }
    
    func renewSelfLocation() {
        if currentLocation != nil {
            let selfLocation = FaeMap()
            selfLocation.whereKey("geo_latitude", value: "\(currentLatitude)")
            selfLocation.whereKey("geo_longitude", value: "\(currentLongitude)")
            selfLocation.renewCoordinate {(status: Int, message: AnyObject?) in
                if status/100 == 2 {
                    print("Successfully renew self position")
                }
                else {
                    print("fail to renew self position")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
