//
//  CCPLoadItems.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

//import UIKit
//
//extension CreateCommentPinViewController {
//    override func setupBaseUI() {
//        super.setupBaseUI()
//        
//        imgTitle.image = #imageLiteral(resourceName: "commentPinTitleImage")
//        lblTitle.text = "Create Comment Pin"
//        btnSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 0.65)
//        switchAnony.onTintColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1)
//        
//        loadCreateCommentPinView()
//    }
//    
//    func loadCreateCommentPinView() {
//        textViewForCommentPin = CreatePinTextView(frame: CGRect(x: (screenWidth - 294) / 2, y: 195, width: 294, height: 35))
//        textViewForCommentPin.placeHolder = "Type a comment..."
//        textViewForCommentPin.observerDelegate = self
//        self.view.addSubview(textViewForCommentPin)
//        self.view.addConstraintsWithFormat("H:[v0(294)]", options: [], views: textViewForCommentPin)
//        self.view.addConstraintsWithFormat("V:|-198-[v0(44)]", options: [], views: textViewForCommentPin)
//        NSLayoutConstraint(item: textViewForCommentPin, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 5, y: 8, width: 171, height: 27))
//        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
//        lableTextViewPlaceholder.textColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
//        lableTextViewPlaceholder.text = "Type a comment..."
//        textViewForCommentPin.addSubview(lableTextViewPlaceholder)
        
//        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
//        self.view.addGestureRecognizer(tapToDismissKeyboard)
        
//        let imageCreateCommentPin = UIImageView(frame: CGRect(x: 166, y: 36, width: 84, height: 91))
//        imageCreateCommentPin.image = UIImage(named: "commentPinTitleImage")
//        self.view.addSubview(imageCreateCommentPin)
        
//        labelCreateCommentPinTitle = UILabel(frame: CGRect(x: 109, y: 146, width: 196, height: 27))
//        labelCreateCommentPinTitle.text = "Create Comment Pin"
//        labelCreateCommentPinTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
//        labelCreateCommentPinTitle.textAlignment = .center
//        labelCreateCommentPinTitle.textColor = UIColor.white
//        self.view.addSubview(labelCreateCommentPinTitle)
//        self.view.addConstraintsWithFormat("V:|-36-[v0(91)]-19-[v1(27)]", options: [], views: imageCreateCommentPin, labelCreateCommentPinTitle)
//        NSLayoutConstraint(item: imageCreateCommentPin, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        NSLayoutConstraint(item: labelCreateCommentPinTitle, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
//        let buttonBackToPinSelection = UIButton()
//        buttonBackToPinSelection.setImage(UIImage(named: "backToPinMenu"), for: .normal)
//        self.view.addSubview(buttonBackToPinSelection)
//        self.view.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: buttonBackToPinSelection)
//        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonBackToPinSelection)
//        buttonBackToPinSelection.addTarget(self, action: #selector(CreateCommentPinViewController.actionBackToPinSelections(_:)), for: .touchUpInside)
        
//        let buttonCloseCreateComment = UIButton()
//        buttonCloseCreateComment.setImage(UIImage(named: "closePinCreation"), for: .normal)
//        self.view.addSubview(buttonCloseCreateComment)
//        self.view.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: buttonCloseCreateComment)
//        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonCloseCreateComment)
//        buttonCloseCreateComment.addTarget(self, action: #selector(CreateCommentPinViewController.actionCloseSubmitPins(_:)), for: .touchUpInside)
        
//        uiviewSelectLocation = UIView()
//        self.view.addSubview(uiviewSelectLocation)
//        self.view.addConstraintsWithFormat("H:[v0(293)]", options: [], views: uiviewSelectLocation)
//        self.view.addConstraintsWithFormat("V:[v0(29)]-209-|", options: [], views: uiviewSelectLocation)
//        NSLayoutConstraint(item: uiviewSelectLocation, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        
//        let imageSelectLocation_1 = UIImageView()
//        imageSelectLocation_1.image = UIImage(named: "pinSelectLocation01")
//        uiviewSelectLocation.addSubview(imageSelectLocation_1)
//        uiviewSelectLocation.addConstraintsWithFormat("H:|-0-[v0(25)]", options: [], views: imageSelectLocation_1)
//        uiviewSelectLocation.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageSelectLocation_1)
//        
//        let imageSelectLocation_2 = UIImageView()
//        imageSelectLocation_2.image = UIImage(named: "pinSelectLocation02")
//        uiviewSelectLocation.addSubview(imageSelectLocation_2)
//        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(10.5)]-0-|", options: [], views: imageSelectLocation_2)
//        uiviewSelectLocation.addConstraintsWithFormat("V:|-7-[v0(19)]", options: [], views: imageSelectLocation_2)
//        
//        labelSelectLocationContent = UILabel()
//        labelSelectLocationContent.text = "Current Map View"
//        labelSelectLocationContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        labelSelectLocationContent.textAlignment = .left
//        labelSelectLocationContent.textColor = UIColor.white
//        uiviewSelectLocation.addSubview(labelSelectLocationContent)
//        uiviewSelectLocation.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelSelectLocationContent)
//        uiviewSelectLocation.addConstraintsWithFormat("V:|-4-[v0(25)]", options: [], views: labelSelectLocationContent)
//        
//        let buttonSelectLocation = UIButton()
//        uiviewSelectLocation.addSubview(buttonSelectLocation)
//        buttonSelectLocation.addTarget(self, action: #selector(CreateCommentPinViewController.actionSelectLocation(_:)), for: .touchUpInside)
//        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonSelectLocation)
//        uiviewSelectLocation.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonSelectLocation)
        
//        buttonCommentSubmit = UIButton()
//        buttonCommentSubmit.setTitle("Submit!", for: .normal)
//        buttonCommentSubmit.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: .normal)
//        buttonCommentSubmit.setTitleColor(UIColor.lightGray, for: .highlighted)
//        buttonCommentSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
//        buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 0.65)
//        self.view.addSubview(buttonCommentSubmit)
//        buttonCommentSubmit.adjustsImageWhenDisabled = false
//        buttonCommentSubmit.isEnabled = false
//        buttonCommentSubmit.addTarget(self, action: #selector(CreateCommentPinViewController.actionSubmitComment(_:)), for: .touchUpInside)
//        self.view.addSubview(self.view)
//        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonCommentSubmit)
//        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonCommentSubmit)
        
        
//        loadMoreOptionsButton()
//        loadMoreOptionsItems()
//        loadAnonymous()
//        loadKeyboardToolBar()
    
//        loadEmojiView()
//    }
    

//    func loadAnonymous() {
//        switchAnony = UISwitch()
//        switchAnony.onTintColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1)
//        switchAnony.transform = CGAffineTransform(scaleX: 35/51, y: 21/31)
//        self.view.addSubview(switchAnony)
//        self.view.addConstraintsWithFormat("H:[v0(35)]-130-|", options: [], views: switchAnony)
//        self.view.addConstraintsWithFormat("V:[v0(21)]-79-|", options: [], views: switchAnony)
//
//        btnDoAnony = UIButton()
//        btnDoAnony.setTitle("Anonymous", for: .normal)
//        btnDoAnony.setTitleColor(UIColor.white, for: .normal)
//        btnDoAnony.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        self.view.addSubview(btnDoAnony)
//        self.view.addConstraintsWithFormat("H:[v0(100)]-14-|", options: [], views: btnDoAnony)
//        self.view.addConstraintsWithFormat("V:[v0(25)]-74-|", options: [], views: btnDoAnony)
//        btnDoAnony.addTarget(self, action: #selector(self.actionDoAnony), for: .touchUpInside)
//    }
//    
//    func actionDoAnony() {
//        switchAnony.setOn(!switchAnony.isOn, animated: true)
//    }
    
//    fileprivate func loadAnonymousButton() {
//        buttonAnonymous = UIButton()
//        buttonAnonymous.setImage(UIImage(named: "anonymousUnclicked"), for: .normal)
//        buttonAnonymous.adjustsImageWhenHighlighted = false
//        buttonAnonymous.tag = 0
//        buttonAnonymous.addTarget(self, action: #selector(self.actionAnonymous(_:)), for: .touchUpInside)
//        self.view.addSubview(buttonAnonymous)
//        self.view.addConstraintsWithFormat("H:[v0(134)]-14-|", options: [], views: buttonAnonymous)
//        self.view.addConstraintsWithFormat("V:[v0(25)]-77-|", options: [], views: buttonAnonymous)
//    }
    
//    fileprivate func loadKeyboardToolBar() {
//        inputToolbar = CreatePinInputToolbar()
//        inputToolbar.delegate = self
//        self.view.addSubview(inputToolbar)
//        inputToolbar.alpha = 0
//        self.view.layoutIfNeeded()
//    }
    
//    fileprivate func loadEmojiView(){
//        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
//        emojiView.sendStickerDelegate = self
//        self.view.addSubview(emojiView)
//    }
    
//    fileprivate func loadMoreOptionsButton() {
//        uiviewMoreOptions = UIView()
//        self.view.addSubview(uiviewMoreOptions)
//        self.view.addConstraintsWithFormat("H:[v0(294)]", options: [], views: uiviewMoreOptions)
//        self.view.addConstraintsWithFormat("V:[v0(29)]-141-|", options: [], views: uiviewMoreOptions)
//        NSLayoutConstraint(item: uiviewMoreOptions, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        
//        let imageMoreOptions_1 = UIImageView()
//        imageMoreOptions_1.image = UIImage(named: "optionsIcon")
//        uiviewMoreOptions.addSubview(imageMoreOptions_1)
//        uiviewMoreOptions.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imageMoreOptions_1)
//        uiviewMoreOptions.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageMoreOptions_1)
//        
//        let imageMoreOptions_2 = UIImageView()
//        imageMoreOptions_2.image = UIImage(named: "pinSelectLocation02")
//        uiviewMoreOptions.addSubview(imageMoreOptions_2)
//        uiviewMoreOptions.addConstraintsWithFormat("H:[v0(10.5)]-0-|", options: [], views: imageMoreOptions_2)
//        uiviewMoreOptions.addConstraintsWithFormat("V:|-7-[v0(19)]", options: [], views: imageMoreOptions_2)
//        
//        let labelMoreOptionsContent = UILabel()
//        labelMoreOptionsContent.text = "More Options"
//        labelMoreOptionsContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        labelMoreOptionsContent.textAlignment = .left
//        labelMoreOptionsContent.textColor = UIColor.white
//        uiviewMoreOptions.addSubview(labelMoreOptionsContent)
//        uiviewMoreOptions.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelMoreOptionsContent)
//        uiviewMoreOptions.addConstraintsWithFormat("V:|-2-[v0(25)]", options: [], views: labelMoreOptionsContent)
//        
//        let buttonMoreOptions = UIButton()
//        uiviewMoreOptions.addSubview(buttonMoreOptions)
//        buttonMoreOptions.addTarget(self, action: #selector(CreateCommentPinViewController.actionShowOrHideMoreOptions(_:)), for: .touchUpInside)
//        buttonMoreOptions.tag = 1
//        uiviewMoreOptions.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonMoreOptions)
//        uiviewMoreOptions.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonMoreOptions)
//    }

//    fileprivate func loadMoreOptionsItems() {
        // Title Label
//        labelCommentPinMoreOptions = UILabel(frame: CGRect(x: 109, y: 146, width: 196, height: 27))
//        labelCommentPinMoreOptions.text = "More Options"
//        labelCommentPinMoreOptions.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
//        labelCommentPinMoreOptions.textAlignment = .center
//        labelCommentPinMoreOptions.textColor = UIColor.white
//        self.view.addSubview(labelCommentPinMoreOptions)
//        labelCommentPinMoreOptions.alpha = 0.0
//        
//        // Duration Select
//        uiviewDuration = UIView()
//        self.view.addSubview(uiviewDuration)
//        self.view.addConstraintsWithFormat("H:[v0(295)]", options: [], views: uiviewDuration)
//        self.view.addConstraintsWithFormat("V:|-197-[v0(29)]", options: [], views: uiviewDuration)
//        NSLayoutConstraint(item: uiviewDuration, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        uiviewDuration.alpha = 0.0
//        
//        let imageDuration_1 = UIImageView()
//        imageDuration_1.image = UIImage(named: "durationIcon")
//        uiviewDuration.addSubview(imageDuration_1)
//        uiviewDuration.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imageDuration_1)
//        uiviewDuration.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageDuration_1)
//        
//        let labelDuration_2 = UILabel()
//        labelDuration_2.text = "3HR"
//        labelDuration_2.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
//        labelDuration_2.textAlignment = .right
//        labelDuration_2.textColor = UIColor.white
//        uiviewDuration.addSubview(labelDuration_2)
//        uiviewDuration.addConstraintsWithFormat("H:[v0(72)]-0-|", options: [], views: labelDuration_2)
//        uiviewDuration.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelDuration_2)
//        
//        let labelDurationContent = UILabel()
//        labelDurationContent.text = "Duration on Map"
//        labelDurationContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        labelDurationContent.textAlignment = .left
//        labelDurationContent.textColor = UIColor.white
//        uiviewDuration.addSubview(labelDurationContent)
//        uiviewDuration.addConstraintsWithFormat("H:|-44-[v0(209)]", options: [], views: labelDurationContent)
//        uiviewDuration.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelDurationContent)
//        
//        let buttonDuration = UIButton()
//        uiviewDuration.addSubview(buttonDuration)
//        uiviewDuration.addConstraintsWithFormat("H:[v0(295)]-0-|", options: [], views: buttonDuration)
//        uiviewDuration.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonDuration)
//        
//        // Interaction Radius change
//        uiviewInterRadius = UIView()
//        self.view.addSubview(uiviewInterRadius)
//        self.view.addConstraintsWithFormat("H:[v0(295)]", options: [], views: uiviewInterRadius)
//        self.view.addConstraintsWithFormat("V:|-256-[v0(29)]", options: [], views: uiviewInterRadius)
//        NSLayoutConstraint(item: uiviewInterRadius, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        uiviewInterRadius.alpha = 0.0
//        
//        let imageInterRadius_1 = UIImageView()
//        imageInterRadius_1.image = UIImage(named: "radiusIcon")
//        uiviewInterRadius.addSubview(imageInterRadius_1)
//        uiviewInterRadius.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imageInterRadius_1)
//        uiviewInterRadius.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageInterRadius_1)
//        
//        let labelInterRadius_2 = UILabel()
//        labelInterRadius_2.text = "C.S"
//        labelInterRadius_2.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
//        labelInterRadius_2.textAlignment = .right
//        labelInterRadius_2.textColor = UIColor.white
//        uiviewInterRadius.addSubview(labelInterRadius_2)
//        uiviewInterRadius.addConstraintsWithFormat("H:[v0(72)]-0-|", options: [], views: labelInterRadius_2)
//        uiviewInterRadius.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelInterRadius_2)
//        
//        let labelInterRadiusContent = UILabel()
//        labelInterRadiusContent.text = "Interaction Radius"
//        labelInterRadiusContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        labelInterRadiusContent.textAlignment = .left
//        labelInterRadiusContent.textColor = UIColor.white
//        uiviewInterRadius.addSubview(labelInterRadiusContent)
//        uiviewInterRadius.addConstraintsWithFormat("H:|-44-[v0(209)]", options: [], views: labelInterRadiusContent)
//        uiviewInterRadius.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelInterRadiusContent)
//        
//        let buttonInterRaidus = UIButton()
//        uiviewInterRadius.addSubview(buttonInterRaidus)
//        uiviewInterRadius.addConstraintsWithFormat("H:[v0(295)]-0-|", options: [], views: buttonInterRaidus)
//        uiviewInterRadius.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonInterRaidus)
//        
//        // Pin Promotions
//        uiviewPinPromot = UIView()
//        self.view.addSubview(uiviewPinPromot)
//        self.view.addConstraintsWithFormat("H:[v0(295)]", options: [], views: uiviewPinPromot)
//        self.view.addConstraintsWithFormat("V:|-315-[v0(29)]", options: [], views: uiviewPinPromot)
//        NSLayoutConstraint(item: uiviewPinPromot, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        uiviewPinPromot.alpha = 0.0
//        
//        let imagePinPromot_1 = UIImageView()
//        imagePinPromot_1.image = UIImage(named: "promotionIcon")
//        uiviewPinPromot.addSubview(imagePinPromot_1)
//        uiviewPinPromot.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imagePinPromot_1)
//        uiviewPinPromot.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imagePinPromot_1)
//        
//        let labelPinPromot_2 = UILabel()
//        labelPinPromot_2.text = "C.S"
//        labelPinPromot_2.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
//        labelPinPromot_2.textAlignment = .right
//        labelPinPromot_2.textColor = UIColor.white
//        uiviewPinPromot.addSubview(labelPinPromot_2)
//        uiviewPinPromot.addConstraintsWithFormat("H:[v0(72)]-0-|", options: [], views: labelPinPromot_2)
//        uiviewPinPromot.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelPinPromot_2)
//        
//        let labelPinPromotContent = UILabel()
//        labelPinPromotContent.text = "Interaction Radius"
//        labelPinPromotContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        labelPinPromotContent.textAlignment = .left
//        labelPinPromotContent.textColor = UIColor.white
//        uiviewPinPromot.addSubview(labelPinPromotContent)
//        uiviewPinPromot.addConstraintsWithFormat("H:|-44-[v0(209)]", options: [], views: labelPinPromotContent)
//        uiviewPinPromot.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelPinPromotContent)
//        
//        let buttonPinPromot = UIButton()
//        uiviewPinPromot.addSubview(buttonPinPromot)
//        uiviewPinPromot.addConstraintsWithFormat("H:[v0(295)]-0-|", options: [], views: buttonPinPromot)
//        uiviewPinPromot.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonPinPromot)
        
        // Button Back
//        buttonBack = UIButton()
//        buttonBack.setTitle("Back", for: .normal)
//        buttonBack.setTitleColor(UIColor.white, for: .normal)
//        buttonBack.setTitleColor(UIColor.lightGray, for: .highlighted)
//        buttonBack.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
//        buttonBack.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
//        self.view.addSubview(buttonBack)
//        buttonBack.addTarget(self, action: #selector(CreateCommentPinViewController.actionShowOrHideMoreOptions(_:)), for: .touchUpInside)
//        buttonBack.tag = 0
//        buttonBack.alpha = 0.0
//        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonBack)
//        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonBack)
//    }
//}
