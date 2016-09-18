//
//  PinSelections.swift
//  faeBeta
//
//  Created by Yue on 9/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController {
    // MARK: -- Blur View and Pins Creating Selections
    
    func loadBlurAndPinSelection() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurViewMap = UIVisualEffectView(effect: blurEffect)
        blurViewMap.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        UIApplication.sharedApplication().keyWindow?.addSubview(blurViewMap)
        loadPinSelections()
        loadCreateCommentPinView()
        uiviewCreateCommentPin.hidden = false
        uiviewCreateCommentPin.alpha = 0.0
        blurViewMap.alpha = 0.0
        blurViewMap.hidden = true
    }
    
    // MARK: -- Pins Creating Selections View
    
    func loadPinSelections() {
        self.uiviewPinSelections = UIView(frame: self.blurViewMap.bounds)
        
        self.labelSubmitTitle = UILabel(frame: CGRectMake(135, 134, 145, 41))
        self.labelSubmitTitle.alpha = 0.0
        self.labelSubmitTitle.text = "Create Pin"
        self.labelSubmitTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 30)
        self.labelSubmitTitle.textAlignment = .Center
        self.labelSubmitTitle.textColor = UIColor.whiteColor()
        self.uiviewPinSelections.addSubview(labelSubmitTitle)
        
        self.buttonMedia = createSubmitButton(79, y: 205, width: 0, height: 0, picName: "submit_media")
        self.buttonChats = createSubmitButton(208, y: 205, width: 0, height: 0, picName: "submit_chats")
        self.buttonComment = createSubmitButton(337, y: 205, width: 0, height: 0, picName: "submit_comment")
        self.buttonComment.addTarget(self, action: #selector(FaeMapViewController.actionCreateCommentPin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.buttonEvent = createSubmitButton(79, y: 347, width: 0, height: 0, picName: "submit_event")
        self.buttonFaevor = createSubmitButton(208, y: 347, width: 0, height: 0, picName: "submit_faevor")
        self.buttonNow = createSubmitButton(337, y: 347, width: 0, height: 0, picName: "submit_now")
        self.buttonNow.addTarget(self, action: #selector(FaeMapViewController.actionGetMapInfo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.buttonJoinMe = createSubmitButton(79, y: 489, width: 0, height: 0, picName: "submit_joinme")
        self.buttonJoinMe.addTarget(self, action: #selector(FaeMapViewController.actionLogOut(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonSell = createSubmitButton(208, y: 489, width: 0, height: 0, picName: "submit_sell")
        self.buttonSell.addTarget(self, action: #selector(FaeMapViewController.actionClearAllUserPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonLive = createSubmitButton(337, y: 489, width: 0, height: 0, picName: "submit_live")
        
        self.labelSubmitMedia = createSubmitLabel(31, y: 224, width: 95, height: 27, title: "Media")
        self.labelSubmitChats = createSubmitLabel(160, y: 224, width: 95, height: 27, title: "Chats")
        self.labelSubmitComment = createSubmitLabel(289, y: 224, width: 95, height: 27, title: "Comment")
        
        self.labelSubmitEvent = createSubmitLabel(31, y: 366, width: 95, height: 27, title: "Event")
        self.labelSubmitFaevor = createSubmitLabel(160, y: 366, width: 95, height: 27, title: "Faevor")
        self.labelSubmitNow = createSubmitLabel(289, y: 366, width: 95, height: 27, title: "Now")
        
        self.labelSubmitJoinMe = createSubmitLabel(31, y: 508, width: 95, height: 27, title: "Join Me!")
        self.labelSubmitSell = createSubmitLabel(160, y: 508, width: 95, height: 27, title: "Sell")
        self.labelSubmitLive = createSubmitLabel(289, y: 508, width: 95, height: 27, title: "Live")
        
        self.buttonClosePinBlurView = UIButton(frame: CGRectMake(0, 736, self.screenWidth, 65))
        self.buttonClosePinBlurView.setTitle("Close", forState: .Normal)
        self.buttonClosePinBlurView.setTitle("Close", forState: .Highlighted)
        self.buttonClosePinBlurView.alpha = 0.0
        self.buttonClosePinBlurView.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.buttonClosePinBlurView.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        self.buttonClosePinBlurView.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        self.buttonClosePinBlurView.backgroundColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 0.5)
        self.uiviewPinSelections.addSubview(buttonClosePinBlurView)
        self.buttonClosePinBlurView.addTarget(self, action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewPinSelections)
        self.uiviewPinSelections.hidden = true
    }
    
    func createSubmitButton(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, picName: String) -> UIButton {
        let button = UIButton(frame: CGRectMake(x, y, width, height))
        button.setImage(UIImage(named: picName), forState: .Normal)
        self.uiviewPinSelections.addSubview(button)
        return button
    }
    
    func createSubmitLabel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, title: String) -> UILabel {
        let label = UILabel(frame: CGRectMake(x, y, width, height))
        label.text = title
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.alpha = 0.0
        self.uiviewPinSelections.addSubview(label)
        return label
    }
    
    // MARK: -- Temporary Methods!!!
    func actionLogOut(sender: UIButton!) {
        let logOut = FaeUser()
        logOut.logOut{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                //                self.testLabel.text = "logout success"
            }
            else{
                //failure
                //                self.testLabel.text = "logout failure"
            }
        }
        submitPinsHideAnimation()
        jumpToWelcomeView()
    }
    
    func actionGetMapInfo(sender: UIButton!) {
        loadCurrentRegionPins()
    }
    
    func actionClearAllUserPins(sender: UIButton!) {
        clearAllMyPins()
    }
    
    func clearAllMyPins() {
        let clearUserPins = FaeMap()
        clearUserPins.getUserAllComments("\(user_id)"){(status:Int,message:AnyObject?) in
            let clearUserPinsJSON = JSON(message!)
            print(clearUserPinsJSON)
            for i in 0...clearUserPinsJSON.count {
                if let commentID = clearUserPinsJSON[i]["comments"]["comment_id"].int {
                    clearUserPins.deleteCommentById("\(commentID)"){(status:Int,message:AnyObject?) in
                        print("Successfully Delete Comment by ID: \(commentID)")
                    }
                }
            }
        }
    }
    
}