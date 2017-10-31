//
//  ChatViewController+SendLoadMessages.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase
import RealmSwift

extension ChatViewController: OutgoingMessageProtocol {
    func sendMeaages_v2(type: String, text: String, media: Data? = nil) {
        let newMessage = RealmMessage_v2()
        let login_user_id = String(Key.shared.user_id)
        //newMessage.login_user_id = login_user_id
        let realm = try! Realm()
        //let messages = realm.objects(RealmMessage_v2.self).filter("chat_id == %@ AND login_user_id == %@", strChatId, String(Key.shared.user_id)).sorted(byKeyPath: "index")
        let messages = realm.filterAllMessages(login_user_id, intIsGroup, strChatId!)
        var newIndex = 0
        if messages.count > 0 {
            newIndex = (messages.last?.index)! + 1
        }
        //newMessage.index = newIndex
        //let primaryKey = "\(login_user_id)_\(strChatId!)_\(newIndex)"
        //newMessage.loginUserID_chatID_index = primaryKey
        //newMessage.chat_id = strChatId!
        newMessage.setPrimaryKeyInfo(login_user_id, intIsGroup, strChatId!, newIndex)
        for user_id in arrUserIDs {
            //let user = realm.objects(RealmUser.self).filter("loginUserID_id = '\(Key.shared.user_id)_\(user_id)'").first!
            let user = realm.filterUser(login_user_id, id: user_id)!
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
        let recentRealm = RealmRecent_v2()
        //recentRealm.login_user_id = login_user_id
        //recentRealm.chat_id = strChatId!
        recentRealm.created_at = newMessage.created_at
        recentRealm.unread_count = 0
        //recentRealm.loginUserID_chatID = "\(login_user_id)_\(strChatId!)"
        recentRealm.setPrimaryKeyInfo(login_user_id, intIsGroup, strChatId!)
        try! realm.write {
            realm.add(newMessage)
            realm.add(recentRealm, update: true)
        }
        //JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    // MARK: - send message
    func sendMessage(text: String? = nil, picture: UIImage? = nil, sticker: UIImage? = nil, isHeartSticker: Bool? = false, location: CLLocation? = nil, place: PlacePin? = nil, audio: Data? = nil, video: Data? = nil, videoDuration: Int = 0, snapImage: Data? = nil, date: Date) {
        
        var outgoingMessage: OutgoingMessage?
        // Bryan
        let shouldHaveTimeStamp = date.timeIntervalSince(dateLastMarker as Date) > 300 && !boolSentInLast5s
        let realmMessage = RealmMessage()
        realmMessage.messageID = "\(Key.shared.user_id)_\(RealmChat.dateConverter(date: date)))"
        realmMessage.withUserID = realmWithUser!.id
        realmMessage.senderID = "\(Key.shared.user_id)"
        realmMessage.senderName = Key.shared.username
        realmMessage.hasTimeStamp = shouldHaveTimeStamp
        realmMessage.delivered = true
        realmMessage.date = RealmChat.dateConverter(date: date)
        // ENDBryan
        
        if let pic = picture {
            // send picture message
            if let imageData = compressImageToData(pic) {
                outgoingMessage = OutgoingMessage(message: "[Picture]", picture: imageData, senderId: "\(Key.shared.user_id)", senderName: Key.shared.username, date: date, status: "Delivered", type: "picture", index: intTotalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
                // Bryan
                realmMessage.message = "[Picture]"
                realmMessage.data = imageData as NSData
                realmMessage.type = "picture"
                // ENDBryan
                boolSentInLast5s = true
                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.enableTimeStamp), userInfo: nil, repeats: false)
            }
        } else if let sti = sticker {
            // send sticker
            let imageData = UIImagePNGRepresentation(sti)
            outgoingMessage = OutgoingMessage(message: isHeartSticker! ? "[Heart]" : "[Sticker]", sticker: imageData!, isHeartSticker: isHeartSticker!, senderId: "\(Key.shared.user_id)", senderName: Key.shared.username, date: date, status: "Delivered", type: "sticker", index: intTotalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            // Bryan
            realmMessage.message = isHeartSticker! ? "[Heart]" : "[Sticker]"
            realmMessage.data = imageData! as NSData
            realmMessage.type = "sticker"
            realmMessage.isHeartSticker = isHeartSticker!
            // ENDBryan
            
            boolSentInLast5s = true
        } else if let loc = location {
            // send location message
            let lat: NSNumber = NSNumber(value: loc.coordinate.latitude as Double)
            let lon: NSNumber = NSNumber(value: loc.coordinate.longitude as Double)
            let comment = text == "" ? "[Location]" : text!
            outgoingMessage = OutgoingMessage(message: comment, latitude: lat, longitude: lon, snapImage: snapImage!, senderId: "\(Key.shared.user_id)", senderName: Key.shared.username, date: date, status: "Delivered", type: "location", index: intTotalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            // Bryan
            realmMessage.message = comment
            realmMessage.latitude.value = lat as? Double
            realmMessage.longitude.value = lon as? Double
            realmMessage.snapImage = snapImage! as NSData
            realmMessage.type = "location"
            // ENDBryan
            
        } else if let place = place {
            //let jsonString = "{ \"place_id\": @number, \"name\": @string, \"categories\": { \"class1\": @string, \"class1_icon_id\": @number, \"class2\": @string, \"class2_icon_id\": @number, \"class3\": @string, \"class3_icon_id\": @number, \"class4\": @string, \"class4_icon_id\": @number }, \"geolocation\": { \"latitude\": @number, \"longitude\": @number }, \"location\": { \"city\": @string, \"country\": @string, \"state\": @string, \"address\": @string, \"zip_code\": @string } }"
            let jsonString = "{" +
                                "\"place_id\": \"\(place.id)\"," +
                                "\"name\": \"\(place.name)\"," +
                                "\"categories\": {" +
                                    "\"class1\": \"\(place.class_1)\"," +
                                    "\"class1_icon_id\": \"\(place.class_2_icon_id)\"," +
                                "}," +
                                "\"geolocation\": {" +
                                    "\"latitude\": \"\(place.coordinate.latitude)\"," +
                                    "\"longitude\": \"\(place.coordinate.longitude)\"" +
                                "}," +
                                "\"location\": {" +
                                    "\"address1\": \"\(place.address1)\"," +
                                    "\"address2\": \"\(place.address2)\"," +
                                "}" +
                            "}"
            let comment = text == "" ? "[Place]" : text!
            outgoingMessage = OutgoingMessage(message: comment, place: jsonString, snapImage: snapImage!, senderId: "\(Key.shared.user_id)", senderName: Key.shared.username, date: date, status: "Delivered", type: "place", index: intTotalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            realmMessage.message = "[Place]"
            realmMessage.place = jsonString
            realmMessage.type = "place"
            
        } else if let audio = audio {
            // create outgoing-message object
            outgoingMessage = OutgoingMessage(message: "[Voice]", audio: audio, senderId: "\(Key.shared.user_id)", senderName: Key.shared.username, date: date, status: "Delivered", type: "audio", index: intTotalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            realmMessage.message = "[Voice]"
            realmMessage.data = audio as NSData
            realmMessage.type = "audio"
            
        } else if let video = video {
            outgoingMessage = OutgoingMessage(message: "[Video]", video: video, snapImage: snapImage!, senderId: "\(Key.shared.user_id)", senderName: Key.shared.username, date: date, status: "Delivered", type: "video", index: intTotalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp, videoDuration: videoDuration)
            realmMessage.message = "[Video]"
            realmMessage.data = video as NSData
            realmMessage.type = "video"
            realmMessage.videoDuration.value = videoDuration
        } else if let snapImage = snapImage {
            outgoingMessage = OutgoingMessage(message: "[GIF]", picture: snapImage, senderId: "\(Key.shared.user_id)", senderName: Key.shared.username, date: date, status: "Delivered", type: "gif", index: intTotalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            realmMessage.message = "[GIF]"
            realmMessage.data = snapImage as NSData
            realmMessage.type = "gif"
        } else if let text = text {
            // send message
            outgoingMessage = OutgoingMessage(message: text, senderId: "\(Key.shared.user_id)", senderName: Key.shared.username, date: date, status: "Delivered", type: "text", index: intTotalNumberOfMessages + 1, hasTimeStamp: shouldHaveTimeStamp)
            // Bryan
            realmMessage.message = text
            realmMessage.type = "text"
            // ENDBryan
        }
        
        // play message sent sound
        
        //JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        
        outgoingMessage!.delegate = self
        
        // add this outgoing message under chatRoom with id and content
        // Bryan
        outgoingMessage!.sendMessage(strChatRoomId, withUser: realmWithUser!)
        
        RealmChat.sendMessage(message: realmMessage, completion: self.fakeCompletion)
        
        _ = insertMessage(dictMessageSent)
        intNumberOfMessagesLoaded += 1
        self.finishSendingMessage(animated: true, cleanTextView: text != nil)
    }
    
    func fakeCompletion() {}
    // ENDBryan
    
    // send image delegate function
    func sendImages(_ images: [UIImage]) {
        for i in 0 ..< images.count {
            //self.sendMessage(picture: images[i], date: Date())
            sendMeaages_v2(type: "[Picture]", text: "[Picture]", media: RealmChat.compressImageToData(images[i]))
        }
        self.toolbarContentView.cleanUpSelectedPhotos()
    }
    
    func sendStickerWithImageName(_ name: String) {
        //self.sendMessage(sticker: UIImage(named: name), date: Date())
        sendMeaages_v2(type: "[Sticker]", text: name)
    }
    
    func sendAudioData(_ data: Data) {
        //self.sendMessage(audio: data, date: Date())
        sendMeaages_v2(type: "[Audio]", text: "[Audio]", media: data)
    }
    
    func sendGifData(_ data: Data) {
        //self.sendMessage(snapImage: data, date: Date())
        sendMeaages_v2(type: "[Gif]", text: "[Gif]", media: data)
    }
    
    func loadMessagesFromRealm() {
        let realm = try! Realm()
        //resultRealmMessages = realm.objects(RealmMessage_v2.self).filter("chat_id == %@ AND login_user_id == %@", strChatId, String(Key.shared.user_id)).sorted(byKeyPath: "index")
        resultRealmMessages = realm.filterAllMessages(String(Key.shared.user_id), intIsGroup, strChatId)
        let count = resultRealmMessages.count
        for i in (count - intNumberOfMessagesOneTime)..<count {
            if i < 0 {
                continue
            } else {
                let messageRealm = resultRealmMessages[i]
                if messageRealm.index < 0 {
                    continue
                }
                let incomingMessage = IncomingMessage(collectionView_: collectionView!)
                let messageJSQ = incomingMessage.createJSQMessage(messageRealm)
                arrJSQMessages.append(messageJSQ)
                arrRealmMessages.append(messageRealm)
                realm.beginWrite()
                resultRealmMessages[i].unread_count = 0
                try! realm.commitWrite()
            }
        }
        finishReceivingMessage(animated: false)
        guard let collectionView = self.collectionView else { return }
        notificationToken = resultRealmMessages.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                felixprint("initial")
                break
            case .update(_, _, let insertions, _):
                print("chat update")
                if insertions.count > 0 {
                    let insertMessage = self!.resultRealmMessages[insertions[0]]
                    let incomingMessage = IncomingMessage(collectionView_: collectionView)
                    let messageJSQ = incomingMessage.createJSQMessage(insertMessage)
                    self!.arrJSQMessages.append(messageJSQ)
                    self!.arrRealmMessages.append(insertMessage)
                    self!.finishReceivingMessage(animated: false)
                    if incomingMessage.senderId != "\(Key.shared.user_id)" {
                        realm.beginWrite()
                        insertMessage.unread_count = 0
                        try! realm.commitWrite()
                    }                    
                }
                break
            case .error:
                print("error")
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
                    let incomingMessage = IncomingMessage(collectionView_: collectionView!)
                    let messageJSQ = incomingMessage.createJSQMessage(messageRealm)
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
    
    
    // MARK: handle messages
    // open an observer on firebase to load new messages
    func loadNewMessage() {
        roomRef = ref.child(strChatRoomId)
        _refHandle = roomRef?.queryLimited(toLast: 15).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let item = (snapshot.value as? NSDictionary)!
            if self.arrStrMessagesKey.contains(snapshot.key) {
                return
            }
            let isIncoming = self.insertMessage(item)
            if isIncoming {
                //JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            }
            DispatchQueue.main.async {
                self.finishReceivingMessage(animated: false)
            }
            self.intNumberOfMessagesLoaded += 1
        })
    }
    
    // load new messages from firebase when scrolling to the top
    func loadPreviousMessages() {
        self.boolLoadingPreviousMessages = true
        if intTotalNumberOfMessages > intNumberOfMessagesLoaded {
            ref.child(strChatRoomId).queryOrdered(byChild: "index").queryStarting(atValue: max(intTotalNumberOfMessages - intNumberOfMessagesLoaded - intNumberOfMessagesOneTime + 1, 1)).queryEnding(atValue: intTotalNumberOfMessages - intNumberOfMessagesLoaded).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                if snapshot.exists() {
                    let result = (snapshot.value! as AnyObject).allValues as! [NSDictionary]
                    for item in result.sorted(by: { ($0["index"] as! Int) > ($1["index"] as! Int) }) {
                        _ = self.insertMessage(item, atIndex: 0)
                        self.intNumberOfMessagesLoaded += 1
                        
                    }
                    let oldOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
                    self.collectionView.reloadData()
                    self.collectionView.layoutIfNeeded()
                    self.collectionView.contentOffset = CGPoint(x: 0.0, y: self.collectionView.contentSize.height - oldOffset)
                    
                }
                self.boolLoadingPreviousMessages = false
            }
        } else {
            self.boolLoadingPreviousMessages = false
        }
    }
    
    func insertMessage_v2(_ message: RealmMessage_v2) -> Bool {
        _ = IncomingMessage(collectionView_: self.collectionView!)
        return false
    }
    
    /// append message to then end
    ///
    /// - Parameter item: the message information
    /// - Returns: true: the message is incoming message false: it's outgoing
    func insertMessage(_ item: NSDictionary) -> Bool {
        // unpack the message from data load to the JSQmessage
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        if item["hasTimeStamp"] != nil && item["hasTimeStamp"] as! Bool {
            let date = dateFormatter().date(from: (item["date"] as? String)!)
            dateLastMarker = date
        }
        if let message = message {
            arrDictMessages.append(item)
            arrJSQMessages.append(message)
            arrStrMessagesKey.append(item["messageId"] as! String)
            return self.incoming(item)
        }
        return false
    }
    
    /// insert the message into the whole messages
    ///
    /// - Parameters:
    ///   - item: the message information
    ///   - index: the place to insert the message
    /// - Returns: true: the message is incoming message false: it's outgoing
    func insertMessage(_ item: NSDictionary, atIndex index: Int) -> Bool {
        // unpack the message from data load to the JSQmessage
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        arrDictMessages.insert(item, at: index)
        arrJSQMessages.insert(message!, at: index)
        
        return self.incoming(item)
    }
    
    private func incoming(_ item: NSDictionary) -> Bool {
        if "\(Key.shared.user_id)" == item["senderId"] as! String {
            return false
        } else {
            return true
        }
    }
    
    private func outgoing(_ item: NSDictionary) -> Bool {
        if "\(Key.shared.user_id)" == item["senderId"] as! String {
            return true
        } else {
            return false
        }
    }
    
    /// This method will transfer an UIImage into NSData, and limit the size of the data
    ///
    /// - Parameter image: the image you want to compress
    /// - Returns: a data for the image
    private func compressImageToData(_ image: UIImage) -> Data? {
        var imageData = UIImageJPEGRepresentation(image, 1)
        let factor = min(5000000.0 / CGFloat(imageData!.count), 1.0)
        imageData = UIImageJPEGRepresentation(image, factor)
        return imageData
    }
    
    // MARK: locationSend Delegate
    func sendPickedLocation(_ lat: CLLocationDegrees, lon: CLLocationDegrees, screenShot: UIImage) {
        let location = CLLocation(latitude: lat, longitude: lon)
        General.shared.getAddress(location: location, original: true) { (placeMark) in
            guard let response = placeMark as? CLPlacemark else { return }
            self.uiviewLocationExtend.setAvator(image: screenShot)
            self.addResponseToLocationExtend(response: response, withMini: false)
        }
    }
    
    func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int) {
        //var imageData = UIImageJPEGRepresentation(snapImage, 1)
        //let factor = min(5000000.0 / CGFloat(imageData!.count), 1.0)
        //imageData = UIImageJPEGRepresentation(snapImage, factor)
        //sendMessage(video: video, videoDuration: duration, snapImage: imageData, date: Date())
        sendMeaages_v2(type: "[Video]", text: "\(duration)", media: video)
        self.toolbarContentView.cleanUpSelectedPhotos()
    }
    
    // MARK: outgoingmessage delegate
    func updateChat_Id(_ newId: String) {
        strChatId = newId
    }
    
    func getSentMessage(_ message: NSDictionary) {
        dictMessageSent = message
    }
}
