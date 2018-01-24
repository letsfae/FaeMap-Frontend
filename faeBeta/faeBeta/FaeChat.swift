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
    
    var token: NotificationToken?
    var notificationRunLoop: CFRunLoop?
    var intLastSentIndex: Int = -1
    
    func updateFriendsList() {
        let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(Key.shared.user_id)", String(Key.shared.user_id), String(Key.shared.user_id), "", "", MYSELF, "", Key.shared.gender])
        let realm = try! Realm()
        try! realm.write {
            realm.add(realmUser, update: true)
        }
        let realmFae = RealmUser(value: ["\(Key.shared.user_id)_1", String(Key.shared.user_id), "1", "Fae Maps Team", "Fae Maps Team", IS_FRIEND, "", ""])
        let realmFaeAvatar = UserImage()
        realmFaeAvatar.user_id = "1"
        realmFaeAvatar.userSmallAvatar = RealmChat.compressImageToData(UIImage(named: "faeAvatar")!)! as NSData
        try! realm.write {
            realm.add(realmFae, update: true)
            realm.add(realmFaeAvatar, update: true)
        }
        apiCalls.getFriends { (status: Int, message: Any?) in
            let json = JSON(message!)
            if status / 100 != 2 {
                return
            }
            if json.count != 0 {
                for i in 1...json.count {
                    let user_id = json[i - 1]["friend_id"].stringValue
                    let user_name = json[i - 1]["friend_user_name"].stringValue
                    let display_name = json[i - 1]["friend_user_nick_name"].stringValue
                    let user_age = json[i - 1]["friend_user_age"].stringValue
                    let user_gender = json[i - 1]["friend_user_gender"].stringValue
                    let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", String(Key.shared.user_id), user_id, user_name, display_name, IS_FRIEND, user_age, user_gender])
                    try! realm.write {
                        realm.add(realmUser, update: true)
                    }
                    General.shared.avatar(userid: Int(user_id)!) { _ in
                    }
                }
            }
        }
    }
    
    func observeMessageChange() {
        // let messageRef = ThreadSafeReference()
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                self.notificationRunLoop = CFRunLoopGetCurrent()
                CFRunLoopPerformBlock(self.notificationRunLoop, CFRunLoopMode.defaultMode.rawValue) {
                    let realm = try! Realm()
                    let messages = realm.objects(RealmMessage_v2.self).filter("login_user_id = '\(Key.shared.user_id)'")
                    self.token = messages.observe { [weak self] (changes: RealmCollectionChange) in
                        switch changes {
                        case .initial:
                            // print("initial")
                            break
                        case .update(_, _, let insertions, _):
                            // print("update")
                            for insert in insertions {
                                // print(insert)
                                // print(self?.intLastSentIndex)
                                if messages[insert].sender?.id != String(Key.shared.user_id) || insert == self?.intLastSentIndex || messages[insert].chat_id == "\(Key.shared.user_id)" {
                                    
                                } else {
                                    self?.intLastSentIndex = insert
                                    self?.sendNewMessageToServer(messages[insert])
                                }
                            }
                            break
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
    
    func sendNewMessageToServer(_ newMessage: RealmMessage_v2) {
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
                    }
                } else {
                    print("failed")
                }
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func keepFetchMessages() {
        
    }
    
    func getMessageFromServer() {
        getFromURL("chats_v2/unread", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
            /*
            if status == 401 {
                if let root = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                    if Key.shared.is_Login {
                        let welcomeVC = WelcomeViewController()
                        root.viewControllers = [welcomeVC]
                        Key.shared.navOpenMode = .welcomeFirst
                        Key.shared.is_Login = false
                        let alertController = UIAlertController(title: "Connection Lost", message: "Another device has logged on to Fae Map with this Account!", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
                        alertController.addAction(okAction)
                        root.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            */
            if let unreadList = result as? NSArray {
                for item in unreadList {
                    let dictItem: NSDictionary = item as! NSDictionary
                    let chat_id = dictItem["last_message_sender_id"] as! Int
                    let unread_count = dictItem["unread_count"] as! Int
                    let chatIdOnServer = dictItem["chat_id"] as! Int
                    if chat_id == 1 {
                        deleteFromURL("chats_v2/\(chatIdOnServer)", parameter: [:], completion: { statusCode, _ in
                            if statusCode / 100 == 2 {
                                print("delete \(chatIdOnServer) successfully")
                            }
                        })
                    } else {
                        let callGroup = DispatchGroup()
                        // while unread_count > 0 {
                        for _ in 0...unread_count / 50 {
                            callGroup.enter()
                            getFromURL("chats_v2/\(Key.shared.user_id)/\(chat_id)", parameter: nil, authentication: Key.shared.headerAuthentication()) { _, result in
                                if let response = result as? NSDictionary {
                                    // unread_count = response["unread_count"] as! Int
                                    let unreadMessages = response["messages"] as! NSArray
                                    for unreadMessage in unreadMessages {
                                        if let message = unreadMessage as? NSDictionary {
                                            if chat_id == 1 { break }
                                            self.storeMessageToRealm(message["message"] as! String, is_group: 0, chatID: chat_id)
                                        }
                                    }
                                    callGroup.leave()
                                } else {
                                    // print("no more new message")
                                }
                            }
                        }
                        callGroup.notify(queue: .main) {
                            // print("finish reading")
                            // postToURL("chats/read", parameter: ["chat_id": chat_id as AnyObject], authentication: headerAuthentication(), completion: { (statusCode, result) in
                            // print("\(statusCode)")
                            // })
                        }
                    }
                }
            }
        }
    }
    
    func storeMessageToRealm(_ message: String, is_group: Int, chatID: Int) {
        // if message == "[GET_CHAT_ID]" { return }
        // print("\(message)")
        guard let messageData = message.data(using: .utf8, allowLossyConversion: false) else { return }
        let messageJSON = JSON(data: messageData)
        let login_user_id = "\(Key.shared.user_id)"
        let realm = try! Realm()
        let callGroup = DispatchGroup()
        for user in messageJSON["members"].arrayValue {
            callGroup.enter()
            if let _ = realm.filterUser(id: user.string!) {
                callGroup.leave()
            } else {
                getFromURL("users/\(user.string!)/name_card", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
                    if status / 100 == 2 && result != nil {
                        let profileJSON = JSON(result!)
                        let newUser = RealmUser(value: ["\(Key.shared.user_id)_\(user.string!)", String(Key.shared.user_id), "\(user.string!)", profileJSON["user_name"].stringValue, profileJSON["user_name"].stringValue, NO_RELATION, "", ""])
                        try! realm.write {
                            realm.add(newUser, update: true)
                        }
                        General.shared.avatar(userid: Int(user.stringValue)!) { (avatarImage) in
                        }
                        callGroup.leave()
                    }
                }
            }
        }
        callGroup.notify(queue: .main) {
            let messageRealm = RealmMessage_v2()
            // messageRealm.login_user_id = login_user_id
            let chat_id = "\(chatID)"
            // messageRealm.chat_id = chat_id
            
            let messagesInThisChat = realm.filterAllMessages(is_group, chat_id) // realm.objects(RealmMessage_v2.self).filter("login_user_id == %@ AND chat_id == %@", login_user_id, chat_id).sorted(byKeyPath: "index")
            var newIndex = 0
            var unread_count = 1
            if messagesInThisChat.count > 0 {
                newIndex = (messagesInThisChat.last?.index)! + 1
                unread_count = (messagesInThisChat.last?.unread_count)! + 1
            }
            // messageRealm.index = newIndex
            messageRealm.setPrimaryKeyInfo(login_user_id, is_group, chat_id, newIndex)
            // let primaryKey = "\(login_user_id)_\(chat_id)_\(newIndex)"
            // messageRealm.loginUserID_chatID_index = primaryKey
            for user in messageJSON["members"].arrayValue {
                if let userRealm = realm.filterUser(id: user.string!) { // objects(RealmUser.self).filter("login_user_id == %@ AND id == %@", login_user_id, user.string!).first {
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
            switch messageRealm.type {
            case "[Place]":
                self.downloadImageFor(messageJSON, primary_key: messageRealm.primary_key)
                break
            default:
                break
            }
            if let media = messageJSON["media"].string {
                if let decodeData = Data(base64Encoded: media, options: NSData.Base64DecodingOptions(rawValue: 0)) {
                    messageRealm.media = decodeData as NSData
                }
            }
            messageRealm.unread_count = unread_count
            
            let recentRealm = RealmRecent_v2()
            // recentRealm.login_user_id = login_user_id
            // recentRealm.chat_id = chat_id
            recentRealm.created_at = messageJSON["created_at"].string!
            recentRealm.unread_count = unread_count
            // recentRealm.loginUserID_chatID = "\(login_user_id)_\(chat_id)"
            recentRealm.setPrimaryKeyInfo(login_user_id, is_group, chat_id)
            try! realm.write {
                realm.add(messageRealm, update: false)
                realm.add(recentRealm, update: true)
            }
        }
    }
    
    func downloadImageFor(_ message: JSON, primary_key: String) {
        let strDetail = message["text"].stringValue.replacingOccurrences(of: "\\", with: "")
        let dataDetail = strDetail.data(using: .utf8)
        let jsonDetail = JSON(data: dataDetail!)
        let imageURL = jsonDetail["imageURL"].stringValue
        if imageURL != "" {
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
    }
}
