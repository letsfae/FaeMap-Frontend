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
    
    func updateFriendsList() {
        let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(Key.shared.user_id)", String(Key.shared.user_id), String(Key.shared.user_id), "", Key.shared.nickname!, true, "", Key.shared.gender])
        let realm = try! Realm()
        try! realm.write {
            realm.add(realmUser, update: true)
        }
        apiCalls.getFriends() {(status: Int, message: Any?) in
            let json = JSON(message!)
            if json.count == 0 {
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
                                if messages[insert].sender?.id != String(Key.shared.user_id) {
                                    break
                                } else {
                                    self?.sendNewMessageToServer(messages[insert])
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
            postToURL("chats_v2", parameter: ["receiver_id": members[1] as AnyObject, "message": String(data: json, encoding: .utf8)!, "type": newMessage.type], authentication: headerAuthentication(), completion: { (statusCode, result) in
                if statusCode / 100 == 2 {
                    if let resultDic = result as? NSDictionary {
                        print(" ")
                    }
                }
            })
        }
        catch {
            print(error.localizedDescription)
        }
        
        print("")
    }
}
