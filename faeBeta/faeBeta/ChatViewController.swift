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
import IDMPhotoBrowser
import Photos

public let kAVATARSTATE = "avatarState"
public let kFIRSTRUN = "firstRun"
public var headerDeviceToken: NSData!

class ChatViewController: JSQMessagesViewControllerCustom, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate ,SendMutipleImagesDelegate, SendStickerDelegate, LocationSendDelegate {
    
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
    var withUser : BackendlessUser?
    {
        didSet{
            self.getAvatar()
        }
    }
    var withUserId : String? // the user id we chat to
    var currentUserId : String?// my user id
    var recent : NSDictionary?//recent chat room message
    var chatRoomId : String!
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
    var fileName = "audioFile.m4a"
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var voiceData = NSData()
    var startRecording = false
    //custom toolBar the bottom toolbar button
    var buttonSet = [UIButton]()
    var buttonSend : UIButton!
    var buttonKeyBoard : UIButton!
    var buttonSticker : UIButton!
    var buttonImagePicker : UIButton!
    //album //a helper to send photo
    var photoPicker : PhotoPicker!
    var photoQuickCollectionView : UICollectionView!//preview of the photoes
    let photoQuickCollectionReuseIdentifier = "photoQuickCollectionReuseIdentifier"
    var selectedImage = [UIImage]()
    var imageDict = [Int : UIImage]()
    var imageReverseDict = [UIImage : NSIndexPath]()
    var imageIndexDict = [UIImage : Int]()
    var indexImageDict = [Int : UIImage]()
    var frameImageName = ["photoQuickSelection1", "photoQuickSelection2", "photoQuickSelection3", "photoQuickSelection4","photoQuickSelection5", "photoQuickSelection6", "photoQuickSelection7", "photoQuickSelection8", "photoQuickSelection9", "photoQuickSelection10"]
    // show at most 10 images
    let requestOption = PHImageRequestOptions()
    var imageQuickPickerShow = false //false : not open the photo preview
    
    var quickSendImageButton : UIButton!//right
    var moreImageButton : UIButton!//left
    
    //sticker
    var stickerViewShow = false//false : not open the stick view
    var stickerPicker : StickerPickView!
    
    //keyboard
    var keyboardHeight: CGFloat! = 0
    var keyboardShow = false // false: keyboard is hide
    
    //scroll view
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
        closeQuickPhotoPanel()
        closeStickerPanel()
//        clearRecentCounter(chatRoomId)// clear the unread message count
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
        self.currentUserId = backendless.userService.currentUser.objectId
        self.senderId = backendless.userService.currentUser.objectId
        self.senderDisplayName = backendless.userService.currentUser.name
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        self.inputToolbar.contentView.textView.delegate = self
        //load firebase messages
        loadMessage()
        // Do any additional setup after loading the view.
        loadInputBarComponent()
        self.inputToolbar.contentView.textView.placeHolder = "Type Something..."
        self.inputToolbar.contentView.backgroundColor = UIColor.whiteColor()
        initializePhotoQuickPicker()
        photoPicker = PhotoPicker()
        addObservers()
    }
    
    override func viewWillAppear(animated: Bool) {
        //check user default
        super.viewWillAppear(true)
        setupRecorder()
        initializeStickerView()
        loadUserDefault()
        self.scrollToBottomAnimated(true)
    }
    
    // MARK: - setup
    
    func navigationBarSet() {
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        let attributes = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : faeGray]
        self.navigationController?.navigationBar.tintColor = colorFae
        self.navigationController!.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "bellHollow"), style: .Plain, target: self, action: #selector(ChatViewController.navigationItemTapped))
        
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        titleLabel.text = withUser == nil ? recent!["withUserUsername"] as? String : withUser?.name
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        self.navigationItem.titleView = titleLabel
    }
    
    func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow), name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidHide), name:UIKeyboardDidHideNotification, object: nil)
    }
    
    // sticker view
    
    func initializeStickerView() {
        stickerPicker = StickerPickView(frame: CGRect(x: 0, y: screenHeight - 271, width: screenWidth, height: 271))
        stickerPicker.sendStickerDelegate = self
    }
    
    //quick image picker and collection view delegate
    
    func initializePhotoQuickPicker() {
        //photoes preview
        let layout = UICollectionViewFlowLayout()
        //        layout.itemSize = CGSizeMake(220, 235)
        layout.scrollDirection = .Horizontal
        photoQuickCollectionView = UICollectionView(frame: CGRect(x: 0, y:screenHeight - 271, width: screenWidth, height: screenHeight), collectionViewLayout: layout)
        photoQuickCollectionView.registerNib(UINib(nibName: "PhotoQuickPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: photoQuickCollectionReuseIdentifier)
        photoQuickCollectionView.delegate = self
        photoQuickCollectionView.dataSource = self
        quickSendImageButton = UIButton(frame: CGRect(x: 10, y: screenHeight - 52, width: 42, height: 42))
        quickSendImageButton.setImage(UIImage(named: "moreImage"), forState: .Normal)
        quickSendImageButton.addTarget(self, action: #selector(ChatViewController.getMoreImage), forControlEvents: .TouchUpInside)
        moreImageButton = UIButton(frame: CGRect(x: screenWidth - 52, y: screenHeight - 52, width: 42, height: 42))
        moreImageButton.addTarget(self, action: #selector(ChatViewController.sendImageFromQuickPicker), forControlEvents: .TouchUpInside)
        moreImageButton.setImage(UIImage(named: "imageQuickSend"), forState: .Normal)
        
        requestOption.resizeMode = .Fast //resize time fast
        requestOption.deliveryMode = .HighQualityFormat //high pixel
        //        UIApplication.sharedApplication().keyWindow?.addSubview(photoQuickCollectionView)
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
        let contentOffset = (screenWidth - 42 - 29 * 6) / 5 + 29
        buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
        buttonKeyBoard.addTarget(self, action: #selector(keyboardButtonClicked), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonKeyBoard)
        
        buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: 54, width: 29, height: 29))
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
        buttonSticker.addTarget(self, action: #selector(ChatViewController.showStikcer), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonSticker)
        
        buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: 54, width: 29, height: 29))
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
        contentView.addSubview(buttonImagePicker)
        
        buttonImagePicker.addTarget(self, action: #selector(ChatViewController.showLibrary), forControlEvents: .TouchUpInside)
        
        let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: 54, width: 29, height: 29))
        buttonCamera.setImage(UIImage(named: "camera"), forState: .Normal)
        contentView.addSubview(buttonCamera)
        
        buttonCamera.addTarget(self, action: #selector(ChatViewController.showCamera), forControlEvents: .TouchUpInside)
        
        let buttonLocation = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: 54, width: 29, height: 29))
        buttonLocation.setImage(UIImage(named: "shareLocation"), forState: .Normal)
        //add a function
        buttonLocation.addTarget(self, action: #selector(ChatViewController.sendLocation), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonLocation)
        
        buttonLocation.addTarget(self, action: #selector(ChatViewController.initializeStickerView), forControlEvents: .TouchUpInside)
        
        buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 5, y: 54, width: 29, height: 29))
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
        contentView.addSubview(buttonSend)
        buttonSend.enabled = false
        buttonSend.addTarget(self, action: #selector(ChatViewController.sendMessageButtonTapped), forControlEvents: .TouchUpInside)
        
        buttonSet.append(buttonKeyBoard)
        buttonSet.append(buttonSticker)
        buttonSet.append(buttonImagePicker)
        buttonSet.append(buttonCamera)
        buttonSet.append(buttonLocation)
        buttonSet.append(buttonSend)
        
        for button in buttonSet{
            button.autoresizingMask = [.FlexibleTopMargin]
        }
    }
    
    //MARK: voice helper function
    
    func setupRecorder() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(.Speaker)
        } catch let error as NSError {
            print(error.description)
        }
        let recordSettings = [AVFormatIDKey : Int(kAudioFormatAppleLossless),
                              AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0 ]
        do {
            soundRecorder = try AVAudioRecorder(URL: getFileURL(), settings: recordSettings as! [String : AnyObject])
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print("cannot record")
        }
    }
    
    //MARK: - JSQMessages Delegate function
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if text != "" {
            //send message
            sendMessage(text, date: date, picture: nil, sticker : nil, location: nil, snapImage : nil, audio : nil)
        }
    }
    
    //MARK: - keyboard input bar tapped event
    func keyboardButtonClicked() {
        //show keyboard and dismiss all other view, like stick and photoes preview
        //        isTyping = false
        if stickerViewShow {
            buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
            stickerPicker.removeFromSuperview()
            //            moveDownInputBar()
            stickerViewShow = false
        }
        if imageQuickPickerShow {
            photoQuickCollectionView.removeFromSuperview()
            moreImageButton.removeFromSuperview()
            quickSendImageButton.removeFromSuperview()
            //            moveDownInputBar()
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
            imageQuickPickerShow = false
        }
        scrollToBottom(true)
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), forState: .Normal)
        self.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    func showCamera() {
        view.endEditing(true)
        closeStickerPanel()
        closeQuickPhotoPanel()
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: true)
    }
    
    
    func showStikcer() {
        
        //show stick view, and dismiss all other views, like keyboard and photoes preview
        if !stickerViewShow {
            UIApplication.sharedApplication().keyWindow?.addSubview(self.stickerPicker)
            self.stickerPicker.frame.origin.y = screenHeight
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
            buttonSticker.setImage(UIImage(named: "stickerChosen"), forState: .Normal)
            if self.imageQuickPickerShow {
                self.photoQuickCollectionView.removeFromSuperview()
                self.moreImageButton.removeFromSuperview()
                self.quickSendImageButton.removeFromSuperview()
                self.buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
                self.imageQuickPickerShow = false
                self.stickerPicker.frame.origin.y = self.screenHeight - 271
            } else if (keyboardShow){
                UIView.setAnimationsEnabled(false)
                self.view.endEditing(true)
                UIView.setAnimationsEnabled(true)
                self.moveUpInputBar()
                self.scrollToBottom(false)
                self.stickerPicker.frame.origin.y = self.screenHeight - 271
            }else{
                UIView.animateWithDuration(0.3, animations: {
                    self.moveUpInputBar()
                    self.stickerPicker.frame.origin.y = self.screenHeight - 271
                })
            }
            
            self.stickerViewShow = true
        }
        self.scrollToBottom(true)
    }
    
    func showLibrary() {
        if !imageQuickPickerShow {
            UIApplication.sharedApplication().keyWindow?.addSubview(photoQuickCollectionView)
            UIApplication.sharedApplication().keyWindow?.addSubview(quickSendImageButton)
            UIApplication.sharedApplication().keyWindow?.addSubview(moreImageButton)
            photoQuickCollectionView.frame.origin.y = screenHeight
            quickSendImageButton.alpha = 0
            moreImageButton.alpha = 0
            
            buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), forState: .Normal)
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
            
            if stickerViewShow {
                stickerPicker.removeFromSuperview()
                buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
                stickerViewShow = false
                self.photoQuickCollectionView.frame.origin.y = self.screenHeight - 271
                self.quickSendImageButton.alpha = 1
                self.moreImageButton.alpha = 1
            } else if (keyboardShow){
                UIView.setAnimationsEnabled(false)
                self.view.endEditing(true)
                UIView.setAnimationsEnabled(true)
                moveUpInputBar()
                scrollToBottom(false)
                self.photoQuickCollectionView.frame.origin.y = self.screenHeight - 271
                self.quickSendImageButton.alpha = 1
                self.moreImageButton.alpha = 1
            }else{
                UIView.animateWithDuration(0.3, animations: {
                    self.moveUpInputBar()
                    self.photoQuickCollectionView.frame.origin.y = self.screenHeight - 271
                    self.quickSendImageButton.alpha = 1
                    self.moreImageButton.alpha = 1
                })
            }
            
            imageQuickPickerShow = true
        }
        scrollToBottom(true)
    }
    
    func sendLocation() {
        closeStickerPanel()
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
    //        if !startRecording {
    //            print("recording")
    //            soundRecorder.record()
    //        } else {
    //            soundRecorder.stop()
    //            // send voice message to firebase
    //            voiceData = NSData(contentsOfURL: getFileURL())!
    //            sendMessage(nil, date: NSDate(), picture: nil, location: nil, audio: voiceData)
    //        }
    //        startRecording = !startRecording
    //    }
    //MARK: - send message
    
    func sendMessage(text : String?, date: NSDate, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : NSData?, audio : NSData?) {
        
        var outgoingMessage = OutgoingMessage?()
        let shouldHaveTimeStamp = date.timeIntervalSinceDate(lastMarkerDate) > 300
        //if text message
        if text != nil {
            // send message
            outgoingMessage = OutgoingMessage(message: text!, senderId: currentUserId!, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "text", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            
        }
        if let pic = picture {
            // send picture message
            let imageData = UIImagePNGRepresentation(pic)
            outgoingMessage = OutgoingMessage(message: "Picture", picture: imageData!, senderId: currentUserId!, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "picture" , index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        if let sti = sticker {
            // send sticker
            let imageData = UIImagePNGRepresentation(sti)
            outgoingMessage = OutgoingMessage(message: "Sticker", picture: imageData!, senderId: currentUserId!, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "sticker", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        
        if let loc = location {
            // send location message
            let lat : NSNumber = NSNumber(double: loc.coordinate.latitude)
            let lon : NSNumber = NSNumber(double: loc.coordinate.longitude)
            
            outgoingMessage = OutgoingMessage(message: "Location", latitude: lat, longitude: lon, snapImage: snapImage!, senderId: currentUserId!, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "location", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        if audio != nil {
            //create outgoing-message object
            outgoingMessage = OutgoingMessage(message: "This is a Voice Message", audio: audio!, senderId: currentUserId!, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "audio", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            
        }
        
        //play message sent sound
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        print(outgoingMessage!.messageDictionary)
        print(chatRoomId)
        self.finishSendingMessage()
        
        if(withUser != nil){
            // add this outgoing message under chatRoom with id and content
            outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary, receiverDeviceToken: withUser?.getProperty("device_id")! as! String)
        }
    }
    
    //send image delegate function
    func sendImages(images: [UIImage]) {
        for image in images {
            print("sending one image")
            self.sendMessage(nil, date: NSDate(), picture: image, sticker : nil, location: nil, snapImage : nil, audio: nil)
        }
    }
    
    func sendStickerWithImageName(name: String) {
        sendMessage(nil, date: NSDate(), picture: nil, sticker : UIImage(named: name), location: nil, snapImage : nil, audio: nil)
        stickerPicker.updateStickerHistory(name)
        //        stickerPicker.reloadHistory()
    }
    
    func sendImageFromQuickPicker() {
        for image in [UIImage](imageDict.values) {
            self.sendMessage(nil, date: NSDate(), picture: image, sticker : nil, location: nil, snapImage : nil, audio: nil)
        }
        for image in [UIImage](imageDict.values) {
            let cell = photoQuickCollectionView.cellForItemAtIndexPath(imageReverseDict[image]!) as?PhotoQuickPickerCollectionViewCell
            if(cell != nil){
                cell!.chosenFrameImageView.hidden = true
            }
        }
        selectedImage.removeAll()
        imageDict.removeAll()
        imageReverseDict.removeAll()
        imageIndexDict.removeAll()
        indexImageDict.removeAll()
    }
    
    //MARK: locationSend Delegate
    func sendPickedLocation(lat: CLLocationDegrees, lon: CLLocationDegrees, screenShot: NSData) {
        sendMessage(nil, date: NSDate(), picture: nil, sticker: nil, location: CLLocation(latitude: lat, longitude: lon), snapImage : screenShot, audio: nil)
    }
    
    //MARK: Load Message
    // this function open observer on firebase, update datesource of JSQMessage when any change happen on firebase
    func loadMessage() {
        
        ref.child(chatRoomId).queryLimitedToLast(UInt(numberOfMessagesOneTime)).observeEventType(.ChildAdded) { (snapshot : FIRDataSnapshot) in
            if snapshot.exists() {
                // becasue the type is ChildAdded so the snapshot is the new message
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialLoadComplete {//message has been downloaded from databse but not load to collectionview yet.
                    
                    let isIncoming = self.insertMessage(item)
                    
                    if isIncoming {
                        
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishReceivingMessageAnimated(true)
                    
                    
                }
                else {
                    // add each dictionary to loaded array
                    self.loaded.append(item)
                    self.numberOfMessagesLoaded += 1
                }
            }
        }
        
        ref.child(chatRoomId).observeEventType(.ChildChanged) { (snapshot : FIRDataSnapshot) in
            
        }
        
        ref.child(chatRoomId).observeEventType(.ChildRemoved) { (snapshot : FIRDataSnapshot) in
            
        }
        
        ref.child(chatRoomId).observeSingleEventOfType(.Value) { (snapshot : FIRDataSnapshot) in
            //this function will run only once
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialLoadComplete = true
        }
        
    }
    
    func loadPreviousMessages(){
        self.isLoadingPreviousMessages = true
        if(totalNumberOfMessages > numberOfMessagesLoaded){
            ref.child(chatRoomId).queryOrderedByChild("index").queryStartingAtValue(max(totalNumberOfMessages - numberOfMessagesLoaded - numberOfMessagesOneTime + 1,1)).queryEndingAtValue(totalNumberOfMessages - numberOfMessagesLoaded).observeSingleEventOfType(.Value) { (snapshot : FIRDataSnapshot) in
                if snapshot.exists() {
                    let result = snapshot.value!.allValues as! [NSDictionary]
                    for item in result.sort({ ($0["index"] as! Int) > ($1["index"] as! Int)}) {
                        self.insertMessage(item,atIndex: 0)
                        self.numberOfMessagesLoaded += 1

                    }
                    let oldOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
                    self.collectionView.reloadData()
                    self.collectionView.layoutIfNeeded()
                    self.collectionView.contentOffset = CGPointMake(0.0, self.collectionView.contentSize.height - oldOffset);

                }
                self.isLoadingPreviousMessages = false
            }
        }else{
            self.isLoadingPreviousMessages = false
        }
    }
    
    //parse information for firebase
    func insertMessages() {
        
        for item in loaded {
            //create message
            insertMessage(item)
        }
    }
    
    func insertMessage(item : NSDictionary) -> Bool {
        //unpack the message from data load to the JSQmessage
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        if(item["hasTimeStamp"] as! Bool){
            let date = dateFormatter().dateFromString((item["date"] as? String)!)
            lastMarkerDate = date
        }
        objects.append(item)
        messages.append(message!)
        
        return incoming(item)
    }
    
    func insertMessage(item : NSDictionary, atIndex index: Int) -> Bool {
        //unpack the message from data load to the JSQmessage
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        objects.insert(item, atIndex: index)
        messages.insert(message!, atIndex: index)
        
        return incoming(item)
    }
    
    func incoming(item : NSDictionary) -> Bool {
        if currentUserId == item["senderId"] as? String {
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item : NSDictionary) -> Bool {
        if currentUserId == item["senderId"] as? String {
            return true
        } else {
            return false
        }
        
    }
    
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
        self.keyboardButtonClicked()
    }
    
    func keyboardDidShow(notification: NSNotification){
        keyboardShow = true
        scrollToBottom(true)
    }
    
    func keyboardDidHide(notification: NSNotification){
        keyboardShow = false
    }
    
    // MARK: - collection view delegate
    
    // JSQMessage delegate not only should handle chat bubble itself, it should handle photoQuickSelect cell
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == photoQuickCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoQuickCollectionReuseIdentifier, forIndexPath: indexPath) as! PhotoQuickPickerCollectionViewCell
            //get image from PHFetchResult
            dispatch_async(dispatch_get_main_queue(), { () in
                
                let asset : PHAsset = self.photoPicker.currentAlbum.albumContent[indexPath.item] as! PHAsset
                
                PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(self.view.frame.width - 1 / 3, self.view.frame.width - 1 / 3), contentMode: .AspectFill, options: self.requestOption) { (result, info) in
                    cell.setImage(result!)
                }
                
                if self.imageDict[indexPath.row] != nil {
                    cell.chosenFrameImageView.hidden = false
                    cell.chosenFrameImageView.image = UIImage(named: self.frameImageName[self.imageIndexDict[self.imageDict[indexPath.row]!]!])
                }
                
            })
            return cell
            
        }
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == backendless.userService.currentUser.objectId {
            cell.textView?.textColor = UIColor.whiteColor()
            cell.textView?.font = UIFont(name: "Avenir Next", size: 16)
        } else {
            cell.textView?.textColor = UIColor(red: 107.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
            cell.textView?.font = UIFont(name: "Avenir Next", size: 16)
        }
        cell.avatarImageView.layer.cornerRadius = 17.5
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView && indexPath.row == messages.count - 1{
            clearRecentCounter(chatRoomId)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoQuickCollectionView {
            return photoPicker.currentAlbum.albumCount
        }
        return messages.count
    }
    
    //this delegate is used to tell which bubble image should be used on current message
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == backendless.userService.currentUser.objectId {
            if data.isMediaMessage {
                outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubbleImage: UIImage(named: "avatarPlaceholder"), capInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)).outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleRedColor())
            }
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    //this is used to edit top label of every cell
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let object = objects[indexPath.row]
        if object["hasTimeStamp"] as! Bool {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayoutCustom!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let object = objects[indexPath.row]
        if object["hasTimeStamp"] as! Bool  {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayoutCustom!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0.0
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
        let status = message["status"] as! String
        
        if indexPath.row == messages.count - 1 {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
        
    }
    // bind avatar image
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    //photoes preview delegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == photoQuickCollectionView {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoQuickPickerCollectionViewCell
            if cell.chosenFrameImageView.hidden {
                if imageDict.count == 10 {
                    showAlertView()
                } else {
                    imageDict[indexPath.row] = cell.photoImageView.image
                    imageIndexDict[cell.photoImageView.image!] = imageDict.count - 1
                    indexImageDict[imageDict.count - 1] = cell.photoImageView.image
                    cell.chosenFrameImageView.image = UIImage(named: frameImageName[imageDict.count - 1])
                    cell.chosenFrameImageView.hidden = false
                    imageReverseDict[cell.photoImageView.image!] = indexPath
                }
            } else {
                cell.chosenFrameImageView.hidden = true
                let deselectedImage = imageDict[indexPath.row]
                let deselectedIndex = imageIndexDict[deselectedImage!]
                imageIndexDict[deselectedImage!] = nil
                indexImageDict[deselectedIndex!] = nil
                shiftChosenFrameFromIndex(deselectedIndex! + 1)
                imageDict[indexPath.row] = nil
                imageReverseDict[deselectedImage!] = nil
            }
            print("imageDict has \(imageDict.count) images")
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
    }
    //photoes preview layout
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.5
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    //taped bubble
    // function when user tap the bubble, like image, location
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        closeStickerPanel()
        closeQuickPhotoPanel()
        
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQPhotoMediaItemCustom
            
            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
        }
        
        if object["type"] as! String == "location" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQLocationMediaItemCustom
            
            let vc = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewControllerWithIdentifier("ChatMapViewController")as! ChatMapViewController
            
            vc.chatLatitude = mediaItem.coordinate.latitude
            vc.chatLongitude = mediaItem.coordinate.longitude
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if object["type"] as! String == "audio" {
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQAudioMediaItem
            
            let data = mediaItem.audioData
            
            preparePlayer(data!)
            
            soundPlayer.play()
        }
    }
    
    
    // MARK: - scroll view delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView == collectionView){
            let scrollViewCurrentOffset = scrollView.contentOffset.y
            if(scrollViewCurrentOffset - scrollViewOriginOffset < 0 && (stickerViewShow || imageQuickPickerShow)){
                if(stickerViewShow){
                    self.stickerPicker.frame.origin.y = min(screenHeight - 271 - (scrollViewCurrentOffset - scrollViewOriginOffset ), screenHeight)
                }else if(imageQuickPickerShow){
                    self.photoQuickCollectionView.frame.origin.y = min(screenHeight - 271 - (scrollViewCurrentOffset - scrollViewOriginOffset ), screenHeight)
                    self.moreImageButton.alpha = 1 - min( -(scrollViewCurrentOffset - scrollViewOriginOffset), 271) / 271.0
                    self.quickSendImageButton.alpha = 1 - min( -(scrollViewCurrentOffset - scrollViewOriginOffset ), 271) / 271.0
                    
                }
                self.inputToolbar.frame.origin.y = min(screenHeight - 271 - 155 - (scrollViewCurrentOffset - scrollViewOriginOffset), screenHeight - 155)
            }
            if scrollViewCurrentOffset < 5 && !isLoadingPreviousMessages{
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
                if(stickerViewShow){
                    UIView.animateWithDuration(0.2, animations: {
                        self.moveDownInputBar()
                        self.stickerPicker.frame.origin.y = self.screenHeight
                        }, completion: {(Bool)->Void in
                            self.stickerViewShow = false
                            self.buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
                            self.stickerPicker.removeFromSuperview()
                    })
                }else if (imageQuickPickerShow){
                    UIView.animateWithDuration(0.2, animations: {
                        self.moveDownInputBar()
                        self.photoQuickCollectionView.frame.origin.y = self.screenHeight
                        self.moreImageButton.alpha = 0
                        self.quickSendImageButton.alpha = 0
                        }, completion: {(Bool)->Void in
                            self.imageQuickPickerShow = false
                            self.buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
                            self.photoQuickCollectionView.removeFromSuperview()
                            self.moreImageButton.removeFromSuperview()
                            self.quickSendImageButton.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    
    //MARK: - Helper functions
    
    func haveAccessToLocation() -> Bool {// not use anymore
        return true
    }
    
    func getAvatar() {
        if showAvatar {
            
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(35, 35)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(35, 35)
            
            //download avatars
            //            avatarImageFromBackendlessUser(backendless.userService.currentUser)
            //            avatarImageFromBackendlessUser(withUser!)
            
            //create avatars
            createAvatars(avatarImageDictionary)
        }
    }
    
//        func getWithUserFromRecent(recent : NSDictionary, result : (withUser : BackendlessUser) -> Void ) {
//    
//            let withUserId = recent["withUserUserId"] as? String
//    
//            let whereClause = "objectId = '\(withUserId!)'"
//            let dataQuery = BackendlessDataQuery()
//            dataQuery.whereClause = whereClause
//    
//            let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
//    
//            dataStore.find(dataQuery, response: { (users : BackendlessCollection!) -> Void in
//    
//                let withUser = users.data.first as! BackendlessUser
//    
//                result(withUser: withUser)
//    
//            }) { (fault : Fault!) -> Void in
//                print("Server report an error : \(fault)")
//            }
//    
//        }
    
        func createAvatars(avatars : NSMutableDictionary?) {
            let currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
            let withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
    
//            if let avat = avatars {
//                if let currentUserAvatarImage = avat.objectForKey(backendless.userService.currentUser.objectId) {
//    
//                    currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: currentUserAvatarImage as! NSData), diameter: 70)
//                    self.collectionView?.reloadData()
//                }
//            }
//    
//            if let avat = avatars {
//                if let withUserAvatarImage = avat.objectForKey(withUser!.objectId!) {
//    
//                    withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: withUserAvatarImage as! NSData), diameter: 70)
//                    self.collectionView?.reloadData()
//                }
//            }
    
            avatarDictionary = [backendless.userService.currentUser.objectId! : currentUserAvatar, withUser!.objectId! : withUserAvatar]
            // need to check if collectionView exist before reload
            if collectionView != nil {collectionView.reloadData()}
        }
    
//        func avatarImageFromBackendlessUser(user : BackendlessUser) {
//    
//            if let imageLink = user.getProperty("Avatar") {
//    
//                getImageFromURL(imageLink as! String, result: { (image) -> Void in
//    
//                    let imageData = UIImageJPEGRepresentation(image!, 1.0)
//    
//                    if self.avatarImageDictionary != nil {
//    
//                        self.avatarImageDictionary!.removeObjectForKey(user.objectId)
//                        self.avatarImageDictionary!.setObject(imageData!, forKey: user.objectId!)
//                    } else {
//                        self.avatarImageDictionary = [user.objectId! : imageData!]
//                    }
//                    self.createAvatars(self.avatarImageDictionary)
//    
//                })
//            }
//    
//        }
    
    func getCacheDirectory() -> String {
        //record: get an available path we can use to save record file
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func getFileURL() -> NSURL {
        //record: change the default save file path from getCacheDirectory
        let path = (getCacheDirectory() as NSString).stringByAppendingPathComponent(fileName)
        let filePath = NSURL(fileURLWithPath: path)
        
        return filePath
    }
    
    func preparePlayer(voiceMessage : NSData) {
        do {
            soundPlayer = try AVAudioPlayer(data: voiceMessage, fileTypeHint: nil)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1
        } catch {
            print("cannot play")
        }
    }
    
    func moveUpInputBar() {
        //when keybord, stick, photoes preview show, move tool bar up
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = self.inputToolbar.frame.origin.y - 271
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
        let yPosition = screenHeight - 155
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
    
    func closeStickerPanel() {
        if stickerViewShow {
            stickerPicker.hidden = true
            stickerPicker.removeFromSuperview()
            moveDownInputBar()
            scrollToBottom(true)
            stickerViewShow = false
            buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
        }
    }
    
    func closeQuickPhotoPanel() {
        
        if imageQuickPickerShow {
            photoQuickCollectionView.removeFromSuperview()
            moreImageButton.removeFromSuperview()
            quickSendImageButton.removeFromSuperview()
            moveDownInputBar()
            scrollToBottom(true)
            imageQuickPickerShow = false
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
            
        }
    }
    
    func shiftChosenFrameFromIndex(index : Int) {
        // when deselect one image in photoes preview, we need to reshuffule
        var i = index
        while i < imageDict.count {
            let image = indexImageDict[i]
            imageIndexDict[image!] = i - 1
            let cell = photoQuickCollectionView?.cellForItemAtIndexPath(imageReverseDict[image!]!) as! PhotoQuickPickerCollectionViewCell
            cell.chosenFrameImageView.image = UIImage(named: frameImageName[i-1])
            indexImageDict[i-1] = image
            i += 1
        }
    }
    
    func showAlertView() {
        let alert = UIAlertController(title: "You can send up to 10 photos at once", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getMoreImage() {
        //jump to the get more image collection view, and deselect the image we select in photoes preview
        for image in [UIImage](imageDict.values) {
            let cell = photoQuickCollectionView.cellForItemAtIndexPath(imageReverseDict[image]!) as! PhotoQuickPickerCollectionViewCell
            cell.chosenFrameImageView.hidden = true
        }
        selectedImage.removeAll()
        imageDict.removeAll()
        imageReverseDict.removeAll()
        imageIndexDict.removeAll()
        indexImageDict.removeAll()
        let vc = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewControllerWithIdentifier("CustomCollectionViewController")as! CustomCollectionViewController
        vc.imageDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: UIImagePickerController
    // this function is not use anymore
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}


