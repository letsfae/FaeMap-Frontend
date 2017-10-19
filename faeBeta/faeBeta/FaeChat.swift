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
    let apiCalls = FaeContact()
    
    
    var token: NotificationToken? = nil
    var notificationRunLoop: CFRunLoop? = nil
    var intLastSentIndex: Int = -1
    
    func updateFriendsList() {
        let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(Key.shared.user_id)", String(Key.shared.user_id), String(Key.shared.user_id), "", "", true, "", Key.shared.gender])
        let realm = try! Realm()
        try! realm.write {
            realm.add(realmUser, update: true)
        }
        apiCalls.getFriends() {(status: Int, message: Any?) in
            let json = JSON(message!)
            if status / 100 != 2 {
                return
            }
            if json.count != 0 {
                for i in 1...json.count {
                    let user_id = json[i-1]["friend_id"].stringValue
                    let user_name = json[i-1]["friend_user_name"].stringValue
                    let display_name = json[i-1]["friend_user_nick_name"].stringValue
                    let user_age = json[i-1]["friend_user_age"].stringValue
                    let user_gender = json[i-1]["friend_user_gender"].stringValue
                    let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", String(Key.shared.user_id), user_id, user_name, display_name, true, user_age, user_gender])
                    try! realm.write {
                        realm.add(realmUser, update: true)
                    }
                    General.shared.avatar(userid: Int(user_id)!) { (avatarImage) in
                    }
                }
            }
            let realmFae = RealmUser(value: ["\(Key.shared.user_id)_1", String(Key.shared.user_id), "1", "Fae Maps Team", "Fae Maps Team", true, "", ""])
            let realmFaeAvatar = UserAvatar()
            realmFaeAvatar.user_id = "1"
            realmFaeAvatar.userSmallAvatar = RealmChat.compressImageToData(UIImage(named: "faeAvatar")!)! as NSData
            try! realm.write {
                realm.add(realmFae, update: true)
                realm.add(realmFaeAvatar, update: true)
            }
            
        }
    }
    
    func observeMessageChange() {
        //let messageRef = ThreadSafeReference()
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                self.notificationRunLoop = CFRunLoopGetCurrent()
                CFRunLoopPerformBlock(self.notificationRunLoop, CFRunLoopMode.defaultMode.rawValue) {
                    let realm = try! Realm()
                    let messages = realm.objects(RealmMessage_v2.self).filter("login_user_id = '\(Key.shared.user_id)'")
                    self.token = messages.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                        switch changes {
                        case .initial:
                            //print("initial")
                            break
                        case .update(_, let deletions, let insertions, let modifications):
                            //print("update")
                            for insert in insertions {
                                if messages[insert].sender?.id != String(Key.shared.user_id) || insert == self?.intLastSentIndex || messages[insert].chat_id == "-1" {
                                    break
                                } else {
                                    self?.intLastSentIndex = insert
                                    //self?.sendNewMessageToServer(messages[insert])
                                }
                            }
                            break
                        case .error:
                            print("error")
                            break
                        }
                    }
               }
               CFRunLoopRun()
            }
        }
    }
    
    deinit {
        token?.stop()
        if let runloop = notificationRunLoop {
            CFRunLoopStop(runloop)
        }
    }
    
    func sendNewMessageToServer(_ newMessage: RealmMessage_v2) {
        let message = newMessage.toDictionary()
        var members: [String] = []
        for user in newMessage.members {
            members.append(user.id)
        }
        message["members"] = members
        if let media = message["media"] {
            message["media"] = (media as! NSData).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue : 0))
        }
        message["sender"] = String(Key.shared.user_id)
        do {
            let json = try JSONSerialization.data(withJSONObject: message, options: [])
            postToURL("chats_v2", parameter: ["receiver_id": members[1] as AnyObject, "message": String(data: json, encoding: .utf8)!, "type": "text"], authentication: headerAuthentication(), completion: { (statusCode, result) in
                if statusCode / 100 == 2 {
                    
                    if let resultDic = result as? NSDictionary {
                        print(statusCode)
                    }
                } else {
                    print("failed")
                }
            })
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func keepFetchMessages() {
        
    }
    
    func getMessageFromServer() {
        getFromURL("chats_v2/unread", parameter: nil, authentication: headerAuthentication()) {_, result in
            if let unreadList = result as? NSArray {
                for item in unreadList {
                    let dictItem: NSDictionary = item as! NSDictionary
                    let chat_id = dictItem["chat_id"] as! Int
                    var unread_count = dictItem["unread_count"] as! Int
                    let callGroup = DispatchGroup()
                    //while unread_count > 0 {
                        callGroup.enter()
                        getFromURL("chats_v2/\(chat_id)", parameter: nil, authentication: headerAuthentication()) {_, result in
                            if let unreadMessages = result as? NSArray {
                                unread_count -= unreadMessages.count
                                for unreadMessage in unreadMessages {
                                    if let message = unreadMessage as? NSDictionary {
                                        self.storeMessageToRealm(message["message"] as! String, is_group: 0)
                                    }
                                }
                                callGroup.leave()
                            } else {
                                //print("no more new message")
                            }
                        }
                    //}
                    callGroup.notify(queue: .main) {
                        print("finish reading")
                        postToURL("chats/read", parameter: ["chat_id": chat_id as AnyObject], authentication: headerAuthentication(), completion: { (statusCode, result) in
                            print("\(statusCode)")
                        })
                    }
                }
            }
        }
    }
    
    func storeMessageToRealm(_ message: String, is_group: Int) {
        if message == "[GET_CHAT_ID]" { return }
        //print("\(message)")
        guard let messageData = message.data(using: .utf8, allowLossyConversion: false) else { return }
        let messageJSON = JSON(data: messageData)
        let messageRealm = RealmMessage_v2()
        let login_user_id = "\(Key.shared.user_id)"
        //messageRealm.login_user_id = login_user_id
        let chat_id = messageJSON["chat_id"].string!
        //messageRealm.chat_id = chat_id
        let realm = try! Realm()
        let messagesInThisChat = realm.filterAllMessages(login_user_id, is_group, chat_id)//realm.objects(RealmMessage_v2.self).filter("login_user_id == %@ AND chat_id == %@", login_user_id, chat_id).sorted(byKeyPath: "index")
        var newIndex = 0
        var unread_count = 1
        if messagesInThisChat.count > 0 {
            newIndex = (messagesInThisChat.last?.index)! + 1
            unread_count = (messagesInThisChat.last?.unread_count)! + 1
        }
        //messageRealm.index = newIndex
        messageRealm.setPrimaryKeyInfo(login_user_id, is_group, chat_id, newIndex)
        //let primaryKey = "\(login_user_id)_\(chat_id)_\(newIndex)"
        //messageRealm.loginUserID_chatID_index = primaryKey
        for user in messageJSON["members"].arrayValue {
            if let userRealm = realm.filterUser(login_user_id, id: user.string!) { //objects(RealmUser.self).filter("login_user_id == %@ AND id == %@", login_user_id, user.string!).first {
                if user.string! == login_user_id {
                    messageRealm.members.insert(userRealm, at: 0)
                } else {
                    messageRealm.members.append(userRealm)
                }
                if userRealm.loginUserID_id == "\(login_user_id)_\(messageJSON["sender"].string!)" {
                    messageRealm.sender = userRealm
                }
            } else {
                
            }
        }
        messageRealm.created_at = messageJSON["created_at"].string!
        messageRealm.type = messageJSON["type"].string!
        messageRealm.text = messageJSON["text"].string!
        if let media = messageJSON["media"].string {
            if let decodeData = Data(base64Encoded: media, options: NSData.Base64DecodingOptions(rawValue : 0)) {
                messageRealm.media = decodeData as NSData
            }
        }
        messageRealm.unread_count = unread_count
        
        let recentRealm = RealmRecent_v2()
        //recentRealm.login_user_id = login_user_id
        //recentRealm.chat_id = chat_id
        recentRealm.created_at = messageJSON["created_at"].string!
        recentRealm.unread_count = unread_count
        //recentRealm.loginUserID_chatID = "\(login_user_id)_\(chat_id)"
        recentRealm.setPrimaryKeyInfo(login_user_id, is_group, chat_id)
        try! realm.write {
            realm.add(messageRealm, update: false)
            realm.add(recentRealm, update: true)
        }
    }
}
