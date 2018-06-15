//
//  FaeChat.swift
//  faeBeta
//
//  Created by Jichao on 2017/9/13.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class FaeChat {
    var token: NotificationToken?
    var notificationRunLoop: CFRunLoop?
    
    // MARK: - Handle sending messages
    func observeMessageChange() {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool { [weak self] in
                guard let `self` = self else { return }
                self.notificationRunLoop = CFRunLoopGetCurrent()
                CFRunLoopPerformBlock(self.notificationRunLoop, CFRunLoopMode.defaultMode.rawValue) {
                    let realm = try! Realm()
                    let messages = realm.objects(RealmMessage.self).filter("login_user_id = '\(Key.shared.user_id)'")
                    self.token = messages.observe { [weak self] (changes: RealmCollectionChange) in
                        switch changes {
                        case .initial:
                            // print("initial")
                            break
                        case .update(_, _, let insertions, _):
                            // print("update")
                            guard let `self` = self else { return }
                            for insert in insertions {
                                if let sender = messages[insert].sender, sender.id != "\(Key.shared.user_id)" {
                                    continue
                                }
                                self.sendNewMessageToServer(messages[insert])
                            }
                        case .error:
                            // print("error")
                            break
                        }
                    }
                }
                CFRunLoopRun()
            }
        }
    }
    
    deinit {
        token?.invalidate()
        if let runloop = notificationRunLoop {
            CFRunLoopStop(runloop)
        }
    }
    
    func sendNewMessageToServer(_ newMessage: RealmMessage) {
        let message = newMessage.toDictionary()
        var members: [String] = []
        for user in newMessage.members {
            members.append(user.id)
        }
        message["members"] = members
        if let media = message["media"] {
            if !["[Place]"].contains(newMessage.type) {
                message["media"] = (media as! NSData).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            } else {
                message["media"] = ""
            }
        }
        message["sender"] = String(Key.shared.user_id)
        do {
            let json = try JSONSerialization.data(withJSONObject: message, options: [])
            postToURL("chats_v2", parameter: ["receiver_id": members[1], "message": String(data: json, encoding: .utf8)!, "type": "text"], authentication: Key.shared.headerAuthentication(), completion: { statusCode, result in
                if statusCode / 100 == 2 {
                    if (result as? NSDictionary) != nil {
                        print("\(statusCode) \(String(describing: message["index"]))")
                        let realm = try! Realm()
                        if let sentMessage = realm.filterMessage("\(Key.shared.user_id)_0_\(members[1])_\(message["index"]!)") {
                            try! realm.write {
                                sentMessage.upload_to_server = true
                            }
                        }
                    }
                } else if statusCode == 500 {
                    
                } else { // TODO: error code undecided
                    print("failed")
                }
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Handle receiving messages
    func getMessageFromServer() {
        getFromURL("chats_v2/unread", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
            if status / 2 == 100 {
                if let unreadList = result as? NSArray {
                    for item in unreadList {
                        let dictItem: NSDictionary = item as! NSDictionary
                        let chat_id = dictItem["last_message_sender_id"] as! Int
                        let unread_count = dictItem["unread_count"] as! Int
                        let chatIdOnServer = dictItem["chat_id"] as! Int
                        if chat_id == 1 {
                            deleteFromURL("chats_v2/\(chatIdOnServer)", parameter: [:], completion: { statusCode, _ in
                                if statusCode / 100 == 2 {
                                    felixprint("[delete chat \(chatIdOnServer) successfully]")
                                }
                            })
                        } else {
                            for _ in 0...unread_count / 50 {
                               self.getMessages(in: "\(chat_id)")
                            }
                        }
                    }
                }
            } else if status == 500 {
                
            } else { // TODO: error code undecided
                
            }
        }
    }
    
    func getMessages(in chat_id: String) {
        getFromURL("chats_v2/\(Key.shared.user_id)/\(chat_id)", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
            if status / 2 == 100 {
                if let response = result as? NSDictionary, let unreadMessages = response["messages"] as? NSArray {
                    for unreadMessage in unreadMessages {
                        if let msgDict = unreadMessage as? NSDictionary, let type = msgDict["type"] as? String, let message = msgDict["message"] as? String {
                            if chat_id == "1" { break }
                            if type != "text", let timestamp = msgDict["message_timestamp"] as? String {
                                self.handleFriendRelation(with: "\(chat_id)", on: message, time: timestamp)
                            } else {
                                self.storeToRealm(message, with: chat_id, is_group: 0)
                            }
                        }
                    }
                } else {
                    // print("no more new message")
                }
            } else if status == 500 {
                
            } else { // TODO: error code undeciced
                
            }
        }
    }
    
    func storeToRealm(_ message: String, with chat_id: String, is_group: Int) {
        guard let messageData = message.data(using: .utf8, allowLossyConversion: false) else { return }
        var messageJSON: JSON!
        do {
            messageJSON = try JSON(data: messageData)
        } catch {
            print("JSON Error: \(error)")
        }
        let login_user_id = "\(Key.shared.user_id)"
        let realm = try! Realm()
        let callGroup = DispatchGroup()
        for user in messageJSON["members"].arrayValue {
            callGroup.enter()
            if let _ = realm.filterUser(id: user.string!) {
                callGroup.leave()
            } else {
                getFromURL("users/\(user.string!)/name_card", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
                    if status / 100 == 2, let result = result {
                        let profileJSON = JSON(result)
                        let newUser = RealmUser(value: ["\(Key.shared.user_id)_\(user.string!)", String(Key.shared.user_id), "\(user.string!)", profileJSON["user_name"].stringValue, profileJSON["user_name"].stringValue, NO_RELATION, profileJSON["age"].stringValue, profileJSON["show_age"].boolValue, profileJSON["gender"].stringValue, profileJSON["show_gender"].boolValue, profileJSON["short_intro"].stringValue, ""])
                        try! realm.write {
                            realm.add(newUser, update: true)
                        }
                        General.shared.avatar(userid: Int(user.stringValue)!) { (avatarImage) in
                        }
                        callGroup.leave()
                    } else if status == 500 {
                        
                    } else { // TODO: error code undecided
                        
                    }
                }
            }
        }
        callGroup.notify(queue: .main) {
            let messageRealm = RealmMessage()
            let messagesInThisChat = realm.filterAllMessages(is_group, chat_id)
            var newIndex = 0
            var unread_count = 1
            if messagesInThisChat.count > 0, let last = messagesInThisChat.last {
                newIndex = last.index + 1
                unread_count = last.unread_count + 1
            }
            messageRealm.setPrimaryKeyInfo(login_user_id, is_group, chat_id, newIndex)
            for user in messageJSON["members"].arrayValue {
                if let userRealm = realm.filterUser(id: user.stringValue) {
                    if user.stringValue == login_user_id {
                        messageRealm.members.insert(userRealm, at: 0)
                    } else {
                        messageRealm.members.append(userRealm)
                    }
                    if let sender = messageJSON["sender"].string, userRealm.loginUserID_id == "\(login_user_id)_\(sender)" {
                        messageRealm.sender = userRealm
                    }
                } else {
                    
                }
            }
            messageRealm.created_at = messageJSON["created_at"].stringValue
            messageRealm.type = messageJSON["type"].stringValue
            messageRealm.text = messageJSON["text"].stringValue
            switch messageRealm.type {
            case "[Place]":
                self.downloadImageFor(messageJSON, primary_key: messageRealm.primary_key)
            default: break
            }
            if let media = messageJSON["media"].string, let decodeData = Data(base64Encoded: media, options: NSData.Base64DecodingOptions(rawValue: 0)) {
                messageRealm.media = decodeData as NSData
            }
            messageRealm.upload_to_server = true
            messageRealm.unread_count = unread_count
            
            let recentRealm = RealmRecentMessage()
            recentRealm.created_at = messageJSON["created_at"].stringValue
            recentRealm.unread_count = unread_count
            recentRealm.setPrimaryKeyInfo(login_user_id, is_group, chat_id)
            
            try! realm.write {
                realm.add(messageRealm, update: false)
                realm.add(recentRealm, update: true)
            }
        }
    }
    
    func downloadImageFor(_ message: JSON, primary_key: String) {
        let strDetail = message["text"].stringValue.replacingOccurrences(of: "\\", with: "")
        guard let dataDetail = strDetail.data(using: .utf8) else { return }
        var json: JSON!
        do {
            json = try JSON(data: dataDetail)
        } catch {
            print("JSON Error: \(error)")
        }
        guard let imageURL = json["imageURL"].string else { return }
        downloadImage(URL: imageURL) { rawData in
            guard let data = rawData else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    if let target = realm.filterMessage(primary_key) {
                        try! realm.write {
                            target.media = data as NSData
                            realm.add(target, update: true)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Handle user relation message
    static func sendContactMessage(to userId: Int, with message: String) {
        sendContactMessage(to: "\(userId)", with: message)
    }
    
    static func sendContactMessage(to userId: String, with message: String) {
        postToURL("chats_v2", parameter: ["receiver_id": userId, "message": message, "type": "customize"], authentication: Key.shared.headerAuthentication(), completion: { statusCode, result in
            if statusCode / 100 == 2 {
                if (result as? NSDictionary) != nil {
                    felixprint("\(statusCode) \(String(describing: result))")
                }
            } else if statusCode == 500 {
                
            } else { // TODO: error code undecided
                print("failed")
            }
        })
    }
    
    func handleFriendRelation(with userId: String, on message: String, time: String) {
        switch message {
        case "send friend request":
            FaeUser().getUserCard(String(userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    let json = JSON(message!)
                    let realm = try! Realm()
                    let user = RealmUser(value: ["\(Key.shared.user_id)_\(userId)", "\(Key.shared.user_id)", "\(userId)", json["user_name"].stringValue, json["nick_name"].stringValue, FRIEND_REQUESTED_BY, json["age"].stringValue, json["show_age"].boolValue, json["gender"].stringValue, json["show_gender"].boolValue, json["short_intro"].stringValue, RealmChat.formatDate(str: time)])
                    try! realm.write {
                        realm.add(user, update: true)
                    }
                } else {
                    print("[get user name card fail] \(status) \(message!)")
                }
            }
        case "resend friend request":
            let realm = try! Realm()
            if let user = realm.filterUser(id: userId) {
                try! realm.write {
                    user.created_at = RealmChat.formatDate(str: time)
                }
            }
        case "withdraw friend request", "ignore friend request", "remove friend":
            let realm = try! Realm()
            if let user = realm.filterUser(id: userId) {
                try! realm.write {
                    user.relation = NO_RELATION
                }
            }
        case "accept friend request":
            let realm = try! Realm()
            if let user = realm.filterUser(id: userId) {
                try! realm.write {
                    user.relation = IS_FRIEND
                }
            }
        case "block":
            let realm = try! Realm()
            if let user = realm.filterUser(id: userId) {
                try! realm.write {
                    if user.relation & IS_FRIEND == IS_FRIEND {
                        user.relation |= BLOCKED_BY
                    } else {
                        user.relation = BLOCKED_BY
                    }
                }
            }
        default: break
        }
    }
}
