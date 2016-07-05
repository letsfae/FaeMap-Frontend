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
    
    // MARK: -- Location
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    
    // MARK: -- Blur View Pin Buttons and Labels
    var uiviewPinSelections: UIView!
    var blurViewMap: UIVisualEffectView!
    var buttonMedia: UIButton!
    var buttonLive: UIButton!
    var buttonComment: UIButton!
    var buttonEvent: UIButton!
    var buttonFaevor: UIButton!
    var buttonNow: UIButton!
    var buttonJoinMe: UIButton!
    var buttonSell: UIButton!
    var buttonIcons: UIButton!
    
    var labelSubmitTitle: UILabel!
    var labelSubmitMedia: UILabel!
    var labelSubmitLive: UILabel!
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
    var myPositionIcon: UIImageView!
    var myPositionOutsideMarker_1: UIImageView!
    var myPositionOutsideMarker_2: UIImageView!
    var myPositionOutsideMarker_3: UIImageView!
    
    // MARK: -- Search Bar
    var uiviewTableSubview: UIView!
    var tblSearchResults: UITableView!
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
    
    // MARK: -- TableData of comment pin info
    var tableCommentBlurView: UIVisualEffectView!
    var commentPinTableData = [[String: AnyObject]]()
    var tableComment: UITableView!
    var tableCommentData = [[String : AnyObject]]()
    var selectedCellIndexPath: NSIndexPath?
    var blurViewNavigationBar: UIView!
    let selectedCellHeight: CGFloat = 250.0
    let unselectedCellHeight: CGFloat = 70.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareAPI = LocalStorageManager()
        shareAPI.readLogInfo()
        if is_Login == 0 {
            self.jumpToWelcomeView()
        }
        
        myPositionIconFirstLoaded = true
        
        loadMapView()
        loadTransparentNavBarItems()
        loadButton()
        loadBlurAndPinSelection()
        blurViewMap.center.y = screenHeight*1.5
        
        loadTableView()
        configureCustomSearchController()
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
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways) {
            currentLocation = locManager.location
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
            faeMapView.camera = camera
        }
        loadPositionAnimateImage()
    }
    
    
    // MARK: -- 如何存到缓存中以备后面继续使用
    func loadCurrentRegionPins() {
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        print("Loading时的坐标")
        print(mapCenterCoordinate)
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "5000")
        loadPinsByZoomLevel.getMapInformation{(status:Int,message:AnyObject?) in
            print("获取地图数据：")
            let mapInfoJSON = JSON(message!)
            print(mapInfoJSON)
            self.commentPinTableData.removeAll()
            for i in 0...(mapInfoJSON.count-1) {//MARK : Error here
                let pinShowOnMap = GMSMarker()
                var pinData = [String: AnyObject]()
                var name = ""
                var time = ""
                var comment = ""
                if let typeInfo = mapInfoJSON[i]["type"].string {
                    print(typeInfo)
                    pinData["type"] = typeInfo
                    if typeInfo == "comment" {
                        pinShowOnMap.icon = UIImage(named: "comment_pin_marker")
                    }
                    if typeInfo == "user" {
                        pinShowOnMap.icon = UIImage(named: "myPosition_icon")
                    }
                }
                if let commentIDInfo = mapInfoJSON[i]["comment_id"].int {
                    print(commentIDInfo)
                    pinData["comment_id"] = commentIDInfo
                }
                if let userIDInfo = mapInfoJSON[i]["user_id"].int {
                    print(userIDInfo)
                    pinData["user_id"] = userIDInfo
                    name = "\(userIDInfo)"
                }
                if let createdTimeInfo = mapInfoJSON[i]["created_at"].string {
                    print(createdTimeInfo)
                    pinData["created_at"] = createdTimeInfo
                    time = "\(createdTimeInfo)"
                }
                if let contentInfo = mapInfoJSON[i]["content"].string {
                    print(contentInfo)
                    let contentDic = ["content": contentInfo]
                    pinData["content"] = contentInfo
                    comment = "\(contentInfo)"
                }
                if let latitudeInfo = mapInfoJSON[i]["geolocation"]["latitude"].double {
                    print(latitudeInfo)
                    pinData["latitude"] = latitudeInfo
                    pinShowOnMap.position.latitude = latitudeInfo
                }
                if let longitudeInfo = mapInfoJSON[i]["geolocation"]["longitude"].double {
                    print(longitudeInfo)
                    pinData["longitude"] = longitudeInfo
                    pinShowOnMap.position.longitude = longitudeInfo
                }
                pinShowOnMap.userData = pinData
                pinShowOnMap.appearAnimation = kGMSMarkerAnimationPop
                pinShowOnMap.map = self.faeMapView
                let singleTableData = ["name": name, "time": time, "comment": comment]
                self.commentPinTableData.append(singleTableData)
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
        
        imagePinOnMap = UIImageView(frame: CGRectMake(screenWidth/2-19, screenHeight/2-41, 38, 41))
        imagePinOnMap.image = UIImage(named: "comment_pin_image")
        imagePinOnMap.hidden = true
    }
    
    // MARK: -- Map Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
        if tableComment != nil{
            hideCommentTable()
        }
        self.navigationController?.navigationBar.hidden = false
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        let directionMap = position.bearing
        let direction: CGFloat = CGFloat(directionMap)
        let angle:CGFloat = ((360.0 - direction) * 3.14/180.0) as CGFloat
        buttonToNorth.transform = CGAffineTransformMakeRotation(angle)
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
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
        print(mapCenterCoordinate)
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
        if let pinData = marker.userData {
            print(pinData)
        }
        selectedCellIndexPath = nil
        loadCommentTable()
        return true
    }
    
    // MARK: -- Actions
    
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
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.hidden = true
        hideCommentTable()
    }
    
    func actionCloseSubmitPins(sender: UIButton!) {
        submitPinsHideAnimation()
        buttonToNorth.hidden = false
        buttonSelfPosition.hidden = false
        buttonChatOnMap.hidden = false
        buttonPinOnMap.hidden = false
        buttonSetLocationOnMap.hidden = true
        imagePinOnMap.hidden = true
        self.tabBarController?.tabBar.hidden = false
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
        buttonSelfPosition.hidden = true
        buttonChatOnMap.hidden = true
        buttonPinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = false
        imagePinOnMap.hidden = false
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.hidden = true
        searchBarSubview.hidden = false
        tblSearchResults.hidden = false
        uiviewTableSubview.hidden = false
        self.customSearchController.customSearchBar.text = ""
        
        isInPinLocationSelect = true
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
        print("Comment Content: \(commentContent)")
        
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
                print("发布了评论")
                print(getMessage)
                if let getMessageID = getMessage["comment_id"] {
                    print(getMessageID!)
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
                    self.tabBarController?.tabBar.hidden = false
                    self.navigationController?.navigationBar.hidden = false
                    
                    let getJustPostedComment = FaeMap()
                    getJustPostedComment.getComment("\(getMessageID!)"){(status:Int,message:AnyObject?) in
                        print(message)
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
        myPositionOutsideMarker_2 = UIImageView(frame: CGRectMake(screenWidth/2, screenHeight/2, 0, 0))
        myPositionOutsideMarker_2.image = UIImage(named: "myPosition_outside")
        self.myPositionOutsideMarker_2.alpha = 1.0
        self.view.addSubview(myPositionOutsideMarker_2)
        myPositionOutsideMarker_3 = UIImageView(frame: CGRectMake(screenWidth/2, screenHeight/2, 0, 0))
        myPositionOutsideMarker_3.image = UIImage(named: "myPosition_outside")
        self.myPositionOutsideMarker_3.alpha = 1.0
        self.view.addSubview(myPositionOutsideMarker_3)
        myPositionIcon = UIImageView(frame: CGRectMake(screenWidth/2-12, screenHeight/2-20, 31.65, 40.84))
        myPositionIcon.image = UIImage(named: "myPosition_icon")
        self.view.addSubview(myPositionIcon)
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
        print("DEBUG: Animation Works!")
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
        buttonCommentSubmit.backgroundColor = UIColor(red: 194/255, green: 229/255, blue: 159/255, alpha: 1.0)
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
        
        buttonMedia = createSubmitButton(35, y: 146, width: 90, height: 90, picName: "submit_media")
        buttonLive = createSubmitButton(163, y: 146, width: 90, height: 90, picName: "submit_live")
        buttonComment = createSubmitButton(291, y: 146, width: 90, height: 90, picName: "submit_comment")
        buttonComment.addTarget(self, action: #selector(FaeMapViewController.actionCreateCommentPin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonEvent = createSubmitButton(35, y: 302, width: 90, height: 90, picName: "submit_event")
        buttonFaevor = createSubmitButton(163, y: 302, width: 90, height: 90, picName: "submit_faevor")
        buttonNow = createSubmitButton(291, y: 302, width: 90, height: 90, picName: "submit_now")
        
        buttonJoinMe = createSubmitButton(35, y: 458, width: 90, height: 90, picName: "submit_joinme")
        buttonJoinMe.addTarget(self, action: #selector(FaeMapViewController.actionLogOut(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonSell = createSubmitButton(163, y: 458, width: 90, height: 90, picName: "submit_sell")
        buttonSell.addTarget(self, action: #selector(FaeMapViewController.actionClearAllUserPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonIcons = createSubmitButton(291, y: 458, width: 90, height: 90, picName: "submit_icons")
        buttonIcons.addTarget(self, action: #selector(FaeMapViewController.actionGetMapInfo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        labelSubmitMedia = createSubmitLabel(32, y: 243, width: 95, height: 27, title: "Media")
        labelSubmitLive = createSubmitLabel(160, y: 243, width: 95, height: 27, title: "Live")
        labelSubmitComment = createSubmitLabel(288, y: 243, width: 95, height: 27, title: "Comment")
        
        labelSubmitEvent = createSubmitLabel(32, y: 399, width: 95, height: 27, title: "Event")
        labelSubmitFaevor = createSubmitLabel(160, y: 399, width: 95, height: 27, title: "Faevor")
        labelSubmitNow = createSubmitLabel(288, y: 399, width: 95, height: 27, title: "Now")
        
        labelSubmitJoinMe = createSubmitLabel(32, y: 555, width: 95, height: 27, title: "LogOut")
        labelSubmitSell = createSubmitLabel(160, y: 555, width: 95, height: 27, title: "Sell")
        labelSubmitIcons = createSubmitLabel(288, y: 555, width: 95, height: 27, title: "GetMap")
        
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
    
    func loadButton() {
        let buttonLeftTopX: CGFloat = 15
        let buttonLeftTopY: CGFloat = 5
        let buttonLeftTopWidth: CGFloat = 32
        let buttonLeftTopHeight: CGFloat = 33
        buttonLeftTop = UIButton(frame: CGRectMake(buttonLeftTopX, buttonLeftTopY, buttonLeftTopWidth, buttonLeftTopHeight))
        buttonLeftTop.setImage(UIImage(named: "leftTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonLeftTop)
        
        let buttonMiddleTopX: CGFloat = 186
        let buttonMiddleTopY: CGFloat = 1
        let buttonMiddleTopWidth: CGFloat = 41
        let buttonMiddleTopHeight: CGFloat = 41
        buttonMiddleTop = UIButton(frame: CGRectMake(buttonMiddleTopX, buttonMiddleTopY, buttonMiddleTopWidth, buttonMiddleTopHeight))
        buttonMiddleTop.setImage(UIImage(named: "middleTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonMiddleTop)
        
        let buttonRightTopX: CGFloat = 368
        let buttonRightTopY: CGFloat = 4
        let buttonRightTopWidth: CGFloat = 31
        let buttonRightTopHeight: CGFloat = 36
        buttonRightTop = UIButton(frame: CGRectMake(buttonRightTopX, buttonRightTopY, buttonRightTopWidth, buttonRightTopHeight))
        buttonRightTop.setImage(UIImage(named: "rightTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonRightTop)
        
        let buttonToNorthX: CGFloat = 22
        let buttonToNorthY: CGFloat = 528
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
        
        let chatOnMapX: CGFloat = 12
        let chatOnMapY: CGFloat = 592
        let chatOnMapWidth: CGFloat = 79
        buttonChatOnMap = UIButton(frame: CGRectMake(chatOnMapX, chatOnMapY, chatOnMapWidth, chatOnMapWidth))
        buttonChatOnMap.setImage(UIImage(named: "chat_map"), forState: .Normal)
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
    
    //MARK: load comment table
    
    func loadCommentTable(){
        tableCommentData = commentPinTableData
        //        print(commentPinTableData)
        //        print(tableCommentData)
        if self.tableComment != nil {
            self.tableComment.removeFromSuperview()
        }
        if self.tableCommentBlurView != nil {
            self.tableCommentBlurView.removeFromSuperview()
        }
        self.tableComment = UITableView(frame:CGRect(x: 0, y: navigationBarHeight, width: screenWidth, height: 0)
        )
        self.tableComment.delegate = self
        self.tableComment.dataSource = self
        tableComment.backgroundColor = UIColor.clearColor()
        let nib = UINib(nibName: "CommentExtentTableViewCell",bundle: nil)
        self.tableComment.registerNib(nib, forCellReuseIdentifier: "commentCell")
        tableComment.tableFooterView = UIView(frame: CGRectZero)
        
        self.navigationController?.navigationBar.hidden = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        tableCommentBlurView = UIVisualEffectView(effect:blurEffect)
        tableCommentBlurView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 0)
        tableCommentBlurView.addSubview(tableComment)
        UIApplication.sharedApplication().keyWindow?.addSubview(tableCommentBlurView)
        UIView.animateWithDuration(0.2, animations:({
            self.resizeCommentTableView()
        }), completion: nil)
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tblSearchResults){
            return placeholder.count
        }
        else if(tableView == self.tableComment){
            return tableCommentData.count
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
        else if(tableView == self.tableComment){
            let cell:CommentExtentTableViewCell = self.tableComment.dequeueReusableCellWithIdentifier("commentCell") as! CommentExtentTableViewCell
            cell.labelTitle.text = self.tableCommentData[indexPath.row]["name"] as? String
            cell.labelDes.text = self.tableCommentData[indexPath.row]["time"] as? String
            cell.textViewComment.text = self.tableCommentData[indexPath.row]["comment"] as? String
            
            cell.hideComment()
            cell.frame.size.width = screenWidth
            cell.index = indexPath
            cell.buttonExtend.tag = indexPath.row
            cell.buttonExtend.addTarget(self,action: #selector(FaeMapViewController.buttonDeleteAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.selectionStyle = .None
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else{
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
        }
        else if(tableView == self.tableComment){
            let cell = self.tableComment.cellForRowAtIndexPath(indexPath) as! CommentExtentTableViewCell
            print(indexPath.row)
            
            if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
                selectedCellIndexPath = nil
                cell.hideComment()
                
            } else {
                selectedCellIndexPath = indexPath
                cell.showComment()
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if selectedCellIndexPath != nil {
                // This ensures, that the cell is fully visible once expanded
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
            }
            resizeCommentTableView()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView == self.tblSearchResults){
            return 48.0
        }
        else if(tableView == self.tableComment){
            if selectedCellIndexPath == indexPath {
                return selectedCellHeight
            }
            return unselectedCellHeight
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == self.tableComment){
            let cell = self.tableComment.cellForRowAtIndexPath(indexPath) as! CommentExtentTableViewCell
            cell.hideComment()
        }
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
                        //                        print("Result \(result.attributedFullText) with placeID \(result.placeID)")
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
    func buttonDeleteAction(sender: UIButton){
        print(sender.tag)
        let cell = sender.superview as! CommentExtentTableViewCell
        self.tableCommentData.removeAtIndex(sender.tag)
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        self.tableComment.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        selectedCellIndexPath = nil
        self.tableComment.reloadData()
        resizeCommentTableView()
        print(cell.index.row)
        if(tableCommentData.count == 0){
            hideCommentTable()
        }
    }
    
    func resizeCommentTableView(){
        var height = CGFloat(tableCommentData.count) * unselectedCellHeight
        if selectedCellIndexPath != nil{
            height = height + selectedCellHeight - unselectedCellHeight
        }
        if tableCommentData.count >= 6{
            height = 6 * unselectedCellHeight
        }
        self.tableComment.frame.size.height = height
        self.tableCommentBlurView.frame.size.height = height+20
        print(height)
    }
    
    func showCommentTable(){
        if tableComment != nil{
            tableComment.hidden = false
            
            UIView.animateWithDuration(0.25, animations:({
                self.resizeCommentTableView()
            }), completion: nil)
        }
        if blurViewNavigationBar != nil{
            blurViewNavigationBar.hidden = false
        }
    }
    
    func hideCommentTable(){
        if tableComment != nil{
            UIView.animateWithDuration(0.2, animations:({
                self.tableComment.frame.size.height = 0
                self.tableCommentBlurView.frame.size.height = 0
            }), completion: { (temp: Bool) in
                if temp {
                    self.tableCommentBlurView.hidden = true
                    self.tableComment.hidden = true
                }
            })
        }
        if blurViewNavigationBar != nil{
            blurViewNavigationBar.hidden = true
        }
    }
    
    
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
            print("1 UP")
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 296 && token {
            print("1 DOWN")
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_2(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 296 && token {
            print("2 UP")
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 346 && token {
            print("2 DOWN")
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_3(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 346 && token {
            print("3 UP")
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 396 && token {
            print("3 DOWN")
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_4(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 396 && token {
            print("4 UP")
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 446 && token {
            print("4 DOWN")
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