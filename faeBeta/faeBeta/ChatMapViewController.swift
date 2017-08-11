//
//  ChatMapViewController.swift
//  faeBeta
//
//  Created by Yue on 16/7/28.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit
import CoreLocation

class ChatMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - properties
    let navigationBarHeight : CGFloat = 20
    
    var faeMapView: MKMapView!
    
    // address text
    var address1 = ""
    var address2 = ""
    var address3 = ""
    
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
    
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees!
    var currentLongitude: CLLocationDegrees!
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
        //self.navigationController?.isNavigationBarHidden = true
        loadMapView()
        loadButton()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = false
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
        faeMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        faeMapView.delegate = self
        view.addSubview(faeMapView)
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = false
        faeMapView.delegate = self
        faeMapView.showsUserLocation = true
        let camera = faeMapView.camera
        camera.centerCoordinate = CLLocationCoordinate2D(latitude: chatLatitude, longitude: chatLongitude)
        faeMapView.setCamera(camera, animated: false)
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        startUpdatingLocation = true
        
        // load address
        viewAddress = UIView(frame: CGRect(x: 0, y: screenHeight - 91, width: screenWidth, height: 125))
        viewAddress.layer.cornerRadius = 25
        viewAddress.backgroundColor = UIColor.white
        
        labelCity = UILabel(frame: CGRect(x: 30 , y: 41, width: screenWidth - 60, height: 20))
        labelCity.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        labelCity.textAlignment = .center
        labelCity.text = address2
        
        labelStreet = UILabel(frame: CGRect(x: 30, y: 21, width: screenWidth - 60, height: 17))
        labelStreet.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        labelStreet.textAlignment = .center
        labelStreet.text = address1
        
        labelCountry = UILabel(frame: CGRect(x: 30, y: 58, width: screenWidth - 60, height: 17))
        labelCountry.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
        labelCountry.textAlignment = .center
        labelCountry.text = address3
        
        self.viewAddress.addSubview(self.labelCountry)
        self.viewAddress.addSubview(self.labelStreet)
        self.viewAddress.addSubview(self.labelCity)
        self.faeMapView.addSubview(self.viewAddress)

        // load pop up dialog
        viewPopUp = UIView(frame: CGRect(x: screenWidth - 179, y: 62, width: 166, height: 90))
        viewPopUp.backgroundColor = UIColor(patternImage: UIImage(named: "chat_map_popup")!)
        viewPopUp.isHidden = true
        
        buttonShare = UIButton(frame: CGRect(x:26, y: 30, width: 40, height: 51))
        buttonShare.setImage(UIImage(named: "buttonShareOnCommentDetail"), for: UIControlState())
        buttonShare.addTarget(self, action: #selector(buttonShareAction(_:)), for: .touchUpInside)
        
        buttonSave = UIButton(frame: CGRect(x:91, y: 30, width: 44, height: 51))
        buttonSave.setImage(UIImage(named: "pinDetailSave"), for: UIControlState())
        buttonSave.addTarget(self, action: #selector(buttonSaveAction(_:)), for: .touchUpInside)
        
        viewPopUp.addSubview(buttonShare)
        viewPopUp.addSubview(buttonSave)
        faeMapView.addSubview(viewPopUp)
        loadChatMarker()
    }
    
    private func loadButton(){
        buttonMiddleRight = UIButton(frame: CGRect(x:screenWidth - 71, y: screenHeight - 230, width: 51, height: 51))
        buttonMiddleRight.setImage(UIImage(named: "pinCenterButton")!, for:UIControlState())
        buttonMiddleRight.adjustsImageWhenHighlighted = false
        buttonMiddleRight.addTarget(self, action: #selector(buttonMiddleRightAction(_:)), for: .touchUpInside)
        self.view.addSubview(buttonMiddleRight)
        
        buttonTopRight = UIButton(frame: CGRect(x:screenWidth-15-31, y: 26, width: 30, height: 30))
        buttonTopRight.setImage(UIImage(named: "mainScreenMore")!, for: UIControlState())
        buttonTopRight.setImage(UIImage(named: "mainScreenMore")!, for: .highlighted)
        buttonTopRight.addTarget(self, action: #selector(buttonTopRightAction(_:)), for: .touchUpInside)
        self.view.addSubview(buttonTopRight)
        
        buttonBottomLeft = UIButton(frame: CGRect(x:20, y: screenHeight - 164, width: 51, height: 51))
        buttonBottomLeft.setImage(UIImage(named: "cancelSelectLocation"), for: UIControlState())
        buttonBottomLeft.addTarget(self, action: #selector(buttonBottomLeftAction(_:)), for: .touchUpInside)
        self.view.addSubview(buttonBottomLeft)
        
        buttonBottomRight = UIButton(frame: CGRect(x:screenWidth - 71, y: screenHeight - 164, width: 51, height: 51))
        buttonBottomRight.setImage(UIImage(named: "mainScreenSelfPosition"), for: UIControlState())
        buttonBottomRight.addTarget(self, action: #selector(buttonBottomRightAction(_:)), for: .touchUpInside)
        self.view.addSubview(buttonBottomRight)
    }
    
    func loadChatMarker(){
        let position = CLLocationCoordinate2DMake(chatLatitude+0.0002, chatLongitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = position
        faeMapView.addAnnotation(annotation)
    }
    
    //MARK: - button actions
    
    func buttonMiddleRightAction(_ sender: UIButton!){
        let camera = faeMapView.camera
        camera.centerCoordinate = CLLocationCoordinate2D(latitude: chatLatitude, longitude: chatLongitude)
        faeMapView.setCamera(camera, animated: false)
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
        let camera = faeMapView.camera
        camera.centerCoordinate = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        faeMapView.setCamera(camera, animated: false)
    }
    
    func buttonShareAction(_ sender: UIButton!){
        print("Share")
    }
    
    func buttonSaveAction(_ sender: UIButton!){
        print("Save")
    }
    
    //MARK: - GMS delegate
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        print("You taped at Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
//        hidePopUp()
//    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let identifier = "self"
            var anView: SelfAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SelfAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = SelfAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            anView.selfIcon.image = #imageLiteral(resourceName: "chat_map_myPosition")
            return anView
        } else {
            let identifier = "place"
            var anView: PlacePinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            anView.assignImage(#imageLiteral(resourceName: "chat_map_currentLoc"))
            anView.imageView.frame = CGRect(x: 6, y: 10, width: 48, height: 54)
            anView.alpha = 1
            return anView
        }
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if willAppearFirstLoad {
            currentLocation = locManager.location
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            let camera = faeMapView.camera
            camera.centerCoordinate = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
            faeMapView.setCamera(camera, animated: false)
            willAppearFirstLoad = false
            startUpdatingLocation = true
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
