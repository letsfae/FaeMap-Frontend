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
    var dictUserDisplayName = [String]()
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
//    var touchToReplyTimer: Timer! // Timer for touching pin comment cell
    //Change by Yao, abandon fileIdString
    
    var imageViewHotPin: UIImageView!
    var stringPlainTextViewTxt = ""
    
    var pinCommentsCount = 0
    
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
    
    enum PinState {
        case normal
        case read
        case hot
        case hotRead
    }
    var pinStateEnum: PinState = .normal
    
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
    
    var isKeyboardInThisView = true // trigger the function inside keyboard notification ctrl if in pin detail view
    
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
    
    var pinComments = [PinComment]()
    var pinDetailUsers = [PinDetailUser]()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("[viewWillAppear]")
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
            if self.pinTypeEnum != .place {
                self.loadInputToolBar()
                self.loadExtendView() // call func for loading extend view (mingjie jin)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if inputToolbar != nil {
            closeToolbarContentView()
            removeObservers()
            toolbarContentView.removeFromSuperview()
        }
        UIApplication.shared.statusBarStyle = .default
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - toolbar Content view delegate
    func showAlertView(withWarning text: String) {
        showAlert(title: text, message: "please try again")
    }
    
    func sendStickerWithImageName(_ name : String) {
        print("[sendStickerWithImageName] name: \(name)")
        let stickerMessage = "<faeSticker>\(name)</faeSticker>"
        sendMessage(stickerMessage, date: Date(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil)
        buttonSend.isEnabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
        UIView.animate(withDuration: 0.3) { 
            self.tableCommentsForPin.frame.size.height = screenHeight - 155
            self.draggingButtonSubview.frame.origin.y = screenHeight - 90
            self.closeToolbarContentView()
        }
        
    }
    
    func sendImages(_ images: [UIImage]) {
        if let image = images.first {
            uploadingFile(image: image)
        }
        UIView.animate(withDuration: 0.3) {
            self.tableCommentsForPin.frame.size.height = screenHeight - 155
            self.draggingButtonSubview.frame.origin.y = screenHeight - 90
            self.closeToolbarContentView()
        }
    }
    
    func showFullAlbum() {
        
    }
    
    func appendEmoji(_ name: String) {
        print("[appendEmojiWithImageName]")
        if inputToolbar != nil{
            buttonSend.isEnabled = true
            buttonSend.setImage(UIImage(named: "canSendMessage"), for: UIControlState())
            self.lableTextViewPlaceholder.isHidden = true
            inputToolbar.contentView.textView.text = inputToolbar.contentView.textView.text + "[\(name)]"
        }
    }
    func deleteLastEmoji() {
        print("[deleteEmoji]")
        if inputToolbar != nil{
            let previous = inputToolbar.contentView.textView.text!
            inputToolbar.contentView.textView.text = previous.stringByDeletingLastEmoji()
            if inputToolbar.contentView.textView.text == "" {
                self.lableTextViewPlaceholder.isHidden = false
                buttonSend.isEnabled = false
                buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
            }
        }
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
            self.pinTypeDecimal = 0
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
            self.pinTypeDecimal = 2
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
            self.pinTypeDecimal = 1
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
    
    func keyboardWillShow(_ notification: Notification) {
        
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isKeyboardInThisView {
                self.tableCommentsForPin.frame.size.height = screenHeight - 155 - keyboardHeight
                self.draggingButtonSubview.frame.origin.y = screenHeight - 90 - keyboardHeight
            }
            self.toolbarDistanceToBottom.constant = -keyboardHeight
            self.view.setNeedsUpdateConstraints()
        }, completion: {(done: Bool) in
            
        })
    }
    
    func keyboardDidShow(_ notification: Notification){
        toolbarContentView.keyboardShow = true
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if self.isKeyboardInThisView {
            self.tableCommentsForPin.frame.size.height = screenHeight - 155
            self.draggingButtonSubview.frame.origin.y = screenHeight - 90
        }
        UIView.animate(withDuration: 0.3, animations: {
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
        buttonKeyBoard.tag = 0
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.closeToolbarContentView()
            }, completion:{ (Bool) -> Void in
        })
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func showStikcer() {
        buttonKeyBoard.tag = 0
        resetToolbarButtonIcon()
        buttonSticker.setImage(UIImage(named: "stickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showStikcer()
        moveUpInputBarContentView(animated)
        self.tableCommentsForPin.frame.size.height = screenHeight - 155 - 271
        self.draggingButtonSubview.frame.origin.y = screenHeight - 90 - 271
    }
    
    func showLibrary() {
        buttonKeyBoard.tag = 0
        resetToolbarButtonIcon()
        buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showLibrary()
        moveUpInputBarContentView(animated)
        self.tableCommentsForPin.frame.size.height = screenHeight - 155 - 271
        self.draggingButtonSubview.frame.origin.y = screenHeight - 90 - 271
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
        if animated {
            self.toolbarContentView.frame.origin.y = screenHeight
            UIView.animate(withDuration: 0.3, animations: {
                self.moveUpInputBar()
                self.toolbarContentView.frame.origin.y = screenHeight - 271
                }, completion:{ (Bool) -> Void in
                    
                    
                    
            })
        } else {
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
    
//    //MARK: -  UIImagePickerController
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
//        
//        self.sendMessage(nil, date: Date(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil)
//        
//        //        UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
//        
//        picker.dismiss(animated: true, completion: nil)
//        
//    }
    
    func image(_ image:UIImage, didFinishSavingWithError error: NSError, contextInfo:AnyObject?) {
        self.appWillEnterForeground()
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
        buttonKeyBoard.tag = 1
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
