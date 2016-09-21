//
//  CreateCommentPin.swift
//  faeBeta
//
//  Created by Yue on 9/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController: UITextViewDelegate {
    // MARK: -- Create Comment Pin View
    func loadCreateCommentPinView() {
        uiviewCreateCommentPin = UIView(frame: self.blurViewMap.bounds)
        self.blurViewMap.addSubview(uiviewCreateCommentPin)
        
        self.textViewForCommentPin = UITextView(frame: CGRectMake(60, 198, 294, 200))
        self.textViewForCommentPin.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.textViewForCommentPin.textColor = UIColor.whiteColor()
        self.textViewForCommentPin.backgroundColor = UIColor.clearColor()
        self.textViewForCommentPin.tintColor = UIColor.whiteColor()
        self.textViewForCommentPin.delegate = self
        self.uiviewCreateCommentPin.addSubview(textViewForCommentPin)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(294)]", options: [], views: textViewForCommentPin)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-198-[v0(200)]", options: [], views: textViewForCommentPin)
        NSLayoutConstraint(item: textViewForCommentPin, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        self.lableTextViewPlaceholder = UILabel(frame: CGRectMake(5, 8, 171, 27))
        self.lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.lableTextViewPlaceholder.textColor = colorPlaceHolder
        self.lableTextViewPlaceholder.text = "Type a comment..."
        self.textViewForCommentPin.addSubview(lableTextViewPlaceholder)
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(FaeMapViewController.tapOutsideToDismissKeyboard(_:)))
        self.uiviewCreateCommentPin.addGestureRecognizer(tapToDismissKeyboard)
        
        let imageCreateCommentPin = UIImageView(frame: CGRectMake(166, 41, 83, 90))
        imageCreateCommentPin.image = UIImage(named: "comment_pin_main_create")
        self.uiviewCreateCommentPin.addSubview(imageCreateCommentPin)
        let labelCreateCommentPinTitle = UILabel(frame: CGRectMake(109, 139, 196, 27))
        labelCreateCommentPinTitle.text = "Create Comment Pin"
        labelCreateCommentPinTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelCreateCommentPinTitle.textAlignment = .Center
        labelCreateCommentPinTitle.textColor = UIColor.whiteColor()
        self.uiviewCreateCommentPin.addSubview(labelCreateCommentPinTitle)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(83)][v1(196)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-41-[v0(90)]-8-[v1(27)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        NSLayoutConstraint(item: imageCreateCommentPin, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: labelCreateCommentPinTitle, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        let buttonBackToPinSelection = UIButton(frame: CGRectMake(15, 36, 18, 18))
        buttonBackToPinSelection.setImage(UIImage(named: "comment_main_back"), forState: .Normal)
        self.uiviewCreateCommentPin.addSubview(buttonBackToPinSelection)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:|-15-[v0(18)]", options: [], views: buttonBackToPinSelection)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(18)]", options: [], views: buttonBackToPinSelection)
        
        let buttonBackToPinSelectionLargerCover = UIButton(frame: CGRectMake(15, 36, 54, 54))
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelectionLargerCover)
        buttonBackToPinSelectionLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionBackToPinSelections(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonBackToPinSelection)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(54)]", options: [], views: buttonBackToPinSelection)
        
        let buttonCloseCreateComment = UIButton(frame: CGRectMake(381, 36, 18, 18))
        buttonCloseCreateComment.setImage(UIImage(named: "comment_main_close"), forState: .Normal)
        self.uiviewCreateCommentPin.addSubview(buttonCloseCreateComment)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: buttonCloseCreateComment)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(18)]", options: [], views: buttonCloseCreateComment)
        
        let buttonCloseCreateCommentLargerCover = UIButton(frame: CGRectMake(345, 36, 54, 54))
        uiviewCreateCommentPin.addSubview(buttonCloseCreateCommentLargerCover)
        buttonCloseCreateCommentLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(54)]-15-|", options: [], views: buttonCloseCreateCommentLargerCover)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(54)]", options: [], views: buttonCloseCreateCommentLargerCover)
        
        let uiviewSelectLocation = UIView()
        self.uiviewCreateCommentPin.addSubview(uiviewSelectLocation)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(276)]", options: [], views: uiviewSelectLocation)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(29)]-155-|", options: [], views: uiviewSelectLocation)
        NSLayoutConstraint(item: uiviewSelectLocation, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
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
        
        self.labelSelectLocationContent = UILabel()
        self.labelSelectLocationContent.text = "Current Location"
        self.labelSelectLocationContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.labelSelectLocationContent.textAlignment = .Left
        self.labelSelectLocationContent.textColor = UIColor.whiteColor()
        uiviewSelectLocation.addSubview(labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-4-[v0(25)]", options: [], views: labelSelectLocationContent)
        
        let buttonSelectLocation = UIButton()
        uiviewSelectLocation.addSubview(buttonSelectLocation)
        buttonSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonSelectLocation)
        uiviewSelectLocation.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonSelectLocation)
        
        self.buttonCommentSubmit = UIButton()
        self.buttonCommentSubmit.setTitle("Submit!", forState: .Normal)
        self.buttonCommentSubmit.setTitle("Submit!", forState: .Highlighted)
        self.buttonCommentSubmit.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.buttonCommentSubmit.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        self.buttonCommentSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        self.buttonCommentSubmit.backgroundColor = UIColor.lightGrayColor()
        self.uiviewCreateCommentPin.addSubview(buttonCommentSubmit)
        self.buttonCommentSubmit.addTarget(self, action: #selector(FaeMapViewController.actionSubmitComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.blurViewMap.addSubview(uiviewCreateCommentPin)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonCommentSubmit)
        self.uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonCommentSubmit)
    }
    
    func tapOutsideToDismissKeyboard(sender: UITapGestureRecognizer) {
        self.textViewForCommentPin.endEditing(true)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == self.textViewForCommentPin {
            let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            if self.textViewForCommentPin.text.stringByTrimmingCharactersInSet(spacing).isEmpty == false {
                self.buttonCommentSubmit.enabled = true
                self.lableTextViewPlaceholder.hidden = true
                self.buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
            }
            else {
                self.buttonCommentSubmit.enabled = false
                self.lableTextViewPlaceholder.hidden = false
                self.buttonCommentSubmit.backgroundColor = UIColor.lightGrayColor()
            }
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView == self.textViewForCommentPin {
            if (text == "\n")  {
                self.textViewForCommentPin.resignFirstResponder()
                return false
            }
        }
        return true
    }

}