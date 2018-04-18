//
//  RealmChatBase.swift
//  faeBeta
//
//  Created by User on 04/04/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - Store chat messages
class RealmMessage: Object {
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

// MARK: - Store basic info for each chatting in recent list
class RealmRecentMessage: Object {
    @objc dynamic var primary_key: String = "" // login_user_id, chat_id
    @objc dynamic var login_user_id: String = ""
    @objc dynamic var is_group: Int = 0
    @objc dynamic var chat_id: String = ""
    @objc dynamic var chat_name: String = ""
    @objc dynamic var created_at: String = ""
    @objc dynamic var unread_count: Int = 0
    
    var latest_message: RealmMessage? {
        return realm?.objects(RealmMessage.self).filter("login_user_id == %@ AND is_group == %@ AND chat_id == %@", String(Key.shared.user_id), is_group, self.chat_id).sorted(byKeyPath: "index").last
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

// MARK: - Helper function to convert a Realm Object to Dictionary
extension Object {
    func toDictionary() -> NSMutableDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)
        
        for prop in self.objectSchema.properties {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [NSMutableDictionary]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    if let object = nestedListObject._rlmArray[index] as AnyObject as? Object {
                        objects.append(object.toDictionary())
                    }
                    //let obj = unsafeBitCast(object, to: Object.self)
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
        return mutabledic
    }
}

// MARK: - Helper functions to filter Realm object / collection
extension Realm {
    func filterAllMessages(_ is_group: Int, _ chat_id: String) -> Results<RealmMessage> {
        return self.objects(RealmMessage.self).filter("login_user_id == %@ AND is_group == %@ AND chat_id == %@", "\(Key.shared.user_id)", is_group, chat_id).sorted(byKeyPath: "index")
    }
    
    func filterMessage(_ primary_key: String) -> RealmMessage? {
        return self.objects(RealmMessage.self).filter("login_user_id == %@ AND primary_key == %@", "\(Key.shared.user_id)", primary_key).first
    }
    
    func filterUser(id: String) -> RealmUser? {
        return self.objects(RealmUser.self).filter("login_user_id == %@ AND id == %@", "\(Key.shared.user_id)", id).first
    }
    
    func filterUser(id: Int) -> RealmUser? {
        return self.filterUser(id: "\(id)")
    }
    
    func filterFriends() -> Results<RealmUser> {
        return self.objects(RealmUser.self).filter("login_user_id == %@ AND relation == %@", "\(Key.shared.user_id)", IS_FRIEND).sorted(byKeyPath: "display_name")
    }
    
    func filterReceivedFriendRequest() -> Results<RealmUser> {
        return self.objects(RealmUser.self).filter("login_user_id == %@ AND relation == %@", "\(Key.shared.user_id)", FRIEND_REQUESTED_BY).sorted(byKeyPath: "created_at", ascending: false)
    }
    
    func filterSentFriendRequest() -> Results<RealmUser> {
        return self.objects(RealmUser.self).filter("login_user_id == %@ AND relation == %@", "\(Key.shared.user_id)", FRIEND_REQUESTED).sorted(byKeyPath: "created_at", ascending: false)
    }
}

// MARK: - Helper functions
class RealmChat {
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
    
    static func compressImageToData(_ image: UIImage) -> Data? {
        var imageData = UIImageJPEGRepresentation(image, 1)
        let factor = min(5000000.0 / CGFloat(imageData!.count), 1.0)
        imageData = UIImageJPEGRepresentation(image, factor)
        return imageData
    }
    
}

