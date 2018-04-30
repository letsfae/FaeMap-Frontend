//
//  ChatViewController+SendLoadMessages.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import RealmSwift

extension ChatViewController {
    // MARK: - Load messages from Realm
    func loadLatestMessagesFromRealm() {
        let realm = try! Realm()
        resultRealmMessages = realm.filterAllMessages(intIsGroup, strChatId)
        let count = resultRealmMessages.count
        for i in (count - intNumberOfMessagesOneTime)..<count {
            if i < 0 {
                continue
            } else {
                let messageRealm = resultRealmMessages[i]
                if messageRealm.index < 0 {
                    continue
                }
                let messageJSQ = JSQMessageMaker.create(from: messageRealm)
                arrJSQMessages.append(messageJSQ)
                arrRealmMessages.append(messageRealm)
                realm.beginWrite()
                resultRealmMessages[i].unread_count = 0
                try! realm.commitWrite()
            }
        }
        finishReceivingMessage(animated: false)
        observeOnMessagesChange()
    }
    
    func observeOnMessagesChange() {
        let realm = try! Realm()
        guard let collectionView = self.collectionView else { return }
        notificationToken = resultRealmMessages.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                felixprint("initial")
            case .update(_, _, let insertions, let modifications):
                felixprint("[chat update]")
                guard let `self` = self else { return }
                if insertions.count > 0 {
                    let insertMessage = self.resultRealmMessages[insertions[0]]
                    let messageJSQ = JSQMessageMaker.create(from: insertMessage)
                    self.arrJSQMessages.append(messageJSQ)
                    self.arrRealmMessages.append(insertMessage)
                    self.finishReceivingMessage(animated: false)
                    if let user = insertMessage.sender, user.id != "\(Key.shared.user_id)" {
                        realm.beginWrite()
                        insertMessage.unread_count = 0
                        try! realm.commitWrite()
                    }
                }
                if modifications.count > 0 {
                    for item in modifications {
                        collectionView.reloadItems(at: [IndexPath(row: item, section: 0)])
                    }
                }
            case .error:
                felixprint("error")
            }
        }
    }
    
    func loadPrevMessagesFromRealm() {
        boolLoadingPreviousMessages = true
        let countAll = resultRealmMessages.count
        if countAll > arrRealmMessages.count {
            let intEndIndex = countAll - arrRealmMessages.count
            let intStartIndex = intEndIndex - intNumberOfMessagesOneTime
            for i in (intStartIndex..<intEndIndex).reversed() {
                if i < 0 {
                    continue
                } else {
                    let messageRealm = resultRealmMessages[i]
                    if messageRealm.index < 0 {
                        continue
                    }
                    let messageJSQ = JSQMessageMaker.create(from: messageRealm)
                    arrJSQMessages.insert(messageJSQ, at: 0)
                    arrRealmMessages.insert(messageRealm, at: 0)
                }
            }
            let oldOffset = collectionView.contentSize.height - collectionView.contentOffset.y
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.contentOffset = CGPoint(x: 0.0, y: collectionView.contentSize.height - oldOffset)
            boolLoadingPreviousMessages = false
        } else {
            boolLoadingPreviousMessages = false
        }
    }

    // MARK: - Store message to Realm
    func storeChatMessageToRealm(type: String, text: String, media: Data? = nil) {
        let newMessage = RealmMessage()
        let login_user_id = String(Key.shared.user_id)
        let realm = try! Realm()
        let messages = realm.filterAllMessages(intIsGroup, strChatId)
        var newIndex = 0
        if messages.count > 0 {
            newIndex = messages.last!.index + 1
        }
        newMessage.setPrimaryKeyInfo(login_user_id, intIsGroup, strChatId, newIndex)
        for user_id in arrUserIDs {
            let user = realm.filterUser(id: user_id)!
            newMessage.members.append(user)
            if user.loginUserID_id == "\(login_user_id)_\(login_user_id)" {
                newMessage.sender = user
            }
        }
        newMessage.created_at = RealmChat.dateConverter(date: Date())
        newMessage.type = type
        newMessage.text = text
        if media != nil {
            newMessage.media = media! as NSData
        }
        let recentRealm = RealmRecentMessage()
        recentRealm.created_at = newMessage.created_at
        recentRealm.unread_count = 0
        recentRealm.setPrimaryKeyInfo(login_user_id, intIsGroup, strChatId)
        try! realm.write {
            realm.add(newMessage)
            realm.add(recentRealm, update: true)
        }
        if type == "text" {
            finishSendingMessage()
        } else {
            finishSendingMessage(animated: true, cleanTextView: false)
        }
    }
}
