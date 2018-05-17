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
                let messageFae = FaeMessageMaker.create(from: messageRealm) { [weak self] in
                    guard let `self` = self else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if messageRealm.type == "[Video]" {
                            let faeMessage = self.arrFaeMessages.filter({ $0.messageId == messageRealm.primary_key })
                            if let index = self.arrFaeMessages.index(of: faeMessage[0]) {
                                self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                            }
                        }
                    }
                }
                arrFaeMessages.append(messageFae)
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
                    if let user = insertMessage.sender, user.id == "\(Key.shared.user_id)" {
                        break
                    }
                    let messageFae = FaeMessageMaker.create(from: insertMessage) { [weak self] in
                        guard let `self` = self else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if insertMessage.type == "[Video]" {
                                let faeMessage = self.arrFaeMessages.filter({ $0.messageId == insertMessage.primary_key })
                                if let index = self.arrFaeMessages.index(of: faeMessage[0]) {
                                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                                }
                            }
                        }
                    }
                    self.arrFaeMessages.append(messageFae)
                    self.finishReceivingMessage(animated: false)
                    if let user = insertMessage.sender, user.id != "\(Key.shared.user_id)" {
                        realm.beginWrite()
                        insertMessage.unread_count = 0
                        try! realm.commitWrite()
                    }
                }
                if modifications.count > 0 {
                    for item in modifications {
                        let message = self.resultRealmMessages[item]
                        let faeMessage = self.arrFaeMessages.filter({ $0.messageId == message.primary_key })
                        if let index = self.arrFaeMessages.index(of: faeMessage[0]) {
                            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        }
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
        if countAll > arrFaeMessages.count {
            let intEndIndex = countAll - arrFaeMessages.count
            let intStartIndex = intEndIndex - intNumberOfMessagesOneTime
            for i in (intStartIndex..<intEndIndex).reversed() {
                if i < 0 {
                    continue
                } else {
                    let messageRealm = resultRealmMessages[i]
                    if messageRealm.index < 0 {
                        continue
                    }
                    let messageFae = FaeMessageMaker.create(from: messageRealm) { [weak self] in
                        guard let `self` = self else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if messageRealm.type == "[Video]" {
                                let faeMessage = self.arrFaeMessages.filter({ $0.messageId == messageRealm.primary_key })
                                if let index = self.arrFaeMessages.index(of: faeMessage[0]) {
                                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                                }
                            }
                        }
                    }
                    arrFaeMessages.insert(messageFae, at: 0)
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
    func storeChatMessageToRealm(type: String, text: String, media: Data? = nil, faePHAsset: FaePHAsset? = nil) {
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
            completeStoring(newMessage)
            showOutgoingMessageInView(newMessage, faePHAsset: faePHAsset)
        } else if faePHAsset == nil {
            completeStoring(newMessage)
            showOutgoingMessageInView(newMessage, faePHAsset: faePHAsset)
        } else {
            showOutgoingMessageInView(newMessage, faePHAsset: faePHAsset)
            guard let phAsset = faePHAsset else { return }
            fetchOriginData(phAsset) { [weak self] (data, url) in
                guard let `self` = self else { return }
                newMessage.media = data! as NSData
                self.completeStoring(newMessage)
                self.updateFaeMessageMedia(newMessage, media: data, url: url)
            }
        }
    }
    
    private func fetchOriginData(_ faePHAsset: FaePHAsset, complete: @escaping ((Data?, URL?) -> Void)) {
        switch faePHAsset.assetType {
        case .photo, .livePhoto:
            if let data = faePHAsset.fullResolutionImageData {
                complete(data, nil)
            } else {
                var asset = faePHAsset
                asset.state = .ready
                _ = asset.cloudImageDownload(progress: { (_) in
                    if asset.state == .ready {
                        asset.state = .progress
                    }
                }, completion: { (data) in
                    asset.state = .complete
                    DispatchQueue.main.async {
                        complete(data, nil)
                    }
                })
            }
        case .video:
            _ = faePHAsset.tempCopyMediaFile(complete: { (url) in
                if let data = try? Data(contentsOf: url) {
                    complete(data, url)
                }
            })
            break
        }
    }
    
    private func completeStoring(_ message: RealmMessage) {
        let recentRealm = RealmRecentMessage()
        recentRealm.created_at = message.created_at
        recentRealm.unread_count = 0
        recentRealm.setPrimaryKeyInfo(String(Key.shared.user_id), intIsGroup, strChatId)
        let realm = try! Realm()
        try! realm.write {
            realm.add(message)
            realm.add(recentRealm, update: true)
        }
    }
    
    private func showOutgoingMessageInView(_ message: RealmMessage, faePHAsset: FaePHAsset? = nil) {
        let faeMessage = FaeMessageMaker.create(from: message, faePHAsset: faePHAsset)
        arrFaeMessages.append(faeMessage)
        if message.type == "text" {
            finishSendingMessage()
        } else {
            finishSendingMessage(animated: true, cleanTextView: false)
        }
    }
    
    private func updateFaeMessageMedia(_ message: RealmMessage, media: Data?, url: URL? = nil) {
        let faeMessage = arrFaeMessages.filter({ $0.messageId == message.primary_key })
        guard let data = media, faeMessage.count == 1 else { return }
        switch message.type {
        case "[Picture]", "[Gif]":
            if let mediaItem = faeMessage[0].media as? JSQPhotoMediaItemCustom {
                if message.type == "[Gif]" {
                    mediaItem.image = UIImage.gif(data: data)
                } else {
                    mediaItem.image = UIImage(data: data)
                }
            }
        case "[Video]":
            if let mediaItem = faeMessage[0].media as? JSQVideoMediaItemCustom, let url = url {
                mediaItem.fileURL = url
                mediaItem.isReadyToPlay = true
            }
        default: break
        }
        if let index = arrFaeMessages.index(of: faeMessage[0]) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}


