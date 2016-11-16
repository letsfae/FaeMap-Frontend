//
//  CCPLoadItems.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreateCommentPinViewController {
    func loadCreateCommentPinView() {
        uiviewCreateCommentPin = UIView(frame: self.view.bounds)
        uiviewCreateCommentPin.alpha = 0.0
        self.view.addSubview(uiviewCreateCommentPin)
        
        textViewForCommentPin = UITextView(frame: CGRect(x: 60, y: 198, width: 294, height: 27))
        textViewForCommentPin.font = UIFont(name: "AvenirNext-Regular", size: 20)
        textViewForCommentPin.textColor = UIColor.white
        textViewForCommentPin.backgroundColor = UIColor.clear
        textViewForCommentPin.tintColor = UIColor.white
        textViewForCommentPin.delegate = self
        textViewForCommentPin.isScrollEnabled = false
        uiviewCreateCommentPin.addSubview(textViewForCommentPin)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(294)]", options: [], views: textViewForCommentPin)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-198-[v0(44)]", options: [], views: textViewForCommentPin)
        NSLayoutConstraint(item: textViewForCommentPin, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateCommentPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 5, y: 8, width: 171, height: 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lableTextViewPlaceholder.textColor = colorPlaceHolder
        lableTextViewPlaceholder.text = "Type a comment..."
        textViewForCommentPin.addSubview(lableTextViewPlaceholder)
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreateCommentPinViewController.tapOutsideToDismissKeyboard(_:)))
        uiviewCreateCommentPin.addGestureRecognizer(tapToDismissKeyboard)
        
        let imageCreateCommentPin = UIImageView(frame: CGRect(x: 166, y: 41, width: 83, height: 90))
        imageCreateCommentPin.image = UIImage(named: "comment_pin_main_create")
        uiviewCreateCommentPin.addSubview(imageCreateCommentPin)
        let labelCreateCommentPinTitle = UILabel(frame: CGRect(x: 109, y: 139, width: 196, height: 27))
        labelCreateCommentPinTitle.text = "Create Comment Pin"
        labelCreateCommentPinTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelCreateCommentPinTitle.textAlignment = .center
        labelCreateCommentPinTitle.textColor = UIColor.white
        uiviewCreateCommentPin.addSubview(labelCreateCommentPinTitle)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-41-[v0(90)]-8-[v1(27)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        NSLayoutConstraint(item: imageCreateCommentPin, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateCommentPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: labelCreateCommentPinTitle, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateCommentPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        let buttonBackToPinSelection = UIButton()
        buttonBackToPinSelection.setImage(UIImage(named: "comment_main_back"), for: UIControlState())
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelection)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: buttonBackToPinSelection)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonBackToPinSelection)
        buttonBackToPinSelection.addTarget(self, action: #selector(CreateCommentPinViewController.actionBackToPinSelections(_:)), for: UIControlEvents.touchUpInside)
        
        let buttonCloseCreateComment = UIButton()
        buttonCloseCreateComment.setImage(UIImage(named: "comment_main_close"), for: UIControlState())
        uiviewCreateCommentPin.addSubview(buttonCloseCreateComment)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: buttonCloseCreateComment)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonCloseCreateComment)
        buttonCloseCreateComment.addTarget(self, action: #selector(CreateCommentPinViewController.actionCloseSubmitPins(_:)), for: .touchUpInside)
        
        let uiviewSelectLocation = UIView()
        uiviewCreateCommentPin.addSubview(uiviewSelectLocation)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(294)]", options: [], views: uiviewSelectLocation)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(29)]-209-|", options: [], views: uiviewSelectLocation)
        NSLayoutConstraint(item: uiviewSelectLocation, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateCommentPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        let imageSelectLocation_1 = UIImageView()
        imageSelectLocation_1.image = UIImage(named: "pin_select_location_1")
        uiviewSelectLocation.addSubview(imageSelectLocation_1)
        uiviewSelectLocation.addConstraintsWithFormat("H:|-0-[v0(25)]", options: [], views: imageSelectLocation_1)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageSelectLocation_1)
        
        let imageSelectLocation_2 = UIImageView()
        imageSelectLocation_2.image = UIImage(named: "pin_select_location_2")
        uiviewSelectLocation.addSubview(imageSelectLocation_2)
        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(10.5)]-7.5-|", options: [], views: imageSelectLocation_2)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-7-[v0(19)]", options: [], views: imageSelectLocation_2)
        
        labelSelectLocationContent = UILabel()
        labelSelectLocationContent.text = "Current Location"
        labelSelectLocationContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelSelectLocationContent.textAlignment = .left
        labelSelectLocationContent.textColor = UIColor.white
        uiviewSelectLocation.addSubview(labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-4-[v0(25)]", options: [], views: labelSelectLocationContent)
        
        let buttonSelectLocation = UIButton()
        uiviewSelectLocation.addSubview(buttonSelectLocation)
        buttonSelectLocation.addTarget(self, action: #selector(CreateCommentPinViewController.actionSelectLocation(_:)), for: .touchUpInside)
        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonSelectLocation)
        uiviewSelectLocation.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonSelectLocation)
        
        buttonCommentSubmit = UIButton()
        buttonCommentSubmit.setTitle("Submit!", for: UIControlState())
        buttonCommentSubmit.setTitle("Submit!", for: .highlighted)
        buttonCommentSubmit.setTitleColor(UIColor.white, for: UIControlState())
        buttonCommentSubmit.setTitleColor(UIColor.lightGray, for: .highlighted)
        buttonCommentSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonCommentSubmit.backgroundColor = UIColor.lightGray
        uiviewCreateCommentPin.addSubview(buttonCommentSubmit)
        buttonCommentSubmit.addTarget(self, action: #selector(CreateCommentPinViewController.actionSubmitComment(_:)), for: .touchUpInside)
        self.view.addSubview(uiviewCreateCommentPin)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonCommentSubmit)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonCommentSubmit)
    }
    
    func loadKeyboardToolBar() {
        uiviewToolBar = UIView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 50))
        uiviewToolBar.backgroundColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 0.7)
        self.view.addSubview(uiviewToolBar)
        
        buttonOpenFaceGesPanel = UIButton()
        buttonOpenFaceGesPanel.setImage(UIImage(named: "faceGesture"), for: UIControlState())
        uiviewToolBar.addSubview(buttonOpenFaceGesPanel)
        uiviewToolBar.addConstraintsWithFormat("H:|-15-[v0(23)]", options: [], views: buttonOpenFaceGesPanel)
        uiviewToolBar.addConstraintsWithFormat("V:[v0(22)]-14-|", options: [], views: buttonOpenFaceGesPanel)
        
        buttonFinishEdit = UIButton()
        buttonFinishEdit.setImage(UIImage(named: "CCPFinish"), for: UIControlState())
        uiviewToolBar.addSubview(buttonFinishEdit)
        uiviewToolBar.addConstraintsWithFormat("H:[v0(49)]-14-|", options: [], views: buttonFinishEdit)
        uiviewToolBar.addConstraintsWithFormat("V:[v0(25)]-11-|", options: [], views: buttonFinishEdit)
        buttonFinishEdit.addTarget(self, action: #selector(CreateCommentPinViewController.actionFinishEditing(_:)), for: .touchUpInside)
        
        labelCountChars = UILabel(frame: CGRect(x: screenWidth-43, y: screenHeight, width: 29, height: 20))
        labelCountChars.text = "200"
        labelCountChars.font = UIFont(name: "AvenirNext-Medium", size: 16)
        labelCountChars.textAlignment = .right
        labelCountChars.textColor = UIColor.white
        self.view.addSubview(labelCountChars)
    }
}
