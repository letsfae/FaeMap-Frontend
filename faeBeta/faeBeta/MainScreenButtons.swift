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
    // MARK: -- Load Map Main Screen Buttons
    func loadButton() {
        buttonLeftTop = UIButton()
        buttonLeftTop.setImage(UIImage(named: "leftTopButton"), forState: .Normal)
        self.view.addSubview(buttonLeftTop)
        buttonLeftTop.addTarget(self, action: #selector(FaeMapViewController.animationMoreShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:|-15-[v0(30)]", options: [], views: buttonLeftTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonLeftTop)
        print("bar height:")
        print(UIApplication.sharedApplication().statusBarFrame.size.height)
        
        buttonMainScreenSearch = UIButton()
        buttonMainScreenSearch.setImage(UIImage(named: "middleTopButton"), forState: .Normal)
        self.view.addSubview(buttonMainScreenSearch)
        buttonMainScreenSearch.addTarget(self, action: #selector(FaeMapViewController.animationMainScreenSearchShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(29)]", options: [], views: buttonMainScreenSearch)
        self.view.addConstraintsWithFormat("V:|-24-[v0(32)]", options: [], views: buttonMainScreenSearch)
        NSLayoutConstraint(item: buttonMainScreenSearch, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        
        buttonRightTop = UIButton()
        buttonRightTop.setImage(UIImage(named: "rightTopButton"), forState: .Normal)
        self.view.addSubview(buttonRightTop)
        buttonRightTop.addTarget(self, action: #selector(FaeMapViewController.animationWindBellShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(26)]-16-|", options: [], views: buttonRightTop)
        self.view.addConstraintsWithFormat("V:|-26-[v0(30)]", options: [], views: buttonRightTop)
        
        
        buttonToNorth = UIButton()
        view.addSubview(buttonToNorth)
        buttonToNorth.setImage(UIImage(named: "compass_new"), forState: .Normal)
        buttonToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addConstraintsWithFormat("H:|-22-[v0(59)]", options: [], views: buttonToNorth)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonToNorth)
        
        
        buttonSelfPosition = UIButton()
        view.addSubview(buttonSelfPosition)
        buttonSelfPosition.setImage(UIImage(named: "self_position"), forState: .Normal)
        buttonSelfPosition.addTarget(self, action: #selector(FaeMapViewController.actionSelfPosition(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: buttonSelfPosition)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonSelfPosition)
        
        
        buttonCancelSelectLocation = UIButton(frame: CGRectMake(0, 0, 59, 59))
        buttonCancelSelectLocation.center.x = 45.5
        buttonCancelSelectLocation.center.y = 625.5
        buttonCancelSelectLocation.setImage(UIImage(named: "cancelSelectLocation"), forState: .Normal)
        view.addSubview(buttonCancelSelectLocation)
        buttonCancelSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionCancelSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonCancelSelectLocation.hidden = true
        view.addConstraintsWithFormat("H:|-22-[v0(59)]", options: [], views: buttonCancelSelectLocation)
        view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonCancelSelectLocation)
        
        
        buttonChatOnMap = UIButton()
        buttonChatOnMap.setImage(UIImage(named: "chat_map"), forState: .Normal)
        buttonChatOnMap.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonChatOnMap)
        view.addConstraintsWithFormat("H:|-12-[v0(79)]", options: [], views: buttonChatOnMap)
        view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonChatOnMap)
        
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
        
        buttonSetLocationOnMap = UIButton()
        buttonSetLocationOnMap.setTitle("Set Location", forState: .Normal)
        buttonSetLocationOnMap.setTitle("Set Location", forState: .Highlighted)
        buttonSetLocationOnMap.setTitleColor(colorFae, forState: .Normal)
        buttonSetLocationOnMap.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        view.addSubview(buttonSetLocationOnMap)
        buttonSetLocationOnMap.addTarget(self, action: #selector(FaeMapViewController.actionSetLocationForComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonSetLocationOnMap.hidden = true
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonSetLocationOnMap)
        view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonSetLocationOnMap)
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
    
    func actionCreatePin(sender: UIButton!) {
        uiviewCreateCommentPin.alpha = 0.0
        uiviewPinSelections.alpha = 1.0
        pinSelectionShowAnimation()
        hideCommentPinDetail()
        shrinkCommentList()
    }
    
    func submitPinsHideAnimation() {
        // initial position of buttons for cool animation
        let buttonCenterX_1: CGFloat = 79/414 * screenWidth
        let buttonCenterX_2: CGFloat = 208/414 * screenWidth
        let buttonCenterX_3: CGFloat = 337/414 * screenWidth
        
        let buttonCenterY_1: CGFloat = 205/736 * screenHeight
        let buttonCenterY_2: CGFloat = 347/736 * screenHeight
        let buttonCenterY_3: CGFloat = 489/736 * screenHeight
        
        let labelDiff: CGFloat = 33/736 * screenHeight
        let labelTitleDiff: CGFloat = 66/736 * screenHeight
        
        blurViewMap.alpha = 0.0
        blurViewMap.hidden = true
        buttonChats.frame = CGRect(x: buttonCenterX_2, y: buttonCenterY_1, width: 0, height: 0)
        buttonClosePinBlurView.alpha = 0.0
        buttonClosePinBlurView.frame = CGRectMake(0, screenHeight, screenWidth, 65)
        buttonComment.frame = CGRect(x: buttonCenterX_3, y: buttonCenterY_1, width: 0, height: 0)
        buttonEvent.frame = CGRect(x: buttonCenterX_1, y: buttonCenterY_2, width: 0, height: 0)
        buttonFaevor.frame = CGRect(x: buttonCenterX_2, y: buttonCenterY_2, width: 0, height: 0)
        buttonJoinMe.frame = CGRect(x: buttonCenterX_1, y: buttonCenterY_3, width: 0, height: 0)
        buttonLive.frame = CGRect(x: buttonCenterX_3, y: buttonCenterY_3, width: 0, height: 0)
        buttonMedia.frame = CGRect(x: buttonCenterX_1, y: buttonCenterY_1, width: 0, height: 0)
        buttonNow.frame = CGRect(x: buttonCenterX_3, y: buttonCenterY_2, width: 0, height: 0)
        buttonSell.frame = CGRect(x: buttonCenterX_2, y: buttonCenterY_3, width: 0, height: 0)
        labelSubmitChats.alpha = 0.0
        labelSubmitChats.center.y -= labelDiff
        labelSubmitComment.alpha = 0.0
        labelSubmitComment.center.y -= labelDiff
        labelSubmitEvent.alpha = 0.0
        labelSubmitEvent.center.y -= labelDiff
        labelSubmitFaevor.alpha = 0.0
        labelSubmitFaevor.center.y -= labelDiff
        labelSubmitJoinMe.alpha = 0.0
        labelSubmitJoinMe.center.y -= labelDiff
        labelSubmitLive.alpha = 0.0
        labelSubmitLive.center.y -= labelDiff
        labelSubmitMedia.alpha = 0.0
        labelSubmitMedia.center.y -= labelDiff
        labelSubmitNow.alpha = 0.0
        labelSubmitNow.center.y -= labelDiff
        labelSubmitSell.alpha = 0.0
        labelSubmitSell.center.y -= labelDiff
        labelSubmitTitle.alpha = 0.0
        labelSubmitTitle.center.y += labelTitleDiff
        uiviewPinSelections.hidden = true
        self.navigationController?.navigationBar.alpha = 1.0
    }
    
    func initialCGRectForButton(button: UIButton, x: CGFloat, y: CGFloat) {
        button.frame = CGRectMake(x, y, 0, 0)
    }
    
    func reCreateCGRectForButton(button: UIButton, x: CGFloat, y: CGFloat) {
        let width: CGFloat = 90/414 * screenWidth
        button.frame = CGRectMake(x, y, width, width)
    }
    
    func pinSelectionShowAnimation() {
        uiviewPinSelections.hidden = false
        blurViewMap.hidden = false
        blurViewMap.layer.opacity = 0.6
        
        // post-animated position of buttons for cool animation
        let buttonOriginX_1: CGFloat = 34/414 * screenWidth
        let buttonOriginX_2: CGFloat = 163/414 * screenWidth
        let buttonOriginX_3: CGFloat = 292/414 * screenWidth
        
        let buttonOriginY_1: CGFloat = 160/736 * screenHeight
        let buttonOriginY_2: CGFloat = 302/736 * screenHeight
        let buttonOriginY_3: CGFloat = 444/736 * screenHeight
        
        // post-animated position of labels for cool animation
        let labelDiff: CGFloat = 33/736 * screenHeight
        let labelTitleDiff: CGFloat = 66/736 * screenHeight
        
        UIView.animateWithDuration(1.4, delay: 0, options: .CurveEaseOut, animations: {
            self.blurViewMap.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.2, delay: 0.35, options: .TransitionFlipFromBottom, animations: {
            self.buttonClosePinBlurView.alpha = 1.0
            self.buttonClosePinBlurView.frame = CGRectMake(0, self.screenHeight-65, self.screenWidth, 65)
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.15, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.labelSubmitTitle.center.y -= labelTitleDiff
            self.labelSubmitTitle.alpha = 1.0
            self.reCreateCGRectForButton(self.buttonMedia, x: buttonOriginX_1, y: buttonOriginY_1)
            self.labelSubmitMedia.center.y += labelDiff
            self.labelSubmitMedia.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.25, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonChats, x: buttonOriginX_2, y: buttonOriginY_1)
            self.labelSubmitChats.center.y += labelDiff
            self.labelSubmitChats.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonComment, x: buttonOriginX_3, y: buttonOriginY_1)
            self.labelSubmitComment.center.y += labelDiff
            self.labelSubmitComment.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.25, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonEvent, x: buttonOriginX_1, y: buttonOriginY_2)
            self.labelSubmitEvent.center.y += labelDiff
            self.labelSubmitEvent.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonFaevor, x: buttonOriginX_2, y: buttonOriginY_2)
            self.labelSubmitFaevor.center.y += labelDiff
            self.labelSubmitFaevor.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.45, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonNow, x: buttonOriginX_3, y: buttonOriginY_2)
            self.labelSubmitNow.center.y += labelDiff
            self.labelSubmitNow.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonJoinMe, x: buttonOriginX_1, y: buttonOriginY_3)
            self.labelSubmitJoinMe.center.y += labelDiff
            self.labelSubmitJoinMe.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.45, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonSell, x: buttonOriginX_2, y: buttonOriginY_3)
            self.labelSubmitSell.center.y += labelDiff
            self.labelSubmitSell.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.55, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonLive, x: buttonOriginX_3, y: buttonOriginY_3)
            self.labelSubmitLive.center.y += labelDiff
            self.labelSubmitLive.alpha = 1.0
            }, completion: nil)
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
