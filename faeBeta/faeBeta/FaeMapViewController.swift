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
    var buttonSell: UIButton!
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
    var couldShowCommentPinCell = false
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
        loadMapChat()
        loadNamecard()
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
    }
    override func viewWillDisappear(animated: Bool) {
        self.buttonLeftTop.hidden = true
        self.buttonMiddleTop.hidden = true
        self.buttonRightTop.hidden = true
    }
    
    // MARK: -- 如何存到缓存中以备后面继续使用
    func loadCurrentRegionPins() {
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "5000")
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
                        if typeInfo == "user" {
                            pinShowOnMap.icon = UIImage(named: "myPosition_icon")
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
        }
        
        if isInPinLocationSelect {
            let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
            let mapCenterCoordinate = mapView.projection.coordinateForPoint(mapCenter)
            GMSGeocoder().reverseGeocodeCoordinate(mapCenterCoordinate, completionHandler: {
                (response, error) -> Void in
                if let fullAddress = response?.firstResult()?.lines {
                    var addressToSearchBar = ""
                    for line in fullAddress {
                        if fullAddress.indexOf(line) == fullAddress.count-1 {
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
            }
        }
        else {
            originPointForRefreshFirstLoad = true
            mapView.clear()
        }
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if couldShowCommentPinCell {
            showCommentPinCells()
            couldShowCommentPinCell = false
        }
        
        commentPinCellsOpen = true
        
        let uiviewCommentPin = CommentPinUIView()
        uiviewCommentPin.clipsToBounds = true
        commentPinUIViewArray.append(uiviewCommentPin)
        uiviewCommentPin.buttonCommentPinLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionExpandCommentPinCell(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPin.buttonDeleteLargerCover.addTarget(self, action: #selector(FaeMapViewController.deleteOneCellAndMoveOtherCommentCellsUp(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPin.buttonMoreLargerCover.addTarget(self, action: #selector(FaeMapViewController.showCommentPinMoreButtonDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let pinData = JSON(marker.userData!)
        if let name = pinData["user_id"].int {
            uiviewCommentPin.labelTitle.text = "\(name)"
        }
        if let time = pinData["created_at"].string {
            uiviewCommentPin.labelDes.text = "\(time)"
        }
        if let content = pinData["content"].string {
            uiviewCommentPin.textViewComment.text = "\(content)"
        }
        if let latitude = pinData["latitude"].double {
            if let longitude = pinData["longitude"].double {
                let camera = GMSCameraPosition.cameraWithLatitude(latitude+0.001, longitude: longitude, zoom: 17)
                faeMapView.animateToCameraPosition(camera)
            }
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
            
            self.addTagToCommentPinCell(uiviewCommentPin)
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
            self.addTagToCommentPinCell(uiviewCommentPin)
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
            self.addTagToCommentPinCell(uiviewCommentPin)
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
            self.addTagToCommentPinCell(uiviewCommentPin)
            commentPinCellNumCount += 1
            commentPinCellGroupHeight = 98
        }
        print("Add!")
        print("Where is comment cell blur view:")
        print(self.commentPinBlurView.center.y)
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
    
    func addTagToCommentPinCell(cell: CommentPinUIView) {
        cell.buttonCommentPinLargerCover.tag = commentPinCellNumCount
        cell.buttonDeleteLargerCover.tag = commentPinCellNumCount
        self.expandedCommentPinCellTag = commentPinCellNumCount
    }
    
    func deleteOneCellAndMoveOtherCommentCellsUp(sender: UIButton!) {
        
        if commentPinCellNumCount == 1 {
            self.commentPinCellNumCount = 0
            self.commentPinUIViewArray.removeAtIndex(sender.tag)
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinBlurView.center.x -= self.commentPinBlurView.frame.size.width
                self.scrollViewForCommentPinArray.contentSize.height -= 78
            }), completion: {(done: Bool) in
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
        print("Delete!")
        print("Where is comment cell blur view:")
        print(self.commentPinBlurView.center.y)
    }
    
    func hideCommentPinCells() {
        if self.commentPinBlurView != nil {
            couldShowCommentPinCell = true
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
            self.navigationController?.navigationBar.hidden = true
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinBlurView.center.y += self.commentPinBlurView.frame.size.height
                self.commentPinBlurView.frame.size.height = 248
            }), completion: { (done: Bool) in
                if done {
                    
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
    
    func actionSelfPosition(sender: UIButton!) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            currentLocation = locManager.location
        }
        self.currentLatitude = currentLocation.coordinate.latitude
        self.currentLongitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        faeMapView.animateToCameraPosition(camera)
    }
    
    func actionTrueNorth(sender: UIButton!) {
        faeMapView.animateToBearing(0)
    }
    
    func actionCreatePin(sender: UIButton!) {
        submitPinsShowAnimation()
        uiviewCreateCommentPin.alpha = 0.0
        uiviewPinSelections.alpha = 1.0
        self.navigationController?.navigationBar.hidden = true
        hideCommentPinCells()
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
    
    func actionSelectLocation(sender: UIButton!) {
        submitPinsHideAnimation()
        faeMapView.addSubview(imagePinOnMap)
        buttonToNorth.hidden = true
        buttonChatOnMap.hidden = true
        buttonPinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = false
        imagePinOnMap.hidden = false
        self.navigationController?.navigationBar.hidden = true
        searchBarSubview.alpha = 1.0
        searchBarSubview.hidden = false
        tblSearchResults.hidden = false
        uiviewTableSubview.hidden = false
        self.customSearchController.customSearchBar.text = ""
        buttonSelfPosition.center.x = 368.5
        buttonSelfPosition.center.y = 625.5
        buttonSelfPosition.hidden = false
        buttonCancelSelectLocation.hidden = false
        isInPinLocationSelect = true
    }
    
    func actionCancelSelectLocation(sender: UIButton!) {
        submitPinsShowAnimation()
        isInPinLocationSelect = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        imagePinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = true
        buttonSelfPosition.hidden = true
        buttonSelfPosition.center.x = 362.5
        buttonSelfPosition.center.y = 611.5
        buttonCancelSelectLocation.hidden = true
    }
    
    func actionCreateCommentPin(sender: UIButton!) {
        UIView.animateWithDuration(0.4, delay: 0, options: .TransitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 0.0
            self.uiviewCreateCommentPin.alpha = 1.0
        }), completion: nil)
        labelSelectLocationContent.text = "Current Location"
    }
    
    func actionBackToPinSelections(sender: UIButton!) {
        UIView.animateWithDuration(0.4, delay: 0, options: .TransitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 1.0
            self.uiviewCreateCommentPin.alpha = 0.0
        }), completion: nil)
        for textFiled in textFieldArray {
            textFiled.endEditing(true)
        }
    }
    
    func actionSetLocationForComment(sender: UIButton!) {
        // May have bug here
        submitPinsShowAnimation()
        let valueInSearchBar = self.customSearchController.customSearchBar.text
        if valueInSearchBar == "" {
            let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
            let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
            GMSGeocoder().reverseGeocodeCoordinate(mapCenterCoordinate, completionHandler: {
                (response, error) -> Void in
                if let fullAddress = response?.firstResult()?.lines {
                    var addressToSearchBar = ""
                    for line in fullAddress {
                        if fullAddress.indexOf(line) == fullAddress.count-1 {
                            addressToSearchBar += line + ""
                        }
                        else {
                            addressToSearchBar += line + ", "
                        }
                    }
                    self.labelSelectLocationContent.text = addressToSearchBar
                }
            })
        }
        else {
            self.labelSelectLocationContent.text = valueInSearchBar
        }
        isInPinLocationSelect = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        imagePinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = true
        buttonSelfPosition.hidden = true
        buttonSelfPosition.center.x = 362.5
        buttonSelfPosition.center.y = 611.5
        buttonCancelSelectLocation.hidden = true
    }
    
    func actionSubmitComment(sender: UIButton) {
        
        let postSingleComment = FaeMap()
        var submitLatitude = ""
        var submitLongitude = ""
        
        if self.labelSelectLocationContent.text == "Current Location" {
            submitLatitude = "\(self.currentLatitude)"
            submitLongitude = "\(self.currentLongitude)"
        }
        else {
            submitLatitude = "\(self.latitudeForPin)"
            submitLongitude = "\(self.longitudeForPin)"
        }
        
        var commentContent = ""
        for everyTextField in textFieldArray {
            if let textContent = everyTextField.text {
                commentContent += textContent
            }
        }
        
        if commentContent == "" {
            let alertUIView = UIAlertView(title: "Content Field is Empty!", message: nil, delegate: self, cancelButtonTitle: "OK, I got it")
            alertUIView.show()
            return
        }
        
        postSingleComment.whereKey("geo_latitude", value: submitLatitude)
        postSingleComment.whereKey("geo_longitude", value: submitLongitude)
        postSingleComment.whereKey("content", value: commentContent)
        postSingleComment.postComment{(status:Int,message:AnyObject?) in
            if let getMessage = message {
                if let getMessageID = getMessage["comment_id"] {
                    self.submitPinsHideAnimation()
                    let commentMarker = GMSMarker()
                    var mapCenter = self.faeMapView.center
                    // Attention: the actual location of this marker is 6 points different from the displayed one
                    mapCenter.y = mapCenter.y + 6.0
                    let mapCenterCoordinate = self.faeMapView.projection.coordinateForPoint(mapCenter)
                    commentMarker.icon = UIImage(named: "comment_pin_marker")
                    commentMarker.position = mapCenterCoordinate
                    commentMarker.appearAnimation = kGMSMarkerAnimationPop
                    commentMarker.map = self.faeMapView
                    self.buttonToNorth.hidden = false
                    self.buttonSelfPosition.hidden = false
                    self.buttonChatOnMap.hidden = false
                    self.buttonPinOnMap.hidden = false
                    self.buttonSetLocationOnMap.hidden = true
                    self.imagePinOnMap.hidden = true
                    self.navigationController?.navigationBar.hidden = false
                    
                    let getJustPostedComment = FaeMap()
                    getJustPostedComment.getComment("\(getMessageID!)"){(status:Int,message:AnyObject?) in
                        let mapInfoJSON = JSON(message!)
                        var pinData = [String: AnyObject]()
                        
                        pinData["comment_id"] = getMessageID!
                        
                        if let userIDInfo = mapInfoJSON["user_id"].int {
                            pinData["user_id"] = userIDInfo
                        }
                        if let createdTimeInfo = mapInfoJSON["created_at"].string {
                            pinData["created_at"] = createdTimeInfo
                        }
                        if let contentInfo = mapInfoJSON["content"].string {
                            pinData["content"] = contentInfo
                        }
                        if let latitudeInfo = mapInfoJSON["geolocation"]["latitude"].double {
                            pinData["latitude"] = latitudeInfo
                        }
                        if let longitudeInfo = mapInfoJSON["geolocation"]["longitude"].double {
                            pinData["longitude"] = longitudeInfo
                        }
                        commentMarker.userData = pinData
                    }
                    self.textFieldArray.removeAll()
                    self.borderArray.removeAll()
                    for every in self.uiviewArray {
                        every.removeFromSuperview()
                    }
                    self.uiviewArray.removeAll()
                    self.loadBasicTextField()
                }
                else {
                    print("Cannot get comment_id of this posted comment")
                }
            }
            else {
                print("Post Comment Fail")
            }
        }
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
        myPositionIcon.addTarget(self, action: #selector(FaeMapViewController.showOpenUserPinAnimation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
        
        buttonJoinMe = createSubmitButton(95, y: 444, width: 90, height: 90, picName: "submit_joinme")
        buttonJoinMe.addTarget(self, action: #selector(FaeMapViewController.actionLogOut(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonSell = createSubmitButton(226, y: 444, width: 90, height: 90, picName: "submit_sell")
        buttonSell.addTarget(self, action: #selector(FaeMapViewController.actionClearAllUserPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        labelSubmitMedia = createSubmitLabel(31, y: 257, width: 95, height: 27, title: "Media")
        labelSubmitChats = createSubmitLabel(160, y: 257, width: 95, height: 27, title: "Chats")
        labelSubmitComment = createSubmitLabel(289, y: 257, width: 95, height: 27, title: "Comment")
        
        labelSubmitEvent = createSubmitLabel(31, y: 399, width: 95, height: 27, title: "Event")
        labelSubmitFaevor = createSubmitLabel(160, y: 399, width: 95, height: 27, title: "Faevor")
        labelSubmitNow = createSubmitLabel(289, y: 399, width: 95, height: 27, title: "Now")
        
        labelSubmitJoinMe = createSubmitLabel(94, y: 541, width: 95, height: 27, title: "LogOut")
        labelSubmitSell = createSubmitLabel(226, y: 541, width: 95, height: 27, title: "Sell")
        
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
    
    // MARK: -- Load Map Main Screen Buttons
    
    func testing(sender: UIButton!) {
        let vc = ChatSendLocation()
        vc.currentLatitude = self.currentLatitude
        vc.currentLongitude = self.currentLongitude
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func loadButton() {
        let testButton = UIButton(frame: CGRectMake(300, 170, 100, 100))
        testButton.backgroundColor = colorFae
        self.view.addSubview(testButton)
        testButton.addTarget(self, action: #selector(FaeMapViewController.testing(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        testButton.hidden = true
        
        let buttonLeftTopX: CGFloat = 15
        let buttonLeftTopY: CGFloat = 5
        let buttonLeftTopWidth: CGFloat = 32
        let buttonLeftTopHeight: CGFloat = 33
        buttonLeftTop = UIButton(frame: CGRectMake(buttonLeftTopX, buttonLeftTopY, buttonLeftTopWidth, buttonLeftTopHeight))
        buttonLeftTop.setImage(UIImage(named: "leftTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonLeftTop)
        buttonLeftTop.addTarget(self, action: #selector(FaeMapViewController.animationMoreShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonMiddleTopX: CGFloat = 186
        let buttonMiddleTopY: CGFloat = 1
        let buttonMiddleTopWidth: CGFloat = 41
        let buttonMiddleTopHeight: CGFloat = 41
        buttonMiddleTop = UIButton(frame: CGRectMake(buttonMiddleTopX, buttonMiddleTopY, buttonMiddleTopWidth, buttonMiddleTopHeight))
        buttonMiddleTop.setImage(UIImage(named: "middleTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonMiddleTop)
        buttonMiddleTop.addTarget(self, action: #selector(FaeMapViewController.animationMainScreenSearchShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonRightTopX: CGFloat = 368
        let buttonRightTopY: CGFloat = 4
        let buttonRightTopWidth: CGFloat = 31
        let buttonRightTopHeight: CGFloat = 36
        buttonRightTop = UIButton(frame: CGRectMake(buttonRightTopX, buttonRightTopY, buttonRightTopWidth, buttonRightTopHeight))
        buttonRightTop.setImage(UIImage(named: "rightTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonRightTop)
        buttonRightTop.addTarget(self, action: #selector(FaeMapViewController.animationWindBellShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonToNorthX: CGFloat = 22
        let buttonToNorthY: CGFloat = 582
        let buttonToNorthWidth: CGFloat = 59
        buttonToNorth = UIButton(frame: CGRectMake(buttonToNorthX, buttonToNorthY, buttonToNorthWidth, buttonToNorthWidth))
        buttonToNorth.setImage(UIImage(named: "compass_new"), forState: .Normal)
        self.view.addSubview(buttonToNorth)
        buttonToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonSelfPositionX: CGFloat = 333
        let buttonSelfPositionY: CGFloat = buttonToNorthY
        let buttonSelfPositionWidth: CGFloat = buttonToNorthWidth
        buttonSelfPosition = UIButton(frame: CGRectMake(buttonSelfPositionX, buttonSelfPositionY, buttonSelfPositionWidth, buttonSelfPositionWidth))
        buttonSelfPosition.setImage(UIImage(named: "self_position"), forState: .Normal)
        self.view.addSubview(buttonSelfPosition)
        buttonSelfPosition.addTarget(self, action: #selector(FaeMapViewController.actionSelfPosition(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonCancelSelectLocationWidth: CGFloat = buttonToNorthWidth
        buttonCancelSelectLocation = UIButton(frame: CGRectMake(0, 0, buttonCancelSelectLocationWidth, buttonCancelSelectLocationWidth))
        buttonCancelSelectLocation.center.x = 45.5
        buttonCancelSelectLocation.center.y = 625.5
        buttonCancelSelectLocation.setImage(UIImage(named: "cancelSelectLocation"), forState: .Normal)
        self.view.addSubview(buttonCancelSelectLocation)
        buttonCancelSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionCancelSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonCancelSelectLocation.hidden = true
        
        let chatOnMapX: CGFloat = 12
        let chatOnMapY: CGFloat = 646
        let chatOnMapWidth: CGFloat = 79
        buttonChatOnMap = UIButton(frame: CGRectMake(chatOnMapX, chatOnMapY, chatOnMapWidth, chatOnMapWidth))
        buttonChatOnMap.setImage(UIImage(named: "chat_map"), forState: .Normal)
        buttonChatOnMap.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonChatOnMap)
        
        let pinOnMapX: CGFloat = 323
        let pinOnMapY: CGFloat = chatOnMapY
        let pinOnMapWidth: CGFloat = chatOnMapWidth
        buttonPinOnMap = UIButton(frame: CGRectMake(pinOnMapX, pinOnMapY, pinOnMapWidth, pinOnMapWidth))
        buttonPinOnMap.setImage(UIImage(named: "pin_map"), forState: .Normal)
        self.view.addSubview(buttonPinOnMap)
        buttonPinOnMap.addTarget(self, action: #selector(FaeMapViewController.actionCreatePin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonSetLocationOnMap = UIButton(frame: CGRectMake(0, 671, screenWidth, 65))
        buttonSetLocationOnMap.setTitle("Set Location", forState: .Normal)
        buttonSetLocationOnMap.setTitle("Set Location", forState: .Highlighted)
        buttonSetLocationOnMap.setTitleColor(colorFae, forState: .Normal)
        buttonSetLocationOnMap.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        UIApplication.sharedApplication().keyWindow?.addSubview(buttonSetLocationOnMap)
        buttonSetLocationOnMap.addTarget(self, action: #selector(FaeMapViewController.actionSetLocationForComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonSetLocationOnMap.hidden = true
        
        buttonAddComment = UIButton(frame: CGRect(x: 280, y: 212, width: 58, height: 58))
        let imageLike = UIImage(named: "comment_pin_groupchat")
        buttonAddComment.setImage(imageLike, forState: .Normal)
        UIApplication.sharedApplication().keyWindow?.addSubview(buttonAddComment)
        buttonAddComment.hidden = true
        buttonAddComment.clipsToBounds = false
        
        buttonCommentLike = UIButton(frame: CGRect(x: 345, y: 212, width: 58, height: 58))
        let imageAddComment = UIImage(named: "comment_pin_like")
        buttonCommentLike.setImage(imageAddComment, forState: .Normal)
        UIApplication.sharedApplication().keyWindow?.addSubview(buttonCommentLike)
        buttonCommentLike.hidden = true
        buttonCommentLike.clipsToBounds = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FaeMapViewController: UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate {
    
    // MARK: TableView Initialize
    
    func loadTableView() {
        uiviewTableSubview = UIView(frame: CGRectMake(0, 0, 398, 0))
        tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.registerClass(CustomCellForAddressSearch.self, forCellReuseIdentifier: "customCellForAddressSearch")
        tblSearchResults.scrollEnabled = false
        tblSearchResults.layer.masksToBounds = true
        tblSearchResults.separatorInset = UIEdgeInsetsZero
        tblSearchResults.layoutMargins = UIEdgeInsetsZero
        uiviewTableSubview.layer.borderColor = UIColor.whiteColor().CGColor
        uiviewTableSubview.layer.borderWidth = 1.0
        uiviewTableSubview.layer.cornerRadius = 2.0
        uiviewTableSubview.layer.shadowOpacity = 0.5
        uiviewTableSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        uiviewTableSubview.layer.shadowRadius = 5.0
        uiviewTableSubview.layer.shadowColor = UIColor.blackColor().CGColor
        uiviewTableSubview.addSubview(tblSearchResults)
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewTableSubview)
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == tableviewMore {
            return 1
        }
        else if tableView == tableviewWindbell{
            return 1
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tblSearchResults){
            return placeholder.count
        }
        else if(tableView == self.mapChatTable) {
            return 10
        }
        else if tableView == tableviewMore {
            return 7
        }
        else if tableView == tableviewWindbell{
            return tableWindbellData.count
        }
        else{
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == self.tblSearchResults){
            let cell = tableView.dequeueReusableCellWithIdentifier("customCellForAddressSearch", forIndexPath: indexPath) as! CustomCellForAddressSearch
            cell.labelCellContent.text = placeholder[indexPath.row].attributedFullText.string
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else if tableView == self.mapChatTable {
            let cell = tableView.dequeueReusableCellWithIdentifier("mapChatTableCell", forIndexPath: indexPath) as! MapChatTableCell
            cell.layoutMargins = UIEdgeInsetsMake(0, 84, 0, 0)
            return cell
        }
        else if tableView == tableviewMore {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellTableViewMore, forIndexPath: indexPath)as! MoreVisibleTableViewCell
            cell.selectionStyle = .None
            if indexPath.row == 0 {
                cell.switchInvisible.hidden = false
                cell.labelTitle.text = "Go Invisible"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell0")
                
            } else if indexPath.row == 1 {
                cell.labelTitle.text = "Mood Avatar"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell1")
                
            } else if indexPath.row == 2 {
                cell.labelTitle.text = "My Pins"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell2")
            } else if indexPath.row == 3 {
                cell.labelTitle.text = "Saved"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell3")
            } else if indexPath.row == 4 {
                cell.labelTitle.text = "Name Cards"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell4")
            } else if indexPath.row == 5 {
                cell.labelTitle.text = "Map Board"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell5")
            } else if indexPath.row == 6 {
                cell.labelTitle.text = "Account Settings"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell6")
            }
            return cell
            
        }
        else if tableView == self.tableviewWindbell{
            let cell = tableView.dequeueReusableCellWithIdentifier("windbelltablecell", forIndexPath: indexPath)as! WindBellTableViewCell
            cell.selectionStyle = .None
            cell.labelTitle.text = tableWindbellData[indexPath.row]["Title"]
            cell.labelContent.text = tableWindbellData[indexPath.row]["Content"]
            cell.labelTime.text = tableWindbellData[indexPath.row]["Time"]
            return cell
            
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == self.tblSearchResults){
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(placeholder[indexPath.row].placeID!, callback: {
                (place, error) -> Void in
                // Get place.coordinate
                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                    (response, error) -> Void in
                    if let selectedAddress = place?.coordinate {
                        let camera = GMSCameraPosition.cameraWithTarget(selectedAddress, zoom: self.faeMapView.camera.zoom)
                        self.faeMapView.animateToCameraPosition(camera)
                    }
                })
            })
            self.customSearchController.customSearchBar.text = self.placeholder[indexPath.row].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if mainScreenSearchActive {
                animationMainScreenSearchHide(self.mainScreenSearchSubview)
            }
        }
        else if tableView == tableviewMore {
            if indexPath.row == 1 {
                animationMoreHide(nil)
                jumpToMoodAvatar()
            }
            if indexPath.row == 4 {
                animationMoreHide(nil)
                jumpToNameCard()
            }
            if indexPath.row == 6 {
                animationMoreHide(nil)
                jumpToAccount()
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView == self.tblSearchResults){
            return 48.0
        }
        else if tableView == self.mapChatTable {
            return 75.0
        }
        else if tableView == tableviewMore {
            return 60
        }
        else if tableView == tableviewWindbell{
            return 82
        }
        else{
            return 0
        }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func configureCustomSearchController() {
        searchBarSubview = UIView(frame: CGRectMake(8, 23, 398, 48.0))
        
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0, 5, 398, 38.0), searchBarFont: UIFont(name: "AvenirNext-Medium", size: 18.0)!, searchBarTextColor: colorFae, searchBarTintColor: UIColor.whiteColor())
        customSearchController.customSearchBar.placeholder = "Search Address or Place                                  "
        customSearchController.customDelegate = self
        customSearchController.customSearchBar.layer.borderWidth = 2.0
        customSearchController.customSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
        
        searchBarSubview.addSubview(customSearchController.customSearchBar)
        searchBarSubview.backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().keyWindow?.addSubview(searchBarSubview)
        
        searchBarSubview.layer.borderColor = UIColor.whiteColor().CGColor
        searchBarSubview.layer.borderWidth = 1.0
        searchBarSubview.layer.cornerRadius = 2.0
        searchBarSubview.layer.shadowOpacity = 0.5
        searchBarSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        searchBarSubview.layer.shadowRadius = 5.0
        searchBarSubview.layer.shadowColor = UIColor.blackColor().CGColor
        
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
    }
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: CustomSearchControllerDelegate functions
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
        customSearchController.customSearchBar.becomeFirstResponder()
        if middleTopActive {
            UIView.animateWithDuration(0.25, animations: ({
                self.blurViewMainScreenSearch.alpha = 1.0
            }))
            middleTopActive = false
        }
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
        
        if placeholder.count > 0 {
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(placeholder[0].placeID!, callback: {
                (place, error) -> Void in
                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                    (response, error) -> Void in
                    if let selectedAddress = place?.coordinate {
                        let camera = GMSCameraPosition.cameraWithTarget(selectedAddress, zoom: self.faeMapView.camera.zoom)
                        self.faeMapView.animateToCameraPosition(camera)
                    }
                })
            })
            self.customSearchController.customSearchBar.text = self.placeholder[0].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
        }
        
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        if(searchText != "") {
            let placeClient = GMSPlacesClient()
            placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil) {
                (results, error : NSError?) -> Void in
                if(error != nil) {
                    print(error)
                }
                self.placeholder.removeAll()
                if results == nil {
                    return
                } else {
                    for result in results! {
                        self.placeholder.append(result)
                    }
                    self.tblSearchResults.reloadData()
                }
            }
            if placeholder.count > 0 {
                searchBarTableShowAnimation()
            }
        }
        else {
            self.placeholder.removeAll()
            searchBarTableHideAnimation()
            self.tblSearchResults.reloadData()
        }
    }
    
    //MARK: Comment table functions
    
    
}

extension FaeMapViewController: UITextFieldDelegate {
    
    func someActionUp() {
        if uiviewArray.last?.lineNumber < 4 {
            self.exist4thLine = false
        }
        if self.exist4thLine {
            moveAllTextFieldUp()
        }
    }
    
    func someActionDown() {
        if uiviewArray.first?.lineNumber > 1 {
            self.exist1stLine = false
        }
        if self.exist1stLine {
            moveAllTextFieldDown()
        }
    }
    
    func revertBool() {
        token = true
    }
    
    func userDragged_1(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 246 && token {
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 296 && token {
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_2(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 296 && token {
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 346 && token {
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_3(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 346 && token {
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 396 && token {
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_4(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 396 && token {
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 446 && token {
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func moveAllTextFieldUp() {
        let gesture_1 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_1(_:)))
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        let gesture_4 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_4(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= 0 {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber < 1 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
            }
            
            if lineNumber > 5 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
            }
            
            switch lineNumber {
            case 1:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.0
                }), completion: nil)
                break
            case 2:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_1)
                self.exist1stLine = true
                break
            case 3:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_2)
                break
            case 4:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_3)
                break
            case 5:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_4)
                self.exist4thLine = true
                break
            default:
                break
            }
            self.uiviewArray[nums].lineNumber = lineNumber - 1
            nums -= 1
        }
    }
    
    func moveAllTextFieldDown() {
        let gesture_1 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_1(_:)))
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        let gesture_4 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_4(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= 0 {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber < 0 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                }), completion: nil)
            }
            
            if lineNumber > 4 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                }), completion: nil)
            }
            
            switch lineNumber {
            case 0:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_1)
                self.exist1stLine = true
                break
            case 1:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_2)
                break
            case 2:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_3)
                break
            case 3:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_4)
                self.exist4thLine = true
                break
            case 4:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 0.0
                }), completion: nil)
                break
            default:
                break
            }
            self.uiviewArray[nums].lineNumber = lineNumber + 1
            nums -= 1
        }
    }
    
    func moveAllTextFieldUpFromIndex(index: Int!) {
        let gesture_4 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_4(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= index {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber > 5 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
            }
            
            switch lineNumber {
            case 5:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_4)
                self.exist4thLine = true
                break
            default:
                break
            }
            self.uiviewArray[nums].lineNumber = lineNumber - 1
            nums -= 1
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var arrNum = 0
        
        if let arrayNum = textFieldArray.indexOf(textField) {
            arrNum = arrayNum
        }
        
        if arrNum > 0 {
            if let checkEmptyTextField = textFieldArray[arrNum-1].text {
                if checkEmptyTextField == "" {
                    textFieldArray[arrNum].resignFirstResponder()
                    textFieldArray[arrNum-1].becomeFirstResponder()
                }
            }
        }
        
        if uiviewArray[arrNum].lineNumber == 1 {
            if arrNum == 0 {
                moveAllTextFieldDown()
            }
            else {
                moveAllTextFieldDown()
                moveAllTextFieldDown()
            }
            return
        }
        
        if uiviewArray[arrNum].lineNumber == 2 {
            if arrNum != 0 {
                moveAllTextFieldDown()
                return
            }
            return
        }
        
        if uiviewArray[arrNum].lineNumber == 3 {
            return
        }
        
        if uiviewArray[arrNum].lineNumber == 4 {
            moveAllTextFieldUp()
            return
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var arrNum = 0
        
        if let arrayNum = textFieldArray.indexOf(textField) {
            arrNum = arrayNum
        }
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        let backSpace = string.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(backSpace, "\\b")
        if isBackSpace == -92 {
            if newLength == 0 {
                textFieldArray[arrNum].text = ""
                if arrNum != 0 {
                    textFieldArray[arrNum].resignFirstResponder()
                    textFieldArray[arrNum-1].becomeFirstResponder()
                }
                if textFieldArray.count > 2 {
                    if arrNum < uiviewArray.count-1 {
                        moveAllTextFieldUpFromIndex(arrNum)
                    }
                    self.uiviewArray[arrNum].removeFromSuperview()
                    self.uiviewArray.removeAtIndex(arrNum)
                    self.textFieldArray.removeAtIndex(arrNum)
                    self.borderArray.removeAtIndex(arrNum)
                }
                else {
                    exist1stLine = false
                    exist4thLine = false
                }
                return false
            }
        }
        
        if newLength <= 25 {
            return true
        }
        else {
            if arrNum == textFieldArray.count-1 {
                createNewTextField()
                addNewTextfieldAnimation()
                textFieldArray[arrNum].resignFirstResponder()
                textFieldArray[arrNum+1].becomeFirstResponder()
                if let currentText = textFieldArray[arrNum+1].text {
                    textFieldArray[arrNum+1].text = "\(string)\(currentText)"
                }
            }
            else {
                textFieldArray[arrNum].resignFirstResponder()
                textFieldArray[arrNum+1].becomeFirstResponder()
                if let currentText = textFieldArray[arrNum+1].text {
                    textFieldArray[arrNum+1].text = "\(string)\(currentText)"
                }
            }
            return false
        }
    }
    
    func deleteFromIndexTextfieldAnimation() {
        let gesture_1 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_1(_:)))
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= 0 {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber < 0 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                }), completion: nil)
                self.uiviewArray[nums].lineNumber = lineNumber + 1
            }
            
            switch lineNumber {
            case 0:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].lineNumber = lineNumber + 1
                self.uiviewArray[nums].addGestureRecognizer(gesture_1)
                break
            case 1:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].lineNumber = lineNumber + 1
                self.uiviewArray[nums].addGestureRecognizer(gesture_2)
                break
            case 2:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].lineNumber = lineNumber + 1
                self.uiviewArray[nums].addGestureRecognizer(gesture_3)
                break
            case 3:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].alpha = 0.0
                }), completion: nil)
                self.uiviewArray.removeLast()
                self.textFieldArray.removeLast()
                self.borderArray.removeLast()
                break
            default:
                break
            }
            
            nums -= 1
        }
    }
    
    func addNewTextfieldAnimation() {
        let gesture_1 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_1(_:)))
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= 0 {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber < 1 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
            }
            
            switch lineNumber {
            case 1:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.0
                }), completion: nil)
                break
            case 2:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.exist1stLine = true
                self.uiviewArray[nums].addGestureRecognizer(gesture_1)
                break
            case 3:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_2)
                break
            case 4:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_3)
                break
            default:
                break
            }
            
            self.uiviewArray[nums].lineNumber = lineNumber - 1
            nums -= 1
        }
    }
    
    func loadBasicTextField() {
        createNewTextField()
        createNewTextField()
        uiviewArray[0].alpha = 1.0
        uiviewArray[0].center.y = uiviewArray[0].center.y - 100.0
        let placeholder = NSAttributedString(string: "Type a comment...", attributes: [NSForegroundColorAttributeName: colorPlaceHolder])
        uiviewArray[0].customTextField.attributedPlaceholder = placeholder
        uiviewArray[0].lineNumber = 2
        uiviewArray[0].customTextField.autocapitalizationType = UITextAutocapitalizationType.None
        uiviewArray[1].alpha = 1.0
        uiviewArray[1].center.y = uiviewArray[1].center.y - 50.0
        uiviewArray[1].lineNumber = 3
        
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        uiviewArray[0].addGestureRecognizer(gesture_2)
        uiviewArray[1].addGestureRecognizer(gesture_3)
    }
    
    func createNewTextField() {
        let newTextField = CustomUIViewForScrollableTextField()
        self.uiviewCreateCommentPin.addSubview(newTextField)
        newTextField.customTextField.delegate = self
        uiviewArray.append(newTextField)
        textFieldArray.append(newTextField.customTextField)
        borderArray.append(newTextField.customBorder)
        newTextField.alpha = 0.0
    }
    
    func tapOutsideToDismissKeyboard(sender: UITapGestureRecognizer) {
        for textFiled in textFieldArray {
            textFiled.endEditing(true)
        }
    }
}
//MARK: show left slide window
extension FaeMapViewController {
    
    func loadMore() {
        dimBackgroundMoreButton = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        dimBackgroundMoreButton.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        dimBackgroundMoreButton.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(dimBackgroundMoreButton)
        dimBackgroundMoreButton.addTarget(self, action: #selector(FaeMapViewController.animationMoreHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        uiviewMoreButton = UIView(frame: CGRectMake(-335, 0, 335, screenHeight))
        uiviewMoreButton.backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewMoreButton)
        
        //initial tableview
        tableviewMore = UITableView(frame: CGRectMake(0, 0, 335, screenHeight), style: .Grouped)
        tableviewMore.delegate = self
        tableviewMore.dataSource = self
        tableviewMore.registerNib(UINib(nibName: "MoreVisibleTableViewCell",bundle: nil), forCellReuseIdentifier: cellTableViewMore)
        tableviewMore.backgroundColor = UIColor.clearColor()
        tableviewMore.separatorColor = UIColor.clearColor()
        tableviewMore.rowHeight = 60
        
        uiviewMoreButton.addSubview(tableviewMore)
        addHeaderViewForMore()
    }
    func jumpToMoodAvatar() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("MoodAvatarViewController")as! MoodAvatarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func jumpToNameCard() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NameCardViewController")as! NameCardViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func jumpToAccount(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("FaeAccountViewController")as! FaeAccountViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func addHeaderViewForMore(){
        viewHeaderForMore = UIView(frame: CGRectMake(0,0,311,268))
        viewHeaderForMore.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        tableviewMore.tableHeaderView = viewHeaderForMore
        tableviewMore.tableHeaderView?.frame = CGRectMake(0, 0, 311, 268)
        
        imageViewBackgroundMore = UIImageView(frame: CGRectMake(0, 148, 335, 120))
        imageViewBackgroundMore.image = UIImage(named: "tableViewMoreBackground")
        viewHeaderForMore.addSubview(imageViewBackgroundMore)
        
        buttonMoreLeft = UIButton(frame: CGRectMake(15,27,33,25))
        buttonMoreLeft.setImage(UIImage(named: "tableViewMoreLeftButton"), forState: .Normal)
        viewHeaderForMore.addSubview(buttonMoreLeft)
        
        buttonMoreRight = UIButton(frame: CGRectMake(293,26,27,27))
        buttonMoreRight.setImage(UIImage(named: "tableviewMoreRightButton-1"), forState: .Normal)
        viewHeaderForMore.addSubview(buttonMoreRight)
        
        imageViewAvatarMore = UIImageView(frame: CGRectMake(122,36,91,91))
        imageViewAvatarMore.layer.cornerRadius = 81 / 2
        imageViewAvatarMore.image = UIImage(named: "myAvatorLin")
        viewHeaderForMore.addSubview(imageViewAvatarMore)
        
        labelMoreName = UILabel(frame: CGRectMake(78,134,180,27))
        labelMoreName.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelMoreName.textAlignment = .Center
        labelMoreName.textColor = UIColor.whiteColor()
        if let name = userFirstname {
            labelMoreName.text = userFirstname! + " " + userLastname!
        }
        labelMoreName.text = "Anynomous"
        viewHeaderForMore.addSubview(labelMoreName)
    }
    
    func animationMoreShow(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewMoreButton.center.x = self.uiviewMoreButton.center.x + 335
            self.dimBackgroundMoreButton.alpha = 0.7
            self.dimBackgroundMoreButton.layer.opacity = 0.7
        }))
    }
    
    func animationMoreHide(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewMoreButton.center.x = self.uiviewMoreButton.center.x - 335
            self.dimBackgroundMoreButton.alpha = 0.0
        }))
    }
    
}
//MARK: show right slide window
extension FaeMapViewController {
    
    func loadWindBell() {
        dimBackgroundWindBell = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        dimBackgroundWindBell.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        dimBackgroundWindBell.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(dimBackgroundWindBell)
        dimBackgroundWindBell.addTarget(self, action: #selector(FaeMapViewController.animationWindBellHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        uiviewWindBell = UIView(frame: CGRectMake(screenWidth, 0, 311, screenHeight))
        uiviewWindBell.backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewWindBell)
        
        labelWindbellTableTitle = UILabel(frame: CGRectMake(115,13+navigationBarHeight,82,26))
        labelWindbellTableTitle.text = "Windbell"
        labelWindbellTableTitle.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        uiviewWindBell.addSubview(labelWindbellTableTitle)
        
        //initial tableview
        tableviewWindbell = UITableView(frame: CGRectMake(0, 50+navigationBarHeight, 311, screenHeight))
        tableviewWindbell.delegate = self
        tableviewWindbell.dataSource = self
        tableviewWindbell.registerNib(UINib(nibName: "WindBellTableViewCell",bundle: nil), forCellReuseIdentifier: "windbelltablecell")
        tableviewWindbell.backgroundColor = UIColor.clearColor()
        //tableviewWindbell.separatorStyle = .SingleLine
        tableviewWindbell.separatorInset = UIEdgeInsetsZero
        
        tableviewWindbell.separatorColor = UIColor(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        
        uiviewWindBell.addSubview(tableviewWindbell)
    }
    
    func animationWindBellShow(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewWindBell.center.x = self.uiviewWindBell.center.x - 311
            self.dimBackgroundWindBell.alpha = 0.7
            self.dimBackgroundWindBell.layer.opacity = 0.7
        }))
    }
    
    func animationWindBellHide(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewWindBell.center.x = self.uiviewWindBell.center.x + 311
            self.dimBackgroundWindBell.alpha = 0.0
        }))
    }
    
}
//MARK: main screen search
extension FaeMapViewController {
    
    func loadMainScreenSearch() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurViewMainScreenSearch = UIVisualEffectView(effect: blurEffect)
        blurViewMainScreenSearch.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        blurViewMainScreenSearch.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(blurViewMainScreenSearch)
        mainScreenSearchSubview = UIButton(frame: blurViewMainScreenSearch.frame)
        UIApplication.sharedApplication().keyWindow?.addSubview(mainScreenSearchSubview)
        mainScreenSearchSubview.hidden = true
        mainScreenSearchSubview.addTarget(self, action: #selector(FaeMapViewController.animationMainScreenSearchHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.blurViewMainScreenSearch.alpha = 0.0
    }
    
    func animationMainScreenSearchShow(sender: UIButton!) {
        self.mainScreenSearchActive = true
        self.searchBarSubview.hidden = false
        self.tblSearchResults.hidden = false
        self.uiviewTableSubview.hidden = false
        self.searchBarSubview.alpha = 0.0
        self.tblSearchResults.alpha = 0.0
        self.uiviewTableSubview.alpha = 0.0
        self.middleTopActive = true
        self.mainScreenSearchSubview.hidden = false
        UIView.animateWithDuration(0.25, animations: ({
            self.searchBarSubview.alpha = 1.0
            self.tblSearchResults.alpha = 1.0
            self.uiviewTableSubview.alpha = 1.0
        }))
    }
    
    func animationMainScreenSearchHide(sender: UIButton!) {
        self.customSearchController.customSearchBar.endEditing(true)
        self.mainScreenSearchSubview.hidden = true
        self.middleTopActive = false
        UIView.animateWithDuration(0.25, animations: ({
            self.blurViewMainScreenSearch.alpha = 0.0
            self.searchBarSubview.alpha = 0.0
            self.tblSearchResults.alpha = 0.0
            self.uiviewTableSubview.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.searchBarSubview.hidden = true
                self.tblSearchResults.hidden = true
                self.uiviewTableSubview.hidden = true
                self.mainScreenSearchActive = false
                self.customSearchController.customSearchBar.text = ""
            }
        })
    }
    
}
//MARK: show unread chat tableView
extension FaeMapViewController {
    func loadMapChat() {
        mapChatSubview = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        mapChatSubview.backgroundColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 0.5)
        mapChatSubview.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(mapChatSubview)
        mapChatSubview.addTarget(self, action: #selector(FaeMapViewController.animationMapChatHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        mapChatWindow = UIView(frame: CGRectMake(31, 115, 350, 439))
        mapChatWindow.layer.cornerRadius = 20
        mapChatWindow.backgroundColor = UIColor.whiteColor()
        mapChatWindow.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(mapChatWindow)
        
        mapChatClose = UIButton(frame: CGRectMake(15, 27, 17, 17))
        mapChatClose.setImage(UIImage(named: "mapChatClose"), forState: .Normal)
        mapChatClose.addTarget(self, action: #selector(FaeMapViewController.animationMapChatHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        mapChatClose.clipsToBounds = true
        mapChatWindow.addSubview(mapChatClose)
        
        labelMapChat = UILabel(frame: CGRectMake(128, 27, 97, 20))
        labelMapChat.text = "Map Chats"
        labelMapChat.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelMapChat.textAlignment = .Center
        labelMapChat.clipsToBounds = true
        mapChatWindow.addSubview(labelMapChat)
        
        let mapChatUnderLine = UIView(frame: CGRectMake(0, 59, 350, 1))
        mapChatUnderLine.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        mapChatWindow.addSubview(mapChatUnderLine)
        
        mapChatTable = UITableView(frame: CGRectMake(0, 60, 350, 370))
        mapChatWindow.addSubview(mapChatTable)
        mapChatTable.delegate = self
        mapChatTable.dataSource = self
        mapChatTable.registerClass(MapChatTableCell.self, forCellReuseIdentifier: "mapChatTableCell")
        mapChatTable.layer.cornerRadius = 20
    }
    
    func animationMapChatShow(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.mapChatSubview.alpha = 0.9
            self.mapChatWindow.alpha = 1.0
        }))
    }
    
    func animationMapChatHide(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.mapChatSubview.alpha = 0.0
            self.mapChatWindow.alpha = 0.0
        }))
    }
}