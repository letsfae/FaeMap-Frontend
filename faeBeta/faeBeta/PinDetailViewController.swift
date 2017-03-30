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
    func dismissMarkerShadow(_ dismiss: Bool)
    // Pass location data to fae map view
    func animateToCamera(_ coordinate: CLLocationCoordinate2D, pinID: String)
    // Change marker icon based on status
    func changeIconImage(marker: GMSMarker, type: String, status: String)
    // Disable self marker on main map true or not
    func disableSelfMarker(yes: Bool)
}

class PinDetailViewController: UIViewController {
    
    enum MediaMode {
        case small
        case large
    }
    enum PinType: String {
        case comment = "comment"
        case media = "media"
        case chat_room = "chat_room"
        case place = "place"
    }
    enum PinState: String {
        case normal = "normal"
        case read = "read"
        case hot = "hot"
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
                self.textviewPinDetail.frame.size.height = textViewOriginalHeight
            }
        }
    }
    var pinIconHeavyShadow: UIImage = #imageLiteral(resourceName: "markerMomentPinHeavyShadow") {
        didSet {
            if pinIcon != nil {
                self.pinIcon.image = pinIconHeavyShadow
            }
        }
    }
    
    weak var delegate: PinDetailDelegate? // Delegate of this class
    var animatingHeart: UIImageView!
    var animatingHeartTimer: Timer! // Timer for animating heart
    var anotherRedSlidingLine: UIView!
    var backJustOnce = true // Control the back to pin detail button, prevent the more than once action
    var boolPinLiked = false
    var btnCommentOption: UIButton! //Custom toolBar the bottom toolbar button
    var btnDoAnony: UIButton!
    var btnFeelingBar_01: UIButton!
    var btnFeelingBar_02: UIButton!
    var btnFeelingBar_03: UIButton!
    var btnFeelingBar_04: UIButton!
    var btnFeelingBar_05: UIButton!
    var btnGoToPinList_Place: UIButton!
    var btnHideAnony: UIButton!
    var btnMoreOptions_Place: UIButton!
    var buttonBackToPinLists: UIButton!
    var buttonDeleteOnPinDetail: UIButton! // Pin options
    var buttonEditOnPinDetail: UIButton! // Pin options
    var buttonFakeTransparentClosingView: UIButton! // Fake Transparent View For Closing
    var buttonKeyBoard : UIButton! //Custom toolBar the bottom toolbar button
    var buttonMoreOnPinCellExpanded = false
    var buttonNextPin: UIButton!
    var buttonOptionOfPin: UIButton!
    var buttonPinAddComment: UIButton!
    var buttonPinBackToMap: UIButton!
    var buttonPinDetailDragToLargeSize: UIButton!
    var buttonPinDetailViewComments: UIButton!
    var buttonPinDetailViewFeelings: UIButton!
    var buttonPinDetailViewPeople: UIButton!
    var buttonPinDownVote: UIButton!
    var buttonPinLike: UIButton!
    var buttonPinUpVote: UIButton!
    var buttonPrevPin: UIButton!
    var buttonReportOnPinDetail: UIButton! // Pin options
    var buttonSaveOnPinDetail: UIButton! // Pin options
    var buttonSend : UIButton! //Custom toolBar the bottom toolbar button
    var buttonShareOnPinDetail: UIButton! // Pin options
    var buttonSticker : UIButton! //Custom toolBar the bottom toolbar button
    var controlBoard: UIView! // A duplicate ControlBoard to hold
    var draggingButtonSubview: UIView! // Another dragging button for UI effect
    var emojiView: StickerPickView! // Input tool bar
    var fileIdArray = [Int]()
    var feelingArray = [Int]()
    var firstLoadInputToolBar = true
    var grayBackButton: UIButton! // Background gray button, alpha = 0.3
    var imagePinUserAvatar: UIImageView!
    var imageViewHotPin: UIImageView!
    var imageViewMediaArray = [UIImageView]()
    var imageViewSaved: UIImageView!
    var imgPlaceQuickView: UIImageView!
    var imgPlaceType: UIImageView!
    var isAnonymous = false // var to record is user is anonymous;
    var isDownVoting = false // Like Function
    var isKeyboardInThisView = true // trigger the function inside keyboard notification ctrl if in pin detail view
    var isSavedByMe = false
    var isUpVoting = false // Like Function
    var keyboardHeight: CGFloat = 0
    var labelPinCommentsCount: UILabel!
    var labelPinDetailViewComments: UILabel!
    var labelPinDetailViewFeelings: UILabel!
    var labelPinDetailViewPeople: UILabel!
    var labelPinLikeCount: UILabel!
    var labelPinTimestamp: UILabel!
    var labelPinTitle: UILabel!
    var labelPinUserName: UILabel!
    var labelPinVoteCount: UILabel!
    var lastContentOffset: CGFloat = 0
    var lblPlaceCity: UILabel!
    var lblPlaceStreet: UILabel!
    var lblPlaceTitle: UILabel!
    var lblTxtPlaceholder: UILabel!
    var mediaMode: MediaMode = .small
    var moreButtonDetailSubview: UIImageView!
    var pinComments = [PinComment]()
    var pinCommentsCount = 0
    var pinDetailLiked = false
    var pinDetailShowed = false
    var pinDetailUsers = [PinDetailUser]()
    var pinIDPinDetailView: String = "-999"
    var pinIcon: UIImageView! // Icon to indicate pin type
    var pinIdSentBySegue: String = "-999" // Pin ID To Use In This Controller
    var pinLikeCount = 0
    var pinMarker = GMSMarker()
    var pinSizeFrom: CGFloat = 0 // For Dragging
    var pinSizeTo: CGFloat = 0 // For Dragging
    var pinStateEnum: PinState = .normal
    var pinStatus = ""
    var pinTypeEnum: PinType = .media
    var pinUserId = 0
    var placeType = "burgers"
    var replyToUser = "" // Reply to specific user, set string as "" if no user is specified
    var scrollViewMedia: UIScrollView! // container to display pin's media
    var selectedMarkerPosition: CLLocationCoordinate2D!
    var strPlaceCity = ""
    var strPlaceImageURL = ""
    var strPlaceStreet = ""
    var strPlaceTitle = ""
    var stringPlainTextViewTxt = ""
    var subviewInputToolBar: UIView! // subview to hold input toolbar
    var subviewNavigation: UIView!
    var subviewTable: UIView!
    var switchAnony: UISwitch!
    var switchedToFullboard = true // FullboardScrollView and TableViewCommentsOnPin control
    var tableCommentsForPin: UITableView!
    var tableMode: TableMode = .talktalk
    var textViewInput: UITextView! // Input tool bar
    var textviewPinDetail: UITextView!
    var thisIsMyPin = false // Check if this pin belongs to current user
    var toolBarExtendView : UIView! // an extend uiview for anynomus texting (mingjie jin)
    var touchToReplyTimer: Timer! // Timer for touching pin comment cell
    var uiviewAnonymous: UIView!
    var uiviewFeelingBar: UIView!
    var uiviewGrayBaseLine: UIView!
    var uiviewPinDetail: UIView!
    var uiviewPinDetailGrayBlock: UIView!
    var uiviewPinDetailMainButtons: UIView!
    var uiviewPinDetailThreeButtons: UIView!
    var uiviewPinUnderLine01: UIView!
    var uiviewPinUnderLine02: UIView!
    var uiviewPlaceDetail: UIView!
    var uiviewPlaceLine: UIView!
    var uiviewRedSlidingLine: UIView!
    var uiviewToolBar: UIView! // Input tool bar
    var uiviewFeeling: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.modalPresentationStyle = .overCurrentContext
        loadTransparentButtonBackToMap()
        loadPinDetailWindow()
        if pinTypeEnum == .place {
            loadPlaceDetail()
            pinIcon.frame.size.width = 48
            pinIcon.center.x = screenWidth / 2
            pinIcon.center.y = 507 * screenHeightFactor
            UIApplication.shared.statusBarStyle = .lightContent
        }
        pinIDPinDetailView = pinIdSentBySegue
        if pinIDPinDetailView != "-999" {
            getSeveralInfo()
        }
        initPinBasicInfo()
        checkPinStatus()
        self.delegate?.disableSelfMarker(yes: true)
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.buttonNextPin.alpha = 1
            self.buttonPrevPin.alpha = 1
            self.draggingButtonSubview.frame.origin.y = 292
            self.grayBackButton.alpha = 1
            self.pinIcon.alpha = 1
            self.subviewNavigation.frame.origin.y = 0
            self.subviewTable.frame.origin.y = 65
            self.tableCommentsForPin.frame.origin.y = 65
            self.uiviewFeelingBar.alpha = 1
            if self.pinTypeEnum == .place {
                self.uiviewPlaceDetail.frame.origin.y = 0
            }
        }, completion: { (done: Bool) in
            if self.pinTypeEnum != .place {
                self.delegate?.changeIconImage(marker: self.pinMarker, type: "\(self.pinTypeEnum)", status: self.pinStatus)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func selectPinState(pinState: PinState, pinType: PinType) {
        switch pinState {
        case .hot:
            pinIcon.image = UIImage(named: "hot\(pinType)PD")
            break
        case .read:
            pinIcon.image = UIImage(named: "read\(pinType)PD")
            break
        case .hotRead:
            pinIcon.image = UIImage(named: "hotRead\(pinType)PD")
            break
        case .normal:
            pinIcon.image = UIImage(named: "normal\(pinType)PD")
            break
        }
    }
    
    func initPinBasicInfo() {
        switch pinTypeEnum {
        case .comment:
            self.labelPinTitle.text = "Comment"
            textViewOriginalHeight = 100
            if scrollViewMedia != nil {
                scrollViewMedia.isHidden = true
                
            }
            if textviewPinDetail != nil {
                textviewPinDetail.isHidden = false
            }
            selectPinState(pinState: pinStateEnum, pinType: pinTypeEnum)
            break
        case .media:
            self.labelPinTitle.text = "Story"
            textViewOriginalHeight = 0
            if scrollViewMedia != nil {
                scrollViewMedia.isHidden = false
            }
            if textviewPinDetail != nil {
                textviewPinDetail.isHidden = true
            }
            selectPinState(pinState: pinStateEnum, pinType: pinTypeEnum)
            break
        case .chat_room:
            self.labelPinTitle.text = "Chat"
            selectPinState(pinState: pinStateEnum, pinType: pinTypeEnum)
            break
        case .place:
            break
        }
        labelPinTitle.textAlignment = .center
    }
    
    func loadTransparentButtonBackToMap() {
        grayBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        grayBackButton.backgroundColor = UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 0.3)
        grayBackButton.alpha = 0
        self.view.addSubview(grayBackButton)
        self.view.sendSubview(toBack: grayBackButton)
        grayBackButton.addTarget(self, action: #selector(self.actionBackToMap(_:)), for: .touchUpInside)
    }
    
    func animateHeart() {
        buttonPinLike.tag = 0
        animatingHeart = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 22))
        animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        animatingHeart.layer.zPosition = 108
        uiviewPinDetailMainButtons.addSubview(animatingHeart)
        
        //
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        let transform: CGAffineTransform = CGAffineTransform(translationX: buttonPinLike.center.x, y: buttonPinLike.center.y)
        let path =  CGMutablePath()
        path.move(to: CGPoint(x:0,y:0), transform: transform)
        path.addLine(to: CGPoint(x:randomX-75, y:-randomY), transform: transform)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue(caTransform3D: CATransform3DMakeScale(randomSize, randomSize, 1))]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.duration = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = path
        orbit.calculationMode = kCAAnimationPaced
        animatingHeart.layer.add(orbit, forKey:"Move")
        animatingHeart.layer.add(fadeAnimation, forKey: "Opacity")
        animatingHeart.layer.add(scaleAnimation, forKey: "Scale")
        animatingHeart.layer.position = CGPoint(x: buttonPinLike.center.x, y: buttonPinLike.center.y)
    }
}
