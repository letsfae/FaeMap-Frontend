//
//  PinMenuLoadItems.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinMenuViewController {
    
    // MARK: -- Init blur view and pin selections
    func loadBlurAndPinSelection() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurViewMap = UIVisualEffectView(effect: blurEffect)
        blurViewMap.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview(blurViewMap)
        loadPinSelections()
        blurViewMap.alpha = 0.0
    }
    
    // MARK: -- Pins Creating Selections View
    private func loadPinSelections() {
        // initial position of buttons for cool animation
        let buttonCenterX_1: CGFloat = 79/414 * screenWidth
        let buttonCenterX_2: CGFloat = 208/414 * screenWidth
        let buttonCenterX_3: CGFloat = 337/414 * screenWidth
        
        let buttonCenterY_1: CGFloat = 205/736 * screenHeight
        /*
         let buttonCenterY_2: CGFloat = 347/736 * screenHeight
         let buttonCenterY_3: CGFloat = 489/736 * screenHeight
         */
        
        uiviewPinSelections = UIView(frame: blurViewMap.bounds)
        
        buttonMedia   = createMenuButton(buttonCenterX_1, y: buttonCenterY_1, picName: "submit_media")
        buttonChats   = createMenuButton(buttonCenterX_2, y: buttonCenterY_1, picName: "submit_chats")
        buttonComment = createMenuButton(buttonCenterX_3, y: buttonCenterY_1, picName: "submit_comment")
        /*
         buttonEvent   = createMenuButton(buttonCenterX_1, y: buttonCenterY_2, picName: "submit_event")
         buttonFaevor  = createMenuButton(buttonCenterX_2, y: buttonCenterY_2, picName: "submit_faevor")
         buttonNow     = createMenuButton(buttonCenterX_3, y: buttonCenterY_2, picName: "submit_now")
         buttonJoinMe  = createMenuButton(buttonCenterX_1, y: buttonCenterY_3, picName: "submit_joinme")
         buttonSell    = createMenuButton(buttonCenterX_2, y: buttonCenterY_3, picName: "submit_sell")
         buttonLive    = createMenuButton(buttonCenterX_3, y: buttonCenterY_3, picName: "submit_live")
         */
        buttonMedia.addTarget(self,
                                action: #selector(PinMenuViewController.actionCreateMediaPin(_:)),
                                for: .touchUpInside)
        buttonComment.addTarget(self,
                                action: #selector(PinMenuViewController.actionCreateCommentPin(_:)),
                                for: .touchUpInside)
        
        // initial position of labels for cool animation
        let labelCenterX_1: CGFloat = 31/414 * screenWidth
        let labelCenterX_2: CGFloat = 160/414 * screenWidth
        let labelCenterX_3: CGFloat = 289/414 * screenWidth
        
        let labelCenterY_1: CGFloat = 224/736 * screenHeight
        /*
         let labelCenterY_2: CGFloat = 366/736 * screenHeight
         let labelCenterY_3: CGFloat = 508/736 * screenHeight
         */
        
        labelMenuMedia   = createMenuLabel(labelCenterX_1, y: labelCenterY_1, title: "Media")
        labelMenuChats   = createMenuLabel(labelCenterX_2, y: labelCenterY_1, title: "Chats")
        labelMenuComment = createMenuLabel(labelCenterX_3, y: labelCenterY_1, title: "Comment")
        /*
         labelMenuEvent   = createMenuLabel(labelCenterX_1, y: labelCenterY_2, title: "Event")
         labelMenuFaevor  = createMenuLabel(labelCenterX_2, y: labelCenterY_2, title: "Faevor")
         labelMenuNow     = createMenuLabel(labelCenterX_3, y: labelCenterY_2, title: "Now")
         labelMenuJoinMe  = createMenuLabel(labelCenterX_1, y: labelCenterY_3, title: "Join Me!")
         labelMenuSell    = createMenuLabel(labelCenterX_2, y: labelCenterY_3, title: "Sell")
         labelMenuLive    = createMenuLabel(labelCenterX_3, y: labelCenterY_3, title: "Live")
         */
        
        let labelTitleX: CGFloat = 135/414 * screenWidth
        let labelTitleY: CGFloat = 134/414 * screenWidth
        let labelTitleW: CGFloat = 145/414 * screenWidth
        let labelTitleH: CGFloat = 41/414 * screenWidth
        let labelTitleF: CGFloat = 30/414 * screenWidth
        labelMenuTitle = UILabel(frame: CGRect(x: labelTitleX, y: labelTitleY, width: labelTitleW, height: labelTitleH))
        labelMenuTitle.alpha = 0.0
        labelMenuTitle.font = UIFont(name: "AvenirNext-DemiBold", size: labelTitleF)
        labelMenuTitle.text = "Create Pin"
        labelMenuTitle.textAlignment = .center
        labelMenuTitle.textColor = UIColor.white
        uiviewPinSelections.addSubview(labelMenuTitle)
        
        buttonClosePinBlurView = UIButton(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 65))
        buttonClosePinBlurView.addTarget(self,
                                         action: #selector(self.actionCloseSubmitPins(_:)),
                                         for: .touchUpInside)
        buttonClosePinBlurView.alpha = 0.0
        buttonClosePinBlurView.backgroundColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 0.7)
        buttonClosePinBlurView.setTitle("Close", for: .highlighted)
        buttonClosePinBlurView.setTitle("Close", for: UIControlState())
        buttonClosePinBlurView.setTitleColor(UIColor.lightGray, for: .highlighted)
        buttonClosePinBlurView.setTitleColor(UIColor.white, for: UIControlState())
        buttonClosePinBlurView.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        uiviewPinSelections.addSubview(buttonClosePinBlurView)
        
        blurViewMap.addSubview(uiviewPinSelections)
    }
    
    private func createMenuButton(_ x: CGFloat, y: CGFloat, picName: String) -> UIButton {
        let button = UIButton(frame: CGRect(x: x, y: y, width: 0, height: 0))
        button.setImage(UIImage(named: picName), for: UIControlState())
        uiviewPinSelections.addSubview(button)
        return button
    }
    
    private func createMenuLabel(_ x: CGFloat, y: CGFloat, title: String) -> UILabel {
        let width: CGFloat = 95/414 * screenWidth
        let height: CGFloat = 27/414 * screenWidth
        let fontSize: CGFloat = 20/414 * screenWidth
        let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
        label.text = title
        label.font = UIFont(name: "AvenirNext-DemiBold", size: fontSize)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.alpha = 0.0
        uiviewPinSelections.addSubview(label)
        return label
    }
}
