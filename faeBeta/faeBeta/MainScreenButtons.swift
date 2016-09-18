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
        //        let testButton = UIButton(frame: CGRectMake(300, 170, 100, 100))
        //        testButton.backgroundColor = colorFae
        //        self.view.addSubview(testButton)
        //        testButton.addTarget(self, action: #selector(FaeMapViewController.testing(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //        testButton.hidden = true
        
        self.buttonLeftTop = UIButton()
        self.buttonLeftTop.setImage(UIImage(named: "leftTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonLeftTop)
        self.buttonLeftTop.addTarget(self, action: #selector(FaeMapViewController.animationMoreShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationController!.navigationBar.addConstraintsWithFormat("H:|-15-[v0(29)]", options: [], views: buttonLeftTop)
        self.navigationController!.navigationBar.addConstraintsWithFormat("V:|-6-[v0(29)]", options: [], views: buttonLeftTop)
        print("bar height:")
        print(UIApplication.sharedApplication().statusBarFrame.size.height)
        
        self.buttonMainScreenSearch = UIButton()
        self.buttonMainScreenSearch.setImage(UIImage(named: "middleTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonMainScreenSearch)
        self.buttonMainScreenSearch.addTarget(self, action: #selector(FaeMapViewController.animationMainScreenSearchShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationController!.navigationBar.addConstraintsWithFormat("H:[v0(27)]", options: [], views: buttonMainScreenSearch)
        self.navigationController!.navigationBar.addConstraintsWithFormat("V:|-6-[v0(29)]", options: [], views: buttonMainScreenSearch)
        NSLayoutConstraint(item: buttonMainScreenSearch, attribute: .CenterX, relatedBy: .Equal, toItem: self.navigationController!.navigationBar, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        
        self.buttonRightTop = UIButton()
        self.buttonRightTop.setImage(UIImage(named: "rightTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonRightTop)
        self.buttonRightTop.addTarget(self, action: #selector(FaeMapViewController.animationWindBellShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationController!.navigationBar.addConstraintsWithFormat("H:[v0(28)]-15-|", options: [], views: buttonRightTop)
        self.navigationController!.navigationBar.addConstraintsWithFormat("V:|-6-[v0(31)]", options: [], views: buttonRightTop)
        
        
        self.buttonToNorth = UIButton()
        self.view.addSubview(buttonToNorth)
        self.buttonToNorth.setImage(UIImage(named: "compass_new"), forState: .Normal)
        self.buttonToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:|-22-[v0(59)]", options: [], views: buttonToNorth)
        self.view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonToNorth)
        
        
        self.buttonSelfPosition = UIButton()
        self.view.addSubview(buttonSelfPosition)
        self.buttonSelfPosition.setImage(UIImage(named: "self_position"), forState: .Normal)
        self.buttonSelfPosition.addTarget(self, action: #selector(FaeMapViewController.actionSelfPosition(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: buttonSelfPosition)
        self.view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonSelfPosition)
        
        
        let buttonCancelSelectLocationWidth: CGFloat = 59
        self.buttonCancelSelectLocation = UIButton(frame: CGRectMake(0, 0, buttonCancelSelectLocationWidth, buttonCancelSelectLocationWidth))
        self.buttonCancelSelectLocation.center.x = 45.5
        self.buttonCancelSelectLocation.center.y = 625.5
        self.buttonCancelSelectLocation.setImage(UIImage(named: "cancelSelectLocation"), forState: .Normal)
        self.view.addSubview(buttonCancelSelectLocation)
        self.buttonCancelSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionCancelSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonCancelSelectLocation.hidden = true
        
        
        self.buttonChatOnMap = UIButton()
        self.buttonChatOnMap.setImage(UIImage(named: "chat_map"), forState: .Normal)
        self.buttonChatOnMap.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonChatOnMap)
        self.view.addConstraintsWithFormat("H:|-12-[v0(79)]", options: [], views: buttonChatOnMap)
        self.view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonChatOnMap)
        
        self.labelUnreadMessages = UILabel(frame: CGRectMake(55, 1, 23, 20))
        self.labelUnreadMessages.backgroundColor = UIColor.init(red: 102/255, green: 192/255, blue: 251/255, alpha: 1)
        self.labelUnreadMessages.layer.cornerRadius = 10
        self.labelUnreadMessages.layer.masksToBounds = true
        self.labelUnreadMessages.layer.opacity = 0.9
        self.labelUnreadMessages.text = "1"
        self.labelUnreadMessages.textAlignment = .Center
        self.labelUnreadMessages.textColor = UIColor.whiteColor()
        self.labelUnreadMessages.font = UIFont(name: "AvenirNext-DemiBold", size: 11)
        self.buttonChatOnMap.addSubview(labelUnreadMessages)
        
        self.buttonPinOnMap = UIButton(frame: CGRectMake(323, 646, 79, 79))
        self.buttonPinOnMap.setImage(UIImage(named: "set_pin_on_map_outside"), forState: .Normal)
        self.view.addSubview(buttonPinOnMap)
        self.buttonPinOnMap.addTarget(self, action: #selector(FaeMapViewController.actionCreatePin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //        self.view.addConstraintsWithFormat("H:[v0(79)]-12-|", options: [], views: buttonPinOnMap)
        //        self.view.addConstraintsWithFormat("V:[v0(79)]-11-|", options: [], views: buttonPinOnMap)
        self.buttonPinOnMapInside = UIButton(frame: CGRectMake(344, 666, 38, 40))
        self.buttonPinOnMapInside.setImage(UIImage(named: "set_pin_on_map_inside"), forState: .Normal)
        self.buttonPinOnMapInside.addTarget(self, action: #selector(FaeMapViewController.actionCreatePin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonPinOnMapInside)
        
        self.buttonSetLocationOnMap = UIButton()
        self.buttonSetLocationOnMap.setTitle("Set Location", forState: .Normal)
        self.buttonSetLocationOnMap.setTitle("Set Location", forState: .Highlighted)
        self.buttonSetLocationOnMap.setTitleColor(colorFae, forState: .Normal)
        self.buttonSetLocationOnMap.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        self.buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        self.buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        self.view.addSubview(buttonSetLocationOnMap)
        self.buttonSetLocationOnMap.addTarget(self, action: #selector(FaeMapViewController.actionSetLocationForComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonSetLocationOnMap.hidden = true
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonSetLocationOnMap)
        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonSetLocationOnMap)
    }
    
    //MARK: Actions for these buttons
    func actionSelfPosition(sender: UIButton!) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            currentLocation = locManager.location
        }
        self.currentLatitude = currentLocation.coordinate.latitude
        self.currentLongitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        self.faeMapView.camera = camera
        if self.isInPinLocationSelect == false {
            self.loadPositionAnimateImage()
        }
    }
    
    func actionTrueNorth(sender: UIButton!) {
        self.faeMapView.animateToBearing(0)
    }
    
    func actionCreatePin(sender: UIButton!) {
        self.uiviewCreateCommentPin.alpha = 0.0
        self.uiviewPinSelections.alpha = 1.0
        self.pinSelectionShowAnimation()
    }
    
    func submitPinsHideAnimation() {
        self.uiviewPinSelections.hidden = true
        self.blurViewMap.alpha = 0.0
        self.blurViewMap.hidden = true
        self.labelSubmitTitle.frame = CGRectMake(135, 134, 145, 41)
        self.labelSubmitTitle.alpha = 0.0
        self.buttonClosePinBlurView.frame = CGRectMake(0, 736, self.screenWidth, 65)
        self.buttonClosePinBlurView.alpha = 0.0
        self.buttonMedia.frame = CGRect(x: 79, y: 205, width: 0, height: 0)
        self.buttonChats.frame = CGRect(x: 208, y: 205, width: 0, height: 0)
        self.buttonComment.frame = CGRect(x: 337, y: 205, width: 0, height: 0)
        self.buttonEvent.frame = CGRect(x: 79, y: 347, width: 0, height: 0)
        self.buttonFaevor.frame = CGRect(x: 208, y: 347, width: 0, height: 0)
        self.buttonNow.frame = CGRect(x: 337, y: 347, width: 0, height: 0)
        self.buttonJoinMe.frame = CGRect(x: 79, y: 489, width: 0, height: 0)
        self.buttonSell.frame = CGRect(x: 208, y: 489, width: 0, height: 0)
        self.buttonLive.frame = CGRect(x: 337, y: 489, width: 0, height: 0)
        self.labelSubmitMedia.frame = CGRectMake(31, 224, 95, 27)
        self.labelSubmitChats.frame = CGRectMake(160, 224, 95, 27)
        self.labelSubmitComment.frame = CGRectMake(289, 224, 95, 27)
        self.labelSubmitEvent.frame = CGRectMake(31, 366, 95, 27)
        self.labelSubmitFaevor.frame = CGRectMake(160, 366, 95, 27)
        self.labelSubmitNow.frame = CGRectMake(289, 366, 95, 27)
        self.labelSubmitJoinMe.frame = CGRectMake(31, 508, 95, 27)
        self.labelSubmitSell.frame = CGRectMake(160, 508, 95, 27)
        self.labelSubmitLive.frame = CGRectMake(289, 508, 95, 27)
        self.labelSubmitMedia.alpha = 0.0
        self.labelSubmitChats.alpha = 0.0
        self.labelSubmitComment.alpha = 0.0
        self.labelSubmitEvent.alpha = 0.0
        self.labelSubmitFaevor.alpha = 0.0
        self.labelSubmitNow.alpha = 0.0
        self.labelSubmitJoinMe.alpha = 0.0
        self.labelSubmitSell.alpha = 0.0
        self.labelSubmitLive.alpha = 0.0
        self.buttonPinOnMap.frame = CGRectMake(323, 646, 79, 79)
        self.buttonPinOnMap.alpha = 1.0
        self.navigationController?.navigationBar.alpha = 1.0
    }
    
    func pinSelectionShowAnimation() {
        self.uiviewPinSelections.hidden = false
        self.blurViewMap.hidden = false
        self.blurViewMap.layer.opacity = 0.6
        UIView.animateWithDuration(1.4, delay: 0, options: .CurveEaseOut, animations: {
            self.blurViewMap.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 20, options: .CurveEaseOut, animations: {
            self.buttonPinOnMap.frame = CGRectMake(262.8, 585.8, 200, 200)
            }, completion: {(done: Bool) in
                if done {
                    
                }
        })
        UIView.animateWithDuration(0.2, delay: 0.5, options: .TransitionFlipFromBottom, animations: {
            self.buttonClosePinBlurView.alpha = 1.0
            self.buttonClosePinBlurView.frame = CGRectMake(0, 671, self.screenWidth, 65)
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.3, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.labelSubmitTitle.frame = CGRectMake(135, 68, 145, 41)
            self.labelSubmitTitle.alpha = 1.0
            self.buttonMedia.frame = CGRect(x: 34, y: 160, width: 90, height: 90)
            self.labelSubmitMedia.frame = CGRect(x: 31, y: 257, width: 95, height: 27)
            self.labelSubmitMedia.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.4, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.buttonChats.frame = CGRect(x: 163, y: 160, width: 90, height: 90)
            self.labelSubmitChats.frame = CGRect(x: 160, y: 257, width: 95, height: 27)
            self.labelSubmitChats.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.5, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.buttonComment.frame = CGRect(x: 292, y: 160, width: 90, height: 90)
            self.labelSubmitComment.frame = CGRect(x: 289, y: 257, width: 95, height: 27)
            self.labelSubmitComment.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.4, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.buttonEvent.frame = CGRect(x: 34, y: 302, width: 90, height: 90)
            self.labelSubmitEvent.frame = CGRect(x: 31, y: 399, width: 95, height: 27)
            self.labelSubmitEvent.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.5, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.buttonFaevor.frame = CGRect(x: 163, y: 302, width: 90, height: 90)
            self.labelSubmitFaevor.frame = CGRect(x: 160, y: 399, width: 95, height: 27)
            self.labelSubmitFaevor.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.6, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.buttonNow.frame = CGRect(x: 292, y: 302, width: 90, height: 90)
            self.labelSubmitNow.frame = CGRect(x: 289, y: 399, width: 95, height: 27)
            self.labelSubmitNow.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.5, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.buttonJoinMe.frame = CGRect(x: 34, y: 444, width: 90, height: 90)
            self.labelSubmitJoinMe.frame = CGRect(x: 31, y: 541, width: 95, height: 27)
            self.labelSubmitJoinMe.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.6, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.buttonSell.frame = CGRect(x: 163, y: 444, width: 90, height: 90)
            self.labelSubmitSell.frame = CGRect(x: 160, y: 541, width: 95, height: 27)
            self.labelSubmitSell.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.883, delay: 0.7, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            self.buttonLive.frame = CGRect(x: 292, y: 444, width: 90, height: 90)
            self.labelSubmitLive.frame = CGRect(x: 289, y: 541, width: 95, height: 27)
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