//
//  DetailedChatViewController.swift
//  iPark
//
//  Created by blesssecret on 9/13/15.
//  Copyright (c) 2015 carryof. All rights reserved.
//

import UIKit
//in this view we only need targetUserID which is objectID

class DetailedChatViewController:  JSQMessagesViewController {
    
    var user: FAuthData?
    
    var messages = [Message]()
    //    var avatars = Dictionary<String, UIImage>()
    var avatars = Dictionary<String, UIImageView>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var senderImageUrl: String!
    var batchMessages = true
    var ref: Firebase!
    
    var chatURL = ""
    var chatID = ""
    var targetUserID = ""
    
    let firebaseURLPrefix = "https://parku.firebaseio.com/chat/"
    let defaultImageURL = "http://www.5525.org/Upload/doc/20150318/3bb54498f22e4359bc5b040bd6975e9c.jpg"
    
//    var profileImageUrl: String? = PFUser.currentUser()!["faceURL"] as? String
    var profileImageUrl: String? = PFUser.currentUser()?.objectForKey("faceURL") as? String

//    var currentUsername: String? = currentUser["nickname"] as? String
    var currentUsername: String? = PFUser.currentUser()?.objectForKey("nickname")as? String
    
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef: Firebase!
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        messagesRef = Firebase(url: chatURL)
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 60 messages)
        messagesRef.queryLimitedToLast(60).observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            let text = snapshot.value["message"] as? String
            let sender = snapshot.value["author"] as? String
            let imageUrl = snapshot.value["authorImg"] as? String
            let authorId = snapshot.value["authorId"] as? String
            let userToId = snapshot.value["userToId"] as? String
            let createdAt = snapshot.value["createdAt"] as? String
            
//            let message = Message(text: text, sender: sender, imageUrl: imageUrl)
            let message = Message(authorId: authorId, userToId: userToId, text: text, createdAt: createdAt, sender: sender, imageUrl: imageUrl)
            self.messages.append(message)
            self.finishReceivingMessage()
        })
    }
    
    func sendMessage(text: String!, sender: String!) {
        // *** STEP 3: ADD A MESSAGE TO FIREBASE
        let authorId = PFUser.currentUser()!.objectId
        let createdAt = NSDate().timeIntervalSince1970 * 1000
//        println(Int(createdAt))
        let createdStr = String(stringInterpolationSegment: Int64(createdAt))
//        let createdInt = Int64(createdAt)
        messagesRef.childByAutoId().setValue([
            "authorId":authorId,
            "userToId":self.targetUserID,
            "createdAt":createdStr,
            "message":text,
            "author":sender,
            "authorImg":self.profileImageUrl
            
            ])
        /*messagesRef.childByAutoId().setValue([
            "authorId":PFUser.currentUser()?.objectId,
            "userToId":self.targetUserID,
            "createdAt":NSDate(),
            "text":text,
            "sender": sender,
            "imageUrl": self.profileImageUrl
            ])*/
        
        println("\(sender)")
        
        let ParseCloudRequest : [NSObject : String!] = [
            "authorName"        :       sender,
            "authorId"          :       PFUser.currentUser()?.objectId,
            "authorMessage"     :       text,
            "authorImg"         :       self.profileImageUrl,
            "userToId"          :       targetUserID,
        ]
        
        PFCloud.callFunctionInBackground("saveChatNotification", withParameters: ParseCloudRequest) { (response: AnyObject?, error: NSError?) -> Void in
            let responseString = response as? String
        }
    }
    
    func tempSendMessage(text: String!, sender: String!) {
//        let message = Message(text: text, sender: sender, imageUrl: senderImageUrl)
        
        let createdAt = NSDate().timeIntervalSince1970 * 1000
        //        println(Int(createdAt))
        let createdStr = String(stringInterpolationSegment: Int64(createdAt))
//        let createdInt = Int64(createdAt)
        let message = Message(authorId: PFUser.currentUser()?.objectId, userToId: targetUserID, text: text, createdAt: createdStr, sender: sender, imageUrl: senderImageUrl)
        messages.append(message)
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        /*if let stringUrl = imageUrl {
        if let url = NSURL(string: stringUrl) {
        if let data = NSData(contentsOfURL: url) {
        let image = UIImage(data: data)
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
        avatars[name] = avatarImage
        println("avatars: \(self.avatars)")
        return
        }
        }
        }*/
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        let income = UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width)//34
        let outgo = UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)//34
        let holderImage = setupAvatarColor(name, incoming: incoming)
        //        let imageView = UIImageView(image:holderImage)
        //        self.avatars[name]=imageView
        //        println(avatars)
        if self.avatars[name] != nil {
            return
        }
        if let stringUrl = imageUrl {
            if let url = NSURL(string:stringUrl) {
                var imageNow = UIImageView()
                
                //                imageNow.sd_setImageWithURL(url, placeholderImage: UIImage(named: "loading"))
                imageNow.sd_setImageWithURL(url, placeholderImage: holderImage, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, url:NSURL!) -> Void in
                    if error == nil {
                        //                    imageNow.image = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
                        //                    self.avatars[name]!.image = avatarImage
                        //                    self.collectionView.reloadData()
                    }
                })
                avatars[name]=imageNow
                
            }
        }
        
        /*
        if let stringUrl = imageUrl{
        if let url = NSURL(string: stringUrl) {
        var error : NSError?
        var request : NSURLRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 5.0)
        NSOperationQueue.mainQueue().cancelAllOperations()
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response:NSURLResponse!, imageData:NSData!, error:NSError!) -> Void in
        if imageData != nil {
        let image = UIImage(data: imageData)
        let diameter = incoming ? UInt(self.collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
        self.avatars[name] = avatarImage
        
        return
        }
        })
        }
        }*/
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        
        //        setupAvatarColor(name, incoming: incoming)
        
    }
    
    func setupAvatarColor(name: String, incoming: Bool) -> UIImage{
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = count(name)
        let initials : String? = name.substringToIndex(advance(sender.startIndex, min(3, nameLength)))
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        //        avatars[name] = userImage
        return userImage
    }
    func loadData(){
        var arrayId = [PFUser.currentUser()?.objectId,targetUserID]
//        arrayId.sort{ $0!.lowercaseString < $1!.lowercaseString }
        arrayId.sort(<)
        chatID = arrayId[0]! + "_" + arrayId[1]!
        
        chatURL = firebaseURLPrefix + chatID
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        
        automaticallyScrollsToMostRecentMessage = true
        navigationController?.navigationBar.topItem?.title = "back"
        
        let currentInstallation : PFInstallation = PFInstallation.currentInstallation()
//        currentInstallation["user"]=PFUser.currentUser()?.objectId
        if let userCurrent=PFUser.currentUser() as PFUser!
        {
            currentInstallation.setObject(userCurrent.objectId!, forKey: "user")
        }
        
        currentInstallation.saveInBackground()
//        if let senderName = PFUser.currentUser()?.objectForKey("nickName") {
//            sender = senderName as! String
//        }
        sender = (self.currentUsername != nil) ? self.currentUsername : "Anonymous"
        
        println(sender)
        if let urlString = self.profileImageUrl {
            if urlString == "" {
                setupAvatarImage(sender, imageUrl: defaultImageURL, incoming: false)
                senderImageUrl = defaultImageURL as String
                self.profileImageUrl = defaultImageURL as String
            }
            else {
                setupAvatarImage(sender, imageUrl: urlString, incoming: false)
                senderImageUrl = self.profileImageUrl
            }
        } else {
            setupAvatarImage(sender, imageUrl: defaultImageURL, incoming: false)
            senderImageUrl = defaultImageURL as String
            self.profileImageUrl = defaultImageURL as String
        }
        setupFirebase()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if ref != nil {
            ref.unauth()
        }
    }
    
    // ACTIONS
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text, sender: sender)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        println("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        
        if message.sender() == sender {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    /*override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
    let message = messages[indexPath.item]
    println(message.sender())
    if let avatar = avatars[message.sender()] {
    //            return UIImageView(image: avatar)
    //            return UIImageView(image: avatar.image)
    return avatars[message.sender()]
    } else {
    setupAvatarImage(message.sender(), imageUrl: message.imageUrl(), incoming: true)
    //            return UIImageView(image:avatars[message.sender()])
    return avatars[message.sender()]
    }
    }*/
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        let holderImage = setupAvatarColor(message.sender(), incoming: true)
        var imageNow = UIImageView(image: holderImage)
        /*if let strUrl = message.imageUrl() {
        let url = NSURL(string:strUrl)
        imageView.sd_setImageWithURL(url, placeholderImage: holderImage)
        }*/
        return imageNow
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.sender() == sender {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let imageHolder = setupAvatarColor( message.sender(), incoming: true)
        if let strUrl = message.imageUrl(){
            let url = NSURL(string: strUrl)
            cell.avatarImageView.sd_setImageWithURL(url, placeholderImage: imageHolder)
        }
        else {
            cell.avatarImageView = UIImageView(image: imageHolder)
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.sender() == sender {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.sender())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.sender() == sender {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}
