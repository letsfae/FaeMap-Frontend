//
//  RealmChatBase.swift
//  faeBeta
//
//  Created by User on 04/04/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMessage_v2: Object {
    @objc dynamic var primary_key: String = "" // login_user_id, is_group, chat_id, index
    @objc dynamic var login_user_id: String = ""
    @objc dynamic var is_group: Int = 0
    @objc dynamic var chat_id: String = "" // for private chat, chat_id is the id of the other user
                                     // for group chat, chat_id is the id of the group chatroom
    @objc dynamic var index: Int = -1
    @objc dynamic var sender: RealmUser? = nil
    let members = List<RealmUser>()
    @objc dynamic var created_at: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var media: NSData? = nil
    @objc dynamic var upload_to_server: Bool = false
    @objc dynamic var delivered_to_user: Bool = false
    @objc dynamic var unread_count: Int = 0
    
    override static func primaryKey() -> String? {
        return "primary_key"
    }
    
    func setPrimaryKeyInfo(_ login_user_id: String, _ is_group: Int, _ chat_id: String, _ index: Int) {
        self.login_user_id = login_user_id
        self.is_group = is_group
        self.chat_id = chat_id
        self.index = index
        self.primary_key = "\(login_user_id)_\(is_group)_\(chat_id)_\(index)"
    }
}

class RealmRecent_v2: Object {
    @objc dynamic var primary_key: String = "" //loginUserID_chatID
    @objc dynamic var login_user_id: String = ""
    @objc dynamic var is_group: Int = 0
    @objc dynamic var chat_id: String = ""
    @objc dynamic var chat_name: String = ""
    //dynamic var latest_message: String = ""
    @objc dynamic var created_at: String = ""
    @objc dynamic var unread_count: Int = 0
    
    var latest_message: RealmMessage_v2? {
        return realm?.objects(RealmMessage_v2.self).filter("login_user_id == %@ AND is_group == %@ AND chat_id == %@", String(Key.shared.user_id), is_group, self.chat_id).sorted(byKeyPath: "index").last
    }
    
    override static func primaryKey() -> String? {
        return "primary_key"
    }
    
    func setPrimaryKeyInfo(_ login_user_id: String, _ is_group: Int, _ chat_id: String) {
        self.login_user_id = login_user_id
        self.is_group = is_group
        self.chat_id = chat_id
        self.primary_key = "\(login_user_id)_\(is_group)_\(chat_id)"
    }
}

extension Object {
    func toDictionary() -> NSMutableDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [NSMutableDictionary]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index]
                    let obj = unsafeBitCast(object, to: Object.self)
                    objects.append(obj.toDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
        return mutabledic
    }
}

extension Realm {
    func filterAllMessages(_ is_group: Int, _ chat_id: String) -> Results<RealmMessage_v2> {
        return self.objects(RealmMessage_v2.self).filter("login_user_id == %@ AND is_group == %@ AND chat_id == %@", "\(Key.shared.user_id)", is_group, chat_id).sorted(byKeyPath: "index")
    }
    
    func filterMessage(_ primary_key: String) -> RealmMessage_v2? {
        return self.objects(RealmMessage_v2.self).filter("login_user_id == %@ AND primary_key == %@", "\(Key.shared.user_id)", primary_key).first
    }
    
    func filterUser(id: String) -> RealmUser? {
        return self.objects(RealmUser.self).filter("login_user_id == %@ AND id == %@", "\(Key.shared.user_id)", id).first
    }
    
    func filterFriends() -> Results<RealmUser> {
        return self.objects(RealmUser.self).filter("login_user_id == %@ AND relation != %@", "\(Key.shared.user_id)", NO_RELATION).sorted(byKeyPath: "display_name")
    }
}

class RealmMessage: Object {
    //messageID's format: senderID_date
    @objc dynamic var messageID : String = ""
    @objc dynamic var withUserID : String = ""
    @objc dynamic var senderID : String = ""
    @objc dynamic var senderName : String = ""
    @objc dynamic var date : String = ""
    @objc dynamic var message : String = ""
    @objc dynamic var delivered = false
    @objc dynamic var hasTimeStamp = false
    @objc dynamic var data : NSData? = nil
    @objc dynamic var type : String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var snapImage : NSData? = nil
    var longitude = RealmOptional<Double>()
    var latitude = RealmOptional<Double>()
    @objc dynamic var place: String? = ""
    //dynamic var latitude : String? = nil
    
    // int cannot be optional
    var videoDuration = RealmOptional<Int>()
    @objc dynamic var isHeartSticker : Bool = false
    override static func indexedProperties() -> [String] {
        return ["date"].reversed()
    }
    
    //For chat pin we may need some backlink
    override static func primaryKey() -> String? {
        return "messageID"
    }
}

class RealmRecent: Object {
    @objc dynamic var withUserID : String = ""
    @objc dynamic var withUserNickName : String = ""
    @objc dynamic var date = NSDate()
    //dynamic var avatar : NSData? = nil
    @objc dynamic var message : String = ""
    @objc dynamic var unread : Int = 0
    
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
            let messageNSDict = message as! NSDictionary
            recent.withUserID =  String(messageNSDict["with_user_id"]! as! Int)
            recent.withUserNickName = messageNSDict["with_nick_name"]! as? String ?? messageNSDict["with_user_name"]! as! String
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let date = dateFormatter.date(from: messageNSDict["last_message_timestamp"] as! String)
            recent.date = date! as NSDate
            recent.message = messageNSDict["last_message"]! as! String
            recent.unread = messageNSDict["unread_count"]! as! Int
            try! realm.write{
                realm.add(recent, update: true)
                //print("update recent")
            }
        }
    }
    
    static func receiveMessage(message : RealmMessage) {
        let realm = try! Realm()
        try! realm.write{
            realm.add(message);
        }
    }
    
    static func receiveMessage(message : NSDictionary, withUserID: String) {
        let realm = try! Realm()
        let timeStr = message["date"]! as! String
        if(realm.objects(RealmMessage.self).filter("messageID = '\(withUserID)_\(timeStr)'").first != nil){
            return
        }
        let messageRealm = RealmMessage()
        messageRealm.messageID = withUserID + (message["messageId"]! as! String)
        messageRealm.withUserID = withUserID
        messageRealm.date = timeStr
        messageRealm.delivered = true
        messageRealm.senderID = message["senderId"]! as! String
        messageRealm.type = message["type"]! as! String
        messageRealm.senderName = message["senderName"]! as! String
        messageRealm.hasTimeStamp = message["hasTimeStamp"]! as! Bool
        messageRealm.message = message["message"]! as! String
        if let data = message["data"] {
            messageRealm.data = Data(base64Encoded: (data as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0)) as NSData?
        }
        if let snapimage = message["snapImage"] {
            messageRealm.snapImage = Data(base64Encoded: (snapimage as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0)) as NSData?
        }
        if let videoDutation = message["videoDuration"] {
            messageRealm.videoDuration.value = videoDutation as? Int
        }
        if let longitude = message["longitude"] {
            messageRealm.longitude.value = longitude as? Double
        }
        if let latitude = message["latitude"] {
            messageRealm.latitude.value = latitude as? Double
        }
        if let _ = message["isHeartSticker"] {
            messageRealm.isHeartSticker = true
        }
        if let place = message["place"] {
            messageRealm.place = place as? String
        }
        //realm.objects(RealmMessage.self).filter(
        try! realm.write {
            realm.add(messageRealm)
        }
    }
    
    static func dateConverter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        return dateFormatter.string(from: date)
    }
    
    static func dateConverter(str: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMddhhmmssSSS"
        return dateFormatter.date(from: str)!
    }
    
    static func formatDate(str: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: str) {
            dateFormatter.dateFormat = "yyyyMMddhhmmss"
            return dateFormatter.string(from: date)
        }
        return str
    }
    
    static func fetchMessageWith(userID: Int, numberOfItem: Int, offset: Int) -> [RealmMessage] {
        return []
    }
    
    static func removeRecentWith(recentItem: RealmRecent) {
        let realm = try! Realm()
        try! realm.write {
            let withUserID = recentItem.withUserID
            realm.delete(realm.objects(RealmMessage.self).filter("withUserID = '\(withUserID)'"))
            realm.delete(recentItem)
        }
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
    
    static func compressImageToData(_ image: UIImage) -> Data? {
        var imageData = UIImageJPEGRepresentation(image, 1)
        let factor = min(5000000.0 / CGFloat(imageData!.count), 1.0)
        imageData = UIImageJPEGRepresentation(image, factor)
        return imageData
    }
    
}

