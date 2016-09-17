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

class FaeMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate {
    
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
    var uiviewPinSelections: UIView!
    var blurViewMap: UIVisualEffectView!
    var buttonMedia: UIButton!
    var buttonChats: UIButton!
    var buttonComment: UIButton!
    var buttonEvent: UIButton!
    var buttonFaevor: UIButton!
    var buttonNow: UIButton!
    var buttonJoinMe: UIButton!
    var buttonSell: UIButton!
    var buttonLive: UIButton!
    
    var labelSubmitTitle: UILabel!
    var labelSubmitMedia: UILabel!
    var labelSubmitChats: UILabel!
    var labelSubmitComment: UILabel!
    var labelSubmitEvent: UILabel!
    var labelSubmitFaevor: UILabel!
    var labelSubmitNow: UILabel!
    var labelSubmitJoinMe: UILabel!
    var labelSubmitSell: UILabel!
    var labelSubmitLive: UILabel!
    var labelUnreadMessages: UILabel!
    
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
    var imagePicker : UIImagePickerController!// MARK: new var
    var buttonImagePicker : UIButton!
    
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
    
    // New Comment Pin Popup Window
    var uiviewCommentPinDetail: UIView!
    var uiviewCommentPinListBlank: UIView!
    
    var uiviewCommentPinUnderLine01: UIView!
    var uiviewCommentPinUnderLine02: UIView!
    var uiviewCommentPinListUnderLine01: UIView!
    var uiviewCommentPinListUnderLine02: UIView!
    
    var buttonBackToCommentPinLists: UIButton!
    var buttonBackToCommentPinDetail: UIButton!
    var buttonOptionOfCommentPin: UIButton!
    var buttonCommentPinDownVote: UIButton!
    var buttonCommentPinUpVote: UIButton!
    
    var buttonCommentPinLike: UIButton!
    var boolCommentPinLiked = false
    
    var buttonCommentPinListClear: UIButton!
    
    var buttonCommentPinAddComment: UIButton!
    var buttonCommentPinDetailDragToLargeSize: UIButton!
    var buttonCommentPinListDragToLargeSize: UIButton!
    
    var imageCommentPinUserAvatar: UIImageView!
    
    var labelCommentPinTitle: UILabel!
    var labelCommentPinVoteCount: UILabel!
    var labelCommentPinUserName: UILabel!
    var labelCommentPinTimestamp: UILabel!
    var labelCommentPinListTitle: UILabel!
    
    var textviewCommentPinDetail: UITextView!
    
    var commentPinCellArray = [CommentPinListCell]()
    
    var commentListScrollView: UIScrollView!
    
    var commentListExpand = false
    var commentListShowed = false
    var commentPinDetailShowed = false
    
    var buttonMoreOnCommentCellExpanded = false
    var moreButtonDetailSubview: UIImageView!
    
    // For Dragging
    var buttonCenter = CGPointZero
    var commentPinSizeFrom: CGFloat = 0
    var commentPinSizeTo: CGFloat = 0
    
    // Like Function
    var commentPinLikeCount: Int = 0 {
        //我们需要在age属性变化前做点什么
        willSet {
            print("New Value is \(newValue)")
            if self.isUpVoting {
                self.labelCommentPinVoteCount.text = "\(newValue+1)"
            }
            else if self.isDownVoting {
                self.labelCommentPinVoteCount.text = "\(newValue-1)"
            }
        }
        //我们需要在age属性发生变化后，更新一下nickName这个属性
        didSet {
            print("Old Value is \(oldValue)")
        }
    }
    
    var isUpVoting = false
    var isDownVoting = false
    
    // Fake Transparent View For Closing
    var buttonFakeTransparentClosingView: UIButton!
    
    
    // System Functions
    
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
        loadBlurAndPinSelection()
        loadMore()
        loadWindBell()
        loadMainScreenSearch()
        loadTableView()
        configureCustomSearchController()
        loadNamecard()
        loadCommentPinDetailWindow()
        loadCommentPinList()
        
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
        
        loadPositionAnimateImage()
        self.buttonLeftTop.hidden = false
        self.buttonMiddleTop.hidden = false
        self.buttonRightTop.hidden = false
        loadTransparentNavBarItems()
        loadMapChat()

        print("DEBUG: WILL APPEAR!!!")
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.buttonLeftTop.hidden = true
        self.buttonMiddleTop.hidden = true
        self.buttonRightTop.hidden = true
        // Need a Comment Clearance??????
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
                    pinShowOnMap.userData = pinData
                    pinShowOnMap.appearAnimation = kGMSMarkerAnimationPop
                    pinShowOnMap.map = self.faeMapView
                }
            }
        }
    }
    
    // Void function for NSTimer, nothing will be conducted
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
        print("You taped at Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
        customSearchController.customSearchBar.endEditing(true)
        if commentPinDetailShowed || commentListShowed{
            self.hideCommentPinDetail()
        }
        
        if openUserPinActive {
            //            hideOpenUserPinAnimation()
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
        let camera = GMSCameraPosition.cameraWithLatitude(latitude+0.001, longitude: longitude, zoom: 17)
        faeMapView.camera = camera
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
                if self.uiviewCommentPinDetail.center.y < 0 {
                    self.showCommentPinDetail()
                }
                if self.commentListShowed == true {
                    actionBackToCommentDetail(self.buttonBackToCommentPinDetail)
                    self.commentListShowed = false
                }
                let pinData = JSON(marker.userData!)
                
                let cell = CommentPinListCell()
                self.commentPinCellArray.append(cell)
                cell.jumpToDetail.addTarget(self, action: #selector(FaeMapViewController.actionJumpToDetail(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.deleteButton.addTarget(self, action: #selector(FaeMapViewController.deleteCommentPinCell(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                if let name = pinData["user_id"].int {
                    labelCommentPinUserName.text = "\(name)"
                    cell.userID = "\(name)"
                }
                if let time = pinData["created_at"].string {
                    labelCommentPinTimestamp.text = "\(time)"
                    cell.time.text = "\(time)"
                }
                if let content = pinData["content"].string {
                    textviewCommentPinDetail.text = "\(content)"
                    cell.content.text = "\(content)"
                }
                
                var commentID = -999
                
                if let commentIDGet = pinData["comment_id"].int {
                    commentID = commentIDGet
                    if self.commentPinAvoidDic[commentID] != nil {
                        print("Comment exists!")
                        print(self.commentPinAvoidDic)
                        //                        if let rowNum = self.commentPinAvoidDic[commentID] {
                        //                            
                        //                        }
                        return true
                    }
                }
                
                self.addTagCommentPinCell(cell, commentID: commentID)
                
                if commentPinCellNumCount == 0 {
                    self.buttonBackToCommentPinDetail.setImage(UIImage(named: "commentPinBackToCommentDetail"), forState: .Normal)
                    self.buttonBackToCommentPinDetail.userInteractionEnabled = true
                    self.commentListScrollView.addSubview(cell)
                    self.commentListScrollView.contentSize.height = 76
                }
                    
                else if commentPinCellNumCount >= 1 {
                    self.commentListScrollView.addSubview(cell)
                    let cellAtHeight = (CGFloat)(commentPinCellNumCount * 76)
                    cell.center.y += cellAtHeight
                    self.commentListScrollView.contentSize.height += 76
                }
                self.commentPinCellNumCount += 1
            }
        }
        return true
    }
    
    func deleteOneCellAndMoveOtherCommentCellsUp(sender: UIButton!) {
        print("Avoid Dic before delete")
        print(self.commentPinAvoidDic)
        
        let commentID = self.commentPinCellArray[sender.tag].commentID
        
        print("content size before deleting")
        print(self.commentListScrollView.contentSize.height)
        if commentPinCellNumCount == 1 {
            self.commentPinCellNumCount = 0
            self.commentPinCellArray.removeAtIndex(sender.tag)
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinCellArray[sender.tag].center.x -= self.screenWidth
                self.commentListScrollView.contentSize.height -= 76
            }), completion: {(done: Bool) in
                
            })
            print("In == 1:")
        }
        
        if commentPinCellNumCount >= 2 {
            self.commentPinCellNumCount -= 1
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinCellArray[sender.tag].center.x -= self.screenWidth
                self.commentListScrollView.contentSize.height -= 76
            }), completion: {(done: Bool) in
                let m = sender.tag + 1
                let n = self.commentPinCellArray.count - 1
                if m <= n {
                    for i in m...n {
                        self.commentPinCellArray[i].jumpToDetail.tag -= 1
                        self.commentPinCellArray[i].deleteButton.tag -= 1
                        UIView.animateWithDuration(0.25, animations: ({
                            self.commentPinCellArray[i].center.y -= 78
                        }))
                    }
                }
                //                UIView.animateWithDuration(0.25, animations: ({
                //                    if self.commentPinCellArray.count <= 3 {
                //                        self.commentListScrollView.frame.size.height -= 76
                //                    }
                //                }), completion: {(done: Bool) in
                //                    print("content size after deleting")
                //                    print(self.commentListScrollView.contentSize.height)
                //                })
                self.commentPinCellArray.removeAtIndex(sender.tag)
            })
            print("In >= 2:")
        }
        print("content size after deleting")
        print(self.commentListScrollView.contentSize.height)
        if let aDictionaryIndex = self.commentPinAvoidDic.indexForKey(commentID) {
            // This will remove the key/value pair from the dictionary and return it as a tuple pair.
            let (key, value) = self.commentPinAvoidDic.removeAtIndex(aDictionaryIndex)
            print(key) // anotherKey
            print(value) // bar
        }
        print("Avoid Dic After delete")
        print(self.commentPinAvoidDic)
        print("Delete!")
    }
    
    
    func showCommentPinDetail() {
        if self.uiviewCommentPinDetail != nil {
            self.navigationController?.navigationBar.hidden = true
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinDetail.center.y += self.uiviewCommentPinDetail.frame.size.height
            }), completion: { (done: Bool) in
                if done {
                    self.commentPinDetailShowed = true
                    self.commentListShowed = false
                }
            })
        }
    }
    
    func hideCommentPinDetail() {
        if self.uiviewCommentPinDetail != nil {
            if self.commentPinDetailShowed {
                UIView.animateWithDuration(0.25, animations: ({
                    self.uiviewCommentPinDetail.center.y -= self.uiviewCommentPinDetail.frame.size.height
                }), completion: { (done: Bool) in
                    if done {
                        self.navigationController?.navigationBar.hidden = false
                        self.commentPinDetailShowed = false
                        self.commentListShowed = false
                    }
                })
            }
            if self.commentListShowed {
                UIView.animateWithDuration(0.25, animations: ({
                    self.uiviewCommentPinListBlank.center.y -= self.uiviewCommentPinListBlank.frame.size.height
                }), completion: { (done: Bool) in
                    if done {
                        self.navigationController?.navigationBar.hidden = false
                        self.commentPinDetailShowed = false
                        self.commentListShowed = false
                        self.uiviewCommentPinListBlank.frame = CGRectMake(-self.screenWidth, 0, self.screenWidth, 320)
                        self.uiviewCommentPinDetail.frame = CGRectMake(0, -320, self.screenWidth, 320)
                    }
                })
            }
            
        }
    }
    
    func showCommentPinCellDetails(cell: CommentPinUIView) {
        cell.imageViewAvatar.hidden = false
        cell.labelTitle.hidden = false
        cell.labelDes.hidden = false
        cell.uiviewUnderLine.hidden = false
        cell.buttonMore.hidden = false
        cell.textViewComment.hidden = false
    }
    
    // MARK: -- Actions of Buttons
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
        myPositionIcon = UIButton(frame: CGRectMake(screenWidth/2-12, screenHeight/2-20, 35, 35))
        myPositionIcon.setImage(UIImage(named: "\(userAvatarMap)"), forState: .Normal)
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
        uiviewCreateCommentPin.alpha = 0.0
        blurViewMap.alpha = 0.0
        blurViewMap.hidden = true
    }
    
    // MARK: -- Create Comment Pin Blur View
    
    func loadCreateCommentPinView() {
        uiviewCreateCommentPin = UIView(frame: self.blurViewMap.bounds)
        self.blurViewMap.addSubview(uiviewCreateCommentPin)
        
        self.loadBasicTextField()
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(FaeMapViewController.tapOutsideToDismissKeyboard(_:)))
        self.uiviewCreateCommentPin.addGestureRecognizer(tapToDismissKeyboard)
        
        let imageCreateCommentPin = UIImageView(frame: CGRectMake(166, 41, 83, 90))
        imageCreateCommentPin.image = UIImage(named: "comment_pin_main_create")
        self.uiviewCreateCommentPin.addSubview(imageCreateCommentPin)
        let labelCreateCommentPinTitle = UILabel(frame: CGRectMake(109, 139, 196, 27))
        labelCreateCommentPinTitle.text = "Create Comment Pin"
        labelCreateCommentPinTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelCreateCommentPinTitle.textAlignment = .Center
        labelCreateCommentPinTitle.textColor = UIColor.whiteColor()
        self.uiviewCreateCommentPin.addSubview(labelCreateCommentPinTitle)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(83)][v1(196)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-41-[v0(90)]-8-[v1(27)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        NSLayoutConstraint(item: imageCreateCommentPin, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: labelCreateCommentPinTitle, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        
        let buttonBackToPinSelection = UIButton(frame: CGRectMake(15, 36, 18, 18))
        buttonBackToPinSelection.setImage(UIImage(named: "comment_main_back"), forState: .Normal)
        self.uiviewCreateCommentPin.addSubview(buttonBackToPinSelection)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:|-15-[v0(18)]", options: [], views: buttonBackToPinSelection)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(18)]", options: [], views: buttonBackToPinSelection)
        
        let buttonBackToPinSelectionLargerCover = UIButton(frame: CGRectMake(15, 36, 54, 54))
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelectionLargerCover)
        buttonBackToPinSelectionLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionBackToPinSelections(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonBackToPinSelection)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(54)]", options: [], views: buttonBackToPinSelection)
        
        let buttonCloseCreateComment = UIButton(frame: CGRectMake(381, 36, 18, 18))
        buttonCloseCreateComment.setImage(UIImage(named: "comment_main_close"), forState: .Normal)
        self.uiviewCreateCommentPin.addSubview(buttonCloseCreateComment)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: buttonCloseCreateComment)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(18)]", options: [], views: buttonCloseCreateComment)
        
        let buttonCloseCreateCommentLargerCover = UIButton(frame: CGRectMake(345, 36, 54, 54))
        uiviewCreateCommentPin.addSubview(buttonCloseCreateCommentLargerCover)
        buttonCloseCreateCommentLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(54)]-15-|", options: [], views: buttonCloseCreateCommentLargerCover)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(54)]", options: [], views: buttonCloseCreateCommentLargerCover)
        
        let uiviewSelectLocation = UIView()
        self.uiviewCreateCommentPin.addSubview(uiviewSelectLocation)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(276)]", options: [], views: uiviewSelectLocation)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(29)]-155-|", options: [], views: uiviewSelectLocation)
        NSLayoutConstraint(item: uiviewSelectLocation, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        let imageSelectLocation_1 = UIImageView()
        imageSelectLocation_1.image = UIImage(named: "pin_select_location_1")
        uiviewSelectLocation.addSubview(imageSelectLocation_1)
        uiviewSelectLocation.addConstraintsWithFormat("H:|-0-[v0(25)]", options: [], views: imageSelectLocation_1)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageSelectLocation_1)
        
        let imageSelectLocation_2 = UIImageView()
        imageSelectLocation_2.image = UIImage(named: "pin_select_location_2")
        uiviewSelectLocation.addSubview(imageSelectLocation_2)
        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(10.5)]-7.5-|", options: [], views: imageSelectLocation_2)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-7-[v0(19)]", options: [], views: imageSelectLocation_2)
        
        labelSelectLocationContent = UILabel()
        labelSelectLocationContent.text = "Current Location"
        labelSelectLocationContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelSelectLocationContent.textAlignment = .Left
        labelSelectLocationContent.textColor = UIColor.whiteColor()
        uiviewSelectLocation.addSubview(labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-4-[v0(25)]", options: [], views: labelSelectLocationContent)
        
        let buttonSelectLocation = UIButton()
        uiviewSelectLocation.addSubview(buttonSelectLocation)
        buttonSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonSelectLocation)
        uiviewSelectLocation.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonSelectLocation)
        
        buttonCommentSubmit = UIButton()
        buttonCommentSubmit.setTitle("Submit!", forState: .Normal)
        buttonCommentSubmit.setTitle("Submit!", forState: .Highlighted)
        buttonCommentSubmit.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonCommentSubmit.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonCommentSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
        self.uiviewCreateCommentPin.addSubview(buttonCommentSubmit)
        buttonCommentSubmit.addTarget(self, action: #selector(FaeMapViewController.actionSubmitComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.blurViewMap.addSubview(uiviewCreateCommentPin)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonCommentSubmit)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonCommentSubmit)
    }
    
    // MARK: -- Temporary Methods!!!
    func actionLogOut(sender: UIButton!) {
        let logOut = FaeUser()
        logOut.logOut{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
//                self.testLabel.text = "logout success"
            }
            else{
                //failure
//                self.testLabel.text = "logout failure"
            }
        }
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
        self.uiviewPinSelections = UIView(frame: self.blurViewMap.bounds)
        
        self.labelSubmitTitle = UILabel(frame: CGRectMake(135, 134, 145, 41))
        self.labelSubmitTitle.alpha = 0.0
        self.labelSubmitTitle.text = "Create Pin"
        self.labelSubmitTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 30)
        self.labelSubmitTitle.textAlignment = .Center
        self.labelSubmitTitle.textColor = UIColor.whiteColor()
        self.uiviewPinSelections.addSubview(labelSubmitTitle)
        
        self.buttonMedia = createSubmitButton(79, y: 205, width: 0, height: 0, picName: "submit_media")
        self.buttonChats = createSubmitButton(208, y: 205, width: 0, height: 0, picName: "submit_chats")
        self.buttonComment = createSubmitButton(337, y: 205, width: 0, height: 0, picName: "submit_comment")
        self.buttonComment.addTarget(self, action: #selector(FaeMapViewController.actionCreateCommentPin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.buttonEvent = createSubmitButton(79, y: 347, width: 0, height: 0, picName: "submit_event")
        self.buttonFaevor = createSubmitButton(208, y: 347, width: 0, height: 0, picName: "submit_faevor")
        self.buttonNow = createSubmitButton(337, y: 347, width: 0, height: 0, picName: "submit_now")
        self.buttonNow.addTarget(self, action: #selector(FaeMapViewController.actionGetMapInfo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.buttonJoinMe = createSubmitButton(79, y: 489, width: 0, height: 0, picName: "submit_joinme")
        self.buttonJoinMe.addTarget(self, action: #selector(FaeMapViewController.actionLogOut(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonSell = createSubmitButton(208, y: 489, width: 0, height: 0, picName: "submit_sell")
        self.buttonSell.addTarget(self, action: #selector(FaeMapViewController.actionClearAllUserPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonLive = createSubmitButton(337, y: 489, width: 0, height: 0, picName: "submit_live")
        
        self.labelSubmitMedia = createSubmitLabel(31, y: 224, width: 95, height: 27, title: "Media")
        self.labelSubmitChats = createSubmitLabel(160, y: 224, width: 95, height: 27, title: "Chats")
        self.labelSubmitComment = createSubmitLabel(289, y: 224, width: 95, height: 27, title: "Comment")
        
        self.labelSubmitEvent = createSubmitLabel(31, y: 366, width: 95, height: 27, title: "Event")
        self.labelSubmitFaevor = createSubmitLabel(160, y: 366, width: 95, height: 27, title: "Faevor")
        self.labelSubmitNow = createSubmitLabel(289, y: 366, width: 95, height: 27, title: "Now")
        
        self.labelSubmitJoinMe = createSubmitLabel(31, y: 508, width: 95, height: 27, title: "Join Me!")
        self.labelSubmitSell = createSubmitLabel(160, y: 508, width: 95, height: 27, title: "Sell")
        self.labelSubmitLive = createSubmitLabel(289, y: 508, width: 95, height: 27, title: "Live")
        
        self.buttonClosePinBlurView = UIButton(frame: CGRectMake(0, 736, self.screenWidth, 65))
        self.buttonClosePinBlurView.setTitle("Close", forState: .Normal)
        self.buttonClosePinBlurView.setTitle("Close", forState: .Highlighted)
        self.buttonClosePinBlurView.alpha = 0.0
        self.buttonClosePinBlurView.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.buttonClosePinBlurView.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        self.buttonClosePinBlurView.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        self.buttonClosePinBlurView.backgroundColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 0.5)
        self.uiviewPinSelections.addSubview(buttonClosePinBlurView)
        self.buttonClosePinBlurView.addTarget(self, action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewPinSelections)
        self.uiviewPinSelections.hidden = true
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
        label.alpha = 0.0
        self.uiviewPinSelections.addSubview(label)
        return label
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}