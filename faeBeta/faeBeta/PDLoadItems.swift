//
//  PDLoadItems.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension PinDetailViewController {
    
    // Load pin detail window
    func loadPinDetailWindow() {
        loadNavigationBar()
        loadingOtherParts()
        loadTableHeader()
        loadPinCtrlButton()
        loadAnotherToolbar()
        loadInputToolBar()
        if pinTypeEnum != .place {
            loadFeelingBar()
        }
        tableCommentsForPin.tableHeaderView = uiviewPinDetail
    }
    
    fileprivate func loadFeelingBar() {
        uiviewFeelingBar = UIView()
        self.view.addSubview(uiviewFeelingBar)
        view.addConstraintsWithFormat("H:|-67-[v0(281)]", options: [], views: uiviewFeelingBar)
        view.addConstraintsWithFormat("V:|-(\(409 * screenHeightFactor))-[v0(52)]", options: [], views: uiviewFeelingBar)
        uiviewFeelingBar.layer.cornerRadius = 26
        uiviewFeelingBar.backgroundColor = UIColor.white
        uiviewFeelingBar.alpha = 0
        
        btnFeelingBar_01 = UIButton(frame: CGRect(x: 20, y: 11, width: 32, height: 32))
        uiviewFeelingBar.addSubview(btnFeelingBar_01)
        btnFeelingBar_01.setImage(#imageLiteral(resourceName: "pdFeeling_01"), for: .normal)
        btnFeelingBar_01.adjustsImageWhenHighlighted = false
        btnFeelingBar_01.tag = 0
        btnFeelingBar_01.addTarget(self, action: #selector(self.postFeeling(_:)), for: .touchUpInside)
        
        btnFeelingBar_02 = UIButton(frame: CGRect(x: 72, y: 11, width: 32, height: 32))
        uiviewFeelingBar.addSubview(btnFeelingBar_02)
        btnFeelingBar_02.setImage(#imageLiteral(resourceName: "pdFeeling_02"), for: .normal)
        btnFeelingBar_02.adjustsImageWhenHighlighted = false
        btnFeelingBar_02.tag = 1
        btnFeelingBar_02.addTarget(self, action: #selector(self.postFeeling(_:)), for: .touchUpInside)
        
        btnFeelingBar_03 = UIButton(frame: CGRect(x: 124, y: 11, width: 32, height: 32))
        uiviewFeelingBar.addSubview(btnFeelingBar_03)
        btnFeelingBar_03.setImage(#imageLiteral(resourceName: "pdFeeling_03"), for: .normal)
        btnFeelingBar_03.adjustsImageWhenHighlighted = false
        btnFeelingBar_03.tag = 2
        btnFeelingBar_03.addTarget(self, action: #selector(self.postFeeling(_:)), for: .touchUpInside)
        
        btnFeelingBar_04 = UIButton(frame: CGRect(x: 176, y: 11, width: 32, height: 32))
        uiviewFeelingBar.addSubview(btnFeelingBar_04)
        btnFeelingBar_04.setImage(#imageLiteral(resourceName: "pdFeeling_04"), for: .normal)
        btnFeelingBar_04.adjustsImageWhenHighlighted = false
        btnFeelingBar_04.tag = 3
        btnFeelingBar_04.addTarget(self, action: #selector(self.postFeeling(_:)), for: .touchUpInside)
        
        btnFeelingBar_05 = UIButton(frame: CGRect(x: 228, y: 11, width: 32, height: 32))
        uiviewFeelingBar.addSubview(btnFeelingBar_05)
        btnFeelingBar_05.setImage(#imageLiteral(resourceName: "pdFeeling_05"), for: .normal)
        btnFeelingBar_05.adjustsImageWhenHighlighted = false
        btnFeelingBar_05.tag = 4
        btnFeelingBar_05.addTarget(self, action: #selector(self.postFeeling(_:)), for: .touchUpInside)
    }
    
    fileprivate func loadInputToolBar() {
        uiviewToolBar = UIView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 51))
        uiviewToolBar.backgroundColor = UIColor.white
        uiviewToolBar.layer.zPosition = 200
        
        let line_0 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line_0.layer.borderWidth = 1
        line_0.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        uiviewToolBar.addSubview(line_0)
        
        textViewInput = UITextView(frame: CGRect(x: 28, y: 14.5, width: screenWidth-142, height: 25))
        textViewInput.delegate = self
        textViewInput.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textViewInput.textColor = UIColor.faeAppInputTextGrayColor()
        textViewInput.tintColor = UIColor.faeAppRedColor()
        textViewInput.textContainerInset = .zero
        textViewInput.showsVerticalScrollIndicator = false
        textViewInput.autocorrectionType = .no
        textViewInput.autocapitalizationType = .none
        uiviewToolBar.addSubview(textViewInput)
        
        lblTxtPlaceholder = UILabel()
        lblTxtPlaceholder.text = "Write a Comment..."
        lblTxtPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblTxtPlaceholder.textColor = UIColor(r: 146, g: 146, b: 146, alpha: 1.0)
        uiviewToolBar.addSubview(lblTxtPlaceholder)
        uiviewToolBar.addConstraintsWithFormat("H:|-33-[v0]-68-|", options: [], views: lblTxtPlaceholder)
        uiviewToolBar.addConstraintsWithFormat("V:|-14-[v0(25)]", options: [], views: lblTxtPlaceholder)
        
        buttonSticker = UIButton()
        buttonSticker.tag = 0
        buttonSticker.isHidden = false
        buttonSticker.setImage(#imageLiteral(resourceName: "sticker"), for: .normal)
        uiviewToolBar.addSubview(buttonSticker)
        uiviewToolBar.addConstraintsWithFormat("H:[v0(29)]-59-|", options: [], views: buttonSticker)
        uiviewToolBar.addConstraintsWithFormat("V:[v0(47)]-0-|", options: [], views: buttonSticker)
        buttonSticker.addTarget(self, action: #selector(self.actionSwitchKeyboard(_:)), for: .touchUpInside)
        
        buttonSend = UIButton()
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
        uiviewToolBar.addSubview(buttonSend)
        uiviewToolBar.addConstraintsWithFormat("H:[v0(29)]-15-|", options: [], views: buttonSend)
        uiviewToolBar.addConstraintsWithFormat("V:[v0(47)]-0-|", options: [], views: buttonSend)
        buttonSend.addTarget(self, action: #selector(self.sendMessageButtonTapped), for: .touchUpInside)
        
        btnCommentOption = UIButton()
        btnCommentOption.setImage(#imageLiteral(resourceName: "pinCommentOptions"), for: .normal)
        uiviewToolBar.addSubview(btnCommentOption)
        uiviewToolBar.addConstraintsWithFormat("H:|-2-[v0(31)]", options: [], views: btnCommentOption)
        uiviewToolBar.addConstraintsWithFormat("V:[v0(25)]-11-|", options: [], views: btnCommentOption)
        btnCommentOption.addTarget(self, action: #selector(self.actionShowHideAnony(_:)), for: .touchUpInside)
        
        self.view.addSubview(uiviewToolBar)
        loadEmojiView()
        loadAnonymous()
    }
    
    fileprivate func loadAnonymous() {
        uiviewAnonymous = UIView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 51))
        uiviewAnonymous.backgroundColor = UIColor.white
        uiviewAnonymous.layer.zPosition = 200
        uiviewAnonymous.isHidden = true
        self.view.addSubview(uiviewAnonymous)
        
        let line_0 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line_0.layer.borderWidth = 1
        line_0.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        uiviewAnonymous.addSubview(line_0)
        
        btnHideAnony = UIButton()
        btnHideAnony.setImage(#imageLiteral(resourceName: "locationExtendCancel"), for: .normal)
        uiviewAnonymous.addSubview(btnHideAnony)
        uiviewAnonymous.addConstraintsWithFormat("H:|-0-[v0(47)]", options: [], views: btnHideAnony)
        uiviewAnonymous.addConstraintsWithFormat("V:[v0(45)]-0-|", options: [], views: btnHideAnony)
        btnHideAnony.addTarget(self, action: #selector(self.actionShowHideAnony(_:)), for: .touchUpInside)
        
        switchAnony = UISwitch(frame: CGRect(x: 0, y: 0, width: 39, height: 23))
        switchAnony.onTintColor = UIColor.faeAppRedColor()
        switchAnony.transform = CGAffineTransform(scaleX: 35/51, y: 21/31)
        uiviewAnonymous.addSubview(switchAnony)
        uiviewAnonymous.addConstraintsWithFormat("H:[v0(35)]-130-|", options: [], views: switchAnony)
        uiviewAnonymous.addConstraintsWithFormat("V:|-14-[v0(21)]", options: [], views: switchAnony)
        
        btnDoAnony = UIButton()
        btnDoAnony.setTitle("Anonymous", for: .normal)
        btnDoAnony.setTitleColor(UIColor.faeAppInputPlaceholderGrayColor(), for: .normal)
        btnDoAnony.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        uiviewAnonymous.addSubview(btnDoAnony)
        uiviewAnonymous.addConstraintsWithFormat("H:[v0(100)]-14-|", options: [], views: btnDoAnony)
        uiviewAnonymous.addConstraintsWithFormat("V:|-6-[v0(45)]", options: [], views: btnDoAnony)
        btnDoAnony.addTarget(self, action: #selector(self.actionDoAnony), for: .touchUpInside)
    }
    
    fileprivate func loadEmojiView(){
        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
        emojiView.sendStickerDelegate = self
        emojiView.layer.zPosition = 130
        self.view.addSubview(emojiView)
    }
    
    fileprivate func loadingOtherParts() {
        subviewTable = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 255))
        subviewTable.backgroundColor = UIColor.white
        subviewTable.center.y -= screenHeight
        self.view.addSubview(subviewTable)
        subviewTable.layer.zPosition = 61
        subviewTable.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        subviewTable.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        subviewTable.layer.shadowOpacity = 0.3
        subviewTable.layer.shadowRadius = 10.0
        
        // Table comments
        tableCommentsForPin = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 255))
        tableCommentsForPin.delegate = self
        tableCommentsForPin.dataSource = self
        tableCommentsForPin.allowsSelection = false
        tableCommentsForPin.register(PinCommentsCell.self, forCellReuseIdentifier: "pinCommentsCell")
        tableCommentsForPin.register(PDEmptyCell.self, forCellReuseIdentifier: "pinEmptyCell")
        tableCommentsForPin.register(PDUserInfoCell.self, forCellReuseIdentifier: "pdUserInfoCell")
        tableCommentsForPin.register(PDFeelingCell.self, forCellReuseIdentifier: "pdFeelingCell")
        tableCommentsForPin.rowHeight = UITableViewAutomaticDimension
        tableCommentsForPin.estimatedRowHeight = 140
        tableCommentsForPin.isScrollEnabled = false
        tableCommentsForPin.tableFooterView = UIView()
        tableCommentsForPin.layer.zPosition = 109
        self.view.addSubview(tableCommentsForPin)
        tableCommentsForPin.center.y -= screenHeight
        tableCommentsForPin.delaysContentTouches = false
        tableCommentsForPin.showsVerticalScrollIndicator = false
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
        tableCommentsForPin.addGestureRecognizer(tapToDismissKeyboard)
        
        // Dragging button
        draggingButtonSubview = UIView(frame: CGRect(x: 0, y: 292, width: screenWidth, height: 27))
        draggingButtonSubview.backgroundColor = UIColor.white
        self.view.addSubview(draggingButtonSubview)
        draggingButtonSubview.layer.zPosition = 109
        draggingButtonSubview.center.y -= screenHeight
        
        uiviewPinUnderLine02 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        uiviewPinUnderLine02.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        self.draggingButtonSubview.addSubview(uiviewPinUnderLine02)
        
        buttonPinDetailDragToLargeSize = UIButton(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 27))
        buttonPinDetailDragToLargeSize.backgroundColor = UIColor.white
        buttonPinDetailDragToLargeSize.setImage(#imageLiteral(resourceName: "pinDetailDraggingButton"), for: UIControlState())
        buttonPinDetailDragToLargeSize.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
        self.draggingButtonSubview.addSubview(buttonPinDetailDragToLargeSize)
        buttonPinDetailDragToLargeSize.center.x = screenWidth/2
        buttonPinDetailDragToLargeSize.tag = 0
    }
    
    fileprivate func loadTableHeader() {
        // Header
        uiviewPinDetail = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 274))
        uiviewPinDetail.backgroundColor = UIColor.white
        uiviewPinDetail.layer.zPosition = 100
        self.view.addSubview(uiviewPinDetail)
        
        // Textview width based on different resolutions
        var textViewWidth: CGFloat = 0
        if screenWidth == 414 { // 5.5
            textViewWidth = 370
        }
        else if screenWidth == 320 { // 4.0
            textViewWidth = 276
        }
        else if screenWidth == 375 { // 4.7
            textViewWidth = 331
        }
        
        // Textview of pin detail
        textviewPinDetail = UITextView(frame: CGRect(x: 27, y: 75, width: textViewWidth, height: 200))
        textviewPinDetail.center.x = screenWidth / 2
        textviewPinDetail.text = ""
        textviewPinDetail.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textviewPinDetail.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textviewPinDetail.isUserInteractionEnabled = true
        textviewPinDetail.isEditable = false
        textviewPinDetail.isScrollEnabled = true
        textviewPinDetail.textContainerInset = .zero
        textviewPinDetail.indicatorStyle = UIScrollViewIndicatorStyle.white
        if pinTypeEnum == .media {
            textviewPinDetail.isHidden = true
        }
        uiviewPinDetail.addSubview(textviewPinDetail)
        
        scrollViewMedia = UIScrollView(frame: CGRect(x: 0, y: 80, width: screenWidth, height: 95))
        scrollViewMedia.delegate = self
        scrollViewMedia.contentSize = CGSize(width: screenWidth-15, height: 95)
        scrollViewMedia.isScrollEnabled = true
        scrollViewMedia.backgroundColor = UIColor.clear
        scrollViewMedia.showsHorizontalScrollIndicator = false
        uiviewPinDetail.addSubview(scrollViewMedia)
        var insets = scrollViewMedia.contentInset
        insets.left = 15
        insets.right = 15
        scrollViewMedia.contentInset = insets
        scrollViewMedia.scrollToLeft(animated: false)
        
        // Hot pin
        imageViewHotPin = UIImageView()
        imageViewHotPin.image = #imageLiteral(resourceName: "pinDetailHotPin")
        imageViewHotPin.contentMode = .scaleAspectFill
        imageViewHotPin.isHidden = true
        uiviewPinDetail.addSubview(imageViewHotPin)
        uiviewPinDetail.addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: imageViewHotPin)
        uiviewPinDetail.addConstraintsWithFormat("V:|-15-[v0(20)]", options: [], views: imageViewHotPin)
        
        // ----
        // Main buttons' container of pin detail
        uiviewPinDetailMainButtons = UIView(frame: CGRect(x: 0, y: 185, width: screenWidth, height: 27))
        uiviewPinDetail.addSubview(uiviewPinDetailMainButtons)
        
        // Feeling quick view
        uiviewFeeling = UIView(frame: CGRect(x: 14, y: 0, width: screenWidth - 180, height: 27))
        uiviewPinDetailMainButtons.addSubview(uiviewFeeling)
        uiviewFeeling.layer.zPosition = 109
        
        // Pin Like
        buttonPinLike = UIButton()
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
        buttonPinLike.addTarget(self, action: #selector(self.actionLikeThisPin(_:)), for: [.touchUpInside, .touchUpOutside])
        buttonPinLike.addTarget(self, action: #selector(self.actionHoldingLikeButton(_:)), for: .touchDown)
        uiviewPinDetailMainButtons.addSubview(buttonPinLike)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: buttonPinLike)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("V:[v0(27)]-0-|", options: [], views: buttonPinLike)
        buttonPinLike.tag = 0
        buttonPinLike.layer.zPosition = 109
        
        // Add Comment
        buttonPinAddComment = UIButton()
        buttonPinAddComment.setImage(#imageLiteral(resourceName: "pinDetailShowCommentsHollow"), for: UIControlState())
        buttonPinAddComment.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
        buttonPinAddComment.tag = 0
        uiviewPinDetailMainButtons.addSubview(buttonPinAddComment)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: buttonPinAddComment)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("V:[v0(27)]-0-|", options: [], views: buttonPinAddComment)
        
        // Label of Like Count
        labelPinLikeCount = UILabel()
        labelPinLikeCount.text = ""
        labelPinLikeCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelPinLikeCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelPinLikeCount.textAlignment = .right
        uiviewPinDetailMainButtons.addSubview(labelPinLikeCount)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("H:[v0(41)]-141-|", options: [], views: labelPinLikeCount)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("V:[v0(27)]-0-|", options: [], views: labelPinLikeCount)
        
        // Label of Comments of Coment Pin Count
        labelPinCommentsCount = UILabel()
        labelPinCommentsCount.text = ""
        labelPinCommentsCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelPinCommentsCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelPinCommentsCount.textAlignment = .right
        uiviewPinDetailMainButtons.addSubview(labelPinCommentsCount)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("H:[v0(41)]-49-|", options: [], views: labelPinCommentsCount)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("V:[v0(27)]-0-|", options: [], views: labelPinCommentsCount)
        
        // ----
        // Gray Block
        uiviewPinDetailGrayBlock = UIView(frame: CGRect(x: 0, y: 227, width: screenWidth, height: 5))
        uiviewPinDetailGrayBlock.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        uiviewPinDetail.addSubview(uiviewPinDetailGrayBlock)
        
        // ----
        // View to hold three buttons
        uiviewPinDetailThreeButtons = UIView(frame: CGRect(x: 0, y: 232, width: screenWidth, height: 42))
        uiviewPinDetail.addSubview(uiviewPinDetailThreeButtons)
        
        // Three buttons bottom gray line
        uiviewGrayBaseLine = UIView()
        uiviewGrayBaseLine.layer.borderWidth = 1.0
        uiviewGrayBaseLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        uiviewPinDetailThreeButtons.addSubview(uiviewGrayBaseLine)
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: uiviewGrayBaseLine)
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: uiviewGrayBaseLine)
        
        let widthOfThreeButtons = screenWidth / 3
        
        // Three buttons bottom sliding red line
        uiviewRedSlidingLine = UIView(frame: CGRect(x: 0, y: 40, width: widthOfThreeButtons, height: 2))
        uiviewRedSlidingLine.layer.borderWidth = 1.0
        uiviewRedSlidingLine.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).cgColor
        uiviewPinDetailThreeButtons.addSubview(uiviewRedSlidingLine)
        
        // "Talk Talk" of this uiview
        labelPinDetailViewComments = UILabel()
        labelPinDetailViewComments.text = "Talk Talk"
        labelPinDetailViewComments.textColor = UIColor.faeAppInputTextGrayColor()
        labelPinDetailViewComments.textAlignment = .center
        labelPinDetailViewComments.font = UIFont(name: "AvenirNext-Medium", size: 16)
        uiviewPinDetailThreeButtons.addSubview(labelPinDetailViewComments)
        
        buttonPinDetailViewComments = UIButton()
        buttonPinDetailViewComments.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewPinDetailThreeButtons.addSubview(buttonPinDetailViewComments)
        buttonPinDetailViewComments.tag = 1
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: labelPinDetailViewComments)
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonPinDetailViewComments)
        
        
        // "Feelings" of this uiview
        labelPinDetailViewFeelings = UILabel()
        labelPinDetailViewFeelings.text = "Feelings"
        labelPinDetailViewFeelings.textColor = UIColor.faeAppInputTextGrayColor()
        labelPinDetailViewFeelings.textAlignment = .center
        labelPinDetailViewFeelings.font = UIFont(name: "AvenirNext-Medium", size: 16)
        uiviewPinDetailThreeButtons.addSubview(labelPinDetailViewFeelings)
        
        buttonPinDetailViewFeelings = UIButton()
        buttonPinDetailViewFeelings.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewPinDetailThreeButtons.addSubview(buttonPinDetailViewFeelings)
        buttonPinDetailViewFeelings.tag = 3
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: labelPinDetailViewFeelings)
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonPinDetailViewFeelings)
        
        
        // "People" of this uiview
        labelPinDetailViewPeople = UILabel()
        labelPinDetailViewPeople.text = "People"
        labelPinDetailViewPeople.textColor = UIColor.faeAppInputTextGrayColor()
        labelPinDetailViewPeople.textAlignment = .center
        labelPinDetailViewPeople.font = UIFont(name: "AvenirNext-Medium", size: 16)
        uiviewPinDetailThreeButtons.addSubview(labelPinDetailViewPeople)
        buttonPinDetailViewPeople = UIButton()
        buttonPinDetailViewPeople.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewPinDetailThreeButtons.addSubview(buttonPinDetailViewPeople)
        buttonPinDetailViewPeople.tag = 5
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: labelPinDetailViewPeople)
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonPinDetailViewPeople)
        
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: labelPinDetailViewComments, labelPinDetailViewFeelings, labelPinDetailViewPeople)
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: buttonPinDetailViewComments, buttonPinDetailViewFeelings, buttonPinDetailViewPeople)
        
        // Comment Pin User Avatar
        imagePinUserAvatar = UIImageView()
        imagePinUserAvatar.image = #imageLiteral(resourceName: "defaultMen")
        imagePinUserAvatar.layer.cornerRadius = 25
        imagePinUserAvatar.clipsToBounds = true
        imagePinUserAvatar.contentMode = .scaleAspectFill
        uiviewPinDetail.addSubview(imagePinUserAvatar)
        uiviewPinDetail.addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imagePinUserAvatar)
        uiviewPinDetail.addConstraintsWithFormat("V:|-15-[v0(50)]", options: [], views: imagePinUserAvatar)
        imagePinUserAvatar.alpha = 1
        
        // Comment Pin Username
        labelPinUserName = UILabel()
        labelPinUserName.text = ""
        labelPinUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelPinUserName.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelPinTitle.textAlignment = .left
        uiviewPinDetail.addSubview(labelPinUserName)
        uiviewPinDetail.addConstraintsWithFormat("H:|-80-[v0(250)]", options: [], views: labelPinUserName)
        uiviewPinDetail.addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: labelPinUserName)
        
        // Timestamp of comment pin detail
        labelPinTimestamp = UILabel()
        labelPinTimestamp.text = ""
        labelPinTimestamp.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelPinTimestamp.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelPinTimestamp.textAlignment = .left
        uiviewPinDetail.addSubview(labelPinTimestamp)
        uiviewPinDetail.addConstraintsWithFormat("H:|-80-[v0(200)]", options: [], views: labelPinTimestamp)
        uiviewPinDetail.addConstraintsWithFormat("V:|-40-[v0(27)]", options: [], views: labelPinTimestamp)
        
        // image view appears when saved pin button pressed
        imageViewSaved = UIImageView()
        imageViewSaved.image = UIImage(named: "pinSaved")
        view.addSubview(imageViewSaved)
        view.addConstraintsWithFormat("H:[v0(182)]", options: [], views: imageViewSaved)
        view.addConstraintsWithFormat("V:|-107-[v0(58)]", options: [], views: imageViewSaved)
        NSLayoutConstraint(item: imageViewSaved, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        imageViewSaved.layer.zPosition = 200
        imageViewSaved.alpha = 0.0
    }
    
    fileprivate func loadNavigationBar() {
        subviewNavigation = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        subviewNavigation.backgroundColor = UIColor.white
        self.view.addSubview(subviewNavigation)
        subviewNavigation.layer.zPosition = 101
        subviewNavigation.center.y -= screenHeight
        
        // Line at y = 64
        uiviewPinUnderLine01 = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewPinUnderLine01.layer.borderWidth = screenWidth
        uiviewPinUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        subviewNavigation.addSubview(uiviewPinUnderLine01)
        
        // Back to Map
        buttonPinBackToMap = UIButton()
        buttonPinBackToMap.setImage(#imageLiteral(resourceName: "pinDetailBackToMap"), for: UIControlState())
        buttonPinBackToMap.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
        subviewNavigation.addSubview(buttonPinBackToMap)
        subviewNavigation.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonPinBackToMap)
        subviewNavigation.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: buttonPinBackToMap)
        buttonPinBackToMap.alpha = 0.0
        buttonPinBackToMap.tag = 1
        
        // Back to Comment Pin List
        buttonBackToPinLists = UIButton()
        buttonBackToPinLists.setImage(#imageLiteral(resourceName: "pinDetailJumpToOpenedPin"), for: UIControlState())
        buttonBackToPinLists.addTarget(self, action: #selector(self.actionGoToList(_:)), for: .touchUpInside)
        subviewNavigation.addSubview(buttonBackToPinLists)
        subviewNavigation.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonBackToPinLists)
        subviewNavigation.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: buttonBackToPinLists)
        
        // Comment Pin Option
        buttonOptionOfPin = UIButton()
        buttonOptionOfPin.setImage(#imageLiteral(resourceName: "pinDetailMoreOptions"), for: UIControlState())
        buttonOptionOfPin.addTarget(self, action: #selector(self.showPinMoreButtonDetails(_:)), for: .touchUpInside)
        subviewNavigation.addSubview(buttonOptionOfPin)
        subviewNavigation.addConstraintsWithFormat("H:[v0(101)]-(-22)-|", options: [], views: buttonOptionOfPin)
        subviewNavigation.addConstraintsWithFormat("V:|-23-[v0(37)]", options: [], views: buttonOptionOfPin)
        
        // Label of Title
        labelPinTitle = UILabel()
        labelPinTitle.text = ""
        labelPinTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelPinTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        subviewNavigation.addSubview(labelPinTitle)
        subviewNavigation.addConstraintsWithFormat("H:[v0(92)]", options: [], views: labelPinTitle)
        subviewNavigation.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelPinTitle)
        NSLayoutConstraint(item: labelPinTitle, attribute: .centerX, relatedBy: .equal, toItem: subviewNavigation, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
    }
    
    fileprivate func loadAnotherToolbar() {
        // Gray Block
        controlBoard = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 42))
        controlBoard.backgroundColor = UIColor.white
        self.view.addSubview(controlBoard)
        self.controlBoard.isHidden = true
        controlBoard.layer.zPosition = 110
        
        // Three buttons bottom gray line
        let grayBaseLine = UIView()
        grayBaseLine.layer.borderWidth = 1.0
        grayBaseLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        self.controlBoard.addSubview(grayBaseLine)
        self.controlBoard.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: grayBaseLine)
        self.controlBoard.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: grayBaseLine)
        
        // View to hold three buttons
        let threeButtonsContainer = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 42))
        self.controlBoard.addSubview(threeButtonsContainer)
        
        let widthOfThreeButtons = screenWidth / 3
        
        // Three buttons bottom sliding red line
        anotherRedSlidingLine = UIView(frame: CGRect(x: 0, y: 40, width: widthOfThreeButtons, height: 2))
        anotherRedSlidingLine.layer.borderWidth = 1.0
        anotherRedSlidingLine.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).cgColor
        self.controlBoard.addSubview(anotherRedSlidingLine)
        
        // "Talk Talk" of this uiview
        let labelComments = UILabel()
        labelComments.text = "Talk Talk"
        labelComments.textColor = UIColor.faeAppInputTextGrayColor()
        labelComments.textAlignment = .center
        labelComments.font = UIFont(name: "AvenirNext-Medium", size: 16)
        threeButtonsContainer.addSubview(labelComments)
        let comments = UIButton()
        comments.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        threeButtonsContainer.addSubview(comments)
        comments.tag = 1
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: labelComments)
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: comments)
        
        // "Feelings" of this uiview
        let labelFeelings = UILabel()
        labelFeelings.text = "Feelings"
        labelFeelings.textColor = UIColor.faeAppInputTextGrayColor()
        labelFeelings.textAlignment = .center
        labelFeelings.font = UIFont(name: "AvenirNext-Medium", size: 16)
        threeButtonsContainer.addSubview(labelFeelings)
        let feelings = UIButton()
        feelings.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        threeButtonsContainer.addSubview(feelings)
        feelings.tag = 3
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: labelFeelings)
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: feelings)
        
        // "People" of this uiview
        let labelPeople = UILabel()
        labelPeople.text = "People"
        labelPeople.textColor = UIColor.faeAppInputTextGrayColor()
        labelPeople.textAlignment = .center
        labelPeople.font = UIFont(name: "AvenirNext-Medium", size: 16)
        threeButtonsContainer.addSubview(labelPeople)
        let people = UIButton()
        people.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        threeButtonsContainer.addSubview(people)
        people.tag = 5
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: labelPeople)
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: people)
        
        threeButtonsContainer.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: labelComments, labelFeelings, labelPeople)
        threeButtonsContainer.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: comments, feelings, people)
    }
    
    fileprivate func loadPinCtrlButton() {
        pinIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 80))
        pinIcon.image = pinIconHeavyShadow
        pinIcon.contentMode = .scaleAspectFit
        pinIcon.center.x = screenWidth / 2
        pinIcon.center.y = 510 * screenHeightFactor
        pinIcon.layer.zPosition = 50
        pinIcon.alpha = 0
        self.view.addSubview(pinIcon)
        
        buttonPrevPin = UIButton(frame: CGRect(x: 15, y: 477 * screenHeightFactor, width: 52, height: 52))
        buttonPrevPin.setImage(UIImage(named: "prevPin"), for: UIControlState())
        buttonPrevPin.layer.zPosition = 60
        buttonPrevPin.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        buttonPrevPin.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        buttonPrevPin.layer.shadowOpacity = 0.6
        buttonPrevPin.layer.shadowRadius = 3.0
        buttonPrevPin.alpha = 0
        self.view.addSubview(buttonPrevPin)
        
        buttonNextPin = UIButton(frame: CGRect(x: 347 * screenHeightFactor, y: 477 * screenHeightFactor, width: 52, height: 52))
        buttonNextPin.setImage(UIImage(named: "nextPin"), for: UIControlState())
        buttonNextPin.layer.zPosition = 60
        buttonNextPin.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        buttonNextPin.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        buttonNextPin.layer.shadowOpacity = 0.6
        buttonNextPin.layer.shadowRadius = 3.0
        buttonNextPin.alpha = 0
        self.view.addSubview(buttonNextPin)
    }
}
