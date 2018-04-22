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
    
    let realm = try! Realm()
    let login_user_id = String(Key.shared.user_id)
    let fae = realm.filterUser(id: "1")!
    let selfUser = realm.filterUser(id: login_user_id)!
    if let _ = fae.message {
    } else {
        let chat_id = "1"
        let newMessage = RealmMessage()
        newMessage.setPrimaryKeyInfo(login_user_id, 0, chat_id, 0)
        newMessage.sender = fae
        newMessage.members.append(selfUser)
        newMessage.members.append(fae)
        newMessage.created_at = RealmChat.dateConverter(date: Date())
        newMessage.type = "text"
        newMessage.text = text
        newMessage.unread_count = 1
        let recentRealm = RealmRecentMessage()
        recentRealm.created_at = newMessage.created_at
        recentRealm.unread_count = 1
        recentRealm.setPrimaryKeyInfo(login_user_id, 0, chat_id)
        try! realm.write {
            realm.add(newMessage)
            realm.add(recentRealm, update: true)
        }
    }
    /*if realm.filterAllMessages(login_user_id, 0, login_user_id).count == 0 {
        let newMessage = RealmMessage()
        newMessage.setPrimaryKeyInfo(login_user_id, 0, login_user_id, -1)
        newMessage.sender = selfUser
        newMessage.members.append(selfUser)
        newMessage.members.append(selfUser)
        newMessage.created_at = RealmChat.dateConverter(date: Date())
        newMessage.type = "text"
        newMessage.text = ""
        newMessage.unread_count = 0
        let recentRealm = RealmRecentMessage()
        recentRealm.created_at = newMessage.created_at
        recentRealm.unread_count = 0
        recentRealm.setPrimaryKeyInfo(login_user_id, 0, login_user_id)
        try! realm.write {
            realm.add(newMessage)
            realm.add(recentRealm, update: true)
        }
    }*/
    
}
