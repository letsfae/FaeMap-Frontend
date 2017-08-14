//
//  LocationPickerMini.swift
//  faeBeta
//
//  Created by User on 14/02/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class LocationPickerMini: UIView {
    
    let widthFactor: CGFloat = screenWidth / 414
    let heightFactor: CGFloat = screenHeight / 736
    
    weak var locationDelegate: LocationSendDelegate!
    
    // MARK: -- Map main screen Objects
    var mapView: MKMapView!
    var buttonSearch: UIButton!
    var buttonShareLocation: UIButton!
    var buttonSend: UIButton!
    
    // MARK: -- Coordinates to send
    var latitudeForPin: CLLocationDegrees = 0.0
    var longitudeForPin: CLLocationDegrees = 0.0
    
    init() {
        // super.init(frame : CGRect(x: 0, y: screenHeight - 271 - 64, width: screenWidth, height: 271))
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 271))
        loadMapView()
        loadButton()
        loadPin()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadMapView() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 271))
        mapView.layer.zPosition = 100
        mapView.showsPointsOfInterest = false
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        mapView.tintColor = UIColor._2499090()
        addSubview(mapView)
        let selfLoc = CLLocationCoordinate2D(latitude: LocManager.shared.curtLat, longitude: LocManager.shared.curtLong)
        let camera = mapView.camera
        camera.centerCoordinate = selfLoc
        mapView.setCamera(camera, animated: false)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 800, 800)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func loadPin() {
        let pinImage = UIImageView(frame: CGRect(x: screenWidth / 2 - 19, y: 89, width: 38, height: 42))
        pinImage.image = UIImage(named: "locationMiniPin")
        pinImage.layer.zPosition = 101
        mapView.addSubview(pinImage)
    }
    
    func loadButton() {
        buttonSearch = UIButton(frame: CGRect(x: 20, y: 204, width: 51, height: 51))
        buttonSearch.setImage(UIImage(named: "locationSearch"), for: .normal)
        buttonSearch.layer.zPosition = 101
        addSubview(buttonSearch)
        //buttonShareLocation = UIButton(frame: CGRect(x: 81, y: 204, width: 51, height: 51))
        //buttonShareLocation.setImage(UIImage(named: "locationShare"), for: .normal)
        //buttonShareLocation.layer.zPosition = 101
        //addSubview(buttonShareLocation)
        buttonSend = UIButton(frame: CGRect(x: screenWidth - 71, y: 204, width: 51, height: 51))
        buttonSend.setImage(UIImage(named: "locationSend"), for: .normal)
        buttonSend.layer.zPosition = 101
        addSubview(buttonSend)
    }
    
    func actionSelfPosition(_ sender: UIButton) {
        let camera = mapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        mapView.setCamera(camera, animated: true)
    }
    
}
