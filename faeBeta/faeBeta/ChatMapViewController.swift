//
//  ChatMapViewController.swift
//  faeBeta
//
//  Created by 王彦翔 on 16/7/28.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ChatMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let navigationBarHeight : CGFloat = 20
    
    
    var faeMapView: GMSMapView!
    
    // address view
    var viewAddress: UIView!
    var labelStreet: UILabel!
    var labelCity: UILabel!
    var labelCountry: UILabel!
    
    // pop up view
    var viewPopUp: UIView!
    var buttonSave: UIButton!
    var buttonShare: UIButton!
    
    var chatLocation: CLLocation!
    var chatLatitude: CLLocationDegrees = 34.0205378
    var chatLongitude: CLLocationDegrees = -118.2854081
    var chatMarker: GMSMarker!
    
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees!
    var currentLongitude: CLLocationDegrees!
    var myPositionIcon: UIImageView!
    var willAppearFirstLoad = false
    var startUpdatingLocation = false
    

    
    var buttonTopLeft: UIButton!
    var buttonTopRight: UIButton!
    var buttonBottomLeft: UIButton!
    var buttonBottomRight: UIButton!
    
    var imagePinOnMap: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        loadMapView()
        loadButton()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        willAppearFirstLoad = true
    }
    
    override func viewDidAppear(animated: Bool){
        buttonBottomLeftAction(UIButton())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: UITouch = touches.first{
            if(touch.view != viewPopUp && touch.view != buttonSave && touch.view != buttonShare){
                hidePopUp()
            }
        }
    }
    
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        print("You taped at Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
        hidePopUp()
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {

        if startUpdatingLocation {
            currentLocation = locManager.location
            self.currentLatitude = currentLocation.coordinate.latitude
            self.currentLongitude = currentLocation.coordinate.longitude
            let position = CLLocationCoordinate2DMake(self.currentLatitude, self.currentLongitude)
            let selfPositionToPoint = faeMapView.projection.pointForCoordinate(position)
            myPositionIcon.center = selfPositionToPoint
        }
    }
    
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
            myPositionIcon.center = selfPositionToPoint
        }
    }
    
    func loadMapView() {
        // load map
        let camera = GMSCameraPosition.cameraWithLatitude(chatLatitude, longitude: chatLongitude, zoom: 17)
        faeMapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        faeMapView.myLocationEnabled = true
        faeMapView.delegate = self
        
        self.view = faeMapView
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        startUpdatingLocation = true
        
        imagePinOnMap = UIImageView(frame: CGRectMake(screenWidth/2-19, screenHeight/2-41, 46, 50))
        imagePinOnMap.image = UIImage(named: "comment_pin_image")
        imagePinOnMap.hidden = true
        
        
        // load address
        viewAddress = UIView(frame: CGRect(x: 0, y: screenHeight - 91, width: screenWidth, height: 125))
        viewAddress.layer.cornerRadius = 25
        viewAddress.backgroundColor = UIColor.whiteColor()
        
        labelCity = UILabel(frame: CGRectMake((screenWidth-193)/2, 21, 193, 20))
        labelCity.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        labelCity.textAlignment = .Center
        labelCity.text = "Address is not available"
        
        labelStreet = UILabel(frame: CGRectMake((screenWidth-193)/2, 41, 193, 17))
        labelStreet.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        labelStreet.textAlignment = .Center
        labelStreet.text = "City is not available"
        
        labelCountry = UILabel(frame: CGRectMake((screenWidth-193)/2, 58, 193, 17))
        labelCountry.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
        labelCountry.textAlignment = .Center
        labelCountry.text = "Country is not available"
        
        viewAddress.addSubview(labelCountry)
        viewAddress.addSubview(labelStreet)
        viewAddress.addSubview(labelCity)
        faeMapView.addSubview(viewAddress)
        
        
        // load pop up dialog
        viewPopUp = UIView(frame: CGRect(x: screenWidth - 179, y: 62, width: 166, height: 90))
        viewPopUp.backgroundColor = UIColor(patternImage: UIImage(named: "chat_map_popup")!)
        viewPopUp.hidden = true
        
        buttonShare = UIButton(frame: CGRect(x:26, y: 30, width: 40, height: 51))
        buttonShare.setImage(UIImage(named: "map_namecard_share"), forState: .Normal)
        buttonShare.addTarget(self, action: #selector(buttonShareAction(_:)), forControlEvents: .TouchUpInside)
        
        buttonSave = UIButton(frame: CGRect(x:91, y: 30, width: 44, height: 51))
        buttonSave.setImage(UIImage(named: "chat_map_save"), forState: .Normal)
        buttonSave.addTarget(self, action: #selector(buttonSaveAction(_:)), forControlEvents: .TouchUpInside)
        
        viewPopUp.addSubview(buttonShare)
        viewPopUp.addSubview(buttonSave)
        faeMapView.addSubview(viewPopUp)
        
        loadChatMarker()
        
        myPositionIcon = UIImageView(frame: CGRectMake(screenWidth/2-12, screenHeight/2-20, 12, 20))
        myPositionIcon.image = UIImage(named: "chat_map_myPosition")
//        faeMapView.addSubview(myPositionIcon)
        
    }
    
    func loadButton(){
        buttonTopLeft = UIButton(frame: CGRect(x:15, y: 26, width: 30, height: 30))
        buttonTopLeft.setImage(UIImage(named: "chat_map_topLeft")!, forState:.Normal)
        buttonTopLeft.setImage(UIImage(named: "chat_map_topLeft")!, forState:.Highlighted)
        buttonTopLeft.addTarget(self, action: #selector(buttonTopLeftAction(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonTopLeft)
        
        buttonTopRight = UIButton(frame: CGRect(x:screenWidth-15-31, y: 26, width: 30, height: 30))
        buttonTopRight.setImage(UIImage(named: "chat_map_topRight")!, forState:.Normal)
        buttonTopRight.setImage(UIImage(named: "chat_map_topRight")!, forState:.Highlighted)
        buttonTopRight.addTarget(self, action: #selector(buttonTopRightAction(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonTopRight)
        
        buttonBottomLeft = UIButton(frame: CGRect(x:20, y: screenHeight - 164, width: 60, height: 60))
        buttonBottomLeft.backgroundColor = UIColor(patternImage: UIImage(named: "chat_map_bottomLeft")!)
        buttonBottomLeft.addTarget(self, action: #selector(buttonBottomLeftAction(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonBottomLeft)
        
        buttonBottomRight = UIButton(frame: CGRect(x:screenWidth-20-60, y: screenHeight - 164, width: 60, height: 60))
        buttonBottomRight.backgroundColor = UIColor(patternImage: UIImage(named: "self_position")!)
        buttonBottomRight.addTarget(self, action: #selector(buttonBottomRightAction(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonBottomRight)
    }
    
    func loadChatMarker(){
        let position = CLLocationCoordinate2DMake(chatLatitude+0.0002, chatLongitude)
        chatMarker = GMSMarker(position: position)
//        chatMarker.title = "chat";
        chatMarker.icon = UIImage(named: "chat_map_currentLoc")
        chatMarker.tracksViewChanges = true
        chatMarker.map = faeMapView;
    }
    
    func hidePopUp(){
        viewPopUp.hidden = true
    }
    
    func buttonTopLeftAction(sender: UIButton!){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func buttonTopRightAction(sender: UIButton!){
        viewPopUp.hidden = false
    }
    
    func buttonBottomLeftAction(sender: UIButton!){
        let camera = GMSCameraPosition.cameraWithLatitude(chatLatitude, longitude: chatLongitude, zoom: 17)
        faeMapView.camera = camera
        startUpdatingLocation = true
    }
    
    func buttonBottomRightAction(sender: UIButton!){
        currentLocation = locManager.location
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        faeMapView.camera = camera
    }
    
    func buttonShareAction(sender: UIButton!){
        print("Share")
    }
    
    func buttonSaveAction(sender: UIButton!){
        print("Save")
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
