//
//  MainScreenButtons.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit
import CCHMapClusterController

extension FaeMapViewController {
    
    // MARK: -- Load Map
    func loadMapView() {
        faeMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        faeMapView.delegate = self
        view.addSubview(faeMapView)
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = false
        faeMapView.delegate = self
        faeMapView.showsUserLocation = true
        mapClusterManager = CCHMapClusterController(mapView: faeMapView)
        mapClusterManager.cellSize = 80
        mapClusterManager.marginFactor = 0.1
        mapClusterManager.delegate = self

        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
    }
    
    // MARK: -- Load Map Main Screen Buttons
    func loadButton() {
        // Left window on main map to open account system
        btnLeftWindow = UIButton()
        btnLeftWindow.setImage(UIImage(named: "mainScreenMore"), for: .normal)
        view.addSubview(btnLeftWindow)
        btnLeftWindow.addTarget(self, action: #selector(self.actionLeftWindowShow(_:)), for: .touchUpInside)
        view.addConstraintsWithFormat("H:|-15-[v0(30)]", options: [], views: btnLeftWindow)
        view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: btnLeftWindow)
        btnLeftWindow.layer.zPosition = 500
        btnLeftWindow.adjustsImageWhenDisabled = false
        
        // Open main map search
        btnMainMapSearch = UIButton()
        btnMainMapSearch.frame = CGRect(x: 0, y: 22, width: 33, height: 36)
        btnMainMapSearch.center.x = screenWidth / 2
        btnMainMapSearch.setImage(UIImage(named: "mainScreenFaeLogo"), for: .normal)
        view.addSubview(btnMainMapSearch)
        btnMainMapSearch.addTarget(self, action: #selector(self.actionMainScreenSearch(_:)), for: .touchUpInside)
        btnMainMapSearch.layer.zPosition = 500
        btnMainMapSearch.adjustsImageWhenDisabled = false
        
        // Wind bell
        btnWindBell = UIButton()
        btnWindBell.setImage(UIImage(named: "mainScreenWindBell"), for: .normal)
        view.addSubview(btnWindBell)
        view.addConstraintsWithFormat("H:[v0(26)]-16-|", options: [], views: btnWindBell)
        view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: btnWindBell)
        btnWindBell.adjustsImageWhenDisabled = false
        
        // Click to back to north
        btnToNorth = UIButton(frame: CGRect(x: 22, y: 582*screenWidthFactor, width: 59, height: 59))
        view.addSubview(btnToNorth)
        btnToNorth.setImage(UIImage(named: "mainScreenNorth"), for: .normal)
        btnToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), for: .touchUpInside)
        btnToNorth.layer.zPosition = 500
        
        // Click to locate the current location
        btnSelfLocation = UIButton(frame: CGRect(x: 333*screenWidthFactor, y: 582*screenWidthFactor, width: 59, height: 59))
        view.addSubview(btnSelfLocation)
        btnSelfLocation.setImage(UIImage(named: "mainScreenSelfPosition"), for: .normal)
        btnSelfLocation.addTarget(self, action: #selector(self.actionSelfPosition(_:)), for: .touchUpInside)
        btnSelfLocation.layer.zPosition = 500
        
        // Open chat view
        btnChatOnMap = UIButton(frame: CGRect(x: 12, y: 646*screenWidthFactor, width: 79, height: 79))
        btnChatOnMap.setImage(UIImage(named: "mainScreenNoChat"), for: .normal)
        btnChatOnMap.addTarget(self, action: #selector(self.actionChatWindowShow(_:)), for: .touchUpInside)
        view.addSubview(btnChatOnMap)
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
        btnPinOnMap.layer.zPosition = 500
    }
}
