//
//  PinDetailBaseViewController.swift
//  faeBeta
//
//  Created by Yue on 6/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PinDetailBaseViewController: UIViewController {

    // MARK: - Enums
    
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
        case hotRead
    }
    enum TableMode: Int {
        case talktalk = 0
        case feelings = 1
        case people = 2
    }
    
    
    // MARK: - Variables
    
    var txtViewInitHeight: CGFloat = 0 {
        didSet {
            if txtviewPinDetail != nil {
                txtviewPinDetail.frame.size.height = txtViewInitHeight
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
    
    static var pinAnnotation: FaePinAnnotation!
    static var pinStateEnum: PinState = .normal
    static var pinStatus = ""
    static var pinTypeEnum: PinType = .media
    static var pinUserId: Int = 0
    static var placeType = ""
    static var selectedMarkerPosition: CLLocationCoordinate2D!
    static var strPlaceCity = ""
    static var strPlaceImageURL = ""
    static var strPlaceStreet = ""
    static var strPlaceTitle = ""
    var animatingHeart: UIImageView!
    var animatingHeartTimer: Timer! // Timer for animating heart
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
    var imgFeelings = [UIImageView]()
    var imgIcon = UIImage()
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
    var txtviewPinDetail: UITextView!
    var uiviewAnonymous: UIView!
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
    var anonyUserDict = [Int: Int]()
    var arrNonDupUserId = [Int]() // UserId array with no duplicates
    
    // MARK: - Chat Room Variables
    var uiviewChatRoom: UIView!
    var btnChatEnter: UIButton!
    var btnChatSpotLeftArrow: UIButton!
    var btnChatSpotRightArrow: UIButton!
    var btnDropDown: UIButton!
    var chatSpotEmojiBubble: UIButton!
    var cllcviewChatMember: UICollectionView!
    var imgChatSpot: FaeImageView!
    var lblChatMemberNum: UILabel!
    var lblChatDesc: UILabel!
    var mutableAttrStringMemberNum: NSMutableAttributedString!
    var mutableAttrStringMemberTotal: NSMutableAttributedString!
    var uiviewChatSpotBar: UIView!
    var uiviewChatSpotLine: UIView!
    var uiviewChatSpotLineFirstBottom: UIView!
    var lblPeopleCount: UILabel!
    var imgCurUserAvatar = UIImage()
    var boolKeyboardShowed = false
    var boolStickerShowed = false
    var directReplyFromUser = false // if true, animates cell right above input tool bar, or to top
    var btnSelectedFeeling: UIButton?
    var previousIndex: Int = -1
    var boolFullPinView = false
    var strTextViewText = ""
    var dictAnonymous = [Int: String]()
    var lblChatRoomTitle: UILabel!
    var chatRoomUserIds = [Int]()
    var category_idx = 0
}
