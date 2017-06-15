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

protocol PinDetailDelegate: class {
    // Cancel marker's shadow when back to Fae Map
    // true  -> just means user want to back to main screen
    // false -> delete this pin from map
    func backToMainMap()
    // Pass location data to fae map view
    func animateToCamera(_ coordinate: CLLocationCoordinate2D, pinID: String)
    // Change marker icon based on status
    func changeIconImage()
    // Reload map pins because of location changed
    func reloadMapPins(_ coordinate: CLLocationCoordinate2D, zoom: Float, pinID: String, marker: GMSMarker)
    // Go to prev or next pin
    func goTo(nextPin: Bool)
}

protocol PinDetailCollectionsDelegate: class {
    // Go back to collections
    func backToCollections(likeCount: String, commentCount: String, pinLikeStatus: Bool)
}

class PinDetailViewController: UIViewController {
    
    enum EnterMode: Int {
        case mainMap = 0
        case collections = 1
    }
    
    enum MediaMode {
        case small
        case large
    }
    enum PinType: String {
        case comment
        case media
        case chat_room
        case place
    }
    enum PinState: String {
        case normal
        case read
        case hot
        case hotRead = "hot and read"
    }
    enum TableMode: Int {
        case talktalk = 0
        case feelings = 1
        case people = 2
    }
    
    var textViewOriginalHeight: CGFloat = 0 {
        didSet {
            if textviewPinDetail != nil {
                textviewPinDetail.frame.size.height = textViewOriginalHeight
            }
        }
    }
    var pinIconHeavyShadow: UIImage = #imageLiteral(resourceName: "markerMomentPinHeavyShadow") {
        didSet {
            if imgPinIcon != nil {
                imgPinIcon.image = pinIconHeavyShadow
            }
        }
    }
    var keyboardHeight: CGFloat = 0 {
        didSet {
            if uiviewInputToolBarSub != nil {
                PDEmptyCell.padding = screenHeight - keyboardHeight - uiviewInputToolBarSub.frame.size.height - 189
            }
        }
    }
    
    weak var delegate: PinDetailDelegate? // Delegate of this class
    weak var colDelegate: PinDetailCollectionsDelegate? // For collections
    
    static var pinMarker = GMSMarker()
    static var pinStateEnum: PinState = .normal
    static var pinStatus = ""
    static var pinTypeEnum: PinType = .media
    static var pinUserId = 0
    static var placeType = ""
    static var selectedMarkerPosition: CLLocationCoordinate2D!
    static var strPlaceCity = ""
    static var strPlaceImageURL = ""
    static var strPlaceStreet = ""
    static var strPlaceTitle = ""
    var animatingHeart: UIImageView!
    var animatingHeartTimer: Timer! // Timer for animating heart
    var anotherRedSlidingLine: UIView!
    var backJustOnce = true // Control the back to pin detail button, prevent the more than once action
    var boolMyPin = false // Check if this pin belongs to current user
    var boolOptionsExpanded = false
    var boolPinLiked = false
    var boolFromMapBoard = false
    var btnCollect: UIButton! // Pin options
    var btnCommentOption: UIButton! // Custom toolBar the bottom toolbar button
    var btnCommentSend: UIButton! // Custom toolBar the bottom toolbar button
    var btnDoAnony: UIButton!
    var btnFeelingArray = [UIButton]()
    var btnFeelingBar_01: UIButton!
    var btnFeelingBar_02: UIButton!
    var btnFeelingBar_03: UIButton!
    var btnFeelingBar_04: UIButton!
    var btnFeelingBar_05: UIButton!
    var btnFeelings: UIButton!
    var btnGoToPinList_Place: UIButton!
    var btnGrayBackToMap: UIButton! // Background gray button, alpha = 0.3
    var btnHalfPinToMap: UIButton!
    var btnHideAnony: UIButton!
    var btnMoreOptions_Place: UIButton!
    var btnNextPin: UIButton!
    var btnOptionDelete: UIButton! // Pin options
    var btnOptionEdit: UIButton! // Pin options
    var btnPeople: UIButton!
    var btnPinComment: UIButton!
    var btnPinLike: UIButton!
    var btnPrevPin: UIButton!
    var btnReport: UIButton! // Pin options
    var btnShare: UIButton! // Pin options
    var btnShowSticker: UIButton! // Custom toolBar the bottom toolbar button
    var btnTalkTalk: UIButton!
    var btnToFullPin: UIButton!
    var btnTransparentClose: UIButton! // Fake Transparent View For Closing
    var emojiView: StickerPickView! // Input tool bar
    var enterMode: EnterMode = .mainMap
    var feelingArray = [Int]()
    var fileIdArray = [Int]()
    var imgCollected: UIImageView!
    var imgHotPin: UIImageView!
    var imgMediaArr = [FaeImageView]()
    var imgPinIcon: UIImageView! // Icon to indicate pin type
    var imgPinUserAvatar: FaeAvatarView!
    var imgPlaceQuickView: UIImageView!
    var imgPlaceType: UIImageView!
    var intChosenFeeling: Int = -1
    var isAnonymous = false // var to record is user is anonymous;
    var isDownVoting = false // Like Function
    var isKeyboardInThisView = true // trigger the function inside keyboard notification ctrl if in pin detail view
    var isSavedByMe = false
    var isUpVoting = false // Like Function
    var lastContentOffset: CGFloat = 0
    var lblCommentCount: UILabel!
    var lblFeelings: UILabel!
    var lblPeople: UILabel!
    var lblPinDate: UILabel!
    var lblPinDisplayName: UILabel!
    var lblPinLikeCount: UILabel!
    var lblPlaceCity: UILabel!
    var lblPlaceStreet: UILabel!
    var lblPlaceTitle: UILabel!
    var lblTalkTalk: UILabel!
    var lblTxtPlaceholder: UILabel!
    var lblAnotherTalkTalk: UILabel!
    var lblAnotherFeelings: UILabel!
    var lblAnotherPeople: UILabel!
    var pinComments = [PinComment]()
    var pinDetailUsers = [PinDetailUser]()
    var scrollViewMedia: UIScrollView! // container to display pin's media
    var strCurrentTxt = ""
    var strPinId = "-1"
    var strReplyTo = "" // Reply to specific user, set string as "" if no user is specified
    var switchAnony: UISwitch!
    var tableMode: TableMode = .talktalk
    var tblMain: UITableView!
    var textViewInput: UITextView! // Input tool bar
    var textviewPinDetail: UITextView!
    var uiviewAnonymous: UIView!
    var uiviewCtrlBoard: UIView! // A duplicate ControlBoard to hold
    var uiviewFeelingBar: UIView!
    var uiviewFeelingQuick: UIView!
    var uiviewGrayMidBlock: UIView!
    var uiviewGrayMidLine: UIView!
    var uiviewInputToolBarSub: UIView! // Input tool bar
    var uiviewInteractBtnSub: UIView!
    var uiviewLineInDragBtn: UIView!
    var uiviewNavBar: FaeNavBar!
    var uiviewOptionsSub: UIImageView!
    var uiviewPlaceDetail: UIView!
    var uiviewPlacePinBottomLine: UIView!
    var uiviewRedSlidingLine: UIView!
    var uiviewTableSub: UIView!
    var uiviewTblCtrlBtnSub: UIView!
    var uiviewTblHeader: UIView!
    var uiviewMain: UIView!
    var uiviewToFullDragBtnSub: UIView! // Another dragging button for UI effect: shadow
    var zoomLevel: Float = 13.8
    var anonyUserDict = [Int: Int]()
    
    // Load Chat
    var uiviewChatRoom: UIView!
    var btnChatEnter: UIButton!
    var btnChatSpotLeftArrow: UIButton!
    var btnChatSpotRightArrow: UIButton!
    var btnDropDown: UIButton!
    var chatSpotEmojiBubble: UIButton!
    var cllcviewChatMember: UICollectionView!
    var imgChatSpot: UIImageView!
    var lblChatMemberNum: UILabel!
    var lblDescriptionText: UILabel!
    var mutableAttrStringMemberNum: NSMutableAttributedString!
    var mutableAttrStringMemberTotal: NSMutableAttributedString!
    var uiviewChatSpotBar: UIView!
    var uiviewChatSpotLine: UIView!
    var uiviewChatSpotLineFirstBottom: UIView!
    var lblPeopleCount: UILabel!
    var imgCurUserAvatar: UIImageView!
    var boolKeyboardShowed = false
    var boolStickerShowed = false
    var directReplyFromUser = false // if true, animates cell right above input tool bar, or to top
    var btnSelectedFeeling: UIButton?
    var previousIndex: Int = -1
    var boolDetailShrinked = true
    var strTextViewText = ""
    var dictAnonymous = [Int: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        modalPresentationStyle = .overCurrentContext
        loadPinDetailWindow()
        initPinBasicInfo()
        getSeveralInfo()
        loadFromCollections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if enterMode != .collections {
            animatePinCtrlBtnsAndFeeling()
        }
        
        print(boolFromMapBoard)
        if boolFromMapBoard {
            btnPinComment.sendActions(for: .touchUpInside)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    fileprivate func loadFromCollections() {
        if enterMode != .collections {
            return
        }
        
        boolDetailShrinked = false
        uiviewFeelingBar.isHidden = true
        btnNextPin.isHidden = true
        btnPrevPin.isHidden = true
        imgPinIcon.isHidden = true
        btnGrayBackToMap.isHidden = true
        uiviewNavBar.rightBtn.isHidden = true
        
        textviewPinDetail.isScrollEnabled = false
        tblMain.isScrollEnabled = true
        btnToFullPin.isHidden = true
        uiviewToFullDragBtnSub.isHidden = true
        
        let toolbarHeight = PinDetailViewController.pinTypeEnum == .chat_room ? 0 : uiviewInputToolBarSub.frame.size.height
        uiviewMain.frame.size.height = screenHeight - toolbarHeight
        tblMain.frame.size.height = screenHeight - 65 - toolbarHeight
        uiviewInputToolBarSub.frame.origin.x = 0
        uiviewInputToolBarSub.frame.origin.y = screenHeight - uiviewInputToolBarSub.frame.size.height
        uiviewTableSub.frame.size.height = screenHeight - 65 - toolbarHeight
        uiviewToFullDragBtnSub.frame.origin.y = screenHeight - toolbarHeight
        
        let txtViewWidth = textviewPinDetail.frame.size.width
        guard let font = textviewPinDetail.font else { return }
        let textViewHeight: CGFloat = textviewPinDetail.text.height(withConstrainedWidth: txtViewWidth, font: font)
        if PinDetailViewController.pinTypeEnum == .media {
            textviewPinDetail.alpha = 1
            textviewPinDetail.frame.size.height = textViewHeight
            scrollViewMedia.frame.origin.y += textViewHeight
            uiviewGrayMidBlock.center.y += 65 + textViewHeight
            uiviewInteractBtnSub.center.y += 65 + textViewHeight
            uiviewTblCtrlBtnSub.center.y += 65 + textViewHeight
            uiviewTblHeader.frame.size.height += 65 + textViewHeight
        } else if PinDetailViewController.pinTypeEnum == .comment && textViewHeight > 100.0 {
            let diffHeight: CGFloat = textViewHeight - 100
            textviewPinDetail.frame.size.height += diffHeight
            uiviewGrayMidBlock.center.y += diffHeight
            uiviewInteractBtnSub.center.y += diffHeight
            uiviewTblCtrlBtnSub.center.y += diffHeight
            uiviewTblHeader.frame.size.height += diffHeight
        }
    }
    
    func selectPinState() {
        if PinDetailViewController.pinTypeEnum == .place {
            return
        }
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
    
    fileprivate func initPinBasicInfo() {
        switch PinDetailViewController.pinTypeEnum {
        case .comment:
            uiviewNavBar.lblTitle.text = "Comment"
            textViewOriginalHeight = 100
            break
        case .media:
            uiviewNavBar.lblTitle.text = "Story"
            textViewOriginalHeight = 0
            break
        case .chat_room:
            uiviewNavBar.lblTitle.text = "Chat Spot"
            uiviewFeelingBar.isHidden = true
            break
        case .place:
            loadPlaceDetail()
            break
        }
        selectPinState()
        checkPinStatus() // check pin status is for social pin
        addObservers() // add input toolbar keyboard observers
    }
}
