//
//  RealmChatBase.swift
//  faeBeta
//
//  Created by User on 04/04/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import RealmSwift

class RealmChat {
    
    class Recent: Object {
        
        dynamic var userID : Int = -1
        dynamic var date : String = ""
        dynamic var avatar : NSData? = nil
        dynamic var message : String = ""
        dynamic var unread = false
        
        override static func indexedProperties() -> [String] {
            return ["date"].reversed()
        }
        
        override static func primaryKey() -> String? {
            return "userID"
        }
    }
    
    class ChatRoom: Object {
        
        dynamic var senderID : Int = -1
        dynamic var date : String = ""
        dynamic var message : String = ""
        dynamic var delivered = false
        dynamic var hasTimeStamp = false
        dynamic var data : NSData? = nil
        dynamic var snapImage : NSData? = nil
        dynamic var longitude : String? = ""
        dynamic var latitude : String? = nil
        
        // int cannot be optional
        dynamic var videoDuration : String? = nil
        
        dynamic var isHeartSticker : Bool = false
        
        override static func indexedProperties() -> [String] {
            return ["date"].reversed()
        }
        
        override static func primaryKey() -> String? {
            return "date"
        }
        
    }
    
    func sendMessage(message : ChatRoom, completion : () -> ()) {
        
    }
    
    func updateRecent(recent : Recent) {
        
    }
    
    func receiveMessage(messsage : ChatRoom) {
        
    }
    
    func fetchMessageWith(userID: Int, numberOfItem: Int, offset: Int) -> [ChatRoom] {
        return []
    }
    
    func removeRecentWith(userID: Int) {
        
    }
    
    func cleanDatabase() {
        
    }
    
    func printDatabase(object : Object, numerOfItem : Int, offset: Int) {
        
    }
    
}

