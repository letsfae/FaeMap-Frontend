//
//  RealmChatBase.swift
//  faeBeta
//
//  Created by User on 04/04/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import RealmSwift


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
    dynamic var withUserID : String = ""
    dynamic var withUserNickName : String = ""
    dynamic var date = NSDate()
    //dynamic var avatar : NSData? = nil
    dynamic var message : String = ""
    dynamic var unread : Int = 0
    
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
    
    static func updateRecent(recents : NSArray) {
        let realm = try! Realm()
        for message in recents{
            let recent = RealmRecent()
            //print(type(of: (message as! NSDictionary)["with_user_id"]!))
            recent.withUserID =  String((message as! NSDictionary)["with_user_id"]! as! Int)
            recent.withUserNickName = (message as! NSDictionary)["with_nick_name"]! as? String ?? (message as! NSDictionary)["with_user_name"]! as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let date = dateFormatter.date(from: (message as! NSDictionary)["last_message_timestamp"]! as! String)
            recent.date = date! as NSDate
            recent.message = (message as! NSDictionary)["last_message"]! as! String
            recent.unread = (message as! NSDictionary)["unread_count"]! as! Int
            try! realm.write{
                realm.add(recent, update: true)
                print("update recent")
            }
        }
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
    
    static func addWithUser(withUser : RealmUser){
        let realm  = try! Realm()
        try! realm.write{
            realm.add(withUser)
            print("add user")
        }
    }
    
}

