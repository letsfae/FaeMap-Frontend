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

extension ChatViewController: OutgoingMessageProtocol{
    
    //MARK: - send message
    func sendMessage(_ text : String?, date: Date, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : Data?, audio : Data?, video : Data?, videoDuration: Int) {
        
        var outgoingMessage: OutgoingMessage? = nil
        let shouldHaveTimeStamp = date.timeIntervalSince(lastMarkerDate as Date) > 300 && !isContinuallySending
        //if text message
        if let text = text {
            // send message
            outgoingMessage = OutgoingMessage(message: text, senderId: user_id.stringValue , senderName: username! , date: date, status: "Delivered", type: "text", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            
        }
        if let pic = picture {
            // send picture message
            
            if let imageData = compressImageToData(pic){
                outgoingMessage = OutgoingMessage(message: "[Picture]", picture: imageData, senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "picture" , index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
                isContinuallySending = true
                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.enableTimeStamp), userInfo: nil, repeats: false)
            }
        }
        
        if let sti = sticker {
            // send sticker
            let imageData = UIImagePNGRepresentation(sti)
            outgoingMessage = OutgoingMessage(message: "[Sticker]", picture: imageData!, senderId: user_id.stringValue, senderName:username!, date: date, status: "Delivered", type: "sticker", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        
        if let loc = location {
            // send location message
            let lat : NSNumber = NSNumber(value: loc.coordinate.latitude as Double)
            let lon : NSNumber = NSNumber(value: loc.coordinate.longitude as Double)
            
            outgoingMessage = OutgoingMessage(message: "[Location]", latitude: lat, longitude: lon, snapImage: snapImage!, senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "location", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        if let audio = audio {
            //create outgoing-message object
            outgoingMessage = OutgoingMessage(message: "[Voice]", audio: audio, senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "audio", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        if let video = video {
            outgoingMessage = OutgoingMessage(message: "[Video]", video: video,snapImage: snapImage! ,senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "video", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp, videoDuration: videoDuration)
        }
        
        //play message sent sound
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        self.finishSendingMessage()
        
        outgoingMessage!.delegate = self
        
        // add this outgoing message under chatRoom with id and content
        outgoingMessage!.sendMessage(chatRoomId, withUser: withUser!)
    }
    
    //send image delegate function
    func sendImages(_ images:[UIImage]) {
        for i in 0 ..< images.count {
            sendMessage(nil, date: Date(), picture: images[i], sticker : nil, location: nil, snapImage : nil, audio: nil, video: nil, videoDuration: 0)
        }
        self.toolbarContentView.cleanUpSelectedPhotos()
    }
    
    func sendStickerWithImageName(_ name: String) {
        sendMessage(nil, date: Date(), picture: nil, sticker : UIImage(named: name), location: nil, snapImage : nil, audio: nil, video: nil, videoDuration: 0)
    }
    
    func sendAudioData(_ data: Data) {
        sendMessage(nil, date: Date(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: data, video: nil, videoDuration: 0)
    }
    
    //MARK: Load Message
    // this function open observer on firebase, update datesource of JSQMessage when any change happen on firebase
    func loadMessage() {
        
        ref.child(chatRoomId).queryLimited(toLast: UInt(numberOfMessagesOneTime)).observe(.childAdded) { (snapshot : FIRDataSnapshot) in
            if snapshot.exists() {
                // becasue the type is ChildAdded so the snapshot is the new message
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialLoadComplete {//message has been downloaded from databse but not load to collectionview yet.
                    
                    let isIncoming = self.insertMessage(item)
                    
                    if isIncoming {
                        
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishReceivingMessage(animated: true)
                    
                    
                }
                else {
                    // add each dictionary to loaded array
                    self.loaded.append(item)
                }
                self.numberOfMessagesLoaded += 1
            }
        }
        
        // for futher usage. may allow the user to drawback or modify message
//        ref.child(chatRoomId).observe(.childChanged) { (snapshot : FIRDataSnapshot) in
//            
//        }
//        
//        ref.child(chatRoomId).observe(.childRemoved) { (snapshot : FIRDataSnapshot) in
//            
//        }
        
        ref.child(chatRoomId).observeSingleEvent(of: .value) { (snapshot : FIRDataSnapshot) in
            //this function will run only once
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
            self.scrollToBottom(true)
        }
        
    }
    
    func loadPreviousMessages(){
        self.isLoadingPreviousMessages = true
        if(totalNumberOfMessages > numberOfMessagesLoaded){
            ref.child(chatRoomId).queryOrdered(byChild: "index").queryStarting(atValue: max(totalNumberOfMessages - numberOfMessagesLoaded - numberOfMessagesOneTime + 1,1)).queryEnding(atValue: totalNumberOfMessages - numberOfMessagesLoaded).observeSingleEvent(of: .value) { (snapshot : FIRDataSnapshot) in
                if snapshot.exists() {
                    let result = (snapshot.value! as AnyObject).allValues as! [NSDictionary]
                    for item in result.sorted(by: { ($0["index"] as! Int) > ($1["index"] as! Int)}) {
                        _ = self.insertMessage(item,atIndex: 0)
                        self.numberOfMessagesLoaded += 1
                        
                    }
                    let oldOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
                    self.collectionView.reloadData()
                    self.collectionView.layoutIfNeeded()
                    self.collectionView.contentOffset = CGPoint(x: 0.0, y: self.collectionView.contentSize.height - oldOffset);
                    
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
            _ = insertMessage(item)
        }
    }
    
    func insertMessage(_ item : NSDictionary) -> Bool {
        //unpack the message from data load to the JSQmessage
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        if(item["hasTimeStamp"] as! Bool){
            let date = dateFormatter().date(from: (item["date"] as? String)!)
            lastMarkerDate = date
        }
        objects.append(item)
        messages.append(message!)
        
        return incoming(item)
    }
    
    func insertMessage(_ item : NSDictionary, atIndex index: Int) -> Bool {
        //unpack the message from data load to the JSQmessage
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        objects.insert(item, at: index)
        messages.insert(message!, at: index)
        
        return incoming(item)
    }
    
    //MARK: utilities
    private func incoming(_ item : NSDictionary) -> Bool {
        if user_id.stringValue == item["senderId"] as! String {
            return false
        } else {
            return true
        }
    }
    
    private func outgoing(_ item : NSDictionary) -> Bool {
        if user_id.stringValue == item["senderId"] as! String {
            return true
        } else {
            return false
        }
        
    }
    
    
    /// This method will transfer an UIImage into NSData, and limit the size of the data
    ///
    /// - Parameter image: the image you want to compress
    /// - Returns: a data for the image
    private func compressImageToData(_ image: UIImage) -> Data?
    {
        var imageData = UIImageJPEGRepresentation(image,1)
        let factor = min( 5000000.0 / CGFloat(imageData!.count), 1.0)
        imageData = UIImageJPEGRepresentation(image,factor)
        return imageData
    }
    
    //MARK: - locationSend Delegate
    func sendPickedLocation(_ lat: CLLocationDegrees, lon: CLLocationDegrees, screenShot: Data) {
        sendMessage(nil, date: Date(), picture: nil, sticker: nil, location: CLLocation(latitude: lat, longitude: lon), snapImage : screenShot, audio: nil, video: nil, videoDuration: 0)
    }
    
    func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int){
        var imageData = UIImageJPEGRepresentation(snapImage,1)
        let factor = min( 5000000.0 / CGFloat(imageData!.count), 1.0)
        imageData = UIImageJPEGRepresentation(snapImage,factor)
        sendMessage(nil, date: Date(), picture: nil, sticker : nil, location: nil, snapImage : imageData, audio: nil, video: video, videoDuration: duration)
        self.toolbarContentView.cleanUpSelectedPhotos()
    }
    
    //MARK: - outgoingmessage delegate
    func updateChat_Id(_ newId: String) {
        chat_id = newId
    }
    
    
}
