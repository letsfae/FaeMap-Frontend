//
//  FaeMapViewController.swift
//  GoogleMapsSample
//
//  Created by Yue on 5/31/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftyJSON

class FaeMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
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
    
    // MARK: -- Blur View Pin Buttons and Labels
//    var uiviewPinSelections: UIView!
//    var blurViewMap: UIVisualEffectView!
//    var buttonMedia: UIButton!
//    var buttonChats: UIButton!
//    var buttonComment: UIButton!
//    var buttonEvent: UIButton!
//    var buttonFaevor: UIButton!
//    var buttonNow: UIButton!
//    var buttonJoinMe: UIButton!
//    var buttonSell: UIButton!
//    var buttonLive: UIButton!
//    
//    var labelSubmitTitle: UILabel!
//    var labelSubmitMedia: UILabel!
//    var labelSubmitChats: UILabel!
//    var labelSubmitComment: UILabel!
//    var labelSubmitEvent: UILabel!
//    var labelSubmitFaevor: UILabel!
//    var labelSubmitNow: UILabel!
//    var labelSubmitJoinMe: UILabel!
//    var labelSubmitSell: UILabel!
//    var labelSubmitLive: UILabel!
    var labelUnreadMessages: UILabel!
    
    var buttonClosePinBlurView: UIButton!
    var buttonCommentSubmit: UIButton!
        
    // MARK: -- Create Comment Pin
    var uiviewCreateCommentPin: UIView!
    var labelSelectLocationContent: UILabel!
    var textViewForCommentPin: UITextView!
    var lableTextViewPlaceholder: UILabel!
    
    // MARK: -- Create Pin
    var imagePinOnMap: UIImageView!
    var buttonSetLocationOnMap: UIButton!
    var isInPinLocationSelect = false
    let colorPlaceHolder = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    
    // MARK: -- My Position Marker
    var myPositionIcon: UIButton!
    var myPositionOutsideMarker_1: UIImageView!
    var myPositionOutsideMarker_2: UIImageView!
    var myPositionOutsideMarker_3: UIImageView!
    
    // MARK: -- Search Bar
    var uiviewTableSubview: UIView!
    var tblSearchResults = UITableView()
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var customSearchController: CustomSearchController!
    var searchBarSubview: UIView!
    var placeholder = [GMSAutocompletePrediction]()
    
    var myPositionIconFirstLoaded = true
    
    // MARK: -- Drag map and refresh pins
    var originPointForRefresh: CLLocationCoordinate2D!
    var originPointForRefreshFirstLoad = true
    
    // MARK: -- Comment Pin Cell
    var commentPinCellNumCount = 0
    var buttonShareOnCommentDetail: UIButton!
    var buttonSaveOnCommentDetail: UIButton!
    var buttonReportOnCommentDetail: UIButton!
    var commentPinAvoidDic = [Int: Int]()
    
    // MARK: -- More Button Vars
    var uiviewMoreButton: UIView!
    var dimBackgroundMoreButton: UIButton!
    
    // MARK: -- WindBell Vars
    var uiviewWindBell: UIView!
    var dimBackgroundWindBell: UIButton!
    
    // MARK: -- Main Screen Search
    var mainScreenSearchBarSubview: UIView!
    var mainSearchController: CustomSearchController!
    var blurViewMainScreenSearch: UIVisualEffectView!
    var mainScreenSearchActive = false
    var mainScreenSearchSubview: UIButton!
    var middleTopActive = false
    var buttonClearMainSearch: UIButton!
    
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
    
    var tableWindbellData = [["Title":"New Comment on your Pin","Content":"Wanna come over to bbq later today?","Time":"Just Now"],["Title":"New Faevors near you!","Content":"Help out others and start earning!","Time":"Just Now"],["Title":"5 likes on your Pin","Content":"Comment and talk to your fans!","Time":"Today - 9:25am"],["Title":"New Pins around you!","Content":"See what your community is up to!","Time":"Yesterday - 3:30pm"],["Title":"New Pins around you!","Content":"See what your community is up to!","Time":"Yesterday - 3:30pm"],["Title":"New Pins around you!","Content":"See what your community is up to!","Time":"Yesterday - 3:30pm"],["Title":"New Pins around you!","Content":"See what your community is up to!","Time":"Yesterday - 3:30pm"]]
    
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
    
    // Map User Pin
    var mapUserPinsDic = [Int: GMSMarker]()
    
    // New Comment Pin Popup Window
    
    var commentIdToPassBySegue: Int = -999
    
    // Comment on pin input toolbar
//    var commentInputToolbar: JSQMessagesInputToolbarCustom!
    
    var tempMarker: UIImageView! // temp marker, it is a UIImageView
    var markerMask: UIView! // mask to prevent UI action
    
    var NSTimerDisplayMarkerArray = [NSTimer]()
    
    // System Functions
    
    @IBAction func unwindToFaeMap(sender: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        let shareAPI = LocalStorageManager()
        shareAPI.readLogInfo()
        if is_Login == 0 {
            self.jumpToWelcomeView()
        }
        self.navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1 )
        myPositionIconFirstLoaded = true
        
        loadMapView()
        loadTransparentNavBarItems()
        loadButton()
        loadMore()
//        loadWindBell()  // <-- This one isn't used for 11.01 Dev Version
        loadMainScreenSearch()
        loadNamecard()
        loadPositionAnimateImage()
//        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(FaeMapViewController.updateSelfLocation), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
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
        print("Will appear loaded")
        actionSelfPosition(buttonSelfPosition)
    }
    
    override func viewDidAppear(animated: Bool) {
        
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
            }
        }
    }
    
    // MARK: -- 如何存到缓存中以备后面继续使用
    func loadCurrentRegionPins() {
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "5000")
        loadPinsByZoomLevel.whereKey("type", value: "comment")
        loadPinsByZoomLevel.getMapInformation{(status:Int, message:AnyObject?) in
            let mapInfoJSON = JSON(message!)
            for eachTimer in self.NSTimerDisplayMarkerArray {
                eachTimer.invalidate()
            }
            self.NSTimerDisplayMarkerArray.removeAll()
            if mapInfoJSON.count > 0 {
                for i in 0...(mapInfoJSON.count-1) {
                    let pinShowOnMap = GMSMarker()
                    pinShowOnMap.zIndex = 1
                    var pinData = [String: AnyObject]()
                    if let typeInfo = mapInfoJSON[i]["type"].string {
                        pinData["type"] = typeInfo
                        if typeInfo == "comment" {
                            pinShowOnMap.icon = UIImage(named: "comment_pin_marker")
                        }
                    }
                    if let commentIDInfo = mapInfoJSON[i]["comment_id"].int {
                        pinData["comment_id"] = commentIDInfo
                    }
                    if let userIDInfo = mapInfoJSON[i]["user_id"].int {
                        pinData["user_id"] = userIDInfo
                    }
                    if let createdTimeInfo = mapInfoJSON[i]["created_at"].string {
                        pinData["created_at"] = createdTimeInfo
                    }
                    if let contentInfo = mapInfoJSON[i]["content"].string {
                        pinData["content"] = contentInfo
                    }
                    if let latitudeInfo = mapInfoJSON[i]["geolocation"]["latitude"].double {
                        pinData["latitude"] = latitudeInfo
                        pinShowOnMap.position.latitude = latitudeInfo
                    }
                    if let longitudeInfo = mapInfoJSON[i]["geolocation"]["longitude"].double {
                        pinData["longitude"] = longitudeInfo
                        pinShowOnMap.position.longitude = longitudeInfo
                    }
                    if let isLiked = mapInfoJSON[i]["user_pin_operations"]["is_liked"].bool {
                        pinData["is_liked"] = isLiked
                    }
                    if let likedTimestamp = mapInfoJSON[i]["user_pin_operations"]["liked_timestamp"].string {
                        pinData["liked_timestamp"] = likedTimestamp
                    }
                    if let isSaved = mapInfoJSON[i]["user_pin_operations"]["is_saved"].bool {
                        pinData["is_saved"] = isSaved
                    }
                    if let savedTimestamp = mapInfoJSON[i]["user_pin_operations"]["saved_timestamp"].string {
                        pinData["saved_timestamp"] = savedTimestamp
                    }
                    
                    pinShowOnMap.userData = pinData
//                    pinShowOnMap.appearAnimation = kGMSMarkerAnimationPop
//                    pinShowOnMap.map = self.faeMapView
                    let delay: Double = Double(arc4random_uniform(50) + 25) / 100
                    let infoDict : [String : AnyObject] = ["argumentInt": pinShowOnMap]
                    let timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(delay), target: self, selector: #selector(FaeMapViewController.functionHereWithArgument(_:)), userInfo: infoDict, repeats: false)
                    self.NSTimerDisplayMarkerArray.append(timer)
                }
            }
        }
    }
    
    func functionHereWithArgument(timer: NSTimer) {
        if let userInfo = timer.userInfo as? Dictionary<String, AnyObject> {
            let marker = userInfo["argumentInt"] as! GMSMarker
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.groundAnchor = CGPointMake(0.5, 1)
            marker.map = self.faeMapView
        }
    }
    
    // Void function for NSTimer, nothing will be conducted
    func nothinghere() {
        
    }
    
    func jumpToLocationEnable(){
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("EnableLocationViewController")as! EnableLocationViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func jumpToWelcomeView(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NavigationWelcomeViewController")as! NavigationWelcomeViewController
        //        self.navigationController?.pushViewController(vc, animated: true)
        //        let vc = ViewController(nibName: "WelcomeViewController", bundle: nil)
        self.presentViewController(vc, animated: true, completion: nil)
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
        faeMapView.myLocationEnabled = false
        faeMapView.delegate = self
        self.view = faeMapView
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        
        imagePinOnMap = UIImageView(frame: CGRectMake(screenWidth/2-19, screenHeight/2-41, 46, 50))
        imagePinOnMap.image = UIImage(named: "comment_pin_image")
        imagePinOnMap.hidden = true
        
        // Default is true, if true, panGesture could not be detected
        self.faeMapView.settings.consumesGesturesInView = false
    }
    
    // MARK: -- Map Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if willAppearFirstLoad {
            currentLocation = locManager.location
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
            faeMapView.camera = camera
            willAppearFirstLoad = false
            startUpdatingLocation = true
            updateSelfLocation()
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
            hideOpenUserPinAnimation()
            openUserPinActive = false
        }
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        let directionMap = position.bearing
        let direction: CGFloat = CGFloat(directionMap)
        let angle:CGFloat = ((360.0 - direction) * 3.14/180.0) as CGFloat
        buttonToNorth.transform = CGAffineTransformMakeRotation(angle)
        
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
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        var mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        var mapCenterCoordinate = mapView.projection.coordinateForPoint(mapCenter)
        if originPointForRefreshFirstLoad {
            originPointForRefresh = mapCenterCoordinate
            originPointForRefreshFirstLoad = false
            loadCurrentRegionPins()
            updateSelfLocation()
        }
        
        if isInPinLocationSelect {
            self.faeMapView.clear()
            mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
            mapCenterCoordinate = mapView.projection.coordinateForPoint(mapCenter)
            GMSGeocoder().reverseGeocodeCoordinate(mapCenterCoordinate, completionHandler: {
                (response, error) -> Void in
                if let fullAddress = response?.firstResult()?.lines {
                    var addressToSearchBar = ""
                    for line in fullAddress {
                        if line == "" {
                            continue
                        }
                        else if fullAddress.indexOf(line) == fullAddress.count-1 {
                            addressToSearchBar += line + ""
                        }
                        else {
                            addressToSearchBar += line + ", "
                        }
                    }
                    self.customSearchController.customSearchBar.text = addressToSearchBar
                }
                self.latitudeForPin = mapCenterCoordinate.latitude
                self.longitudeForPin = mapCenterCoordinate.longitude
            })
        }
        
        if mapView.camera.zoom >= 13 {
            let radius = sqrt(pow(mapCenterCoordinate.latitude-originPointForRefresh.latitude, 2.0)+pow(mapCenterCoordinate.longitude-originPointForRefresh.longitude, 2.0))
            if radius > 0.04 {
                mapView.clear()
                originPointForRefresh = mapCenterCoordinate
                loadCurrentRegionPins()
                updateSelfLocation()
            }
        }
        else {
            originPointForRefreshFirstLoad = true
            mapView.clear()
        }
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        let latitude = marker.position.latitude
        let longitude = marker.position.longitude
        let camera = GMSCameraPosition.cameraWithLatitude(latitude+0.001, longitude: longitude, zoom: 17)
        mapView.animateToCameraPosition (camera)
        let pinLoc = JSON(marker.userData!)
        if let type = pinLoc["type"].string {
            if type == "user" {
                
                if let userid = pinLoc["user_id"].int {
                    loadUserPinInformation("\(userid)")
                }
                showOpenUserPinAnimation(latitude, longi: longitude)
                return true
            }
            if type == "comment" {
                var pinData = JSON(marker.userData!)
                if let commentIDGet = pinData["comment_id"].int {
                    commentIdToPassBySegue = commentIDGet
                }
                self.jumpToCommentPinDetail()
                return true
            }
        }
        return true
    }
    
    func jumpToCommentPinDetail() {
        self.performSegueWithIdentifier("mapToCommentPinDetail", sender: self)
    }
    
    // MARK: -- Animations
    
    func loadPositionAnimateImage() {
        if myPositionIconFirstLoaded {
            myPositionIconFirstLoaded = false
        }
        else {
            myPositionOutsideMarker_1.removeFromSuperview()
            myPositionOutsideMarker_2.removeFromSuperview()
            myPositionOutsideMarker_3.removeFromSuperview()
            myPositionIcon.removeFromSuperview()
        }
        myPositionOutsideMarker_1 = UIImageView(frame: CGRectMake(screenWidth/2, screenHeight/2, 0, 0))
        self.myPositionOutsideMarker_1.alpha = 1.0
        self.view.addSubview(myPositionOutsideMarker_1)
        myPositionOutsideMarker_1.layer.zPosition = 0
        myPositionOutsideMarker_2 = UIImageView(frame: CGRectMake(screenWidth/2, screenHeight/2, 0, 0))
        self.myPositionOutsideMarker_2.alpha = 1.0
        self.view.addSubview(myPositionOutsideMarker_2)
        myPositionOutsideMarker_2.layer.zPosition = 0
        myPositionOutsideMarker_3 = UIImageView(frame: CGRectMake(screenWidth/2, screenHeight/2, 0, 0))
        self.myPositionOutsideMarker_3.alpha = 1.0
        self.view.addSubview(myPositionOutsideMarker_3)
        myPositionOutsideMarker_3.layer.zPosition = 0
        myPositionIcon = UIButton(frame: CGRectMake(screenWidth/2-12, screenHeight/2-20, 35, 35))
        //        myPositionIcon.addTarget(self, action: #selector(FaeMapViewController.showOpenUserPinAnimation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(myPositionIcon)
        myPositionIcon.layer.zPosition = 0
        myPositionAnimation()
    }
    
    func myPositionAnimation() {
        UIView.animateWithDuration(3, delay: 0, options: .Repeat, animations: ({
            if self.myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
                self.myPositionOutsideMarker_1.alpha = 0.0
            }
        }), completion: nil)
        UIView.animateWithDuration(3, delay: 0.8, options: .Repeat, animations: ({
            if self.myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
                self.myPositionOutsideMarker_2.alpha = 0.0
            }
        }), completion: nil)
        UIView.animateWithDuration(3, delay: 1.6, options: .Repeat, animations: ({
            if self.myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
                self.myPositionOutsideMarker_3.alpha = 0.0
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
