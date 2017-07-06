//
//  CMPLoadItems.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

//import UIKit
//
//extension CreateMomentPinViewController {

//        textviewDescrip = CreatePinTextView(frame: CGRect(x: (screenWidth - 294) / 2, y: 195, width: 294, height: 35))
//        textviewDescrip.placeHolder = "Add Description..."
//        textviewDescrip.observerDelegate = self
//        textviewDescrip.alpha = 0
//        self.view.addSubview(textviewDescrip)
//        self.view.addConstraintsWithFormat("H:[v0(294)]", options: [], views: textViewForMediaPin)
//        self.view.addConstraintsWithFormat("V:|-198-[v0(44)]", options: [], views: textViewForMediaPin)
        
//        NSLayoutConstraint(item: textViewForMediaPin, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        
//        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 5, y: 8, width: 171, height: 27))
//        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
//        lableTextViewPlaceholder.textColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
//        textViewForMediaPin.addSubview(lableTextViewPlaceholder)
        
//        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
//        self.view.addGestureRecognizer(tapToDismissKeyboard)
        
//        let imageCreateMediaPin = UIImageView(frame: CGRect(x: 166, y: 36, width: 84, height: 91))
//        imageCreateMediaPin.image = UIImage(named: "momentPinTitleImage")
//        self.view.addSubview(imageCreateMediaPin)
        
//        labelCreateMediaPinTitle = UILabel(frame: CGRect(x: 109, y: 146, width: 196, height: 27))
//        labelCreateMediaPinTitle.text = "Create Story Pin"
//        labelCreateMediaPinTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
//        labelCreateMediaPinTitle.textAlignment = .center
//        labelCreateMediaPinTitle.textColor = UIColor.white
//        self.view.addSubview(labelCreateMediaPinTitle)
//        self.view.addConstraintsWithFormat("V:|-36-[v0(91)]-19-[v1(27)]", options: [], views: imageCreateMediaPin, labelCreateMediaPinTitle)
//        NSLayoutConstraint(item: imageCreateMediaPin, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        NSLayoutConstraint(item: labelCreateMediaPinTitle, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
//        let buttonBackToPinSelection = UIButton()
//        buttonBackToPinSelection.setImage(UIImage(named: "backToPinMenu"), for: UIControlState())
//        self.view.addSubview(buttonBackToPinSelection)
//        self.view.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: buttonBackToPinSelection)
//        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonBackToPinSelection)
//        buttonBackToPinSelection.addTarget(self, action: #selector(CreateMomentPinViewController.actionBackToPinSelections(_:)), for: UIControlEvents.touchUpInside)
//        
//        let buttonCloseCreateMedia = UIButton()
//        buttonCloseCreateMedia.setImage(UIImage(named: "closePinCreation"), for: UIControlState())
//        self.view.addSubview(buttonCloseCreateMedia)
//        self.view.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: buttonCloseCreateMedia)
//        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonCloseCreateMedia)
//        buttonCloseCreateMedia.addTarget(self, action: #selector(CreateMomentPinViewController.actionCloseSubmitPins(_:)), for: .touchUpInside)
        
//        uiviewSelectLocation = UIView()
//        self.view.addSubview(uiviewSelectLocation)
//        self.view.addConstraintsWithFormat("H:[v0(293)]", options: [], views: uiviewSelectLocation)
//        self.view.addConstraintsWithFormat("V:[v0(29)]-209-|", options: [], views: uiviewSelectLocation)
//        NSLayoutConstraint(item: uiviewSelectLocation, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        
//        let imageSelectLocation_1 = UIImageView()
//        imageSelectLocation_1.image = UIImage(named: "pinSelectLocation01")
//        uiviewSelectLocation.addSubview(imageSelectLocation_1)
//        uiviewSelectLocation.addConstraintsWithFormat("H:|-2-[v0(25)]", options: [], views: imageSelectLocation_1)
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
//        buttonSelectLocation.addTarget(self, action: #selector(self.actionSelectLocation(_:)), for: .touchUpInside)
//        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonSelectLocation)
//        uiviewSelectLocation.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonSelectLocation)
        
//        buttonMediaSubmit = UIButton()
//        buttonMediaSubmit.setTitle("Submit!", for: UIControlState())
//        buttonMediaSubmit.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
//        buttonMediaSubmit.setTitleColor(UIColor.lightGray, for: .highlighted)
//        buttonMediaSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
//        buttonMediaSubmit.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 0.65)
//        self.view.addSubview(buttonMediaSubmit)
//        buttonMediaSubmit.addTarget(self, action: #selector(self.actionSubmitMedia(_:)), for: .touchUpInside)
//        buttonMediaSubmit.adjustsImageWhenDisabled = false
//        buttonMediaSubmit.isEnabled = false
//        buttonMediaSubmit.tag = 1
//        self.view.addSubview(self.view)
//        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonMediaSubmit)
//        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonMediaSubmit)
//        
//        loadAddDescriptionButton()
//        loadMoreOptionsButton()
//        loadAnonymous()
//        loadKeyboardToolBar()
//        loadEmojiView()
//    }
    
//    fileprivate func loadAnonymous() {
//        switchAnony = UISwitch(frame: CGRect(x: 0, y: 0, width: 39, height: 23))
//        switchAnony.onTintColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1)
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
//        buttonAnonymous.tag = 0
//        buttonAnonymous.adjustsImageWhenHighlighted = false
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
//        inputToolbar.mode = .emoji
//        self.view.layoutIfNeeded()
//    }
    
//    fileprivate func loadEmojiView(){
//        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
//        emojiView.sendStickerDelegate = self
//        self.view.addSubview(emojiView)
//    }
    
//    fileprivate func loadAddDescriptionButton() {
//        uiviewAddDescription = UIView()
//        self.view.addSubview(uiviewAddDescription)
//        self.view.addConstraintsWithFormat("H:[v0(293)]", options: [], views: uiviewAddDescription)
//        self.view.addConstraintsWithFormat("V:[v0(29)]-277-|", options: [], views: uiviewAddDescription)
//        NSLayoutConstraint(item: uiviewAddDescription, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
//        
//        let imageAddDes_1 = UIImageView()
//        imageAddDes_1.image = UIImage(named: "addDescription")
//        uiviewAddDescription.addSubview(imageAddDes_1)
//        uiviewAddDescription.addConstraintsWithFormat("H:|-1-[v0(27)]", options: [], views: imageAddDes_1)
//        uiviewAddDescription.addConstraintsWithFormat("V:|-2-[v0(25)]", options: [], views: imageAddDes_1)
//        
//        let imageAddDes_2 = UIImageView()
//        imageAddDes_2.image = UIImage(named: "plusIcon")
//        uiviewAddDescription.addSubview(imageAddDes_2)
//        uiviewAddDescription.addConstraintsWithFormat("H:[v0(16)]-0-|", options: [], views: imageAddDes_2)
//        uiviewAddDescription.addConstraintsWithFormat("V:|-7-[v0(16)]", options: [], views: imageAddDes_2)
//        
//        labelAddDesContent = UILabel()
//        labelAddDesContent.text = "Add Description"
//        labelAddDesContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        labelAddDesContent.textAlignment = .left
//        labelAddDesContent.textColor = UIColor.white
//        uiviewAddDescription.addSubview(labelAddDesContent)
//        uiviewAddDescription.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelAddDesContent)
//        uiviewAddDescription.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelAddDesContent)
//        
//        let buttonAddDes = UIButton()
//        uiviewAddDescription.addSubview(buttonAddDes)
//        buttonAddDes.addTarget(self, action: #selector(self.actionShowAddDes(_:)), for: .touchUpInside)
//        buttonAddDes.tag = 1
//        uiviewAddDescription.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonAddDes)
//        uiviewAddDescription.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonAddDes)
//        
//        loadAddDescriptionItems()
//    }
//    
//    fileprivate func loadAddDescriptionItems() {
//        // Title Label
//        labelMediaPinAddDes = UILabel(frame: CGRect(x: (screenWidth - 196) / 2, y: 146, width: 196, height: 27))
//        labelMediaPinAddDes.text = "Add Description"
//        labelMediaPinAddDes.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
//        labelMediaPinAddDes.textAlignment = .center
//        labelMediaPinAddDes.textColor = .white
//        self.view.addSubview(labelMediaPinAddDes)
//        labelMediaPinAddDes.alpha = 0.0
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
//        labelMoreOptionsContent.textColor = .white
//        uiviewMoreOptions.addSubview(labelMoreOptionsContent)
//        uiviewMoreOptions.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelMoreOptionsContent)
//        uiviewMoreOptions.addConstraintsWithFormat("V:|-4-[v0(25)]", options: [], views: labelMoreOptionsContent)
//        
//        let buttonMoreOptions = UIButton()
//        uiviewMoreOptions.addSubview(buttonMoreOptions)
//        buttonMoreOptions.addTarget(self, action: #selector(self.actionShowOrHideMoreOptions(_:)), for: .touchUpInside)
//        buttonMoreOptions.tag = 1
//        uiviewMoreOptions.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonMoreOptions)
//        uiviewMoreOptions.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonMoreOptions)
//        
//        loadMoreOptionsItems()
//    }
    
//    fileprivate func loadMoreOptionsItems() {
        // Title Label
//        labelMediaPinMoreOptions = UILabel(frame: CGRect(x: (screenWidth - 196) / 2, y: 146, width: 196, height: 27))
//        labelMediaPinMoreOptions.text = "More Options"
//        labelMediaPinMoreOptions.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
//        labelMediaPinMoreOptions.textAlignment = .center
//        labelMediaPinMoreOptions.textColor = .white
//        self.view.addSubview(labelMediaPinMoreOptions)
//        labelMediaPinMoreOptions.alpha = 0.0
        
        //More Option Table View
//        tableMoreOptions = CreatePinOptionsTableView(frame: CGRect(x: 0, y: 195, width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 5))
//        self.view.addSubview(tableMoreOptions)
//        tableMoreOptions.delegate = self
//        tableMoreOptions.dataSource = self
//        tableMoreOptions.alpha = 0
//        
//        // Button Back
//        buttonBack = UIButton()
//        buttonBack.setTitle("Back", for: UIControlState())
//        buttonBack.setTitleColor(UIColor.white, for: UIControlState())
//        buttonBack.setTitleColor(UIColor.lightGray, for: .highlighted)
//        buttonBack.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
//        buttonBack.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1.0)
//        self.view.addSubview(buttonBack)
//        buttonBack.addTarget(self, action: #selector(CreateMomentPinViewController.actionShowOrHideMoreOptions(_:)), for: .touchUpInside)
//        buttonBack.tag = 0
//        buttonBack.alpha = 0.0
//        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonBack)
//        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonBack)
//    }
//}
