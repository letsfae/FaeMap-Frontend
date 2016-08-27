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

class FaeMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: -- Common Used Vars and Constants
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let navigationBarHeight : CGFloat = 20
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    // MARK: -- Map main screen Objects
    var faeMapView: GMSMapView!
    var buttonLeftTop: UIButton!
    var buttonMiddleTop: UIButton!
    var buttonRightTop: UIButton!
    var buttonToNorth: UIButton!
    var buttonSelfPosition: UIButton!
    var buttonChatOnMap: UIButton!
    var buttonPinOnMap: UIButton!
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
    var uiviewPinSelections: UIView!
    var blurViewMap: UIVisualEffectView!
    var buttonMedia: UIButton!
    var buttonChats: UIButton!
    var buttonComment: UIButton!
    var buttonEvent: UIButton!
    var buttonFaevor: UIButton!
    var buttonNow: UIButton!
    var buttonJoinMe: UIButton!
    var buttonClearAllMyPin: UIButton!
    var buttonIcons: UIButton!
    
    var labelSubmitTitle: UILabel!
    var labelSubmitMedia: UILabel!
    var labelSubmitChats: UILabel!
    var labelSubmitComment: UILabel!
    var labelSubmitEvent: UILabel!
    var labelSubmitFaevor: UILabel!
    var labelSubmitNow: UILabel!
    var labelSubmitJoinMe: UILabel!
    var labelSubmitSell: UILabel!
    var labelSubmitIcons: UILabel!
    
    var buttonClosePinBlurView: UIButton!
    var buttonCommentSubmit: UIButton!
    
    // MARK: -- Create Comment Pin
    var uiviewCreateCommentPin: UIView!
    var labelSelectLocationContent: UILabel!
    
    // MARK: -- Create Pin
    var imagePinOnMap: UIImageView!
    var buttonSetLocationOnMap: UIButton!
    var isInPinLocationSelect = false
    
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
    
    // MARK: -- Custom Scrollable TextFields
    let colorPlaceHolder = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    
    var uiviewArray = [CustomUIViewForScrollableTextField]()
    var textFieldArray = [UITextField]()
    var borderArray = [UIView]()
    
    var exist1stLine = false
    var exist4thLine = false
    
    var token = true
    
    var myPositionIconFirstLoaded = true
    
    // MARK: -- Drag map and refresh pins
    var originPointForRefresh: CLLocationCoordinate2D!
    var originPointForRefreshFirstLoad = true
    
    // MARK: -- Comment Pin Cell
    var commentPinBlurView: UIVisualEffectView!
    var commentPinCellNumCount = 0
    var commentPinUIViewArray = [CommentPinUIView]()
    var scrollViewForCommentPinArray: UIScrollView!
    var commentPinCellGroupHeight: CGFloat = 0
    var buttonCommentLike: UIButton!
    var buttonAddComment: UIButton!
    var expandedCommentPinCellTag = -999
    var moreButtonDetailSubview: UIImageView!
    var buttonShareOnCommentDetail: UIButton!
    var buttonSaveOnCommentDetail: UIButton!
    var buttonReportOnCommentDetail: UIButton!
    var buttonMoreOnCommentCellExpanded = false
    var commentPinCellsOpen = false
    var commentPinAvoidDic = [Int: Int]()
    
    // MARK: -- More Button Vars
    var uiviewMoreButton: UIView!
    var dimBackgroundMoreButton: UIButton!
    
    // MARK: -- WindBell Vars
    var uiviewWindBell: UIView!
    var dimBackgroundWindBell: UIButton!
    
    // MARK: -- Main Screen Search
    var blurViewMainScreenSearch: UIVisualEffectView!
    var mainScreenSearchActive = false
    var mainScreenSearchSubview: UIButton!
    var middleTopActive = false
    
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
    
    // Windbell table view
    var labelWindbellTableTitle: UILabel!
    var tableviewWindbell = UITableView()
    
    var tableWindbellData = [["Title":"New Comment on your Pin","Content":"Wanna come over to bbq later today?","Time":"Just Now"],["Title":"New Faevors near you!","Content":"Help out others and start earning!","Time":"Just Now"],["Title":"5 likes on your Pin","Content":"Comment and talk to your fans!","Time":"Today - 9:25am"],["Title":"New Pins around you!","Content":"See what your community is up to!","Time":"Yesterday - 3:30pm"],["Title":"New Pins around you!","Content":"See what your community is up to!","Time":"Yesterday - 3:30pm"],["Title":"New Pins around you!","Content":"See what your community is up to!","Time":"Yesterday - 3:30pm"],["Title":"New Pins around you!","Content":"See what your community is up to!","Time":"Yesterday - 3:30pm"]]
    
    // Open User Pin View
    var uiviewDialog : UIView!
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
    var imageview : UIImageView!
    var imageviewNamecardAvatar : UIImageView!
    var imageviewNamecardGender : UIImageView!
    var labelNamecardName : UILabel!
    var labelNamecardDescription : UILabel!
    var viewLine : UIView!
    var collectionPhotos : UICollectionView!
    var buttonChat : UIButton!
    var buttonMore : UIButton!
    
    let tagName = ["Single", "HMU", "I do Favors"]
    var tagButtonSet = [UIButton]()
    var selectedButtonSet = [UIButton]()
    var tagLength = [CGFloat]()
    var tagColor = [UIColor]()
    var tagTitle = [NSMutableAttributedString]()
    let exlength : CGFloat = 8
    let selectedInterval : CGFloat = 11
    let maxLength : CGFloat = 360
    let lineInterval : CGFloat = 25.7
    let intervalInLine : CGFloat = 13.8
    let tagHeight : CGFloat = 18
    
    var openUserPinActive = false
    
    // Map User Pin
    var mapUserPinsDic = [Int: GMSMarker]()
    
    // System Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = FaeUser()
        user.whereKey("email", value: "user9@email.com")
        user.whereKey("password", value: "A1234567")
        user.logInBackground({(status:Int, error:AnyObject?) in 
            print(status)
            if status / 100 == 2 {
                print("login success")
            }
            }
        )
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
        loadBlurAndPinSelection()
        loadMore()
        loadWindBell()
        loadMainScreenSearch()
        loadTableView()
        configureCustomSearchController()
        loadMapChat()
        loadNamecard()
        
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(FaeMapViewController.updateSelfLocation), userInfo: nil, repeats: true)
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
        
        loadPositionAnimateImage()
        self.buttonLeftTop.hidden = false
        self.buttonMiddleTop.hidden = false
        self.buttonRightTop.hidden = false
        loadTransparentNavBarItems()
    }
    override func viewWillDisappear(animated: Bool) {
        self.buttonLeftTop.hidden = true
        self.buttonMiddleTop.hidden = true
        self.buttonRightTop.hidden = true
        self.commentPinUIViewArray.removeAll()
        if self.commentPinBlurView != nil {
            self.commentPinBlurView.removeFromSuperview()
            self.commentPinCellNumCount = 0
        }
        self.navigationController!.navigationBar.translucent = false
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
        loadPinsByZoomLevel.getMapInformation{(status:Int,message:AnyObject?) in
            print("获取地图数据：")
            let mapInfoJSON = JSON(message!)
            if mapInfoJSON.count > 0 {
                for i in 0...(mapInfoJSON.count-1) {
                    let pinShowOnMap = GMSMarker()
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
                    pinShowOnMap.userData = pinData
                    pinShowOnMap.appearAnimation = kGMSMarkerAnimationPop
                    pinShowOnMap.map = self.faeMapView
                }
            }
        }
    }
    
    func nothinghere() {
        
    }
    
    func jumpToLocationEnable(){
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("LocationEnableViewController")as! LocationEnableViewController
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
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.navigationController!.navigationBar.translucent = true
    }
    
    // MARK: -- Load Map
    
    func loadMapView() {
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        faeMapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        faeMapView.myLocationEnabled = false
        faeMapView.delegate = self
        self.view = faeMapView
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        
        imagePinOnMap = UIImageView(frame: CGRectMake(screenWidth/2-19, screenHeight/2-41, 46, 50))
        imagePinOnMap.image = UIImage(named: "comment_pin_image")
        imagePinOnMap.hidden = true
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
        print("You taped at Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
        customSearchController.customSearchBar.endEditing(true)
        if commentPinCellsOpen {
            hideCommentPinCells()
            commentPinCellsOpen = false
        }
        if buttonMoreOnCommentCellExpanded {
            hideCommentPinMoreButtonDetails()
        }
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
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = mapView.projection.coordinateForPoint(mapCenter)
        print("Map Zoom Level: \(faeMapView.camera.zoom)")
        if originPointForRefreshFirstLoad {
            originPointForRefresh = mapCenterCoordinate
            originPointForRefreshFirstLoad = false
            loadCurrentRegionPins()
            updateSelfLocation()
        }
        
        if isInPinLocationSelect {
            self.faeMapView.clear()
            let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
            let mapCenterCoordinate = mapView.projection.coordinateForPoint(mapCenter)
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
        //        let camera = GMSCameraPosition.cameraWithLatitude(latitude+0.001, longitude: longitude, zoom: faeMapView.camera.zoom)
        //        faeMapView.animateToCameraPosition(camera)
        let pinLoc = JSON(marker.userData!)
        if let type = pinLoc["type"].string {
            if type == "user" {
                showOpenUserPinAnimation(latitude, longi: longitude)
                if let userid = marker.userData!["user_id"] {
                    print(userid)
                }
                return true
            }
            if type == "comment" {
                let pinData = JSON(marker.userData!)
                
                var commentID = -999
                if let commentIDGet = pinData["comment_id"].int {
                    commentID = commentIDGet
                    if self.commentPinAvoidDic[commentID] != nil {
                        print("Comment exists!")
                        print(self.commentPinAvoidDic)
                        if let rowNum = self.commentPinAvoidDic[commentID] {
                            print(rowNum)
                            // 列表被收回
                            //                            if self.commentPinCellsOpen == false {
                            //                                self.showCommentPinCells()
                            //                                // 如果当前没有任何pin cell被展开：
                            //                                if expandedCommentPinCellTag == -999 {
                            //                                    self.actionExpandCommentPinCell(self.commentPinUIViewArray[rowNum].buttonCommentPinLargerCover)
                            //                                }
                            //                                // 如果当前有pin cell被展开：
                            //                                else {
                            //                                    self.actionExpandCommentPinCellSpecialUse(rowNum)
                            //                                }
                            //                                // 未展开应该展开的PinCell，因此出现了差错。
                            //                                self.commentPinUIViewArray[rowNum].buttonDeleteLargerCover.hidden = true
                            //                                self.commentPinUIViewArray[rowNum].buttonMoreLargerCover.hidden = false
                            //                                self.commentPinUIViewArray[rowNum].buttonDelete.alpha = 0.0
                            //                                self.commentPinUIViewArray[rowNum].buttonMore.alpha = 1.0
                            //                                print(self.commentPinUIViewArray[rowNum].textViewComment.text)
                            //                                self.expandedCommentPinCellTag = rowNum
                            //                                print("rowNum is:")
                            //                                print(rowNum)
                            //                                if rowNum == self.commentPinUIViewArray.count-1 {
                            //                                    self.commentPinBlurView.frame.size.height = 248
                            //                                }
                            //                                else if rowNum == self.commentPinUIViewArray.count-2 {
                            //                                    self.commentPinBlurView.frame.size.height = 248 + 78
                            //                                }
                            //                                else {
                            //                                    let blurViewHeight = 248.0 + Double(self.commentPinUIViewArray.count-1)*78.0
                            //                                    self.commentPinBlurView.frame.size.height = CGFloat(blurViewHeight)
                            //                                }
                            //                            }
                        }
                        //                        return true
                    }
                }
                
                if commentPinCellsOpen == false {
                    showCommentPinCells()
                }
                
                commentPinCellsOpen = true
                
                let uiviewCommentPin = CommentPinUIView()
                uiviewCommentPin.clipsToBounds = true
                commentPinUIViewArray.append(uiviewCommentPin)
                uiviewCommentPin.buttonCommentPinLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionExpandCommentPinCell(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                uiviewCommentPin.buttonDeleteLargerCover.addTarget(self, action: #selector(FaeMapViewController.deleteOneCellAndMoveOtherCommentCellsUp(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                uiviewCommentPin.buttonMoreLargerCover.addTarget(self, action: #selector(FaeMapViewController.showCommentPinMoreButtonDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                uiviewCommentPin.commentID = commentID
                
                if let name = pinData["user_id"].int {
                    uiviewCommentPin.labelTitle.text = "\(name)"
                }
                if let time = pinData["created_at"].string {
                    uiviewCommentPin.labelDes.text = "\(time)"
                }
                if let content = pinData["content"].string {
                    uiviewCommentPin.textViewComment.text = "\(content)"
                }
                
                if commentPinCellNumCount >= 3 {
                    //            先shrink之前的cell if there is one
                    self.shrinkExpandedCommentCell(expandedCommentPinCellTag)
                    
                    let cellAtHeight = (CGFloat)(commentPinCellNumCount * 78)
                    scrollViewForCommentPinArray.addSubview(uiviewCommentPin)
                    scrollViewForCommentPinArray.contentSize.height += 228
                    UIView.animateWithDuration(0.2, animations:({
                        //                if some cell expanded, += 150
                        //                else, += 0
                        if self.expandedCommentPinCellTag == -999 {
                            self.commentPinBlurView.frame.size.height = 248
                        }
                        else {
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDeleteLargerCover.hidden = false
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMoreLargerCover.hidden = true
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDelete.alpha = 1.0
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMore.alpha = 0.0
                            self.commentPinBlurView.frame.size.height += 0
                        }
                        uiviewCommentPin.uiviewUnderLine.center.y += 150
                        uiviewCommentPin.frame = CGRect(x: 0, y: cellAtHeight, width: self.screenWidth, height: 228)
                        self.commentPinBlurView.frame.size.height = 248
                    }), completion: { (done: Bool) in
                        if done {
                            self.showCommentPinCellDetails(uiviewCommentPin)
                        }
                    })
                    
                    self.addTagToCommentPinCell(uiviewCommentPin, commentID: commentID)
                    commentPinCellNumCount += 1
                    
                    let bottomPoint = CGPointMake(0, cellAtHeight)
                    self.scrollViewForCommentPinArray.setContentOffset(bottomPoint, animated: false)
                    commentPinCellGroupHeight = 254
                }
                
                if commentPinCellNumCount == 2 {
                    //            先shrink之前的cell if there is one
                    self.shrinkExpandedCommentCell(expandedCommentPinCellTag)
                    scrollViewForCommentPinArray.addSubview(uiviewCommentPin)
                    scrollViewForCommentPinArray.contentSize.height += 228
                    scrollViewForCommentPinArray.frame.size.height += 150
                    UIView.animateWithDuration(0.2, animations:({
                        //                if some cell expanded, += 150
                        //                else, += 0
                        if self.expandedCommentPinCellTag == -999 {
                            self.commentPinBlurView.frame.size.height = 248
                        }
                        else {
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDeleteLargerCover.hidden = false
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMoreLargerCover.hidden = true
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDelete.alpha = 1.0
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMore.alpha = 0.0
                            self.commentPinBlurView.frame.size.height += 0
                        }
                        uiviewCommentPin.uiviewUnderLine.center.y += 150
                        uiviewCommentPin.frame = CGRect(x: 0, y: 156, width: self.screenWidth, height: 228)
                        self.commentPinBlurView.frame.size.height = 248
                    }), completion: { (done: Bool) in
                        if done {
                            self.showCommentPinCellDetails(uiviewCommentPin)
                        }
                    })
                    self.addTagToCommentPinCell(uiviewCommentPin, commentID: commentID)
                    commentPinCellNumCount += 1
                    commentPinCellGroupHeight = 254
                    let bottomPoint = CGPointMake(0, 156)
                    self.scrollViewForCommentPinArray.setContentOffset(bottomPoint, animated: false)
                }
                
                if commentPinCellNumCount == 1 {
                    //            先shrink之前的cell
                    self.shrinkExpandedCommentCell(expandedCommentPinCellTag)
                    scrollViewForCommentPinArray.addSubview(uiviewCommentPin)
                    scrollViewForCommentPinArray.contentSize.height += 228
                    scrollViewForCommentPinArray.frame.size.height += 150
                    UIView.animateWithDuration(0.2, animations:({
                        //                if some cell expanded, += 150
                        //                else, += 0
                        if self.expandedCommentPinCellTag == -999 {
                            self.commentPinBlurView.frame.size.height += 150
                        }
                        else {
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDeleteLargerCover.hidden = false
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMoreLargerCover.hidden = true
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDelete.alpha = 1.0
                            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMore.alpha = 0.0
                            self.commentPinBlurView.frame.size.height += 0
                        }
                        uiviewCommentPin.uiviewUnderLine.center.y += 150
                        uiviewCommentPin.frame = CGRect(x: 0, y: 78, width: self.screenWidth, height: 228)
                        self.commentPinBlurView.frame.size.height = 248
                    }), completion: { (done: Bool) in
                        if done {
                            self.showCommentPinCellDetails(uiviewCommentPin)
                        }
                    })
                    self.addTagToCommentPinCell(uiviewCommentPin, commentID: commentID)
                    commentPinCellNumCount += 1
                    commentPinCellGroupHeight = 176
                    let bottomPoint = CGPointMake(0, 78)
                    self.scrollViewForCommentPinArray.setContentOffset(bottomPoint, animated: false)
                }
                
                if commentPinCellNumCount == 0 {
                    scrollViewForCommentPinArray = UIScrollView(frame: CGRectMake(0, 20, screenWidth, 228))
                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                    commentPinBlurView = UIVisualEffectView(effect:blurEffect)
                    commentPinBlurView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 0)
                    
                    commentPinBlurView.addSubview(scrollViewForCommentPinArray)
                    scrollViewForCommentPinArray.addSubview(uiviewCommentPin)
                    scrollViewForCommentPinArray.contentSize.height = 228
                    scrollViewForCommentPinArray.scrollEnabled = false
                    scrollViewForCommentPinArray.clipsToBounds = true
                    self.view.addSubview(commentPinBlurView)
                    
                    commentPinBlurView.layer.zPosition = 1
                    self.navigationController?.navigationBar.hidden = true
                    UIView.animateWithDuration(0.2, animations:({
                        self.commentPinBlurView.frame.size.height = 248
                        uiviewCommentPin.frame.size.height = 228
                        uiviewCommentPin.uiviewUnderLine.center.y += 150
                    }), completion: { (done: Bool) in
                        if done {
                            self.showCommentPinCellDetails(uiviewCommentPin)
                        }
                    })
                    self.addTagToCommentPinCell(uiviewCommentPin, commentID: commentID)
                    commentPinCellNumCount += 1
                    commentPinCellGroupHeight = 98
                }
                print("Add!")
                print("Where is comment cell blur view:")
                print(self.commentPinBlurView.center.y)
                return true
            }
        }
        return true
    }
    
    func showCommentPinMoreButtonDetails(sender: UIButton!) {
        print("DEBUG: ")
        if buttonMoreOnCommentCellExpanded == false {
            moreButtonDetailSubview = UIImageView(frame: CGRectMake(400, 70, 0, 0))
            moreButtonDetailSubview.image = UIImage(named: "moreButtonDetailSubview")
            UIApplication.sharedApplication().keyWindow?.addSubview(moreButtonDetailSubview)
            buttonShareOnCommentDetail = UIButton(frame: CGRectMake(0, 0, 0, 0))
            buttonShareOnCommentDetail.setImage(UIImage(named: "buttonShareOnCommentDetail"), forState: .Normal)
            moreButtonDetailSubview.addSubview(buttonShareOnCommentDetail)
            buttonShareOnCommentDetail.clipsToBounds = true
            buttonShareOnCommentDetail.alpha = 0.0
            buttonSaveOnCommentDetail = UIButton(frame: CGRectMake(0, 0, 0, 0))
            buttonSaveOnCommentDetail.setImage(UIImage(named: "buttonSaveOnCommentDetail"), forState: .Normal)
            moreButtonDetailSubview.addSubview(buttonSaveOnCommentDetail)
            buttonSaveOnCommentDetail.clipsToBounds = true
            buttonSaveOnCommentDetail.alpha = 0.0
            buttonReportOnCommentDetail = UIButton(frame: CGRectMake(0, 0, 0, 0))
            buttonReportOnCommentDetail.setImage(UIImage(named: "buttonReportOnCommentDetail"), forState: .Normal)
            moreButtonDetailSubview.addSubview(buttonReportOnCommentDetail)
            buttonReportOnCommentDetail.clipsToBounds = true
            buttonReportOnCommentDetail.alpha = 0.0
            UIView.animateWithDuration(0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRectMake(171, 70, 229, 110)
                self.buttonShareOnCommentDetail.frame = CGRectMake(21, 40, 44, 51)
                self.buttonSaveOnCommentDetail.frame = CGRectMake(91, 40, 44, 51)
                self.buttonReportOnCommentDetail.frame = CGRectMake(161, 40, 44, 51)
                self.buttonShareOnCommentDetail.alpha = 1.0
                self.buttonSaveOnCommentDetail.alpha = 1.0
                self.buttonReportOnCommentDetail.alpha = 1.0
            }))
            buttonMoreOnCommentCellExpanded = true
        }
        else {
            hideCommentPinMoreButtonDetails()
        }
        
    }
    
    func hideCommentPinMoreButtonDetails() {
        buttonMoreOnCommentCellExpanded = false
        UIView.animateWithDuration(0.25, animations: ({
            self.moreButtonDetailSubview.frame = CGRectMake(400, 70, 0, 0)
            self.buttonShareOnCommentDetail.frame = CGRectMake(0, 0, 0, 0)
            self.buttonSaveOnCommentDetail.frame = CGRectMake(0, 0, 0, 0)
            self.buttonReportOnCommentDetail.frame = CGRectMake(0, 0, 0, 0)
            self.buttonShareOnCommentDetail.alpha = 0.0
            self.buttonSaveOnCommentDetail.alpha = 0.0
            self.buttonReportOnCommentDetail.alpha = 0.0
        }))
    }
    
    func addTagToCommentPinCell(cell: CommentPinUIView, commentID: Int) {
        cell.buttonCommentPinLargerCover.tag = commentPinCellNumCount
        cell.buttonDeleteLargerCover.tag = commentPinCellNumCount
        self.expandedCommentPinCellTag = commentPinCellNumCount
        self.commentPinAvoidDic[commentID] = commentPinCellNumCount
    }
    
    func deleteOneCellAndMoveOtherCommentCellsUp(sender: UIButton!) {
        print(self.commentPinAvoidDic)
        
        let commentID = self.commentPinUIViewArray[sender.tag].commentID
        
        if commentPinCellNumCount == 1 {
            self.commentPinCellNumCount = 0
            self.commentPinUIViewArray.removeAtIndex(sender.tag)
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinBlurView.center.x -= self.commentPinBlurView.frame.size.width
                self.scrollViewForCommentPinArray.contentSize.height -= 78
            }), completion: {(done: Bool) in
                self.hideCommentPinCells()
                self.commentPinCellsOpen = false
            })
            print("after deleting in 1:")
            print(commentPinCellNumCount)
        }
        
        if commentPinCellNumCount >= 2 {
            self.commentPinCellNumCount -= 1
            print("content size before deleting")
            print(self.scrollViewForCommentPinArray.contentSize.height)
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinUIViewArray[sender.tag].center.x -= self.commentPinBlurView.frame.size.width
                self.scrollViewForCommentPinArray.contentSize.height -= 78
            }), completion: {(done: Bool) in
                let m = sender.tag + 1
                let n = self.commentPinUIViewArray.count - 1
                if m <= n {
                    for i in m...n {
                        self.commentPinUIViewArray[i].buttonDeleteLargerCover.tag -= 1
                        self.commentPinUIViewArray[i].buttonCommentPinLargerCover.tag -= 1
                        UIView.animateWithDuration(0.25, animations: ({
                            self.commentPinUIViewArray[i].center.y -= 78
                        }))
                    }
                }
                UIView.animateWithDuration(0.25, animations: ({
                    if self.commentPinUIViewArray.count <= 3 {
                        self.commentPinBlurView.frame.size.height -= 78
                        self.scrollViewForCommentPinArray.frame.size.height -= 78
                    }
                }), completion: {(done: Bool) in
                    print("content size after deleting")
                    print(self.scrollViewForCommentPinArray.contentSize.height)
                })
                self.commentPinUIViewArray.removeAtIndex(sender.tag)
            })
            print("after deleting in 2:")
            print(commentPinCellNumCount)
        }
        if let aDictionaryIndex = self.commentPinAvoidDic.indexForKey(commentID) {
            // This will remove the key/value pair from the dictionary and return it as a tuple pair.
            let (key, value) = self.commentPinAvoidDic.removeAtIndex(aDictionaryIndex)
            print(key) // anotherKey
            print(value) // bar
        }
        print(self.commentPinAvoidDic)
        print("Delete!")
        print("Where is comment cell blur view:")
        print(self.commentPinBlurView.center.y)
    }
    
    func hideCommentPinCells() {
        if self.commentPinBlurView != nil {
            commentPinCellsOpen = false
            self.buttonCommentLike.hidden = true
            self.buttonAddComment.hidden = true
            if self.expandedCommentPinCellTag != -999 {
                self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDeleteLargerCover.hidden = false
                self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMoreLargerCover.hidden = true
                self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDelete.alpha = 1.0
                self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMore.alpha = 0.0
            }
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinBlurView.center.y -= self.commentPinBlurView.frame.size.height
            }), completion: { (done: Bool) in
                if done {
                    self.navigationController?.navigationBar.hidden = false
                }
            })
        }
    }
    
    func showCommentPinCells() {
        if self.commentPinBlurView != nil {
            self.commentPinCellsOpen = true
            self.navigationController?.navigationBar.hidden = true
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinBlurView.center.y += self.commentPinBlurView.frame.size.height
                self.commentPinBlurView.frame.size.height = 248
            }), completion: { (done: Bool) in
                if done {
                    self.buttonCommentLike.hidden = false
                    self.buttonAddComment.hidden = false
                }
            })
        }
    }
    
    func showCommentPinCellDetails(cell: CommentPinUIView) {
        cell.imageViewAvatar.hidden = false
        cell.labelTitle.hidden = false
        cell.labelDes.hidden = false
        cell.uiviewUnderLine.hidden = false
        cell.buttonMore.hidden = false
        cell.textViewComment.hidden = false
        self.buttonAddComment.hidden = false
        self.buttonCommentLike.hidden = false
    }
    
    func shrinkExpandedCommentCell(tag: Int) {
        
        if tag == -999 {
            return
        }
        UIView.animateWithDuration(0.25, animations: ({
            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDeleteLargerCover.hidden = false
            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMoreLargerCover.hidden = true
            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonDelete.alpha = 1.0
            self.commentPinUIViewArray[self.expandedCommentPinCellTag].buttonMore.alpha = 0.0
            self.shrinkCommentPinCell(tag)
        }))
        print("shrink expanded cell works!")
        self.commentPinUIViewArray[tag].hasExpanded = false
        self.commentPinUIViewArray[tag].textViewComment.hidden = true
        self.scrollViewForCommentPinArray.contentSize.height -= 150
    }
    
    // MARK: -- Actions of Buttons
    func actionExpandCommentPinCell(sender: UIButton!) {
        if buttonMoreOnCommentCellExpanded {
            hideCommentPinMoreButtonDetails()
        }
        if self.commentPinUIViewArray[sender.tag].hasExpanded == false {
            self.shrinkExpandedCommentCell(expandedCommentPinCellTag)
            self.scrollViewForCommentPinArray.contentSize.height += 150
            self.expandedCommentPinCellTag = sender.tag
            self.commentPinUIViewArray[sender.tag].buttonDeleteLargerCover.hidden = true
            self.commentPinUIViewArray[sender.tag].buttonMoreLargerCover.hidden = false
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinUIViewArray[sender.tag].buttonDelete.alpha = 0.0
                self.commentPinUIViewArray[sender.tag].buttonMore.alpha = 1.0
                if sender.tag >= self.commentPinUIViewArray.count - 1 {
                    self.commentPinBlurView.frame.size.height = 248
                    self.scrollViewForCommentPinArray.frame.size.height = 228
                }
                else if sender.tag == self.commentPinUIViewArray.count - 2 {
                    self.commentPinBlurView.frame.size.height = 326
                    self.scrollViewForCommentPinArray.frame.size.height = 306
                }
                else {
                    self.commentPinBlurView.frame.size.height = 404
                    self.scrollViewForCommentPinArray.frame.size.height = 384
                }
                self.expandCommentPinCell(sender.tag)
            }), completion: {(done: Bool) in
                if done {
                    self.buttonCommentLike.hidden = false
                    self.buttonAddComment.hidden = false
                    self.commentPinUIViewArray[sender.tag].textViewComment.hidden = false
                }
            })
            self.commentPinUIViewArray[sender.tag].hasExpanded = true
            self.scrollViewForCommentPinArray.scrollEnabled = false
        }
        else {
            self.expandedCommentPinCellTag = -999
            self.scrollViewForCommentPinArray.contentSize.height -= 150
            self.buttonCommentLike.hidden = true
            self.buttonAddComment.hidden = true
            self.commentPinUIViewArray[sender.tag].textViewComment.hidden = true
            self.commentPinUIViewArray[sender.tag].buttonDeleteLargerCover.hidden = false
            self.commentPinUIViewArray[sender.tag].buttonMoreLargerCover.hidden = true
            let toPoint = (CGFloat)(sender.tag * 78)
            let scrollToPoint = CGPointMake(0, toPoint)
            self.scrollViewForCommentPinArray.setContentOffset(scrollToPoint, animated: false)
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinUIViewArray[sender.tag].buttonDelete.alpha = 1.0
                self.commentPinUIViewArray[sender.tag].buttonMore.alpha = 0.0
                self.commentPinBlurView.frame.size.height = self.commentPinCellGroupHeight
                self.scrollViewForCommentPinArray.frame.size.height = self.commentPinCellGroupHeight - 20
                self.shrinkCommentPinCell(sender.tag)
            }), completion: {(done: Bool) in
                if done {
                    
                }
            })
            self.commentPinUIViewArray[sender.tag].hasExpanded = false
            self.scrollViewForCommentPinArray.scrollEnabled = true
            return
        }
        let cellAtHeight = (CGFloat)(sender.tag * 78)
        print(cellAtHeight)
        let scrollPoint = CGPointMake(0, cellAtHeight)
        self.scrollViewForCommentPinArray.setContentOffset(scrollPoint, animated: true)
    }
    
    //    func actionExpandCommentPinCellSpecialUse(rowNum: Int) {
    //        if buttonMoreOnCommentCellExpanded {
    //            hideCommentPinMoreButtonDetails()
    //        }
    //        if self.commentPinUIViewArray[sender.tag].hasExpanded == false {
    //            self.shrinkExpandedCommentCell(expandedCommentPinCellTag)
    //            self.scrollViewForCommentPinArray.contentSize.height += 150
    //            self.expandedCommentPinCellTag = sender.tag
    //            self.commentPinUIViewArray[sender.tag].buttonDeleteLargerCover.hidden = true
    //            self.commentPinUIViewArray[sender.tag].buttonMoreLargerCover.hidden = false
    //            UIView.animateWithDuration(0.25, animations: ({
    //                self.commentPinUIViewArray[sender.tag].buttonDelete.alpha = 0.0
    //                self.commentPinUIViewArray[sender.tag].buttonMore.alpha = 1.0
    //                if sender.tag >= self.commentPinUIViewArray.count - 1 {
    //                    self.commentPinBlurView.frame.size.height = 248
    //                    self.scrollViewForCommentPinArray.frame.size.height = 228
    //                }
    //                else if sender.tag == self.commentPinUIViewArray.count - 2 {
    //                    self.commentPinBlurView.frame.size.height = 326
    //                    self.scrollViewForCommentPinArray.frame.size.height = 306
    //                }
    //                else {
    //                    self.commentPinBlurView.frame.size.height = 404
    //                    self.scrollViewForCommentPinArray.frame.size.height = 384
    //                }
    //                self.expandCommentPinCell(sender.tag)
    //            }), completion: {(done: Bool) in
    //                if done {
    //                    self.buttonCommentLike.hidden = false
    //                    self.buttonAddComment.hidden = false
    //                    self.commentPinUIViewArray[sender.tag].textViewComment.hidden = false
    //                }
    //            })
    //            self.commentPinUIViewArray[sender.tag].hasExpanded = true
    //            self.scrollViewForCommentPinArray.scrollEnabled = false
    //        }
    //        else {
    //            self.expandedCommentPinCellTag = -999
    //            self.scrollViewForCommentPinArray.contentSize.height -= 150
    //            self.buttonCommentLike.hidden = true
    //            self.buttonAddComment.hidden = true
    //            self.commentPinUIViewArray[sender.tag].textViewComment.hidden = true
    //            self.commentPinUIViewArray[sender.tag].buttonDeleteLargerCover.hidden = false
    //            self.commentPinUIViewArray[sender.tag].buttonMoreLargerCover.hidden = true
    //            let toPoint = (CGFloat)(sender.tag * 78)
    //            let scrollToPoint = CGPointMake(0, toPoint)
    //            self.scrollViewForCommentPinArray.setContentOffset(scrollToPoint, animated: false)
    //            UIView.animateWithDuration(0.25, animations: ({
    //                self.commentPinUIViewArray[sender.tag].buttonDelete.alpha = 1.0
    //                self.commentPinUIViewArray[sender.tag].buttonMore.alpha = 0.0
    //                self.commentPinBlurView.frame.size.height = self.commentPinCellGroupHeight
    //                self.scrollViewForCommentPinArray.frame.size.height = self.commentPinCellGroupHeight - 20
    //                self.shrinkCommentPinCell(sender.tag)
    //            }), completion: {(done: Bool) in
    //                if done {
    //
    //                }
    //            })
    //            self.commentPinUIViewArray[sender.tag].hasExpanded = false
    //            self.scrollViewForCommentPinArray.scrollEnabled = true
    //            return
    //        }
    //        let cellAtHeight = (CGFloat)(sender.tag * 78)
    //        print(cellAtHeight)
    //        let scrollPoint = CGPointMake(0, cellAtHeight)
    //        self.scrollViewForCommentPinArray.setContentOffset(scrollPoint, animated: true)
    //    }
    
    func expandCommentPinCell(tag: Int) {
        self.commentPinUIViewArray[tag].frame.size.height += 150
        self.commentPinUIViewArray[tag].uiviewUnderLine.center.y += 150
        if tag == self.commentPinUIViewArray.count - 1 {
            return
        }
        let m = tag+1
        let n = self.commentPinUIViewArray.count - 1
        for i in m...n {
            self.commentPinUIViewArray[i].center.y += 150
        }
    }
    
    func shrinkCommentPinCell(tag: Int) {
        self.commentPinUIViewArray[tag].frame.size.height -= 150
        self.commentPinUIViewArray[tag].uiviewUnderLine.center.y -= 150
        if tag == self.commentPinUIViewArray.count - 1 {
            return
        }
        let m = tag+1
        let n = self.commentPinUIViewArray.count - 1
        for i in m...n {
            self.commentPinUIViewArray[i].center.y -= 150
        }
    }
    
    func actionCloseSubmitPins(sender: UIButton!) {
        submitPinsHideAnimation()
        buttonToNorth.hidden = false
        buttonSelfPosition.hidden = false
        buttonChatOnMap.hidden = false
        buttonPinOnMap.hidden = false
        buttonSetLocationOnMap.hidden = true
        imagePinOnMap.hidden = true
        self.navigationController?.navigationBar.hidden = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        for textFiled in textFieldArray {
            textFiled.endEditing(true)
        }
        self.textFieldArray.removeAll()
        self.borderArray.removeAll()
        for every in self.uiviewArray {
            every.removeFromSuperview()
        }
        self.uiviewArray.removeAll()
        self.loadBasicTextField()
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
        myPositionOutsideMarker_1.image = UIImage(named: "myPosition_outside")
        self.myPositionOutsideMarker_1.alpha = 1.0
        self.view.addSubview(myPositionOutsideMarker_1)
        myPositionOutsideMarker_1.layer.zPosition = 0
        myPositionOutsideMarker_2 = UIImageView(frame: CGRectMake(screenWidth/2, screenHeight/2, 0, 0))
        myPositionOutsideMarker_2.image = UIImage(named: "myPosition_outside")
        self.myPositionOutsideMarker_2.alpha = 1.0
        self.view.addSubview(myPositionOutsideMarker_2)
        myPositionOutsideMarker_2.layer.zPosition = 0
        myPositionOutsideMarker_3 = UIImageView(frame: CGRectMake(screenWidth/2, screenHeight/2, 0, 0))
        myPositionOutsideMarker_3.image = UIImage(named: "myPosition_outside")
        self.myPositionOutsideMarker_3.alpha = 1.0
        self.view.addSubview(myPositionOutsideMarker_3)
        myPositionOutsideMarker_3.layer.zPosition = 0
        myPositionIcon = UIButton(frame: CGRectMake(screenWidth/2-12, screenHeight/2-20, 31.65, 40.84))
        myPositionIcon.setImage(UIImage(named: "myPosition_icon"), forState: .Normal)
        //        myPositionIcon.addTarget(self, action: #selector(FaeMapViewController.showOpenUserPinAnimation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(myPositionIcon)
        myPositionIcon.layer.zPosition = 0
        myPositionAnimation()
        
    }
    
    func myPositionAnimation() {
        UIView.animateWithDuration(3, delay: 0, options: .Repeat, animations: ({
            self.myPositionOutsideMarker_1.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
            self.myPositionOutsideMarker_1.alpha = 0.0
        }), completion: nil)
        UIView.animateWithDuration(3, delay: 0.8, options: .Repeat, animations: ({
            self.myPositionOutsideMarker_2.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
            self.myPositionOutsideMarker_2.alpha = 0.0
        }), completion: nil)
        UIView.animateWithDuration(3, delay: 1.6, options: .Repeat, animations: ({
            self.myPositionOutsideMarker_3.frame = CGRectMake(self.screenWidth/2-60, self.screenHeight/2-60, 120, 120)
            self.myPositionOutsideMarker_3.alpha = 0.0
        }), completion: nil)
    }
    
    func submitPinsHideAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.blurViewMap.center.y = self.screenHeight*1.5
        }), completion: nil)
    }
    
    func submitPinsShowAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.blurViewMap.center.y = self.screenHeight*0.5
        }), completion: nil)
    }
    
    func searchBarTableHideAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRectMake(0, 0, 398, 0)
            self.uiviewTableSubview.frame = CGRectMake(8, 23+53, 398, 0)
        }), completion: nil)
    }
    
    func searchBarTableShowAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRectMake(0, 0, 398, 240)
            self.uiviewTableSubview.frame = CGRectMake(8, 23+53, 398, 240)
        }), completion: nil)
    }
    
    // MARK: -- Blur View and Pins Creating Selections
    
    func loadBlurAndPinSelection() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurViewMap = UIVisualEffectView(effect: blurEffect)
        blurViewMap.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        UIApplication.sharedApplication().keyWindow?.addSubview(blurViewMap)
        loadPinSelections()
        loadCreateCommentPinView()
        uiviewCreateCommentPin.hidden = false
        uiviewCreateCommentPin.alpha = 0
        blurViewMap.center.y = screenHeight*1.5
    }
    
    // MARK: -- Create Comment Pin Blur View
    
    func loadCreateCommentPinView() {
        uiviewCreateCommentPin = UIView(frame: self.blurViewMap.bounds)
        
        self.loadBasicTextField()
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(FaeMapViewController.tapOutsideToDismissKeyboard(_:)))
        uiviewCreateCommentPin.addGestureRecognizer(tapToDismissKeyboard)
        
        let imageCreateCommentPin = UIImageView(frame: CGRectMake(166, 41, 83, 90))
        imageCreateCommentPin.image = UIImage(named: "comment_pin_main_create")
        uiviewCreateCommentPin.addSubview(imageCreateCommentPin)
        self.blurViewMap.addSubview(uiviewCreateCommentPin)
        
        let labelCreateCommentPinTitle = UILabel(frame: CGRectMake(109, 139, 196, 27))
        labelCreateCommentPinTitle.text = "Create Comment Pin"
        labelCreateCommentPinTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelCreateCommentPinTitle.textAlignment = .Center
        labelCreateCommentPinTitle.textColor = UIColor.whiteColor()
        self.uiviewCreateCommentPin.addSubview(labelCreateCommentPinTitle)
        
        let buttonBackToPinSelection = UIButton(frame: CGRectMake(15, 36, 18, 18))
        buttonBackToPinSelection.setImage(UIImage(named: "comment_main_back"), forState: .Normal)
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelection)
        let buttonBackToPinSelectionLargerCover = UIButton(frame: CGRectMake(15, 36, 54, 54))
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelectionLargerCover)
        buttonBackToPinSelectionLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionBackToPinSelections(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonCloseCreateComment = UIButton(frame: CGRectMake(381, 36, 18, 18))
        buttonCloseCreateComment.setImage(UIImage(named: "comment_main_close"), forState: .Normal)
        uiviewCreateCommentPin.addSubview(buttonCloseCreateComment)
        let buttonCloseCreateCommentLargerCover = UIButton(frame: CGRectMake(345, 36, 54, 54))
        uiviewCreateCommentPin.addSubview(buttonCloseCreateCommentLargerCover)
        buttonCloseCreateCommentLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let uiviewSelectLocation = UIView(frame: CGRectMake(68, 552, 276, 29))
        let imageSelectLocation_1 = UIImageView(frame: CGRectMake(0, 0, 25, 29))
        imageSelectLocation_1.image = UIImage(named: "pin_select_location_1")
        uiviewSelectLocation.addSubview(imageSelectLocation_1)
        let imageSelectLocation_2 = UIImageView(frame: CGRectMake(268.5, 7, 10.5, 19))
        imageSelectLocation_2.image = UIImage(named: "pin_select_location_2")
        uiviewSelectLocation.addSubview(imageSelectLocation_2)
        self.uiviewCreateCommentPin.addSubview(uiviewSelectLocation)
        
        labelSelectLocationContent = UILabel(frame: CGRectMake(42, 4, 209, 25))
        labelSelectLocationContent.text = "Current Location"
        labelSelectLocationContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelSelectLocationContent.textAlignment = .Left
        labelSelectLocationContent.textColor = UIColor.whiteColor()
        uiviewSelectLocation.addSubview(labelSelectLocationContent)
        
        let buttonSelectLocation = UIButton(frame: uiviewSelectLocation.bounds)
        uiviewSelectLocation.addSubview(buttonSelectLocation)
        buttonSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonCommentSubmit = UIButton(frame: CGRectMake(0, 671, screenWidth, 65))
        buttonCommentSubmit.setTitle("Submit!", forState: .Normal)
        buttonCommentSubmit.setTitle("Submit!", forState: .Highlighted)
        buttonCommentSubmit.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonCommentSubmit.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonCommentSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
        self.uiviewCreateCommentPin.addSubview(buttonCommentSubmit)
        buttonCommentSubmit.addTarget(self, action: #selector(FaeMapViewController.actionSubmitComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.blurViewMap.addSubview(uiviewCreateCommentPin)
        
    }
    
    // MARK: -- Temporary Methods!!!
    func actionLogOut(sender: UIButton!) {
        let logOut = FaeUser()
        logOut.logOut()
        submitPinsHideAnimation()
        jumpToWelcomeView()
    }
    
    func actionGetMapInfo(sender: UIButton!) {
        loadCurrentRegionPins()
    }
    
    func actionClearAllUserPins(sender: UIButton!) {
        clearAllMyPins()
    }
    
    func clearAllMyPins() {
        let clearUserPins = FaeMap()
        clearUserPins.getUserAllComments("\(user_id)"){(status:Int,message:AnyObject?) in
            let clearUserPinsJSON = JSON(message!)
            print(clearUserPinsJSON)
            for i in 0...clearUserPinsJSON.count {
                if let commentID = clearUserPinsJSON[i]["comments"]["comment_id"].int {
                    clearUserPins.deleteCommentById("\(commentID)"){(status:Int,message:AnyObject?) in
                        print("Successfully Delete Comment by ID: \(commentID)")
                    }
                }
            }
        }
    }
    
    // MARK: -- Pins Creating Selections View
    
    func loadPinSelections() {
        uiviewPinSelections = UIView(frame: self.blurViewMap.bounds)
        
        labelSubmitTitle = UILabel(frame: CGRectMake(135, 68, 145, 41))
        labelSubmitTitle.text = "Create Pin"
        labelSubmitTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 30)
        labelSubmitTitle.textAlignment = .Center
        labelSubmitTitle.textColor = UIColor.whiteColor()
        self.uiviewPinSelections.addSubview(labelSubmitTitle)
        
        buttonMedia = createSubmitButton(34, y: 160, width: 90, height: 90, picName: "submit_media")
        buttonChats = createSubmitButton(163, y: 160, width: 90, height: 90, picName: "submit_chats")
        buttonComment = createSubmitButton(292, y: 160, width: 90, height: 90, picName: "submit_comment")
        buttonComment.addTarget(self, action: #selector(FaeMapViewController.actionCreateCommentPin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonEvent = createSubmitButton(34, y: 302, width: 90, height: 90, picName: "submit_event")
        buttonFaevor = createSubmitButton(163, y: 302, width: 90, height: 90, picName: "submit_faevor")
        buttonNow = createSubmitButton(292, y: 302, width: 90, height: 90, picName: "submit_now")
        buttonNow.addTarget(self, action: #selector(FaeMapViewController.actionGetMapInfo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonJoinMe = createSubmitButton(95, y: 444, width: 90, height: 90, picName: "submit_joinme")
        buttonJoinMe.addTarget(self, action: #selector(FaeMapViewController.actionLogOut(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonClearAllMyPin = createSubmitButton(226, y: 444, width: 90, height: 90, picName: "submit_sell")
        buttonClearAllMyPin.addTarget(self, action: #selector(FaeMapViewController.actionClearAllUserPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        labelSubmitMedia = createSubmitLabel(31, y: 257, width: 95, height: 27, title: "Media")
        labelSubmitChats = createSubmitLabel(160, y: 257, width: 95, height: 27, title: "Chats")
        labelSubmitComment = createSubmitLabel(289, y: 257, width: 95, height: 27, title: "Comment")
        
        labelSubmitEvent = createSubmitLabel(31, y: 399, width: 95, height: 27, title: "Event")
        labelSubmitFaevor = createSubmitLabel(160, y: 399, width: 95, height: 27, title: "Faevor")
        labelSubmitNow = createSubmitLabel(289, y: 399, width: 95, height: 27, title: "Now")
        
        labelSubmitJoinMe = createSubmitLabel(94, y: 541, width: 95, height: 27, title: "LogOut")
        labelSubmitSell = createSubmitLabel(226, y: 541, width: 95, height: 27, title: "Clear My Pins")
        
        buttonClosePinBlurView = UIButton(frame: CGRectMake(0, 671, screenWidth, 65))
        buttonClosePinBlurView.setTitle("Close", forState: .Normal)
        buttonClosePinBlurView.setTitle("Close", forState: .Highlighted)
        buttonClosePinBlurView.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonClosePinBlurView.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonClosePinBlurView.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonClosePinBlurView.backgroundColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 0.5)
        self.uiviewPinSelections.addSubview(buttonClosePinBlurView)
        buttonClosePinBlurView.addTarget(self, action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.blurViewMap.addSubview(uiviewPinSelections)
    }
    
    func createSubmitButton(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, picName: String) -> UIButton {
        let button = UIButton(frame: CGRectMake(x, y, width, height))
        button.setImage(UIImage(named: picName), forState: .Normal)
        self.uiviewPinSelections.addSubview(button)
        return button
    }
    
    func createSubmitLabel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, title: String) -> UILabel {
        let label = UILabel(frame: CGRectMake(x, y, width, height))
        label.text = title
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        self.uiviewPinSelections.addSubview(label)
        return label
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}