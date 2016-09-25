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

// this class is used to box information of one message user sent and send them to firebase.
class OutgoingMessage {
    
    private let firebase = FIRDatabase.database().reference().child("Message")
    
    let messageDictionary : NSMutableDictionary
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
    
    
    
    
    func sendMessage(chatRoomId : String, item : NSMutableDictionary, receiverDeviceToken: String) {
        
        let reference = firebase.child(chatRoomId).childByAutoId()
        
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) -> Void in
            
            if error != nil {
                print("Error, couldn't send message: \(error)")
            }else{
                let messageText:String = (item["senderName"] as! String) + ": " + (item["message"] as! String)
                self.publishMessageAsPushNotificationAsync(messageText, deviceId: receiverDeviceToken )
            }
        }
        
        UpdateRecents(chatRoomId, lastMessage: (item["message"] as? String)!)
    }
    
    func publishMessageAsPushNotificationAsync(message: String, deviceId: String) {
        
        let deliveryOptions = DeliveryOptions()
        deliveryOptions.pushSinglecast = [deviceId]
        
        let publishOptions = PublishOptions()
        publishOptions.assignHeaders(["ios-text":message,
            "ios-badge":"5",
            "ios-sound":"\(AudioServicesPlaySystemSound (1104))"])
        backendless.messaging.publish("default",
                                      message: message,
                                      publishOptions:publishOptions,
                                      deliveryOptions:deliveryOptions,
                                      response:{ ( messageStatus : MessageStatus!) -> () in
                                        print("MessageStatus = \(messageStatus.status) ['\(messageStatus.messageId)']")
            },
                                      error: { ( fault : Fault!) -> () in
                                        print("Server reported an error: \(fault)")
            }
        )
    }
    
}
