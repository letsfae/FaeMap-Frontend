//
//  ChatSendLocation.swift
//  faeBeta
//
//  Created by Yue on 7/25/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

protocol LocationSendDelegate {
    func sendPickedLocation(lat : CLLocationDegrees, lon : CLLocationDegrees, screenShot : NSData)
}

class ChatSendLocationController: UIViewController, GMSMapViewDelegate, CustomSearchControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var widthFactor : CGFloat = 375 / 414
    var heightFactor : CGFloat = 667 / 736
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    var locationDelegate : LocationSendDelegate!
    
    // MARK: -- Location
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var willAppearFirstLoad = false
    
    // MARK: -- Map main screen Objects
    var faeMapView: GMSMapView!
    var buttonSelfPosition: UIButton!
    var buttonCancelSelectLocation: UIButton!
    var buttonSetLocationOnMap: UIButton!
    
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
    var searchBarSubviewButton: UIButton!
    
    //MARK: -- Coordinates to send
    var latitudeForPin: CLLocationDegrees = 0.0
    var longitudeForPin: CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        widthFactor = screenWidth / 414
        heightFactor = screenHeight / 736
        loadMapView()
        loadTableView()
        configureCustomSearchController()
        loadButton()
        loadPin()
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    func jumpToLocationEnable(){
//        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("LocationEnableViewController")as! LocationEnableViewController
//        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func loadMapView() {
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        faeMapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        faeMapView.myLocationEnabled = true
        faeMapView.delegate = self
        self.view = faeMapView
    }
    
    func loadPin() {
        let pinImage = UIImageView(frame: CGRectMake(186 * widthFactor, 326 * heightFactor, 45 * widthFactor, 47 * heightFactor))
        pinImage.image = UIImage(named: "chat_map_currentLoc")
        self.view.addSubview(pinImage)
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        customSearchController.customSearchBar.endEditing(true)
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if willAppearFirstLoad {
            currentLocation = locManager.location
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
            faeMapView.camera = camera
            willAppearFirstLoad = false
        }
    }
    
    func configureCustomSearchController() {
        searchBarSubview = UIView(frame: CGRectMake(8 * widthFactor, 23 * heightFactor, (screenWidth - 8 * 2 * widthFactor), 48 * heightFactor))
        
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0, 5 * heightFactor, 398 * widthFactor, 38.0 * heightFactor), searchBarFont: UIFont(name: "AvenirNext-Medium", size: 18.0)!, searchBarTextColor: colorFae, searchBarTintColor: UIColor.whiteColor())
        customSearchController.customSearchBar.placeholder = "Search Address or Place                                  "
        customSearchController.customDelegate = self
        customSearchController.customSearchBar.layer.borderWidth = 2.0
        customSearchController.customSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
        
        searchBarSubview.addSubview(customSearchController.customSearchBar)
        searchBarSubview.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(searchBarSubview)
        
        searchBarSubview.layer.borderColor = UIColor.whiteColor().CGColor
        searchBarSubview.layer.borderWidth = 1.0
        searchBarSubview.layer.cornerRadius = 2.0
        searchBarSubview.layer.shadowOpacity = 0.5
        searchBarSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        searchBarSubview.layer.shadowRadius = 5.0
        searchBarSubview.layer.shadowColor = UIColor.blackColor().CGColor
        
        searchBarSubviewButton = UIButton(frame: CGRectMake(8 * widthFactor, 23 * heightFactor, 398 * widthFactor, 48 * heightFactor))
        searchBarSubview.addSubview(searchBarSubviewButton)
        searchBarSubviewButton.addTarget(self, action: #selector(ChatSendLocationController.actionActiveSearchBar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func loadButton() {
        buttonSelfPosition = UIButton(frame: CGRectMake(screenWidth - (16+59) *  widthFactor, screenHeight - 59 * widthFactor - 75 * heightFactor, 59 * widthFactor, 59 * widthFactor))
        buttonSelfPosition.setImage(UIImage(named: "self_position"), forState: .Normal)
        self.view.addSubview(buttonSelfPosition)
        buttonSelfPosition.addTarget(self, action: #selector(ChatSendLocationController.actionSelfPosition(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonCancelSelectLocation = UIButton(frame: CGRectMake(16 * widthFactor, screenHeight - 59 * widthFactor - 75 * heightFactor, 59 * widthFactor, 59 * widthFactor))
        buttonCancelSelectLocation.setImage(UIImage(named: "cancelSelectLocation"), forState: .Normal)
        self.view.addSubview(buttonCancelSelectLocation)
        buttonCancelSelectLocation.addTarget(self, action: #selector(ChatSendLocationController.actionCancelSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonSetLocationOnMap = UIButton(frame: CGRectMake(0, screenHeight - 65 * heightFactor, screenWidth, 65 * heightFactor))
        buttonSetLocationOnMap.setTitle("Send Location", forState: .Normal)
        buttonSetLocationOnMap.setTitle("Send Location", forState: .Highlighted)
        buttonSetLocationOnMap.setTitleColor(colorFae, forState: .Normal)
        buttonSetLocationOnMap.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        self.view.addSubview(buttonSetLocationOnMap)
        buttonSetLocationOnMap.addTarget(self, action: #selector(ChatSendLocationController.actionSetLocationForComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
    
    func actionCancelSelectLocation(sender: UIButton!) {
        self.navigationController?.popViewControllerAnimated(true)
//        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func actionSetLocationForComment(sender: UIButton!) {
        UIGraphicsBeginImageContext(self.faeMapView.frame.size)
        self.faeMapView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenShotImage = UIGraphicsGetImageFromCurrentImageContext()
        self.navigationController?.popViewControllerAnimated(true)
        locationDelegate.sendPickedLocation(self.latitudeForPin, lon: self.longitudeForPin, screenShot : screenShotImage!.highestQualityJPEGNSData)
    }
    
    func actionActiveSearchBar(sender: UIButton!) {
        self.customSearchController.customSearchBar.becomeFirstResponder()
    }
    
    func loadTableView() {
        uiviewTableSubview = UIView(frame: CGRectMake(0, 0, 398 * widthFactor, 0))
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
        self.view.addSubview(uiviewTableSubview)
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tblSearchResults){
            return placeholder.count
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
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView == self.tblSearchResults){
            return 48.0
        }
            
        else{
            return 0
        }
    }
    
    func searchBarTableHideAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRectMake(0, 0, 398 * self.widthFactor, 0)
            self.uiviewTableSubview.frame = CGRectMake(8 * self.widthFactor, (23+53) * self.heightFactor, 398 * self.widthFactor, 0)
        }), completion: nil)
    }
    
    func searchBarTableShowAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRectMake(0, 0, 398 * self.widthFactor, 240 * self.heightFactor)
            self.uiviewTableSubview.frame = CGRectMake(8 * self.widthFactor, (23+53) * self.heightFactor, 398 * self.widthFactor, 240 * self.heightFactor)
        }), completion: nil)
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
}
