//
//  ChatMapViewController.swift
//  faeBeta
//
//  Created by Yue on 16/7/28.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ChatMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - properties
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
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
    var buttonMiddleRight: UIButton!

    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        loadMapView()
        loadButton()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        willAppearFirstLoad = true
    }
    
    override func viewDidAppear(_ animated: Bool){
        buttonMiddleRightAction(UIButton())
    }

    // MARK: - handle touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch: UITouch = touches.first{
            if(touch.view != viewPopUp && touch.view != buttonSave && touch.view != buttonShare){
                hidePopUp()
            }
        }
    }
    
    //MARK: - Load map elements
    private func loadMapView() {
        // load map
        let camera = GMSCameraPosition.camera(withLatitude: chatLatitude, longitude: chatLongitude, zoom: 17)
        faeMapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        faeMapView.isMyLocationEnabled = true
        faeMapView.delegate = self
        
        self.view = faeMapView
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        startUpdatingLocation = true
        
        // load address
        viewAddress = UIView(frame: CGRect(x: 0, y: screenHeight - 91, width: screenWidth, height: 125))
        viewAddress.layer.cornerRadius = 25
        viewAddress.backgroundColor = UIColor.white
        
        labelCity = UILabel(frame: CGRect(x: (screenWidth-193)/2, y: 21, width: 193, height: 20))
        labelCity.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        labelCity.textAlignment = .center
        labelCity.text = "Address is not available"
        
        labelStreet = UILabel(frame: CGRect(x: (screenWidth-193)/2, y: 41, width: 193, height: 17))
        labelStreet.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        labelStreet.textAlignment = .center
        labelStreet.text = "City is not available"
        
        labelCountry = UILabel(frame: CGRect(x: (screenWidth-193)/2, y: 58, width: 193, height: 17))
        labelCountry.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
        labelCountry.textAlignment = .center
        labelCountry.text = "Country is not available"
        
        viewAddress.addSubview(labelCountry)
        viewAddress.addSubview(labelStreet)
        viewAddress.addSubview(labelCity)
        faeMapView.addSubview(viewAddress)

        // load pop up dialog
        viewPopUp = UIView(frame: CGRect(x: screenWidth - 179, y: 62, width: 166, height: 90))
        viewPopUp.backgroundColor = UIColor(patternImage: UIImage(named: "chat_map_popup")!)
        viewPopUp.isHidden = true
        
        buttonShare = UIButton(frame: CGRect(x:26, y: 30, width: 40, height: 51))
        buttonShare.setImage(UIImage(named: "map_namecard_share"), for: UIControlState())
        buttonShare.addTarget(self, action: #selector(buttonShareAction(_:)), for: .touchUpInside)
        
        buttonSave = UIButton(frame: CGRect(x:91, y: 30, width: 44, height: 51))
        buttonSave.setImage(UIImage(named: "chat_map_save"), for: UIControlState())
        buttonSave.addTarget(self, action: #selector(buttonSaveAction(_:)), for: .touchUpInside)
        
        viewPopUp.addSubview(buttonShare)
        viewPopUp.addSubview(buttonSave)
        faeMapView.addSubview(viewPopUp)
        
        loadChatMarker()
        
        myPositionIcon = UIImageView(frame: CGRect(x: screenWidth/2-12, y: screenHeight/2-20, width: 12, height: 20))
        myPositionIcon.image = UIImage(named: "chat_map_myPosition")
//        faeMapView.addSubview(myPositionIcon)
        
    }
    
    private func loadButton(){
        buttonMiddleRight = UIButton(frame: CGRect(x:screenWidth - 71, y: screenHeight - 230, width: 51, height: 51))
        buttonMiddleRight.setImage(UIImage(named: "pinCenterButton")!, for:UIControlState())
        buttonMiddleRight.adjustsImageWhenHighlighted = false
        buttonMiddleRight.addTarget(self, action: #selector(buttonMiddleRightAction(_:)), for: .touchUpInside)
        self.view.addSubview(buttonMiddleRight)
        
        buttonTopRight = UIButton(frame: CGRect(x:screenWidth-15-31, y: 26, width: 30, height: 30))
        buttonTopRight.setImage(UIImage(named: "chat_map_topRight")!, for: UIControlState())
        buttonTopRight.setImage(UIImage(named: "chat_map_topRight")!, for: .highlighted)
        buttonTopRight.addTarget(self, action: #selector(buttonTopRightAction(_:)), for: .touchUpInside)
        self.view.addSubview(buttonTopRight)
        
        buttonBottomLeft = UIButton(frame: CGRect(x:20, y: screenHeight - 164, width: 51, height: 51))
        buttonBottomLeft.setImage(UIImage(named: "cancelSelectLocation"), for: UIControlState())
        buttonBottomLeft.addTarget(self, action: #selector(buttonBottomLeftAction(_:)), for: .touchUpInside)
        self.view.addSubview(buttonBottomLeft)
        
        buttonBottomRight = UIButton(frame: CGRect(x:screenWidth - 71, y: screenHeight - 164, width: 60, height: 60))
        buttonBottomRight.setImage(UIImage(named: "mainScreenSelfPosition"), for: UIControlState())
        buttonBottomRight.addTarget(self, action: #selector(buttonBottomRightAction(_:)), for: .touchUpInside)
        self.view.addSubview(buttonBottomRight)
    }
    
    func loadChatMarker(){
        let position = CLLocationCoordinate2DMake(chatLatitude+0.0002, chatLongitude)
        chatMarker = GMSMarker(position: position)
        chatMarker.icon = UIImage(named: "chat_map_currentLoc")
        chatMarker.tracksViewChanges = true
        chatMarker.map = faeMapView;
    }
    
    //MARK: - button actions
    
    func buttonMiddleRightAction(_ sender: UIButton!){
        let camera = GMSCameraPosition.camera(withLatitude: chatLatitude, longitude: chatLongitude, zoom: 17)
        faeMapView.camera = camera
        startUpdatingLocation = true
    }
    
    func buttonTopRightAction(_ sender: UIButton!){
        viewPopUp.isHidden = false
    }
    
    func buttonBottomLeftAction(_ sender: UIButton!){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func buttonBottomRightAction(_ sender: UIButton!){
        currentLocation = locManager.location
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
        faeMapView.camera = camera
    }
    
    func buttonShareAction(_ sender: UIButton!){
        print("Share")
    }
    
    func buttonSaveAction(_ sender: UIButton!){
        print("Save")
    }
    
    //MARK: - GMS delegate
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You taped at Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
        hidePopUp()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        if startUpdatingLocation {
            currentLocation = locManager.location
            self.currentLatitude = currentLocation.coordinate.latitude
            self.currentLongitude = currentLocation.coordinate.longitude
            let position = CLLocationCoordinate2DMake(self.currentLatitude, self.currentLongitude)
            let selfPositionToPoint = faeMapView.projection.point(for: position)
            myPositionIcon.center = selfPositionToPoint
        }
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if willAppearFirstLoad {
            currentLocation = locManager.location
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
            faeMapView.camera = camera
            willAppearFirstLoad = false
            startUpdatingLocation = true
        }
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let selfPositionToPoint = faeMapView.projection.point(for: position)
            myPositionIcon.center = selfPositionToPoint
        }
    }
    
    //MARK: - utilities
    func hidePopUp(){
        viewPopUp.isHidden = true
    }
    
    func updateLocationInformation()
    {
//        var chatLatitude: CLLocationDegrees = 34.0205378
//        var chatLongitude: CLLocationDegrees = -118.2854081
    }

}
