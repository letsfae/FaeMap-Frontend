//
//  MapViewController.swift
//  faeBeta
//  wrote by tianming
//  Created by blesssecret on 5/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    //6 plus 414 736 56.25
    //6      375 667 56.221
    //5      320 568 56.333
    
    let navigationBarHeight : CGFloat = 64.0
    var mapView: MGLMapView!
    
    //    var buttonPointNorth: UIButton!
    //    var buttonChatOnMap: UIButton!
    //    var buttonSetPinOnMap: UIButton!
    //    var buttonReturnToUserPlace: UIButton!
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        let shareAPI = LocalStorageManager()
        shareAPI.readLogInfo()
        if is_Login == 0 {
            self.jumpToWelcomeView()
        }
//        let user = FaeUser()
//        user.logOut()
        self.locationManager.delegate = self
        loadNavbarOnMap()
        
        initializeMap()
        loadTabbarOnMap()
        
        loadButtononPointNorth()
        loadButtonChatOnMap()
        loadButtonReturnToUserPlace()
        loadButtonSetPinOnMap()
        
    }
    override func viewWillAppear(animated: Bool) {
        let authstate = CLLocationManager.authorizationStatus()
        if(authstate == CLAuthorizationStatus.NotDetermined){
            print("Not Authorised")
            self.locationManager.requestAlwaysAuthorization()
        }
        else if(authstate == CLAuthorizationStatus.Denied){
            jumpToLocationEnable()
        }
    }
    func jumpToLocationEnable(){
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("LocationEnableViewController")as! LocationEnableViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }/*
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus ++++")
        switch status {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .Authorized:
            print(".Authorized")
            break
        case .Denied:
            print(".Denied")
            jumpToLocationEnable()
            break
        default:
            print("Unhandled authorization status")
            break
                
        }
    }*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func jumpToWelcomeView(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NavigationWelcomeViewController")as! NavigationWelcomeViewController
//        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = ViewController(nibName: "WelcomeViewController", bundle: nil)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func initializeMap() {
        let mapFrame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
        let mapStyleUrl = NSURL(string: "mapbox://styles/mapbox/emerald-v8")
        mapView = MGLMapView(frame: mapFrame, styleURL: mapStyleUrl)
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 34.023472,
            longitude: -118.285808),zoomLevel: 13, animated: false)
        
        self.view.addSubview(mapView)
    }
    
    func getUserLocation() {
        mapView.userTrackingMode = .Follow
    }
    
    func loadNavbarOnMap() {
        let navigationBar = self.navigationController?.navigationBar
        
        navigationBar!.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        //        self.navigationController?.navigationBar.translucent = false
        navigationBar!.shadowImage = UIImage(named: "transparent")
        navigationBar!.topItem?.title = ""
        
        self.addButtonMoreOnNavbar()
        self.addButtonProfileOnNavbar()
        self.addButtonNotificationOnNavbar()
    }
    func addButtonMoreOnNavbar() {
        let buttonMoreOnNavbar = UIButton(type: .Custom) as UIButton
        let buttonMoreOnNavbarWidth = (31.1/414) * screenWidth
        let buttonMoreOnNavbarHeight = (33/736) * screenHeight
        buttonMoreOnNavbar.frame = CGRectMake(0, 0, buttonMoreOnNavbarWidth, buttonMoreOnNavbarHeight)
        var imageButtonMore = UIImage(named: "navbar_more_left_on_map")! as UIImage
        imageButtonMore = imageButtonMore.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        buttonMoreOnNavbar.setImage(imageButtonMore, forState: .Normal)
        //        buttonMoreOnNavbar.addTarget(self, action: Selector(""), forControlEvents: .TouchUpInside)
        
        let barButtonItemMoreOnNavbar: UIBarButtonItem = UIBarButtonItem(customView: buttonMoreOnNavbar)
        self.navigationItem.setLeftBarButtonItem(barButtonItemMoreOnNavbar, animated: false)
    }
    
    func addButtonProfileOnNavbar() {
        let buttonProfileOnNavbar = UIButton(type: .Custom) as UIButton
        let buttonProfileOnNavbarWidth = (37.6/414) * screenWidth
        let buttonProfileOnNavbarHeight = (39/736) * screenHeight
        buttonProfileOnNavbar.frame = CGRectMake(0, 0, buttonProfileOnNavbarWidth, buttonProfileOnNavbarHeight)
        let imageButtonProfile = UIImage(named: "navbar_profile_center_on_map")
        buttonProfileOnNavbar.setImage(imageButtonProfile, forState: .Normal)
        self.navigationItem.titleView = buttonProfileOnNavbar
    }
    
    func addButtonNotificationOnNavbar() {
        let buttonNotificationOnNavbar = UIButton(type: .Custom) as UIButton
        let buttonNotificationOnNavbarWidth = (29/414) * screenWidth
        let buttonNotificationOnNavbarHeight = (33/736) * screenHeight
        buttonNotificationOnNavbar.frame = CGRectMake(0, 0, buttonNotificationOnNavbarWidth, buttonNotificationOnNavbarHeight)
        var imageButtonNotification = UIImage(named: "navbar_notification_on_map")! as UIImage
        imageButtonNotification = imageButtonNotification.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        buttonNotificationOnNavbar.setImage(imageButtonNotification, forState: .Normal)
        let barButtonNotificationOnNavbar: UIBarButtonItem = UIBarButtonItem(customView: buttonNotificationOnNavbar)
        self.navigationItem.setRightBarButtonItem(barButtonNotificationOnNavbar, animated: false)
    }
    
    func loadButtononPointNorth()  {
        var buttonPointNorth: UIButton!
        let xFloatButtonPointNorth = (26/414) * screenWidth
        let yFloatButtonPointNorth = (532/736) * screenHeight
        let buttonPointNorthWidth = (51/414) * screenWidth
        let buttonPointNorthHeight = (51/736) * screenHeight
        buttonPointNorth = UIButton(frame: CGRectMake(xFloatButtonPointNorth, yFloatButtonPointNorth, buttonPointNorthWidth, buttonPointNorthHeight))
        let image = UIImage(named: "point_north_on_map")! as UIImage
        buttonPointNorth.setImage(image, forState: .Normal)
        
        self.view.addSubview(buttonPointNorth)
    }
    
    func loadButtonChatOnMap() {
        var buttonChatOnMap: UIButton!
        let xFloatButtonChatOnMap = (18/414) * screenWidth
        let yFloatButtonChatOnMap = (598/736) * screenHeight
        let buttonChatOnMapWidth = (67/414) * screenWidth
        let buttonChatOnMapHeight = (67/736) * screenHeight
        buttonChatOnMap = UIButton(frame: CGRectMake(xFloatButtonChatOnMap, yFloatButtonChatOnMap, buttonChatOnMapWidth, buttonChatOnMapHeight))
        let image = UIImage(named: "chat_on_map")! as UIImage
        buttonChatOnMap.setImage(image, forState: .Normal)
        
        self.view.addSubview(buttonChatOnMap)
    }
    
    func loadButtonReturnToUserPlace() {
        var buttonReturnToUserPlace: UIButton!
        let xFloatButtonReturnToUserPlace = (337/414) * screenWidth
        let yFloatButtonReturnToUserPlace = (532/736) * screenHeight
        let buttonReturnToUserPlaceWidth = (51/414) * screenWidth
        let buttonReturnToUserPlaceHeight = (51/736) * screenHeight
        buttonReturnToUserPlace = UIButton(frame: CGRectMake(xFloatButtonReturnToUserPlace, yFloatButtonReturnToUserPlace, buttonReturnToUserPlaceWidth, buttonReturnToUserPlaceHeight))
        let image = UIImage(named: "return_to_user_location")! as UIImage
        buttonReturnToUserPlace.setImage(image, forState: .Normal)
        
        self.view.addSubview(buttonReturnToUserPlace)
    }
    
    func loadButtonSetPinOnMap() {
        var buttonSetPinOnMap: UIButton!
        let xFloatButtonSetPinOnMap = (329/414) * screenWidth
        let yFloatButtonSetPinOnMap = (598/736) * screenHeight
        let buttonSetPinOnMapWidth = (67/414) * screenWidth
        let buttonSetPinOnMapHeight = (67/736) * screenHeight
        buttonSetPinOnMap = UIButton(frame: CGRectMake(xFloatButtonSetPinOnMap, yFloatButtonSetPinOnMap, buttonSetPinOnMapWidth, buttonSetPinOnMapHeight))
        let image = UIImage(named: "set_pin_on_map")! as UIImage
        buttonSetPinOnMap.setImage(image, forState: .Normal)
        
        self.view.addSubview(buttonSetPinOnMap)
    }
    
    func loadTabbarOnMap() {
        let tabbar = self.tabBarController?.tabBar
        //        tabbar?.backgroundColor = UIColor.blueColor()
        //        tabbar?.backgroundImage = UIImage(named: "tabbar_fae_map")
        //        tabbar?.selectedItem?. = "Fae Map"
        //        tabbar?.selectedItem?.badgeValue = "1"
        tabbar?.tintColor = UIColor.redColor()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
