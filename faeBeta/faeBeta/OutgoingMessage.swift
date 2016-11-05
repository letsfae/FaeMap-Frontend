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
    func updateChat_Id(newId: String)
}

// this class is used to box information of one message user sent and send them to firebase.
class OutgoingMessage {
    
    private let firebase = FIRDatabase.database().reference().child("Message")
    
    let messageDictionary : NSMutableDictionary
    
    var delegate : OutgoingMessageProtocol!
    //text
    init(message : String, senderId : String, senderName : String, date: NSDate, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().stringFromDate(date), status, type, index, hasTimeStamp], forKeys: ["message", "senderId", "senderName", "date", "status", "type", "index", "hasTimeStamp"])
    }
    //location
    init(message : String, latitude: NSNumber, longitude : NSNumber, snapImage : NSData, senderId : String, senderName : String, date: NSDate, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        let snap = snapImage.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, snap, senderId, senderName, dateFormatter().stringFromDate(date), status, type, index, hasTimeStamp], forKeys: ["message", "latitude", "longitude", "snapImage", "senderId", "senderName", "date", "status", "type", "index","hasTimeStamp"])
    }
    //picture
    init(message : String, picture : NSData, senderId : String, senderName : String, date: NSDate, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        
        let pic = picture.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, pic, senderId, senderName, dateFormatter().stringFromDate(date), status, type, index, hasTimeStamp], forKeys: ["message", "picture","senderId", "senderName", "date", "status", "type", "index", "hasTimeStamp"])
    }
    
    
    // outgoing message for sticker
    init (message : String, sticker : NSData, senderId : String, senderName : String, date : NSDate, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        let stick = sticker.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        messageDictionary = NSMutableDictionary(objects: [message, stick, senderId, senderName, dateFormatter().stringFromDate(date), status, type, index, hasTimeStamp], forKeys: ["message", "picture","senderId", "senderName", "date", "status", "type", "index", "hasTimeStamp"])
    }
    
    // outgoing message for audio
    init (message : String, audio : NSData, senderId : String, senderName : String, date : NSDate, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        
        let voice = audio.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, voice, senderId, senderName, dateFormatter().stringFromDate(date), status, type, index, hasTimeStamp], forKeys: ["message", "audio","senderId", "senderName", "date", "status", "type", "index", "hasTimeStamp"])
    }
    
    // outgoing message for video
    init (message : String, video : NSData, snapImage : NSData,senderId : String, senderName : String, date : NSDate, status : String, type : String, index : Int, hasTimeStamp: Bool) {
        
        let video = video.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue : 0))
        let snap = snapImage.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, video, snap,senderId, senderName, dateFormatter().stringFromDate(date), status, type, index, hasTimeStamp], forKeys: ["message", "video","snapImage","senderId", "senderName", "date", "status", "type", "index", "hasTimeStamp"])
    }
    
    func sendMessage(chatRoomId : String, item : NSMutableDictionary, withUser user: FaeWithUser) {
        
        let reference = firebase.child(chatRoomId).childByAutoId()
        
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) -> Void in
            
            if error != nil {
                print("Error, couldn't send message: \(error)")
            }else{
                //WARNING : I changed item["type"] to "text" here to make backend work
                postToURL("chats", parameter: ["receiver_id": user.userId, "message": item["message"] as! String, "type": "text"], authentication: headerAuthentication(), completion: { (statusCode, result) in
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
