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
//import Photos
import MobileCoreServices
import CoreMedia
import AVFoundation


public let kAVATARSTATE = "avatarState"
public let kFIRSTRUN = "firstRun"
public var headerDeviceToken: Data!

class ChatViewController: JSQMessagesViewControllerCustom, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate ,SendMutipleImagesDelegate, LocationSendDelegate , FAEChatToolBarContentViewDelegate
{
    //MARK: - properties
    let ref = FIRDatabase.database().reference().child(fireBaseRef)// reference to all chat room
    var messages : [JSQMessage] = []
    var objects : [NSDictionary] = []//
    var loaded : [NSDictionary] = []// load dict from firebase that this chat room all message
    
    var avatarImageDictionary : NSMutableDictionary?//not use anymore
    var avatarDictionary : NSMutableDictionary?//not use anymore
    //
    var showAvatar : Bool = true//false not show avatar , true show avatar
    var firstLoad : Bool?// whether it is the first time to load this room.
    var withUser : FaeWithUser?

    var withUserId : String? // the user id we chat to
    var withUserName : String? // the user name we chat to
    var currentUserId : String?// my user id
    var recent : NSDictionary?//recent chat room message
    var chatRoomId : String!
    var chat_id: String?//the chat Id returned by the server
    var initialLoadComplete : Bool = false// the first time open this chat room, false means we need to load every message to the chat room, true means we only need to load the new messages.
    var outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named:"bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).outgoingMessagesBubbleImage(with: UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0))
    //the message I sent bubble
    let incomingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named:"bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).incomingMessagesBubbleImage(with: UIColor.white)
    //the message other person sent bubble
    let userDefaults = UserDefaults.standard

    //voice MARK: has bug here can record and upload but can't replay after download,
    var fileName = "audioFile.caf"
//    var soundPlayer : AVAudioPlayer!

    //custom toolBar the bottom toolbar button
    private var buttonSet = [UIButton]()
    private var buttonSend : UIButton!
    private var buttonKeyBoard : UIButton!
    private var buttonSticker : UIButton!
    private var buttonImagePicker : UIButton!
    private var buttonVoiceRecorder: UIButton!

    var isContinuallySending = false// this virable is use to avoid mutiple time stamp when sending photos, true: did send sth in last 5s
    
    //toolbar content
    var toolbarContentView : FAEChatToolBarContentView!
    
    //scroll view
    var isClosingToolbarContentView = false
    var scrollViewOriginOffset: CGFloat! = 0
    
    //step by step loading
    let numberOfMessagesOneTime = 15
    var numberOfMeesagesReceived = 0
    var numberOfMessagesLoaded = 0
    var totalNumberOfMessages : Int{
        get{
            if let lastMessage = objects.last{
                return lastMessage["index"] as! Int
            }
            return 0
        }
        set{
        }
    }
    
    var isLoadingPreviousMessages = false
    
    //time stamp
    var lastMarkerDate: Date! = Date.distantPast
    
    //typing indicator
    //    var userIsTypingRef = firebase.database.reference().child("typingIndicator")
    //    var userTypingQuery : FIRDatabaseQuery!
    //    private var localTyping = false
    //    var isTyping : Bool {
    //        get {
    //            return localTyping
    //        }
    //        set {
    //            localTyping = newValue
    //            userIsTypingRef.setValue(newValue)
    //        }
    //    }
    
    
    fileprivate func observeTyping() {
        //        print("the senderId is \(self.senderId)")
        //        userIsTypingRef = userIsTypingRef.child(self.senderId)
        //        userIsTypingRef.onDisconnectRemoveValue()
        //        userTypingQuery = firebase.database.reference().child("typingIndicator").queryOrderedByChild(self.senderId)
        //        userTypingQuery = userIsTypingRef.queryOrderedByKey().queryEqualToValue(withUser?.objectId)
        //        userTypingQuery.observeEventType(.Value) { (snapshot : FIRDataSnapshot) in
        //            if snapshot.exists() {
        //                print("it is exist")
        //                print(snapshot)
        //                if snapshot.value as! Bool {
        //                    self.showTypingIndicator = true
        //                    self.scrollToBottomAnimated(true)
        //                } else {
        //                    self.showTypingIndicator = false
        //                }
        //            } else {
        //                print("it is not exist")
        //                self.showTypingIndicator = false
        //            }
        //        }
    }
    
    // MARK: - view life cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //update recent
        closeToolbarContentView()
        removeObservers()
        ref.removeAllObservers()//firebase : remove all the Listener (firebase default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarSet()
        collectionView.backgroundColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1.0)// override jsq collection view
        self.senderId = user_id.stringValue
        self.senderDisplayName = withUser!.userName
        self.inputToolbar.contentView.textView.delegate = self
        
        //load firebase messages
        loadMessage()
        // Do any additional setup after loading the view.
        loadInputBarComponent()
        
        self.inputToolbar.contentView.textView.placeHolder = "Type Something..."
        self.inputToolbar.contentView.backgroundColor = UIColor.white
        self.inputToolbar.contentView.textView.contentInset = UIEdgeInsetsMake(3.0, 0.0, 1.0, 0.0);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //check user default
        super.viewWillAppear(true)
        addObservers()
        loadUserDefault()
        // This line is to fix the collectionView messed up function
        moveDownInputBar()
        getAvatar()
        setupToolbarContentView()
    }
    
    // MARK: - setup
    
    private func navigationBarSet() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        let attributes = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : UIColor.faeAppInputTextGrayColor()] as [String : Any]
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationController!.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = nil
        
        //ATTENTION: Temporary comment it here because it's not used for now
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "bellHollow"), style: .Plain, target: self, action: #selector(ChatViewController.navigationItemTapped))
    
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        titleLabel.text = withUser!.userName
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        self.navigationItem.titleView = titleLabel
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name:NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name:NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        inputToolbar.contentView.textView.addObserver(self, forKeyPath: "text", options: [.new] , context: nil)
    }
    
    func removeObservers()
    {
        self.inputToolbar.contentView.textView.removeObserver(self, forKeyPath: "text", context: nil)
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
        let contentView = self.inputToolbar.contentView
        let contentOffset = (screenWidth - 42 - 29 * 7) / 6 + 29
        buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        buttonKeyBoard.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
        contentView?.addSubview(buttonKeyBoard)
        
        buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonSticker.setImage(UIImage(named: "sticker"), for: UIControlState())
        buttonSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
        buttonSticker.addTarget(self, action: #selector(ChatViewController.showStikcer), for: .touchUpInside)
        contentView?.addSubview(buttonSticker)
        
        buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: UIControlState())
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
        contentView?.addSubview(buttonImagePicker)
        
        buttonImagePicker.addTarget(self, action: #selector(ChatViewController.showLibrary), for: .touchUpInside)
        
        let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonCamera.setImage(UIImage(named: "camera"), for: UIControlState())
        buttonCamera.setImage(UIImage(named: "camera"), for: .highlighted)
        contentView?.addSubview(buttonCamera)
        
        buttonCamera.addTarget(self, action: #selector(ChatViewController.showCamera), for: .touchUpInside)
        
        buttonVoiceRecorder = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: UIControlState())
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: .highlighted)
        //add a function
        buttonVoiceRecorder.addTarget(self, action: #selector(ChatViewController.showRecord), for: .touchUpInside)
        
        contentView?.addSubview(buttonVoiceRecorder)
        
        let buttonLocation = UIButton(frame: CGRect(x: 21 + contentOffset * 5, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonLocation.setImage(UIImage(named: "shareLocation"), for: UIControlState())
        buttonLocation.setImage(UIImage(named: "shareLocation"), for: .highlighted)
        //add a function
        buttonLocation.addTarget(self, action: #selector(ChatViewController.sendLocation), for: .touchUpInside)
        contentView?.addSubview(buttonLocation)
        
        buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 6, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .disabled )
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .highlighted)
        buttonSend.setImage(UIImage(named: "canSendMessage"), for: .normal )
        
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
        
        for button in buttonSet{
            button.autoresizingMask = [.flexibleTopMargin]
        }
    }
    
    // be sure to call this in ViewWillAppear!!!
    func setupToolbarContentView()
    {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0,y: screenHeight,width: screenWidth, height: 271))
        toolbarContentView.delegate = self
        toolbarContentView.inputToolbar = inputToolbar
        toolbarContentView.cleanUpSelectedPhotos()
        UIApplication.shared.keyWindow?.addSubview(toolbarContentView)
    }
    
    //MARK: - JSQMessages Delegate function
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            //send message
            sendMessage(text, date: date, picture: nil, sticker : nil, location: nil, snapImage : nil, audio : nil, video: nil, videoDuration: 0)
        }
    }
    
    //MARK: - keyboard input bar tapped event
    func showKeyboard() {
        
        resetToolbarButtonIcon()
        self.buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        self.toolbarContentView.showKeyboard()
        scrollToBottom(true)
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
    
    func showRecord() {
        resetToolbarButtonIcon()
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage_red"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showRecord()
        moveUpInputBarContentView(animated)
    }
    
    func sendLocation() {
        resetToolbarButtonIcon()
        closeToolbarContentView()
        let vc = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatSendLocationController") as! ChatSendLocationController
        vc.locationDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func sendMessageButtonTapped() {
        sendMessage(self.inputToolbar.contentView.textView.text, date: Date(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil, video: nil, videoDuration: 0)
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
        self.showKeyboard()
    }
    
    func keyboardDidShow(_ notification: Notification){
        toolbarContentView.keyboardShow = true
        scrollToBottom(true)
    }
    
    func keyboardDidHide(_ notification: Notification){
        toolbarContentView.keyboardShow = false
    }
    
    
    // MARK: - scroll view delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == collectionView){
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            if(scrollViewCurrentOffset - scrollViewOriginOffset < 0 && (toolbarContentView.mediaContentShow) && !isClosingToolbarContentView && scrollView.isScrollEnabled == true){
                self.toolbarContentView.frame.origin.y = min(screenHeight - 273 - (scrollViewCurrentOffset - scrollViewOriginOffset ), screenHeight)

                self.inputToolbar.frame.origin.y = min(screenHeight - 273 - self.inputToolbar.frame.height - 64 - (scrollViewCurrentOffset - scrollViewOriginOffset), screenHeight - self.inputToolbar.frame.height - 64)
            }
            if scrollViewCurrentOffset < 1 && !isLoadingPreviousMessages{
                loadPreviousMessages()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if(scrollView == collectionView){
            scrollViewOriginOffset = scrollView.contentOffset.y
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if(scrollView == collectionView){
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            if(scrollViewCurrentOffset - scrollViewOriginOffset < -5){
                
                isClosingToolbarContentView = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.moveDownInputBar()
                    self.toolbarContentView.frame.origin.y = screenHeight
                    }, completion: {(Bool)->Void in
                        self.toolbarContentView.closeAll()
                        self.resetToolbarButtonIcon()
                        self.isClosingToolbarContentView = false
                        self.toolbarContentView.cleanUpSelectedPhotos()
                })
            }
        }
    }
    
    
    
    //MARK: - move input bars
    func moveUpInputBarContentView(_ animated: Bool)
    {
        self.collectionView.isScrollEnabled = false
        if(animated){
            self.toolbarContentView.frame.origin.y = screenHeight
            UIView.animate(withDuration: 0.3, animations: {
                self.moveUpInputBar()
                self.toolbarContentView.frame.origin.y = screenHeight - 271
            }, completion:{ (Bool) -> Void in
                self.collectionView.isScrollEnabled = true
            })
        }else{
            self.moveUpInputBar()
            self.toolbarContentView.frame.origin.y = screenHeight - 271
            self.collectionView.isScrollEnabled = true
        }
        scrollToBottom(animated)
    }
    
    func moveUpInputBar() {
        //when keybord, stick, photoes preview show, move tool bar up
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = screenHeight - 271 - height - 64
        UIView.setAnimationsEnabled(false)
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + height, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + height, right: 0.0)
        UIView.setAnimationsEnabled(true)
        //        self.inputToolbar.frame.origin.y = yPosition
        self.inputToolbar.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
    }
    
    func moveDownInputBar() {
        //
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = screenHeight - height - 64
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
        self.inputToolbar.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
    }

    
    //MARK: - Helper functions
    
    // allow app to add time stamp to message
    func enableTimeStamp(){
        self.isContinuallySending = false
    }
    
    private func getAvatar() {
        if showAvatar {
            createAvatars(avatarImageDictionary)
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 35, height: 35)
            self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 35, height: 35)
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    private func createAvatars(_ avatars : NSMutableDictionary?) {
        let currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: (avatarDic[user_id] ?? UIImage(named: "avatarPlaceholder")) , diameter: 70)
        let withUserAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: (avatarDic[NSNumber(value: Int(withUser!.userId)! as Int)] ?? UIImage(named: "avatarPlaceholder")), diameter: 70)
        avatarDictionary = [user_id.stringValue : currentUserAvatar!, withUser!.userId : withUserAvatar!]
        // need to check if collectionView exist before reload
    }
    
    func scrollToBottom(_ animated:Bool) {
        //override:
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        //get the last item index
        if item >= 0 {
            let lastItemIndex = IndexPath(item: item, section: 0)
            self.collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top , animated: animated)
        }
    }
    
    func closeToolbarContentView()
    {
        resetToolbarButtonIcon()
        moveDownInputBar()
        scrollToBottom(true)
        toolbarContentView.closeAll()
        toolbarContentView.frame.origin.y = screenHeight
    }
    
    func showAlertView(withWarning text: String) {
        let alert = UIAlertController(title:text, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // segue to the full album page
    func showFullAlbum()
    {
        //jump to the get more image collection view, and deselect the image we select in photoes preview
        let vc = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewController(withIdentifier: "CustomCollectionViewController")as! CustomCollectionViewController
        vc.imageDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // change every button to its origin state
    fileprivate func resetToolbarButtonIcon()
    {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        buttonSticker.setImage(UIImage(named: "sticker"), for: UIControlState())
        buttonSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: UIControlState())
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: UIControlState())
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: .highlighted)
        buttonSend.isEnabled = false
    }
    
    func endEdit()
    {
        self.view.endEditing(true)
    }
    
    //MARK: - obsere value
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        let textView = object as! UITextView
        if (textView == self.inputToolbar.contentView.textView && keyPath! == "text") {

            let newString = (change![NSKeyValueChangeKey.newKey]! as! String)
            buttonSend.isEnabled = newString.characters.count > 0
        }
    }
    
    // Need to refresh the album because user might take a photo outside the app
    func appWillEnterForeground(){
        self.collectionView.reloadData()
        self.toolbarContentView.reloadPhotoAlbum()
    }
    
    //MARK: -  UIImagePickerController
    
    // handle events after user took a photo/video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type = info[UIImagePickerControllerMediaType] as! String
        switch type {
        case (kUTTypeImage as String as String):
            let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            self.sendMessage(nil, date: Date(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil, video: nil, videoDuration: 0)
            
            UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        case (kUTTypeMovie as String as String):
            let movieURL = info[UIImagePickerControllerMediaURL] as! URL

            //get duration of the video
            let asset = AVURLAsset(url: movieURL)
            let duration = CMTimeGetSeconds(asset.duration);
            let seconds = Int(ceil(duration))
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            var time = asset.duration
            time.value = 0
            
            //get snapImage
            var snapImage = UIImage()
            do{
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime:nil)
                snapImage = UIImage(cgImage: imageRef)
            }
            catch{
                //Handle failure
            }
            
            var imageData = UIImageJPEGRepresentation(snapImage,1)
            let factor = min( 5000000.0 / CGFloat(imageData!.count), 1.0)
            imageData = UIImageJPEGRepresentation(snapImage,factor)
        
            let path = movieURL.path
            let data = FileManager.default.contents(atPath: path)
            self.sendMessage(nil, date: Date(), picture: nil, sticker : nil, location: nil, snapImage : imageData, audio: nil, video: data, videoDuration: seconds)
            break
        default:
            break
        }

        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // after saving the photo, refresh the album
    func image(_ image:UIImage, didFinishSavingWithError error: NSError, contextInfo:AnyObject?)
    {
        self.appWillEnterForeground()
    }
    
}


