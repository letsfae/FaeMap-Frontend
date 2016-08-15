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

class OutgoingMessage {
    
    private let firebase = FIRDatabase.database().reference().child("Message")
    
    let messageDictionary : NSMutableDictionary
    //text
    init(message : String, senderId : String, senderName : String, date: NSDate, status : String, type : String) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "senderId", "senderName", "date", "status", "type"])
    }
    //location
    init(message : String, latitude: NSNumber, longitude : NSNumber, snapImage : NSData, senderId : String, senderName : String, date: NSDate, status : String, type : String) {
        let snap = snapImage.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, snap, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "latitude", "longitude", "snapImage", "senderId", "senderName", "date", "status", "type"])
    }
    //picture
    init(message : String, picture : NSData, senderId : String, senderName : String, date: NSDate, status : String, type : String) {
        let pic = picture.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, pic, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "picture","senderId", "senderName", "date", "status", "type"])
    }
    
    
    // outgoing message for sticker
    init (message : String, sticker : NSData, senderId : String, senderName : String, date : NSDate, status : String, type : String) {
        let stick = sticker.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        messageDictionary = NSMutableDictionary(objects: [message, stick, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "picture","senderId", "senderName", "date", "status", "type"])
    }
    
    // outgoing message for audio
    init (message : String, audio : NSData, senderId : String, senderName : String, date : NSDate, status : String, type : String) {
        
        let voice = audio.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue : 0))
        messageDictionary = NSMutableDictionary(objects: [message, voice, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "audio","senderId", "senderName", "date", "status", "type"])
    }
    
    
    
    
    func sendMessage(chatRoomId : String, item : NSMutableDictionary) {
        
        let reference = firebase.child(chatRoomId).childByAutoId()
        
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) -> Void in
            
            if error != nil {
                print("Error, couldn't send message: \(error)")
            }
        }

        UpdateRecents(chatRoomId, lastMessage: (item["message"] as? String)!)
    }
    
}