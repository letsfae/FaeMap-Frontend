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

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate,SendMutipleImagesDelegate, SendStickerDelegate, LocationSendDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    let appDeleget = UIApplication.sharedApplication().delegate as! AppDelegate
    let ref = firebase.database.reference().child("Message")
    var messages : [JSQMessage] = []
    var objects : [NSDictionary] = []
    var loaded : [NSDictionary] = []
    
    var avatarImageDictionary : NSMutableDictionary?
    var avatarDictionary : NSMutableDictionary?
    //
    var showAvatar : Bool = false
    let factor : CGFloat = 375 / 414
    var firstLoad : Bool?
//    var withUser : BackendlessUser?
    var withUserId : String?
    var currentUserId : String?
    var recent : NSDictionary?
    var chatRoomId : String!
    var initialLoadComplete : Bool = false
    var outgoingBubble = JSQMessagesBubbleImageFactory(bubbleImage: UIImage(named:"bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).outgoingMessagesBubbleImageWithColor(UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0))
    
    let incomingBubble = JSQMessagesBubbleImageFactory(bubbleImage: UIImage(named:"bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).incomingMessagesBubbleImageWithColor(UIColor.whiteColor())
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var faeGray = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    //voice
    var fileName = "audioFile.m4a"
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var voiceData = NSData()
    var startRecording = false
    //custom toolBar
    var buttonSet = [UIButton]()
    var buttonSend : UIButton!
    var buttonKeyBoard : UIButton!
    var buttonSticker : UIButton!
    var buttonImagePicker : UIButton!
    //album
    var photoPicker : PhotoPicker!
    var photoQuickCollectionView : UICollectionView!
    let photoQuickCollectionReuseIdentifier = "photoQuickCollectionReuseIdentifier"
    var selectedImage = [UIImage]()
    var imageDict = [Int : UIImage]()
    var imageReverseDict = [UIImage : NSIndexPath]()
    var imageIndexDict = [UIImage : Int]()
    var indexImageDict = [Int : UIImage]()
    var frameImageName = ["photoQuickSelection1", "photoQuickSelection2", "photoQuickSelection3", "photoQuickSelection4","photoQuickSelection5", "photoQuickSelection6", "photoQuickSelection7", "photoQuickSelection8", "photoQuickSelection9", "photoQuickSelection10"]
    let requestOption = PHImageRequestOptions()
    var imageQuickPickerShow = false
    
    var quickSendImageButton : UIButton!
    var moreImageButton : UIButton!
    
    //sticker
    var stickerViewShow = false
    var stickerPicker : StickerPickView!
    
    
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
    
    
    override func viewWillDisappear(animated: Bool) {
        //update recent
        super.viewWillDisappear(true)
        closeStickerPanel()
        closeQuickPhotoPanel()
        clearRecentCounter(chatRoomId)
        ref.removeAllObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        setupRecorder()
        initializeStickerView()
//        observeTyping()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSet()
        collectionView.backgroundColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1.0)
        self.senderId = currentUserId
        self.senderDisplayName = currentUserId
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        if withUserId == nil {
//            getWithUserFromRecent(recent!, result: { (withUser) in
//                self.withUser = withUser
//                self.title = withUser.name
//                self.getAvatar()
//            })
        } else {
//            self.title = withUser!.name
//            self.getAvatar()
        }
        self.inputToolbar.contentView.textView.delegate = self
        //load firebase messages
        loadMessage()
        // Do any additional setup after loading the view.
        loadInputBarComponent()
        self.inputToolbar.contentView.textView.placeHolder = "Type Something..."
        self.inputToolbar.contentView.backgroundColor = UIColor.whiteColor()
        initializePhotoQuickPicker()
        photoPicker = PhotoPicker()
    }
    
    func navigationBarSet() {
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        let attributes = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : faeGray]
        self.navigationController?.navigationBar.tintColor = colorFae
        self.navigationController!.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "bell"), style: .Plain, target: self, action: #selector(ChatViewController.navigationItemTapped))
    }
    
    override func viewWillAppear(animated: Bool) {
        //check user default
        super.viewWillAppear(true)
        loadUserDefault()
        self.scrollToBottomAnimated(true)
    }
    
    //MARK : JSQMessages dataSource functions
    
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
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoQuickCollectionView {
            return photoPicker.currentAlbum.albumCount
        }
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == backendless.userService.currentUser.objectId {
            if data.isMediaMessage {
                outgoingBubble = JSQMessagesBubbleImageFactory(bubbleImage: UIImage(named: "avatarPlaceholder"), capInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)).outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleRedColor())
            }
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0.0
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
        let status = message["status"] as! String
        
        if indexPath.row == messages.count - 1 {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    //MARK : JSQMessages Delegate function
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if text != "" {
            //send message
            sendMessage(text, date: date, picture: nil, sticker : nil, location: nil, snapImage : nil, audio : nil)
        }
    }
    
    func showCamera() {
        view.endEditing(true)
        closeStickerPanel()
        closeQuickPhotoPanel()
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: true)
    }
    
    func showLibrary() {
        view.endEditing(true)
        if !imageQuickPickerShow {
            
            buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), forState: .Normal)
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
            
            if stickerViewShow {
                stickerPicker.removeFromSuperview()
                buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
                stickerViewShow = false
            } else {
                moveUpInputBar()
            }
            UIApplication.sharedApplication().keyWindow?.addSubview(photoQuickCollectionView)
            UIApplication.sharedApplication().keyWindow?.addSubview(quickSendImageButton)
            UIApplication.sharedApplication().keyWindow?.addSubview(moreImageButton)
            imageQuickPickerShow = true
        }
        scrollToBottom()
    }
    
    func sendLocation() {
        //        if self.haveAccessToLocation() {
        //            self.sendMessage(nil, date: NSDate(), picture: nil, sticker : nil, location: "location", audio: nil)
        //        }
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatSendLocationController") as! ChatSendLocationController
        vc.locationDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func sendMessageButtonPressed() {
        sendMessage(self.inputToolbar.contentView.textView.text, date: NSDate(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil)
        buttonSend.enabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
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
    //MARK: send message
    
    func sendMessage(text : String?, date: NSDate, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : NSData?, audio : NSData?) {
        
        var outgoingMessage = OutgoingMessage?()
        
        //if text message
        if text != nil {
            // send message
            outgoingMessage = OutgoingMessage(message: text!, senderId: currentUserId!, senderName: currentUserId!, date: date, status: "Delivered", type: "text")
            
        }
        if let pic = picture {
            // send picture message
            let imageData = UIImagePNGRepresentation(pic)
            outgoingMessage = OutgoingMessage(message: "Picture", picture: imageData!, senderId: currentUserId!, senderName: currentUserId!, date: date, status: "Delivered", type: "picture")
        }
        
        if let sti = sticker {
            // send sticker
            let imageData = UIImagePNGRepresentation(sti)
            outgoingMessage = OutgoingMessage(message: "Sticker", picture: imageData!, senderId: currentUserId!, senderName: currentUserId!, date: date, status: "Delivered", type: "sticker")
        }
        
        
        if let loc = location {
            // send location message
            let lat : NSNumber = NSNumber(double: loc.coordinate.latitude)
            let lon : NSNumber = NSNumber(double: loc.coordinate.longitude)
            
            outgoingMessage = OutgoingMessage(message: "Location", latitude: lat, longitude: lon, snapImage: snapImage!, senderId: currentUserId!, senderName: currentUserId!, date: date, status: "Delivered", type: "location")
        }
        
        if audio != nil {
            //create outgoing-message object
            outgoingMessage = OutgoingMessage(message: "This is a Voice Message", audio: audio!, senderId: currentUserId!, senderName: currentUserId!, date: date, status: "Delivered", type: "audio")
            
        }
        
        //play message sent sound
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        print(outgoingMessage!.messageDictionary)
        print(chatRoomId)
        self.finishSendingMessage()
        
        // add this outgoing message under chatRoom with id and content
        outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary)
    }
    
    
    //MARK : Load Message
    
    func loadMessage() {
        
        ref.child(chatRoomId).observeEventType(.ChildAdded) { (snapshot : FIRDataSnapshot) in
            if snapshot.exists() {
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialLoadComplete {
                    
                    let incoming = self.insertMessage(item)
                    
                    if incoming {
                        
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishReceivingMessageAnimated(true)
                    
                } else {
                    
                    // add each dictionary to loaded array
                    self.loaded.append(item)
                }
            }
        }
        
        ref.child(chatRoomId).observeEventType(.ChildChanged) { (snapshot : FIRDataSnapshot) in
            
        }
        
        ref.child(chatRoomId).observeEventType(.ChildRemoved) { (snapshot : FIRDataSnapshot) in
            
        }
        
        ref.child(chatRoomId).observeSingleEventOfType(.Value) { (snapshot : FIRDataSnapshot) in
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialLoadComplete = true
        }
        
    }
    
    func insertMessages() {
        
        for item in loaded {
            //create message
            insertMessage(item)
        }
    }
    
    func insertMessage(item : NSDictionary) -> Bool {
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item)
    }
    
    func incoming(item : NSDictionary) -> Bool {
        if currentUserId == item["senderId"] as! String {
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item : NSDictionary) -> Bool {
        if currentUserId == item["senderId"] as! String {
            return true
        } else {
            return false
        }
        
    }
    
    //MARK: Helper functions
    
    func haveAccessToLocation() -> Bool {
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
//            createAvatars(avatarImageDictionary)
        }
    }
    
//    func getWithUserFromRecent(recent : NSDictionary, result : (withUser : BackendlessUser) -> Void ) {
//        
//        let withUserId = recent["withUserUserId"] as? String
//        
//        let whereClause = "objectId = '\(withUserId!)'"
//        let dataQuery = BackendlessDataQuery()
//        dataQuery.whereClause = whereClause
//        
//        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
//        
//        dataStore.find(dataQuery, response: { (users : BackendlessCollection!) -> Void in
//            
//            let withUser = users.data.first as! BackendlessUser
//            
//            result(withUser: withUser)
//            
//        }) { (fault : Fault!) -> Void in
//            print("Server report an error : \(fault)")
//        }
//        
//    }
    
//    func createAvatars(avatars : NSMutableDictionary?) {
//        var currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
//        var withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
//        
//        if let avat = avatars {
//            if let currentUserAvatarImage = avat.objectForKey(backendless.userService.currentUser.objectId) {
//                
//                currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: currentUserAvatarImage as! NSData), diameter: 70)
//                self.collectionView?.reloadData()
//            }
//        }
//        
//        if let avat = avatars {
//            if let withUserAvatarImage = avat.objectForKey(withUser!.objectId!) {
//                
//                withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: withUserAvatarImage as! NSData), diameter: 70)
//                self.collectionView?.reloadData()
//            }
//        }
//        
//        avatarDictionary = [backendless.userService.currentUser.objectId! : currentUserAvatar, withUser!.objectId! : withUserAvatar]
//    }
    
//    func avatarImageFromBackendlessUser(user : BackendlessUser) {
//        
//        if let imageLink = user.getProperty("Avatar") {
//            
//            getImageFromURL(imageLink as! String, result: { (image) -> Void in
//                
//                let imageData = UIImageJPEGRepresentation(image!, 1.0)
//                
//                if self.avatarImageDictionary != nil {
//                    
//                    self.avatarImageDictionary!.removeObjectForKey(user.objectId)
//                    self.avatarImageDictionary!.setObject(imageData!, forKey: user.objectId!)
//                } else {
//                    self.avatarImageDictionary = [user.objectId! : imageData!]
//                }
//                self.createAvatars(self.avatarImageDictionary)
//                
//            })
//        }
//        
//    }
    
    //MARK : JSQDelegate functions
    
    //taped bubble
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        closeStickerPanel()
        closeQuickPhotoPanel()
        
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQPhotoMediaItem
            
            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
        }
        
        if object["type"] as! String == "location" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("ChatMapViewController")as! ChatMapViewController
            
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
    
    //MARK : UIImagePickerController
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK : user default function
    
    func loadUserDefault() {
        firstLoad = userDefaults.boolForKey(kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setBool(showAvatar, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        
        showAvatar = userDefaults.boolForKey(kAVATARSTATE)
    }
    
    //MARK : voice helper function
    
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
    
    func getCacheDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func getFileURL() -> NSURL {
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
    
    //MARK: navigationItem function
    
    func navigationItemTapped() {
    }
    
    //MARK: delegate for input text field
    
    override func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count == 0 {
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
    
    //MARK: load custom input tool bar
    
    func loadInputBarComponent() {
        
        let camera = Camera(delegate_: self)
        let contentView = self.inputToolbar.contentView
        
        buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
        buttonKeyBoard.addTarget(self, action: #selector(keyboardButtonClicked), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonKeyBoard)
        
        buttonSticker = UIButton(frame: CGRect(x: 82, y: 54, width: 29, height: 29))
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
        buttonSticker.addTarget(self, action: #selector(stickButtonClicked), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonSticker)
        
        buttonImagePicker = UIButton(frame: CGRect(x: 143, y: 54, width: 29, height: 29))
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
        contentView.addSubview(buttonImagePicker)
        
        buttonImagePicker.addTarget(self, action: #selector(ChatViewController.showLibrary), forControlEvents: .TouchUpInside)
        
        let buttonCamera = UIButton(frame: CGRect(x: 204, y: 54, width: 29, height: 29))
        buttonCamera.setImage(UIImage(named: "camera"), forState: .Normal)
        contentView.addSubview(buttonCamera)
        
        buttonCamera.addTarget(self, action: #selector(ChatViewController.showCamera), forControlEvents: .TouchUpInside)
        
        let buttonLocation = UIButton(frame: CGRect(x: 265, y: 54, width: 29, height: 29))
        buttonLocation.setImage(UIImage(named: "shareLocation"), forState: .Normal)
        //add a function
        buttonLocation.addTarget(self, action: #selector(ChatViewController.sendLocation), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonLocation)
        
        buttonLocation.addTarget(self, action: #selector(ChatViewController.initializeStickerView), forControlEvents: .TouchUpInside)
        
        buttonSend = UIButton(frame: CGRect(x: 326, y: 54, width: 29, height: 29))
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
        contentView.addSubview(buttonSend)
        buttonSend.enabled = false
        buttonSend.addTarget(self, action: #selector(ChatViewController.sendMessageButtonPressed), forControlEvents: .TouchUpInside)
        
        buttonSet.append(buttonKeyBoard)
        buttonSet.append(buttonSticker)
        buttonSet.append(buttonImagePicker)
        buttonSet.append(buttonCamera)
        buttonSet.append(buttonLocation)
        buttonSet.append(buttonSend)
        
        for button in buttonSet {
            button.autoresizingMask = [.FlexibleTopMargin]
        }
    }
    
    func keyboardButtonClicked() {
//        isTyping = false
        if stickerViewShow {
            buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
            stickerPicker.removeFromSuperview()
            moveDownInputBar()
            stickerViewShow = false
        }
        if imageQuickPickerShow {
            photoQuickCollectionView.removeFromSuperview()
            moreImageButton.removeFromSuperview()
            quickSendImageButton.removeFromSuperview()
            moveDownInputBar()
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
            imageQuickPickerShow = false
        }
        scrollToBottom()
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), forState: .Normal)
        self.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    //send image delegate function
    
    func sendImages(images: [UIImage]) {
        for image in images {
            print("sending one image")
            self.sendMessage(nil, date: NSDate(), picture: image, sticker : nil, location: nil, snapImage : nil, audio: nil)
        }
    }
    
    // sticker view
    
    func stickButtonClicked() {
        if !stickerViewShow {
            view.endEditing(true)
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
            buttonSticker.setImage(UIImage(named: "stickerChosen"), forState: .Normal)
            if imageQuickPickerShow {
                photoQuickCollectionView.removeFromSuperview()
                moreImageButton.removeFromSuperview()
                quickSendImageButton.removeFromSuperview()
                buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
                imageQuickPickerShow = false
            } else {
                moveUpInputBar()
            }
            UIApplication.sharedApplication().keyWindow?.addSubview(stickerPicker)
            scrollToBottom()
            stickerViewShow = true
        }
    }
    
    func initializeStickerView() {
        stickerPicker = StickerPickView(frame: CGRect(x: 0, y: screenHeight - 271, width: screenWidth, height: 271))
                stickerPicker.sendStickerDelegate = self
    }
    
    func moveUpInputBar() {
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = self.inputToolbar.frame.origin.y - 271
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + 90, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + 90, right: 0.0)
        self.inputToolbar.frame = CGRectMake(xPosition, yPosition, width, height)
    }
    
    func moveDownInputBar() {
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = self.inputToolbar.frame.origin.y + 271
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 90, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 90, right: 0.0)
        self.inputToolbar.frame = CGRectMake(xPosition, yPosition, width, height)
    }
    
    func scrollToBottom() {
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        if item >= 0 {
            let lastItemIndex = NSIndexPath(forItem: item, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    func closeStickerPanel() {
        if stickerViewShow {
            stickerPicker.removeFromSuperview()
            moveDownInputBar()
            scrollToBottom()
            stickerViewShow = false
            buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
        }
    }
    
    func sendStickerWithImageName(name: String) {
        sendMessage(nil, date: NSDate(), picture: nil, sticker : UIImage(named: name), location: nil, snapImage : nil, audio: nil)
        stickerPicker.updateStickerHistory(name)
//        stickerPicker.reloadHistory()
    }
    
    //locationSend Delegate
    func sendPickedLocation(lat: CLLocationDegrees, lon: CLLocationDegrees, screenShot: NSData) {
        sendMessage(nil, date: NSDate(), picture: nil, sticker: nil, location: CLLocation(latitude: lat, longitude: lon), snapImage : screenShot, audio: nil)
    }
    
    //quick image picker and collection view delegate
    
    func initializePhotoQuickPicker() {
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

        requestOption.resizeMode = .Fast
        requestOption.deliveryMode = .HighQualityFormat
//        UIApplication.sharedApplication().keyWindow?.addSubview(photoQuickCollectionView)
    }
    
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
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.5
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func shiftChosenFrameFromIndex(index : Int) {
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

    func closeQuickPhotoPanel() {
        if imageQuickPickerShow {
            photoQuickCollectionView.removeFromSuperview()
            moreImageButton.removeFromSuperview()
            quickSendImageButton.removeFromSuperview()
            moveDownInputBar()
            scrollToBottom()
            imageQuickPickerShow = false
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
            
        }
    }

    func showAlertView() {
        let alert = UIAlertController(title: "You can send up to 10 photos at once", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func sendImageFromQuickPicker() {
        for image in [UIImage](imageDict.values) {
            self.sendMessage(nil, date: NSDate(), picture: image, sticker : nil, location: nil, snapImage : nil, audio: nil)
        }
        for image in [UIImage](imageDict.values) {
            let cell = photoQuickCollectionView.cellForItemAtIndexPath(imageReverseDict[image]!) as! PhotoQuickPickerCollectionViewCell
            cell.chosenFrameImageView.hidden = true
        }
        selectedImage.removeAll()
        imageDict.removeAll()
        imageReverseDict.removeAll()
        imageIndexDict.removeAll()
        indexImageDict.removeAll()
    }
    
    func getMoreImage() {
        for image in [UIImage](imageDict.values) {
            let cell = photoQuickCollectionView.cellForItemAtIndexPath(imageReverseDict[image]!) as! PhotoQuickPickerCollectionViewCell
            cell.chosenFrameImageView.hidden = true
        }
        selectedImage.removeAll()
        imageDict.removeAll()
        imageReverseDict.removeAll()
        imageIndexDict.removeAll()
        indexImageDict.removeAll()
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("CustomCollectionViewController")as! CustomCollectionViewController
        vc.imageDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

