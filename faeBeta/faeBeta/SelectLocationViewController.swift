//
//  SelectLocationViewController.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SelectLocationViewController: UIViewController, MKMapViewDelegate {
    
    weak var delegate: BoardsSearchDelegate?
    
    var slMapView: MKMapView!
    var imgPinOnMap: UIImageView!
    var btnCancel: UIButton!
    var btnLocat: FMLocateSelf!
    var buttonSetLocationOnMap: UIButton!
    var btnSelect: FMDistIndicator!
    var lblSearchContent: UILabel!
    var routeAddress: RouteAddress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapView()
        loadSearchBar()
        loadButtons()
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
            anView.invisibleOn()
            return anView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = mapView.convert(mapCenter, toCoordinateFrom: nil)
        let location = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
        General.shared.getAddress(location: location) { (address) in
            guard let addr = address as? String else { return }
            DispatchQueue.main.async {
                self.lblSearchContent.text = addr
                self.routeAddress = RouteAddress(name: addr, coordinate: location.coordinate)
            }
        }
    }

    func loadMapView() {
        slMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        slMapView.showsUserLocation = true
        slMapView.delegate = self
        slMapView.showsPointsOfInterest = false
        slMapView.showsCompass = false
        slMapView.tintColor = UIColor._2499090()
        view.addSubview(slMapView)
        
        let camera = slMapView.camera
        camera.altitude = Key.shared.dblAltitude
        camera.centerCoordinate = Key.shared.selectedLoc
        slMapView.setCamera(camera, animated: false)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(camera.centerCoordinate, 800, 800)
        slMapView.setRegion(coordinateRegion, animated: false)
        
        imgPinOnMap = UIImageView(frame: CGRect(x: screenWidth / 2 - 24, y: screenHeight / 2 - 52, width: 48, height: 52))
        imgPinOnMap.image = BoardsSearchViewController.boolToDestination ? #imageLiteral(resourceName: "icon_destination") : #imageLiteral(resourceName: "icon_startpoint")
        view.addSubview(imgPinOnMap)
    }
    
    func loadSearchBar() {
        let imgSchbarShadow = UIImageView()
        imgSchbarShadow.frame = CGRect(x: 2, y: 17, width: 410 * screenWidthFactor, height: 60)
        imgSchbarShadow.image = #imageLiteral(resourceName: "mapSearchBar")
        view.addSubview(imgSchbarShadow)
        imgSchbarShadow.layer.zPosition = 500
        imgSchbarShadow.isUserInteractionEnabled = true
        
        // Left window on main map to open account system
        let btnLeftWindow = UIButton()
        btnLeftWindow.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        imgSchbarShadow.addSubview(btnLeftWindow)
        btnLeftWindow.addTarget(self, action: #selector(self.actionBack(_:)), for: .touchUpInside)
        imgSchbarShadow.addConstraintsWithFormat("H:|-6-[v0(40.5)]", options: [], views: btnLeftWindow)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0(48)]", options: [], views: btnLeftWindow)
        btnLeftWindow.adjustsImageWhenDisabled = false
        
        let imgSearchIcon = UIImageView()
        imgSearchIcon.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        imgSchbarShadow.addSubview(imgSearchIcon)
        imgSchbarShadow.addConstraintsWithFormat("H:|-54-[v0(15)]", options: [], views: imgSearchIcon)
        imgSchbarShadow.addConstraintsWithFormat("V:|-23-[v0(15)]", options: [], views: imgSearchIcon)
        
        lblSearchContent = UILabel()
        lblSearchContent.textAlignment = .left
        lblSearchContent.lineBreakMode = .byTruncatingTail
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = UIColor._898989()
        imgSchbarShadow.addSubview(lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("H:|-78-[v0]-60-|", options: [], views: lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("V:|-18.5-[v0(25)]", options: [], views: lblSearchContent)
    }
    
    func loadButtons() {
        btnCancel = UIButton()
        btnCancel.setImage(#imageLiteral(resourceName: "cancelSelectLocation"), for: .normal)
        view.addSubview(btnCancel)
        btnCancel.addTarget(self, action: #selector(self.actionBack(_:)), for: .touchUpInside)
        view.addConstraintsWithFormat("H:|-20-[v0(63)]", options: [], views: btnCancel)
        view.addConstraintsWithFormat("V:[v0(63)]-11-|", options: [], views: btnCancel)
        
        btnLocat = FMLocateSelf()
        btnLocat.removeTarget(nil, action: nil, for: .touchUpInside)
        btnLocat.addTarget(self, action: #selector(self.actionSelfPosition(_:)), for: .touchUpInside)
        view.addSubview(btnLocat)
        view.addConstraintsWithFormat("H:[v0(63)]-20-|", options: [], views: btnLocat)
        view.addConstraintsWithFormat("V:[v0(63)]-11-|", options: [], views: btnLocat)
        
        btnSelect = FMDistIndicator()
        btnSelect.frame.origin.y = screenHeight - 74
        btnSelect.lblDistance.text = "Select"
        btnSelect.isUserInteractionEnabled = true
        view.addSubview(btnSelect)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        btnSelect.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(_ tap: UITapGestureRecognizer) {
        guard routeAddress != nil else { return }
        navigationController?.popViewController(animated: false)
        delegate?.sendLocationBack?(address: routeAddress)
    }
    
    func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    func actionSelfPosition(_ sender: UIButton!) {
        let camera = slMapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        slMapView.setCamera(camera, animated: false)
    }
}
