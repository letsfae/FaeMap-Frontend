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

extension FaeMapViewController: CreatePinViewControllerDelegate {
    // MARK: -- Load Map Main Screen Buttons
    func loadButton() {
        // Left window on main map to open account system
        buttonLeftTop = UIButton()
        buttonLeftTop.setImage(UIImage(named: "leftTopButton"), forState: .Normal)
        self.view.addSubview(buttonLeftTop)
        buttonLeftTop.addTarget(self, action: #selector(FaeMapViewController.animationMoreShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:|-15-[v0(30)]", options: [], views: buttonLeftTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonLeftTop)
        print("bar height:")
        print(UIApplication.sharedApplication().statusBarFrame.size.height)
        
        // Open main map search
        buttonMainScreenSearch = UIButton()
        buttonMainScreenSearch.setImage(UIImage(named: "middleTopButton"), forState: .Normal)
        self.view.addSubview(buttonMainScreenSearch)
        buttonMainScreenSearch.addTarget(self, action: #selector(FaeMapViewController.animationMainScreenSearchShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(29)]", options: [], views: buttonMainScreenSearch)
        self.view.addConstraintsWithFormat("V:|-24-[v0(32)]", options: [], views: buttonMainScreenSearch)
        NSLayoutConstraint(item: buttonMainScreenSearch, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        // Wind bell
        buttonRightTop = UIButton()
        buttonRightTop.setImage(UIImage(named: "rightTopButton"), forState: .Normal)
        self.view.addSubview(buttonRightTop)
        buttonRightTop.addTarget(self, action: #selector(FaeMapViewController.animationWindBellShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(26)]-16-|", options: [], views: buttonRightTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonRightTop)
        
        // Click to back to north
        buttonToNorth = UIButton()
        view.addSubview(buttonToNorth)
        buttonToNorth.setImage(UIImage(named: "compass_new"), forState: .Normal)
        buttonToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addConstraintsWithFormat("H:|-22-[v0(59)]", options: [], views: buttonToNorth)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonToNorth)
        
        // Click to locate the current location
        buttonSelfPosition = UIButton()
        view.addSubview(buttonSelfPosition)
        buttonSelfPosition.setImage(UIImage(named: "self_position"), forState: .Normal)
        buttonSelfPosition.addTarget(self, action: #selector(FaeMapViewController.actionSelfPosition(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: buttonSelfPosition)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonSelfPosition)
        
        // Open chat view
        buttonChatOnMap = UIButton()
        buttonChatOnMap.setImage(UIImage(named: "chat_map"), forState: .Normal)
        buttonChatOnMap.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonChatOnMap)
        view.addConstraintsWithFormat("H:|-12-[v0(79)]", options: [], views: buttonChatOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonChatOnMap)
        
        // Show the number of unread messages on main map
        labelUnreadMessages = UILabel(frame: CGRectMake(55, 1, 23, 20))
        labelUnreadMessages.backgroundColor = UIColor.init(red: 102/255, green: 192/255, blue: 251/255, alpha: 1)
        labelUnreadMessages.layer.cornerRadius = 10
        labelUnreadMessages.layer.masksToBounds = true
        labelUnreadMessages.layer.opacity = 0.9
        labelUnreadMessages.text = "1"
        labelUnreadMessages.textAlignment = .Center
        labelUnreadMessages.textColor = UIColor.whiteColor()
        labelUnreadMessages.font = UIFont(name: "AvenirNext-DemiBold", size: 11)
        buttonChatOnMap.addSubview(labelUnreadMessages)
        
        // Create pin on main map
        buttonPinOnMap = UIButton(frame: CGRectMake(323, 646, 79, 79))
        buttonPinOnMap.setImage(UIImage(named: "set_pin_on_map"), forState: .Normal)
        view.addSubview(buttonPinOnMap)
        buttonPinOnMap.addTarget(self, action: #selector(FaeMapViewController.actionCreatePin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addConstraintsWithFormat("H:[v0(79)]-12-|", options: [], views: buttonPinOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonPinOnMap)
//        buttonPinOnMapInside = UIButton(frame: CGRectMake(344, 666, 38, 40))
//        buttonPinOnMapInside.setImage(UIImage(named: "set_pin_on_map_inside"), forState: .Normal)
//        buttonPinOnMapInside.addTarget(self, action: #selector(FaeMapViewController.actionCreatePin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        view.addSubview(buttonPinOnMapInside)
    }
    
    //MARK: Actions for these buttons
    func actionSelfPosition(sender: UIButton!) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            currentLocation = locManager.location
        }
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        faeMapView.camera = camera
        if isInPinLocationSelect == false {
            loadPositionAnimateImage()
        }
    }
    
    func actionTrueNorth(sender: UIButton!) {
        faeMapView.animateToBearing(0)
        faeMapView.clear()
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
        originPointForRefresh = mapCenterCoordinate
        loadCurrentRegionPins()
    }
    
    // Jump to create pin view controller
    func actionCreatePin(sender: UIButton!) {
        let createPinVC = CreatePinViewController()
        createPinVC.modalPresentationStyle = .OverCurrentContext
        createPinVC.currentLatitude = self.currentLatitude
        createPinVC.currentLongitude = self.currentLongitude
        createPinVC.delegate = self
        self.presentViewController(createPinVC, animated: false, completion: nil)
    }
    
    // Back from create pin view controller
    func sendCommentGeoInfo(commentID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        print("Receive Data From Create Comment Pin:")
        print(commentID)
        print(latitude)
        print(longitude)
        let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 17)
        faeMapView.camera = camera
        animatePinWhenItIsCreated(commentID)
    }
    
    // Animation for pin logo
    func animatePinWhenItIsCreated(commentID: String) {
        let pinLogo = UIImageView(frame: CGRectMake(0, 0, 167, 183))
        let mapCenter = CGPointMake(screenWidth/2, screenHeight/2-27)
        pinLogo.center = mapCenter
        pinLogo.image = UIImage(named: "commentMarkerWhenCreated")
        self.view.addSubview(pinLogo)
        UIView.animateWithDuration(0.783, delay: 0.15, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            pinLogo.frame.size.width = 50
            pinLogo.frame.size.height = 54
            pinLogo.center = mapCenter
            }, completion: { (done: Bool) in
                if done {
                    self.loadMarkerWithCommentID(commentID, tempMaker: pinLogo)
                }
        })
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, options: NSLayoutFormatOptions, views: UIView...) {
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerate() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: nil, views: viewDictionary))
    }
}
