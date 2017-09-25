//
//  IncomingMessage.swift
//  quickChat
//
//  Created by User on 6/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import SwiftyJSON
import RealmSwift

// this class is used to create JSQMessage object from information in firebase, it can be message from current user
// or the other user who current user are chatting with.

class IncomingMessage {
    
    //MARK: - properties
    private var collectionView : JSQMessagesCollectionViewCustom
    private var senderName: String = ""
    private var senderId: String = ""
    private var createdAt: Date = Date()
    
    //MARK: - init
    init(collectionView_ : JSQMessagesCollectionViewCustom) {
        collectionView = collectionView_
    }
    
    func createJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        var message: JSQMessage!
        senderName = (reamlMessage.sender?.display_name)!
        senderId = (reamlMessage.sender?.id)!
        createdAt = dateFormatter().date(from: reamlMessage.created_at)!
        switch reamlMessage.type {
        case "text":
            message = textJSQMessage(reamlMessage)
            break
        case "[Picture]":
            message = pictureJSQMessage(reamlMessage)
            break
        case "[Video]":
            message = videoJSQMessage(reamlMessage)
            break
        case "[Audio]":
            message = audioJSQMessage(reamlMessage)
            break
        case "[Heart]":
            message = stickerJSQMessage(reamlMessage)
            break
        case "[Sticker]":
            message = stickerJSQMessage(reamlMessage)
            break
        case "[Gif]":
            message = pictureJSQMessage(reamlMessage)
            break
        case "[Location]":
            message = locationJSQMessage(reamlMessage)
            break
        case "[Place]":
            message = placeJSQMessage(reamlMessage)
            break
        case "[Collection]":
            message = collectionJSQMessage(reamlMessage)
            break
        default:
            message = textJSQMessage(reamlMessage)
            break
        }
        return message
    }
    
    fileprivate func textJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        let content = reamlMessage.text
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, text: content)
    }
    
    fileprivate func pictureJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        let imgPic = UIImage(data: reamlMessage.media! as Data)
        let mediaItem = JSQPhotoMediaItemCustom(image: imgPic)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId)
        
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    fileprivate func videoJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        let boolLocalized: Bool = reamlMessage.text != "[Video]"
        var fileURL = ""
        let realm = try! Realm()
        if !boolLocalized {
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            fileURL = documentPath + "/" + reamlMessage.loginUserID_chatID_index + ".mov"
            do {
                try reamlMessage.media?.write(to: URL(fileURLWithPath: fileURL), options: [.atomic])
                realm.beginWrite()
                reamlMessage.text = fileURL
            } catch {
                // fail to write to document folder
                // local disk is full
            }
        } else {
            fileURL = reamlMessage.text
        }
        let asset = AVURLAsset(url: URL(fileURLWithPath: fileURL))
        let duration = CMTimeGetSeconds(asset.duration)
        var time = asset.duration
        time.value = 0
        var snapImage = UIImage()
        if !boolLocalized {
            do {
                let imgRef = try AVAssetImageGenerator(asset: asset).copyCGImage(at: time, actualTime: nil)
                snapImage = UIImage(cgImage: imgRef)
                reamlMessage.media = RealmChat.compressImageToData(snapImage)! as NSData
                try! realm.commitWrite()
            } catch {
                // fail to get snap image
            }
        } else {
            snapImage = UIImage(data: reamlMessage.media! as Data)!
        }
        let mediaItem = JSQVideoMediaItemCustom(fileURL: URL(fileURLWithPath: fileURL), snapImage: snapImage, duration: Int32(duration), isReadyToPlay: true)
         mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    fileprivate func audioJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
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
        let mediaItem = JSQAudioMediaItemCustom(audioViewAttributes: attribute)
        
        mediaItem.audioData = reamlMessage.media! as Data
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    fileprivate func stickerJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        let imgSticker = UIImage(named: reamlMessage.text)
        let mediaItem = JSQStickerMediaItem(image: imgSticker)
        if reamlMessage.type == "[Heart]" {
            mediaItem?.sizeCustomize = CGSize(width: 65, height: 44)
        }
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    fileprivate func gifJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        let content = reamlMessage.text
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, text: content)
    }
    
    fileprivate func locationJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        let strLocDetail = reamlMessage.text.replacingOccurrences(of: "\\", with: "")
        var mediaItem: JSQLocationMediaItemCustom
        let data = strLocDetail.data(using: .utf8)
        //if let dataFromStr = strLocDetail.data(using: .utf8, allowLossyConversion: false) {
        let jsonLoc = JSON(data: data!)
        let clLoc = CLLocation(latitude: Double(jsonLoc["latitude"].stringValue)!, longitude: Double(jsonLoc["longitude"].stringValue)!)
        let snapImage = UIImage(data: reamlMessage.media! as Data)
        var comment = ""
        if let comm = jsonLoc["comment"].string {
            comment = comm
        }
        mediaItem = JSQLocationMediaItemCustom(location: clLoc, snapImage: snapImage, text: comment)
        mediaItem.address1 = jsonLoc["address1"].stringValue
        mediaItem.address2 = jsonLoc["address2"].stringValue
        mediaItem.address3 = jsonLoc["address3"].stringValue
        mediaItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
        //}
        //return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, text: reamlMessage.type)
    }
    
    fileprivate func placeJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        let content = reamlMessage.text
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, text: content)
    }
    
    fileprivate func collectionJSQMessage(_ reamlMessage: RealmMessage_v2) -> JSQMessage {
        let content = reamlMessage.text
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, text: content)
    }
    
    //MARK: - create messages
    func createMessage(_ dictionary : NSDictionary) -> JSQMessage? {
        var message : JSQMessage?
        let type = dictionary["type"] as? String
        
        if type == "text" {
            //create text message
            message = createTextMessage(dictionary)
        }
        
        if type == "location" {
            //create locaiton message
            message = createLocationMessage(dictionary)
        }
        
        if type == "place" {
            message = createPlaceMessage(dictionary)
        }
        
        if type == "picture" {
            //create pitcute message
            message = createPictureMessage(dictionary)
        }
        
        if type == "audio" {
            message = createAudioMessage(dictionary)
        }
        
        if type == "sticker" {
            message = createStickerMessage(dictionary)
        }
        
        if type == "video" {
            message = createVideoMessage(dictionary)
        }
        
        if type == "gif"{
            message = createGifMessage(dictionary)
        }
        
        if type != nil && message == nil
        {
            dictionary.setValue("[Current version does not support this message type, please update your app!]", forKey: "message")
            message = createTextMessage(dictionary)
        }
        
        if let mes = message {
            return mes
        } else {
            return nil
        }
    }
    
    private func createTextMessage(_ item : NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        let text = item["message"] as? String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
    private func createLocationMessage(_ item : NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        
        let latitude = item["latitude"] as? Double
        let longitude = item["longitude"] as? Double
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        //var mediaItem = JSQLocationMediaItemCustom(location: location, snapImage: nil)
        
        //if let comment = item["message"] as? String {
        let comment = item["message"] as? String
        let mediaItem = JSQLocationMediaItemCustom(location: location, snapImage: nil, text: comment)
        //}
        
        //init?
        
        if(mediaItem!.addressLine1 == nil) {
            print("addressLine 1 is nil")
        }
        print(mediaItem!)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            if error == nil {
                guard let addr = placemarks?[0] else { return }
                mediaItem?.addressLine1.text = (addr.subThoroughfare! + " " + addr.thoroughfare!).uppercased()
                var cityText = addr.locality
                if(addr.administrativeArea != nil) {
                    cityText = cityText! + ", " + addr.administrativeArea!
                }
                if(addr.postalCode != nil) {
                    cityText = cityText! + " " + addr.postalCode!
                }
                mediaItem?.addressLine2.text = cityText?.uppercased()
                mediaItem?.addressLine3.text = addr.country?.uppercased()
                
                mediaItem?.address1 = mediaItem?.addressLine1.text?.uppercased()
                mediaItem?.address2 = mediaItem?.addressLine2.text?.uppercased()
                mediaItem?.address3 = mediaItem?.addressLine3.text?.uppercased()
            } else {
                print("error when fetching address")
            }
        })
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)

        self.snapShotFromData(item) { (image) in
            mediaItem?.cachedMapSnapshotImage = image
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    private func createPlaceMessage(_ item : NSDictionary) -> JSQMessage {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        
        let placeString = item["place"] as? String
        let place = PlacePin(string: placeString!.replacingOccurrences(of: "\\", with: ""))
        
        let comment = item["message"] as? String
        
        let mediaItem = JSQPlaceMediaItemCustom(place: place, snapImage: nil, text: comment)
        //let mediaItem = JSQPhotoMediaItemCustom(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        self.snapShotFromData(item) { (image) in
            mediaItem?.cachedPlaceSnapshotImage = image
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    private func createPictureMessage(_ item : NSDictionary) -> JSQMessage {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        
        let mediaItem = JSQPhotoMediaItemCustom(image: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image) in
            mediaItem?.image = image
            //self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    private func createGifMessage(_ item : NSDictionary) -> JSQMessage {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        
        let mediaItem = JSQPhotoMediaItemCustom(image: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        gifFromData(item) { (image) in
            mediaItem?.image = image
            self.collectionView.reloadData()
        }

        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    // create incoming audio message
    private func createAudioMessage(_ item : NSDictionary) -> JSQMessage {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        
        let isOutGoingMessage = userId! == "\(Key.shared.user_id)"
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
        let mediaItem = JSQAudioMediaItemCustom(audioViewAttributes: attribute)
        
        voiceFromData(item) { (voiceData) in
            mediaItem.audioData = voiceData
            self.collectionView.reloadData()
        }
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }

    private func createVideoMessage(_ item : NSDictionary) -> JSQMessage {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        let image = item["snapImage"] as? UIImage
        var duration = 0
        if item["videoDuration"] != nil {
            duration = item["videoDuration"] as! Int
        }
        let mediaItem = JSQVideoMediaItemCustom(fileURL:URL(string:""), snapImage:image, duration:Int32(duration), isReadyToPlay:true)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)

        videoFromData(item) { (videoURL) in
            self.snapShotFromData(item) { (image) in
                mediaItem?.fileURL = videoURL!
                mediaItem?.snapImage = image

                self.collectionView.reloadData()
            }

        }
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }

    private func createStickerMessage(_ item : NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        
        let mediaItem = JSQStickerMediaItem(image: nil)
        
        if let isHeartSticker = item["isHeartSticker"] as? Bool {
            if isHeartSticker {
                mediaItem?.sizeCustomize = CGSize(width: 65, height: 44)
            }
        }
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image) in
            mediaItem?.image = image
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
        
    }
    
    //MARK: - abstract m	edia from data
    fileprivate func imageFromData_v2(_ reamlMessage: RealmMessage_v2, result: (_ image : UIImage?) -> Void) {
        var image : UIImage?
        if let decodedData = reamlMessage.media {
            image = UIImage(data: decodedData as Data)
            result(image)
        }
    }
    
    private func imageFromData(_ item : NSDictionary, result : (_ image : UIImage?) -> Void) {
        var image : UIImage?
        
        if let decodedData = Data(base64Encoded: (item["data"] as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0)) {
        
            image = UIImage(data: decodedData)
            result(image)
        }
    }
        
    private func gifFromData(_ item : NSDictionary, result : (_ image : UIImage?) -> Void) {
        var image : UIImage?
        
        if let decodedData = Data(base64Encoded: (item["data"] as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0)) {
            
            image = UIImage.gif(data: decodedData)
            result(image)
        }
    }
        
    private func voiceFromData(_ item : NSDictionary, result : (_ voiceData : Data?) -> Void) {
        
        if let decodedData = Data(base64Encoded: (item["data"] as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0)){
            result(decodedData)
        }
    }
    
    private func videoFromData(_ item : NSDictionary, result : (_ videoData : URL?) -> Void) {
        let str = item["data"] as? String
        let filePath = self.documentsPathForFileName("/\(str!.substring(with: str!.characters.index(str!.endIndex, offsetBy: -33) ..< str!.characters.index(str!.endIndex, offsetBy: -1)))).mov")

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            let videoFileURL = URL(fileURLWithPath: filePath)
            result(videoFileURL)
        } else {
            if let decodedData = Data(base64Encoded: str!, options: NSData.Base64DecodingOptions(rawValue : 0)) {
                if str!.characters.count > 50 {
                    try? decodedData.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
                    
                    let videoFileURL = URL(fileURLWithPath: filePath)
                    result(videoFileURL)
                }
            }
        }
    }
    
    private func snapShotFromData(_ item : NSDictionary, result : (_ image : UIImage?) -> Void) {
        var image : UIImage?
        if let data = item["snapImage"] {
            let decodedData = Data(base64Encoded: (data as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0))
            
            image = UIImage(data: decodedData!)
            
        }
        result(image)
    }
    
    //MARK: - utilities
    
    /// return a file path string for a document
    ///
    /// - Parameter name: the name of the file
    /// - Returns: the string of the path
    private func documentsPathForFileName(_ name: String) -> String {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath + name
    }
    
    func returnOutgoingStatusFromUser(_ senderId : String) -> Bool {
        
        if senderId == "\(Key.shared.user_id)" {
            //outgoings
            return true
        } else {
            return false
        }
    }
}
