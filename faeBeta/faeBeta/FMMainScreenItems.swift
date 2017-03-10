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
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
        self.faeMapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        faeMapView.delegate = self
        
        faeMapView.preferredFrameRate = GMSFrameRate.maximum
        faeMapView.isIndoorEnabled = false
        faeMapView.isBuildingsEnabled = false
        faeMapView.settings.tiltGestures = false

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
        buttonLeftTop = UIButton()
        buttonLeftTop.setImage(UIImage(named: "mainScreenMore"), for: .normal)
        self.view.addSubview(buttonLeftTop)
        buttonLeftTop.addTarget(self, action: #selector(self.animationMoreShow(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-15-[v0(30)]", options: [], views: buttonLeftTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonLeftTop)
        buttonLeftTop.layer.zPosition = 500
        
        // Open main map search
        buttonMainScreenSearch = UIButton()
        buttonMainScreenSearch.setImage(UIImage(named: "mainScreenFaeLogo"), for: .normal)
        self.view.addSubview(buttonMainScreenSearch)
        buttonMainScreenSearch.addTarget(self, action: #selector(self.actionMainScreenSearch(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(33)]", options: [], views: buttonMainScreenSearch)
        self.view.addConstraintsWithFormat("V:|-22-[v0(36)]", options: [], views: buttonMainScreenSearch)
        NSLayoutConstraint(item: buttonMainScreenSearch, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        buttonMainScreenSearch.layer.zPosition = 500
        
        // Wind bell
        buttonRightTop = UIButton()
        buttonRightTop.setImage(UIImage(named: "mainScreenWindBell"), for: .normal)
        self.view.addSubview(buttonRightTop)
        buttonRightTop.addTarget(self, action: #selector(self.animationWindBellShow(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(26)]-16-|", options: [], views: buttonRightTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonRightTop)
        
        // Click to back to north
        buttonToNorth = UIButton()
        view.addSubview(buttonToNorth)
        buttonToNorth.setImage(UIImage(named: "mainScreenNorth"), for: .normal)
        buttonToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), for: .touchUpInside)
        view.addConstraintsWithFormat("H:|-22-[v0(59)]", options: [], views: buttonToNorth)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonToNorth)
        buttonToNorth.layer.zPosition = 500
        
        // Click to locate the current location
        buttonSelfPosition = UIButton()
        view.addSubview(buttonSelfPosition)
        buttonSelfPosition.setImage(UIImage(named: "mainScreenSelfPosition"), for: .normal)
        buttonSelfPosition.addTarget(self, action: #selector(self.actionSelfPosition(_:)), for: .touchUpInside)
        view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: buttonSelfPosition)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonSelfPosition)
        buttonSelfPosition.layer.zPosition = 500
        
        // Open chat view
        buttonChatOnMap = UIButton()
        buttonChatOnMap.setImage(UIImage(named: "mainScreenNoChat"), for: .normal)
        buttonChatOnMap.addTarget(self, action: #selector(self.animationMapChatShow(_:)), for: .touchUpInside)
        view.addSubview(buttonChatOnMap)
        view.addConstraintsWithFormat("H:|-12-[v0(79)]", options: [], views: buttonChatOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonChatOnMap)
        buttonChatOnMap.layer.zPosition = 500
        
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
        buttonChatOnMap.addSubview(labelUnreadMessages)
        
        // Create pin on main map
        buttonPinOnMap = UIButton(frame: CGRect(x: 323, y: 646, width: 79, height: 79))
        buttonPinOnMap.setImage(UIImage(named: "mainScreenPinMap"), for: .normal)
        view.addSubview(buttonPinOnMap)
        buttonPinOnMap.addTarget(self, action: #selector(self.actionCreatePin(_:)), for: .touchUpInside)
        view.addConstraintsWithFormat("H:[v0(79)]-12-|", options: [], views: buttonPinOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonPinOnMap)
        buttonPinOnMap.layer.zPosition = 500
    }
    
    func actionMainScreenSearch(_ sender: UIButton) {
        let mainScreenSearchVC = MainScreenSearchViewController()
        mainScreenSearchVC.modalPresentationStyle = .overCurrentContext
        mainScreenSearchVC.delegate = self
        self.present(mainScreenSearchVC, animated: false, completion: nil)
    }
}
