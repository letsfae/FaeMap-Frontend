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
        uiviewCreateCommentPin = UIView(frame: blurViewMap.bounds)
        blurViewMap.addSubview(uiviewCreateCommentPin)
        
        textViewForCommentPin = UITextView(frame: CGRectMake(60, 198, 294, 27))
        textViewForCommentPin.font = UIFont(name: "AvenirNext-Regular", size: 20)
        textViewForCommentPin.textColor = UIColor.whiteColor()
        textViewForCommentPin.backgroundColor = UIColor.clearColor()
        textViewForCommentPin.tintColor = UIColor.whiteColor()
        textViewForCommentPin.delegate = self
        textViewForCommentPin.scrollEnabled = false
        uiviewCreateCommentPin.addSubview(textViewForCommentPin)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(294)]", options: [], views: textViewForCommentPin)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-198-[v0(44)]", options: [], views: textViewForCommentPin)
        NSLayoutConstraint(item: textViewForCommentPin, attribute: .CenterX, relatedBy: .Equal, toItem: uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        lableTextViewPlaceholder = UILabel(frame: CGRectMake(5, 8, 171, 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lableTextViewPlaceholder.textColor = colorPlaceHolder
        lableTextViewPlaceholder.text = "Type a comment..."
        textViewForCommentPin.addSubview(lableTextViewPlaceholder)
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(FaeMapViewController.tapOutsideToDismissKeyboard(_:)))
        uiviewCreateCommentPin.addGestureRecognizer(tapToDismissKeyboard)
        
        let imageCreateCommentPin = UIImageView(frame: CGRectMake(166, 41, 83, 90))
        imageCreateCommentPin.image = UIImage(named: "comment_pin_main_create")
        uiviewCreateCommentPin.addSubview(imageCreateCommentPin)
        let labelCreateCommentPinTitle = UILabel(frame: CGRectMake(109, 139, 196, 27))
        labelCreateCommentPinTitle.text = "Create Comment Pin"
        labelCreateCommentPinTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelCreateCommentPinTitle.textAlignment = .Center
        labelCreateCommentPinTitle.textColor = UIColor.whiteColor()
        uiviewCreateCommentPin.addSubview(labelCreateCommentPinTitle)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(83)][v1(196)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-41-[v0(90)]-8-[v1(27)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        NSLayoutConstraint(item: imageCreateCommentPin, attribute: .CenterX, relatedBy: .Equal, toItem: uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: labelCreateCommentPinTitle, attribute: .CenterX, relatedBy: .Equal, toItem: uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        let buttonBackToPinSelection = UIButton(frame: CGRectMake(15, 36, 18, 18))
        buttonBackToPinSelection.setImage(UIImage(named: "comment_main_back"), forState: .Normal)
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelection)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:|-15-[v0(18)]", options: [], views: buttonBackToPinSelection)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(18)]", options: [], views: buttonBackToPinSelection)
        
        let buttonBackToPinSelectionLargerCover = UIButton(frame: CGRectMake(15, 36, 54, 54))
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelectionLargerCover)
        buttonBackToPinSelectionLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionBackToPinSelections(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonBackToPinSelection)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(54)]", options: [], views: buttonBackToPinSelection)
        
        let buttonCloseCreateComment = UIButton(frame: CGRectMake(381, 36, 18, 18))
        buttonCloseCreateComment.setImage(UIImage(named: "comment_main_close"), forState: .Normal)
        uiviewCreateCommentPin.addSubview(buttonCloseCreateComment)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: buttonCloseCreateComment)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(18)]", options: [], views: buttonCloseCreateComment)
        
        let buttonCloseCreateCommentLargerCover = UIButton(frame: CGRectMake(345, 36, 54, 54))
        uiviewCreateCommentPin.addSubview(buttonCloseCreateCommentLargerCover)
        buttonCloseCreateCommentLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionCloseSubmitPins(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(54)]-15-|", options: [], views: buttonCloseCreateCommentLargerCover)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(54)]", options: [], views: buttonCloseCreateCommentLargerCover)
        
        let uiviewSelectLocation = UIView()
        uiviewCreateCommentPin.addSubview(uiviewSelectLocation)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(276)]", options: [], views: uiviewSelectLocation)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(29)]-155-|", options: [], views: uiviewSelectLocation)
        NSLayoutConstraint(item: uiviewSelectLocation, attribute: .CenterX, relatedBy: .Equal, toItem: uiviewCreateCommentPin, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
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
        labelSelectLocationContent.textAlignment = .Left
        labelSelectLocationContent.textColor = UIColor.whiteColor()
        uiviewSelectLocation.addSubview(labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-4-[v0(25)]", options: [], views: labelSelectLocationContent)
        
        let buttonSelectLocation = UIButton()
        uiviewSelectLocation.addSubview(buttonSelectLocation)
        buttonSelectLocation.addTarget(self, action: #selector(FaeMapViewController.actionSelectLocation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonSelectLocation)
        uiviewSelectLocation.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonSelectLocation)
        
        buttonCommentSubmit = UIButton()
        buttonCommentSubmit.setTitle("Submit!", forState: .Normal)
        buttonCommentSubmit.setTitle("Submit!", forState: .Highlighted)
        buttonCommentSubmit.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonCommentSubmit.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonCommentSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonCommentSubmit.backgroundColor = UIColor.lightGrayColor()
        uiviewCreateCommentPin.addSubview(buttonCommentSubmit)
        buttonCommentSubmit.addTarget(self, action: #selector(FaeMapViewController.actionSubmitComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        blurViewMap.addSubview(uiviewCreateCommentPin)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonCommentSubmit)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonCommentSubmit)
    }
    
    func tapOutsideToDismissKeyboard(sender: UITapGestureRecognizer) {
        textViewForCommentPin.endEditing(true)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == textViewForCommentPin {
            let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            if textViewForCommentPin.text.stringByTrimmingCharactersInSet(spacing).isEmpty == false {
                buttonCommentSubmit.enabled = true
                lableTextViewPlaceholder.hidden = true
                buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
            }
            else {
                buttonCommentSubmit.enabled = false
                lableTextViewPlaceholder.hidden = false
                buttonCommentSubmit.backgroundColor = UIColor.lightGrayColor()
            }
        }
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            print(numLines)
            if numLines <= 8 {
                let fixedWidth = textView.frame.size.width
                textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
                var newFrame = textView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                textView.frame = newFrame
                textView.scrollEnabled = false
            }
            else if numLines > 8 {
                textView.scrollEnabled = true
            }
            print(textView.text)
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewForCommentPin {
            if (text == "\n")  {
                textViewForCommentPin.resignFirstResponder()
                return false
            }
        }
        return true
    }

}
