//
//  ChatViewController+collecitonView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import IDMPhotoBrowser
import Photos
import AVKit
import AVFoundation
import SwiftyJSON

extension ChatViewController {
    // MARK: - collection view delegate
    
    // JSQMessage delegate not only should handle chat bubble itself, it should handle photoQuickSelect cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCellCustom
        
        let data = arrJSQMessages[indexPath.row]
        
        if data.senderId == "\(Key.shared.user_id)" {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor._107105105()
        }
        cell.textView?.font = UIFont(name: "Avenir Next", size: 17.5)
        cell.avatarImageView.layer.cornerRadius = 19.5
        cell.avatarImageView.contentMode = .scaleAspectFill
        cell.avatarImageView.layer.masksToBounds = true
        //let object = arrDictMessages[indexPath.row]
        let index = resultRealmMessages.count - (arrJSQMessages.count - indexPath.row)
        let messageType = resultRealmMessages[index].type
        switch (messageType) {
            case "text":
                cell.contentType = Text
                break
            case "[Picture]":
                cell.contentType = Picture
                break
            case "[Sticker]":
                cell.contentType = Sticker
                break
            case "[Location]":
                cell.contentType = Location
                break
            case "[Place]":
                cell.contentType = Place
                break
            case "[Collection]":
                cell.contentType = Collection
                break
            case "[Audio]":
                cell.contentType = Audio
                let JSQMessage = arrJSQMessages[indexPath.row]
                if let message = JSQMessage.media as? JSQAudioMediaItemCustom {
                    message.delegate = self
                }
                break
            case "[Video]":
                cell.contentType = Video
            // if it's a unknow message type, display a unknow message type
            default:
                cell.contentType = Text
                break
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == arrRealmMessages.count - 1 {
            let message = arrRealmMessages[indexPath.row]
            if message.sender?.id != "\(Key.shared.user_id)" || message.type != "[Heart]" {
                boolJustSentHeart = false
            }
        }
        /*if collectionView == self.collectionView && indexPath.row == arrJSQMessages.count - 1 {
            clearRecentCounter(strChatId)
            let object = arrDictMessages[indexPath.row]

            //Do not allow user to send two heart continously
            let userId = object["senderId"] as? String
            let isOutGoingMessage = userId! == "\(Key.shared.user_id)"
            

            if object["type"] as! String == "sticker" && object["isHeartSticker"] != nil && object["isHeartSticker"] as! Bool == true && isOutGoingMessage{
                boolJustSentHeart = true
            }else{
                boolJustSentHeart = false
            }
        }*/
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return arrJSQMessages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrJSQMessages.count
    }
    
    //this delegate is used to tell which bubble image should be used on current message
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = arrJSQMessages[indexPath.row]
        
        if message.senderId == "\(Key.shared.user_id)" {
            if message.isMediaMessage {
                outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubble: UIImage(named: "avatarPlaceholder"), capInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)).outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
            }
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    //this is used to edit top label of every cell
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
        /*let message = arrDictMessages[indexPath.row]
        
        let status = message["status"] as! String
        
        if indexPath.row == arrJSQMessages.count - 1 {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }*/
        
    }
    // bind avatar image
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = arrJSQMessages[indexPath.row]
        let avatar = avatarDictionary!.object(forKey: message.senderId) as! JSQMessageAvatarImageDataSource
        return avatar 
    }
  
    
    //taped bubble
    // function when user tap the bubble, like image, location
    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if inputToolbar.frame.minY > screenHeight - floatInputBarHeight {
            closeToolbarContentView()
        }
        let message = arrRealmMessages[indexPath.row]
        if ["[Picture]", "[Gif]"].contains(message.type) {
            let photo = IDMPhoto.photos(withImages: [UIImage(data: message.media! as Data)!])
            let browser = IDMPhotoBrowser(photos: photo)
            present(browser!, animated: true, completion: nil)
        }
        if message.type == "[Video]" {
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
        }
        if message.type == "[Location]" {
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
        }
        if message.type == "[Place]" {
            let strPlaceDetail = message.text.replacingOccurrences(of: "\\", with: "")
            let dataPlace = strPlaceDetail.data(using: .utf8)
            let jsonPlace = JSON(data: dataPlace!)
            FaeMap().getPin(type: "place", pinId: jsonPlace["id"].stringValue) { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    guard let placeInfo = message else { return }
                    let jsonPlace = JSON(placeInfo)
                    //let vcPlaceDetail = PlaceDetailViewController()
                    self.vcPlaceDetail.place = PlacePin(json: jsonPlace)
                    self.navigationController?.pushViewController(self.vcPlaceDetail, animated: true)
                }
            }
        }
        // TODO JICHAO
        if message.type == "[Collection]" {
            let strCollectionDetail = message.text.replacingOccurrences(of: "\\", with: "")
            let dataCollection = strCollectionDetail.data(using: .utf8)
            let jsonCollection = JSON(data: dataCollection!)
            
            vcCollection.enterMode = .place
            vcCollection.boolFromChat = true
            vcCollection.colId = jsonCollection["id"].intValue
            navigationController?.pushViewController(self.vcCollection, animated: true)
            
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
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        let message = arrRealmMessages[indexPath.row]
        if ["[Picture]", "[Sticker]", "text"].contains(message.type) {
            selectedIndexPathForMenu = indexPath
            return true
        }
        return false
        
        /*let object = arrDictMessages[indexPath.row]
        
        if object["type"] as! String == "picture" || object["type"] as! String == "text" || object["type"] as! String == "sticker"{
            returnValue = true
        }
        self.selectedIndexPathForMenu = indexPath;*/
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionViewCustom!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        print(indexPath.row)
        let messageJSQ = arrJSQMessages[indexPath.row]
        uiviewNameCard.userId = Int(messageJSQ.senderId)!
        uiviewNameCard.boolSmallSize = true
        uiviewNameCard.imgBackShadow.frame = CGRect.zero
        uiviewNameCard.show { }
    }
}
