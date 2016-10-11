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
//        blurViewMap.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.1)
//        blurViewMap.layer.opacity = 0.6
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
        // initial position of buttons for cool animation
        let buttonCenterX_1: CGFloat = 79/414 * screenWidth
        let buttonCenterX_2: CGFloat = 208/414 * screenWidth
        let buttonCenterX_3: CGFloat = 337/414 * screenWidth
        
        let buttonCenterY_1: CGFloat = 205/736 * screenHeight
        let buttonCenterY_2: CGFloat = 347/736 * screenHeight
        let buttonCenterY_3: CGFloat = 489/736 * screenHeight

        uiviewPinSelections = UIView(frame: blurViewMap.bounds)
        
        buttonMedia   = createSubmitButton(buttonCenterX_1, y: buttonCenterY_1, picName: "submit_media")
        buttonChats   = createSubmitButton(buttonCenterX_2, y: buttonCenterY_1, picName: "submit_chats")
        buttonComment = createSubmitButton(buttonCenterX_3, y: buttonCenterY_1, picName: "submit_comment")
        buttonEvent   = createSubmitButton(buttonCenterX_1, y: buttonCenterY_2, picName: "submit_event")
        buttonFaevor  = createSubmitButton(buttonCenterX_2, y: buttonCenterY_2, picName: "submit_faevor")
        buttonNow     = createSubmitButton(buttonCenterX_3, y: buttonCenterY_2, picName: "submit_now")
        buttonJoinMe  = createSubmitButton(buttonCenterX_1, y: buttonCenterY_3, picName: "submit_joinme")
        buttonSell    = createSubmitButton(buttonCenterX_2, y: buttonCenterY_3, picName: "submit_sell")
        buttonLive    = createSubmitButton(buttonCenterX_3, y: buttonCenterY_3, picName: "submit_live")
        
        buttonComment.addTarget(self,
                                action: #selector(FaeMapViewController.actionCreateCommentPin(_:)),
                                forControlEvents: UIControlEvents.TouchUpInside)
        
        // initial position of labels for cool animation
        let labelCenterX_1: CGFloat = 31/414 * screenWidth
        let labelCenterX_2: CGFloat = 160/414 * screenWidth
        let labelCenterX_3: CGFloat = 289/414 * screenWidth
        
        let labelCenterY_1: CGFloat = 224/736 * screenHeight
        let labelCenterY_2: CGFloat = 366/736 * screenHeight
        let labelCenterY_3: CGFloat = 508/736 * screenHeight
        
        labelSubmitMedia   = createSubmitLabel(labelCenterX_1, y: labelCenterY_1, title: "Media")
        labelSubmitChats   = createSubmitLabel(labelCenterX_2, y: labelCenterY_1, title: "Chats")
        labelSubmitComment = createSubmitLabel(labelCenterX_3, y: labelCenterY_1, title: "Comment")
        labelSubmitEvent   = createSubmitLabel(labelCenterX_1, y: labelCenterY_2, title: "Event")
        labelSubmitFaevor  = createSubmitLabel(labelCenterX_2, y: labelCenterY_2, title: "Faevor")
        labelSubmitNow     = createSubmitLabel(labelCenterX_3, y: labelCenterY_2, title: "Now")
        labelSubmitJoinMe  = createSubmitLabel(labelCenterX_1, y: labelCenterY_3, title: "Join Me!")
        labelSubmitSell    = createSubmitLabel(labelCenterX_2, y: labelCenterY_3, title: "Sell")
        labelSubmitLive    = createSubmitLabel(labelCenterX_3, y: labelCenterY_3, title: "Live")
        
        let labelTitleX: CGFloat = 135/414 * screenWidth
        let labelTitleY: CGFloat = 134/414 * screenWidth
        let labelTitleW: CGFloat = 145/414 * screenWidth
        let labelTitleH: CGFloat = 41/414 * screenWidth
        let labelTitleF: CGFloat = 30/414 * screenWidth
        labelSubmitTitle = UILabel(frame: CGRectMake(labelTitleX, labelTitleY, labelTitleW, labelTitleH))
        labelSubmitTitle.alpha = 0.0
        labelSubmitTitle.font = UIFont(name: "AvenirNext-DemiBold", size: labelTitleF)
        labelSubmitTitle.text = "Create Pin"
        labelSubmitTitle.textAlignment = .Center
        labelSubmitTitle.textColor = UIColor.whiteColor()
        uiviewPinSelections.addSubview(labelSubmitTitle)
        
        buttonClosePinBlurView = UIButton(frame: CGRectMake(0, screenHeight, screenWidth, 65))
        buttonClosePinBlurView.addTarget(self,
                                         action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)),
                                         forControlEvents: UIControlEvents.TouchUpInside)
        buttonClosePinBlurView.alpha = 0.0
        buttonClosePinBlurView.backgroundColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 0.7)
        buttonClosePinBlurView.setTitle("Close", forState: .Highlighted)
        buttonClosePinBlurView.setTitle("Close", forState: .Normal)
        buttonClosePinBlurView.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonClosePinBlurView.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonClosePinBlurView.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        uiviewPinSelections.addSubview(buttonClosePinBlurView)
        uiviewPinSelections.hidden = true
        
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewPinSelections)
    }
    
    func createSubmitButton(x: CGFloat, y: CGFloat, picName: String) -> UIButton {
        let button = UIButton(frame: CGRectMake(x, y, 0, 0))
        button.setImage(UIImage(named: picName), forState: .Normal)
        uiviewPinSelections.addSubview(button)
        return button
    }
    
    func createSubmitLabel(x: CGFloat, y: CGFloat, title: String) -> UILabel {
        let width: CGFloat = 95/414 * screenWidth
        let height: CGFloat = 27/414 * screenWidth
        let fontSize: CGFloat = 20/414 * screenWidth
        let label = UILabel(frame: CGRectMake(x, y, width, height))
        label.text = title
        label.font = UIFont(name: "AvenirNext-DemiBold", size: fontSize)
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.alpha = 0.0
        uiviewPinSelections.addSubview(label)
        return label
    }
}
