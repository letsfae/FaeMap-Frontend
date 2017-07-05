//
//  PinDetailViewController.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import RealmSwift
import GoogleMaps

/*
 To see the variables defined for this class, check its super class: PinDetailBaseViewController.swift
 */
class PinDetailViewController: PinDetailBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, OpenedPinListViewControllerDelegate, PinTalkTalkCellDelegate, EditPinViewControllerDelegate, SendStickerDelegate, PinFeelingCellDelegate {
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        // modalPresentationStyle defines that this view controller is over the FaeMapViewController,
        // so that user can see the main map via half pin detail view
        modalPresentationStyle = .overCurrentContext
        
        loadPinDetailWindow()
        initPinBasicInfo()
        getSeveralInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch enterMode {
        case .collections:
            checkCurrentUserChosenFeeling()
            break
        case .mainMap:
            animatePinCtrlBtnsAndFeeling()
            break
        }
        
        if boolFromMapBoard {
            btnPinComment.sendActions(for: .touchUpInside)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    // init some basics of a specific pin, like title text, pin icon, etc
    fileprivate func initPinBasicInfo() {
        // add the user id of the owner of this pin to this array for display tab "People"
        arrNonDupUserId = [PinDetailViewController.pinUserId]
        
        switch PinDetailViewController.pinTypeEnum {
        case .comment:
            uiviewNavBar.lblTitle.text = "Comment"
            txtViewInitHeight = 100
            break
        case .media:
            uiviewNavBar.lblTitle.text = "Story"
            txtViewInitHeight = 0
            break
        case .chat_room:
            uiviewNavBar.lblTitle.text = "Chat Spot"
            uiviewFeelingBar.isHidden = true
            break
        case .place:
            break
        }
        
        selectPinIcon()
        checkPinStatus() // check pin status is for social pin
        addObservers() // add input toolbar keyboard observers
    }
    
    // add pull down refresh feature for tblMain (tableView type)
    fileprivate func addPullDownToRefresh() {
        tblMain.addPullRefresh { [unowned self] in
            self.getSeveralInfo()
            
            // unfinished here
            // following line should be called after get pin info
            self.tblMain.stopPullRefreshEver()
        }
    }
    
    // select pin icon display in the very middle of the screen
    // pinState: hot, read, hotRead, normal
    fileprivate func selectPinIcon() {
        guard PinDetailViewController.pinTypeEnum != .place else { return }
        
        let pinState = PinDetailViewController.pinStateEnum
        let pinType = PinDetailViewController.pinTypeEnum
        
        switch pinState {
        case .hot:
            imgPinIcon.image = UIImage(named: "hot\(pinType)PD")
            break
        case .read:
            imgPinIcon.image = UIImage(named: "read\(pinType)PD")
            break
        case .hotRead:
            imgPinIcon.image = UIImage(named: "hotRead\(pinType)PD")
            break
        case .normal:
            imgPinIcon.image = UIImage(named: "normal\(pinType)PD")
            break
        }
    }
    
    // MARK: - Loading Components
    
    // load all the basic components of pin detail view (comment, media, chat_room, place)
    fileprivate func loadPinDetailWindow() {
        
        loadTransparentBtnBackToMap()
        loadFeelingBar()
        
        // uiviewMain is a transparent view to hold the main table
        uiviewMain = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 320))
        uiviewMain.layer.zPosition = 101
        uiviewMain.clipsToBounds = true
        view.addSubview(uiviewMain)
        uiviewMain.frame.origin.y = enterMode == .collections ? 0 : -screenHeight
        
        loadNavigationBar()
        loadPinCtrlButton()
        loadingOtherParts()
        loadTableHeader()
        loadToolBar()
        loadInputToolBar()
        loadChatView()
        
        tblMain.tableHeaderView = PinDetailViewController.pinTypeEnum == .chat_room ? uiviewChatRoom : uiviewTblHeader
        
        loadFromCollections()
        addPullDownToRefresh()
    }
    
    // setup all components to full pin view mode
    fileprivate func loadFromCollections() {
        guard enterMode == .collections else { return }
        
        boolFullPinView = true
        btnGrayBackToMap.isHidden = true
        btnNextPin.isHidden = true
        btnPrevPin.isHidden = true
        btnToFullPin.isHidden = true
        imgPinIcon.isHidden = true
        tblMain.isScrollEnabled = true
        txtviewPinDetail.isScrollEnabled = false
        uiviewFeelingBar.isHidden = true
        uiviewNavBar.rightBtn.isHidden = true
        uiviewToFullDragBtnSub.isHidden = true
        
        // hide input tool bar below the very bottom of the entire screen
        let isChatRoom = PinDetailViewController.pinTypeEnum == .chat_room
        let toolbarHeight = isChatRoom ? 0 : uiviewInputToolBarSub.frame.size.height
        uiviewMain.frame.size.height = screenHeight - toolbarHeight
        tblMain.frame.size.height = screenHeight - 65 - toolbarHeight
        uiviewInputToolBarSub.frame.origin.x = 0
        uiviewInputToolBarSub.frame.origin.y = screenHeight - uiviewInputToolBarSub.frame.size.height
        uiviewTableSub.frame.size.height = screenHeight - 65 - toolbarHeight
        uiviewToFullDragBtnSub.frame.origin.y = screenHeight - toolbarHeight
        
        // calculate the height of txtviewPinDetail based on the current width of it
        // width is assigned according to the device
        let txtViewWidth = txtviewPinDetail.frame.size.width
        guard let font = txtviewPinDetail.font else { return }
        let textViewHeight: CGFloat = txtviewPinDetail.text.height(withConstrainedWidth: txtViewWidth, font: font)
        
        // in media mode,
        // txtviewPinDetail is hidden by setting its height to zero
        // so, add the full height to all components associated with txtviewPinDetail
        //
        // in comment mode,
        // txtviewPinDetail is with height of 100,
        // add the difference of it
        if PinDetailViewController.pinTypeEnum == .media {
            txtviewPinDetail.alpha = 1
            txtviewPinDetail.frame.size.height = textViewHeight
            scrollViewMedia.frame.origin.y += textViewHeight
            uiviewGrayMidBlock.center.y += 65 + textViewHeight
            uiviewInteractBtnSub.center.y += 65 + textViewHeight
            uiviewTblHeader.frame.size.height += 65 + textViewHeight
        } else if PinDetailViewController.pinTypeEnum == .comment && textViewHeight > 100.0 {
            let diffHeight: CGFloat = textViewHeight - 100
            txtviewPinDetail.frame.size.height += diffHeight
            uiviewGrayMidBlock.center.y += diffHeight
            uiviewInteractBtnSub.center.y += diffHeight
            uiviewTblHeader.frame.size.height += diffHeight
        }
    }
    
    // This button is located the very back of all view
    fileprivate func loadTransparentBtnBackToMap() {
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
        guard PinDetailViewController.pinTypeEnum != .place else { return }
        
        let feelingBarAnchor = CGPoint(x: 414 / 2, y: 461)
        
        uiviewFeelingBar = UIView(frame: CGRect(x: 414 / 2, y: 451, w: 0, h: 0))
        view.addSubview(uiviewFeelingBar)
        uiviewFeelingBar.layer.anchorPoint = feelingBarAnchor
        uiviewFeelingBar.layer.cornerRadius = 26 * screenHeightFactor
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
        
        btnPrevPin = UIButton(frame: CGRect(x: 41, y: 503, w: 0, h: 0))
        btnPrevPin.setImage(UIImage(named: "prevPin"), for: UIControlState())
        btnPrevPin.layer.zPosition = 60
        btnPrevPin.layer.shadowColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0).cgColor
        btnPrevPin.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btnPrevPin.layer.shadowOpacity = 0.6
        btnPrevPin.layer.shadowRadius = 3.0
        btnPrevPin.alpha = 0
        btnPrevPin.addTarget(self, action: #selector(self.actionGotoPin(_:)), for: .touchUpInside)
        view.addSubview(btnPrevPin)
        
        btnNextPin = UIButton(frame: CGRect(x: 373, y: 503, w: 0, h: 0))
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
        txtviewPinDetail = UITextView(frame: CGRect(x: 27, y: 75, width: textViewWidth, height: 100))
        txtviewPinDetail.frame.size.height = PinDetailViewController.pinTypeEnum == .media ? 0 : 100
        txtviewPinDetail.alpha = PinDetailViewController.pinTypeEnum == .media ? 0 : 1
        txtviewPinDetail.center.x = screenWidth / 2
        txtviewPinDetail.font = UIFont(name: "AvenirNext-Regular", size: 18)
        txtviewPinDetail.indicatorStyle = UIScrollViewIndicatorStyle.white
        txtviewPinDetail.isEditable = false
        txtviewPinDetail.isScrollEnabled = true
        txtviewPinDetail.isUserInteractionEnabled = true
        txtviewPinDetail.attributedText = strTextViewText.convertStringWithEmoji()
        txtviewPinDetail.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        txtviewPinDetail.textContainerInset = .zero
        uiviewTblHeader.addSubview(txtviewPinDetail)
        
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
        
        // 6/20/17 Vicky
        for i in 0..<5 {
            let imgFeeling = UIImageView(frame: CGRect(x: i * 30, y: 0, width: 27, height: 27))
            imgFeelings.append(imgFeeling)
            uiviewFeelingQuick.addSubview(imgFeelings[i])
        }
        // 6/20/17 Vicky End
        
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
    
    // MARK: - Chat Pin Components
    
    fileprivate func loadChatView() {
        guard PinDetailViewController.pinTypeEnum == .chat_room else { return }
        
        uiviewChatRoom = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 65))
        
        uiviewChatSpotBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 227))
        uiviewChatSpotBar.backgroundColor = UIColor.white
        
        imgChatSpot = FaeImageView(frame: CGRect(x: 0, y: 15, width: 80, height: 80))
        imgChatSpot.center.x = screenWidth / 2
        imgChatSpot.layer.cornerRadius = 40
        imgChatSpot.clipsToBounds = true
        uiviewChatSpotBar.addSubview(imgChatSpot)
        if let chatRoomId = Int(strPinId) {
            imgChatSpot.fileID = chatRoomId
            imgChatSpot.loadImage(id: chatRoomId, isChatRoom: true)
        }
        
        lblChatRoomTitle = UILabel(frame: CGRect(x: 0, y: 107, width: screenWidth, height: 30))
        lblChatRoomTitle.textAlignment = .center
        lblChatRoomTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblChatRoomTitle.textColor = UIColor.faeAppInputTextGrayColor()
        uiviewChatSpotBar.addSubview(lblChatRoomTitle)
        
        lblChatMemberNum = UILabel(frame: CGRect(x: 0, y: 139, width: screenWidth, height: 30))
        lblChatMemberNum.textAlignment = .center
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
        uiviewChatRoom.addSubview(lblPeopleCount)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        cllcviewChatMember = UICollectionView(frame: CGRect(x: 0, y: 282, width: screenWidth, height: 50), collectionViewLayout: layout)
        cllcviewChatMember.dataSource = self
        cllcviewChatMember.delegate = self
        cllcviewChatMember.register(PDChatUserCell.self, forCellWithReuseIdentifier: "pdChatUserCell")
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
        
        lblChatDesc = UILabel()
        lblChatDesc.lineBreakMode = .byTruncatingTail
        lblChatDesc.numberOfLines = 0
        lblChatDesc.textColor = UIColor(red: 146 / 255, green: 146 / 255, blue: 146 / 255, alpha: 100)
        lblChatDesc.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.uiviewChatRoom.addSubview(lblChatDesc)
        uiviewChatRoom.addConstraintsWithFormat("H:|-20-[v0]-20-|", options: [], views: lblChatDesc)
        uiviewChatRoom.addConstraintsWithFormat("V:|-391-[v0]", options: [], views: lblChatDesc)
    }
    
    // MARK: - Place Pin Components
    
    func manageYelpData() {
        lblPlaceTitle.text = PinDetailViewController.strPlaceTitle
        lblPlaceStreet.text = PinDetailViewController.strPlaceStreet
        lblPlaceCity.text = PinDetailViewController.strPlaceCity
        let imageURL = PinDetailViewController.strPlaceImageURL
        imgPlaceQuickView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { _, _, _, _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.imgPlaceQuickView.alpha = 1
            })
        })
    }
    
    func loadPlaceDetail() {
        guard PinDetailViewController.pinTypeEnum == .place else { return }
        
        uiviewPlaceDetail = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 320))
        uiviewPlaceDetail.backgroundColor = UIColor.white
        uiviewMain.addSubview(uiviewPlaceDetail)
        
        uiviewPlacePinBottomLine = UIView(frame: CGRect(x: 0, y: 292, width: screenWidth, height: 1))
        uiviewPlacePinBottomLine.backgroundColor = UIColor(r: 200, g: 199, b: 204, alpha: 100)
        uiviewPlaceDetail.addSubview(uiviewPlacePinBottomLine)
        
        imgPlaceQuickView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 170))
        imgPlaceQuickView.contentMode = .scaleAspectFill
        imgPlaceQuickView.clipsToBounds = true
        uiviewPlaceDetail.addSubview(imgPlaceQuickView)
        imgPlaceQuickView.alpha = 0
        
        imgPlaceType = UIImageView(frame: CGRect(x: 0, y: 128, width: 58, height: 58))
        imgPlaceType.center.x = screenWidth / 2
        imgPlaceType.layer.borderColor = UIColor(r: 225, g: 225, b: 225, alpha: 100).cgColor
        imgPlaceType.layer.borderWidth = 2
        imgPlaceType.layer.cornerRadius = 5
        imgPlaceType.clipsToBounds = true
        imgPlaceType.contentMode = .scaleAspectFit
        uiviewPlaceDetail.addSubview(imgPlaceType)
        imgPlaceType.backgroundColor = UIColor.white
        
        lblPlaceTitle = UILabel(frame: CGRect(x: 0, y: 191, width: screenWidth, height: 27))
        lblPlaceTitle.center.x = screenWidth / 2
        lblPlaceTitle.text = ""
        lblPlaceTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblPlaceTitle.textColor = UIColor.faeAppInputTextGrayColor()
        lblPlaceTitle.textAlignment = .center
        uiviewPlaceDetail.addSubview(lblPlaceTitle)
        
        lblPlaceStreet = UILabel(frame: CGRect(x: 0, y: 221, width: screenWidth, height: 22))
        lblPlaceStreet.center.x = screenWidth / 2
        lblPlaceStreet.text = ""
        lblPlaceStreet.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPlaceStreet.textColor = UIColor.faeAppInputTextGrayColor()
        lblPlaceStreet.textAlignment = .center
        uiviewPlaceDetail.addSubview(lblPlaceStreet)
        
        lblPlaceCity = UILabel(frame: CGRect(x: 0, y: 243, width: screenWidth, height: 22))
        lblPlaceCity.center.x = screenWidth / 2
        lblPlaceCity.text = ""
        lblPlaceCity.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPlaceCity.textColor = UIColor.faeAppInputTextGrayColor()
        lblPlaceCity.textAlignment = .center
        uiviewPlaceDetail.addSubview(lblPlaceCity)
        
        btnGoToPinList_Place = UIButton(frame: CGRect(x: 0, y: 165, width: 53, height: 48))
        btnGoToPinList_Place.setImage(#imageLiteral(resourceName: "pinDetailJumpToOpenedPin"), for: .normal)
        uiviewPlaceDetail.addSubview(btnGoToPinList_Place)
        btnGoToPinList_Place.addTarget(self, action: #selector(self.actionGoToList(_:)), for: .touchUpInside)
        
        btnMoreOptions_Place = UIButton()
        btnMoreOptions_Place.setImage(#imageLiteral(resourceName: "pinDetailMoreOptions"), for: .normal)
        uiviewPlaceDetail.addSubview(btnMoreOptions_Place)
        uiviewPlaceDetail.addConstraintsWithFormat("H:[v0(53)]-0-|", options: [], views: btnMoreOptions_Place)
        uiviewPlaceDetail.addConstraintsWithFormat("V:|-165-[v0(48)]", options: [], views: btnMoreOptions_Place)
        btnMoreOptions_Place.addTarget(self, action: #selector(self.showPinMoreButtonDetails(_:)), for: .touchUpInside)
        
        self.initPlaceBasicInfo()
        self.manageYelpData()
        
        // Pin icon size is slightly different from social pin's icon
        imgPinIcon.frame.size.width = 48
        imgPinIcon.center.x = screenWidth / 2
        imgPinIcon.center.y = 507 * screenHeightFactor
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func initPlaceBasicInfo() {
        switch PinDetailViewController.placeType {
        case "burgers":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinBurger")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailBurger")
            break
        case "pizza":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinPizza")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailPizza")
            break
        case "foodtrucks":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinFoodtruck")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailFoodtruck")
            break
        case "coffee":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinCoffee")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailCoffee")
            break
        case "desserts":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinDesert")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailDesert")
            break
        case "movietheaters":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinCinema")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailCinema")
            break
        case "beautysvc":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinBoutique")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailBoutique")
            break
        case "playgrounds":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinSport")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailSport")
            break
        case "museums":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinArt")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailArt")
            break
        case "juicebars":
            imgPinIcon.image = #imageLiteral(resourceName: "placePinBoba")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailBoba")
            break
        default:
            break
        }
    }
    
    // MARK: - Story Pin Images
    
    func loadMedias() {
        imgMediaArr.removeAll()
        for subview in scrollViewMedia.subviews {
            subview.removeFromSuperview()
        }
        for index in 0..<fileIdArray.count {
            var offset = 105
            var width: CGFloat = 95
            if enterMode == .collections {
                offset = 170
                width = 160
            }
            
            let imageView = FaeImageView(frame: CGRect(x: CGFloat(offset * index), y: 0, width: width, height: width))
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 13.5
            imageView.fileID = fileIdArray[index]
            imageView.loadImage(id: fileIdArray[index])
            imgMediaArr.append(imageView)
            scrollViewMedia.addSubview(imageView)
        }
        if self.enterMode == .collections {
            self.scrollViewMedia.contentSize = CGSize(width: fileIdArray.count * 170 - 10, height: 160)
        } else {
            self.scrollViewMedia.contentSize = CGSize(width: fileIdArray.count * 105 - 10, height: 95)
        }
        
    }
    
    func zoomMedia(_ type: MediaMode) {
        var width = 95
        let space = 10
        if type == .large {
            width = 160
        }
        for index in 0...imgMediaArr.count - 1 {
            UIView.animate(withDuration: 0.5, animations: {
                self.imgMediaArr[index].frame.origin.x = CGFloat((width + space) * index)
                self.imgMediaArr[index].frame.size.width = CGFloat(width)
                self.imgMediaArr[index].frame.size.height = CGFloat(width)
                self.scrollViewMedia.frame.size.height = CGFloat(width)
            })
        }
        self.scrollViewMedia.contentSize = CGSize(width: CGFloat(fileIdArray.count * (width + space) - space), height: CGFloat(width))
    }
    
    // MARK: - More Options
    
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews() {
        if boolOptionsExpanded == true {
            self.hidePinMoreButtonDetails()
        }
    }
    // Show more options button in comment pin detail window
    func showPinMoreButtonDetails(_ sender: UIButton!) {
        self.endEdit()
        if boolOptionsExpanded == false {
            
            btnTransparentClose = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            btnTransparentClose.layer.zPosition = 110
            view.addSubview(btnTransparentClose)
            btnTransparentClose.addTarget(self, action: #selector(self.actionToCloseOtherViews), for: .touchUpInside)
            
            let menuOffset: CGFloat = PinDetailViewController.pinTypeEnum == .place ? 148 : 0
            let buttonHeight: CGFloat = 51
            let buttonWidth: CGFloat = 50
            let buttonY: CGFloat = 97 + menuOffset
            let firstButtonX: CGFloat = 192
            let secondButtonX: CGFloat = 262
            let subviewHeightAfter: CGFloat = 110
            let subviewWidthAfter: CGFloat = 229
            let subviewXAfter: CGFloat = 171
            let subviewXBefore: CGFloat = 400
            let subviewYAfter: CGFloat = (57 + menuOffset)
            let subviewYBefore: CGFloat = (57 + menuOffset)
            let thirdButtonX: CGFloat = 332
            
            uiviewOptionsSub = UIImageView(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
            uiviewOptionsSub.image = #imageLiteral(resourceName: "moreButtonDetailSubview")
            uiviewOptionsSub.layer.zPosition = 111
            view.addSubview(uiviewOptionsSub)
            
            btnShare = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
            btnShare.setImage(#imageLiteral(resourceName: "pinDetailShare"), for: UIControlState())
            btnShare.layer.zPosition = 111
            view.addSubview(btnShare)
            btnShare.clipsToBounds = true
            btnShare.alpha = 0.0
            btnShare.addTarget(self, action: #selector(self.actionShareComment(_:)), for: .touchUpInside)
            
            btnOptionEdit = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
            btnOptionEdit.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: UIControlState())
            btnOptionEdit.layer.zPosition = 111
            view.addSubview(btnOptionEdit)
            btnOptionEdit.clipsToBounds = true
            btnOptionEdit.alpha = 0.0
            btnOptionEdit.addTarget(self, action: #selector(self.actionEditComment(_:)), for: .touchUpInside)
            
            btnCollect = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
            if isSavedByMe {
                btnCollect.setImage(#imageLiteral(resourceName: "pinDetailUnsave"), for: .normal)
            } else {
                btnCollect.setImage(#imageLiteral(resourceName: "pinDetailSave"), for: .normal)
            }
            btnCollect.layer.zPosition = 111
            view.addSubview(btnCollect)
            btnCollect.clipsToBounds = true
            btnCollect.alpha = 0.0
            btnCollect.addTarget(self, action: #selector(self.actionSaveThisPin(_:)), for: .touchUpInside)
            
            btnOptionDelete = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
            btnOptionDelete.setImage(#imageLiteral(resourceName: "pinDetailDelete"), for: UIControlState())
            btnOptionDelete.layer.zPosition = 111
            view.addSubview(btnOptionDelete)
            btnOptionDelete.clipsToBounds = true
            btnOptionDelete.alpha = 0.0
            btnOptionDelete.addTarget(self, action: #selector(self.actionDeleteThisPin(_:)), for: .touchUpInside)
            
            btnReport = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
            btnReport.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: UIControlState())
            btnReport.layer.zPosition = 111
            view.addSubview(btnReport)
            btnReport.clipsToBounds = true
            btnReport.alpha = 0.0
            btnReport.addTarget(self, action: #selector(self.actionReportThisPin), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.25, animations: ({
                self.uiviewOptionsSub.frame = CGRect(x: subviewXAfter, y: subviewYAfter, w: subviewWidthAfter, h: subviewHeightAfter)
                self.btnShare.frame = CGRect(x: firstButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
                self.btnOptionEdit.frame = CGRect(x: secondButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
                self.btnCollect.frame = CGRect(x: secondButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
                self.btnOptionDelete.frame = CGRect(x: thirdButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
                self.btnReport.frame = CGRect(x: thirdButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
                if self.boolMyPin == true {
                    self.btnOptionEdit.alpha = 1.0
                    self.btnOptionDelete.alpha = 1.0
                } else {
                    self.btnCollect.alpha = 1.0
                    self.btnReport.alpha = 1.0
                }
                self.btnShare.alpha = 1.0
            }))
            boolOptionsExpanded = true
        } else {
            self.hidePinMoreButtonDetails()
        }
    }
    
    // Hide comment pin more options' button
    fileprivate func hidePinMoreButtonDetails() {
        boolOptionsExpanded = false
        var menuOffset: CGFloat = 0
        if PinDetailViewController.pinTypeEnum == .place {
            menuOffset = 148
        }
        let subviewXBefore: CGFloat = 400
        let subviewYBefore: CGFloat = (57 + menuOffset)
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewOptionsSub.frame = CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0)
            self.btnShare.frame = CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0)
            self.btnOptionEdit.frame = CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0)
            self.btnCollect.frame = CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0)
            self.btnOptionDelete.frame = CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0)
            self.btnReport.frame = CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0)
            self.btnShare.alpha = 0.0
            self.btnOptionEdit.alpha = 0.0
            self.btnCollect.alpha = 0.0
            self.btnOptionDelete.alpha = 0.0
            self.btnReport.alpha = 0.0
        }))
        btnTransparentClose.removeFromSuperview()
    }
    
    // When clicking share button in comment pin detail window's more options button
    func actionShareComment(_ sender: UIButton) {
        self.actionToCloseOtherViews()
        print("Share Clicks!")
    }
    
    func actionEditComment(_ sender: UIButton) {
        if strPinId == "-1" {
            return
        }
        self.isKeyboardInThisView = false
        let vcEditPin = EditPinViewController()
        vcEditPin.zoomLevel = zoomLevel
        vcEditPin.delegate = self
        vcEditPin.previousCommentContent = self.strCurrentTxt
        vcEditPin.pinID = "\(self.strPinId)"
        vcEditPin.pinMediaImageArray = imgMediaArr
        vcEditPin.pinGeoLocation = CLLocationCoordinate2D(latitude: PinDetailViewController.selectedMarkerPosition.latitude, longitude: PinDetailViewController.selectedMarkerPosition.longitude)
        vcEditPin.editPinMode = PinDetailViewController.pinTypeEnum
        vcEditPin.pinType = "\(PinDetailViewController.pinTypeEnum)"
        vcEditPin.mediaIdArray = fileIdArray
        self.present(vcEditPin, animated: true, completion: nil)
        actionToCloseOtherViews()
    }
    
    func actionReportThisPin() {
        let reportPinVC = ReportCommentPinViewController()
        reportPinVC.reportType = 0
        self.isKeyboardInThisView = false
        self.present(reportPinVC, animated: true, completion: nil)
        actionToCloseOtherViews()
    }
    
    func actionDeleteThisPin(_ sender: UIButton) {
        if strPinId == "-1" {
            return
        }
        let alertController = UIAlertController(title: "Delete Pin", message: "This Pin will be deleted on the map and in mapboards. All the comments and replies will also be removed.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_: UIAlertAction) -> Void in
            print("Delete")
            let deleteCommentPin = FaePinAction()
            deleteCommentPin.deletePinById(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) { (status: Int, _: Any?) in
                if status / 100 == 2 {
                    print("Successfully delete pin")
                    self.actionBackToMap(self.uiviewNavBar.leftBtn)
                    self.delegate?.backToMainMap()
                } else {
                    print("Fail to delete comment")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (_: UIAlertAction) -> Void in
            print("Cancel Deleting")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
        actionToCloseOtherViews()
    }
    
    // When clicking save button in comment pin detail window's more options button
    func actionSaveThisPin(_ sender: UIButton) {
        if isSavedByMe {
            self.unsaveThisPin()
        } else {
            self.saveThisPin()
        }
        self.actionToCloseOtherViews()
    }
    
    // MARK: - Actions
    
    func actionGotoPin(_ sender: UIButton) {
        if PinDetailViewController.pinTypeEnum == .place {
            if sender == btnPrevPin {
                self.delegate?.goTo(nextPin: false)
            } else {
                self.delegate?.goTo(nextPin: true)
            }
            self.initPlaceBasicInfo()
            self.manageYelpData()
        }
    }
    
    func actionDoAnony() {
        switchAnony.setOn(!switchAnony.isOn, animated: true)
    }
    
    // Animation of the red sliding line (Talk Talk, Feelings, People)
    func animationRedSlidingLine(_ sender: UIButton) {
        if sender == btnTalkTalk {
            tableMode = .talktalk
            tblMain.reloadData()
            UIView.animate(withDuration: 0.3, animations: {
                self.uiviewMain.frame.size.height = screenHeight - self.uiviewInputToolBarSub.frame.size.height
            })
        } else if sender == btnFeelings {
            tableMode = .feelings
            tblMain.reloadData()
            tblMain.layoutIfNeeded()
            tblMain.setContentOffset(CGPoint.zero, animated: false)
            uiviewMain.frame.size.height = screenHeight
        } else if sender == btnPeople {
            tableMode = .people
            tblMain.reloadData()
            // Vicky 06/22/17
            tblMain.layoutIfNeeded()
            tblMain.setContentOffset(CGPoint.zero, animated: false)
            //            tblMain.contentOffset.y = 0
            // Vicky 06/22/17 End
            uiviewMain.frame.size.height = screenHeight
        }
        self.endEdit()
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewRedSlidingLine.center.x = sender.center.x
        }), completion: nil)
    }
    
    func endEdit() {
        textViewInput.endEditing(true)
        textViewInput.resignFirstResponder()
        boolKeyboardShowed = false
        self.emojiView.tag = 0
        if btnPinComment.tag == 1 || btnToFullPin.tag == 1 {
            UIView.animate(withDuration: 0.3, animations: ({
                self.emojiView.frame.origin.y = screenHeight
                if self.uiviewAnonymous.isHidden {
                    if self.tableMode == .talktalk {
                        self.uiviewMain.frame.size.height = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                        self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height
                        self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                        self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                        self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                    } else {
                        self.uiviewMain.frame.size.height = screenHeight
                        self.tblMain.frame.size.height = screenHeight - 65
                        self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight
                        self.uiviewInputToolBarSub.frame.origin.y = screenHeight
                        self.uiviewAnonymous.frame.origin.y = screenHeight
                    }
                } else {
                    if self.tableMode == .talktalk {
                        self.uiviewMain.frame.size.height = screenHeight - 51
                        self.tblMain.frame.size.height = screenHeight - 65 - 51
                        self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - 51
                        self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                        self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                    } else {
                        self.uiviewMain.frame.size.height = screenHeight
                        self.tblMain.frame.size.height = screenHeight - 65
                        self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight
                        self.uiviewInputToolBarSub.frame.origin.y = screenHeight
                        self.uiviewAnonymous.frame.origin.y = screenHeight
                    }
                }
            }), completion: { _ in
                if self.tableMode == .feelings {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tblMain.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        if PinDetailViewController.pinTypeEnum == .chat_room {
            return
        }
        self.endEdit()
    }
    
    func actionShowHideAnony(_ sender: UIButton) {
        if sender == btnCommentOption {
            self.tblMain.frame.size.height = screenHeight - 65 - 51 - keyboardHeight
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - 51 - keyboardHeight
            uiviewAnonymous.isHidden = false
            uiviewInputToolBarSub.isHidden = true
        } else if sender == btnHideAnony {
            self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height - keyboardHeight
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - keyboardHeight
            uiviewAnonymous.isHidden = true
            uiviewInputToolBarSub.isHidden = false
        }
    }
    
    func actionSwitchKeyboard(_ sender: UIButton) {
        if emojiView.tag == 1 {
            textViewInput.becomeFirstResponder()
            directReplyFromUser = false
            boolKeyboardShowed = true
            self.actionHideEmojiView()
        } else {
            textViewInput.resignFirstResponder()
            boolKeyboardShowed = false
            self.actionShowEmojiView()
        }
    }
    
    func actionShowEmojiView() {
        boolStickerShowed = true
        btnShowSticker.setImage(#imageLiteral(resourceName: "stickerChosen"), for: .normal)
        self.emojiView.tag = 1
        UIView.animate(withDuration: 0.3) {
            self.emojiView.frame.origin.y = screenHeight - 271
            self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height - 271
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - 271
            self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - 271
        }
    }
    
    func actionHideEmojiView() {
        boolStickerShowed = false
        btnShowSticker.setImage(#imageLiteral(resourceName: "sticker"), for: .normal)
        self.emojiView.tag = 0
        UIView.animate(withDuration: 0.3) {
            self.emojiView.frame.origin.y = screenHeight
        }
    }
    
    func actionLikeThisPin(_ sender: UIButton) {
        self.endEdit()
        
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
        }
        
        if sender.tag == 1 && self.strPinId != "-999" {
            btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: UIControlState())
            if animatingHeart != nil {
                animatingHeart.image = nil
            }
            self.unlikeThisPin()
            print("debug animating sender.tag 1")
            print(sender.tag)
            sender.tag = 0
            return
        }
        
        if sender.tag == 0 && self.strPinId != "-999" {
            btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
            self.animateHeart()
            self.likeThisPin()
            print("debug animating sender.tag 0")
            print(sender.tag)
            sender.tag = 1
        }
    }
    
    func actionHoldingLikeButton(_ sender: UIButton) {
        self.endEdit()
        btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
        animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.animateHeart), userInfo: nil, repeats: true)
    }
    
    // Back to pin list window when in detail window
    func actionGoToList(_ sender: UIButton!) {
        self.endEdit()
        if backJustOnce == true {
            backJustOnce = false
            let openedPinListVC = OpenedPinListViewController()
            openedPinListVC.delegate = self
            openedPinListVC.modalPresentationStyle = .overCurrentContext
            btnPrevPin.isHidden = true
            btnNextPin.isHidden = true
            imgPinIcon.isHidden = true
            btnGrayBackToMap.isHidden = true
            self.present(openedPinListVC, animated: false, completion: {
                self.uiviewMain.frame.origin.y -= screenHeight
            })
        }
    }
    
    func actionBackToMap(_ sender: UIButton) {
        self.endEdit()
        if enterMode == .collections {
            guard let likes = lblPinLikeCount.text else { return }
            guard let comments = lblCommentCount.text else { return }
            self.boolPinLiked = btnPinLike.currentImage == #imageLiteral(resourceName: "pinDetailLikeHeartFull")
            let isLiked = self.boolPinLiked
            // Vicky 06/20/17
            var feelings = [Int]()
            for i in 0..<feelingArray.count {
                if feelingArray[i] != 0 {
                    feelings.append(i)
                }
            }
            self.colDelegate?.backToCollections(likeCount: likes, commentCount: comments, pinLikeStatus: isLiked, feelingArray: feelings)
            // Vicky 06/20/17 End
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.delegate?.backToMainMap()
        if PinDetailViewController.pinTypeEnum != .place {
            UIView.animate(withDuration: 0.2) {
                self.uiviewFeelingBar.frame = CGRect(x: 414 / 2, y: 451, w: 0, h: 0)
                for btn in self.btnFeelingArray {
                    btn.frame = CGRect.zero
                }
                self.btnPrevPin.frame = CGRect(x: 41, y: 503, w: 0, h: 0)
                self.btnNextPin.frame = CGRect(x: 373, y: 503, w: 0, h: 0)
            }
        }
        UIView.animate(withDuration: 0.5, animations: ({
            self.uiviewMain.center.y -= screenHeight
            self.btnGrayBackToMap.alpha = 0
            self.imgPinIcon.alpha = 0
            self.btnPrevPin.alpha = 0
            self.btnNextPin.alpha = 0
        }), completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // When clicking reply button in pin detail window
    func actionReplyToThisPin(_ sender: UIButton) {
        
        // Back to half pin view
        if sender.tag == 1 && sender != btnPinComment {
            self.endEdit()
            boolFullPinView = false
            btnPinComment.tag = 0
            btnToFullPin.tag = 0
            lblTxtPlaceholder.text = "Write a Comment..."
            strReplyTo = ""
            
            uiviewNavBar.leftBtn.tag = 1
            tblMain.setContentOffset(CGPoint.zero, animated: true)
            
            UIView.animate(withDuration: 0.5, animations: ({
                self.btnHalfPinToMap.alpha = 1.0 // nav bar left btn
                self.uiviewNavBar.leftBtn.alpha = 0.0 // nav bar left btn
                self.txtviewPinDetail.frame.size.height = 100 // back to original text height
                
                self.uiviewInteractBtnSub.frame.origin.y = 185
                self.uiviewGrayMidBlock.frame.origin.y = 227
                self.uiviewTableSub.frame.size.height = 255
                self.uiviewTblHeader.frame.size.height = 239
                self.uiviewToFullDragBtnSub.frame.origin.y = 292
                self.uiviewMain.frame.size.height = 320
                self.uiviewInputToolBarSub.frame.origin.y = screenHeight
            }), completion: { _ in
                self.txtviewPinDetail.isScrollEnabled = true
                self.tblMain.isScrollEnabled = false
                self.tblMain.frame.size.height = 227
            })
            // deal with diff UI according to pinType
            if PinDetailViewController.pinTypeEnum == .media {
                self.zoomMedia(.small)
                UIView.animate(withDuration: 0.5, animations: ({
                    self.scrollViewMedia.frame.origin.y = 80
                    self.txtviewPinDetail.alpha = 0
                }), completion: nil)
            }
            return
        }
        /*
         -------------------- Below is to Full Pin View --------------------
         */
        boolFullPinView = true
        if sender.tag == 1 && sender == btnPinComment {
            self.boolKeyboardShowed = true
            self.directReplyFromUser = false
            self.lblTxtPlaceholder.text = "Write a Comment..."
            self.strReplyTo = ""
            self.textViewInput.becomeFirstResponder()
            return
        }
        sender.tag = 1
        let textViewHeight: CGFloat = txtviewPinDetail.contentSize.height
        if btnToFullPin.tag == 1 && sender == btnPinComment {
            boolKeyboardShowed = true
            directReplyFromUser = false
            lblTxtPlaceholder.text = "Write a Comment..."
            strReplyTo = ""
            textViewInput.becomeFirstResponder()
            return
        }
        self.readThisPin()
        txtviewPinDetail.isScrollEnabled = false
        tblMain.isScrollEnabled = true
        if PinDetailViewController.pinTypeEnum == .media {
            self.zoomMedia(.large)
            UIView.animate(withDuration: 0.5, animations: ({
                self.txtviewPinDetail.alpha = 1
                self.scrollViewMedia.frame.origin.y += textViewHeight
                self.txtviewPinDetail.frame.size.height = textViewHeight
                self.uiviewGrayMidBlock.center.y += 65 + textViewHeight
                self.uiviewInteractBtnSub.center.y += 65 + textViewHeight
                self.uiviewTblHeader.frame.size.height += 65 + textViewHeight
            }), completion: nil)
            self.scrollViewMedia.scrollToLeft(animated: true)
        } else if PinDetailViewController.pinTypeEnum == .comment && textViewHeight > 100.0 {
            let diffHeight: CGFloat = textViewHeight - 100
            UIView.animate(withDuration: 0.5, animations: ({
                self.uiviewTblHeader.frame.size.height += diffHeight
                self.txtviewPinDetail.frame.size.height += diffHeight
                self.uiviewGrayMidBlock.center.y += diffHeight
                self.uiviewInteractBtnSub.center.y += diffHeight
            }), completion: nil)
        }
        UIView.animate(withDuration: 0.5, animations: ({
            self.btnHalfPinToMap.alpha = 0.0
            self.uiviewNavBar.leftBtn.alpha = 1.0
            let toolbarHeight = PinDetailViewController.pinTypeEnum == .chat_room ? 0 : self.uiviewInputToolBarSub.frame.size.height
            self.tblMain.frame.size.height = screenHeight - 65 - toolbarHeight
            self.uiviewInputToolBarSub.frame.origin.y = screenHeight - toolbarHeight
            self.uiviewMain.frame.size.height = screenHeight - toolbarHeight
            self.uiviewTableSub.frame.size.height = screenHeight - 65 - toolbarHeight
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - toolbarHeight
        }), completion: { _ in
            if PinDetailViewController.pinTypeEnum != .chat_room {
                self.tblMain.reloadData()
                if sender == self.btnPinComment {
                    self.textViewInput.becomeFirstResponder()
                    self.directReplyFromUser = false
                    self.boolKeyboardShowed = true
                }
            }
        })
    }
    
    func handleFeelingPanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: uiviewFeelingBar)
        
        if location.y < 0 || location.y > 52 * screenWidthFactor {
            if btnSelectedFeeling != nil {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    let yAxis: CGFloat = 11
                    let width: CGFloat = 32
                    self.btnSelectedFeeling?.frame = CGRect(x: CGFloat(20 + 52 * self.previousIndex), y: yAxis, w: width, h: width)
                }, completion: nil)
            }
            return
        }
        
        let index = Int((location.x - 20 * screenWidthFactor) / 52 * screenWidthFactor)
        
        if index > 4 || index < 0 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let yAxis: CGFloat = 11
                let width: CGFloat = 32
                self.btnSelectedFeeling?.frame = CGRect(x: CGFloat(20 + 52 * self.previousIndex), y: yAxis, w: width, h: width)
            }, completion: nil)
            return
        }
        
        let button = btnFeelingArray[index]
        
        if btnSelectedFeeling != button {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let yAxis: CGFloat = 11
                let width: CGFloat = 32
                self.btnSelectedFeeling?.frame = CGRect(x: CGFloat(20 + 52 * self.previousIndex), y: yAxis, w: width, h: width)
            }, completion: nil)
        }
        
        btnSelectedFeeling = button
        previousIndex = index
        
        uiviewFeelingBar.bringSubview(toFront: button)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let yAxis: CGFloat = -19
            let width: CGFloat = 46
            button.frame = CGRect(x: CGFloat(13 + 52 * index), y: yAxis, w: width, h: width)
        }, completion: nil)
        
        if gesture.state == .ended {
            if index == intChosenFeeling {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    let yAxis: CGFloat = 3
                    let width: CGFloat = 46
                    button.frame = CGRect(x: CGFloat(13 + 52 * index), y: yAxis, w: width, h: width)
                }, completion: nil)
                return
            }
            self.postFeeling(button)
        }
    }
    
    // MARK: - API Calls
    
    // get info of social pin, this func is not for place pin
    fileprivate func getSeveralInfo() {
        if PinDetailViewController.pinTypeEnum != .chat_room {
            getPinAttributeNum()
            getPinInfo()
            getPinComments(sendMessageFlag: false)
        } else {
            getChatRoomInfo()
        }
    }
    
    func getChatRoomInfo() {
        
        guard PinDetailViewController.pinTypeEnum == .chat_room else { return }
        
        guard strPinId != "-1" else { return }
        
        let getChat = FaeMap()
        getChat.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) { (status: Int, message: Any?) in
            
            guard status / 100 == 2 else {
                print("[getChat] fail")
                return
            }
            guard let unwrapMessage = message else { return }
            let chatJSON = JSON(unwrapMessage)
            print(chatJSON["user_id"].intValue)
            self.lblChatRoomTitle.text = chatJSON["title"].stringValue
            let memberCount = chatJSON["members"].arrayValue.count
            let capacity = chatJSON["capacity"].intValue
            self.lblChatMemberNum.text = memberCount == 1 ? "1 Member" : "\(memberCount) Members"
            self.lblChatDesc.text = chatJSON["description"].stringValue
            
            self.chatRoomUserIds.removeAll()
            let userIds = chatJSON["members"].arrayValue.map({ $0.intValue })
            for userId in userIds {
                self.chatRoomUserIds.append(userId)
            }
            
            let stylePeople = [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(),
                               NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
            
            let styleMemNum = [NSForegroundColorAttributeName: UIColor.faeAppRedColor(),
                               NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
            let styleMemTotal = [NSForegroundColorAttributeName: UIColor.faeAppInputPlaceholderGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
            
            let attrStrPeople = NSMutableAttributedString(string: "People  ", attributes: stylePeople)
            let attrStrMemCount = NSMutableAttributedString(string: "\(memberCount)", attributes: styleMemNum)
            let attrStrSlash = NSMutableAttributedString(string: "/", attributes: styleMemTotal)
            let attrStrMemTotal = NSMutableAttributedString(string: "\(capacity)", attributes: styleMemTotal)
            
            let attrStr = NSMutableAttributedString(string: "")
            attrStr.append(attrStrPeople)
            attrStr.append(attrStrMemCount)
            attrStr.append(attrStrSlash)
            attrStr.append(attrStrMemTotal)
            self.lblPeopleCount.attributedText = attrStr
            
            self.cllcviewChatMember.reloadData()
        }
    }
    
    func getPinInfo() {
        guard strPinId != "-1" else { return }
        
        // Cache the current user's profile pic and use it when current user post a feeling
        // The small size (20x20) of it will be displayed at the right bottom corner of the feeling table
        if user_id != -1 {
            General.shared.avatar(userid: user_id, completion: { avatarImage in
                self.imgCurUserAvatar = avatarImage
            })
        }
        
        let getPinById = FaeMap()
        getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) { (_: Int, message: Any?) in
            let pinInfoJSON = JSON(message!)
            // Time
            self.lblPinDate.text = pinInfoJSON["created_at"].stringValue.formatFaeDate()
            // Check if pin is mine
            if let userid = pinInfoJSON["user_id"].int {
                if userid == Int(user_id) {
                    self.boolMyPin = true
                } else {
                    self.boolMyPin = false
                }
            }
            // Feelings
            self.feelingArray.removeAll()
            
            var feelingCount = 0
            let feelings = pinInfoJSON["feeling_count"].arrayValue.map({ Int($0.stringValue) })
            for feeling in feelings {
                if feeling != nil {
                    self.feelingArray.append(feeling!)
                    feelingCount += feeling!
                }
            }
            let attri_0 = [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(),
                           NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
            let attri_1 = [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(),
                           NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 14)!]
            let attr_0 = NSMutableAttributedString(string: "Feelings  ", attributes: attri_0)
            let attr_1 = NSMutableAttributedString(string: "\(feelingCount)", attributes: attri_1)
            let attr = NSMutableAttributedString(string: "")
            attr.append(attr_0)
            attr.append(attr_1)
            self.lblFeelings.attributedText = attr
            
            if self.tableMode == .feelings {
                self.tblMain.reloadData()
            }
            // QuickView is the middle line of pin detail, displayed the chosen feeling the all users have posted
            self.loadFeelingQuickView()
            
            // Images of story pin
            if PinDetailViewController.pinTypeEnum == .media {
                self.fileIdArray.removeAll()
                let fileIDs = pinInfoJSON["file_ids"].arrayValue.map({ Int($0.stringValue) })
                for fileID in fileIDs {
                    if fileID != nil {
                        self.fileIdArray.append(fileID!)
                    }
                }
                // Use separate func to load pictures in a scrollView
                self.loadMedias()
                self.strCurrentTxt = pinInfoJSON["description"].stringValue
                if self.enterMode != .collections {
                    self.txtviewPinDetail.attributedText = self.strCurrentTxt.convertStringWithEmoji()
                }
            } else if PinDetailViewController.pinTypeEnum == .comment {
                self.strCurrentTxt = pinInfoJSON["content"].stringValue
                self.txtviewPinDetail.attributedText = self.strCurrentTxt.convertStringWithEmoji()
            }
            
            // Liked or not
            if !pinInfoJSON["user_pin_operations"]["is_liked"].boolValue {
                self.btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: UIControlState())
                self.btnPinLike.tag = 0
                if self.animatingHeart != nil {
                    self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollow")
                }
            } else {
                self.btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
                self.btnPinLike.tag = 1
                if self.animatingHeart != nil {
                    self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
                }
            }
            // Saved or not
            if !pinInfoJSON["user_pin_operations"]["is_saved"].boolValue {
                self.isSavedByMe = false
                self.imgCollected.image = #imageLiteral(resourceName: "pinUnsaved")
            } else {
                self.isSavedByMe = true
                self.imgCollected.image = #imageLiteral(resourceName: "pinSaved")
            }
            // Get nick name
            let commentCount = pinInfoJSON["comment_count"].intValue
            let anonymous = pinInfoJSON["anonymous"].boolValue
            if anonymous {
                self.lblPinDisplayName.text = "Someone"
                self.isAnonymous = true
                self.arrNonDupUserId.removeFirst()
            } else {
                self.lblPinDisplayName.text = pinInfoJSON["nick_name"].stringValue
                // Get avatar
                General.shared.avatar(userid: pinInfoJSON["user_id"].intValue, completion: { avatarImage in
                    self.imgPinUserAvatar.image = avatarImage
                    UIView.animate(withDuration: 0.2, animations: {
                        self.imgPinUserAvatar.alpha = 1
                    })
                })
            }
            let peopleCount = self.isAnonymous ? commentCount : commentCount + 1
            let attr_2 = NSMutableAttributedString(string: "People  ", attributes: attri_0)
            let attr_3 = NSMutableAttributedString(string: "\(peopleCount)", attributes: attri_1)
            let attributedText = NSMutableAttributedString(string: "")
            attributedText.append(attr_2)
            attributedText.append(attr_3)
            self.lblPeople.attributedText = attributedText
        }
    }
    
    func postFeeling(_ sender: UIButton) {
        if sender.tag == intChosenFeeling {
            self.deleteFeeling()
            intChosenFeeling = -1
            return
        }
        intChosenFeeling = sender.tag
        let postFeeling = FaePinAction()
        postFeeling.whereKey("feeling", value: "\(sender.tag)")
        postFeeling.postFeelingToPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { status, message in
            if status / 100 != 2 {
                return
            }
            UIView.animate(withDuration: 0.2, animations: {
                let yAxis: CGFloat = 11
                let width: CGFloat = 32
                for i in 0..<self.btnFeelingArray.count {
                    self.btnFeelingArray[i].frame = CGRect(x: CGFloat(20 + 52 * i), y: yAxis, w: width, h: width)
                }
                if sender.tag < 5 {
                    let xOffset = CGFloat(sender.tag * 52 + 13)
                    self.btnFeelingArray[sender.tag].frame = CGRect(x: xOffset, y: 3, w: 46, h: 46)
                }
            })
            
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) { (_: Int, message: Any?) in
                let pinInfoJSON = JSON(message!)
                self.feelingArray.removeAll()
                var feelingCount = 0
                let feelings = pinInfoJSON["feeling_count"].arrayValue.map({ Int($0.stringValue) })
                for feeling in feelings {
                    if feeling != nil {
                        self.feelingArray.append(feeling!)
                        feelingCount += feeling!
                    }
                }
                let attri_0 = [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(),
                               NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
                let attri_1 = [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(),
                               NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 14)!]
                
                let attr_0 = NSMutableAttributedString(string: "Feelings  ", attributes: attri_0)
                let attr_1 = NSMutableAttributedString(string: "\(feelingCount)", attributes: attri_1)
                let attr = NSMutableAttributedString(string: "")
                attr.append(attr_0)
                attr.append(attr_1)
                self.lblFeelings.attributedText = attr
                
                if self.tableMode == .feelings && self.boolFullPinView {
                    self.tblMain.reloadData()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tblMain.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                self.loadFeelingQuickView()
            }
        }
    }
    
    func deleteFeeling() {
        UIView.animate(withDuration: 0.2, animations: {
            self.btnFeelingBar_01.frame = CGRect(x: 20, y: 11, w: 32, h: 32)
            self.btnFeelingBar_02.frame = CGRect(x: 72, y: 11, w: 32, h: 32)
            self.btnFeelingBar_03.frame = CGRect(x: 124, y: 11, w: 32, h: 32)
            self.btnFeelingBar_04.frame = CGRect(x: 176, y: 11, w: 32, h: 32)
            self.btnFeelingBar_05.frame = CGRect(x: 228, y: 11, w: 32, h: 32)
        })
        let deleteFeeling = FaePinAction()
        deleteFeeling.deleteFeeling("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { status, message in
            if status / 100 != 2 {
                return
            }
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) { (_: Int, message: Any?) in
                let pinInfoJSON = JSON(message!)
                self.feelingArray.removeAll()
                let feelings = pinInfoJSON["feeling_count"].arrayValue.map({ Int($0.stringValue) })
                for feeling in feelings {
                    if feeling != nil {
                        self.feelingArray.append(feeling!)
                    }
                }
                if self.tableMode == .feelings {
                    self.tblMain.reloadData()
                }
                self.loadFeelingQuickView()
            }
        }
    }
    
    func loadFeelingQuickView() {
        var feelings = [Int]()
        for i in 0..<feelingArray.count {
            if feelingArray[i] != 0 {
                feelings.append(i)
            }
        }
        
        let feelingCount = feelings.count <= 5 ? feelings.count : 5
        
        for i in 0..<feelingCount {
            imgFeelings[i].image = feelings[i] >= 9 ?
                UIImage(named: "pdFeeling_\(feelings[i] + 1)-1") :
                UIImage(named: "pdFeeling_0\(feelings[i] + 1)-1")
        }
        
        for i in feelingCount..<5 {
            imgFeelings[i].image = nil
        }
    }
    
    func getPinAttributeNum() {
        if strPinId == "-1" {
            return
        }
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            let mapInfoJSON = JSON(message!)
            let likesCount = mapInfoJSON["likes"].intValue
            self.lblPinLikeCount.text = "\(likesCount)"
            let commentsCount = mapInfoJSON["comments"].intValue
            self.lblCommentCount.text = "\(commentsCount)"
            
            let attri_0 = [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(),
                           NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
            let attri_1 = [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(),
                           NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 14)!]
            
            let attr_0 = NSMutableAttributedString(string: "Talk Talk  ", attributes: attri_0)
            let attr_1 = NSMutableAttributedString(string: "\(commentsCount)", attributes: attri_1)
            let attr = NSMutableAttributedString(string: "")
            attr.append(attr_0)
            attr.append(attr_1)
            self.lblTalkTalk.attributedText = attr
            
            if likesCount >= 15 || commentsCount >= 10 {
                self.imgHotPin.isHidden = false
                if PinDetailViewController.pinStatus == "read" || PinDetailViewController.pinStatus == "hot and read" {
                    PinDetailViewController.pinStatus = "hot and read"
                    PinDetailViewController.pinStateEnum = .hotRead
                } else {
                    PinDetailViewController.pinStatus = "hot"
                    PinDetailViewController.pinStateEnum = .hot
                }
                self.selectPinIcon()
                self.delegate?.changeIconImage()
            } else {
                self.imgHotPin.isHidden = true
            }
        }
    }
    
    func getPinComments(sendMessageFlag: Bool) {
        if strPinId == "-1" {
            return
        }
        pinComments.removeAll()
        let getPinComments = FaePinAction()
        getPinComments.getPinComments("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, message: Any?) in
            if status / 100 != 2 {
                print("[getPinComments] fail to get pin comments")
                return
            }
            let commentsJSON = JSON(message!)
            guard let pinCommentJsonArray = commentsJSON.array else {
                print("[getPinComments] fail to parse pin comments")
                return
            }
            self.pinComments = pinCommentJsonArray.map { PinComment(json: $0) }
            self.pinComments.reverse()
            
            // Processing anonymous
            var anonyCount = 1
            for i in 0..<self.pinComments.count {
                let pinComment = self.pinComments[i]
                if pinComment.anonymous && self.dictAnonymous[pinComment.userId] == nil {
                    self.dictAnonymous[pinComment.userId] = "Anonymous \(anonyCount)"
                    anonyCount += 1
                }
            }
            // End
            
            self.tblMain.reloadData()
            
            guard self.pinComments.count >= 1 else { return }
            for comment in self.pinComments {
                if self.arrNonDupUserId.contains(comment.userId) {
                    continue
                }
                self.arrNonDupUserId.append(comment.userId)
            }
            if sendMessageFlag {
                let indexPath = IndexPath(row: self.pinComments.count - 1, section: 0)
                self.tblMain.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func getLastComment() {
        if strPinId == "-1" {
            return
        }
        
        let getPinComments = FaePinAction()
        getPinComments.getPinComments("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, message: Any?) in
            if status / 100 != 2 {
                print("[getLastComment] fail to get pin comments")
                return
            }
            let commentsJSON = JSON(message!)
            guard let pinCommentJsonArray = commentsJSON.array else {
                print("[getLastComment] fail to parse pin comments - 1")
                return
            }
            guard let lastCommentJSON = pinCommentJsonArray.first else {
                print("[getLastComment] fail to parse pin comments - 2")
                return
            }
            let lastComment = PinComment(json: lastCommentJSON)
            self.pinComments.append(lastComment)
            
            // Processing anonymous
            let anonyCount = self.dictAnonymous.count + 1
            if lastComment.anonymous && self.dictAnonymous[lastComment.userId] == nil {
                self.dictAnonymous[lastComment.userId] = "Anonymous \(anonyCount)"
            }
            
            self.tblMain.reloadData()
            
            if !lastComment.anonymous {
                let userid = lastComment.userId
                self.userNameCard(userid, self.pinComments.count - 1, completion: { id, _ in
                    if id != 0 {
                        
                    }
                })
                
            }
            
            let indexPath = IndexPath(row: self.pinComments.count - 1, section: 0)
            self.tblMain.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    fileprivate func userNameCard(_ userid: Int, _ index: Int, completion: @escaping (Int, Int) -> Void) {
        let getUser = FaeUser()
        getUser.getUserCard("\(userid)", completion: { status, message in
            if status / 100 != 2 {
                print("[userNameCard] fail to get user")
            } else {
                
                let userJSON = JSON(message!)
                
                if index != -1 {
                    let displayName = userJSON["nick_name"].stringValue
                    self.pinComments[index].displayName = displayName
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tblMain.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
                
                var userDetail = PinDetailUser(json: userJSON)
                userDetail.userId = userid
                if self.pinDetailUsers.contains(userDetail) {
                    print("[userNameCard], exists this user")
                    completion(0, 0)
                } else {
                    self.pinDetailUsers.append(userDetail)
                    guard let userIndex = self.pinDetailUsers.index(of: userDetail) else { return }
                    completion(userid, userIndex)
                }
            }
            if index != -1 && index == self.pinComments.count - 1 {
                print("[index != -1 && index == self.pinComments.count - 1]")
                let peopleCount = self.pinDetailUsers.count
                let attri_0 = [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(),
                               NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
                let attri_1 = [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(),
                               NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 14)!]
                let attr_0 = NSMutableAttributedString(string: "People  ", attributes: attri_0)
                let attr_1 = NSMutableAttributedString(string: "\(peopleCount)", attributes: attri_1)
                let attr = NSMutableAttributedString(string: "")
                attr.append(attr_0)
                attr.append(attr_1)
                self.lblPeople.attributedText = attr
            }
        })
    }
    
    func checkPinStatus() {
        guard PinDetailViewController.pinTypeEnum != .place else { return }
        if PinDetailViewController.pinStatus == "new" {
            let realm = try! Realm()
            if realm.objects(NewFaePin.self).filter("pinId == \(self.strPinId) AND pinType == '\(PinDetailViewController.pinTypeEnum)'").first != nil {
                print("[checkPinStatus] newPin exists!")
            } else {
                let newPin = NewFaePin()
                newPin.pinId = Int(self.strPinId)!
                newPin.pinType = "\(PinDetailViewController.pinTypeEnum)"
                try! realm.write {
                    realm.add(newPin)
                    print("[checkPinStatus] newPin written!")
                }
            }
            PinDetailViewController.pinStatus = "normal"
            self.delegate?.changeIconImage()
        }
    }
    
    func commentThisPin(text: String) {
        if strPinId == "-1" {
            return
        }
        let commentThisPin = FaePinAction()
        commentThisPin.whereKey("content", value: text)
        commentThisPin.whereKey("anonymous", value: "\(switchAnony.isOn)")
        if self.strPinId != "-999" {
            commentThisPin.commentThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, _: Any?) in
                if status / 100 == 2 {
                    print("Successfully comment this pin!")
                    self.getPinAttributeNum()
                    self.getLastComment()
                } else {
                    print("Fail to comment this pin!")
                }
            }
        }
    }
    
    func likeThisPin() {
        if strPinId == "-1" {
            return
        }
        let likeThisPin = FaePinAction()
        likeThisPin.whereKey("", value: "")
        if self.strPinId != "-999" {
            likeThisPin.likeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, _: Any?) in
                if status == 201 {
                    print("[likeThisPin] Successfully like this pin!")
                    self.getPinAttributeNum()
                } else {
                    print("Fail to like this pin!")
                }
            }
        }
    }
    
    func saveThisPin() {
        guard self.strPinId != "-1" else { return }
        let saveThisPin = FaePinAction()
        saveThisPin.whereKey("", value: "")
        saveThisPin.saveThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, _: Any?) in
            if status / 100 == 2 {
                print("Successfully save this pin!")
                self.getPinSavedState()
                self.getPinAttributeNum()
                UIView.animate(withDuration: 0.5, animations: ({
                    self.imgCollected.alpha = 1.0
                }), completion: { _ in
                    UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                        self.imgCollected.alpha = 0.0
                    }, completion: nil)
                })
            } else {
                print("Fail to save this pin!")
            }
        }
    }
    
    func unsaveThisPin() {
        if self.strPinId == "-1" {
            return
        }
        let unsaveThisPin = FaePinAction()
        unsaveThisPin.whereKey("", value: "")
        if self.strPinId != "-999" {
            unsaveThisPin.unsaveThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, _: Any?) in
                if status / 100 == 2 {
                    print("Successfully unsave this pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum()
                    UIView.animate(withDuration: 0.5, animations: ({
                        self.imgCollected.alpha = 1.0
                    }), completion: { _ in
                        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                            self.imgCollected.alpha = 0.0
                        }, completion: nil)
                    })
                } else {
                    print("Fail to unsave this pin!")
                }
            }
        }
    }
    
    // Have read this pin
    func readThisPin() {
        if self.strPinId == "-1" {
            return
        }
        let readThisPin = FaePinAction()
        readThisPin.whereKey("", value: "")
        readThisPin.haveReadThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, _: Any?) in
            if status / 100 == 2 {
                print("Successfully read this pin!")
                if PinDetailViewController.pinStatus == "hot" || PinDetailViewController.pinStatus == "hot and read" {
                    PinDetailViewController.pinStatus = "hot and read"
                    PinDetailViewController.pinStateEnum = .hotRead
                } else {
                    PinDetailViewController.pinStatus = "read"
                    PinDetailViewController.pinStateEnum = .read
                }
                self.selectPinIcon()
                self.delegate?.changeIconImage()
            } else {
                print("Fail to read this pin!")
            }
        }
    }
    
    func unlikeThisPin() {
        if self.strPinId == "-1" {
            return
        }
        let unlikeThisPin = FaePinAction()
        unlikeThisPin.whereKey("", value: "")
        unlikeThisPin.unlikeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status: Int, _: Any?) in
            if status / 100 == 2 {
                print("Successfully unlike this pin!")
                self.getPinAttributeNum()
            } else {
                print("Fail to unlike this pin!")
            }
        }
    }
    
    func getPinSavedState() {
        let getPinSavedState = FaeMap()
        getPinSavedState.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) { (_: Int, message: Any?) in
            let commentInfoJSON = JSON(message!)
            if let isSaved = commentInfoJSON["user_pin_operations"]["is_saved"].bool {
                if isSaved == false {
                    self.isSavedByMe = false
                    self.imgCollected.image = #imageLiteral(resourceName: "pinUnsaved")
                } else {
                    self.isSavedByMe = true
                    self.imgCollected.image = #imageLiteral(resourceName: "pinSaved")
                }
            }
        }
    }
    
    // MARK: - UITableView Delegate and Datasource functions
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if PinDetailViewController.pinTypeEnum == .chat_room {
            return nil
        }
        
        let uiview = UIView()
        uiview.backgroundColor = .white
        uiview.addSubview(uiviewTblCtrlBtnSub)
        
        return uiview
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return PinDetailViewController.pinTypeEnum == .chat_room ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.pinComments.count == 0 && tableMode == .talktalk {
            return 1
        } else if self.pinComments.count > 0 && tableMode == .talktalk {
            return pinComments.count
        } else if tableMode == .feelings {
            return 1
        } else if tableMode == .people {
            return arrNonDupUserId.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.pinComments.count == 0 && tableMode == .talktalk {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinEmptyCell", for: indexPath) as! PDEmptyCell
            return cell
        } else if self.pinComments.count > 0 && tableMode == .talktalk {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinCommentsCell", for: indexPath) as! PinTalkTalkCell
            let comment = self.pinComments[indexPath.row]
            cell.delegate = self
            cell.pinID = self.strPinId
            cell.pinType = "\(PinDetailViewController.pinTypeEnum)"
            cell.userID = comment.userId
            cell.cellIndex = indexPath
            cell.pinCommentID = "\(comment.commentId)"
            cell.lblTime.text = comment.date
            cell.lblVoteCount.text = "\(comment.numVoteCount)"
            cell.voteType = comment.voteType
            cell.loadUserInfo(id: comment.userId, isAnony: comment.anonymous, anonyText: dictAnonymous[comment.userId])
            switch comment.voteType {
            case "up":
                cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
                cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                break
            case "down":
                cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
                break
            default:
                cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                break
            }
            cell.lblContent.attributedText = comment.attributedText
            return cell
        } else if tableMode == .feelings {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pdFeelingCell", for: indexPath) as! PDFeelingCell
            cell.delegate = self
            for i in 0..<11 {
                cell.imgArray[i].label.text = "\(self.feelingArray[i])"
                if i == self.intChosenFeeling {
                    cell.imgArray[i].avatar.isHidden = false
                    cell.imgArray[i].avatar.frame = CGRect(x: 40.5, y: 37.5, width: 0, height: 0)
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.imgArray[i].avatar.frame = CGRect(x: 27, y: 25, width: 20, height: 20)
                    })
                    cell.imgArray[i].avatar.image = self.imgCurUserAvatar
                } else {
                    if !cell.imgArray[i].avatar.isHidden {
                        UIView.animate(withDuration: 0.2, animations: {
                            cell.imgArray[i].avatar.frame = CGRect(x: 40.5, y: 37.5, width: 0, height: 0)
                        }, completion: { _ in
                            cell.imgArray[i].avatar.isHidden = true
                        })
                    }
                }
            }
            return cell
        } else if tableMode == .people {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pdUserInfoCell", for: indexPath) as! PDPeopleCell
            let userId = self.arrNonDupUserId[indexPath.row]
            cell.userId = userId
            cell.updatePrivacyUI(id: userId)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tblMain.fixedPullToRefreshViewForDidScroll()
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.textViewInput {
            let spacing = CharacterSet.whitespacesAndNewlines
            if textView.text.trimmingCharacters(in: spacing).isEmpty == false {
                self.lblTxtPlaceholder.isHidden = true
            } else {
                self.lblTxtPlaceholder.isHidden = false
                self.strReplyTo = ""
            }
            
            if textView.text.characters.count == 0 {
                // when text has no char, cannot send message
                btnCommentSend.isEnabled = false
                btnCommentSend.setImage(UIImage(named: "cannotSendMessage"), for: .normal)
            } else {
                btnCommentSend.isEnabled = true
                btnCommentSend.setImage(UIImage(named: "canSendMessage"), for: .normal)
            }
            
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            let numlineOnDevice = 4
            var keyboardHeight: CGFloat = screenHeight - self.uiviewInputToolBarSub.frame.origin.y - self.uiviewInputToolBarSub.frame.size.height
            if emojiView.tag == 1 {
                keyboardHeight = 271
            }
            if numLines <= numlineOnDevice {
                let txtHeight = ceil(textView.contentSize.height)
                textView.frame.size.height = txtHeight
                uiviewInputToolBarSub.frame.size.height = txtHeight + 26
                uiviewInputToolBarSub.frame.origin.y = screenHeight - txtHeight - 26 - keyboardHeight
                tblMain.frame.size.height = screenHeight - txtHeight - 26 - 65 - keyboardHeight
                textView.setContentOffset(CGPoint.zero, animated: false)
            } else {
                textView.frame.size.height = 98
                uiviewInputToolBarSub.frame.size.height = 124
                uiviewInputToolBarSub.frame.origin.y = screenHeight - 124 - keyboardHeight
                tblMain.frame.size.height = screenHeight - 124 - 65 - keyboardHeight
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chatRoomUserIds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pdChatUserCell", for: indexPath) as! PDChatUserCell
        
        cell.layer.borderWidth = indexPath.row == 0 ? 2 : 0
        cell.setValueForCell(userId: chatRoomUserIds[indexPath.row])
        
        return cell
    }
    
    // MARK: - Delegate Controls
    
    // PinFeelingCellDelegate
    func postFeelingFromFeelingCell(_ feeling: Int) {
        let tmpBtn = UIButton()
        tmpBtn.tag = feeling
        self.postFeeling(tmpBtn)
    }
    // PinFeelingCellDelegate
    func deleteFeelingFromFeelingCell() {
        self.deleteFeeling()
    }
    
    // SendStickerDelegate
    func sendStickerWithImageName(_ name: String) {
        print("[sendStickerWithImageName] name: \(name)")
        let stickerMessage = "<faeSticker>\(name)</faeSticker>"
        sendMessage(stickerMessage)
        btnCommentSend.isEnabled = false
        btnCommentSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
        UIView.animate(withDuration: 0.3) {
            self.tblMain.frame.size.height = screenHeight - 155
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - 90
        }
        
    }
    func appendEmojiWithImageName(_ name: String) {
        self.textViewInput.insertText("[\(name)]")
        let strLength: Int = self.textViewInput.text.characters.count
        self.textViewInput.scrollRangeToVisible(NSMakeRange(strLength - 1, 0))
    }
    func deleteEmoji() {
        self.textViewInput.text = self.textViewInput.text.stringByDeletingLastEmoji()
        self.textViewDidChange(textViewInput)
    }
    
    // EditPinViewControllerDelegate
    func reloadPinContent(_ coordinate: CLLocationCoordinate2D, zoom: Float) {
        if self.strPinId != "-1" {
            self.getSeveralInfo()
            tblMain.contentOffset.y = 0
        }
        PinDetailViewController.selectedMarkerPosition = coordinate
        zoomLevel = zoom
        self.delegate?.reloadMapPins(PinDetailViewController.selectedMarkerPosition, zoom: zoom, pinID: self.strPinId, marker: PinDetailViewController.pinMarker)
    }
    
    // OpenedPinListViewControllerDelegate
    func animateToCameraFromOpenedPinListView(_ coordinate: CLLocationCoordinate2D, index: Int) {
        btnPrevPin.isHidden = false
        btnNextPin.isHidden = false
        imgPinIcon.isHidden = false
        btnGrayBackToMap.isHidden = false
        
        self.backJustOnce = true
        self.uiviewMain.frame.origin.y = 0
        self.uiviewNavBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
        self.tblMain.center.y += screenHeight
        self.uiviewToFullDragBtnSub.center.y += screenHeight
        
        PinDetailViewController.selectedMarkerPosition = coordinate
        PinDetailViewController.placeType = OpenedPlaces.openedPlaces[index].category
        PinDetailViewController.strPlaceTitle = OpenedPlaces.openedPlaces[index].title
        PinDetailViewController.strPlaceStreet = OpenedPlaces.openedPlaces[index].street
        PinDetailViewController.strPlaceCity = OpenedPlaces.openedPlaces[index].city
        PinDetailViewController.strPlaceImageURL = OpenedPlaces.openedPlaces[index].imageURL
        self.initPlaceBasicInfo()
        self.manageYelpData()
        
        self.delegate?.animateToCamera(coordinate, pinID: "ddd")
        UIApplication.shared.statusBarStyle = .lightContent
    }
    func directlyReturnToMap() {
        self.actionBackToMap(UIButton())
    }
    
    // OpenedPinListViewControllerDelegate
    func backFromOpenedPinList(pinType: String, pinID: String) {
        backJustOnce = true
        uiviewNavBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
    }
    
    func directReplyFromPinCell(_ username: String, index: IndexPath) {
        self.strReplyTo = "<a>@\(username)</a> "
        self.lblTxtPlaceholder.isHidden = true
        self.appendReplyDisplayName(displayName: "@\(username)  ")
        textViewInput.becomeFirstResponder()
        directReplyFromUser = true
        boolKeyboardShowed = true
        tblMain.scrollToRow(at: index, at: .bottom, animated: true)
    }
    
    func showActionSheetFromPinCell(_ username: String, userid: Int, index: IndexPath) {
        textViewInput.resignFirstResponder()
        if !boolKeyboardShowed && !boolStickerShowed {
            self.showActionSheet(name: username, userid: userid, index: index)
        }
        boolKeyboardShowed = false
    }
    
    func showActionSheet(name: String, userid: Int, index: IndexPath) {
        let menu = UIAlertController(title: nil, message: "Action", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor.faeAppRedColor()
        let writeReply = UIAlertAction(title: "Write a Reply", style: .default) { (_: UIAlertAction) in
            self.strReplyTo = "<a>@\(name)</a> "
            self.lblTxtPlaceholder.isHidden = true
            self.appendReplyDisplayName(displayName: "@\(name)  ")
            self.textViewInput.becomeFirstResponder()
            self.directReplyFromUser = true
            self.boolKeyboardShowed = true
            self.tblMain.scrollToRow(at: index, at: .bottom, animated: true)
        }
        let report = UIAlertAction(title: "Report", style: .default) { (_: UIAlertAction) in
            self.actionReportThisPin()
        }
        let delete = UIAlertAction(title: "Delete", style: .default) { (_: UIAlertAction) in
            let deletePinComment = FaePinAction()
            let pinCommentID = self.pinComments[index.row].commentId
            deletePinComment.uncommentThisPin(pinCommentID: "\(pinCommentID)", completion: { status, message in
                if status / 100 == 2 {
                    print("[Delete Pin Comment] Success")
                    // Vicky 06/21/17
                    self.getPinAttributeNum()
                    // Vicky 06/21/17 End
                } else {
                    print("[Delete Pin Comment] status: \(status), message: \(message!)")
                }
            })
            self.pinComments.remove(at: index.row)
            self.tblMain.reloadData()
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_: UIAlertAction) in
            self.strReplyTo = ""
            self.lblTxtPlaceholder.text = "Write a Comment..."
        }
        menu.addAction(writeReply)
        if user_id == userid {
            menu.addAction(delete)
        } else {
            menu.addAction(report)
        }
        menu.addAction(cancel)
        self.present(menu, animated: true, completion: nil)
    }
    
    // Vicky 06/21/17
    // PinTalkTalkCellDelegate
    func upVoteComment(index: IndexPath) {
        let cell = self.tblMain.cellForRow(at: index) as! PinTalkTalkCell
        
        if self.pinComments[index.row].voteType == "up" || cell.pinCommentID == "" {
            self.cancelVote(index: index)
            return
        }
        
        cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
        cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
        let upVote = FaePinAction()
        upVote.whereKey("vote", value: "up")
        upVote.votePinComments(pinID: "\(cell.pinCommentID)") { (status: Int, _: Any?) in
            print("[upVoteThisComment] pinCommentID: \(cell.pinCommentID)")
            if status / 100 == 2 {
                self.pinComments[index.row].voteType = "up"
                self.updateVoteCount(index: index)
                print("[upVoteThisComment] Successfully upvote this pin comment")
            } else if status == 400 {
                print("[upVoteThisComment] Already upvote this pin comment")
            } else {
                if self.pinComments[index.row].voteType == "down" {
                    cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
                } else if self.pinComments[index.row].voteType == "" {
                    cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                print("[upVoteThisComment] Fail to upvote this pin comment")
            }
        }
    }
    
    // PinTalkTalkCellDelegate
    func downVoteComment(index: IndexPath) {
        let cell = self.tblMain.cellForRow(at: index) as! PinTalkTalkCell
        
        if self.pinComments[index.row].voteType == "down" || cell.pinCommentID == "" {
            self.cancelVote(index: index)
            return
        }
        cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
        cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
        let downVote = FaePinAction()
        downVote.whereKey("vote", value: "down")
        downVote.votePinComments(pinID: "\(cell.pinCommentID)") { (status: Int, _: Any?) in
            if status / 100 == 2 {
                self.pinComments[index.row].voteType = "down"
                self.updateVoteCount(index: index)
                print("[upVoteThisComment] Successfully downvote this pin comment")
            } else if status == 400 {
                print("[upVoteThisComment] Already downvote this pin comment")
            } else {
                if self.pinComments[index.row].voteType == "up" {
                    cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
                    cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                } else if self.pinComments[index.row].voteType == "" {
                    cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                print("[upVoteThisComment] Fail to downvote this pin comment")
            }
        }
    }
    
    func cancelVote(index: IndexPath) {
        let cell = self.tblMain.cellForRow(at: index) as! PinTalkTalkCell
        
        let cancelVote = FaePinAction()
        cancelVote.cancelVotePinComments(pinId: "\(cell.pinCommentID)") { (status: Int, _: Any?) in
            if status / 100 == 2 {
                self.pinComments[index.row].voteType = ""
                cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                self.updateVoteCount(index: index)
                print("[upVoteThisComment] Successfully cancel vote this pin comment")
            } else if status == 400 {
                print("[upVoteThisComment] Already cancel vote this pin comment")
            }
        }
    }
    
    func updateVoteCount(index: IndexPath) {
        let cell = self.tblMain.cellForRow(at: index) as! PinTalkTalkCell
        
        let getPinCommentsDetail = FaePinAction()
        getPinCommentsDetail.getPinComments("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (_: Int, message: Any?) in
            let commentsOfCommentJSON = JSON(message!)
            if commentsOfCommentJSON.count > 0 {
                for i in 0...(commentsOfCommentJSON.count - 1) {
                    var upVote = -999
                    var downVote = -999
                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].int {
                        if cell.pinCommentID != "\(pin_comment_id)" {
                            continue
                        }
                    }
                    if let vote_up_count = commentsOfCommentJSON[i]["vote_up_count"].int {
                        print("[getPinComments] upVoteCount: \(vote_up_count)")
                        upVote = vote_up_count
                    }
                    if let vote_down_count = commentsOfCommentJSON[i]["vote_down_count"].int {
                        print("[getPinComments] downVoteCount: \(vote_down_count)")
                        downVote = vote_down_count
                    }
                    if let _ = commentsOfCommentJSON[i]["pin_comment_operations"]["vote"].string {
                        
                    }
                    if upVote != -999 && downVote != -999 {
                        cell.lblVoteCount.text = "\(upVote - downVote)"
                        self.pinComments[index.row].numVoteCount = upVote - downVote
                    }
                }
            }
        }
    }
    
    // MARK: - Input Tool Bar Functions
    
    func appendReplyDisplayName(displayName: String) {
        let attributedStr = NSMutableAttributedString(string: "")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 37))
        label.attributedText = NSAttributedString(string: displayName, attributes: [NSForegroundColorAttributeName: UIColor(r: 146, g: 146, b: 146, alpha: 100), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18)!])
        label.numberOfLines = 1
        
        // calculate the size of the image
        label.sizeToFit()
        var size = label.frame.size
        label.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        label.textAlignment = .center
        size = label.frame.size
        
        //        get a high quality image
        label.attributedText = NSAttributedString(string: displayName, attributes: [NSForegroundColorAttributeName: UIColor(r: 146, g: 146, b: 146, alpha: 100), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 54)!])
        label.sizeToFit()
        var size2 = label.frame.size
        label.frame = CGRect(x: 0, y: 0, width: size2.width, height: size2.height)
        size2 = label.frame.size
        
        var image: UIImage?
        UIGraphicsBeginImageContext(CGSize(width: size2.width, height: size2.height))
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext() {
            image = screenShotImage
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: -6.9, width: size.width, height: size.height)
        
        let nameStr = NSAttributedString(attachment: attachment)
        attributedStr.append(nameStr)
        
        self.textViewInput.isScrollEnabled = false
        self.textViewInput.attributedText = attributedStr
        self.textViewInput.isScrollEnabled = true
        
        self.textViewInput.font = UIFont(name: "AvenirNext-Regular", size: 18)
        self.textViewInput.textColor = UIColor.faeAppInputTextGrayColor()
    }
    
    // MARK: - keyboard input bar tapped event
    func sendMessageButtonTapped() {
        self.animationRedSlidingLine(self.btnTalkTalk)
        self.sendMessage(textViewInput.text)
        btnCommentSend.isEnabled = false
        btnCommentSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    // MARK: - send messages
    func sendMessage(_ text: String?) {
        if let realText = text {
            self.commentThisPin(text: "\(self.strReplyTo)\(realText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))")
        }
        
        self.strReplyTo = ""
        self.textViewInput.text = ""
        self.lblTxtPlaceholder.text = "Write a Comment..."
        self.textViewDidChange(textViewInput)
        self.endEdit()
    }
    
    // MARK: - add or remove observers
    func addObservers() {
        guard PinDetailViewController.pinTypeEnum != .place else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
    }
    
    func appWillEnterForeground() {
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        self.actionHideEmojiView()
        
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isKeyboardInThisView {
                self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - self.keyboardHeight
                self.uiviewAnonymous.frame.origin.y = screenHeight - 51 - self.keyboardHeight
                self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height - self.keyboardHeight
                self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - self.keyboardHeight
            }
        }, completion: { _ in
            
        })
        if !directReplyFromUser {
            tblMain.setContentOffset(CGPoint(x: 0, y: uiviewTblHeader.frame.size.height), animated: false)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        boolKeyboardShowed = true
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        uiviewAnonymous.isHidden = true
        uiviewInputToolBarSub.isHidden = false
        keyboardHeight = 0
        self.uiviewAnonymous.frame.origin.y = screenHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isKeyboardInThisView {
                self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height
                self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
            }
        }, completion: nil)
    }
    
    func keyboardDidHide(_ notification: Notification) {
        boolKeyboardShowed = false
    }
    
    // MARK: - Animations
    
    func animateHeart() {
        btnPinLike.tag = 0
        animatingHeart = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 22))
        animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        animatingHeart.layer.zPosition = 108
        uiviewInteractBtnSub.addSubview(animatingHeart)
        
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        let transform: CGAffineTransform = CGAffineTransform(translationX: btnPinLike.center.x, y: btnPinLike.center.y)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0), transform: transform)
        path.addLine(to: CGPoint(x: randomX - 75, y: -randomY), transform: transform)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue(caTransform3D: CATransform3DMakeScale(randomSize, randomSize, 1))]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.duration = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.3
        fadeAnimation.beginTime = CACurrentMediaTime() + 0.72
        
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = path
        orbit.calculationMode = kCAAnimationPaced
        
        animatingHeart.layer.add(orbit, forKey: "Move")
        animatingHeart.layer.add(fadeAnimation, forKey: "Opacity")
        animatingHeart.layer.add(scaleAnimation, forKey: "Scale")
        animatingHeart.layer.position = CGPoint(x: btnPinLike.center.x, y: btnPinLike.center.y)
    }
    
    func animatePinCtrlBtnsAndFeeling() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            
            self.btnGrayBackToMap.alpha = 1
            self.btnNextPin.alpha = 1
            self.btnPrevPin.alpha = 1
            self.imgPinIcon.alpha = 1
            
            self.uiviewMain.frame.origin.y = 0
            
            self.uiviewInputToolBarSub.frame.origin.x = 0
        }, completion: { _ in
            if PinDetailViewController.pinTypeEnum != .place {
                self.delegate?.changeIconImage()
            }
        })
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            if PinDetailViewController.pinTypeEnum == .comment || PinDetailViewController.pinTypeEnum == .media {
                self.uiviewFeelingBar.frame = CGRect(x: (414 - 281) / 2, y: 409, w: 281, h: 52)
                let yAxis: CGFloat = 11
                let width: CGFloat = 32
                for i in 0..<self.btnFeelingArray.count {
                    self.btnFeelingArray[i].frame = CGRect(x: CGFloat(20 + 52 * i), y: yAxis, w: width, h: width)
                }
            }
            self.btnPrevPin.frame = CGRect(x: 15, y: 477 , w: 52 , h: 52)
            self.btnNextPin.frame = CGRect(x: 347 , y: 477 , w: 52 , h: 52)
        }, completion: { _ in
            self.checkCurrentUserChosenFeeling()
        })
    }
    
    func checkCurrentUserChosenFeeling() {
        guard PinDetailViewController.pinTypeEnum == .comment
           || PinDetailViewController.pinTypeEnum == .media else { return }
        
        let getPinById = FaeMap()
        getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) { (_: Int, message: Any?) in
            let pinInfoJSON = JSON(message!)
            // Has posted feeling or not
            guard let chosenFeel = pinInfoJSON["user_pin_operations"]["feeling"].int else {
                self.intChosenFeeling = -1
                return
            }
            self.intChosenFeeling = chosenFeel
            if chosenFeel < 5 && chosenFeel >= 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    let xOffset = CGFloat(chosenFeel * 52 + 12)
                    self.btnFeelingArray[chosenFeel].frame = CGRect(x: xOffset, y: 3, w: 48, h: 48)
                })
            }
        }
    }
}
