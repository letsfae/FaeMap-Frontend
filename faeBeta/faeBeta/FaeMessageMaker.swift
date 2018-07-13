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

class FaeMessage: JSQMessage {
    var messageId: String
    var messageType: String
    
    init(senderId: String, senderDisplayName: String, date: Date, messageId: String, messageType: String, text: String) {
        self.messageId = messageId
        self.messageType = messageType
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
    }
    
    init(senderId: String, senderDisplayName: String, date: Date, messageId: String, messageType: String, media: JSQMessageMediaData?) {
        self.messageId = messageId
        self.messageType = messageType
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: media)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class FaeMessageMaker {
    // MARK: - properties
    private static var senderName: String = ""
    private static var senderId: String = ""
    private static var createdAt: Date = Date()
    private static var messageId: String = ""
    private static var messageType: String = ""
    
    // MARK: - Create FaeMessage
    static func create(from realmMessage: RealmMessage, faePHAsset: FaePHAsset? = nil, complete: (() -> Void)? = nil) -> FaeMessage {
        var message: FaeMessage!
        senderName = (realmMessage.sender?.display_name)!
        senderId = (realmMessage.sender?.id)!
        createdAt = RealmChat.dateConverter(str: realmMessage.created_at)
        messageId = realmMessage.primary_key
        messageType = realmMessage.type
        switch realmMessage.type {
        case "text":
            message = textJSQMessage(realmMessage)
        case "[Picture]":
            message = pictureJSQMessage(realmMessage, faePHAsset: faePHAsset)
        case "[Video]":
            message = videoJSQMessage(realmMessage, faePHAsset: faePHAsset, complete: complete)
        case "[Audio]":
            message = audioJSQMessage(realmMessage)
        case "[Heart]":
            message = stickerJSQMessage(realmMessage)
        case "[Sticker]":
            message = stickerJSQMessage(realmMessage)
        case "[Gif]":
            message = pictureJSQMessage(realmMessage, faePHAsset: faePHAsset)
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
    private static func textJSQMessage(_ realmMessage: RealmMessage) -> FaeMessage {
        return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, text: realmMessage.text)
    }
    
    private static func pictureJSQMessage(_ realmMessage: RealmMessage, faePHAsset: FaePHAsset? = nil) -> FaeMessage {
        var imgMedia: UIImage!
        if faePHAsset != nil {
            imgMedia = faePHAsset?.thumbnailImage 
        } else {
            if realmMessage.type == "[Gif]" {
                imgMedia = UIImage.gif(data: realmMessage.media! as Data)
            } else {
                imgMedia = UIImage(data: realmMessage.media! as Data)
            }
        }
        let mediaItem = JSQPhotoMediaItemCustom(image: imgMedia)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = isOutgoingMessage(senderId)
        
        return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, media: mediaItem)
    }
    
    private static func videoJSQMessage(_ realmMessage: RealmMessage, faePHAsset: FaePHAsset? = nil, complete: (() -> Void)? = nil) -> FaeMessage {
        let fileManager = FileManager.default
        var snapImage = UIImage()
        let duration = realmMessage.text
        let mediaItem = JSQVideoMediaItemCustom(fileURL: URL(string: ""), snapImage: snapImage, duration: Int32(Double(duration)!), isReadyToPlay: false)
        mediaItem?.appliesMediaViewMaskAsOutgoing = isOutgoingMessage(senderId)
        if faePHAsset != nil {
            if faePHAsset?.phAsset == nil, let url = faePHAsset?.localURL {
                let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
                generator.appliesPreferredTrackTransform = true
                var cgImage: CGImage?
                do {
                    cgImage = try generator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                } catch let error as NSError {
                    // Handle the error
                    print(error)
                }
                mediaItem?.snapImage = cgImage != nil ? UIImage(cgImage: cgImage!) : UIImage()
                mediaItem?.fileURL = url
                mediaItem?.isReadyToPlay = true
            } else {
                mediaItem?.snapImage = faePHAsset?.thumbnailImage ?? UIImage()
            }
            return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, media: mediaItem)
        }
        var writeURL: URL? = nil
        if #available(iOS 10.0, *) {
            writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(realmMessage.primary_key).mov")
        } else {
            writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(realmMessage.primary_key).mov")
        }
        
        func writeDataToDisk(complete: @escaping (() -> Void)) {
            let msgKey = realmMessage.primary_key
            DispatchQueue.global(qos: .background).async {
                do {
                    let realm = try! Realm()
                    if let message = realm.filterMessage(msgKey) {
                        try message.media?.write(to: writeURL!, options: [.atomic])
                    }
                } catch {
                    // fail to write to document folder
                    // local disk is full
                }
                complete()
            }
        }
        
        func captureSnapImage(complete: @escaping (() -> Void)) {
            let generator = AVAssetImageGenerator(asset: AVURLAsset(url: writeURL!))
            var times = [NSValue]()
            times.append(NSValue(time: CMTime(seconds: 0.0, preferredTimescale: 1)))
            generator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, cgImage, actualTime, result, error) in
                if result == .succeeded, let img = cgImage {
                    snapImage = UIImage(cgImage: img)
                    complete()
                } else {
                    // TODO: handle error
                }
            }
        }
        
        if !FileManager.default.fileExists(atPath: writeURL!.absoluteString) {
            writeDataToDisk {
                mediaItem?.fileURL = writeURL!
                captureSnapImage() {
                    mediaItem?.snapImage = snapImage
                    mediaItem?.isReadyToPlay = true
                    complete?()
                }
            }
        } else {
            mediaItem?.fileURL = writeURL!
            captureSnapImage() {
                mediaItem?.snapImage = snapImage
                mediaItem?.isReadyToPlay = true
                complete?()
            }
        }
        
        return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, media: mediaItem)
    }
    
    private static func audioJSQMessage(_ realmMessage: RealmMessage) -> FaeMessage {
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
        return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, media: mediaItem)
    }
    
    private static func stickerJSQMessage(_ realmMessage: RealmMessage) -> FaeMessage {
        let imgSticker = UIImage(named: realmMessage.text)
        let mediaItem = JSQStickerMediaItem(image: imgSticker)
        if realmMessage.sender?.id != "\(Key.shared.user_id)" {
            mediaItem?.boolIncoming = true
        }
        if realmMessage.type == "[Heart]" {
            mediaItem?.sizeCustomize = CGSize(width: 61, height: 50)
        }
        mediaItem?.appliesMediaViewMaskAsOutgoing = isOutgoingMessage(senderId)
        return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, media: mediaItem)
    }
    
    private static func locationJSQMessage(_ realmMessage: RealmMessage) -> FaeMessage {
        let strLocDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
        var mediaItem: JSQLocationMediaItemCustom
        let data = strLocDetail.data(using: .utf8)
        var jsonLoc: JSON!
        do {
            jsonLoc = try JSON(data: data!)
        } catch {
            print("JSON Error: \(error)")
        }
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
        return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, media: mediaItem)
    }
    
    private static func placeJSQMessage(_ realmMessage: RealmMessage) -> FaeMessage {
        let strPlaceDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
        let dataPlace = strPlaceDetail.data(using: .utf8)
        var jsonPlace: JSON!
        do {
            jsonPlace = try JSON(data: dataPlace!)
        } catch {
            print("JSON Error: \(error)")
        }
        var snapImage = UIImage(named: "default_place")
        if let media = realmMessage.media {
            snapImage = UIImage(data: media as Data)
        }
        let mediaItem = JSQPlaceCollectionMediaItemCustom(itemID: jsonPlace["id"].intValue, type: "place", snapImage: snapImage, text: jsonPlace["comment"].stringValue)
        mediaItem?.title = jsonPlace["name"].stringValue
        mediaItem?.subtitle = jsonPlace["address"].stringValue
        return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, media: mediaItem)
    }
    
    private static func collectionJSQMessage(_ realmMessage: RealmMessage) -> FaeMessage {
        let strCollectionDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
        let dataCollection = strCollectionDetail.data(using: .utf8)
        var jsonCollection: JSON!
        do {
            jsonCollection = try JSON(data: dataCollection!)
        } catch {
            print("JSON Error: \(error)")
        }
        let snapImage = UIImage(named: "defaultPlaceIcon")
        let mediaItem = JSQPlaceCollectionMediaItemCustom(itemID: jsonCollection["id"].intValue, type: "collection", snapImage: snapImage, text: jsonCollection["comment"].stringValue)
        mediaItem?.title = jsonCollection["name"].stringValue
        mediaItem?.subtitle = jsonCollection["count"].stringValue + " items"
        return FaeMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, messageId: messageId, messageType: messageType, media: mediaItem)
    }
    
    private static func isOutgoingMessage(_ senderId : String) -> Bool {
        return senderId == "\(Key.shared.user_id)"
    }
}

extension UIImage {
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
        
        return cropped
    }
}
