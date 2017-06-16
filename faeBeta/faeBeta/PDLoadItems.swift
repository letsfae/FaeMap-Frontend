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
        
        self.loadTransparentButtonBackToMap()
        self.loadFeelingBar()
        
        uiviewMain = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 320))
        uiviewMain.layer.zPosition = 101
        uiviewMain.clipsToBounds = true
        self.view.addSubview(uiviewMain)
        uiviewMain.frame.origin.y = enterMode == .collections ? 0 : -screenHeight
        
        self.loadNavigationBar()
        self.loadPinCtrlButton()
        self.loadingOtherParts()
        self.loadTableHeader()
        self.loadToolBar()
        self.loadInputToolBar()
        self.loadChatView()
        
        tblMain.tableHeaderView = PinDetailViewController.pinTypeEnum == .chat_room ? uiviewChatRoom : uiviewTblHeader
    }
    
    fileprivate func loadTransparentButtonBackToMap() {
        btnGrayBackToMap = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        btnGrayBackToMap.backgroundColor = UIColor(red: 115 / 255, green: 115 / 255, blue: 115 / 255, alpha: 0.5)
        btnGrayBackToMap.alpha = 0
        view.addSubview(btnGrayBackToMap)
        view.sendSubview(toBack: btnGrayBackToMap)
        btnGrayBackToMap.addTarget(self, action: #selector(self.actionBackToMap(_:)), for: .touchUpInside)
    }
    
    fileprivate func loadNavigationBar() {
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        uiviewMain.addSubview(uiviewNavBar)
        
        btnHalfPinToMap = UIButton()
        
        if enterMode != .collections {
            uiviewNavBar.leftBtnWidth = 24
            uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "pinDetailFullToHalf"), for: .normal)
            uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
            uiviewNavBar.leftBtn.alpha = 0.0
            uiviewNavBar.leftBtn.tag = 1
            
            btnHalfPinToMap.setImage(#imageLiteral(resourceName: "pinDetailHalfPinBack"), for: .normal)
            btnHalfPinToMap.addTarget(self, action: #selector(self.actionBackToMap(_:)), for: .touchUpInside)
            uiviewNavBar.addSubview(btnHalfPinToMap)
            uiviewNavBar.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: btnHalfPinToMap)
            uiviewNavBar.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: btnHalfPinToMap)
        } else {
            uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionBackToMap(_:)), for: .touchUpInside)
        }
        
        uiviewNavBar.loadBtnConstraints()
        
        // Comment Pin Option
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(self.showPinMoreButtonDetails(_:)), for: .touchUpInside)
    }
    
    fileprivate func loadFeelingBar() {
        if PinDetailViewController.pinTypeEnum == .place {
            return
        }
        
        let feelingBarAnchor = CGPoint(x: screenWidth / 2, y: 461 * screenHeightFactor)
        
        uiviewFeelingBar = UIView(frame: CGRect(x: screenWidth / 2, y: 451 * screenHeightFactor, width: 0, height: 0))
        view.addSubview(uiviewFeelingBar)
        uiviewFeelingBar.layer.anchorPoint = feelingBarAnchor
        uiviewFeelingBar.layer.cornerRadius = 26
        uiviewFeelingBar.backgroundColor = UIColor.white
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(self.handleFeelingPanGesture(_:)))
        uiviewFeelingBar.addGestureRecognizer(panGesture)
        
        btnFeelingBar_01 = UIButton()
        btnFeelingBar_02 = UIButton()
        btnFeelingBar_03 = UIButton()
        btnFeelingBar_04 = UIButton()
        btnFeelingBar_05 = UIButton()
        
        btnFeelingArray.append(btnFeelingBar_01)
        btnFeelingArray.append(btnFeelingBar_02)
        btnFeelingArray.append(btnFeelingBar_03)
        btnFeelingArray.append(btnFeelingBar_04)
        btnFeelingArray.append(btnFeelingBar_05)
        
        for i in 0..<btnFeelingArray.count {
            btnFeelingArray[i].frame = CGRect.zero
            uiviewFeelingBar.addSubview(btnFeelingArray[i])
            btnFeelingArray[i].setImage(UIImage(named: "pdFeeling_0\(i + 1)-1"), for: .normal)
            btnFeelingArray[i].adjustsImageWhenHighlighted = false
            btnFeelingArray[i].tag = i
            btnFeelingArray[i].layer.anchorPoint = feelingBarAnchor
            btnFeelingArray[i].addTarget(self, action: #selector(self.postFeeling(_:)), for: .touchUpInside)
        }
    }
    
    fileprivate func loadPinCtrlButton() {
        imgPinIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 80))
        imgPinIcon.image = pinIconHeavyShadow
        imgPinIcon.contentMode = .scaleAspectFit
        imgPinIcon.center.x = screenWidth / 2
        imgPinIcon.center.y = 510 * screenHeightFactor
        imgPinIcon.layer.zPosition = 50
        imgPinIcon.alpha = 0
        view.addSubview(imgPinIcon)
        
        btnPrevPin = UIButton(frame: CGRect(x: 41 * screenHeightFactor, y: 503 * screenHeightFactor, width: 0, height: 0))
        btnPrevPin.setImage(UIImage(named: "prevPin"), for: UIControlState())
        btnPrevPin.layer.zPosition = 60
        btnPrevPin.layer.shadowColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0).cgColor
        btnPrevPin.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btnPrevPin.layer.shadowOpacity = 0.6
        btnPrevPin.layer.shadowRadius = 3.0
        btnPrevPin.alpha = 0
        btnPrevPin.addTarget(self, action: #selector(self.actionGotoPin(_:)), for: .touchUpInside)
        view.addSubview(btnPrevPin)
        
        btnNextPin = UIButton(frame: CGRect(x: 373 * screenHeightFactor, y: 503 * screenHeightFactor, width: 0, height: 0))
        btnNextPin.setImage(UIImage(named: "nextPin"), for: UIControlState())
        btnNextPin.layer.zPosition = 60
        btnNextPin.layer.shadowColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0).cgColor
        btnNextPin.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btnNextPin.layer.shadowOpacity = 0.6
        btnNextPin.layer.shadowRadius = 3.0
        btnNextPin.alpha = 0
        btnNextPin.addTarget(self, action: #selector(self.actionGotoPin(_:)), for: .touchUpInside)
        view.addSubview(btnNextPin)
    }
    
    fileprivate func loadingOtherParts() {
        uiviewTableSub = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 255))
        uiviewTableSub.backgroundColor = UIColor.white
        uiviewMain.addSubview(uiviewTableSub)
        uiviewTableSub.layer.shadowColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0).cgColor
        uiviewTableSub.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        uiviewTableSub.layer.shadowOpacity = 0.3
        uiviewTableSub.layer.shadowRadius = 10.0
        
        tblMain = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 255))
        tblMain.delegate = self
        tblMain.dataSource = self
        tblMain.allowsSelection = false
        tblMain.delaysContentTouches = false
        tblMain.estimatedRowHeight = 140
        tblMain.isScrollEnabled = false
        tblMain.register(PDEmptyCell.self, forCellReuseIdentifier: "pinEmptyCell")
        tblMain.register(PDFeelingCell.self, forCellReuseIdentifier: "pdFeelingCell")
        tblMain.register(PDPeopleCell.self, forCellReuseIdentifier: "pdUserInfoCell")
        tblMain.register(PinTalkTalkCell.self, forCellReuseIdentifier: "pinCommentsCell")
        tblMain.rowHeight = UITableViewAutomaticDimension
        tblMain.showsVerticalScrollIndicator = false
        tblMain.tableFooterView = UIView()
        uiviewMain.addSubview(tblMain)
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
        tblMain.addGestureRecognizer(tapToDismissKeyboard)
        
        uiviewToFullDragBtnSub = UIView(frame: CGRect(x: 0, y: 292, width: screenWidth, height: 27))
        uiviewToFullDragBtnSub.backgroundColor = UIColor.white
        uiviewMain.addSubview(uiviewToFullDragBtnSub)
        
        uiviewLineInDragBtn = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        uiviewLineInDragBtn.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0)
        uiviewToFullDragBtnSub.addSubview(uiviewLineInDragBtn)
        
        btnToFullPin = UIButton(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 27))
        btnToFullPin.backgroundColor = UIColor.white
        btnToFullPin.setImage(#imageLiteral(resourceName: "pinDetailDraggingButton"), for: UIControlState())
        btnToFullPin.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
        uiviewToFullDragBtnSub.addSubview(btnToFullPin)
        btnToFullPin.center.x = screenWidth / 2
        btnToFullPin.tag = 0
    }
    
    fileprivate func loadTableHeader() {
        
        uiviewTblHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 232))
        uiviewTblHeader.backgroundColor = UIColor.white
        
        // Textview width based on different resolutions
        var textViewWidth: CGFloat = 0
        if screenWidth == 414 { // 5.5
            textViewWidth = 370
        } else if screenWidth == 375 { // 4.7
            textViewWidth = 331
        } else if screenWidth == 320 { // 4.0
            textViewWidth = 276
        }
        
        // Textview of pin detail
        textviewPinDetail = UITextView(frame: CGRect(x: 27, y: 75, width: textViewWidth, height: 100))
        textviewPinDetail.frame.size.height = PinDetailViewController.pinTypeEnum == .media ? 0 : 100
        textviewPinDetail.alpha = PinDetailViewController.pinTypeEnum == .media ? 0 : 1
        textviewPinDetail.center.x = screenWidth / 2
        textviewPinDetail.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textviewPinDetail.indicatorStyle = UIScrollViewIndicatorStyle.white
        textviewPinDetail.isEditable = false
        textviewPinDetail.isScrollEnabled = true
        textviewPinDetail.isUserInteractionEnabled = true
        textviewPinDetail.attributedText = strTextViewText.convertStringWithEmoji()
        textviewPinDetail.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        textviewPinDetail.textContainerInset = .zero
        uiviewTblHeader.addSubview(textviewPinDetail)
        
        scrollViewMedia = UIScrollView(frame: CGRect(x: 0, y: 80, width: screenWidth, height: 0))
        scrollViewMedia.frame.size.height = enterMode == .collections ? 160 : 95
        scrollViewMedia.delegate = self
        scrollViewMedia.contentSize = CGSize(width: screenWidth - 15, height: 95)
        scrollViewMedia.isScrollEnabled = true
        scrollViewMedia.backgroundColor = UIColor.clear
        scrollViewMedia.showsHorizontalScrollIndicator = false
        uiviewTblHeader.addSubview(scrollViewMedia)
        var insets = scrollViewMedia.contentInset
        insets.left = 15
        insets.right = 15
        scrollViewMedia.contentInset = insets
        scrollViewMedia.scrollToLeft(animated: false)
        scrollViewMedia.isHidden = PinDetailViewController.pinTypeEnum == .media ? false : true
        
        // Hot pin
        imgHotPin = UIImageView()
        imgHotPin.image = #imageLiteral(resourceName: "pinDetailHotPin")
        imgHotPin.contentMode = .scaleAspectFill
        imgHotPin.isHidden = true
        uiviewTblHeader.addSubview(imgHotPin)
        uiviewTblHeader.addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: imgHotPin)
        uiviewTblHeader.addConstraintsWithFormat("V:|-15-[v0(20)]", options: [], views: imgHotPin)
        
        // Main buttons' container of pin detail
        uiviewInteractBtnSub = UIView(frame: CGRect(x: 0, y: 185, width: screenWidth, height: 27))
        uiviewTblHeader.addSubview(uiviewInteractBtnSub)
        
        // Feeling quick view
        uiviewFeelingQuick = UIView(frame: CGRect(x: 14, y: 0, width: screenWidth - 180, height: 27))
        uiviewInteractBtnSub.addSubview(uiviewFeelingQuick)
        uiviewFeelingQuick.layer.zPosition = 109
        
        // Pin Like
        btnPinLike = UIButton()
        btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: UIControlState())
        btnPinLike.addTarget(self, action: #selector(self.actionLikeThisPin(_:)), for: [.touchUpInside, .touchUpOutside])
        btnPinLike.addTarget(self, action: #selector(self.actionHoldingLikeButton(_:)), for: .touchDown)
        uiviewInteractBtnSub.addSubview(btnPinLike)
        uiviewInteractBtnSub.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: btnPinLike)
        uiviewInteractBtnSub.addConstraintsWithFormat("V:[v0(27)]-0-|", options: [], views: btnPinLike)
        btnPinLike.tag = 0
        btnPinLike.layer.zPosition = 109
        
        // Add Comment
        btnPinComment = UIButton()
        btnPinComment.setImage(#imageLiteral(resourceName: "pinDetailShowCommentsHollow"), for: UIControlState())
        btnPinComment.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
        btnPinComment.tag = 0
        uiviewInteractBtnSub.addSubview(btnPinComment)
        uiviewInteractBtnSub.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: btnPinComment)
        uiviewInteractBtnSub.addConstraintsWithFormat("V:[v0(27)]-0-|", options: [], views: btnPinComment)
        
        // Label of Like Count
        lblPinLikeCount = UILabel()
        lblPinLikeCount.text = ""
        lblPinLikeCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        lblPinLikeCount.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0)
        lblPinLikeCount.textAlignment = .right
        uiviewInteractBtnSub.addSubview(lblPinLikeCount)
        uiviewInteractBtnSub.addConstraintsWithFormat("H:[v0(41)]-141-|", options: [], views: lblPinLikeCount)
        uiviewInteractBtnSub.addConstraintsWithFormat("V:[v0(27)]-0-|", options: [], views: lblPinLikeCount)
        
        // Label of Comments of Coment Pin Count
        lblCommentCount = UILabel()
        lblCommentCount.text = ""
        lblCommentCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        lblCommentCount.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0)
        lblCommentCount.textAlignment = .right
        uiviewInteractBtnSub.addSubview(lblCommentCount)
        uiviewInteractBtnSub.addConstraintsWithFormat("H:[v0(41)]-49-|", options: [], views: lblCommentCount)
        uiviewInteractBtnSub.addConstraintsWithFormat("V:[v0(27)]-0-|", options: [], views: lblCommentCount)
        
        // Gray Block
        uiviewGrayMidBlock = UIView(frame: CGRect(x: 0, y: 227, width: screenWidth, height: 5))
        uiviewGrayMidBlock.backgroundColor = UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 1.0)
        uiviewTblHeader.addSubview(uiviewGrayMidBlock)
        
        // Comment Pin User Avatar
        imgPinUserAvatar = FaeAvatarView(frame: CGRect.zero)
        imgPinUserAvatar.image = #imageLiteral(resourceName: "defaultMen")
        imgPinUserAvatar.layer.cornerRadius = 25
        imgPinUserAvatar.clipsToBounds = true
        imgPinUserAvatar.contentMode = .scaleAspectFill
        uiviewTblHeader.addSubview(imgPinUserAvatar)
        uiviewTblHeader.addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imgPinUserAvatar)
        uiviewTblHeader.addConstraintsWithFormat("V:|-15-[v0(50)]", options: [], views: imgPinUserAvatar)
        imgPinUserAvatar.alpha = 1
        
        // Comment Pin Username
        lblPinDisplayName = UILabel()
        lblPinDisplayName.text = ""
        lblPinDisplayName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblPinDisplayName.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        lblPinDisplayName.textAlignment = .left
        uiviewTblHeader.addSubview(lblPinDisplayName)
        uiviewTblHeader.addConstraintsWithFormat("H:|-80-[v0(250)]", options: [], views: lblPinDisplayName)
        uiviewTblHeader.addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: lblPinDisplayName)
        
        // Timestamp of comment pin detail
        lblPinDate = UILabel()
        lblPinDate.text = ""
        lblPinDate.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblPinDate.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0)
        lblPinDate.textAlignment = .left
        uiviewTblHeader.addSubview(lblPinDate)
        uiviewTblHeader.addConstraintsWithFormat("H:|-80-[v0(200)]", options: [], views: lblPinDate)
        uiviewTblHeader.addConstraintsWithFormat("V:|-40-[v0(27)]", options: [], views: lblPinDate)
        
        // image view appears when saved pin button pressed
        imgCollected = UIImageView()
        imgCollected.image = UIImage(named: "pinSaved")
        view.addSubview(imgCollected)
        view.addConstraintsWithFormat("H:[v0(182)]", options: [], views: imgCollected)
        view.addConstraintsWithFormat("V:|-107-[v0(58)]", options: [], views: imgCollected)
        NSLayoutConstraint(item: imgCollected, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        imgCollected.layer.zPosition = 200
        imgCollected.alpha = 0.0
    }
    
    fileprivate func loadToolBar() {
        // View to hold three buttons
        uiviewTblCtrlBtnSub = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 42))
        
        // Three buttons bottom gray line
        uiviewGrayMidLine = UIView()
        uiviewGrayMidLine.layer.borderWidth = 1.0
        uiviewGrayMidLine.layer.borderColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0).cgColor
        uiviewTblCtrlBtnSub.addSubview(uiviewGrayMidLine)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewGrayMidLine)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: uiviewGrayMidLine)
        
        let widthOfThreeButtons = screenWidth / 3
        
        // Three buttons bottom sliding red line
        uiviewRedSlidingLine = UIView(frame: CGRect(x: 0, y: 40, width: widthOfThreeButtons, height: 2))
        uiviewRedSlidingLine.layer.borderWidth = 1.0
        uiviewRedSlidingLine.layer.borderColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0).cgColor
        uiviewTblCtrlBtnSub.addSubview(uiviewRedSlidingLine)
        
        // "Talk Talk" of this uiview
        lblTalkTalk = UILabel()
        lblTalkTalk.text = "Talk Talk"
        lblTalkTalk.textColor = UIColor.faeAppInputTextGrayColor()
        lblTalkTalk.textAlignment = .center
        lblTalkTalk.font = UIFont(name: "AvenirNext-Medium", size: 16)
        uiviewTblCtrlBtnSub.addSubview(lblTalkTalk)
        
        btnTalkTalk = UIButton()
        btnTalkTalk.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnTalkTalk)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: lblTalkTalk)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: btnTalkTalk)
        
        // "Feelings" of this uiview
        lblFeelings = UILabel()
        lblFeelings.text = "Feelings"
        lblFeelings.textColor = UIColor.faeAppInputTextGrayColor()
        lblFeelings.textAlignment = .center
        lblFeelings.font = UIFont(name: "AvenirNext-Medium", size: 16)
        uiviewTblCtrlBtnSub.addSubview(lblFeelings)
        
        btnFeelings = UIButton()
        btnFeelings.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnFeelings)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: lblFeelings)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: btnFeelings)
        
        // "People" of this uiview
        lblPeople = UILabel()
        lblPeople.text = "People"
        lblPeople.textColor = UIColor.faeAppInputTextGrayColor()
        lblPeople.textAlignment = .center
        lblPeople.font = UIFont(name: "AvenirNext-Medium", size: 16)
        uiviewTblCtrlBtnSub.addSubview(lblPeople)
        btnPeople = UIButton()
        btnPeople.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnPeople)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: lblPeople)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: btnPeople)
        
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: lblTalkTalk, lblFeelings, lblPeople)
        uiviewTblCtrlBtnSub.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: btnTalkTalk, btnFeelings, btnPeople)
    }
    
    fileprivate func loadInputToolBar() {
        uiviewInputToolBarSub = UIView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 51))
        uiviewInputToolBarSub.backgroundColor = UIColor.white
        uiviewInputToolBarSub.layer.zPosition = 200
        
        let line_0 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line_0.layer.borderWidth = 1
        line_0.layer.borderColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0).cgColor
        uiviewInputToolBarSub.addSubview(line_0)
        
        textViewInput = UITextView(frame: CGRect(x: 28, y: 14.5, width: screenWidth - 142, height: 25))
        textViewInput.delegate = self
        textViewInput.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textViewInput.textColor = UIColor.faeAppInputTextGrayColor()
        textViewInput.tintColor = UIColor.faeAppRedColor()
        textViewInput.textContainerInset = .zero
        textViewInput.showsVerticalScrollIndicator = false
        textViewInput.autocorrectionType = .no
        textViewInput.autocapitalizationType = .none
        textViewInput.layoutManager.allowsNonContiguousLayout = false
        uiviewInputToolBarSub.addSubview(textViewInput)
        
        lblTxtPlaceholder = UILabel()
        lblTxtPlaceholder.text = "Write a Comment..."
        lblTxtPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblTxtPlaceholder.textColor = UIColor(r: 146, g: 146, b: 146, alpha: 100)
        uiviewInputToolBarSub.addSubview(lblTxtPlaceholder)
        uiviewInputToolBarSub.addConstraintsWithFormat("H:|-33-[v0]-68-|", options: [], views: lblTxtPlaceholder)
        uiviewInputToolBarSub.addConstraintsWithFormat("V:|-14-[v0(25)]", options: [], views: lblTxtPlaceholder)
        
        btnShowSticker = UIButton()
        btnShowSticker.tag = 0
        btnShowSticker.isHidden = false
        btnShowSticker.setImage(#imageLiteral(resourceName: "sticker"), for: .normal)
        uiviewInputToolBarSub.addSubview(btnShowSticker)
        uiviewInputToolBarSub.addConstraintsWithFormat("H:[v0(29)]-59-|", options: [], views: btnShowSticker)
        uiviewInputToolBarSub.addConstraintsWithFormat("V:[v0(47)]-0-|", options: [], views: btnShowSticker)
        btnShowSticker.addTarget(self, action: #selector(self.actionSwitchKeyboard(_:)), for: .touchUpInside)
        
        btnCommentSend = UIButton()
        btnCommentSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
        uiviewInputToolBarSub.addSubview(btnCommentSend)
        uiviewInputToolBarSub.addConstraintsWithFormat("H:[v0(29)]-15-|", options: [], views: btnCommentSend)
        uiviewInputToolBarSub.addConstraintsWithFormat("V:[v0(47)]-0-|", options: [], views: btnCommentSend)
        btnCommentSend.addTarget(self, action: #selector(self.sendMessageButtonTapped), for: .touchUpInside)
        
        btnCommentOption = UIButton()
        btnCommentOption.setImage(#imageLiteral(resourceName: "pinCommentOptions"), for: .normal)
        uiviewInputToolBarSub.addSubview(btnCommentOption)
        uiviewInputToolBarSub.addConstraintsWithFormat("H:|-2-[v0(31)]", options: [], views: btnCommentOption)
        uiviewInputToolBarSub.addConstraintsWithFormat("V:[v0(25)]-11-|", options: [], views: btnCommentOption)
        btnCommentOption.addTarget(self, action: #selector(self.actionShowHideAnony(_:)), for: .touchUpInside)
        
        view.addSubview(uiviewInputToolBarSub)
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
        line_0.layer.borderColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0).cgColor
        uiviewAnonymous.addSubview(line_0)
        
        btnHideAnony = UIButton()
        btnHideAnony.setImage(#imageLiteral(resourceName: "locationExtendCancel"), for: .normal)
        uiviewAnonymous.addSubview(btnHideAnony)
        uiviewAnonymous.addConstraintsWithFormat("H:|-0-[v0(47)]", options: [], views: btnHideAnony)
        uiviewAnonymous.addConstraintsWithFormat("V:[v0(45)]-0-|", options: [], views: btnHideAnony)
        btnHideAnony.addTarget(self, action: #selector(self.actionShowHideAnony(_:)), for: .touchUpInside)
        
        switchAnony = UISwitch(frame: CGRect(x: 0, y: 0, width: 39, height: 23))
        switchAnony.onTintColor = UIColor.faeAppRedColor()
        switchAnony.transform = CGAffineTransform(scaleX: 35 / 51, y: 21 / 31)
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
    
    fileprivate func loadEmojiView() {
        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
        emojiView.sendStickerDelegate = self
        emojiView.layer.zPosition = 130
        self.view.addSubview(emojiView)
    }
    
    fileprivate func loadChatView() {
        if PinDetailViewController.pinTypeEnum != .chat_room {
            return
        }
        
        uiviewChatRoom = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 65))
        
        uiviewChatSpotBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 227))
        uiviewChatSpotBar.backgroundColor = UIColor.white
        
        imgChatSpot = UIImageView(frame: CGRect(x: (screenWidth / 2) - 40, y: 15, width: 80, height: 80))
        imgChatSpot.layer.cornerRadius = 40
        imgChatSpot.clipsToBounds = true
        imgChatSpot.backgroundColor = UIColor.faeAppRedColor()
        uiviewChatSpotBar.addSubview(imgChatSpot)
        
        let lblChatGroupName = UILabel(frame: CGRect(x: 0, y: 107, width: screenWidth, height: 30))
        lblChatGroupName.textAlignment = NSTextAlignment.center
        lblChatGroupName.text = "California Chat"
        lblChatGroupName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblChatGroupName.textColor = UIColor.faeAppInputTextGrayColor()
        uiviewChatSpotBar.addSubview(lblChatGroupName)
        
        lblChatMemberNum = UILabel(frame: CGRect(x: 0, y: 139, width: screenWidth, height: 30))
        lblChatMemberNum.textAlignment = NSTextAlignment.center
        lblChatMemberNum.text = "39 Members"
        lblChatMemberNum.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblChatMemberNum.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        
        uiviewChatSpotBar.addSubview(lblChatMemberNum)
        
        btnChatEnter = UIButton(frame: CGRect(x: 0, y: 173, width: 210, height: 40))
        btnChatEnter.center.x = screenWidth / 2
        btnChatEnter.setTitle("Enter Chat", for: .normal)
        btnChatEnter.setTitleColor(UIColor.white, for: .normal)
        btnChatEnter.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnChatEnter.titleLabel?.textAlignment = .center
        btnChatEnter.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 100)
        btnChatEnter.layer.cornerRadius = 20
        uiviewChatSpotBar.addSubview(btnChatEnter)
        
        uiviewChatSpotLineFirstBottom = UIView(frame: CGRect(x: 0, y: 227, width: screenWidth, height: 5))
        uiviewChatSpotLineFirstBottom.backgroundColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 100)
        uiviewChatSpotBar.addSubview(uiviewChatSpotLineFirstBottom)
        
        self.uiviewChatRoom.addSubview(uiviewChatSpotBar)
        
        lblPeopleCount = UILabel(frame: CGRect(x: 15, y: 247, width: 200, height: 22))
        
        let attriMemberStrPeople = [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(),
                                    NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
        
        let attriMemberNum = [NSForegroundColorAttributeName: UIColor.faeAppRedColor(),
                              NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
        
        let attriMemberTotal = [NSForegroundColorAttributeName: UIColor.faeAppInputPlaceholderGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
        // set attributes
        
        let mutableAttrStringPeople = NSMutableAttributedString(string: "People  ", attributes: attriMemberStrPeople)
        mutableAttrStringMemberNum = NSMutableAttributedString(string: "39", attributes: attriMemberNum)
        let mutableAttrStringSlash = NSMutableAttributedString(string: "/", attributes: attriMemberTotal)
        mutableAttrStringMemberTotal = NSMutableAttributedString(string: "50", attributes: attriMemberTotal)
        // set attributed parts
        
        let mutableStrIniTitle = NSMutableAttributedString(string: "")
        mutableStrIniTitle.append(mutableAttrStringPeople)
        mutableStrIniTitle.append(mutableAttrStringMemberNum)
        mutableStrIniTitle.append(mutableAttrStringSlash)
        mutableStrIniTitle.append(mutableAttrStringMemberTotal)
        lblPeopleCount.attributedText = mutableStrIniTitle
        uiviewChatRoom.addSubview(lblPeopleCount)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        cllcviewChatMember = UICollectionView(frame: CGRect(x: 0, y: 282, width: screenWidth, height: 50), collectionViewLayout: layout)
        cllcviewChatMember.dataSource = self
        cllcviewChatMember.delegate = self
        cllcviewChatMember.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MemberCell")
        cllcviewChatMember.backgroundColor = UIColor.white
        cllcviewChatMember.showsHorizontalScrollIndicator = false
        self.uiviewChatRoom.addSubview(cllcviewChatMember)
        
        uiviewChatSpotLine = UIView(frame: CGRect(x: 0, y: 351, width: screenWidth, height: 1))
        uiviewChatSpotLine.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 100)
        self.uiviewChatRoom.addSubview(uiviewChatSpotLine)
        
        let lblDesTitle = UILabel(frame: CGRect(x: 15, y: 363, width: screenWidth, height: 22))
        lblDesTitle.text = "Description"
        lblDesTitle.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1)
        lblDesTitle.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.uiviewChatRoom.addSubview(lblDesTitle)
        
        lblDescriptionText = UILabel()
        lblDescriptionText.lineBreakMode = .byTruncatingTail
        lblDescriptionText.numberOfLines = 0
        lblDescriptionText.text = "Once upon a time there was a ninja fruit, inside the ninja fruit there was a ninja.One day someone ate the fruit and also ate the ninja.The person therefore was never seen again."
        lblDescriptionText.textColor = UIColor(red: 146 / 255, green: 146 / 255, blue: 146 / 255, alpha: 100)
        lblDescriptionText.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.uiviewChatRoom.addSubview(lblDescriptionText)
        uiviewChatRoom.addConstraintsWithFormat("H:|-20-[v0]-20-|", options: [], views: lblDescriptionText)
        uiviewChatRoom.addConstraintsWithFormat("V:|-391-[v0]", options: [], views: lblDescriptionText)
    }
}
