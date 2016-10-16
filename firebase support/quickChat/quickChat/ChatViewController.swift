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

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let appDeleget = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let ref = firebase.database.reference().child("Message")
    
    
    var messages : [JSQMessage] = []
    var objects : [NSDictionary] = []
    var loaded : [NSDictionary] = []
    
    var avatarImageDictionary : NSMutableDictionary?
    var avatarDictionary : NSMutableDictionary?
    
    var showAvatar : Bool = true
    var firstLoad : Bool?
    
    var withUser : BackendlessUser?
    var recent : NSDictionary?
    
    var chatRoomId : String!
    
    var initialLoadComplete : Bool = false
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewWillDisappear(animated: Bool) {
        //update recent
        clearRecentCounter(chatRoomId)
        ref.removeAllObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
         self.collectionView.collectionViewLayout.springinessEnabled = false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = backendless.userService.currentUser.objectId
        self.senderDisplayName = backendless.userService.currentUser.name
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        if withUser == nil {
//        if withUser?.objectId == nil {
            getWithUserFromRecent(recent!, result: { (withUser) in
                print(withUser.name)
                self.withUser = withUser
                self.title = withUser.name
                self.getAvatar()
            })
        } else {
            self.title = withUser!.name
            self.getAvatar()
        }
        
        //load firebase messages
        loadMessage()
        
        self.inputToolbar.contentView.textView.placeHolder = "New Message"
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        //check user default
        
        loadUserDefault()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK : JSQMessages dataSource functions
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == backendless.userService.currentUser.objectId {
//            cell.textView.textColor = UIColor.greenColor()
        } else {
//            cell.textView.textColor = UIColor.blackColor()
        }
        
        return cell
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]

    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == backendless.userService.currentUser.objectId {
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

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
        let status = message["status"] as! String
        
        if indexPath.row == messages.count - 1 {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
        
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if outgoing(objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
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
            sendMessage(text, date: date, picture: nil, location: nil)
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("accessory button pressed")
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (aler : UIAlertAction!) in
            print("Take photo")
            camera.presentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (aler : UIAlertAction) in
            print("photo library")
            camera.PresentPhotoLibrary(self, canEdit: true)
            
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .Default) { (aler : UIAlertAction) in
            print("Share location")
            if self.haveAccessToLocation() {
                self.sendMessage(nil, date: NSDate(), picture: nil, location: "location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .Cancel) { (aler : UIAlertAction) in
            print("Cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    //MARK: send message
    
    func sendMessage(text : String?, date: NSDate, picture : UIImage?, location : String?) {
        
        var outgoingMessage = OutgoingMessage?()
        
        //if text message
        if let text = text {
            // send message
            outgoingMessage = OutgoingMessage(message: text, senderId: backendless.userService.currentUser.objectId!, senderName: backendless.userService.currentUser.name!, date: date, status: "Delivered", type: "text")
            
        }
        if let pic = picture {
            // send picture message
            let imageData = UIImageJPEGRepresentation(pic, 1.0)
            
            outgoingMessage = OutgoingMessage(message: "Picture", picture: imageData!, senderId: backendless.userService.currentUser.objectId!, senderName: backendless.userService.currentUser.name!, date: date, status: "Delivered", type: "picture")
        }
        if let loc = location {
            // sned location message
            let lat : NSNumber = NSNumber(double: (appDeleget.coordinate?.latitude)!)
            let lon : NSNumber = NSNumber(double: (appDeleget.coordinate?.longitude)!)
            
            outgoingMessage = OutgoingMessage(message: "Location", latitude: lat, longitude: lon, senderId: backendless.userService.currentUser.objectId!, senderName: backendless.userService.currentUser.name!, date: date, status: "Delivered", type: "location")
            
            let location = CLLocation(latitude: (appDeleget.coordinate?.latitude)!, longitude: (appDeleget.coordinate?.longitude)!)
            
            let locationMediaItem = JSQLocationMediaItem(location: nil)
            
            locationMediaItem.setLocation(location, withCompletionHandler: {
                () -> Void in
                self.collectionView!.reloadData()
            })
        }
        
        //play message sent sound
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        self.finishSendingMessage()
        
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
            print("run")
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
        if backendless.userService.currentUser.objectId == item["senderId"] as! String {
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item : NSDictionary) -> Bool {
        if backendless.userService.currentUser.objectId == item["senderId"] as! String {
            return true
        } else {
            return false
        }
        
    }
    
    //MARK: Helper functions
    
    func haveAccessToLocation() -> Bool {
        if let _ = appDeleget.coordinate?.latitude {
            return true
        } else {
            return false
        }
    }
    
    func getAvatar() {
        if showAvatar {
            
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30, 30)
            
            //download avatars
            avatarImageFromBackendlessUser(backendless.userService.currentUser)
            avatarImageFromBackendlessUser(withUser!)
            
            //create avatars
            
            createAvatars(avatarImageDictionary)
        }
    }
    
    func getWithUserFromRecent(recent : NSDictionary, result : (withUser : BackendlessUser) -> Void ) {
        
        let withUserId = recent["withUserUserId"] as? String
        
        let whereClause = "objectId = '\(withUserId!)'"
        
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(Backendless.ofClass())
        dataStore.find(dataQuery, response: { (users : BackendlessCollection!) in
            
            let withUser = users.data.first as! BackendlessUser
            
            result(withUser: withUser)
            
            }) { (fault) in
                print("Server report an error : \(fault)")
        }
        
    }
    
    func createAvatars(avatars : NSMutableDictionary?) {
        var currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
        var withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        if let avat = avatars {
            
            if let currentUserAvatarImage = avat.objectForKey(backendless.userService.currentUser.objectId) {
                currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: currentUserAvatarImage as! NSData), diameter: 70)
                self.collectionView.reloadData()
            }
            
            
        }
        
        if let avat = avatars {
            
            if let withUserAvatarImage = avat.objectForKey(withUser!.objectId!) {
                withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: withUserAvatarImage as! NSData), diameter: 70)
                self.collectionView.reloadData()
            }
            
        }
        
        avatarDictionary = [backendless.userService.currentUser.objectId : currentUserAvatar, withUser!.objectId! : withUserAvatar]
    }
    
    func avatarImageFromBackendlessUser(user : BackendlessUser) {
        
        if let imageLink = user.getProperty("Avatar") {
            
            getImageFromURL(imageLink as! String, result: { (image) in
                
                let imageData = UIImageJPEGRepresentation(image!, 1.0)
                
                if self.avatarImageDictionary != nil {
                    
                    self.avatarImageDictionary!.removeObjectForKey(user.objectId)
                    self.avatarImageDictionary!.setObject(imageData!, forKey: user.objectId!)
                } else {
                    self.avatarImageDictionary = [user.objectId! : imageData!]
                }
                self.createAvatars(self.avatarImageDictionary)
            })
            
        }
        
    }
    
    //MARK : JSQDelegate functions
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let object = objects[indexPath.row]
        
        if (object["type"] as! String == "picture") {
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
        }
        
        if object["type"] as! String == "location" {
            
            self.performSegueWithIdentifier("chatToMapSeg", sender: indexPath)
            
        }
        
    }
    
    //MARK : UIImagePickerController
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, location: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK : Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatToMapSeg" {
            let indexPath = sender as! NSIndexPath
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let mapView = segue.destinationViewController as! MapViewController
            
            mapView.location = mediaItem.location
            
            
        }
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

}
