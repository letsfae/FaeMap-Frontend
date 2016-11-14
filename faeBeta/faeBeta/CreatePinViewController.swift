//
//  CreatePinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

protocol CreatePinViewControllerDelegate {
    func sendCommentGeoInfo(_ commentID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class CreatePinViewController: UIViewController, UITextViewDelegate {
    
    var delegate: CreatePinViewControllerDelegate?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    // MARK: -- Blur View Pin Buttons and Labels
    var uiviewPinSelections: UIView!
    var blurViewMap: UIVisualEffectView!
    var buttonMedia: UIButton!
    var buttonChats: UIButton!
    var buttonComment: UIButton!
    var buttonEvent: UIButton!
    var buttonFaevor: UIButton!
    var buttonNow: UIButton!
    var buttonJoinMe: UIButton!
    var buttonSell: UIButton!
    var buttonLive: UIButton!
    
    var labelSubmitTitle: UILabel!
    var labelSubmitMedia: UILabel!
    var labelSubmitChats: UILabel!
    var labelSubmitComment: UILabel!
    var labelSubmitEvent: UILabel!
    var labelSubmitFaevor: UILabel!
    var labelSubmitNow: UILabel!
    var labelSubmitJoinMe: UILabel!
    var labelSubmitSell: UILabel!
    var labelSubmitLive: UILabel!
    var labelUnreadMessages: UILabel!
    
    var buttonClosePinBlurView: UIButton!
    var buttonCommentSubmit: UIButton!
    
    // MARK: -- Create Comment Pin
    var uiviewCreateCommentPin: UIView!
    var labelSelectLocationContent: UILabel!
    var textViewForCommentPin: UITextView!
    var lableTextViewPlaceholder: UILabel!
    
    // MARK: -- Create Pin
    var imagePinOnMap: UIImageView!
    var buttonSetLocationOnMap: UIButton!
    var isInPinLocationSelect = false
    let colorPlaceHolder = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    
    // MARK: -- Geo Information Sent to Server
    var selectedLatitude: String!
    var selectedLongitude: String!
    
    // MARK: -- location manager
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        loadBlurAndPinSelection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        blurViewMap.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.blurViewMap.alpha = 1.0
            }, completion: nil)
        actionCreateCommentPin(buttonComment)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locManager.location
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
    }
    
    func loadBlurAndPinSelection() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurViewMap = UIVisualEffectView(effect: blurEffect)
        blurViewMap.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        //        blurViewMap.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.1)
        //        blurViewMap.layer.opacity = 0.6
        self.view.addSubview(blurViewMap)
        loadPinSelections()
        loadCreateCommentPinView()
        uiviewCreateCommentPin.isHidden = false
        uiviewCreateCommentPin.alpha = 0.0
        blurViewMap.alpha = 0.0
        blurViewMap.isHidden = true
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
                                action: #selector(CreatePinViewController.actionCreateCommentPin(_:)),
                                for: .touchUpInside)
        
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
        labelSubmitTitle = UILabel(frame: CGRect(x: labelTitleX, y: labelTitleY, width: labelTitleW, height: labelTitleH))
        labelSubmitTitle.alpha = 0.0
        labelSubmitTitle.font = UIFont(name: "AvenirNext-DemiBold", size: labelTitleF)
        labelSubmitTitle.text = "Create Pin"
        labelSubmitTitle.textAlignment = .center
        labelSubmitTitle.textColor = UIColor.white
        uiviewPinSelections.addSubview(labelSubmitTitle)
        
        buttonClosePinBlurView = UIButton(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 65))
        buttonClosePinBlurView.addTarget(self,
                                         action: #selector(CreatePinViewController.actionCloseSubmitPins(_:)),
                                         for: .touchUpInside)
        buttonClosePinBlurView.alpha = 0.0
        buttonClosePinBlurView.backgroundColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 0.7)
        buttonClosePinBlurView.setTitle("Close", for: .highlighted)
        buttonClosePinBlurView.setTitle("Close", for: UIControlState())
        buttonClosePinBlurView.setTitleColor(UIColor.lightGray, for: .highlighted)
        buttonClosePinBlurView.setTitleColor(UIColor.white, for: UIControlState())
        buttonClosePinBlurView.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        uiviewPinSelections.addSubview(buttonClosePinBlurView)
        uiviewPinSelections.isHidden = true
        
        blurViewMap.addSubview(uiviewPinSelections)
    }
    
    func actionCloseSubmitPins(_ sender: UIButton!) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func createSubmitButton(_ x: CGFloat, y: CGFloat, picName: String) -> UIButton {
        let button = UIButton(frame: CGRect(x: x, y: y, width: 0, height: 0))
        button.setImage(UIImage(named: picName), for: UIControlState())
        uiviewPinSelections.addSubview(button)
        return button
    }
    
    func createSubmitLabel(_ x: CGFloat, y: CGFloat, title: String) -> UILabel {
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
    
    func loadCreateCommentPinView() {
        uiviewCreateCommentPin = UIView(frame: blurViewMap.bounds)
        blurViewMap.addSubview(uiviewCreateCommentPin)
        
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
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreatePinViewController.tapOutsideToDismissKeyboard(_:)))
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
//        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(83)][v1(196)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-41-[v0(90)]-8-[v1(27)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
        NSLayoutConstraint(item: imageCreateCommentPin, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateCommentPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: labelCreateCommentPinTitle, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateCommentPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        /*
        // Hide this button for 11.01 Dev
        let buttonBackToPinSelection = UIButton()
        buttonBackToPinSelection.setImage(UIImage(named: "comment_main_back"), forState: .Normal)
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelection)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:|-15-[v0(18)]", options: [], views: buttonBackToPinSelection)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(18)]", options: [], views: buttonBackToPinSelection)
        let buttonBackToPinSelectionLargerCover = UIButton()
        uiviewCreateCommentPin.addSubview(buttonBackToPinSelectionLargerCover)
//        buttonBackToPinSelectionLargerCover.addTarget(self, action: #selector(FaeMapViewController.actionBackToPinSelections(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonBackToPinSelection)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(54)]", options: [], views: buttonBackToPinSelection)
        buttonBackToPinSelection.hidden = true            // --> delete if want to see the Waze menu style animation
        buttonBackToPinSelectionLargerCover.hidden = true // --> delete if want to see the Waze menu style animation
        /////////////////////////////////
        */
        
        let buttonCloseCreateComment = UIButton(frame: CGRect(x: 381, y: 36, width: 18, height: 18))
        buttonCloseCreateComment.setImage(UIImage(named: "comment_main_close"), for: UIControlState())
        uiviewCreateCommentPin.addSubview(buttonCloseCreateComment)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: buttonCloseCreateComment)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(18)]", options: [], views: buttonCloseCreateComment)
        
        let buttonCloseCreateCommentLargerCover = UIButton(frame: CGRect(x: 345, y: 36, width: 54, height: 54))
        uiviewCreateCommentPin.addSubview(buttonCloseCreateCommentLargerCover)
        buttonCloseCreateCommentLargerCover.addTarget(self, action: #selector(CreatePinViewController.actionCloseSubmitPins(_:)), for: .touchUpInside)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(54)]-15-|", options: [], views: buttonCloseCreateCommentLargerCover)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:|-36-[v0(54)]", options: [], views: buttonCloseCreateCommentLargerCover)
        
        let uiviewSelectLocation = UIView()
        uiviewCreateCommentPin.addSubview(uiviewSelectLocation)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:[v0(276)]", options: [], views: uiviewSelectLocation)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(29)]-155-|", options: [], views: uiviewSelectLocation)
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
        buttonSelectLocation.addTarget(self, action: #selector(CreatePinViewController.actionSelectLocation(_:)), for: .touchUpInside)
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
        buttonCommentSubmit.addTarget(self, action: #selector(CreatePinViewController.actionSubmitComment(_:)), for: .touchUpInside)
        blurViewMap.addSubview(uiviewCreateCommentPin)
        uiviewCreateCommentPin.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonCommentSubmit)
        uiviewCreateCommentPin.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonCommentSubmit)
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        textViewForCommentPin.endEditing(true)
        textViewForCommentPin.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == textViewForCommentPin {
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if textViewForCommentPin.text.trimmingCharacters(in: spacing).isEmpty == false {
                buttonCommentSubmit.isEnabled = true
                lableTextViewPlaceholder.isHidden = true
                buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
            }
            else {
                buttonCommentSubmit.isEnabled = false
                lableTextViewPlaceholder.isHidden = false
                buttonCommentSubmit.backgroundColor = UIColor.lightGray
            }
        }
        let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
        if numLines <= 8 {
            let fixedWidth = textView.frame.size.width
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            textView.frame = newFrame
            textView.isScrollEnabled = false
        }
        else if numLines > 8 {
            textView.isScrollEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewForCommentPin {
            if (text == "\n")  {
                textViewForCommentPin.resignFirstResponder()
                return false
            }
            return textView.text.characters.count + (text.characters.count - range.length) <= 200
        }
        return true
    }

    // It is not currently use for 11.01's DEV
    func actionCreateCommentPin(_ sender: UIButton!) {
        UIView.animate(withDuration: 0.4, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 0.0
            self.uiviewCreateCommentPin.alpha = 1.0
        }), completion: nil)
        labelSelectLocationContent.text = "Current Location"
    }
    ///////////////////////////////////////////
    
    func actionSubmitComment(_ sender: UIButton) {
        let postSingleComment = FaeMap()

        var submitLatitude = selectedLatitude
        var submitLongitude = selectedLongitude
        
        let commentContent = textViewForCommentPin.text
        
        if labelSelectLocationContent.text == "Current Location" {
            submitLatitude = "\(currentLatitude)"
            submitLongitude = "\(currentLongitude)"
        }
        
        if commentContent == "" {
            return
        }
        
        postSingleComment.whereKey("geo_latitude", value: submitLatitude)
        postSingleComment.whereKey("geo_longitude", value: submitLongitude)
        postSingleComment.whereKey("content", value: commentContent)
        postSingleComment.whereKey("interaction_radius", value: "99999999")
        postSingleComment.whereKey("duration", value: "180")
        
        postSingleComment.postComment{(status: Int, message: Any?) in
            if let getMessage = message as? NSDictionary{
                print("Have Post Comment")
                if let getMessageID = getMessage["comment_id"] {
                    let getJustPostedComment = FaeMap()
                    getJustPostedComment.getComment("\(getMessageID)"){(status: Int, message: Any?) in
                        print("Have got comment_id of this posted comment")
                        let latDouble = Double(submitLatitude!)
                        let longDouble = Double(submitLongitude!)
                        let lat = CLLocationDegrees(latDouble!)
                        let long = CLLocationDegrees(longDouble!)
                        self.delegate?.sendCommentGeoInfo("\(getMessageID)", latitude: lat, longitude: long)
                        self.dismiss(animated: false, completion: nil)
                    }
                }
                else {
                    print("Cannot get comment_id of this posted comment")
                }
            }
            else {
                print("Post Comment Fail")
            }
        }
    }
}
