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

class FaeMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: -- Common Used Vars and Constants
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
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
    
    // MARK: -- Blur View Pin Buttons and Labels
    var uiviewPinSelections: UIView!
    
    var blurViewMap: UIVisualEffectView!
    var buttonSubmitMedia: UIButton!
    var buttonSubmitLive: UIButton!
    var buttonSubmitComment: UIButton!
    var buttonSubmitEvent: UIButton!
    var buttonSubmitFaevor: UIButton!
    var buttonSubmitNow: UIButton!
    var buttonSubmitJoinMe: UIButton!
    var buttonSubmitSell: UIButton!
    var buttonSubmitIcons: UIButton!
    
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
    
    var buttonSubmitClose: UIButton!
    
    // MARK: -- Create Comment Pin
    var uiviewCreateCommentPin: UIView!
    var labelSelectLocationContent: UILabel!
    
    // MARK: -- Create Pin
    var imagePinOnMap: UIImageView!
    var buttonSetLocationOnMap: UIButton!
    var isInPinLocationSelect = false
    
    // MARK: -- My Position Marker
    var myPositionInsideMarker: UIImageView!
    var myPositionOutsideMarker: UIImageView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMapView()
        loadTransparentNavBarItems()
        loadButton()
        loadBlurAndPinSelection()
        blurViewMap.center.y = screenHeight*1.5
        
        loadTableView()
        configureCustomSearchController()
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
        loadPositionAnimateImage()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            currentLocation = locManager.location
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            self.actionSelfPosition(self.buttonSelfPosition)
            let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
            faeMapView.camera = camera
        }
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
            myPositionInsideMarker.center = selfPositionToPoint
            myPositionOutsideMarker.center = selfPositionToPoint
        }
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//        print("You taped at Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
        customSearchController.customSearchBar.endEditing(true)
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        let directionMap = position.bearing
        let direction: CGFloat = CGFloat(directionMap)
        let angle:CGFloat = ((360.0 - direction) * 3.14/180.0) as CGFloat
        buttonToNorth.transform = CGAffineTransformMakeRotation(angle)
        
        locManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            currentLocation = locManager.location
            let currentLatitude = currentLocation.coordinate.latitude
            let currentLongitude = currentLocation.coordinate.longitude
            let position = CLLocationCoordinate2DMake(currentLatitude, currentLongitude)
            let selfPositionToPoint = faeMapView.projection.pointForCoordinate(position)
            myPositionInsideMarker.center = selfPositionToPoint
            myPositionOutsideMarker.center = selfPositionToPoint
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
            })
        }
    }
    
//    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
//        var mapCenter = mapView.projection.pointForCoordinate(marker.position)
//        mapCenter.y = mapCenter.y - 150.0
//        let mapCenterCoordinate = mapView.projection.coordinateForPoint(mapCenter)
//        let camera = GMSCameraPosition.cameraWithTarget(mapCenterCoordinate, zoom: mapView.camera.zoom)
//        mapView.animateToCameraPosition(camera)
//        return true
//    }
    
    // MARK: -- Actions
    
    func actionSelfPosition(sender: UIButton!) {
        locManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            currentLocation = locManager.location
        }
        let currentLatitude = currentLocation.coordinate.latitude
        let currentLongitude = currentLocation.coordinate.longitude
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
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        for textFiled in textFieldArray {
            textFiled.endEditing(true)
        }
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
        self.labelSelectLocationContent.text = self.customSearchController.customSearchBar.text
        isInPinLocationSelect = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
    }
    
    func actionSubmitLocationForComment(sender: UIButton) {
        submitPinsHideAnimation()
        let commentMarker = GMSMarker()
        var mapCenter = faeMapView.center
        // Attention: the actual location of this marker is 6 points different from the displayed one
        mapCenter.y = mapCenter.y + 6.0
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        commentMarker.icon = UIImage(named: "comment_pin_marker")
        commentMarker.position = mapCenterCoordinate
        commentMarker.appearAnimation = kGMSMarkerAnimationPop
        commentMarker.map = faeMapView
        buttonToNorth.hidden = false
        buttonSelfPosition.hidden = false
        buttonChatOnMap.hidden = false
        buttonPinOnMap.hidden = false
        buttonSetLocationOnMap.hidden = true
        imagePinOnMap.hidden = true
        self.tabBarController?.tabBar.hidden = false
    }
    
    // MARK: -- Animations
    
    func loadPositionAnimateImage() {
        myPositionOutsideMarker = UIImageView(frame: CGRectMake(screenWidth/2-29, screenHeight/2-29, 58, 58))
        myPositionOutsideMarker.image = UIImage(named: "myPosition_outside")
        self.view.addSubview(myPositionOutsideMarker)
        myPositionInsideMarker = UIImageView(frame: CGRectMake(screenWidth/2-28, screenHeight/2-28, 56, 56))
        myPositionInsideMarker.image = UIImage(named: "myPosition_inside")
        self.view.addSubview(myPositionInsideMarker)
        myPostionAnimation()
    }
    
    func myPostionAnimation() {
        UIView.animateWithDuration(3, delay: 0, options: [.Repeat, .Autoreverse], animations: ({
            self.myPositionOutsideMarker.frame = CGRectMake(self.screenWidth/2-40, self.screenHeight/2-40, 80, 80)
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
        self.blurViewMap.contentView.addSubview(uiviewCreateCommentPin)
        
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
        
        let buttonCommentSubmit = UIButton(frame: CGRectMake(0, 671, screenWidth, 65))
        buttonCommentSubmit.setTitle("Submit!", forState: .Normal)
        buttonCommentSubmit.setTitle("Submit!", forState: .Highlighted)
        buttonCommentSubmit.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonCommentSubmit.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonCommentSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonCommentSubmit.backgroundColor = UIColor(red: 194/255, green: 229/255, blue: 159/255, alpha: 1.0)
        self.uiviewCreateCommentPin.addSubview(buttonCommentSubmit)
        buttonCommentSubmit.addTarget(self, action: #selector(FaeMapViewController.actionSubmitLocationForComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.blurViewMap.contentView.addSubview(uiviewCreateCommentPin)
        
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
        
        buttonSubmitMedia = createSubmitButton(35, y: 146, width: 90, height: 90, picName: "submit_media")
        buttonSubmitLive = createSubmitButton(163, y: 146, width: 90, height: 90, picName: "submit_live")
        buttonSubmitComment = createSubmitButton(291, y: 146, width: 90, height: 90, picName: "submit_comment")
        buttonSubmitComment.addTarget(self, action: #selector(FaeMapViewController.actionCreateCommentPin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonSubmitEvent = createSubmitButton(35, y: 302, width: 90, height: 90, picName: "submit_event")
        buttonSubmitFaevor = createSubmitButton(163, y: 302, width: 90, height: 90, picName: "submit_faevor")
        buttonSubmitNow = createSubmitButton(291, y: 302, width: 90, height: 90, picName: "submit_now")
        
        buttonSubmitJoinMe = createSubmitButton(35, y: 458, width: 90, height: 90, picName: "submit_joinme")
        buttonSubmitSell = createSubmitButton(163, y: 458, width: 90, height: 90, picName: "submit_sell")
        buttonSubmitIcons = createSubmitButton(291, y: 458, width: 90, height: 90, picName: "submit_icons")
        
        labelSubmitMedia = createSubmitLabel(32, y: 243, width: 95, height: 27, title: "Media")
        labelSubmitLive = createSubmitLabel(160, y: 243, width: 95, height: 27, title: "Live")
        labelSubmitComment = createSubmitLabel(288, y: 243, width: 95, height: 27, title: "Comment")
        
        labelSubmitEvent = createSubmitLabel(32, y: 399, width: 95, height: 27, title: "Event")
        labelSubmitFaevor = createSubmitLabel(160, y: 399, width: 95, height: 27, title: "Faevor")
        labelSubmitNow = createSubmitLabel(288, y: 399, width: 95, height: 27, title: "Now")
        
        labelSubmitJoinMe = createSubmitLabel(32, y: 555, width: 95, height: 27, title: "Join Me!")
        labelSubmitSell = createSubmitLabel(160, y: 555, width: 95, height: 27, title: "Sell")
        labelSubmitIcons = createSubmitLabel(288, y: 555, width: 95, height: 27, title: "Icons")
        
        buttonSubmitClose = UIButton(frame: CGRectMake(0, 671, screenWidth, 65))
        buttonSubmitClose.setTitle("Close", forState: .Normal)
        buttonSubmitClose.setTitle("Close", forState: .Highlighted)
        buttonSubmitClose.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonSubmitClose.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonSubmitClose.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSubmitClose.backgroundColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 0.5)
        self.uiviewPinSelections.addSubview(buttonSubmitClose)
        buttonSubmitClose.addTarget(self, action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.blurViewMap.contentView.addSubview(uiviewPinSelections)
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
        buttonToNorth.setImage(UIImage(named: "compass"), forState: .Normal)
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
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholder.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customCellForAddressSearch", forIndexPath: indexPath) as! CustomCellForAddressSearch
        cell.labelCellContent.text = placeholder[indexPath.row].attributedFullText.string
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48.0
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
                        print("Result \(result.attributedFullText) with placeID \(result.placeID)")
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
        print(index)
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
                textFieldArray[arrNum].resignFirstResponder()
                textFieldArray[arrNum].text = ""
                if arrNum != 0 {
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