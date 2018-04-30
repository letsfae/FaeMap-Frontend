//
//  JSQMessageMaker.swift
//  quickChat
//
//  Created by User on 6/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class JSQMessageMaker {
    // MARK: - properties
    private static var senderName: String = ""
    private static var senderId: String = ""
    private static var createdAt: Date = Date()
    
    // MARK: - Create JSQMessage
    static func create(from realmMessage: RealmMessage) -> JSQMessage {
        var message: JSQMessage!
        senderName = (realmMessage.sender?.display_name)!
        senderId = (realmMessage.sender?.id)!
        createdAt = RealmChat.dateConverter(str: realmMessage.created_at)
        switch realmMessage.type {
        case "text":
            message = textJSQMessage(realmMessage)
        case "[Picture]":
            message = pictureJSQMessage(realmMessage)
        case "[Video]":
            message = videoJSQMessage(realmMessage)
        case "[Audio]":
            message = audioJSQMessage(realmMessage)
        case "[Heart]":
            message = stickerJSQMessage(realmMessage)
        case "[Sticker]":
            message = stickerJSQMessage(realmMessage)
        case "[Gif]":
            message = pictureJSQMessage(realmMessage)
        case "[Location]":
            message = locationJSQMessage(realmMessage)
        case "[Place]":
            message = placeJSQMessage(realmMessage)
        case "[Collection]":
            message = collectionJSQMessage(realmMessage)
        default:
            message = textJSQMessage(realmMessage)
        }
        return message
    }
    
    // MARK: - Helper methods for different types
    private static func textJSQMessage(_ realmMessage: RealmMessage) -> JSQMessage {
        let content = realmMessage.text
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, text: content)
    }
    
    private static func pictureJSQMessage(_ realmMessage: RealmMessage) -> JSQMessage {
        var imgMedia: UIImage!
        if realmMessage.type == "[Gif]" {
            imgMedia = UIImage.gif(data: realmMessage.media! as Data)
        } else {
            imgMedia = UIImage(data: realmMessage.media! as Data)
        }
        let mediaItem = JSQPhotoMediaItemCustom(image: imgMedia)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = isOutgoingMessage(senderId)
        
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    private static func videoJSQMessage(_ realmMessage: RealmMessage) -> JSQMessage {
        let tempPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let fileURL = tempPath + "/" + realmMessage.primary_key + ".mov"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL) {
            do {
                try realmMessage.media?.write(to: URL(fileURLWithPath: fileURL), options: [.atomic])
            } catch {
                // fail to write to document folder
                // local disk is full
            }
        }
        let asset = AVURLAsset(url: URL(fileURLWithPath: fileURL))
        let duration = realmMessage.text
        var snapImage = UIImage()
        do {
            let imgRef = try AVAssetImageGenerator(asset: asset).copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 1), actualTime: nil)
            snapImage = UIImage(cgImage: imgRef)
        } catch {
            // fail to get snap image
        }
        let mediaItem = JSQVideoMediaItemCustom(fileURL: URL(fileURLWithPath: fileURL), snapImage: snapImage, duration: Int32(Double(duration)!), isReadyToPlay: true)
         mediaItem?.appliesMediaViewMaskAsOutgoing = isOutgoingMessage(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    private static func audioJSQMessage(_ realmMessage: RealmMessage) -> JSQMessage {
        let isOutGoingMessage = senderId == "\(Key.shared.user_id)"
        let options: AVAudioSessionCategoryOptions = [AVAudioSessionCategoryOptions.duckOthers, AVAudioSessionCategoryOptions.defaultToSpeaker,AVAudioSessionCategoryOptions.allowBluetooth]
        let font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        let attribute = JSQAudioMediaViewAttributesCustom(
            playButtonImage: UIImage(named: isOutGoingMessage ? "playButton_white.png" : "playButton_red.png")!,
            pauseButtonImage: UIImage(named: isOutGoingMessage ? "pauseButton_white.png" : "pauseButton_red.png")!,
            label: font!,
            showFractionalSecodns: false,
            backgroundColor: isOutGoingMessage ? UIColor._2499090() : UIColor.white,
            tintColor: isOutGoingMessage ? UIColor.white : UIColor._2499090(),
            controlInsets: UIEdgeInsetsMake(7, 12, 3, 14),
            controlPadding: 5,
            audioCategory: "AVAudioSessionCategoryPlayback",
            audioCategoryOptions: options)
        //let mediaItem = JSQAudioMediaItemCustom(audioViewAttributes: attribute)
        
        //mediaItem.audioData = realmMessage.media! as Data
        let mediaItem = JSQAudioMediaItemCustom(data: realmMessage.media! as Data, audioViewAttributes: attribute)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    private static func stickerJSQMessage(_ realmMessage: RealmMessage) -> JSQMessage {
        let imgSticker = UIImage(named: realmMessage.text)
        let mediaItem = JSQStickerMediaItem(image: imgSticker)
        if realmMessage.sender?.id != "\(Key.shared.user_id)" {
            mediaItem?.boolIncoming = true
        }
        if realmMessage.type == "[Heart]" {
            mediaItem?.sizeCustomize = CGSize(width: 61, height: 50)
        }
        mediaItem?.appliesMediaViewMaskAsOutgoing = isOutgoingMessage(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    private static func locationJSQMessage(_ realmMessage: RealmMessage) -> JSQMessage {
        let strLocDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
        var mediaItem: JSQLocationMediaItemCustom
        let data = strLocDetail.data(using: .utf8)
        let jsonLoc = JSON(data: data!)
        let clLoc = CLLocation(latitude: Double(jsonLoc["latitude"].stringValue)!, longitude: Double(jsonLoc["longitude"].stringValue)!)
        var snapImage: UIImage!
        if let nsdata = realmMessage.media {
            snapImage = UIImage(data: nsdata as Data)
        } else {
            snapImage = UIImage(named: "collection_locations")
        }
        var comment = ""
        if let comm = jsonLoc["comment"].string {
            comment = comm
        }
        mediaItem = JSQLocationMediaItemCustom(location: clLoc, snapImage: snapImage, text: comment)
        mediaItem.address1 = jsonLoc["address1"].stringValue.trimmingCharacters(in: .whitespaces)
        mediaItem.address2 = jsonLoc["address2"].stringValue.trimmingCharacters(in: .whitespaces)
        mediaItem.address3 = jsonLoc["address3"].stringValue.trimmingCharacters(in: .whitespaces)
        mediaItem.appliesMediaViewMaskAsOutgoing = isOutgoingMessage(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    private static func placeJSQMessage(_ realmMessage: RealmMessage) -> JSQMessage {
        let strPlaceDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
        let dataPlace = strPlaceDetail.data(using: .utf8)
        let jsonPlace = JSON(data: dataPlace!)
        var snapImage = UIImage(named: "place_result_48")
        if let media = realmMessage.media {
            snapImage = UIImage(data: media as Data)
        }
        let mediaItem = JSQPlaceCollectionMediaItemCustom(itemID: jsonPlace["id"].intValue, type: "place", snapImage: snapImage, text: jsonPlace["comment"].stringValue)
        mediaItem?.title = jsonPlace["name"].stringValue
        mediaItem?.subtitle = jsonPlace["address"].stringValue
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem!)
    }
    
    private static func collectionJSQMessage(_ realmMessage: RealmMessage) -> JSQMessage {
        let strCollectionDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
        let dataCollection = strCollectionDetail.data(using: .utf8)
        let jsonCollection = JSON(data: dataCollection!)
        let snapImage = UIImage(named: "defaultPlaceIcon")
        let mediaItem = JSQPlaceCollectionMediaItemCustom(itemID: jsonCollection["id"].intValue, type: "collection", snapImage: snapImage, text: jsonCollection["comment"].stringValue)
        mediaItem?.title = jsonCollection["name"].stringValue
        mediaItem?.subtitle = jsonCollection["count"].stringValue + " items"
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem!)
    }
    
    private static func isOutgoingMessage(_ senderId : String) -> Bool {
        return senderId == "\(Key.shared.user_id)"
    }
}
