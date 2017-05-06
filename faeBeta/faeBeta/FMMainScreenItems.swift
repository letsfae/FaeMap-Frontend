//
//  MainScreenButtons.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController {
    
    // MARK: -- Load Map
    func loadMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 13.8)
        self.faeMapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        faeMapView.delegate = self
        
        faeMapView.preferredFrameRate = GMSFrameRate.maximum
        faeMapView.isIndoorEnabled = false
//        faeMapView.isBuildingsEnabled = false
//        faeMapView.settings.tiltGestures = false
        faeMapView.setMinZoom(9, maxZoom: 21)

        self.view = faeMapView
        
        let kMapStyle = "[{\"featureType\": \"poi.business\",\"stylers\": [{ \"visibility\": \"off\" }]}]"
        do {
            // Set the map style by passing a valid JSON string.
            faeMapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
        }

        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        
        // Default is true, if true, panGesture could not be detected
        self.faeMapView.settings.consumesGesturesInView = false
    }
    
    // MARK: -- Load Map Main Screen Buttons
    func loadButton() {
        // Left window on main map to open account system
        btnLeftWindow = UIButton()
        btnLeftWindow.setImage(UIImage(named: "mainScreenMore"), for: .normal)
        self.view.addSubview(btnLeftWindow)
        btnLeftWindow.addTarget(self, action: #selector(self.actionLeftWindowShow(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-15-[v0(30)]", options: [], views: btnLeftWindow)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: btnLeftWindow)
        btnLeftWindow.layer.zPosition = 500
        btnLeftWindow.adjustsImageWhenDisabled = false
        
        // Open main map search
        btnMainMapSearch = UIButton()
        btnMainMapSearch.setImage(UIImage(named: "mainScreenFaeLogo"), for: .normal)
        self.view.addSubview(btnMainMapSearch)
        btnMainMapSearch.addTarget(self, action: #selector(self.actionMainScreenSearch(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(33)]", options: [], views: btnMainMapSearch)
        self.view.addConstraintsWithFormat("V:|-22-[v0(36)]", options: [], views: btnMainMapSearch)
        NSLayoutConstraint(item: btnMainMapSearch, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        btnMainMapSearch.layer.zPosition = 500
        btnMainMapSearch.adjustsImageWhenDisabled = false
        
        // Wind bell
        btnWindBell = UIButton()
        btnWindBell.setImage(UIImage(named: "mainScreenWindBell"), for: .normal)
        self.view.addSubview(btnWindBell)
        self.view.addConstraintsWithFormat("H:[v0(26)]-16-|", options: [], views: btnWindBell)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: btnWindBell)
        btnWindBell.adjustsImageWhenDisabled = false
        
        // Click to back to north
        btnToNorth = UIButton(frame: CGRect(x: 22, y: 582*screenWidthFactor, width: 59, height: 59))
        view.addSubview(btnToNorth)
        btnToNorth.setImage(UIImage(named: "mainScreenNorth"), for: .normal)
        btnToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), for: .touchUpInside)
//        view.addConstraintsWithFormat("H:|-22-[v0(59)]", options: [], views: btnToNorth)
//        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: btnToNorth)
        btnToNorth.layer.zPosition = 500
        
        // Click to locate the current location
        btnSelfLocation = UIButton(frame: CGRect(x: 333*screenWidthFactor, y: 582*screenWidthFactor, width: 59, height: 59))
        view.addSubview(btnSelfLocation)
        btnSelfLocation.setImage(UIImage(named: "mainScreenSelfPosition"), for: .normal)
        btnSelfLocation.addTarget(self, action: #selector(self.actionSelfPosition(_:)), for: .touchUpInside)
//        view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: btnSelfLocation)
//        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: btnSelfLocation)
        btnSelfLocation.layer.zPosition = 500
        
        // Open chat view
        btnChatOnMap = UIButton(frame: CGRect(x: 12, y: 646*screenWidthFactor, width: 79, height: 79))
        btnChatOnMap.setImage(UIImage(named: "mainScreenNoChat"), for: .normal)
        btnChatOnMap.addTarget(self, action: #selector(self.actionChatWindowShow(_:)), for: .touchUpInside)
        view.addSubview(btnChatOnMap)
//        view.addConstraintsWithFormat("H:|-12-[v0(79)]", options: [], views: btnChatOnMap)
//        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: btnChatOnMap)
        btnChatOnMap.layer.zPosition = 500
        
        // Show the number of unread messages on main map
        labelUnreadMessages = UILabel(frame: CGRect(x: 55, y: 1, width: 25, height: 22))
        labelUnreadMessages.backgroundColor = UIColor.init(red: 102/255, green: 192/255, blue: 251/255, alpha: 1)
        labelUnreadMessages.layer.cornerRadius = 11
        labelUnreadMessages.layer.masksToBounds = true
        labelUnreadMessages.layer.opacity = 0.9
        labelUnreadMessages.text = "1"
        labelUnreadMessages.textAlignment = .center
        labelUnreadMessages.textColor = UIColor.white
        labelUnreadMessages.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        btnChatOnMap.addSubview(labelUnreadMessages)
        
        // Create pin on main map
        btnPinOnMap = UIButton(frame: CGRect(x: 323*screenWidthFactor, y: 646*screenWidthFactor, width: 79, height: 79))
        btnPinOnMap.setImage(UIImage(named: "mainScreenPinMap"), for: .normal)
        view.addSubview(btnPinOnMap)
        btnPinOnMap.addTarget(self, action: #selector(self.actionCreatePin(_:)), for: .touchUpInside)
//        view.addConstraintsWithFormat("H:[v0(79)]-12-|", options: [], views: btnPinOnMap)
//        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: btnPinOnMap)
        btnPinOnMap.layer.zPosition = 500
    }
}
