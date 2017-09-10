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

class LocationPickerMini: UIView, MKMapViewDelegate {
    
    weak var locationDelegate: LocationSendDelegate!
    
    // MARK: properties
    var mapView: MKMapView!
    var btnSearch: UIButton!
    var btnSend: UIButton!
    
    // Coordinates to send
    var latitudeForPin: CLLocationDegrees = 0.0
    var longitudeForPin: CLLocationDegrees = 0.0
    
    // MARK: init
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 271))
        loadMapView()
        loadButton()
        loadPin()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup
    func loadMapView() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 271))
        mapView.layer.zPosition = 100
        mapView.showsPointsOfInterest = false
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.tintColor = UIColor._2499090()
        addSubview(mapView)
        let selfLoc = CLLocationCoordinate2D(latitude: LocManager.shared.curtLat, longitude: LocManager.shared.curtLong)
        let camera = mapView.camera
        camera.centerCoordinate = selfLoc
        mapView.setCamera(camera, animated: false)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 800, 800)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let identifier = "self_selected_mode"
            var anView: SelfAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SelfAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = SelfAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            return anView
        }
        
        return nil
        
    }
    
    func loadPin() {
        let pinImage = UIImageView(frame: CGRect(x: screenWidth / 2 - 19, y: 89, width: 38, height: 42))
        pinImage.image = UIImage(named: "locationMiniPin")
        pinImage.layer.zPosition = 101
        mapView.addSubview(pinImage)
    }
    
    func loadButton() {
        btnSearch = UIButton(frame: CGRect(x: 20, y: 204, width: 51, height: 51))
        btnSearch.setImage(UIImage(named: "locationSearch"), for: .normal)
        btnSearch.layer.zPosition = 101
        addSubview(btnSearch)
        btnSend = UIButton(frame: CGRect(x: screenWidth - 71, y: 204, width: 51, height: 51))
        btnSend.setImage(UIImage(named: "locationSend"), for: .normal)
        btnSend.layer.zPosition = 101
        addSubview(btnSend)
    }
    
    func actionSelfPosition(_ sender: UIButton) {
        let camera = mapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        mapView.setCamera(camera, animated: true)
    }
    
}
