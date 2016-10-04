//
//  ChatViewController+SendLoadMessages.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase

extension ChatViewController{
    //MARK: - send message
    func sendMessage(text : String?, date: NSDate, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : NSData?, audio : NSData?) {
        
        var outgoingMessage = OutgoingMessage?()
        let shouldHaveTimeStamp = date.timeIntervalSinceDate(lastMarkerDate) > 300 && !isContinuallySending
        //if text message
        if text != nil {
            // send message
            outgoingMessage = OutgoingMessage(message: text!, senderId: currentUserId!, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "text", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            
        }
        if let pic = picture {
            // send picture message
            
            var imageData = UIImageJPEGRepresentation(pic,1)
            let factor = min( 5000000.0 / CGFloat(imageData!.length), 1.0)
            imageData = UIImageJPEGRepresentation(pic,factor)
            outgoingMessage = OutgoingMessage(message: "Picture", picture: imageData!, senderId: currentUserId!, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "picture" , index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            isContinuallySending = true
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.enableTimeStamp), userInfo: nil, repeats: false)
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
        
        //        print(outgoingMessage!.messageDictionary)
        //        print(chatRoomId)
        self.finishSendingMessage()
        
        // add this outgoing message under chatRoom with id and content
        outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary, withUser: withUser!)
    }
    
    //send image delegate function
    func sendImages() {
        sendImageFromQuickPicker()
    }
    
    func sendStickerWithImageName(name: String) {
        sendMessage(nil, date: NSDate(), picture: nil, sticker : UIImage(named: name), location: nil, snapImage : nil, audio: nil)
        stickerPicker.updateStickerHistory(name)
        //        stickerPicker.reloadHistory()
    }
    
    func sendImageFromQuickPicker() {
        for i in 0..<photoPicker.indexImageDict.count{
            self.sendMessage(nil, date: NSDate(), picture: photoPicker.indexImageDict[i], sticker : nil, location: nil, snapImage : nil, audio: nil)
        }
        cleanUpSelectedPhotos()
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
                }
                self.numberOfMessagesLoaded += 1
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
            self.scrollToBottom(true)
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
}
