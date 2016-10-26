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

public let kAVATARSTATE = "avatarState"
public let kFIRSTRUN = "firstRun"
public var headerDeviceToken: NSData!

class ChatViewController: JSQMessagesViewControllerCustom, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate ,SendMutipleImagesDelegate, LocationSendDelegate , FAEChatToolBarContentViewDelegate{
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    //    let appDeleget = UIApplication.sharedApplication().delegate as! AppDelegate
    let ref = firebase.database.reference().child("Message")// reference to all chat room
    var messages : [JSQMessage] = []
    var objects : [NSDictionary] = []//
    var loaded : [NSDictionary] = []// load dict from firebase that this chat room all message
    
    var avatarImageDictionary : NSMutableDictionary?//not use anymore
    var avatarDictionary : NSMutableDictionary?//not use anymore
    //
    var showAvatar : Bool = true//false not show avatar , true show avatar
    let factor : CGFloat = 375 / 414// autolayout factor MARK: 5s may has error, 6 and 6+ is ok
    var firstLoad : Bool?// whether it is the first time to load this room.
    var withUser : FaeWithUser?

    var withUserId : String? // the user id we chat to
    var withUserName : String? // the user name we chat to
    var currentUserId : String?// my user id
    var recent : NSDictionary?//recent chat room message
    var chatRoomId : String!
    var chat_id: String?//the chat Id returned by the server
    var initialLoadComplete : Bool = false// the first time open this chat room, false means we need to load every message to the chat room, true means we only need to load the new messages.
    var outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubbleImage: UIImage(named:"bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).outgoingMessagesBubbleImageWithColor(UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0))
    //the message I sent bubble
    let incomingBubble = JSQMessagesBubbleImageFactoryCustom(bubbleImage: UIImage(named:"bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).incomingMessagesBubbleImageWithColor(UIColor.whiteColor())
    //the message other person sent bubble
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var faeGray = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)//gray color
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    //pink color
    
    //voice MARK: has bug here can record and upload but can't replay after download,
    var fileName = "audioFile.caf"
//    var soundPlayer : AVAudioPlayer!

    //custom toolBar the bottom toolbar button
    var buttonSet = [UIButton]()
    var buttonSend : UIButton!
    var buttonKeyBoard : UIButton!
    var buttonSticker : UIButton!
    var buttonImagePicker : UIButton!
    var buttonVoiceRecorder: UIButton!
    //album //a helper to send photo

    var isContinuallySending = false

    //keyboard
    var keyboardHeight: CGFloat! = 0
    
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
    var lastMarkerDate: NSDate! = NSDate.distantPast()
    
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
    
    
    private func observeTyping() {
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
    
    // MARK: - view did/will funcs
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        //update recent
        closeToolbarContentView()
        ref.removeAllObservers()//firebase : remove all the Listener (firebase default)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        clearRecentCounter(chatRoomId)// clear the unread message count
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
        self.inputToolbar.contentView.backgroundColor = UIColor.whiteColor()
        self.inputToolbar.contentView.textView.contentInset = UIEdgeInsetsMake(3.0, 0.0, 1.0, 0.0);
        addObservers()
        // setup requestion option 
//        requestOption.resizeMode = .Fast //resize time fast
//        requestOption.deliveryMode = .HighQualityFormat //high pixel
//        requestOption.synchronous = false
    }
    
    override func viewWillAppear(animated: Bool) {
        //check user default
        super.viewWillAppear(true)
        loadUserDefault()
        // This line is to fix the collectionView messed up function
        moveDownInputBar()
        getAvatar()
        setupToolbarContentView()
    }
    
    
    func appWillEnterForeground(){
        self.collectionView.reloadData()
    }
    
    // MARK: - setup
    
    func navigationBarSet() {
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        let attributes = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : faeGray]
        self.navigationController?.navigationBar.tintColor = colorFae
        self.navigationController!.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = nil
        
        //ATTENTION: Temporary comment it here because it's not used for now
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "bellHollow"), style: .Plain, target: self, action: #selector(ChatViewController.navigationItemTapped))
        
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        titleLabel.text = withUser!.userName
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        self.navigationItem.titleView = titleLabel
    }
    
    func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow), name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidHide), name:UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appWillEnterForeground), name:"appWillEnterForeground", object: nil)
    }

    //MARK: user default function
    func loadUserDefault() {
        firstLoad = userDefaults.boolForKey(kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setBool(showAvatar, forKey: kAVATARSTATE)
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
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Highlighted)
        buttonKeyBoard.addTarget(self, action: #selector(showKeyboard), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonKeyBoard)
        
        buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Highlighted)
        buttonSticker.addTarget(self, action: #selector(ChatViewController.showStikcer), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonSticker)
        
        buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Highlighted)
        contentView.addSubview(buttonImagePicker)
        
        buttonImagePicker.addTarget(self, action: #selector(ChatViewController.showLibrary), forControlEvents: .TouchUpInside)
        
        let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonCamera.setImage(UIImage(named: "camera"), forState: .Normal)
        buttonCamera.setImage(UIImage(named: "camera"), forState: .Highlighted)
        contentView.addSubview(buttonCamera)
        
        buttonCamera.addTarget(self, action: #selector(ChatViewController.showCamera), forControlEvents: .TouchUpInside)
        
        buttonVoiceRecorder = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), forState: .Normal)
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), forState: .Highlighted)
        //add a function
        buttonVoiceRecorder.addTarget(self, action: #selector(ChatViewController.showRecord), forControlEvents: .TouchUpInside)
        
        contentView.addSubview(buttonVoiceRecorder)
        
        let buttonLocation = UIButton(frame: CGRect(x: 21 + contentOffset * 5, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonLocation.setImage(UIImage(named: "shareLocation"), forState: .Normal)
        buttonLocation.setImage(UIImage(named: "shareLocation"), forState: .Highlighted)
        //add a function
        buttonLocation.addTarget(self, action: #selector(ChatViewController.sendLocation), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonLocation)
        
        buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 6, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Highlighted)
        contentView.addSubview(buttonSend)
        buttonSend.enabled = false
        buttonSend.addTarget(self, action: #selector(ChatViewController.sendMessageButtonTapped), forControlEvents: .TouchUpInside)
        
        buttonSet.append(buttonKeyBoard)
        buttonSet.append(buttonSticker)
        buttonSet.append(buttonImagePicker)
        buttonSet.append(buttonCamera)
        buttonSet.append(buttonLocation)
        buttonSet.append(buttonVoiceRecorder)
        buttonSet.append(buttonSend)
        
        for button in buttonSet{
            button.autoresizingMask = [.FlexibleTopMargin]
        }
    }
    
    func setupToolbarContentView()
    {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0,y: screenHeight,width: screenWidth, height: 271))
        toolbarContentView.delegate = self
        toolbarContentView.cleanUpSelectedPhotos()
        UIApplication.sharedApplication().keyWindow?.addSubview(toolbarContentView)
    }
    
    //MARK: - JSQMessages Delegate function
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if text != "" {
            //send message
            sendMessage(text, date: date, picture: nil, sticker : nil, location: nil, snapImage : nil, audio : nil)
        }
    }
    
    //MARK: - keyboard input bar tapped event
    func showKeyboard() {
        
        resetToolbarButtonIcon()
        self.buttonKeyBoard.setImage(UIImage(named: "keyboard"), forState: .Normal)
        self.toolbarContentView.showKeyboard()
        scrollToBottom(true)
        self.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    func showCamera() {
        view.endEditing(true)
        UIView.animateWithDuration(0.3, animations: {
             self.closeToolbarContentView()
            }, completion:{ (Bool) -> Void in
        })
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    
    func showStikcer() {
        resetToolbarButtonIcon()
        buttonSticker.setImage(UIImage(named: "stickerChosen"), forState: .Normal)
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showStikcer()
        moveUpInputBarContentView(animated)
    }
    
    func showLibrary() {
        resetToolbarButtonIcon()
        buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), forState: .Normal)
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showLibrary()
        moveUpInputBarContentView(animated)
    }
    
    func showRecord() {
        resetToolbarButtonIcon()
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage_red"), forState: .Normal)
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showRecord()
        moveUpInputBarContentView(animated)
    }
    
    func sendLocation() {
        resetToolbarButtonIcon()
        closeToolbarContentView()
        let vc = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatSendLocationController") as! ChatSendLocationController
        vc.locationDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func sendMessageButtonTapped() {
        sendMessage(self.inputToolbar.contentView.textView.text, date: NSDate(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil)
        buttonSend.enabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
    }
    
    //MARK: navigationItem function
    // right item , show all push notification
    func navigationItemTapped() {
    }
    
    //for voice test
    //    override func didPressAccessoryButton(sender: UIButton!) {
    //    }
     
    //MARK: - input text field delegate & keyboard
    
    override func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count == 0 {
            // when text has no char, cannot send message
            buttonSend.enabled = false
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
        } else {
            buttonSend.enabled = true
            buttonSend.setImage(UIImage(named: "canSendMessage"), forState: .Normal)
        }
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
    }
    
    override func textViewDidBeginEditing(textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), forState: .Normal)
        self.showKeyboard()
    }
    
    func keyboardDidShow(notification: NSNotification){
        toolbarContentView.keyboardShow = true
        scrollToBottom(true)
    }
    
    func keyboardDidHide(notification: NSNotification){
        toolbarContentView.keyboardShow = false
    }
    
    
    // MARK: - scroll view delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView == collectionView){
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            if(scrollViewCurrentOffset - scrollViewOriginOffset < 0 && (toolbarContentView.mediaContentShow) && !isClosingToolbarContentView && scrollView.scrollEnabled == true){
                self.toolbarContentView.frame.origin.y = min(screenHeight - 273 - (scrollViewCurrentOffset - scrollViewOriginOffset ), screenHeight)

                self.inputToolbar.frame.origin.y = min(screenHeight - 271 - 155 - (scrollViewCurrentOffset - scrollViewOriginOffset), screenHeight - 155)
            }
            if scrollViewCurrentOffset < 1 && !isLoadingPreviousMessages{
                loadPreviousMessages()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if(scrollView == collectionView){
            scrollViewOriginOffset = scrollView.contentOffset.y
        }
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if(scrollView == collectionView){
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            if(scrollViewCurrentOffset - scrollViewOriginOffset < -5){
                
                isClosingToolbarContentView = true
                UIView.animateWithDuration(0.2, animations: {
                    self.moveDownInputBar()
                    self.toolbarContentView.frame.origin.y = self.screenHeight
                    }, completion: {(Bool)->Void in
                        self.toolbarContentView.closeAll()
                        self.resetToolbarButtonIcon()
                        self.isClosingToolbarContentView = false
                })
            }
        }
    }
    
    
    //MARK: - Helper functions
    func enableTimeStamp(){
        self.isContinuallySending = false
    }
    
    func haveAccessToLocation() -> Bool {// not use anymore
        return true
    }
    
    func getAvatar() {
        if showAvatar {
            createAvatars(avatarImageDictionary)
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(35, 35)
            self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(35, 35)
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
        func createAvatars(avatars : NSMutableDictionary?) {
            let currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage((avatarDic[user_id] ?? UIImage(named: "avatarPlaceholder")) , diameter: 70)
            let withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage((avatarDic[NSNumber(integer:Int(withUser!.userId)!)] ?? UIImage(named: "avatarPlaceholder")), diameter: 70)
            avatarDictionary = [user_id.stringValue : currentUserAvatar, withUser!.userId : withUserAvatar]
            // need to check if collectionView exist before reload
        }
    
    func moveUpInputBarContentView(animated: Bool)
    {
        self.collectionView.scrollEnabled = false
        if(animated){
            self.toolbarContentView.frame.origin.y = self.screenHeight
            UIView.animateWithDuration(0.3, animations: {
                self.moveUpInputBar()
                self.toolbarContentView.frame.origin.y = self.screenHeight - 271
                }, completion:{ (Bool) -> Void in
                    self.collectionView.scrollEnabled = true
            })
        }else{
            self.moveUpInputBar()
            self.toolbarContentView.frame.origin.y = self.screenHeight - 271
            self.collectionView.scrollEnabled = true
        }
        scrollToBottom(animated)
    }
    
    func moveUpInputBar() {
        //when keybord, stick, photoes preview show, move tool bar up
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = self.screenHeight - 275 - 150
        UIView.setAnimationsEnabled(false)
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + 90, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + 90, right: 0.0)
        UIView.setAnimationsEnabled(true)
        //        self.inputToolbar.frame.origin.y = yPosition
        self.inputToolbar.frame = CGRectMake(xPosition, yPosition, width, height)
    }
    
    func moveDownInputBar() {
        //
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = screenHeight - 153
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 90, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 90, right: 0.0)
        self.inputToolbar.frame = CGRectMake(xPosition, yPosition, width, height)
    }
    
    func scrollToBottom(animated:Bool) {
        //override:
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        //get the last item index
        if item >= 0 {
            let lastItemIndex = NSIndexPath(forItem: item, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Top , animated: animated)
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
    
    func showAlertView() {
        let alert = UIAlertController(title: "You can send up to 10 photos at once", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getMoreImage()
    {
        //jump to the get more image collection view, and deselect the image we select in photoes preview
        let vc = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewControllerWithIdentifier("CustomCollectionViewController")as! CustomCollectionViewController
        vc.imageDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func resetToolbarButtonIcon()
    {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Highlighted)
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), forState: .Normal)
        buttonVoiceRecorder.setImage(UIImage(named: "voiceMessage"), forState: .Highlighted)
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
    }
    
    func endEdit()
    {
        self.view.endEditing(true)
    }
    
    //MARK: -  UIImagePickerController
    // this function is not use anymore
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil)

        UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func image(image:UIImage, didFinishSavingWithError error: NSError, contextInfo:AnyObject?)
    {
        self.appWillEnterForeground()
    }
    
}


