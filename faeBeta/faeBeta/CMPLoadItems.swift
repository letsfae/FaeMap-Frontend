//
//  CMPLoadItems.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreateMomentPinViewController {
    func loadCreateMediaPinView() {
        uiviewCreateMediaPin = UIView(frame: self.view.bounds)
        uiviewCreateMediaPin.alpha = 0.0
        self.view.addSubview(uiviewCreateMediaPin)
        
        let layout = CenterCellCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 49
        
        collectionViewMedia = UICollectionView(frame: CGRect(x: 0, y: 200, width: screenWidth, height: 200), collectionViewLayout: layout)
        collectionViewMedia.register(CMPCollectionViewCell.self, forCellWithReuseIdentifier: "selectedMedia")
        collectionViewMedia.delegate = self
        collectionViewMedia.dataSource = self
        collectionViewMedia.isPagingEnabled = false
        collectionViewMedia.isHidden = true
        collectionViewMedia.backgroundColor = UIColor.clear
        collectionViewMedia.showsHorizontalScrollIndicator = false
        uiviewCreateMediaPin.addSubview(collectionViewMedia)
        
        buttonTakeMedia = UIButton(frame: CGRect(x: 109, y: 268, width: 65, height: 65))
        buttonTakeMedia.setImage(UIImage(named: "momentPinTakeMoment"), for: UIControlState())
        uiviewCreateMediaPin.addSubview(buttonTakeMedia)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:|-109-[v0(65)]", options: [], views: buttonTakeMedia)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-268-[v0(65)]", options: [], views: buttonTakeMedia)
        buttonTakeMedia.addTarget(self, action: #selector(self.actionTakeMedia(_:)), for: .touchUpInside)
        
        buttonSelectMedia = UIButton(frame: CGRect(x: 241, y: 268, width: 65, height: 65))
        buttonSelectMedia.setImage(UIImage(named: "momentPinSelectMoment"), for: UIControlState())
        buttonSelectMedia.tag = 1
        uiviewCreateMediaPin.addSubview(buttonSelectMedia)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(65)]-109-|", options: [], views: buttonSelectMedia)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-268-[v0(65)]", options: [], views: buttonSelectMedia)
        buttonSelectMedia.addTarget(self, action: #selector(self.actionTakeMedia(_:)), for: .touchUpInside)
        
        textViewForMediaPin = UITextView(frame: CGRect(x: 60, y: 198, width: 294, height: 27))
        textViewForMediaPin.font = UIFont(name: "AvenirNext-Regular", size: 20)
        textViewForMediaPin.textColor = UIColor.white
        textViewForMediaPin.backgroundColor = UIColor.clear
        textViewForMediaPin.tintColor = UIColor.white
        textViewForMediaPin.delegate = self
        textViewForMediaPin.isScrollEnabled = false
        textViewForMediaPin.alpha = 0
        uiviewCreateMediaPin.addSubview(textViewForMediaPin)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(294)]", options: [], views: textViewForMediaPin)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-198-[v0(44)]", options: [], views: textViewForMediaPin)
        NSLayoutConstraint(item: textViewForMediaPin, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 5, y: 8, width: 171, height: 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lableTextViewPlaceholder.textColor = colorPlaceHolder
        lableTextViewPlaceholder.text = "Add Description..."
        textViewForMediaPin.addSubview(lableTextViewPlaceholder)
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
        uiviewCreateMediaPin.addGestureRecognizer(tapToDismissKeyboard)
        
        let imageCreateMediaPin = UIImageView(frame: CGRect(x: 166, y: 36, width: 84, height: 91))
        imageCreateMediaPin.image = UIImage(named: "momentPinTitleImage")
        uiviewCreateMediaPin.addSubview(imageCreateMediaPin)
        
        labelCreateMediaPinTitle = UILabel(frame: CGRect(x: 109, y: 146, width: 196, height: 27))
        labelCreateMediaPinTitle.text = "Create Moment Pin"
        labelCreateMediaPinTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelCreateMediaPinTitle.textAlignment = .center
        labelCreateMediaPinTitle.textColor = UIColor.white
        uiviewCreateMediaPin.addSubview(labelCreateMediaPinTitle)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-36-[v0(91)]-19-[v1(27)]", options: [], views: imageCreateMediaPin, labelCreateMediaPinTitle)
        NSLayoutConstraint(item: imageCreateMediaPin, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: labelCreateMediaPinTitle, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        let buttonBackToPinSelection = UIButton()
        buttonBackToPinSelection.setImage(UIImage(named: "backToPinMenu"), for: UIControlState())
        uiviewCreateMediaPin.addSubview(buttonBackToPinSelection)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: buttonBackToPinSelection)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonBackToPinSelection)
        buttonBackToPinSelection.addTarget(self, action: #selector(CreateMomentPinViewController.actionBackToPinSelections(_:)), for: UIControlEvents.touchUpInside)
        
        let buttonCloseCreateMedia = UIButton()
        buttonCloseCreateMedia.setImage(UIImage(named: "closePinCreation"), for: UIControlState())
        uiviewCreateMediaPin.addSubview(buttonCloseCreateMedia)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: buttonCloseCreateMedia)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonCloseCreateMedia)
        buttonCloseCreateMedia.addTarget(self, action: #selector(CreateMomentPinViewController.actionCloseSubmitPins(_:)), for: .touchUpInside)
        
        uiviewSelectLocation = UIView()
        uiviewCreateMediaPin.addSubview(uiviewSelectLocation)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(293)]", options: [], views: uiviewSelectLocation)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:[v0(29)]-209-|", options: [], views: uiviewSelectLocation)
        NSLayoutConstraint(item: uiviewSelectLocation, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        let imageSelectLocation_1 = UIImageView()
        imageSelectLocation_1.image = UIImage(named: "pinSelectLocation01")
        uiviewSelectLocation.addSubview(imageSelectLocation_1)
        uiviewSelectLocation.addConstraintsWithFormat("H:|-2-[v0(25)]", options: [], views: imageSelectLocation_1)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageSelectLocation_1)
        
        let imageSelectLocation_2 = UIImageView()
        imageSelectLocation_2.image = UIImage(named: "pinSelectLocation02")
        uiviewSelectLocation.addSubview(imageSelectLocation_2)
        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(10.5)]-0-|", options: [], views: imageSelectLocation_2)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-7-[v0(19)]", options: [], views: imageSelectLocation_2)
        
        labelSelectLocationContent = UILabel()
        labelSelectLocationContent.text = "Choose Location"
        labelSelectLocationContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelSelectLocationContent.textAlignment = .left
        labelSelectLocationContent.textColor = UIColor.white
        uiviewSelectLocation.addSubview(labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelSelectLocationContent)
        uiviewSelectLocation.addConstraintsWithFormat("V:|-4-[v0(25)]", options: [], views: labelSelectLocationContent)
        
        let buttonSelectLocation = UIButton()
        uiviewSelectLocation.addSubview(buttonSelectLocation)
        buttonSelectLocation.addTarget(self, action: #selector(CreateMomentPinViewController.actionSelectLocation(_:)), for: .touchUpInside)
        uiviewSelectLocation.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonSelectLocation)
        uiviewSelectLocation.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonSelectLocation)
        
        buttonMediaSubmit = UIButton()
        buttonMediaSubmit.setTitle("Submit!", for: UIControlState())
        buttonMediaSubmit.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
        buttonMediaSubmit.setTitleColor(UIColor.lightGray, for: .highlighted)
        buttonMediaSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonMediaSubmit.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 0.65)
        uiviewCreateMediaPin.addSubview(buttonMediaSubmit)
        buttonMediaSubmit.addTarget(self, action: #selector(CreateMomentPinViewController.actionSubmitMedia(_:)), for: .touchUpInside)
        buttonMediaSubmit.adjustsImageWhenDisabled = false
        buttonMediaSubmit.isEnabled = true
        buttonMediaSubmit.tag = 1
        self.view.addSubview(uiviewCreateMediaPin)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonMediaSubmit)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonMediaSubmit)
        
        loadAddDescriptionButton()
        loadMoreOptionsButton()
        loadAnonymousButton()
        loadAddMediaButton()
    }
    
    private func loadAddMediaButton() {
        buttonAddMedia = UIButton()
        buttonAddMedia.tag = 0
        buttonAddMedia.alpha = 0
        buttonAddMedia.setImage(#imageLiteral(resourceName: "momentAddMedia"), for: .normal)
        buttonAddMedia.addTarget(self, action: #selector(self.actionAddMedia(_:)), for: .touchUpInside)
        uiviewCreateMediaPin.addSubview(buttonAddMedia)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(88)]-0-|", options: [], views: buttonAddMedia)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-200-[v0(200)]", options: [], views: buttonAddMedia)
    }
    
    private func loadAnonymousButton() {
        buttonAnonymous = UIButton()
        buttonAnonymous.setImage(UIImage(named: "anonymousUnclicked"), for: .normal)
        buttonAnonymous.tag = 0
        buttonAnonymous.adjustsImageWhenHighlighted = false
        buttonAnonymous.addTarget(self, action: #selector(self.actionAnonymous(_:)), for: .touchUpInside)
        uiviewCreateMediaPin.addSubview(buttonAnonymous)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(134)]-14-|", options: [], views: buttonAnonymous)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:[v0(25)]-77-|", options: [], views: buttonAnonymous)
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
        buttonFinishEdit.setImage(UIImage(named: "finishEditing"), for: UIControlState())
        uiviewToolBar.addSubview(buttonFinishEdit)
        uiviewToolBar.addConstraintsWithFormat("H:[v0(49)]-14-|", options: [], views: buttonFinishEdit)
        uiviewToolBar.addConstraintsWithFormat("V:[v0(25)]-11-|", options: [], views: buttonFinishEdit)
        buttonFinishEdit.addTarget(self, action: #selector(CreateMomentPinViewController.actionFinishEditing(_:)), for: .touchUpInside)
        
        labelCountChars = UILabel(frame: CGRect(x: screenWidth-43, y: screenHeight, width: 29, height: 20))
        labelCountChars.text = "200"
        labelCountChars.font = UIFont(name: "AvenirNext-Medium", size: 16)
        labelCountChars.textAlignment = .right
        labelCountChars.textColor = UIColor.white
        self.view.addSubview(labelCountChars)
    }
    
    private func loadAddDescriptionButton() {
        uiviewAddDescription = UIView()
        uiviewCreateMediaPin.addSubview(uiviewAddDescription)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(293)]", options: [], views: uiviewAddDescription)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:[v0(29)]-277-|", options: [], views: uiviewAddDescription)
        NSLayoutConstraint(item: uiviewAddDescription, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        let imageAddDes_1 = UIImageView()
        imageAddDes_1.image = UIImage(named: "addDescription")
        uiviewAddDescription.addSubview(imageAddDes_1)
        uiviewAddDescription.addConstraintsWithFormat("H:|-1-[v0(27)]", options: [], views: imageAddDes_1)
        uiviewAddDescription.addConstraintsWithFormat("V:|-2-[v0(25)]", options: [], views: imageAddDes_1)
        
        let imageAddDes_2 = UIImageView()
        imageAddDes_2.image = UIImage(named: "plusIcon")
        uiviewAddDescription.addSubview(imageAddDes_2)
        uiviewAddDescription.addConstraintsWithFormat("H:[v0(16)]-0-|", options: [], views: imageAddDes_2)
        uiviewAddDescription.addConstraintsWithFormat("V:|-7-[v0(16)]", options: [], views: imageAddDes_2)
        
        let labelAddDesContent = UILabel()
        labelAddDesContent.text = "Add Description"
        labelAddDesContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelAddDesContent.textAlignment = .left
        labelAddDesContent.textColor = UIColor.white
        uiviewAddDescription.addSubview(labelAddDesContent)
        uiviewAddDescription.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelAddDesContent)
        uiviewAddDescription.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelAddDesContent)
        
        let buttonAddDes = UIButton()
        uiviewAddDescription.addSubview(buttonAddDes)
        buttonAddDes.addTarget(self, action: #selector(CreateMomentPinViewController.actionShowAddDes(_:)), for: .touchUpInside)
        buttonAddDes.tag = 1
        uiviewAddDescription.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonAddDes)
        uiviewAddDescription.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonAddDes)
        
        loadAddDescriptionItems()
    }
    
    private func loadAddDescriptionItems() {
        // Title Label
        labelMediaPinAddDes = UILabel(frame: CGRect(x: 109, y: 146, width: 196, height: 27))
        labelMediaPinAddDes.text = "Add Description"
        labelMediaPinAddDes.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelMediaPinAddDes.textAlignment = .center
        labelMediaPinAddDes.textColor = UIColor.white
        uiviewCreateMediaPin.addSubview(labelMediaPinAddDes)
        labelMediaPinAddDes.alpha = 0.0
    }
    
    private func loadMoreOptionsButton() {
        uiviewMoreOptions = UIView()
        uiviewCreateMediaPin.addSubview(uiviewMoreOptions)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(294)]", options: [], views: uiviewMoreOptions)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:[v0(29)]-141-|", options: [], views: uiviewMoreOptions)
        NSLayoutConstraint(item: uiviewMoreOptions, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        let imageMoreOptions_1 = UIImageView()
        imageMoreOptions_1.image = UIImage(named: "optionsIcon")
        uiviewMoreOptions.addSubview(imageMoreOptions_1)
        uiviewMoreOptions.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imageMoreOptions_1)
        uiviewMoreOptions.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageMoreOptions_1)
        
        let imageMoreOptions_2 = UIImageView()
        imageMoreOptions_2.image = UIImage(named: "pinSelectLocation02")
        uiviewMoreOptions.addSubview(imageMoreOptions_2)
        uiviewMoreOptions.addConstraintsWithFormat("H:[v0(10.5)]-0-|", options: [], views: imageMoreOptions_2)
        uiviewMoreOptions.addConstraintsWithFormat("V:|-7-[v0(19)]", options: [], views: imageMoreOptions_2)
        
        let labelMoreOptionsContent = UILabel()
        labelMoreOptionsContent.text = "More Options"
        labelMoreOptionsContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelMoreOptionsContent.textAlignment = .left
        labelMoreOptionsContent.textColor = UIColor.white
        uiviewMoreOptions.addSubview(labelMoreOptionsContent)
        uiviewMoreOptions.addConstraintsWithFormat("H:|-42-[v0(209)]", options: [], views: labelMoreOptionsContent)
        uiviewMoreOptions.addConstraintsWithFormat("V:|-4-[v0(25)]", options: [], views: labelMoreOptionsContent)
        
        let buttonMoreOptions = UIButton()
        uiviewMoreOptions.addSubview(buttonMoreOptions)
        buttonMoreOptions.addTarget(self, action: #selector(CreateMomentPinViewController.actionShowMoreOptions(_:)), for: .touchUpInside)
        buttonMoreOptions.tag = 1
        uiviewMoreOptions.addConstraintsWithFormat("H:[v0(276)]-0-|", options: [], views: buttonMoreOptions)
        uiviewMoreOptions.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonMoreOptions)
        
        loadMoreOptionsItems()
    }
    
    private func loadMoreOptionsItems() {
        // Title Label
        labelMediaPinMoreOptions = UILabel(frame: CGRect(x: 109, y: 146, width: 196, height: 27))
        labelMediaPinMoreOptions.text = "More Options"
        labelMediaPinMoreOptions.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelMediaPinMoreOptions.textAlignment = .center
        labelMediaPinMoreOptions.textColor = UIColor.white
        uiviewCreateMediaPin.addSubview(labelMediaPinMoreOptions)
        labelMediaPinMoreOptions.alpha = 0.0
        
        // Duration Select
        uiviewDuration = UIView()
        uiviewCreateMediaPin.addSubview(uiviewDuration)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(295)]", options: [], views: uiviewDuration)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-197-[v0(29)]", options: [], views: uiviewDuration)
        NSLayoutConstraint(item: uiviewDuration, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        uiviewDuration.alpha = 0.0
        
        let imageDuration_1 = UIImageView()
        imageDuration_1.image = UIImage(named: "durationIcon")
        uiviewDuration.addSubview(imageDuration_1)
        uiviewDuration.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imageDuration_1)
        uiviewDuration.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageDuration_1)
        
        let labelDuration_2 = UILabel()
        labelDuration_2.text = "3HR"
        labelDuration_2.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        labelDuration_2.textAlignment = .right
        labelDuration_2.textColor = UIColor.white
        uiviewDuration.addSubview(labelDuration_2)
        uiviewDuration.addConstraintsWithFormat("H:[v0(72)]-0-|", options: [], views: labelDuration_2)
        uiviewDuration.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelDuration_2)
        
        let labelDurationContent = UILabel()
        labelDurationContent.text = "Duration on Map"
        labelDurationContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelDurationContent.textAlignment = .left
        labelDurationContent.textColor = UIColor.white
        uiviewDuration.addSubview(labelDurationContent)
        uiviewDuration.addConstraintsWithFormat("H:|-44-[v0(209)]", options: [], views: labelDurationContent)
        uiviewDuration.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelDurationContent)
        
        let buttonDuration = UIButton()
        uiviewDuration.addSubview(buttonDuration)
        uiviewDuration.addConstraintsWithFormat("H:[v0(295)]-0-|", options: [], views: buttonDuration)
        uiviewDuration.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonDuration)
        
        // Interaction Radius change
        uiviewInterRadius = UIView()
        uiviewCreateMediaPin.addSubview(uiviewInterRadius)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(295)]", options: [], views: uiviewInterRadius)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-256-[v0(29)]", options: [], views: uiviewInterRadius)
        NSLayoutConstraint(item: uiviewInterRadius, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        uiviewInterRadius.alpha = 0.0
        
        let imageInterRadius_1 = UIImageView()
        imageInterRadius_1.image = UIImage(named: "radiusIcon")
        uiviewInterRadius.addSubview(imageInterRadius_1)
        uiviewInterRadius.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imageInterRadius_1)
        uiviewInterRadius.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imageInterRadius_1)
        
        let labelInterRadius_2 = UILabel()
        labelInterRadius_2.text = "C.S"
        labelInterRadius_2.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        labelInterRadius_2.textAlignment = .right
        labelInterRadius_2.textColor = UIColor.white
        uiviewInterRadius.addSubview(labelInterRadius_2)
        uiviewInterRadius.addConstraintsWithFormat("H:[v0(72)]-0-|", options: [], views: labelInterRadius_2)
        uiviewInterRadius.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelInterRadius_2)
        
        let labelInterRadiusContent = UILabel()
        labelInterRadiusContent.text = "Interaction Radius"
        labelInterRadiusContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelInterRadiusContent.textAlignment = .left
        labelInterRadiusContent.textColor = UIColor.white
        uiviewInterRadius.addSubview(labelInterRadiusContent)
        uiviewInterRadius.addConstraintsWithFormat("H:|-44-[v0(209)]", options: [], views: labelInterRadiusContent)
        uiviewInterRadius.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelInterRadiusContent)
        
        let buttonInterRaidus = UIButton()
        uiviewInterRadius.addSubview(buttonInterRaidus)
        uiviewInterRadius.addConstraintsWithFormat("H:[v0(295)]-0-|", options: [], views: buttonInterRaidus)
        uiviewInterRadius.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonInterRaidus)
        
        // Pin Promotions
        uiviewPinPromot = UIView()
        uiviewCreateMediaPin.addSubview(uiviewPinPromot)
        uiviewCreateMediaPin.addConstraintsWithFormat("H:[v0(295)]", options: [], views: uiviewPinPromot)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:|-315-[v0(29)]", options: [], views: uiviewPinPromot)
        NSLayoutConstraint(item: uiviewPinPromot, attribute: .centerX, relatedBy: .equal, toItem: uiviewCreateMediaPin, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        uiviewPinPromot.alpha = 0.0
        
        let imagePinPromot_1 = UIImageView()
        imagePinPromot_1.image = UIImage(named: "promotionIcon")
        uiviewPinPromot.addSubview(imagePinPromot_1)
        uiviewPinPromot.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imagePinPromot_1)
        uiviewPinPromot.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: imagePinPromot_1)
        
        let labelPinPromot_2 = UILabel()
        labelPinPromot_2.text = "C.S"
        labelPinPromot_2.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        labelPinPromot_2.textAlignment = .right
        labelPinPromot_2.textColor = UIColor.white
        uiviewPinPromot.addSubview(labelPinPromot_2)
        uiviewPinPromot.addConstraintsWithFormat("H:[v0(72)]-0-|", options: [], views: labelPinPromot_2)
        uiviewPinPromot.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelPinPromot_2)
        
        let labelPinPromotContent = UILabel()
        labelPinPromotContent.text = "Interaction Radius"
        labelPinPromotContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelPinPromotContent.textAlignment = .left
        labelPinPromotContent.textColor = UIColor.white
        uiviewPinPromot.addSubview(labelPinPromotContent)
        uiviewPinPromot.addConstraintsWithFormat("H:|-44-[v0(209)]", options: [], views: labelPinPromotContent)
        uiviewPinPromot.addConstraintsWithFormat("V:|-3-[v0(25)]", options: [], views: labelPinPromotContent)
        
        let buttonPinPromot = UIButton()
        uiviewPinPromot.addSubview(buttonPinPromot)
        uiviewPinPromot.addConstraintsWithFormat("H:[v0(295)]-0-|", options: [], views: buttonPinPromot)
        uiviewPinPromot.addConstraintsWithFormat("V:[v0(29)]-0-|", options: [], views: buttonPinPromot)
        
        // Button Back
        buttonBack = UIButton()
        buttonBack.setTitle("Back", for: UIControlState())
        buttonBack.setTitleColor(UIColor.white, for: UIControlState())
        buttonBack.setTitleColor(UIColor.lightGray, for: .highlighted)
        buttonBack.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonBack.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1.0)
        uiviewCreateMediaPin.addSubview(buttonBack)
        buttonBack.addTarget(self, action: #selector(CreateMomentPinViewController.actionBack(_:)), for: .touchUpInside)
        buttonBack.tag = 0
        buttonBack.alpha = 0.0
        uiviewCreateMediaPin.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonBack)
        uiviewCreateMediaPin.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonBack)
    }
}
