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

class PinDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FAEChatToolBarContentViewDelegate, UITextViewDelegate {
    
    // Delegate of this class
    weak var delegate: PinDetailDelegate?
    
    // Pin ID To Use In This Controller
    var pinIdSentBySegue: String = "-999"
    var pinStatus = ""
    var pinMarker = GMSMarker()
    var pinTypeDecimal = -999 // 0 -> comment, 1 -> chat_room, 2 -> story
    
    // Pin options
    var buttonShareOnPinDetail: UIButton!
    var buttonEditOnPinDetail: UIButton!
    var buttonSaveOnPinDetail: UIButton!
    var buttonDeleteOnPinDetail: UIButton!
    var buttonReportOnPinDetail: UIButton!
    
    var subviewTable: UIView!
    var animatingHeart: UIImageView!
    var anotherRedSlidingLine: UIView!
    var boolPinLiked = false
    var buttonBackToPinLists: UIButton!
    var buttonMoreOnPinCellExpanded = false
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
    var dictCommentsOnPinDetail = [[String: AnyObject]]()
    var imagePinUserAvatar: UIImageView!
    var imageViewSaved: UIImageView!
    var labelPinCommentsCount: UILabel!
    var labelPinDetailViewComments: UILabel!
    var labelPinDetailViewFeelings: UILabel!
    var labelPinDetailViewPeople: UILabel!
    var labelPinLikeCount: UILabel!
    var labelPinTimestamp: UILabel!
    var labelPinTitle: UILabel!
    var labelPinUserName: UILabel!
    var labelPinVoteCount: UILabel!
    var lableTextViewPlaceholder: UILabel!
    var moreButtonDetailSubview: UIImageView!
    var numberOfCommentTableCells: Int = 0
    var pinDetailLiked = false
    var pinDetailShowed = false
    var pinIDPinDetailView: String = "-999"
    var subviewNavigation: UIView!
    var tableCommentsForPin: UITableView!
    var textviewPinDetail: UITextView!
    var uiviewGrayBaseLine: UIView!
    var uiviewPinDetail: UIView!
    var uiviewPinDetailGrayBlock: UIView!
    var uiviewPinDetailMainButtons: UIView!
    var uiviewPinDetailThreeButtons: UIView!
    var uiviewPinUnderLine01: UIView!
    var uiviewPinUnderLine02: UIView!
    var uiviewRedSlidingLine: UIView!
    
    // For Dragging
    var pinSizeFrom: CGFloat = 0
    var pinSizeTo: CGFloat = 0
    
    // Like Function
    var pinLikeCount: Int = 0
    var isUpVoting = false
    var isDownVoting = false
    
    var buttonFakeTransparentClosingView: UIButton! // Fake Transparent View For Closing
    var thisIsMyPin = false // Check if this pin belongs to current user
    var backJustOnce = true // Control the back to pin detail button, prevent the more than once action
    
    var controlBoard: UIView! // A duplicate ControlBoard to hold
    
    // Toolbar
    var inputToolbar: JSQMessagesInputToolbarCustom!
    var isObservingInputTextView = false
    var inputTextViewContext = 0
    var inputTextViewMaximumHeight: CGFloat = 250 * screenHeightFactor * screenHeightFactor// the distance from the top of toolbar to top of screen
    var toolbarDistanceToBottom: NSLayoutConstraint!
    var toolbarHeightConstraint: NSLayoutConstraint!
    
    var toolBarExtendView : UIView! // an extend uiview for anynomus texting (mingjie jin)
    var isAnonymous = false // var to record is user is anonymous;
    
    //custom toolBar the bottom toolbar button
    var buttonSet = [UIButton]()
    var buttonSend : UIButton!
    var buttonKeyBoard : UIButton!
    var buttonSticker : UIButton!
    var buttonImagePicker : UIButton!
    var toolbarContentView: FAEChatToolBarContentView!
    
    var animatingHeartTimer: Timer! // Timer for animating heart
    var buttonNextPin: UIButton!
    var buttonPrevPin: UIButton!
    var draggingButtonSubview: UIView! // Another dragging button for UI effect
    var fileIdArray = [Int]()
    var firstLoadInputToolBar = true
    var grayBackButton: UIButton! // Background gray button, alpha = 0.3
    var imageViewMediaArray = [UIImageView]()
    var pinIcon: UIImageView! // Icon to indicate pin type
    var replyToUser = "" // Reply to specific user, set string as "" if no user is specified
    var scrollViewMedia: UIScrollView! // container to display pin's media
    var selectedMarkerPosition: CLLocationCoordinate2D!
    var subviewInputToolBar: UIView! // subview to hold input toolbar
    var switchedToFullboard = true // FullboardScrollView and TableViewCommentsOnPin control
    var touchToReplyTimer: Timer! // Timer for touching pin comment cell
    //Change by Yao, abandon fileIdString
    
    var imageViewHotPin: UIImageView!
    var stringPlainTextViewTxt = ""
    
    var lblEmptyCommentArea: UILabel!
    
    enum MediaMode {
        case small
        case large
    }
    var mediaMode: MediaMode = .small

    var lastContentOffset: CGFloat = 0
    
    var isSavedByMe = false
    enum PinType {
        case comment
        case media
        case chat_room
        case place
    }
    var pinTypeEnum: PinType = .media
    var pinTypeString = ""
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
    
    var isKeyboardInThisView = true
    
    var placeType = "burgers"
    var uiviewPlaceDetail: UIView!
    var uiviewPlaceLine: UIView!
    var imgPlaceQuickView: UIImageView!
    var imgPlaceType: UIImageView!
    var lblPlaceTitle: UILabel!
    var lblPlaceStreet: UILabel!
    var lblPlaceCity: UILabel!
    var btnGoToPinList_Place: UIButton!
    var btnMoreOptions_Place: UIButton!
    
    var strPlaceTitle = ""
    var strPlaceStreet = ""
    var strPlaceCity = ""
    var strPlaceImageURL = ""
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[viewWillAppear]")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.633, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.subviewNavigation.frame.origin.y = 0
            self.tableCommentsForPin.frame.origin.y = 65
            self.subviewTable.frame.origin.y = 65
            self.draggingButtonSubview.frame.origin.y = 292
            self.grayBackButton.alpha = 1
            self.pinIcon.alpha = 1
            self.buttonPrevPin.alpha = 1
            self.buttonNextPin.alpha = 1
            if self.pinTypeEnum == .place {
                self.uiviewPlaceDetail.frame.origin.y = 0
            }
        }, completion: { (done: Bool) in
            self.loadInputToolBar()
            self.loadExtendView() // call func for loading extend view (mingjie jin)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if inputToolbar != nil {
            closeToolbarContentView()
            removeObservers()
        }
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initPinBasicInfo() {
        switch pinTypeEnum {
        case .comment:
            self.pinTypeDecimal = 0
            self.labelPinTitle.text = "Comment"
            pinIconHeavyShadow = #imageLiteral(resourceName: "markerCommentPinHeavyShadow")
            textViewOriginalHeight = 100
            if scrollViewMedia != nil {
                scrollViewMedia.isHidden = true
                
            }
            if textviewPinDetail != nil {
                textviewPinDetail.isHidden = false
            }
            break
        case .media:
            self.pinTypeDecimal = 2
            self.labelPinTitle.text = "Story"
            pinIconHeavyShadow = #imageLiteral(resourceName: "markerMomentPinHeavyShadow")
            textViewOriginalHeight = 0
            if scrollViewMedia != nil {
                scrollViewMedia.isHidden = false
            }
            if textviewPinDetail != nil {
                textviewPinDetail.isHidden = true
            }
            break
        case .chat_room:
            self.pinTypeDecimal = 1
            self.labelPinTitle.text = "Chat"
            break
        case .place:
            
            break
        }
        labelPinTitle.textAlignment = .center
    }
    
    func getSeveralInfo() {
        getPinAttributeNum("\(self.pinTypeEnum)", pinID: pinIDPinDetailView)
        getPinInfo()
        getPinComments("\(self.pinTypeEnum)", pinID: pinIDPinDetailView, sendMessageFlag: false)
    }
    
    func loadTransparentButtonBackToMap() {
        grayBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        grayBackButton.backgroundColor = UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 0.3)
        grayBackButton.alpha = 0
        self.view.addSubview(grayBackButton)
        self.view.sendSubview(toBack: grayBackButton)
        grayBackButton.addTarget(self, action: #selector(self.actionBackToMap(_:)), for: .touchUpInside)
    }
    
    func loadInputToolBar() {
        if !firstLoadInputToolBar {
            return
        }
        firstLoadInputToolBar = false
        setupInputToolbar()
        setupToolbarContentView()
        addObservers()
        for constraint in self.inputToolbar.constraints{
            if constraint.constant == 90 {
                toolbarHeightConstraint = constraint
            }
        }
        if toolbarHeightConstraint == nil{
            toolbarHeightConstraint = NSLayoutConstraint(item:inputToolbar, attribute:.height,relatedBy:.equal,toItem:nil,attribute:.notAnAttribute ,multiplier:1,constant:90)
            self.inputToolbar.addConstraint(toolbarHeightConstraint)
            
            toolbarDistanceToBottom = NSLayoutConstraint(item:inputToolbar, attribute:.width,relatedBy:.equal,toItem:self.view,attribute:.width ,multiplier:1,constant:0)
            self.view.addConstraint(toolbarDistanceToBottom)
            
            toolbarDistanceToBottom = NSLayoutConstraint(item:inputToolbar, attribute:.bottom,relatedBy:.equal,toItem:self.view,attribute:.bottom ,multiplier:1,constant:0)
            self.view.addConstraint(toolbarDistanceToBottom)
            self.view.setNeedsUpdateConstraints()
        }
        adjustInputToolbarHeightConstraint(byDelta: -90) // A tricky way to set the toolbarHeight to default
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name:NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name:NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        
        if (self.isObservingInputTextView) {
            return;
        }
        let scrollView = self.inputToolbar.contentView.textView as UIScrollView
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        
        self.isObservingInputTextView = true
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        if (!self.isObservingInputTextView) {
            return;
        }
        
        self.inputToolbar.contentView.textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        self.isObservingInputTextView = false
    }
    
    func setupInputToolbar()
    {
        func loadInputBarComponent() {
            
            //        let camera = Camera(delegate_: self)
            let contentView = self.inputToolbar.contentView
            contentView?.backgroundColor = UIColor.white
            let contentOffset = (screenWidth - 42 - 29 * 5) / 4 + 29
            buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
            buttonKeyBoard.addTarget(self, action: #selector(self.showKeyboard(_:)), for: .touchUpInside)
            contentView?.addSubview(buttonKeyBoard)
            
            
            buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSticker.setImage(UIImage(named: "sticker"), for: .normal)
            buttonSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
            buttonSticker.addTarget(self, action: #selector(self.showStikcer), for: .touchUpInside)
            contentView?.addSubview(buttonSticker)
            
            buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .normal)
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
            contentView?.addSubview(buttonImagePicker)
            
            buttonImagePicker.addTarget(self, action: #selector(self.showLibrary), for: .touchUpInside)
            
            let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonCamera.setImage(UIImage(named: "camera"), for: .normal)
            buttonCamera.setImage(UIImage(named: "camera"), for: .highlighted)
            contentView?.addSubview(buttonCamera)
            
            buttonCamera.addTarget(self, action: #selector(self.showCamera), for: .touchUpInside)
            
            
            buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .highlighted)
            contentView?.addSubview(buttonSend)
            buttonSend.isEnabled = false
            buttonSend.addTarget(self, action: #selector(self.sendMessageButtonTapped), for: .touchUpInside)
            
            buttonSet.append(buttonKeyBoard)
            buttonSet.append(buttonSticker)
            buttonSet.append(buttonImagePicker)
            buttonSet.append(buttonCamera)
            buttonSet.append(buttonSend)
            
            for button in buttonSet{
                button.autoresizingMask = [.flexibleTopMargin]
            }
        }
        inputToolbar = JSQMessagesInputToolbarCustom(frame: CGRect(x: 0, y: screenHeight-90, width: screenWidth, height: 90))
        inputToolbar.contentView.textView.delegate = self
        inputToolbar.contentView.textView.tintColor = UIColor.faeAppRedColor()
        inputToolbar.contentView.textView.font = UIFont(name: "AvenirNext-Regular", size: 18)
        inputToolbar.contentView.textView.delaysContentTouches = false
        
        //should button to open anonymous extend view (mingjie jin)
        inputToolbar.contentView.heartButton.setImage(UIImage(named: "anonymousNormal"), for: UIControlState.normal)
        inputToolbar.contentView.heartButton.setImage(UIImage(named: "anonymousHighlight"), for: UIControlState.highlighted)
        inputToolbar.contentView.heartButton.addTarget(self, action:#selector(extendButtonAction(_:)), for: UIControlEvents.touchUpInside)
        inputToolbar.contentView.heartButtonHidden = false
        
        
        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 7, y: 3, width: 200, height: 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lableTextViewPlaceholder.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        lableTextViewPlaceholder.text = "Write a Comment..."
        inputToolbar.contentView.textView.addSubview(lableTextViewPlaceholder)
        
        inputToolbar.maximumHeight = 90
        subviewInputToolBar = UIView(frame: CGRect(x: 0, y: screenHeight-90, width: screenWidth, height: 90))
        subviewInputToolBar.backgroundColor = UIColor.white
        self.view.addSubview(subviewInputToolBar)
        subviewInputToolBar.layer.zPosition = 120
        self.view.addSubview(inputToolbar)
        inputToolbar.layer.zPosition = 121
        loadInputBarComponent()
        inputToolbar.isHidden = true
        subviewInputToolBar.isHidden = true
        
    }
    
    func setupToolbarContentView() {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0,y: screenHeight,width: screenWidth, height: 271))
        toolbarContentView.delegate = self
        toolbarContentView.cleanUpSelectedPhotos()
        toolbarContentView.setup(3)
        UIApplication.shared.keyWindow?.addSubview(toolbarContentView)
    }
    
    // Animation of the red sliding line
    func animationRedSlidingLine(_ sender: UIButton) {
        endEdit()
        if sender.tag == 1 {
//            tableCommentsForPin.isHidden = false
        }
        else if sender.tag == 3 {
//            tableCommentsForPin.isHidden = true
        }
        let tag = CGFloat(sender.tag)
        let centerAtOneSix = screenWidth / 6
        let targetCenter = CGFloat(tag * centerAtOneSix)
        print("[animationRedSlidingLine] did slide")
        UIView.animate(withDuration: 0.25, animations:({
            self.uiviewRedSlidingLine.center.x = targetCenter
            self.anotherRedSlidingLine.center.x = targetCenter
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    // Disable a button, make it unclickable
    func disableTheButton(_ button: UIButton) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: UIControlState())
        button.tintColor = UIColor.lightGray
        button.isUserInteractionEnabled = false
    }
    
    // Hide pin detail window
    func hidePinDetail() {
        if uiviewPinDetail != nil {
            if pinDetailShowed {
                actionBackToMap(self.buttonPinBackToMap)
                UIView.animate(withDuration: 0.5, animations: ({
                    
                }), completion: { (done: Bool) in
                    if done {
                        
                    }
                })
            }
        }
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
    
    func appWillEnterForeground(){
        
    }
    
    func keyboardWillShow(_ notification: Notification){
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        if isKeyboardInThisView {
            self.tableCommentsForPin.frame.size.height -= keyboardHeight
        }
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.toolbarDistanceToBottom.constant = -keyboardHeight
            self.view.setNeedsUpdateConstraints()
        }, completion: {(done: Bool) in
            
        })
    }
    
    func keyboardDidShow(_ notification: Notification){
        toolbarContentView.keyboardShow = true
        self.tableCommentsForPin.scrollToTop(animated: true)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if isKeyboardInThisView {
            self.tableCommentsForPin.frame.size.height = screenHeight - 90 - 65
        }
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.toolbarDistanceToBottom.constant = 0
            self.view.setNeedsUpdateConstraints()
            }, completion: nil)
    }
    
    func keyboardDidHide(_ notification: Notification){
        toolbarContentView.keyboardShow = false
    }
    
    
    //MARK: - keyboard input bar tapped event
    func showKeyboard(_ sender: UIButton) {
        resetToolbarButtonIcon()
        if sender.tag == 1 {
            sender.tag = 0
            isKeyboardInThisView = true
            self.buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
            self.inputToolbar.contentView.textView.resignFirstResponder()
            return
        }
        sender.tag = 1
        self.buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        self.toolbarContentView.showKeyboard()
        self.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    func showCamera() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.closeToolbarContentView()
            }, completion:{ (Bool) -> Void in
        })
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    func showStikcer() {
        resetToolbarButtonIcon()
        buttonSticker.setImage(UIImage(named: "stickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showStikcer()
        moveUpInputBarContentView(animated)
    }
    
    func showLibrary() {
        resetToolbarButtonIcon()
        buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showLibrary()
        moveUpInputBarContentView(animated)
    }
    
    func sendMessageButtonTapped() {
        sendMessage(self.inputToolbar.contentView.textView.text, date: Date(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil)
        buttonSend.isEnabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    func resetToolbarButtonIcon()
    {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        buttonSticker.setImage(UIImage(named: "sticker"), for: .normal)
        buttonSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .normal)
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    func closeToolbarContentView() {
        resetToolbarButtonIcon()
        moveDownInputBar()
        toolbarContentView.closeAll()
        toolbarContentView.frame.origin.y = screenHeight
    }
    
    func moveUpInputBar() {
        toolbarDistanceToBottom.constant = -271
        self.view.setNeedsUpdateConstraints()
    }
    
    func moveDownInputBar() {
        toolbarDistanceToBottom.constant = 0
        self.view.setNeedsUpdateConstraints()
    }
    
    func moveUpInputBarContentView(_ animated: Bool)
    {
        if(animated){
            self.toolbarContentView.frame.origin.y = screenHeight
            UIView.animate(withDuration: 0.3, animations: {
                self.moveUpInputBar()
                self.toolbarContentView.frame.origin.y = screenHeight - 271
                }, completion:{ (Bool) -> Void in
                    
                    
                    
            })
        }else{
            self.moveUpInputBar()
            self.toolbarContentView.frame.origin.y = screenHeight - 271
        }
    }
    
    // MARK: - send messages
    func sendMessage(_ text : String?, date: Date, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : Data?, audio : Data?) {
        if let realText = text {
            commentThisPin("\(self.pinTypeEnum)", pinID: pinIDPinDetailView, text: "\(self.replyToUser)\(realText)")
        }
        self.replyToUser = ""
        self.inputToolbar.contentView.textView.text = ""
        self.lableTextViewPlaceholder.isHidden = false
        self.inputToolbar.contentView.textView.resignFirstResponder()
    }
    
    //MARK: -  UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.sendMessage(nil, date: Date(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil)
        
        //        UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func image(_ image:UIImage, didFinishSavingWithError error: NSError, contextInfo:AnyObject?) {
        self.appWillEnterForeground()
    }
    
    //MARK: - toolbar Content view delegate
    func showAlertView(withWarning text:String) {
        
    }
    
    func sendStickerWithImageName(_ name : String) {
        
    }
    func sendImages(_ images:[UIImage]) {
        
    }
    
    func showFullAlbum() {
        
    }
    
    func endEdit() {
        self.view.endEditing(true)
        if inputToolbar != nil {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
    }
    
    //MARK: - TEXTVIEW delegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.inputToolbar.contentView.textView {
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if self.inputToolbar.contentView.textView.text.trimmingCharacters(in: spacing).isEmpty == false {
                self.lableTextViewPlaceholder.isHidden = true
            }
            else {
                self.lableTextViewPlaceholder.isHidden = false
            }
            if textView.text.characters.count == 0 {
                // when text has no char, cannot send message
                buttonSend.isEnabled = false
                buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
            } else {
                buttonSend.isEnabled = true
                buttonSend.setImage(UIImage(named: "canSendMessage"), for: UIControlState())
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        
        // adjust position for extend view (mingjie jin)
        if(screenHeight == 736) {
            toolBarExtendView.frame.origin.y += 271
        } else {
            toolBarExtendView.frame.origin.y += 258
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        self.showKeyboard(UIButton())
        
        // adjust position for extend view (mingjie jin)
        if(screenHeight == 736) {
            toolBarExtendView.frame.origin.y -= 271
        } else {
            toolBarExtendView.frame.origin.y -= 258
        }
    }
    
    //MARK: - observe key path
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        let textView = object as! UITextView
        if (textView == self.inputToolbar.contentView.textView && keyPath! == "contentSize") {
            
            let oldContentSize = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgSizeValue
            
            let newContentSize = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgSizeValue
            
            let dy = (newContentSize?.height)! - (oldContentSize?.height)!;
            
            if toolbarHeightConstraint != nil {
                self.adjustInputToolbarForComposerTextViewContentSizeChange(dy)
            }
        }
    }
    
    // set up content of extend view (mingjie jin)
    func loadExtendView() {
        print("[button frame] : \(inputToolbar.contentView.heartButton.frame)")
        let topBorder: CALayer = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        topBorder.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1).cgColor
        toolBarExtendView = UIView(frame: CGRect(x: 0, y: screenHeight - 141, width: screenWidth, height: 50))
        toolBarExtendView.isHidden = true
        toolBarExtendView.layer.zPosition = 121
        toolBarExtendView.backgroundColor = UIColor.white
        let anonyLabel = UILabel(frame: CGRect(x: screenWidth - 115, y: 14, width: 100, height: 25))
        anonyLabel.text = "Anonymous"
        anonyLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        anonyLabel.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
        anonyLabel.textAlignment = .center
        toolBarExtendView.addSubview(anonyLabel)
        toolBarExtendView.layer.addSublayer(topBorder)
        let checkbutton = UIButton(frame: CGRect(x: screenWidth - 149, y: 14, width: 22, height: 22))
        checkbutton.adjustsImageWhenHighlighted = false
        checkbutton.setImage(UIImage(named: "uncheckBoxGray"), for: UIControlState.normal)
        checkbutton.addTarget(self, action: #selector(checkboxAction(_:)), for: UIControlEvents.touchUpInside)
        toolBarExtendView.addSubview(checkbutton)
        view.addSubview(toolBarExtendView)
    }
    
    // action func for extend button (mingjie jin)
    
    func extendButtonAction(_ sender: UIButton) {
        if(toolBarExtendView.isHidden) {
            sender.setImage(UIImage(named: "anonymousHighlight"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "anonymousNormal"), for: .normal)
        }
        toolBarExtendView.isHidden = !toolBarExtendView.isHidden
    }
    
    // action func for check box button (mingjie jin)
    
    func checkboxAction(_ sender: UIButton) {
        if(isAnonymous) {
            sender.setImage(UIImage(named: "uncheckBoxGray"), for: UIControlState.normal)
        } else {
            sender.setImage(UIImage(named: "checkBoxGray"), for: UIControlState.normal)
        }
        isAnonymous = !isAnonymous
        //toolBarExtendView.frame.origin.x -= 271
    }
    
}
