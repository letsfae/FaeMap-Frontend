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
    var senderId: String = ""
    private var createdAt: Date = Date()
    
    //MARK: - init
    init(collectionView_ : JSQMessagesCollectionViewCustom) {
        collectionView = collectionView_
    }
    
    func createJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
        var message: JSQMessage!
        senderName = (realmMessage.sender?.display_name)!
        senderId = (realmMessage.sender?.id)!
        //createdAt = dateFormatter().date(from: realmMessage.created_at)!
        createdAt = RealmChat.dateConverter(str: realmMessage.created_at)
        switch realmMessage.type {
        case "text":
            message = textJSQMessage(realmMessage)
            break
        case "[Picture]":
            message = pictureJSQMessage(realmMessage)
            break
        case "[Video]":
            message = videoJSQMessage(realmMessage)
            break
        case "[Audio]":
            message = audioJSQMessage(realmMessage)
            break
        case "[Heart]":
            message = stickerJSQMessage(realmMessage)
            break
        case "[Sticker]":
            message = stickerJSQMessage(realmMessage)
            break
        case "[Gif]":
            message = pictureJSQMessage(realmMessage)
            break
        case "[Location]":
            message = locationJSQMessage(realmMessage)
            break
        case "[Place]":
            message = placeJSQMessage(realmMessage)
            break
        case "[Collection]":
            message = collectionJSQMessage(realmMessage)
            break
        default:
            message = textJSQMessage(realmMessage)
            break
        }
        return message
    }
    
    fileprivate func textJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
        let content = realmMessage.text
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, text: content)
    }
    
    fileprivate func pictureJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
        let imgPic = UIImage(data: realmMessage.media! as Data)
        let mediaItem = JSQPhotoMediaItemCustom(image: imgPic)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId)
        
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    fileprivate func videoJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
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
        let mediaItem = JSQVideoMediaItemCustom(fileURL: URL(fileURLWithPath: fileURL), snapImage: snapImage, duration: Int32(duration)!, isReadyToPlay: true)
         mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    fileprivate func audioJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
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
    
    fileprivate func stickerJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
        let imgSticker = UIImage(named: realmMessage.text)
        let mediaItem = JSQStickerMediaItem(image: imgSticker)
        if realmMessage.type == "[Heart]" {
            mediaItem?.sizeCustomize = CGSize(width: 61, height: 50)
        }
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    fileprivate func locationJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
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
        mediaItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId)
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem)
    }
    
    fileprivate func placeJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
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
    
    fileprivate func collectionJSQMessage(_ realmMessage: RealmMessage_v2) -> JSQMessage {
        let strCollectionDetail = realmMessage.text.replacingOccurrences(of: "\\", with: "")
        let dataCollection = strCollectionDetail.data(using: .utf8)
        let jsonCollection = JSON(data: dataCollection!)
        let snapImage = UIImage(named: "defaultPlaceIcon")
        let mediaItem = JSQPlaceCollectionMediaItemCustom(itemID: jsonCollection["id"].intValue, type: "collection", snapImage: snapImage, text: jsonCollection["comment"].stringValue)
        mediaItem?.title = jsonCollection["name"].stringValue
        mediaItem?.subtitle = jsonCollection["count"].stringValue + " items"
        return JSQMessage(senderId: senderId, senderDisplayName: senderName, date: createdAt, media: mediaItem!)
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
            //message = createPlaceMessage(dictionary)
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
    
    /*private func createPlaceMessage(_ item : NSDictionary) -> JSQMessage {
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
            mediaItem?.cachedSnapshotImage = image
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }*/
    
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
    fileprivate func imageFromData_v2(_ realmMessage: RealmMessage_v2, result: (_ image : UIImage?) -> Void) {
        var image : UIImage?
        if let decodedData = realmMessage.media {
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
        let filePath = self.documentsPathForFileName("/\(str!.substring(with: str!.index(str!.endIndex, offsetBy: -33) ..< str!.index(str!.endIndex, offsetBy: -1)))).mov")

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            let videoFileURL = URL(fileURLWithPath: filePath)
            result(videoFileURL)
        } else {
            if let decodedData = Data(base64Encoded: str!, options: NSData.Base64DecodingOptions(rawValue : 0)) {
                if str!.count > 50 {
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
