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
    func sendMessage(text : String? = nil, picture : UIImage? = nil, sticker : UIImage? = nil, isHeartSticker: Bool? = false, location : CLLocation? = nil, audio : Data? = nil, video : Data? = nil, videoDuration: Int = 0, snapImage : Data? = nil, date: Date) {
        
        var outgoingMessage: OutgoingMessage? = nil
        let shouldHaveTimeStamp = date.timeIntervalSince(lastMarkerDate as Date) > 300 && !isContinuallySending
        //if text message
        if let text = text {
            // send message
            outgoingMessage = OutgoingMessage(message: text, senderId: user_id.stringValue , senderName: username! , date: date, status: "Delivered", type: "text", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            
        }
        else if let pic = picture {
            // send picture message
            
            if let imageData = compressImageToData(pic){
                outgoingMessage = OutgoingMessage(message: "[Picture]", picture: imageData, senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "picture" , index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
                isContinuallySending = true
                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.enableTimeStamp), userInfo: nil, repeats: false)
            }
        }
        
        else if let sti = sticker {
            // send sticker
            let imageData = UIImagePNGRepresentation(sti)
            outgoingMessage = OutgoingMessage(message: "[Sticker]", sticker: imageData!, isHeartSticker: isHeartSticker! , senderId: user_id.stringValue, senderName:username!, date: date, status: "Delivered", type: "sticker", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        
        else if let loc = location {
            // send location message
            let lat : NSNumber = NSNumber(value: loc.coordinate.latitude as Double)
            let lon : NSNumber = NSNumber(value: loc.coordinate.longitude as Double)
            
            outgoingMessage = OutgoingMessage(message: "[Location]", latitude: lat, longitude: lon, snapImage: snapImage!, senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "location", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        else if let audio = audio {
            //create outgoing-message object
            outgoingMessage = OutgoingMessage(message: "[Voice]", audio: audio, senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "audio", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        else if let video = video {
            outgoingMessage = OutgoingMessage(message: "[Video]", video: video,snapImage: snapImage! ,senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "video", index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp, videoDuration: videoDuration)
        }
        else if let snapImage = snapImage{
            outgoingMessage = OutgoingMessage(message: "[GIF]", picture: snapImage, senderId: user_id.stringValue, senderName: username!, date: date, status: "Delivered", type: "gif" , index: totalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
        }
        
        //play message sent sound
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        self.finishSendingMessage(animated: true, cleanTextView: text != nil)
        
        outgoingMessage!.delegate = self
        
        // add this outgoing message under chatRoom with id and content
        outgoingMessage!.sendMessage(chatRoomId, withUser: withUser!)
    }
    
    //send image delegate function
    func sendImages(_ images:[UIImage]) {
        for i in 0 ..< images.count {
            sendMessage(picture: images[i], date: Date())
        }
        self.toolbarContentView.cleanUpSelectedPhotos()
    }
    
    func sendStickerWithImageName(_ name: String) {
        sendMessage(sticker : UIImage(named: name), date: Date())
    }
    
    func sendAudioData(_ data: Data) {
        sendMessage(audio: data,date: Date())
    }
    
    func sendGifData(_ data: Data){
        sendMessage(snapImage : data, date: Date())
    }
    
    //MARK: - Load Message
    // this function open observer on firebase, update datesource of JSQMessage when any change happen on firebase
    func loadMessages(){
        roomRef = ref.child(chatRoomId)
        roomRef?.queryLimited(toLast: UInt(numberOfMessagesOneTime)).observe(.childAdded) { (snapshot : FIRDataSnapshot) in
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
        
        roomRef?.child(chatRoomId).observeSingleEvent(of: .value) { (snapshot : FIRDataSnapshot) in
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
    
    /// append message to then end
    ///
    /// - Parameter item: the message information
    /// - Returns: true: the message is incoming message false: it's outgoing
    func insertMessage(_ item : NSDictionary) -> Bool {
        //unpack the message from data load to the JSQmessage
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        if(item["hasTimeStamp"] != nil && item["hasTimeStamp"] as! Bool){
            let date = dateFormatter().date(from: (item["date"] as? String)!)
            lastMarkerDate = date
        }
        if let message = message{
            
            objects.append(item)
            messages.append(message)
            
            return incoming(item)
        }
        return false
    }
    
    
    /// insert the message into the whole messages
    ///
    /// - Parameters:
    ///   - item: the message information
    ///   - index: the place to insert the message
    /// - Returns: true: the message is incoming message false: it's outgoing
    func insertMessage(_ item : NSDictionary, atIndex index: Int) -> Bool {
        //unpack the message from data load to the JSQmessage
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        objects.insert(item, at: index)
        messages.insert(message!, at: index)
        
        return incoming(item)
    }
    
    
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
        sendMessage(location: CLLocation(latitude: lat, longitude: lon), snapImage : screenShot, date: Date())
    }
    
    func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int){
        var imageData = UIImageJPEGRepresentation(snapImage,1)
        let factor = min( 5000000.0 / CGFloat(imageData!.count), 1.0)
        imageData = UIImageJPEGRepresentation(snapImage,factor)
        sendMessage(video: video, videoDuration: duration, snapImage : imageData, date: Date())
        self.toolbarContentView.cleanUpSelectedPhotos()
    }
    
    //MARK: - outgoingmessage delegate
    func updateChat_Id(_ newId: String) {
        chat_id = newId
    }
    
    
}
