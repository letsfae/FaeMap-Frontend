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

extension ChatViewController {
    // MARK: - collection view delegate
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCellCustom
        let JSQMessage = arrJSQMessages[indexPath.row]        
        if JSQMessage.senderId == "\(Key.shared.user_id)" {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor._107105105()
        }
        cell.textView?.font = UIFont(name: "Avenir Next", size: 17.5)
        cell.avatarImageView.layer.cornerRadius = 19.5
        cell.avatarImageView.contentMode = .scaleAspectFill
        cell.avatarImageView.layer.masksToBounds = true
        let index = resultRealmMessages.count - (arrJSQMessages.count - indexPath.row)
        let realmMessage = resultRealmMessages[index]
        switch realmMessage.type {
            case "text":
                cell.contentType = Text
            case "[Picture]":
                cell.contentType = Picture
            case "[Sticker]":
                cell.contentType = Sticker
            case "[Location]":
                cell.contentType = Location
            case "[Place]":
                cell.contentType = Place
            case "[Collection]":
                cell.contentType = Collection
            case "[Audio]":
                cell.contentType = Audio
                let JSQMessage = arrJSQMessages[indexPath.row]
                if let message = JSQMessage.media as? JSQAudioMediaItemCustom {
                    message.delegate = self
                }
            case "[Video]":
                cell.contentType = Video
                let JSQMessage = arrJSQMessages[indexPath.row]
                if let message = JSQMessage.media as? JSQVideoMediaItemCustom {
                    if let sender = realmMessage.sender, sender.id == "\(Key.shared.user_id)" {
                        if realmMessage.upload_to_server {
                            message.stopAnimating()
                        } else {
                            message.startAnimating()
                        }
                    }
                }
            default: // unknown type
                cell.contentType = Text
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == arrJSQMessages.count - 1, let message = resultRealmMessages.last {
            if message.sender?.id != "\(Key.shared.user_id)" || message.type != "[Heart]" {
                boolJustSentHeart = false
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return arrJSQMessages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrJSQMessages.count
    }
    
    // this delegate is used to tell which bubble image should be used on current message
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        var outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "bubble2"), capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).outgoingMessagesBubbleImage(with: UIColor._2499090())
        let message = arrJSQMessages[indexPath.row]
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
    
    // this is used to edit top label of every cell
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = arrJSQMessages[indexPath.row]
        if indexPath.row == 0 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        } else {
            let prevMessage = arrJSQMessages[indexPath.row - 1]
            if message.date.timeIntervalSince(prevMessage.date) / 60 > 3 {
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
            }
        }
        return nil
    }
    
    //this is to modify the label height
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayoutCustom!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = arrJSQMessages[indexPath.row]
        if indexPath.row == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            let prevMessage = arrJSQMessages[indexPath.row - 1]
            if message.date.timeIntervalSince(prevMessage.date) / 60 > 3 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayoutCustom!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0.0
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return NSAttributedString(string: "")
    }
    
    // bind avatar image
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = arrJSQMessages[indexPath.row]
        let avatar = avatarDictionary.object(forKey: message.senderId) as! JSQMessageAvatarImageDataSource
        return avatar 
    }
    
    // delegate when user tap the bubble, like image, location
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if inputToolbar.frame.minY > screenHeight - floatInputBarHeight {
            closeToolbarContentView()
        }
        floatContentOffsetY = collectionView.contentOffset.y
        let index = resultRealmMessages.count - (arrJSQMessages.count - indexPath.row)
        let message = resultRealmMessages[index]
        switch message.type {
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
            //let realmMessage = arrRealmMessages[indexPath.row]
            var images = [SKPhoto]()
            let realm = try! Realm()
            let allMessage = realm.objects(RealmMessage.self).filter("login_user_id == %@ AND is_group == %@ AND chat_id == %@ AND type IN {'[Picture]', '[Gif]'}", "\(Key.shared.user_id)", intIsGroup, strChatId).sorted(byKeyPath: "index")
            for msg in allMessage {
                let photo = SKPhoto.photoWithRealmMessage(msg)
                images.append(photo)
            }
            let index = allMessage.index(where: { $0.index == message.index })
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(index ?? 0)
            present(browser, animated: true, completion: nil)
        case "[Video]":
            let messageJSQ = arrJSQMessages[indexPath.row]
            if let mediaItem = messageJSQ.media as? JSQVideoMediaItemCustom {
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
            let strLocDetail = message.text.replacingOccurrences(of: "\\", with: "")
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
            let strPlaceDetail = message.text.replacingOccurrences(of: "\\", with: "")
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
            let strCollectionDetail = message.text.replacingOccurrences(of: "\\", with: "")
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
    
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        let index = resultRealmMessages.count - (arrJSQMessages.count - indexPath.row)
        let message = resultRealmMessages[index]
        if ["[Picture]", "[Sticker]", "text"].contains(message.type) {
            selectedIndexPathForMenu = indexPath
            return true
        }
        return false
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        view.endEditing(true)
        resetToolbarButtonIcon()
        let messageJSQ = arrJSQMessages[indexPath.row]
        uiviewNameCard.userId = Int(messageJSQ.senderId)!
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
