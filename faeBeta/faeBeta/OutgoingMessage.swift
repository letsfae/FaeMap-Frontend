//
//  OutgoingMessage.swift
//  quickChat
//
//  Created by User on 6/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import AVFoundation

protocol OutgoingMessageProtocol {
    func updateChat_Id(_ newId: String)
}

// this class is used to box information of one message user sent and send them to firebase.
class OutgoingMessage {
    
    fileprivate let firebase = FIRDatabase.database().reference().child("Message")
    
    let messageDictionary : NSMutableDictionary
    
    var delegate : OutgoingMessageProtocol!
    //text
    init(message : String, senderId : String, senderName : String, date: Date, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type, index, hasTimeStamp], forKeys: ["message" as NSCopying, "senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "index" as NSCopying, "hasTimeStamp" as NSCopying])
    }
    //location
    init(message : String, latitude: NSNumber, longitude : NSNumber, snapImage : Data, senderId : String, senderName : String, date: Date, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        let snap = snapImage.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue : 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, snap, senderId, senderName, dateFormatter().string(from: date), status, type, index, hasTimeStamp], forKeys: ["message" as NSCopying, "latitude" as NSCopying, "longitude" as NSCopying, "snapImage" as NSCopying, "senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "index" as NSCopying,"hasTimeStamp" as NSCopying])
    }
    //picture
    init(message : String, picture : Data, senderId : String, senderName : String, date: Date, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        
        let pic = picture.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, pic, senderId, senderName, dateFormatter().string(from: date), status, type, index, hasTimeStamp], forKeys: ["message"as NSCopying, "picture" as NSCopying,"senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "index" as NSCopying, "hasTimeStamp" as NSCopying])
    }
    
    
    // outgoing message for sticker
    init (message : String, sticker : Data, senderId : String, senderName : String, date : Date, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        let stick = sticker.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        messageDictionary = NSMutableDictionary(objects: [message, stick, senderId, senderName, dateFormatter().string(from: date), status, type, index, hasTimeStamp], forKeys: ["message" as NSCopying, "picture" as NSCopying, "senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "index" as NSCopying, "hasTimeStamp" as NSCopying])
    }
    
    // outgoing message for audio
    init (message : String, audio : Data, senderId : String, senderName : String, date : Date, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        
        let voice = audio.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, voice, senderId, senderName, dateFormatter().string(from: date), status, type, index, hasTimeStamp], forKeys: ["message" as NSCopying, "audio" as NSCopying,"senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "index" as NSCopying, "hasTimeStamp" as NSCopying])
    }
    
    // outgoing message for video
    init (message : String, video : Data, snapImage : Data,senderId : String, senderName : String, date : Date, status : String, type : String, index : Int, hasTimeStamp: Bool, videoDuration duration: Int) {
        
        let video = video.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue : 0))
        let snap = snapImage.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, video, snap,senderId, senderName, dateFormatter().string(from: date), status, type, index, hasTimeStamp, duration], forKeys: ["message" as NSCopying, "video" as NSCopying,"snapImage" as NSCopying,"senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "index" as NSCopying, "hasTimeStamp" as NSCopying,"videoDuration" as NSCopying])
    }
    
    func sendMessage(_ chatRoomId : String, item : NSMutableDictionary, withUser user: FaeWithUser) {
        
        let reference = firebase.child(chatRoomId).childByAutoId()
        
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) -> Void in
            
            if error != nil {
                print("Error, couldn't send message: \(error)")
            }else{
                //WARNING : I changed item["type"] to "text" here to make backend work
                postToURL("chats", parameter: ["receiver_id": user.userId as AnyObject, "message": item["message"] as AnyObject, "type": "text" as AnyObject], authentication: headerAuthentication(), completion: { (statusCode, result) in
                    if(statusCode / 100 == 2){
                        if let resultDic = result as? NSDictionary{
                            self.delegate.updateChat_Id((resultDic["chat_id"] as! NSNumber).stringValue)
                        }
                    }
                })
            }
        }
        
    }
    
}
