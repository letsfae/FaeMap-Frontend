//
//  FirebaseWelcomer.swift
//  faeBeta
//
//  Created by User on 03/02/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import AVFoundation
import RealmSwift

func sendWelcomeMessage() {
    
    let text = "Hey there! Welcome to Faevorite Map! We are here to ensure that you have the best experience on our new platform. Kindly let us know if you encounter any problems or what we can do to make your experience better. Feel free to chat with us here. Happy Discovering!"
    
    //_ = OutgoingMessage.init(message : text, senderId : "1", senderName : "Fae Map Crew", date: Date(), status : "Delivered", type : "text", index : 1, hasTimeStamp: true)
    
    //print("[my user_id] :" + user_id.stringValue)
    //print("[my username] :" + username!)
    
    //Bryan
    //message.sendMessageWithWelcomeInformation("1-" + user_id.stringValue , withUser: RealmWithUser(userName: username!, userId: user_id.stringValue, userAvatar: nil))
    //ENDBryan
    let realm = try! Realm()
    let login_user_id = String(Key.shared.user_id)
    let fae = realm.filterUser(login_user_id, id: "1")!
    let selfUser = realm.filterUser(login_user_id, id: login_user_id)!
    if let _ = fae.message {
    } else {
        let chat_id = "1"
        let newMessage = RealmMessage_v2()
        newMessage.setPrimaryKeyInfo(login_user_id, 0, chat_id, 0)
        newMessage.sender = fae
        newMessage.members.append(selfUser)
        newMessage.members.append(fae)
        newMessage.created_at = RealmChat.dateConverter(date: Date())
        newMessage.type = "text"
        newMessage.text = text
        newMessage.unread_count = 1
        let recentRealm = RealmRecent_v2()
        recentRealm.created_at = newMessage.created_at
        recentRealm.unread_count = 1
        recentRealm.setPrimaryKeyInfo(login_user_id, 0, chat_id)
        try! realm.write {
            realm.add(newMessage)
            realm.add(recentRealm, update: true)
        }
    }
    /*if realm.filterAllMessages(login_user_id, 0, login_user_id).count == 0 {
        let newMessage = RealmMessage_v2()
        newMessage.setPrimaryKeyInfo(login_user_id, 0, login_user_id, -1)
        newMessage.sender = selfUser
        newMessage.members.append(selfUser)
        newMessage.members.append(selfUser)
        newMessage.created_at = RealmChat.dateConverter(date: Date())
        newMessage.type = "text"
        newMessage.text = ""
        newMessage.unread_count = 0
        let recentRealm = RealmRecent_v2()
        recentRealm.created_at = newMessage.created_at
        recentRealm.unread_count = 0
        recentRealm.setPrimaryKeyInfo(login_user_id, 0, login_user_id)
        try! realm.write {
            realm.add(newMessage)
            realm.add(recentRealm, update: true)
        }
    }*/
    
}
