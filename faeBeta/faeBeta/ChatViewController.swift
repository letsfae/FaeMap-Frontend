//
//  ChatViewController.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase
import Photos
import MobileCoreServices
import CoreMedia
import AVFoundation

public let kAVATARSTATE = "avatarState"
public let kFIRSTRUN = "firstRun"
public var headerDeviceToken: Data!

class ChatViewController: JSQMessagesViewControllerCustom, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, SendMutipleImagesDelegate, LocationSendDelegate, FAEChatToolBarContentViewDelegate, CAAnimationDelegate {
    //MARK: - properties
    var ref = Database.database().reference().child(fireBaseRef) // reference to all chat room
    var roomRef: DatabaseReference?
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = [] //
    var loaded: [NSDictionary] = [] // load dict from firebase that this chat room all message
    
    var avatarImageDictionary: NSMutableDictionary? //not use anymore
    var avatarDictionary: NSMutableDictionary? //not use anymore
    //
    var showAvatar: Bool = true //false not show avatar , true show avatar
    var firstLoad: Bool? // whether it is the first time to load this room.
    
    //Bryan
    //var withUser : FaeWithUser?
    var realmWithUser: RealmUser?
    //ENDBryan
    
    var uiviewNavBar: FaeNavBar!
    
    var withUserId: String? // the user id we chat to
    var withUserName: String? // the user name we chat to
    var currentUserId: String? // my user id
    var recent: NSDictionary? //recent chat room message
    var chatRoomId: String!
    var chat_id: String? //the chat Id returned by the server
    var initialLoadComplete: Bool = false // the first time open this chat room, false means we need to load every message to the chat room, true means we only need to load the new messages.
    var outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).outgoingMessagesBubbleImage(with: UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0))
    //the message I sent bubble
    let incomingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).incomingMessagesBubbleImage(with: UIColor.white)
    //the message other person sent bubble
    let userDefaults = UserDefaults.standard
    
    //voice MARK: has bug here can record and upload but can't replay after download,
    var fileName = "audioFile.caf"
    //    var soundPlayer : AVAudioPlayer!
    
    //custom toolBar the bottom toolbar button
    private var buttonSet = [UIButton]()
    private var buttonSend: UIButton!
    private var buttonKeyBoard: UIButton!
    private var buttonSticker: UIButton!
    private var buttonImagePicker: UIButton!
    private var buttonVoiceRecorder: UIButton!
    private var buttonLocation: UIButton!
    
    // a timer to show heart animation continously
    private var animatingHeartTimer: Timer!
    
    var isContinuallySending = false // this virable is used to avoid mutiple time stamp when sending photos, true: did send sth in last 5s
    var userJustSentHeart = false // this virable is used to check if user just sent a heart sticker and avoid sending heart continuously
    
    //toolbar content
    var toolbarContentView: FAEChatToolBarContentView!
    
    //scroll view
    var isClosingToolbarContentView = false
    var scrollViewOriginOffset: CGFloat! = 0
    
    //step by step loading
    let numberOfMessagesOneTime = 15
    var numberOfMeesagesReceived = 0
    var numberOfMessagesLoaded = 0
    var totalNumberOfMessages: Int {
        get {
            if let lastMessage = objects.last {
                return lastMessage["index"] as! Int
            }
            return 0
        }
        set {
        }
    }
    
    var isLoadingPreviousMessages = false
    
    //time stamp
    var lastMarkerDate: Date! = Date.distantPast
    
    // heart animation related
    var animatingHeart: UIImageView!
    var animHeartDic: [CAAnimation: UIImageView] = [CAAnimation: UIImageView]()
    
    // locationExtendView
    var locExtendView = LocationExtendView()
    
    fileprivate func observeTyping() {}
    
    var keyboardHeight: CGFloat = 0.0
    var toolbarLastY: CGFloat = screenHeight - 90
    var collectionViewLastBottomInset: CGFloat = 90
    // MARK: - view life cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //update recent
        print("chat view will disappear")
        //self.navigationController?.navigationBar.isHidden = false
        //closeToolbarContentView()
        //moveUpInputBar()
        //closeLocExtendView()
        //moveDownInputBar()
        toolbarLastY = inputToolbar.frame.origin.y
        collectionViewLastBottomInset = collectionView.contentInset.bottom
        removeObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("chat view did disappear")
        closeToolbarContentView()
        closeLocExtendView()
        moveDownInputBar()
        
        toolbarContentView.clearToolBarViews()
        
        //        messages = []
        //        objects = []
        //        loaded = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("chat view did appear")
        //print("set up tool bar views")
        inputToolbar.frame.origin.y = toolbarLastY
        //collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: collectionViewLastBottomInset, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: collectionViewLastBottomInset, right: 0.0)
        //collectionView.isScrollEnabled = true
        scrollToBottom(false)
        let initializeType = (FAEChatToolBarContentType.sticker.rawValue | FAEChatToolBarContentType.photo.rawValue | FAEChatToolBarContentType.audio.rawValue)
        toolbarContentView.setup(initializeType)
        
    }
    
    override func viewDidLoad() {
        print("chat view did load")
        super.viewDidLoad()
        
        navigationBarSet()
        collectionView.backgroundColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1.0) // override jsq collection view
        senderId = "\(Key.shared.user_id)"
        //Bryan
        //        senderDisplayName = realmWithUser!.userName
        senderDisplayName = realmWithUser!.userNickName
        //ENDBryan
        inputToolbar.contentView.textView.delegate = self
        
        //load firebase messages
        loadMessages()
        // Do any additional setup after loading the view.
        loadInputBarComponent()
        
        inputToolbar.contentView.textView.placeHolder = "Type Something..."
        inputToolbar.contentView.backgroundColor = UIColor.white
        inputToolbar.contentView.textView.contentInset = UIEdgeInsetsMake(3.0, 0.0, 1.0, 0.0)
        setupToolbarContentView()
        
        // new feature for location
        toolbarContentView.miniLocation.buttonSearch.addTarget(self, action: #selector(showFullLocationView), for: .touchUpInside)
        toolbarContentView.miniLocation.buttonSend.addTarget(self, action: #selector(sendLocationMessageFromMini), for: .touchUpInside)
        
        locExtendView.isHidden = true
        locExtendView.buttonCancel.addTarget(self, action: #selector(closeLocExtendView), for: .touchUpInside)
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //view.addGestureRecognizer(tap)
        
        //let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        //swipeRight.direction = .right
        //view.addGestureRecognizer(swipeRight)
        let initializeType = (FAEChatToolBarContentType.sticker.rawValue | FAEChatToolBarContentType.photo.rawValue | FAEChatToolBarContentType.audio.rawValue)
        toolbarContentView.setup(initializeType)
       
        view.addSubview(locExtendView)
        moveDownInputBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //check user default
        print("chat view will appear")
        super.viewWillAppear(true)
        addObservers()
        loadUserDefault()
        // This line is to fix the collectionView messed up function
        //moveDownInputBar()
        getAvatar()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil && chatRoomId != nil {
            roomRef?.removeAllObservers()
        }
    }
    
    func navigationBarPopView() {
        toolbarContentView.clearToolBarViews()
        //        navigationController?.popViewController(animated:)
    }
    
    // MARK: - setup
    
    private func navigationBarSet() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
        //uiviewNavBar.leftBtn.addTarget(self.navigationController, action: #selector(self.navigationController?.popViewController(animated:)), for: .touchUpInside)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navigationLeftItemTapped), for: .touchUpInside)
        
        uiviewNavBar.lblTitle.text = realmWithUser!.userNickName
        /*
(??)        self.navigationController?.navigationBar.isHidden = false
(??)        self.navigationController?.navigationBar.topItem?.title = ""
(??)        let attributes = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : UIColor._898989()] as [String : Any]
(??)        self.navigationController?.navigationBar.tintColor = UIColor._2499090()
(??)        self.navigationController!.navigationBar.titleTextAttributes = attributes
(??)        self.navigationController?.navigationBar.shadowImage = nil
        
        //ATTENTION: Temporary comment it here because it's not used for now
        //        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "bellHollow"), style: .Plain, target: self, action: #selector(ChatViewController.navigationItemTapped))
        
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navigationBack"), style: .plain, target: navigationController, action: #selector(navigationController?.popViewController(animated:)))
        
        navigationItem.leftBarButtonItem = leftButton
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        //Bryan
        //titleLabel.text = realmWithUser!.userName
        titleLabel.text = realmWithUser!.userNickName
        //ENDBryan
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        navigationItem.titleView = titleLabel
         */
    }
    
    func navigationLeftItemTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addObservers() {
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        inputToolbar.contentView.textView.addObserver(self, forKeyPath: "text", options: [.new], context: nil)
    }
    
    func removeObservers() {
        inputToolbar.contentView.textView.removeObserver(self, forKeyPath: "text", context: nil)
    }
    
    //MARK: user default function
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
    
    //MARK: load custom input tool bar
    
    func loadInputBarComponent() {
        
        //        let camera = Camera(delegate_: self)
        let contentView = inputToolbar.contentView
        let contentOffset = (screenWidth - 42 - 29 * 7) / 6 + 29
        buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        buttonKeyBoard.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
        contentView?.addSubview(buttonKeyBoard)
        
        buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonSticker.setImage(UIImage(named: "sticker"), for: UIControlState())
        buttonSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
        buttonSticker.addTarget(self, action: #selector(showStikcer), for: .touchUpInside)
        contentView?.addSubview(buttonSticker)
        
        buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: UIControlState())
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
        contentView?.addSubview(buttonImagePicker)
        
        buttonImagePicker.addTarget(self, action: #selector(showLibrary), for: .touchUpInside)
        
        let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonCamera.setImage(UIImage(named: "camera"), for: UIControlState())
        buttonCamera.setImage(UIImage(named: "camera"), for: .highlighted)
        contentView?.addSubview(buttonCamera)
        
        buttonCamera.addTarget(self, action: #selector(ChatViewController.showCamera), for: .touchUpInside)
        
        buttonVoiceRecorder = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: UIControlState())
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: .highlighted)
        //add a function
        buttonVoiceRecorder.addTarget(self, action: #selector(showRecord), for: .touchUpInside)
        
        contentView?.addSubview(buttonVoiceRecorder)
        
        buttonLocation = UIButton(frame: CGRect(x: 21 + contentOffset * 5, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonLocation.setImage(UIImage(named: "shareLocation"), for: UIControlState())
        buttonLocation.showsTouchWhenHighlighted = false
        //add a function
        buttonLocation.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)
        contentView?.addSubview(buttonLocation)
        
        buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 6, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .disabled)
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .highlighted)
        buttonSend.setImage(UIImage(named: "canSendMessage"), for: .normal)
        
        contentView?.addSubview(buttonSend)
        buttonSend.isEnabled = false
        buttonSend.addTarget(self, action: #selector(ChatViewController.sendMessageButtonTapped), for: .touchUpInside)
        
        buttonSet.append(buttonKeyBoard)
        buttonSet.append(buttonSticker)
        buttonSet.append(buttonImagePicker)
        buttonSet.append(buttonCamera)
        buttonSet.append(buttonLocation)
        buttonSet.append(buttonVoiceRecorder)
        buttonSet.append(buttonSend)
        
        for button in buttonSet {
            button.autoresizingMask = [.flexibleTopMargin]
        }
        
        //heart Button
        automaticallyAdjustsScrollViewInsets = false
        
        inputToolbar.contentView.heartButtonHidden = false
        inputToolbar.contentView.heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        inputToolbar.contentView.heartButton.addTarget(self, action: #selector(actionHoldingLikeButton(_:)), for: .touchDown)
        inputToolbar.contentView.heartButton.addTarget(self, action: #selector(actionLeaveLikeButton(_:)), for: .touchDragOutside)
        
    }
    
    // be sure to call this in ViewWillAppear!!!
    func setupToolbarContentView() {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271))
        toolbarContentView.delegate = self
        toolbarContentView.inputToolbar = inputToolbar
        toolbarContentView.cleanUpSelectedPhotos()
        //UIApplication.shared.keyWindow?.addSubview(toolbarContentView)
        view.addSubview(toolbarContentView)
    }
    
    //MARK: - JSQMessages Delegate function
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            //send message
            sendMessage(text: text, date: date)
        }
    }
    
    //MARK: - keyboard input bar tapped event
    func showKeyboard() {
        
        resetToolbarButtonIcon()
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        toolbarContentView.showKeyboard()
        /*UIView.animate(withDuration: 0.2, animations: {
            let extendHeight = self.locExtendView.isHidden ? 0 : self.locExtendView.frame.height
            //if screenHeight == 736 {
                self.locExtendView.frame.origin.y = screenHeight - self.keyboardHeight - extendHeight - 90
            //} else {
                //self.locExtendView.frame.origin.y = screenHeight - 258 - extendHeight - 90
            //}
            
        }, completion: { (_) -> Void in
        })*/
        collectionView.isScrollEnabled = false
        let height = inputToolbar.frame.height
        let extendHeight = self.locExtendView.isHidden ? 0 : self.locExtendView.frame.height
        if !locExtendView.isHidden {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight + height + extendHeight, right: 0.0)
            collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight + height + extendHeight, right: 0.0)
            //inputToolbar.frame.origin.y = screenHeight - (keyboardHeight + height + extendHeight)
        }
        collectionView.isScrollEnabled = true
        //moveUpInputBarContentView(false)
        inputToolbar.contentView.textView.becomeFirstResponder()
        scrollToBottom(true)
        
    }
    
    func showCamera() {
        view.endEditing(true)
        locExtendView.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.closeToolbarContentView()
        }, completion: { (_) -> Void in
        })
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    func showStikcer() {
        resetToolbarButtonIcon()
        buttonSticker.setImage(UIImage(named: "stickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        toolbarContentView.showStikcer()
        moveUpInputBarContentView(animated)
        scrollToBottom(false)
    }
    
    func showLibrary() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
            print("not authorized!")
            showAlertView(withWarning: "Cannot use this function without authorization to Photo!")
            return
        }
        resetToolbarButtonIcon()
        buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        toolbarContentView.showLibrary()
        locExtendView.isHidden = true
        moveUpInputBarContentView(animated)
        scrollToBottom(false)
    }
    
    func showRecord() {
        resetToolbarButtonIcon()
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage_red"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        toolbarContentView.showRecord()
        moveUpInputBarContentView(animated)
        scrollToBottom(false)
    }
    
    func sendLocation() {
        resetToolbarButtonIcon()
        buttonLocation.setImage(UIImage(named: "locationChosen"), for: UIControlState())
        //closeToolbarContentView()
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        toolbarContentView.showMiniLocation()
        moveUpInputBarContentView(animated)
        scrollToBottom(false)
    }
    
    func sendMessageButtonTapped() {
        if locExtendView.isHidden {
            sendMessage(text: inputToolbar.contentView.textView.text, date: Date())
        } else {
            sendMessage(text: inputToolbar.contentView.textView.text, location: locExtendView.location, snapImage: locExtendView.getImageDate(), date: Date())
        }
        locExtendView.isHidden = true
        buttonSend.isEnabled = false
    }
    
    //MARK: navigationItem function
    // right item , show all push notification
    func navigationItemTapped() {
    }
    
    //for voice test
    //    override func didPressAccessoryButton(sender: UIButton!) {
    //    }
    
    //MARK: - input text field delegate & keyboard
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text.characters.count == 0 {
            // when text has no char, cannot send message
            buttonSend.isEnabled = false
        } else {
            buttonSend.isEnabled = true
        }
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        showKeyboard()
        buttonSend.isEnabled = inputToolbar.contentView.textView.text.characters.count > 0 || !locExtendView.isHidden
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                //self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                //self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            keyboardHeight = (endFrame?.size.height)!
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            let extendHeight = self.locExtendView.isHidden ? 0 : self.locExtendView.frame.height
                            self.locExtendView.frame.origin.y = screenHeight - self.keyboardHeight - extendHeight - 90
                            self.collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: self.keyboardHeight + self.inputToolbar.frame.height + extendHeight, right: 0.0)
                            self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: self.keyboardHeight + self.inputToolbar.frame.height + extendHeight, right: 0.0)
            },
                           completion:{ (_) -> Void in
                            self.scrollToBottom(false)
            })
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        //print("keyboard will show")
        /*let inset = collectionView.contentInset.bottom
         if(!locExtendView.isHidden) {
         collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: inset + locExtendView.frame.height, right: 0.0)
         collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: inset + locExtendView.frame.height, right: 0.0)
         }*/
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            //locExtendView.isHidden = false
            let extendHeight = self.locExtendView.isHidden ? 0 : self.locExtendView.frame.height
            locExtendView.frame.origin.y = screenHeight - self.keyboardHeight - extendHeight - 90
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: self.keyboardHeight + self.inputToolbar.frame.height, right: 0.0)
                self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: self.keyboardHeight + self.inputToolbar.frame.height, right: 0.0)
            }, completion: { (_) -> Void in
            })
            
            //showKeyboard()
            
        }

       
    }
    
    func keyboardDidShow(_ notification: Notification) {
        
        /*if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            //locExtendView.isHidden = false
            //let extendHeight = self.locExtendView.isHidden ? 0 : self.locExtendView.frame.height
            //locExtendView.frame.origin.y = screenHeight - self.keyboardHeight - extendHeight - 90
            //showKeyboard()
        }*/
       
        toolbarContentView.keyboardShow = true
        //scrollToBottom(true)
    }
    
    func keyboardDidHide(_ notification: Notification) {
        /* let inset = collectionView.contentInset.bottom
        if(!locExtendView.isHidden) {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: inset - locExtendView.frame.height, right: 0.0)
            collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: inset - locExtendView.frame.height, right: 0.0)
        } */
        toolbarContentView.keyboardShow = false
    }
    
    // MARK: - scroll view delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            if scrollViewCurrentOffset - scrollViewOriginOffset < 0
                && (toolbarContentView.mediaContentShow)
                && !isClosingToolbarContentView && scrollView.isScrollEnabled == true {
                toolbarContentView.frame.origin.y = min(screenHeight - 273 - (scrollViewCurrentOffset - scrollViewOriginOffset), screenHeight)
                
                inputToolbar.frame.origin.y = min(screenHeight - 273 - inputToolbar.frame.height - 64 - (scrollViewCurrentOffset - scrollViewOriginOffset), screenHeight - inputToolbar.frame.height - 64)
                
                locExtendView.frame.origin.y = screenHeight - 271 - 76 - 90 - (scrollViewCurrentOffset - scrollViewOriginOffset)
            }
            if scrollViewCurrentOffset < 1 && !isLoadingPreviousMessages {
                loadPreviousMessages()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            scrollViewOriginOffset = scrollView.contentOffset.y
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == collectionView {
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            if scrollViewCurrentOffset - scrollViewOriginOffset < -5 {
                
                isClosingToolbarContentView = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.moveDownInputBar()
                    self.toolbarContentView.frame.origin.y = screenHeight
                }, completion: { (_) -> Void in
                    self.toolbarContentView.closeAll()
                    self.resetToolbarButtonIcon()
                    self.isClosingToolbarContentView = false
                    self.toolbarContentView.cleanUpSelectedPhotos()
                })
            }
        }
    }
    
    //MARK: - move input bars
    func moveUpInputBarContentView(_ animated: Bool) {
        collectionView.isScrollEnabled = false
        if animated {
            toolbarContentView.frame.origin.y = screenHeight
            UIView.animate(withDuration: 0.3, animations: {
                self.moveUpInputBar()
                self.toolbarContentView.frame.origin.y = screenHeight - 271
                self.locExtendView.frame.origin.y = screenHeight - 271 - 76 - 90
                
            }, completion: { (_) -> Void in
                self.collectionView.isScrollEnabled = true
            })
        } else {
            moveUpInputBar()
            toolbarContentView.frame.origin.y = screenHeight - 271
            locExtendView.frame.origin.y = screenHeight - 271 - 76 - 90
            collectionView.isScrollEnabled = true
        }
        //scrollToBottom(animated)
    }
    
    func moveUpInputBar() {
        //when keybord, stick, photoes preview show, move tool bar up
        let height = inputToolbar.frame.height
        let width = inputToolbar.frame.width
        let xPosition = inputToolbar.frame.origin.x
        let yPosition = screenHeight - 271 - height// - 64
        UIView.setAnimationsEnabled(false)
        let extendHeight = locExtendView.isHidden ? 0 : locExtendView.frame.height
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + height + extendHeight, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + height + extendHeight, right: 0.0)
        UIView.setAnimationsEnabled(true)
        //        self.inputToolbar.frame.origin.y = yPosition
        inputToolbar.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        //        if(locExtendView.frame.origin.y == )
        //        locExtendView.frame.origin.y -= 271
    }
    
    func moveDownInputBar() {
        //
        view.endEditing(true)
        let height = inputToolbar.frame.height
        let width = inputToolbar.frame.width
        let xPosition = inputToolbar.frame.origin.x
        let yPosition = screenHeight - height// - 64
        let extendHeight = locExtendView.isHidden ? 0 : locExtendView.frame.height
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height + extendHeight, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height + extendHeight, right: 0.0)
        inputToolbar.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        //        if(locExtendView.frame.origin.y != screenHeight - 64 - 76 - 90) {
        locExtendView.frame.origin.y = screenHeight - 76 - 90
        //        }
    }
    
    func adjustCollectionScroll() {
        
    }
    
    //MARK: - Helper functions
    
    // allow app to add time stamp to message
    func enableTimeStamp() {
        isContinuallySending = false
    }
    
    private func getAvatar() {
        if showAvatar {
            createAvatars(avatarImageDictionary)
            collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 35, height: 35)
            collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 35, height: 35)
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    private func createAvatars(_ avatars: NSMutableDictionary?) {
        
        let currentUserAvatar = avatarDic[Key.shared.user_id] != nil ? JSQMessagesAvatarImage(avatarImage: avatarDic[Key.shared.user_id], highlightedImage: avatarDic[Key.shared.user_id], placeholderImage: avatarDic[Key.shared.user_id]) : JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        //Bryan
        let withUserAvatar = avatarDic[Int(realmWithUser!.userID)!] != nil ? JSQMessagesAvatarImage(avatarImage: avatarDic[Int(realmWithUser!.userID)!], highlightedImage: avatarDic[Int(realmWithUser!.userID)!], placeholderImage: avatarDic[Int(realmWithUser!.userID)!]) : JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        avatarDictionary = ["\(Key.shared.user_id)": currentUserAvatar!, realmWithUser!.userID: withUserAvatar!]
        //ENDBryan
        // need to check if collectionView exist before reload
    }
    
    func scrollToBottom(_ animated: Bool) {
        //override:
        let item = collectionView(collectionView!, numberOfItemsInSection: 0) - 1
        //get the last item index
        if item >= 0 {
            let lastItemIndex = IndexPath(item: item, section: 0)
            collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: animated)
        }
    }
    
    func closeToolbarContentView() {
        resetToolbarButtonIcon()
        moveDownInputBar()
        scrollToBottom(true)
        toolbarContentView.closeAll()
        toolbarContentView.frame.origin.y = screenHeight
    }
    
    func showAlertView(withWarning text: String) {
        let alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // segue to the full album page
    func showFullAlbum() {
        closeToolbarContentView()
        //jump to the get more image collection view, and deselect the image we select in photoes preview
        // TODO
        //let vc = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewController(withIdentifier: "FullAlbumCollectionViewController")as! FullAlbumCollectionViewController
        let layout = UICollectionViewFlowLayout()
        //layout.scrollDirection = .vertical
        //layout.itemSize = CGSize(width: (screenWidth - 4) / 3, height: (screenWidth - 4) / 3)
        //layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1)
        let vc = FullAlbumCollectionViewController(collectionViewLayout: layout)
        //vc.collectionView?.register(PhotoPickerCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        vc.imageDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // change every button to its origin state
    fileprivate func resetToolbarButtonIcon() {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        buttonSticker.setImage(UIImage(named: "sticker"), for: UIControlState())
        buttonSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: UIControlState())
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: UIControlState())
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: .highlighted)
        buttonLocation.setImage(UIImage(named: "shareLocation"), for: UIControlState())
        buttonSend.isEnabled = !locExtendView.isHidden
    }
    
    func endEdit() {
        view.endEditing(true)
    }
    
    @objc private func heartButtonTapped() {
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
            animatingHeartTimer = nil
        }
        //animateHeart()
        if !userJustSentHeart {
            sendMessage(sticker: #imageLiteral(resourceName: "pinDetailLikeHeartFullLarge"), isHeartSticker: true, date: Date())
            userJustSentHeart = true
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
        animatingHeart = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 22))
        animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        animatingHeart.layer.opacity = 0
        inputToolbar.contentView.addSubview(animatingHeart)
        
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
        animatingHeart.layer.add(orbit, forKey: "Move")
        animatingHeart.layer.add(fadeAnimation, forKey: "Opacity")
        animatingHeart.layer.add(scaleAnimation, forKey: "Scale")
        animatingHeart.layer.position = CGPoint(x: inputToolbar.contentView.heartButton.center.x, y: inputToolbar.contentView.heartButton.center.y)
    }
    
    //MARK: - obsere value
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        let textView = object as! UITextView
        if textView == inputToolbar.contentView.textView && keyPath! == "text" {
            
            let newString = (change![NSKeyValueChangeKey.newKey]! as! String)
            buttonSend.isEnabled = newString.characters.count > 0
        }
    }
    
    // Need to refresh the album because user might take a photo outside the app
    func appWillEnterForeground() {
        collectionView.reloadData()
        toolbarContentView.reloadPhotoAlbum()
    }
    
    //MARK: -  UIImagePickerController
    
    // handle events after user took a photo/video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let type = info[UIImagePickerControllerMediaType] as! String
        switch type {
        case (kUTTypeImage as String as String):
            let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            sendMessage(picture: picture, date: Date())
            
            UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        case (kUTTypeMovie as String as String):
            let movieURL = info[UIImagePickerControllerMediaURL] as! URL
            
            //get duration of the video
            let asset = AVURLAsset(url: movieURL)
            let duration = CMTimeGetSeconds(asset.duration)
            let seconds = Int(ceil(duration))
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
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
            imageData = UIImageJPEGRepresentation(snapImage, factor)
            
            let path = movieURL.path
            let data = FileManager.default.contents(atPath: path)
            sendMessage(video: data, videoDuration: seconds, snapImage: imageData, date: Date())
            break
        default:
            break
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // after saving the photo, refresh the album
    func image(_ image: UIImage, didFinishSavingWithError error: NSError, contextInfo: AnyObject?) {
        appWillEnterForeground()
    }
    
    //MARK: - CAAnimationDelegate
    func animationDidStart(_ anim: CAAnimation) {
        if anim.duration == 1 {
            animHeartDic[anim] = animatingHeart
            let seconds = 0.5
            let delay = seconds * Double(NSEC_PER_SEC) // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.inputToolbar.contentView.sendSubview(toBack: self.animHeartDic[anim]!)
            })
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim.duration == 1 && flag {
            animHeartDic[anim]?.removeFromSuperview()
            animHeartDic[anim] = nil
        }
    }
    
    func showFullLocationView(_ sender: UIButton) {
        // TODO
        //let vc = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatSendLocationController") as! ChatSendLocationController
        let vc = ChatSendLocationController()
        vc.locationDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func closeLocExtendView() {
        locExtendView.isHidden = true
        let inset = collectionView.contentInset.bottom
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: inset - locExtendView.frame.height, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: inset - locExtendView.frame.height, right: 0.0)
        //buttonSend.isEnabled = !locExtendView.isHidden
        buttonSend.isEnabled = inputToolbar.contentView.textView.text.characters.count > 0
    }
    
    func sendLocationMessageFromMini(_ sender: UIButton) {
        if let mapview = toolbarContentView.miniLocation.mapView {
            UIGraphicsBeginImageContext(mapview.frame.size)
            mapview.layer.render(in: UIGraphicsGetCurrentContext()!)
            if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext() {
                locExtendView.setAvator(image: screenShotImage)
                let location = CLLocation(latitude: mapview.camera.centerCoordinate.latitude, longitude: mapview.camera.centerCoordinate.longitude)
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
                    (placemarks, error) -> Void in
                    guard let response = placemarks?[0] else { return }
                    self.addResponseToLocationExtend(response: response, withMini: true)
                })
                /*General.shared.getAddress(location: location, original: true) { placeMark in
                    guard let response = placeMark as? CLPlacemark else { return }
                    self.addResponseToLocationExtend(response: response, withMini: true)
                }*/
            }
        }
        
        //buttonSend.isEnabled = true
    }
    
    func addResponseToLocationExtend(response: CLPlacemark, withMini: Bool) {
        var texts: [String] = []
        texts.append((response.subThoroughfare)! + " " + (response.thoroughfare)!)
        var cityText = response.locality
        
        if response.administrativeArea != nil {
            cityText = cityText! + ", " + (response.administrativeArea)!
        }
        
        if response.postalCode != nil {
            cityText = cityText! + " " + (response.postalCode)!
        }
        texts.append(cityText!)
        texts.append((response.country)!)
        
        locExtendView.setLabel(texts: texts)
        locExtendView.location = CLLocation(latitude: toolbarContentView.miniLocation.mapView.camera.centerCoordinate.latitude, longitude: toolbarContentView.miniLocation.mapView.camera.centerCoordinate.longitude)
        locExtendView.isHidden = false
        let extendHeight = locExtendView.isHidden ? 0 : locExtendView.frame.height
        if withMini {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + inputToolbar.frame.height + extendHeight, right: 0.0)
            collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + inputToolbar.frame.height + extendHeight, right: 0.0)
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: inputToolbar.frame.height + extendHeight, right: 0.0)
            collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: inputToolbar.frame.height + extendHeight, right: 0.0)
        }
        //showKeyboard()
        //inputToolbar.contentView.textView.becomeFirstResponder()
        scrollToBottom(true)
        buttonSend.isEnabled = true
        
    }
    
    func appendEmoji(_ name: String) {}
    func deleteLastEmoji() {}
    
    func dismissKeyboard() {
        view.endEditing(true)
        moveDownInputBar()
        
    }
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
    
    }
}
