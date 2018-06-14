//
//  ChatViewController+collecitonView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Photos
import AVKit
import AVFoundation
import SwiftyJSON
import RealmSwift

// MARK: - collectionView delegate
extension ChatViewController {
    /// datasource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCellCustom
        let faeMessage = arrFaeMessages[indexPath.row]        
        if faeMessage.senderId == "\(Key.shared.user_id)" {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor._107105105()
        }
        cell.textView?.font = UIFont(name: "Avenir Next", size: 17.5)
        cell.avatarImageView.layer.cornerRadius = 19.5
        cell.avatarImageView.contentMode = .scaleAspectFill
        cell.avatarImageView.layer.masksToBounds = true
        switch faeMessage.messageType {
            case "text":
                cell.contentType = Text
            case "[Picture]", "[Gif]":
                cell.contentType = Picture
            case "[Sticker]", "[Heart]":
                cell.contentType = Sticker
            case "[Location]":
                cell.contentType = Location
            case "[Place]":
                cell.contentType = Place
            case "[Collection]":
                cell.contentType = Collection
            case "[Audio]":
                cell.contentType = Audio
                if let message = faeMessage.media as? JSQAudioMediaItemCustom {
                    message.delegate = self
                }
            case "[Video]":
                cell.contentType = Video
                if let message = faeMessage.media as? JSQVideoMediaItemCustom {
                    if faeMessage.messageId == "\(Key.shared.user_id)" {
                        let realm = try! Realm()
                        if let realmMessage = realm.filterMessage(faeMessage.messageId) {
                            realmMessage.upload_to_server ? message.stopAnimating() : message.startAnimating()
                        }
                    }
                }
            default: // unknown type
                cell.contentType = Text
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == arrFaeMessages.count - 1, let faeMessage = arrFaeMessages.last {
            if faeMessage.senderId != "\(Key.shared.user_id)" || faeMessage.messageType != "[Heart]" || Date().timeIntervalSince(faeMessage.date) > 180 {
                boolJustSentHeart = false
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return arrFaeMessages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFaeMessages.count
    }
    
    /// Set bubble image for incoming/outgoing messages
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        var outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).outgoingMessagesBubbleImage(with: UIColor._2499090())
        let message = arrFaeMessages[indexPath.row]
        if message.senderId == "\(Key.shared.user_id)" {
            if message.isMediaMessage {
                outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "avatarPlaceholder"), capInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)).outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
            }
            return outgoingBubble
        } else {
            let incomingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).incomingMessagesBubbleImage(with: UIColor.white)
            return incomingBubble
        }
    }
    
    /// Set top label for timestamp if necessary
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let faeMessage = arrFaeMessages[indexPath.row]
        if indexPath.row == 0 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: faeMessage.date)
        } else {
            let prevMessage = arrFaeMessages[indexPath.row - 1]
            if faeMessage.date.timeIntervalSince(prevMessage.date) / 60 > 3 {
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: faeMessage.date)
            }
        }
        return nil
    }
    
    /// Set the label height
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayoutCustom!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let faeMessage = arrFaeMessages[indexPath.row]
        if indexPath.row == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            let prevMessage = arrFaeMessages[indexPath.row - 1]
            if faeMessage.date.timeIntervalSince(prevMessage.date) / 60 > 3 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    /// Set bottom label height
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayoutCustom!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0.0
    }
    
    /// Set bottom label content
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return NSAttributedString(string: "")
    }
    
    /// Set avatar image
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let faeMessage = arrFaeMessages[indexPath.row]
        let avatar = avatarDictionary.object(forKey: faeMessage.senderId) as! JSQMessageAvatarImageDataSource
        return avatar 
    }
    
    /// Called when user tap the bubble, including image, location, place, collection
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let faeMessage = arrFaeMessages[indexPath.row]
        let realm = try! Realm()
        guard let realmMessage = realm.filterMessage(faeMessage.messageId) else {
            // TODO: alert
            return
        }
        switch faeMessage.messageType {
        case "[Picture]", "[Gif]":
            /*let messageJSQ = arrJSQMessages[indexPath.row]
              if let mediaItem = messageJSQ.media as? JSQPhotoMediaItemCustom {
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mediaItem.image)
                images.append(photo)
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: nil)
            }*/
            var images = [SKPhoto]()
            let realm = try! Realm()
            let allMessage = realm.objects(RealmMessage.self).filter("login_user_id == %@ AND is_group == %@ AND chat_id == %@ AND type IN {'[Picture]', '[Gif]'}", "\(Key.shared.user_id)", intIsGroup, strChatId).sorted(byKeyPath: "index")
            for msg in allMessage {
                let photo = SKPhoto.photoWithRealmMessage(msg)
                images.append(photo)
            }
            let index = allMessage.index(where: { $0.index == realmMessage.index })
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(index ?? 0)
            present(browser, animated: true, completion: nil)
        case "[Video]":
            if let mediaItem = faeMessage.media as? JSQVideoMediaItemCustom {
                if let videoURL = mediaItem.fileURL {
                    let player = AVPlayer(url: videoURL)
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    //boolGoToFullContent = true
                    present(playerController, animated: true) {
                        player.play()
                    }
                }
            }
        case "[Location]":
            var arrControllers = navigationController?.viewControllers
            if let controller = Key.shared.FMVCtrler {
                controller.arrCtrlers = arrControllers!
                controller.boolFromMap = false
            }
            while !(arrControllers?.last is InitialPageController) {
                arrControllers?.removeLast()
            }
            let strLocDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
            let jsonLocDetail = JSON(data: strLocDetail.data(using: .utf8)!)
            //let vcLocDetail = LocDetailViewController()
            let coordinate = CLLocationCoordinate2D(latitude: Double(jsonLocDetail["latitude"].stringValue)!, longitude: Double(jsonLocDetail["longitude"].stringValue)!)
            mapDelegate?.jumpToViewLocation(coordinate: coordinate, created: false)
            navigationController?.setViewControllers(arrControllers!, animated: true)
            
            // TODO: capital first letter
            /*self.vcLocDetail.strLocName = jsonLocDetail["address1"].stringValue
             self.vcLocDetail.strLocAddr = jsonLocDetail["address2"].stringValue + ", " + jsonLocDetail["address3"].stringValue
             navigationController?.pushViewController(self.vcLocDetail, animated: true)*/
        case "[Place]":
            let strPlaceDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
            let dataPlace = strPlaceDetail.data(using: .utf8)
            let jsonPlace = JSON(data: dataPlace!)
            FaeMap().getPin(type: "place", pinId: jsonPlace["id"].stringValue) { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    guard let placeInfo = message else { return }
                    let jsonPlace = JSON(placeInfo)
                    let vcPlaceDetail = PlaceDetailViewController()
                    vcPlaceDetail.place = PlacePin(json: jsonPlace)
                    self.navigationController?.pushViewController(vcPlaceDetail, animated: true)
                }
            }
        case "[Collection]":
            let strCollectionDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
            let dataCollection = strCollectionDetail.data(using: .utf8)
            let jsonCollection = JSON(data: dataCollection!)
            let vcCollection = CollectionsListDetailViewController()
            vcCollection.enterMode = .place
            vcCollection.boolFromChat = true
            vcCollection.colId = jsonCollection["id"].intValue
            navigationController?.pushViewController(vcCollection, animated: true)
            
            //            FaeCollection().getOneCollection(jsonCollection["id"].stringValue, completion: { (status: Int, message: Any?) in
            //                if status / 100 == 2 {
            //                    let resultJson = JSON(message!)
            //                    let collectionDetail = PinCollection(json: resultJson)
            //                    //let vcCollection = CollectionsListDetailViewController()
            //                    // TODO VICKY
            ////                    self.vcCollection.arrColDetails = collectionDetail
            //                    self.vcCollection.enterMode = .place
            //                    self.vcCollection.boolFromChat = true
            //                    self.vcCollection.colId = jsonCollection["id"].intValue
            //                    self.navigationController?.pushViewController(self.vcCollection, animated: true)
            //                }
        //            })
        default: break
        }
    }
    
    /// Set long press menu for cell
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        /*let JSQMessage = arrFaeMessages[indexPath.item]
        if ["[Picture]", "[Sticker]", "text"].contains(JSQMessage.messageType) {
            selectedIndexPathForMenu = indexPath
            return true
        }*/
        selectedIndexPathForMenu = indexPath
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        let faeMessage = arrFaeMessages[indexPath.item]
        if action == #selector(copy(_:)) {
            felixprint("copy")
            UIPasteboard.general.string = faeMessage.text
        }
        if action == #selector(delete(_:)) {
            felixprint("delete")
            let realm = try! Realm()
            if let messageRealm = realm.filterMessage(faeMessage.messageId) {
                try! realm.write {
                    realm.delete(messageRealm)
                }
            }
            arrFaeMessages = arrFaeMessages.filter { $0.messageId != faeMessage.messageId }
            collectionView.deleteItems(at: [indexPath])
            collectionView.collectionViewLayout.invalidateLayout()
        }
        if action.description == "favoriteSticker:" {
            felixprint("favorite")
            let realm = try! Realm()
            if let messageRealm = realm.filterMessage(faeMessage.messageId) {
                let favoriteName = messageRealm.text
                var stickerLike: [String] = []
                if let current = FaeCoreData.shared.readByKey("stickerLike_\(Key.shared.user_id)") as? [String]{
                    stickerLike = current
                }
                if let existIndex = stickerLike.index(of: favoriteName) {
                    stickerLike.remove(at: existIndex)
                }
                stickerLike.insert(favoriteName, at: 0)
                FaeCoreData.shared.save("stickerLike_\(Key.shared.user_id)", value: stickerLike)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "favoriteSticker"), object: nil)
            }
        }
    }

    /// Called when avatar tapped
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        view.endEditing(true)
        resetToolbarButtonIcon()
        let faeMessage = arrFaeMessages[indexPath.row]
        uiviewNameCard.userId = Int(faeMessage.senderId)!
        uiviewNameCard.boolSmallSize = true
        uiviewNameCard.imgBackShadow.frame = CGRect.zero
        uiviewNameCard.show { }
    }
}

// MARK: - NameCardDelegate
extension ChatViewController: NameCardDelegate {
    func openFaeUsrInfo() {
    }
    
    func chatUser(id: Int) {
    }
    
    func reportUser(id: Int) {
        let reportPinVC = ReportViewController()
        reportPinVC.reportType = 0
        present(reportPinVC, animated: true, completion: nil)
    }
    
    func openAddFriendPage(userId: Int, status: FriendStatus) {
        let addFriendVC = AddFriendFromNameCardViewController()
        addFriendVC.delegate = uiviewNameCard
        addFriendVC.userId = userId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }    
}
