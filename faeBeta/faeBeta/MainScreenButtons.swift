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
//                testButton.hidden = true
        
        let buttonLeftTopX: CGFloat = 15
        let buttonLeftTopY: CGFloat = 5
        let buttonLeftTopWidth: CGFloat = 32
        let buttonLeftTopHeight: CGFloat = 33
        buttonLeftTop = UIButton(frame: CGRectMake(buttonLeftTopX, buttonLeftTopY, buttonLeftTopWidth, buttonLeftTopHeight))
        buttonLeftTop.setImage(UIImage(named: "leftTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonLeftTop)
        buttonLeftTop.addTarget(self, action: #selector(FaeMapViewController.animationMoreShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonMiddleTopX: CGFloat = 186
        let buttonMiddleTopY: CGFloat = 1
        let buttonMiddleTopWidth: CGFloat = 41
        let buttonMiddleTopHeight: CGFloat = 41
        buttonMiddleTop = UIButton(frame: CGRectMake(buttonMiddleTopX, buttonMiddleTopY, buttonMiddleTopWidth, buttonMiddleTopHeight))
        buttonMiddleTop.setImage(UIImage(named: "middleTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonMiddleTop)
        buttonMiddleTop.addTarget(self, action: #selector(FaeMapViewController.animationMainScreenSearchShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonRightTopX: CGFloat = 368
        let buttonRightTopY: CGFloat = 4
        let buttonRightTopWidth: CGFloat = 31
        let buttonRightTopHeight: CGFloat = 36
        buttonRightTop = UIButton(frame: CGRectMake(buttonRightTopX, buttonRightTopY, buttonRightTopWidth, buttonRightTopHeight))
        buttonRightTop.setImage(UIImage(named: "rightTopButton"), forState: .Normal)
        self.navigationController!.navigationBar.addSubview(buttonRightTop)
        buttonRightTop.addTarget(self, action: #selector(FaeMapViewController.animationWindBellShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonToNorthX: CGFloat = 22
        let buttonToNorthY: CGFloat = 582
        let buttonToNorthWidth: CGFloat = 59
        buttonToNorth = UIButton(frame: CGRectMake(buttonToNorthX, buttonToNorthY, buttonToNorthWidth, buttonToNorthWidth))
        buttonToNorth.setImage(UIImage(named: "compass_new"), forState: .Normal)
        self.view.addSubview(buttonToNorth)
        buttonToNorth.addTarget(self, action: #selector(FaeMapViewController.actionTrueNorth(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonSelfPositionX: CGFloat = 333
        let buttonSelfPositionY: CGFloat = buttonToNorthY
        let buttonSelfPositionWidth: CGFloat = buttonToNorthWidth
        buttonSelfPosition = UIButton(frame: CGRectMake(buttonSelfPositionX, buttonSelfPositionY, buttonSelfPositionWidth, buttonSelfPositionWidth))
        buttonSelfPosition.setImage(UIImage(named: "self_position"), forState: .Normal)
        self.view.addSubview(buttonSelfPosition)
        buttonSelfPosition.addTarget(self, action: #selector(FaeMapViewController.actionSelfPosition(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonCancelSelectLocationWidth: CGFloat = buttonToNorthWidth
        buttonCancelSelectLocation = UIButton(frame: CGRectMake(0, 0, buttonCancelSelectLocationWidth, buttonCancelSelectLocationWidth))
        buttonCancelSelectLocation.center.x = 45.5
        buttonCancelSelectLocation.center.y = 625.5
        buttonCancelSelectLocation.setImage(UIImage(named: "cancelSelectLocation"), forState: .Normal)
        self.view.addSubview(buttonCancelSelectLocation)
        buttonCancelSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionCancelSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonCancelSelectLocation.hidden = true
        
        let chatOnMapX: CGFloat = 12
        let chatOnMapY: CGFloat = 646
        let chatOnMapWidth: CGFloat = 79
        buttonChatOnMap = UIButton(frame: CGRectMake(chatOnMapX, chatOnMapY, chatOnMapWidth, chatOnMapWidth))
        buttonChatOnMap.setImage(UIImage(named: "chat_map"), forState: .Normal)
        buttonChatOnMap.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonChatOnMap)
        
        let pinOnMapX: CGFloat = 323
        let pinOnMapY: CGFloat = chatOnMapY
        let pinOnMapWidth: CGFloat = chatOnMapWidth
        buttonPinOnMap = UIButton(frame: CGRectMake(pinOnMapX, pinOnMapY, pinOnMapWidth, pinOnMapWidth))
        buttonPinOnMap.setImage(UIImage(named: "pin_map"), forState: .Normal)
        self.view.addSubview(buttonPinOnMap)
        buttonPinOnMap.addTarget(self, action: #selector(FaeMapViewController.actionCreatePin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonSetLocationOnMap = UIButton(frame: CGRectMake(0, 671, screenWidth, 65))
        buttonSetLocationOnMap.setTitle("Set Location", forState: .Normal)
        buttonSetLocationOnMap.setTitle("Set Location", forState: .Highlighted)
        buttonSetLocationOnMap.setTitleColor(colorFae, forState: .Normal)
        buttonSetLocationOnMap.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        UIApplication.sharedApplication().keyWindow?.addSubview(buttonSetLocationOnMap)
        buttonSetLocationOnMap.addTarget(self, action: #selector(FaeMapViewController.actionSetLocationForComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonSetLocationOnMap.hidden = true
        
        buttonAddComment = UIButton(frame: CGRect(x: 280, y: 212, width: 58, height: 58))
        let imageLike = UIImage(named: "comment_pin_groupchat")
        buttonAddComment.setImage(imageLike, forState: .Normal)
        UIApplication.sharedApplication().keyWindow?.addSubview(buttonAddComment)
        buttonAddComment.hidden = true
        buttonAddComment.clipsToBounds = false
        
        buttonCommentLike = UIButton(frame: CGRect(x: 345, y: 212, width: 58, height: 58))
        let imageAddComment = UIImage(named: "comment_pin_like")
        buttonCommentLike.setImage(imageAddComment, forState: .Normal)
        UIApplication.sharedApplication().keyWindow?.addSubview(buttonCommentLike)
        buttonCommentLike.hidden = true
        buttonCommentLike.clipsToBounds = false
    }
    
    //MARK: Actions for these buttons
    func actionSelfPosition(sender: UIButton!) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            currentLocation = locManager.location
        }
        self.currentLatitude = currentLocation.coordinate.latitude
        self.currentLongitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude: currentLongitude, zoom: 17)
        faeMapView.animateToCameraPosition(camera)
    }
    
    func actionTrueNorth(sender: UIButton!) {
        faeMapView.animateToBearing(0)
    }
    
    func actionCreatePin(sender: UIButton!) {
        submitPinsShowAnimation()
        uiviewCreateCommentPin.alpha = 0.0
        uiviewPinSelections.alpha = 1.0
        self.navigationController?.navigationBar.hidden = true
        hideCommentPinCells()
    }
    
}