//
//  SelectLocationViewController.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class SelectLocationViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    var mapSelectLocation: GMSMapView!

    var imagePinOnMap: UIImageView!
    
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    var willAppearFirstLoad = false
    
    var buttonCancelSelectLocation: UIButton!
    var buttonSelfPosition: UIButton!
    var buttonSetLocationOnMap: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        locManager.requestAlwaysAuthorization()        
        willAppearFirstLoad = true
    }
    
    func loadMapView() {
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        self.mapSelectLocation = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapSelectLocation.myLocationEnabled = false
        mapSelectLocation.delegate = self
        self.view = mapSelectLocation
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        
        imagePinOnMap = UIImageView(frame: CGRectMake(screenWidth/2-19, screenHeight/2-41, 46, 50))
        imagePinOnMap.image = UIImage(named: "comment_pin_image")
        
        // Default is true, if true, panGesture could not be detected
        self.mapSelectLocation.settings.consumesGesturesInView = false
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if willAppearFirstLoad {
            currentLocation = locManager.location
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
            mapSelectLocation.camera = camera
            willAppearFirstLoad = false
        }
    }
    
    func loadButtons() {
        buttonCancelSelectLocation = UIButton(frame: CGRectMake(0, 0, 59, 59))
        buttonCancelSelectLocation.setImage(UIImage(named: "cancelSelectLocation"), forState: .Normal)
        self.view.addSubview(buttonCancelSelectLocation)
        buttonCancelSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionCancelSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonCancelSelectLocation.hidden = true
        self.view.addConstraintsWithFormat("H:|-18-[v0(59)]", options: [], views: buttonCancelSelectLocation)
        self.view.addConstraintsWithFormat("V:[v0(59)]-77-|", options: [], views: buttonCancelSelectLocation)
        
        buttonSelfPosition = UIButton()
        self.view.addSubview(buttonSelfPosition)
        buttonSelfPosition.setImage(UIImage(named: "self_position"), forState: .Normal)
        buttonSelfPosition.addTarget(self, action: #selector(FaeMapViewController.actionSelfPosition(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(59)]-18-|", options: [], views: buttonSelfPosition)
        self.view.addConstraintsWithFormat("V:[v0(59)]-77-|", options: [], views: buttonSelfPosition)
        
        buttonSetLocationOnMap = UIButton()
        buttonSetLocationOnMap.setTitle("Set Location", forState: .Normal)
        buttonSetLocationOnMap.setTitle("Set Location", forState: .Highlighted)
        buttonSetLocationOnMap.setTitleColor(colorFae, forState: .Normal)
        buttonSetLocationOnMap.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        self.view.addSubview(buttonSetLocationOnMap)
        buttonSetLocationOnMap.addTarget(self, action: #selector(FaeMapViewController.actionSetLocationForComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonSetLocationOnMap.hidden = true
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonSetLocationOnMap)
        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonSetLocationOnMap)
    }
    
    func actionCancelSelectLocation(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
}
