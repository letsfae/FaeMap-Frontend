//
//  ChatViewController.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Photos
import MobileCoreServices
import CoreMedia
import AVFoundation
import RealmSwift

public let kAVATARSTATE = "avatarState"
public let kFIRSTRUN = "firstRun"
public var headerDeviceToken: Data!

class ChatViewController: JSQMessagesViewControllerCustom, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, SendMutipleImagesDelegate, LocationSendDelegate, FAEChatToolBarContentViewDelegate, CAAnimationDelegate, BoardsSearchDelegate, JSQAudioMediaItemDelegateCustom {
    var playingAudio: JSQAudioMediaItemCustom?
    
    func audioMediaItem(_ audioMediaItem: JSQAudioMediaItemCustom, didChangeAudioCategory category: String, options: AVAudioSessionCategoryOptions = [], error: Error?) {
    }
    
    func audioMediaItemDidStartPlayingAudio(_ audioMediaItem: JSQAudioMediaItemCustom, audioButton sender: UIButton) {
        if let current = playingAudio {
            if current != audioMediaItem {
                current.finishPlaying()
            }
        }
        playingAudio = audioMediaItem
    }
    
    // MARK: properties
    var uiviewNavBar: FaeNavBar!
    var uiviewLocationExtend = LocationExtendView()
    var toolbarContentView: FAEChatToolBarContentView!
    var uiviewNameCard: FMNameCardView!
    // custom toolBar the bottom toolbar button
    var btnSet = [UIButton]()
    var btnSend: UIButton!
    var btnKeyBoard: UIButton!
    var btnSticker: UIButton!
    var btnImagePicker: UIButton!
    var btnVoiceRecorder: UIButton!
    var btnLocation: UIButton!
    // heart animation related
    var imgHeart: UIImageView!
    var imgHeartDic: [CAAnimation: UIImageView] = [CAAnimation: UIImageView]()
    // the proxy of the keyboard
    var uiviewKeyboard: UIView!
    
    var dictArrInitMessages: [NSDictionary] = [] // load latest 15 messages before showing chatting
    var arrJSQMessages: [JSQMessage] = [] // data source of collectionView
    var arrStrMessagesKey: [String] = [] // the key of each message to tell whether it is loaded
    var arrDictMessages: [NSDictionary] = [] // same content as JSQMessages, but in dictionary format
    var dictMessageSent: NSDictionary = [:] // the message just sent, used to reload collectionView
    let intNumberOfMessagesOneTime = 15
    var intNumberOfMessagesLoaded = 0
    var intTotalNumberOfMessages: Int {
        get {
            if let lastMessage = arrDictMessages.last {
                return lastMessage["index"] as! Int
            }
            return 0
        }
    }
    
    var realmWithUser: RealmUser? // info of the other user of chatting
    var avatarDictionary: NSMutableDictionary! = [:] // avatars of users in this chatting
    var strChatRoomId: String! // chatRoomId in the firebase
    var strChatId: String! = "" // the chat Id returned by our server
    
    // the message bubble of mine
    var outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).outgoingMessagesBubbleImage(with: UIColor._2499090())
    // the message bubble of the other user
    let incomingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).incomingMessagesBubbleImage(with: UIColor.white)
    var boolInitialLoadComplete = false // the first time open this chat room
    var boolLoadingPreviousMessages = false // load previous message when scroll to the top
    var dateLastMarker: Date! = Date.distantPast // time of last messages sent
    var boolSentInLast5s = false // avoid mutiple timestamps when sending photos
    private var animatingHeartTimer: Timer! // a timer to show heart animation continously
    var boolJustSentHeart = false // check if user just sent a heart sticker and avoid sending heart continuously
    
    var boolGoToFullContent = false // go to full album, full map, taking photo from chatting
    var boolClosingToolbarContentView = false
    var floatScrollViewOriginOffset: CGFloat = 0.0 // origin offset when starting dragging
    var floatDistanceInputBarToBottom: CGFloat {
        get {
            return self.toolbarBottomLayoutGuide.constant
        }
        set {
            self.toolbarBottomLayoutGuide.constant = newValue
        }
    }
    let floatLocExtendHeight: CGFloat = 76
    //let floatInputBarHeight: CGFloat = 90
    var floatInputBarHeight: CGFloat {
        get {
            return self.toolbarHeightConstraint.constant
        }
    }
    let floatToolBarContentHeight: CGFloat = 271 + device_offset_bot
  
    //let realm = try! Realm()
    var arrRealmMessages: [RealmMessage_v2] = []
    var arrRealmUsers: [RealmUser] = []
    var arrUserIDs: [String] = []
    var resultRealmMessages: Results<RealmMessage_v2>!
    var notificationToken: NotificationToken?
    var intIsGroup: Int = 0
    // not used now
    let userDefaults = UserDefaults.standard
    var showAvatar: Bool = true //false not show avatar, true show avatar
    var firstLoad: Bool? // whether it is the first time to load this room.
    
    let vcLocDetail = LocDetailViewController()
    let vcPlaceDetail = PlaceDetailViewController()
    let vcCollection = CollectionsListDetailViewController()
    
    weak var mapDelegate: LocDetailDelegate?
    
    var uiviewSafeZone: UIView!
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor._241241241()
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        senderId = "\(Key.shared.user_id)"
        //senderDisplayName = realmWithUser!.display_name
        
        /*let realm = try! Realm()
        let messages = realm.objects(RealmMessage_v2.self).filter("login_user_id = '\(Key.shared.user_id)'")
        notificationToken = messages.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                print("initial")
                break
            case .update:
                print("update")
            case .error:
                print("error")
            }
        }*/
        
        let realm = try! Realm()
        for user_id in arrUserIDs {
            if let user = realm.filterUser(id: "\(user_id)") {
                arrRealmUsers.append(user)
            }
        }
        senderDisplayName = arrRealmUsers[1].display_name
        setAvatar()
        loadMessagesFromRealm()
        navigationBarSet()
        loadInputBarComponent()
        setupToolbarContentView()
        uiviewLocationExtend.isHidden = true
        uiviewLocationExtend.buttonCancel.addTarget(self, action: #selector(closeLocExtendView), for: .touchUpInside)
        view.addSubview(uiviewLocationExtend)
        DispatchQueue.main.async {
            self.moveDownInputBar()
        }
        setupNameCard()
        inputToolbar.contentView.textView.becomeFirstResponder()
        inputToolbar.contentView.textView.resignFirstResponder()
        
        /*for message in dictArrInitMessages {
            _ = insertMessage(message)
            self.intNumberOfMessagesLoaded += 1
        }
        self.finishReceivingMessage(animated: false)*/
        /* ///////// Felix
         let realm = try! Realm()
         let messagesToLoad = realm.objects(RealmMessage.self).filter("withUserID == %@", withUserId!).sorted(byKeyPath: "date")
         for i in (messagesToLoad.count - 10)..<messagesToLoad.count {
         let message = messagesToLoad[i]
         let item: NSDictionary = ["type": message.type, "senderName": message.senderName, "senderId": message.senderID, "message": message.message, "date": message.date, "latitude": message.latitude.value, "longitude": message.longitude.value, "place": message.place, "snapImage": message.snapImage?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue : 0)), "videoDuration": message.videoDuration.value, "isHeartSticker": message.isHeartSticker, "data": message.data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue : 0)), "keyValue": message.messageID, "hasTimeStamp": message.hasTimeStamp, "status": message.status]
         //print("_")
         _ = insertMessage(item)
         }
         ///////// */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        loadUserDefault()
        //loadNewMessage()
        
        if boolGoToFullContent {
            scrollToBottom(false)
            boolGoToFullContent = false
        }
        
        if !boolInitialLoadComplete {
            scrollToBottom(false)
            boolInitialLoadComplete = true
        }
        let initializeType = (FAEChatToolBarContentType.sticker.rawValue | FAEChatToolBarContentType.photo.rawValue | FAEChatToolBarContentType.audio.rawValue | FAEChatToolBarContentType.minimap.rawValue)
        DispatchQueue.main.async {
        self.toolbarContentView.setup(FAEChatToolBarContentType.sticker.rawValue)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //toolbarContentView.setup(FAEChatToolBarContentType.sticker.rawValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //removeObservers()
        playingAudio?.finishPlaying()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //ref.removeObserver(withHandle: _refHandle!)
        closeLocExtendView()
        moveDownInputBar()
        toolbarContentView.clearToolBarViews()
    }
    
    // MARK: setup    
    private func navigationBarSet() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navigationLeftItemTapped), for: .touchUpInside)        
        uiviewNavBar.lblTitle.text = arrRealmUsers[1].display_name
    }
    
    func loadInputBarComponent() {
        //        let camera = Camera(delegate_: self)
        let contentView = inputToolbar.contentView
        contentView?.backgroundColor = UIColor.white
        contentView?.textView.placeHolder = "Type Something..."
        contentView?.textView.contentInset = UIEdgeInsetsMake(3.0, 0.0, 1.0, 0.0)
        contentView?.textView.delegate = self
        
        let contentOffset = (screenWidth - 42 - 29 * 7) / 6 + 29
        btnKeyBoard = UIButton(frame: CGRect(x: 21, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        btnKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        btnKeyBoard.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
        contentView?.addSubview(btnKeyBoard)
        
        btnSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnSticker.setImage(UIImage(named: "sticker"), for: UIControlState())
        btnSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
        btnSticker.addTarget(self, action: #selector(showStikcer), for: .touchUpInside)
        contentView?.addSubview(btnSticker)
        
        btnImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnImagePicker.setImage(UIImage(named: "imagePicker"), for: UIControlState())
        btnImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
        contentView?.addSubview(btnImagePicker)
        btnImagePicker.addTarget(self, action: #selector(showLibrary), for: .touchUpInside)
        
        let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonCamera.setImage(UIImage(named: "camera"), for: UIControlState())
        buttonCamera.setImage(UIImage(named: "camera"), for: .highlighted)
        contentView?.addSubview(buttonCamera)
        buttonCamera.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
        
        btnVoiceRecorder = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: UIControlState())
        btnVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: .highlighted)
        btnVoiceRecorder.addTarget(self, action: #selector(showRecord), for: .touchUpInside)
        contentView?.addSubview(btnVoiceRecorder)
        
        btnLocation = UIButton(frame: CGRect(x: 21 + contentOffset * 5, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnLocation.setImage(UIImage(named: "shareLocation"), for: UIControlState())
        btnLocation.showsTouchWhenHighlighted = false
        btnLocation.addTarget(self, action: #selector(showMiniMap), for: .touchUpInside)
        contentView?.addSubview(btnLocation)
        
        btnSend = UIButton(frame: CGRect(x: 21 + contentOffset * 6, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnSend.setImage(UIImage(named: "cannotSendMessage"), for: .disabled)
        btnSend.setImage(UIImage(named: "cannotSendMessage"), for: .highlighted)
        btnSend.setImage(UIImage(named: "canSendMessage"), for: .normal)
        
        contentView?.addSubview(btnSend)
        btnSend.isEnabled = false
        btnSend.addTarget(self, action: #selector(ChatViewController.sendMessageButtonTapped), for: .touchUpInside)
        
        btnSet.append(btnKeyBoard)
        btnSet.append(btnSticker)
        btnSet.append(btnImagePicker)
        btnSet.append(buttonCamera)
        btnSet.append(btnLocation)
        btnSet.append(btnVoiceRecorder)
        btnSet.append(btnSend)
        
        for button in btnSet {
            button.autoresizingMask = [.flexibleTopMargin]
        }
        
        contentView?.heartButtonHidden = false
        contentView?.heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        contentView?.heartButton.addTarget(self, action: #selector(actionHoldingLikeButton(_:)), for: .touchDown)
        contentView?.heartButton.addTarget(self, action: #selector(actionLeaveLikeButton(_:)), for: .touchDragOutside)
        
        uiviewSafeZone = UIView(frame: (CGRect(x:0, y: 90, width: screenWidth, height: 300)))
        uiviewSafeZone.backgroundColor = .white
        contentView?.addSubview(uiviewSafeZone)
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func setupToolbarContentView() {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: floatToolBarContentHeight))
        toolbarContentView.delegate = self
        toolbarContentView.inputToolbar = inputToolbar
        toolbarContentView.cleanUpSelectedPhotos()
        view.addSubview(toolbarContentView)
        toolbarContentView.viewMiniLoc.btnSearch.addTarget(self, action: #selector(showFullLocationView), for: .touchUpInside)
        toolbarContentView.viewMiniLoc.btnSend.addTarget(self, action: #selector(sendLocationMessageFromMini), for: .touchUpInside)
    }
    
    func setupNameCard() {
        uiviewNameCard = FMNameCardView()
        view.addSubview(uiviewNameCard)
    }
    
    @objc func navigationLeftItemTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigationRightItemTapped() {
        // TODO
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        //inputToolbar.contentView.textView.addObserver(self, forKeyPath: "text", options: [.new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeInputMode), name: NSNotification.Name.UITextInputCurrentInputModeDidChange, object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        let textView = object as! UITextView
        if textView == inputToolbar.contentView.textView && keyPath! == "text" {
            
            let newString = (change![NSKeyValueChangeKey.newKey]! as! String)
            btnSend.isEnabled = newString.count > 0
        }
        if inputToolbar.contentView.textView.sizeChanged {
            scrollToBottom(false)
            inputToolbar.contentView.textView.sizeChanged = false
        }
    }
    
    func removeObservers() {
        inputToolbar.contentView.textView.removeObserver(self, forKeyPath: "text", context: nil)
    }
    
    // MARK: user default function
    func loadUserDefault() {
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(showAvatar, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        showAvatar = true
        //        showAvatar = userDefaults.boolForKey(kAVATARSTATE)
    }
    
    // MARK: JSQMessages Delegate (useless, but require implementation)
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    }
    
    //MARK: input bar tapped events
    @objc func showKeyboard() {
        resetToolbarButtonIcon()
        btnKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        inputToolbar.contentView.textView.becomeFirstResponder()
        toolbarContentView.showKeyboard()
        //scrollToBottom(false)
    }
    
    @objc func showStikcer() {
        view.endEditing(true)
        //toolbarContentView.setup(FAEChatToolBarContentType.sticker.rawValue)
        resetToolbarButtonIcon()
        btnSticker.setImage(UIImage(named: "stickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.boolKeyboardShow
        toolbarContentView.showStikcer()
        moveUpInputBarContentView(animated)
        scrollToBottom(false)
    }
    
    @objc func showLibrary() {
        view.endEditing(true)
        toolbarContentView.setup(FAEChatToolBarContentType.photo.rawValue)
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
            print("not authorized!")
            showAlertView(withWarning: "Cannot use this function without authorization to Photo!")
            return
        }
        resetToolbarButtonIcon()
        btnImagePicker.setImage(UIImage(named: "imagePickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.boolKeyboardShow
        toolbarContentView.showLibrary()
        uiviewLocationExtend.isHidden = true
        moveUpInputBarContentView(animated)
        scrollToBottom(false)
    }
    
    @objc func showCamera() {
        view.endEditing(true)
        uiviewLocationExtend.isHidden = true
        boolGoToFullContent = true
        UIView.animate(withDuration: 0.3, animations: {
            self.closeToolbarContentView()
        }, completion: nil)
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    @objc func showRecord() {
        view.endEditing(true)
        toolbarContentView.setup(FAEChatToolBarContentType.audio.rawValue)
        resetToolbarButtonIcon()
        btnVoiceRecorder.setImage(UIImage(named: "voiceMessage_red"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.boolKeyboardShow
        toolbarContentView.showRecord()
        moveUpInputBarContentView(animated)
        scrollToBottom(false)
    }
    
    @objc func showMiniMap() {
        view.endEditing(true)
        toolbarContentView.setup(FAEChatToolBarContentType.minimap.rawValue)
        resetToolbarButtonIcon()
        btnLocation.setImage(UIImage(named: "locationChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.boolKeyboardShow
        toolbarContentView.showMiniLocation()
        moveUpInputBarContentView(animated)
        scrollToBottom(false)
    }
    
    @objc func sendMessageButtonTapped() {
        if uiviewLocationExtend.isHidden {
            sendMeaages_v2(type: "text", text: inputToolbar.contentView.textView.text)
            //sendMessage(text: inputToolbar.contentView.textView.text, date: Date())
        } else {
            switch uiviewLocationExtend.strType {
            case "Location":
                let locDetail = "{\"latitude\":\"\(uiviewLocationExtend.location.coordinate.latitude)\", \"longitude\":\"\(uiviewLocationExtend.location.coordinate.longitude)\", \"address1\":\"\(uiviewLocationExtend.LabelLine1.text!)\", \"address2\":\"\(uiviewLocationExtend.LabelLine2.text!)\", \"address3\":\"\(uiviewLocationExtend.LabelLine3.text!)\", \"comment\":\"\(inputToolbar.contentView.textView.text ?? "")\"}"
                sendMeaages_v2(type: "[Location]", text: locDetail, media: uiviewLocationExtend.getImageData())
                break
            case "Place":
                if let place = uiviewLocationExtend.placeData {
                    let placeDetail = "{\"id\":\"\(place.id)\", \"name\":\"\(place.name)\", \"address\":\"\(place.address1),\(place.address2)\", \"imageURL\":\"\(place.imageURL)\"}"
                    sendMeaages_v2(type: "[Place]", text: placeDetail, media: uiviewLocationExtend.getImageData())
                }
                break
            default:
                break
            }
            //sendMessage(text: inputToolbar.contentView.textView.text, location: uiviewLocationExtend.location, snapImage: uiviewLocationExtend.getImageDate(), date: Date())
        }
        if uiviewLocationExtend.isHidden == false {
            uiviewLocationExtend.isHidden = true
            closeLocExtendView()
        }
        btnSend.isEnabled = false
    }
    
    //MARK: handle the position of input bar
    func moveUpInputBarContentView(_ animated: Bool) {
        collectionView.isScrollEnabled = false
        if animated {
            toolbarContentView.frame.origin.y = screenHeight
            floatDistanceInputBarToBottom = 0.0
            UIView.animate(withDuration: 0.3, animations: {
                self.setContraintsWhenInputBarMove(inputBarToBottom: self.floatToolBarContentHeight, keyboard: false)
            }, completion: { (_) -> Void in
                self.collectionView.isScrollEnabled = true
            })
        } else {
            self.setContraintsWhenInputBarMove(inputBarToBottom: self.floatToolBarContentHeight, keyboard: false)
            collectionView.isScrollEnabled = true
        }
    }
    
    func moveDownInputBar() {
        view.endEditing(true)
        setContraintsWhenInputBarMove(inputBarToBottom: device_offset_bot, keyboard: false)
    }
    
    // MARK: input text field delegate
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 0 {
            // when text has no char, cannot send message
            btnSend.isEnabled = false
        } else {
            btnSend.isEnabled = true
        }
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        btnKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        showKeyboard()
        btnSend.isEnabled = inputToolbar.contentView.textView.text.count > 0 || !uiviewLocationExtend.isHidden
    }
    
    override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
    
    // MARK: keyboard delegate
    @objc func keyboardWillShow(_ notification: NSNotification) {
        keyboardFrameChange(notification)
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        toolbarContentView.boolKeyboardShow = true
        setProxyKeyboardView()
        //if UITextInputMode.activeInputModes.filter
        
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        if uiviewKeyboard == nil || uiviewKeyboard.frame.origin.y >= screenHeight { // keyboard is not visiable
            return
        }
        if toolbarContentView.mediaContentShow { // show toolbar, no keyboard
            uiviewKeyboard.frame.origin.y = screenHeight
            return
        }
        keyboardFrameChange(notification)
    }
    
    @objc func keyboardDidHide(_ notification: NSNotification) {
        toolbarContentView.boolKeyboardShow = false
        uiviewKeyboard = nil
    }
    
    @objc func changeInputMode(_ notification: NSNotification) {
        // TODO
        //print("method change")
        //inputToolbar.contentView.textView.resignFirstResponder()
        //inputToolbar.contentView.textView.becomeFirstResponder()
        setProxyKeyboardView()
        if uiviewKeyboard != nil {
            //print(uiviewKeyboard.frame.height)
            //setContraintsWhenInputBarMove(inputBarToBottom: uiviewKeyboard.frame.height)
            //if uiviewKeyboard.frame.height != 258
        }
        if let currentMode = inputToolbar.contentView.textView.textInputMode {
            let _ = NSStringFromClass(type(of: currentMode))
            //print(className)
        }
    }
    
    @objc func keyboardDidChangeFrame(_ notification: NSNotification) {
        //print("frame changed")
        if uiviewKeyboard != nil {
            //print(uiviewKeyboard.frame.height)
            //setContraintsWhenInputBarMove(inputBarToBottom: uiviewKeyboard.frame.height)
        }
    }
    
    @objc func keyboardFrameChange(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            var distance: CGFloat = 0.0
            if (endFrame?.origin.y)! < screenHeight {
                distance = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: {
                self.setContraintsWhenInputBarMove(inputBarToBottom: distance, keyboard: true)
                if endFrame?.origin.y != screenHeight {
                    self.scrollToBottom(false)
                }
            },
            completion:{ (_) -> Void in
                //TODO debug keyboard
            })
        }
    }
    
    func setContraintsWhenInputBarMove(inputBarToBottom distance: CGFloat, keyboard notToolBar: Bool = true, isScrolling: Bool = false) {
        let extendHeight = uiviewLocationExtend.isHidden ? 0.0 : floatLocExtendHeight
        floatDistanceInputBarToBottom = distance + 0.0
        uiviewLocationExtend.frame.origin.y = screenHeight - distance - floatInputBarHeight - floatLocExtendHeight
        inputToolbar.frame.origin.y = screenHeight - distance - floatInputBarHeight - 0.0
        if !notToolBar {
            toolbarContentView.frame.origin.y = screenHeight - distance
        }
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
        if !isScrolling {
            let insets = UIEdgeInsetsMake(device_offset_top, 0.0, distance + floatInputBarHeight + extendHeight, 0.0)
            self.collectionView.contentInset = insets
            self.collectionView.scrollIndicatorInsets = insets
        }
    }
    
    func setProxyKeyboardView() {
        var keyboardViewProxy = inputToolbar.contentView.textView.inputAccessoryView?.superview
        let windows = UIApplication.shared.windows
        for window in windows.reversed() {
            let className = NSStringFromClass(type(of: window))
            if className == "UIRemoteKeyboardWindow" {
                for subview in window.subviews {
                    for hostview in subview.subviews {
                        let hostClassName = NSStringFromClass(type(of: hostview))
                        if hostClassName == "UIInputSetHostView" {
                            keyboardViewProxy = hostview
                        }
                    }
                }
            }
        }
        uiviewKeyboard = keyboardViewProxy
    }
    
    // MARK: scroll view delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if inputToolbar.contentView.textView.sizeChanged && toolbarContentView.boolKeyboardShow {
            setContraintsWhenInputBarMove(inputBarToBottom: uiviewKeyboard.frame.height)            
            return
        }
        if scrollView == collectionView {
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            var dragDistanceY = scrollViewCurrentOffset - floatScrollViewOriginOffset
            //print("current offset: \(scrollViewCurrentOffset)")
            if dragDistanceY < 0
                && (toolbarContentView.mediaContentShow || toolbarContentView.boolKeyboardShow)
                && !boolClosingToolbarContentView && scrollView.isScrollEnabled == true {
                if toolbarContentView.boolKeyboardShow {
                    if uiviewKeyboard == nil || uiviewKeyboard.frame.origin.y >= screenHeight {
                        return
                    }
                    /*if inputToolbar.contentView.textView.sizeChanged {
                        setContraintsWhenInputBarMove(inputBarToBottom: uiviewKeyboard.frame.height)
                        inputToolbar.contentView.textView.sizeChanged = false
                        return
                    }*/
                    let keyboardHeight = uiviewKeyboard.frame.height
                    if -dragDistanceY > keyboardHeight {
                        dragDistanceY = -keyboardHeight
                    }
                    setContraintsWhenInputBarMove(inputBarToBottom: keyboardHeight + dragDistanceY, keyboard: true, isScrolling: true)
                    UIView.animate(withDuration: 0, delay: TimeInterval(0), options: [.beginFromCurrentState], animations: {
                        self.uiviewKeyboard.frame.origin.y = screenHeight - keyboardHeight - dragDistanceY
                    }, completion: nil)
                } else {
                    if -dragDistanceY > floatToolBarContentHeight {
                        dragDistanceY = -floatToolBarContentHeight
                    }
                    setContraintsWhenInputBarMove(inputBarToBottom: floatToolBarContentHeight + dragDistanceY + 0.0, keyboard: false, isScrolling: true)
                }
            }
            if scrollViewCurrentOffset < 1 && !boolLoadingPreviousMessages {
                //loadPreviousMessages()
                loadPrevMessagesFromRealm()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            floatScrollViewOriginOffset = scrollView.contentOffset.y
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == collectionView {
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            if scrollViewCurrentOffset - floatScrollViewOriginOffset < -5 {
                UIView.setAnimationsEnabled(false)
                self.inputToolbar.contentView.textView.resignFirstResponder()
                UIView.setAnimationsEnabled(true)
                
                boolClosingToolbarContentView = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.setContraintsWhenInputBarMove(inputBarToBottom: device_offset_bot, keyboard: false)
                    if self.uiviewKeyboard != nil {
                        self.uiviewKeyboard.frame.origin.y = screenHeight
                    }
                }, completion: { (_) -> Void in
                    self.toolbarContentView.closeAll()
                    self.resetToolbarButtonIcon()
                    self.toolbarContentView.cleanUpSelectedPhotos()
                    self.boolClosingToolbarContentView = false
                })
            }
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    }

    // MARK: quick photo picker
    func showFullAlbum() {
        closeToolbarContentView()
        boolGoToFullContent = true
        let layout = UICollectionViewFlowLayout()
        let vcFullAlbum = FullAlbumCollectionViewController(collectionViewLayout: layout)
        vcFullAlbum.imageDelegate = self
        navigationController?.pushViewController(vcFullAlbum, animated: true)
    }
    
    // MARK: handle events after user took a photo/video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let type = info[UIImagePickerControllerMediaType] as! String
        switch type {
        case (kUTTypeImage as String as String):
            let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
            sendMeaages_v2(type: "[Picture]", text: "[Picture]", media: RealmChat.compressImageToData(picture))
            //sendMessage(picture: picture, date: Date())
            
            UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        case (kUTTypeMovie as String as String):
            let movieURL = info[UIImagePickerControllerMediaURL] as! URL
            
            //get duration of the video
            let asset = AVURLAsset(url: movieURL)
            let duration = CMTimeGetSeconds(asset.duration)
            let seconds = Int(ceil(duration))
            
            /*let imageGenerator = AVAssetImageGenerator(asset: asset)
            var time = asset.duration
            time.value = 0
            
            //get snapImage
            var snapImage = UIImage()
            do {
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                snapImage = UIImage(cgImage: imageRef)
            } catch {
                //Handle failure
            }
            
            var imageData = UIImageJPEGRepresentation(snapImage, 1)
            let factor = min(5000000.0 / CGFloat(imageData!.count), 1.0)
            imageData = UIImageJPEGRepresentation(snapImage, factor)*/
            
            let path = movieURL.path
            let data = FileManager.default.contents(atPath: path)
            //sendMessage(video: data, videoDuration: seconds, snapImage: imageData, date: Date())
            sendMeaages_v2(type: "[Video]", text: "[\"\(seconds)\"]", media: data)
            break
        default:
            break
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // after saving the photo, refresh the album
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError, contextInfo: AnyObject?) {
        appWillEnterForeground()
    }
    
    // MARK: mini-map picker
    @objc func showFullLocationView(_ sender: UIButton) {
        // TODO
        closeToolbarContentView()
        boolGoToFullContent = true
        let vc = SelectLocationViewController()
        vc.boolFromChat = true
        vc.boolSearchEnabled = true
        vc.delegate = self
        Key.shared.selectedLoc = LocManager.shared.curtLoc.coordinate
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // BoardsSearchDelegate
    func sendLocationBack(address: RouteAddress) {
        let location = CLLocation(latitude: address.coordinate.latitude, longitude: address.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            guard let response = placemarks?[0] else { return }
            self.addResponseToLocationExtend(response: response, withMini: false)
        })
        AddPinToCollectionView().mapScreenShot(coordinate: CLLocationCoordinate2D(latitude: address.coordinate.latitude, longitude: address.coordinate.longitude)) { (snapShotImage) in
            self.uiviewLocationExtend.setAvator(image: snapShotImage)
        }
        
        /*CLGeocoder().reverseGeocodeLocation(CLLocation(latitude:  address.coordinate.latitude, longitude: address.coordinate.longitude), completionHandler: { (placemarks, error) -> Void in
            guard let response = placemarks?[0] else { return }
            
            self.addResponseToLocationExtend(response: response, withMini: false)
            //self.sendLocationMessageFromMini(UIButton())
            self.inputToolbar.contentView.textView.becomeFirstResponder()
        })*/
    }
    
    func sendPlaceBack(placeData: PlacePin) {
        downloadImage(URL: placeData.imageURL) { (rawData) in
            guard let data = rawData else { return }
            self.uiviewLocationExtend.placeData = placeData
            self.uiviewLocationExtend.setAvator(image: UIImage(data: data)!)
            self.uiviewLocationExtend.setToPlace()
            self.uiviewLocationExtend.isHidden = false
            let extendHeight = self.uiviewLocationExtend.isHidden ? 0 : self.floatLocExtendHeight
            var distance = self.floatInputBarHeight + extendHeight
            distance += self.floatToolBarContentHeight
            let insets = UIEdgeInsetsMake(0.0, 0.0, distance, 0.0)
            self.collectionView.contentInset = insets
            self.collectionView.scrollIndicatorInsets = insets
            self.scrollToBottom(false)
            self.btnSend.isEnabled = true
            self.inputToolbar.contentView.textView.becomeFirstResponder()
        }
    }
    
    @objc func closeLocExtendView() {
        uiviewLocationExtend.isHidden = true
        let insets = UIEdgeInsetsMake(device_offset_top, 0.0, collectionView.contentInset.bottom - floatLocExtendHeight, 0.0)
        self.collectionView.contentInset = insets
        self.collectionView.scrollIndicatorInsets = insets
        btnSend.isEnabled = inputToolbar.contentView.textView.text.count > 0
    }
    
    @objc func sendLocationMessageFromMini(_ sender: UIButton) {
        if let mapview = toolbarContentView.viewMiniLoc.mapView {
            UIGraphicsBeginImageContext(mapview.frame.size)
            mapview.layer.render(in: UIGraphicsGetCurrentContext()!)
            if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext() {
                uiviewLocationExtend.setAvator(image: screenShotImage)
                let location = CLLocation(latitude: mapview.camera.centerCoordinate.latitude, longitude: mapview.camera.centerCoordinate.longitude)
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
                    (placemarks, error) -> Void in
                    guard let response = placemarks?[0] else { return }
                    self.addResponseToLocationExtend(response: response, withMini: true)
                })
            }
        }
    }
    
    func addResponseToLocationExtend(response: CLPlacemark, withMini: Bool) {
        uiviewLocationExtend.setToLocation()
        if let lines = response.addressDictionary?["FormattedAddressLines"] as? [String] {
            uiviewLocationExtend.setLabel(texts: lines)
        }
        /*texts.append((response.subThoroughfare)! + " " + (response.thoroughfare)!)
        var cityText = response.locality
        if response.administrativeArea != nil {
            cityText = cityText! + ", " + (response.administrativeArea)!
        }
        if response.postalCode != nil {
            cityText = cityText! + " " + (response.postalCode)!
        }
        texts.append(cityText!)
        texts.append((response.country)!)*/
        
        //uiviewLocationExtend.setLabel(texts: texts)
        uiviewLocationExtend.location = CLLocation(latitude: toolbarContentView.viewMiniLoc.mapView.camera.centerCoordinate.latitude, longitude: toolbarContentView.viewMiniLoc.mapView.camera.centerCoordinate.longitude)
        
        uiviewLocationExtend.isHidden = false
        let extendHeight = uiviewLocationExtend.isHidden ? 0 : floatLocExtendHeight
        var distance = floatInputBarHeight + extendHeight
        if withMini {
            distance += floatToolBarContentHeight
        }
        let insets = UIEdgeInsetsMake(0.0, 0.0, distance, 0.0)
        self.collectionView.contentInset = insets
        self.collectionView.scrollIndicatorInsets = insets
        scrollToBottom(false)
        btnSend.isEnabled = true
    }
    
    // MARK: heart button related
    @objc private func heartButtonTapped() {
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
            animatingHeartTimer = nil
        }
        //animateHeart()
        if !boolJustSentHeart {
            //sendMessage(sticker: #imageLiteral(resourceName: "pinDetailLikeHeartFullLarge"), isHeartSticker: true, date: Date())
            sendMeaages_v2(type: "[Heart]", text: "pinDetailLikeHeartFullLarge")
            boolJustSentHeart = true
        }
    }
    
    @objc private func actionHoldingLikeButton(_ sender: UIButton) {
        if animatingHeartTimer == nil {
            animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(animateHeart), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func actionLeaveLikeButton(_ sender: UIButton) {
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
            animatingHeartTimer = nil
        }
    }
    
    @objc private func animateHeart() {
        imgHeart = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 22))
        imgHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        imgHeart.layer.opacity = 0
        inputToolbar.contentView.addSubview(imgHeart)
        
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        let transform: CGAffineTransform = CGAffineTransform(translationX: inputToolbar.contentView.heartButton.center.x, y: inputToolbar.contentView.heartButton.center.y)
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
        fadeAnimation.duration = 1
        fadeAnimation.delegate = self
        
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = path
        orbit.calculationMode = kCAAnimationPaced
        imgHeart.layer.add(orbit, forKey: "Move")
        imgHeart.layer.add(fadeAnimation, forKey: "Opacity")
        imgHeart.layer.add(scaleAnimation, forKey: "Scale")
        imgHeart.layer.position = CGPoint(x: inputToolbar.contentView.heartButton.center.x, y: inputToolbar.contentView.heartButton.center.y)
    }
    
    // CAAnimationDelegate
    func animationDidStart(_ anim: CAAnimation) {
        if anim.duration == 1 {
            imgHeartDic[anim] = imgHeart
            let seconds = 0.5
            let delay = seconds * Double(NSEC_PER_SEC) // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.inputToolbar.contentView.sendSubview(toBack: self.imgHeartDic[anim]!)
            })
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim.duration == 1 && flag {
            imgHeartDic[anim]?.removeFromSuperview()
            imgHeartDic[anim] = nil
        }
    }
    
    // MARK: utilities
    
    private func setAvatar() {
        createAvatars()
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 39, height: 39)
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 39, height: 39)
        if collectionView != nil {
            collectionView.reloadData()
        }
    }
    
    private func createAvatars() {
        for user in arrRealmUsers {
            var avatarJSQ: JSQMessagesAvatarImage
            if let avatarData = user.avatar?.userSmallAvatar {
                let avatarImg = UIImage(data: avatarData as Data)
                avatarJSQ = JSQMessagesAvatarImage(avatarImage: avatarImg, highlightedImage: avatarImg, placeholderImage: avatarImg)
            } else {
                avatarJSQ = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
            }
            avatarDictionary.addEntries(from: [user.id : avatarJSQ])
        }
        /*let currentUserAvatar = avatarDic[Key.shared.user_id] != nil ? JSQMessagesAvatarImage(avatarImage: avatarDic[Key.shared.user_id], highlightedImage: avatarDic[Key.shared.user_id], placeholderImage: avatarDic[Key.shared.user_id]) : JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        let withUserAvatar = avatarDic[Int(realmWithUser!.id)!] != nil ? JSQMessagesAvatarImage(avatarImage: avatarDic[Int(realmWithUser!.id)!], highlightedImage: avatarDic[Int(realmWithUser!.id)!], placeholderImage: avatarDic[Int(realmWithUser!.id)!]) : JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        avatarDictionary = ["\(Key.shared.user_id)": currentUserAvatar!, realmWithUser!.id: withUserAvatar!]*/
    }
    
    // scroll to the bottom of all messages
    func scrollToBottom(_ animated: Bool) {
        let currentHeight = collectionView!.collectionViewLayout.collectionViewContentSize.height
        let extendHeight = uiviewLocationExtend.isHidden ? 0.0 : floatLocExtendHeight
        let currentVisibleHeight = inputToolbar.frame.origin.y - 65 - device_offset_top - extendHeight
        if currentHeight > currentVisibleHeight {
            collectionView?.setContentOffset(CGPoint(x: 0, y: currentHeight - currentVisibleHeight), animated: animated)
        }
        
        /*let item = collectionView(collectionView!, numberOfItemsInSection: 0) - 1
        if item >= 0 {
            let lastItemIndex = IndexPath(item: item, section: 0)
            collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: animated)
        }*/
    }
    
    // dismiss the toolbar content view
    func closeToolbarContentView() {
        resetToolbarButtonIcon()
        moveDownInputBar()
        scrollToBottom(false)
        toolbarContentView.closeAll()
    }
    
    // change every button to its origin state
    fileprivate func resetToolbarButtonIcon() {
        btnKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        btnKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        btnSticker.setImage(UIImage(named: "sticker"), for: UIControlState())
        btnSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
        btnImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
        btnImagePicker.setImage(UIImage(named: "imagePicker"), for: UIControlState())
        btnVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: UIControlState())
        btnVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: .highlighted)
        btnLocation.setImage(UIImage(named: "shareLocation"), for: UIControlState())
        btnSend.isEnabled = !uiviewLocationExtend.isHidden || inputToolbar.contentView.textView.text.count > 0
    }
    
    // allow adding timestamp to message (used in SendLoadMessages)
    @objc func enableTimeStamp() {
        boolSentInLast5s = false
    }
    
    // show alert message
    func showAlertView(withWarning text: String) {
        let alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
 
    // need to refresh the album because user might take a photo outside the app
    @objc func appWillEnterForeground() {
        collectionView.reloadData()
        toolbarContentView.reloadPhotoAlbum()
    }

    func appendEmoji(_ name: String) { }
    
    func deleteLastEmoji() { }
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) { }
}
