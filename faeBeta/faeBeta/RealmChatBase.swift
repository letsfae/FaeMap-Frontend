//
//  RealmChatBase.swift
//  faeBeta
//
//  Created by User on 04/04/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import RealmSwift

class RealmWithUser: Object{
    dynamic var userName: String = ""
    dynamic var userID: String = ""
    dynamic var userAvatar: String? = nil
    override static func primaryKey() -> String? {
        return "userID"
    }
}

class RealmMessage: Object {
    dynamic var withUserID : String = ""
    dynamic var senderID : String = ""
    dynamic var senderName : String = ""
    dynamic var date = NSDate()
    dynamic var message : String = ""
    dynamic var delivered = false
    dynamic var hasTimeStamp = false
    dynamic var data : NSData? = nil
    dynamic var type : String = ""
    dynamic var status: String = ""
    dynamic var snapImage : NSData? = nil
    let longitude = RealmOptional<Float>()
    let latitude = RealmOptional<Float>()
    //dynamic var latitude : String? = nil
    
    // int cannot be optional
    let videoDuration = RealmOptional<Int>()
    dynamic var isHeartSticker : Bool = false
    override static func indexedProperties() -> [String] {
        return ["date"].reversed()
    }
    
    //        override static func primaryKey() -> String? {
    //            return "date"
    //        }
}

class RealmRecent: Object {
    dynamic var withUser: RealmWithUser?
    dynamic var date = NSDate()
    //dynamic var avatar : NSData? = nil
    dynamic var message : String = ""
    dynamic var unread = false
    
    override static func indexedProperties() -> [String] {
        return ["date"].reversed()
    }
    
    override static func primaryKey() -> String? {
        return "withUserID"
    }
}

class RealmChat {
    static func sendMessage(message : RealmMessage, completion : () -> ()){
        let realm = try! Realm()
        try! realm.write{
            realm.add(message)
            print("add message")
        }
    }
    
    static func updateRecent(recent : NSArray) {
        
    }
    
    static func receiveMessage(message : RealmMessage) {
        let realm = try! Realm()
        try! realm.write{
            realm.add(message);
        }
    }
    
    static func fetchMessageWith(userID: Int, numberOfItem: Int, offset: Int) -> [RealmMessage] {
        return []
    }
    
    static func removeRecentWith(userID: Int) {
        
    }
    
    static func cleanDatabase() {
        
    }
    
    static func printDatabase(object : Object, numerOfItem : Int, offset: Int) {
    }
    
    static func addWithUser(withUser : RealmWithUser){
        let realm  = try! Realm()
        try! realm.write{
            realm.add(withUser)
            print("add user")
        }
    }
    
}

