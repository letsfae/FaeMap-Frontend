//
//  IncomingMessage.swift
//  quickChat
//
//  Created by User on 6/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import JSQMessagesViewController

// this class is used to create JSQMessage object from information in firebase, it can be message from current user
// or the other user who current user are chatting with.

class IncomingMessage {
    
    //MARK: - properties
    private var collectionView : JSQMessagesCollectionViewCustom
    
    //MARK: - init
    init(collectionView_ : JSQMessagesCollectionViewCustom) {
        collectionView = collectionView_
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
        let mediaItem = JSQLocationMediaItemCustom(location: location, snapImage: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)

        self.snapShotFromData(item) { (image) in
            mediaItem?.cachedMapSnapshotImage = image
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    private func createPictureMessage(_ item : NSDictionary) -> JSQMessage
    {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        
        let mediaItem = JSQPhotoMediaItemCustom(image: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image) in
            mediaItem?.image = image
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    private func createGifMessage(_ item : NSDictionary) -> JSQMessage
    {
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
        
        let isOutGoingMessage = userId! == user_id.stringValue
        let options: AVAudioSessionCategoryOptions = [AVAudioSessionCategoryOptions.duckOthers, AVAudioSessionCategoryOptions.defaultToSpeaker,AVAudioSessionCategoryOptions.allowBluetooth]
        let font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        let attribute = JSQAudioMediaViewAttributesCustom(
            playButtonImage: UIImage(named: isOutGoingMessage ? "playButton_white.png" : "playButton_red.png")!,
            pauseButtonImage: UIImage(named: isOutGoingMessage ? "pauseButton_white.png" : "pauseButton_red.png")!,
            label: font!,
            showFractionalSecodns:false,
            backgroundColor: isOutGoingMessage ? UIColor.faeAppRedColor() : UIColor.white,
            tintColor: isOutGoingMessage ? UIColor.white : UIColor.faeAppRedColor(),
            controlInsets:UIEdgeInsetsMake(7, 12, 3, 14),
            controlPadding:5,
            audioCategory:"AVAudioSessionCategoryPlayback",
            audioCategoryOptions: options)
        let mediaItem = JSQAudioMediaItemCustom(audioViewAttributes : attribute)
        
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
        let mediaItem = JSQVideoMediaItemCustom(fileURL:URL(string:""),snapImage:image, duration:Int32(duration), isReadyToPlay:true)
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
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image) in
            mediaItem?.image = image
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
        
    }
    
    //MARK: - abstract media from data
    private func imageFromData(_ item : NSDictionary, result : (_ image : UIImage?) -> Void) {
        var image : UIImage?
        
        if let decodedData = Data(base64Encoded: (item["picture"] as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0)){
        
            image = UIImage(data: decodedData)
            result(image)
        }
    }
        
    private func gifFromData(_ item : NSDictionary, result : (_ image : UIImage?) -> Void) {
        var image : UIImage?
        
        if let decodedData = Data(base64Encoded: (item["picture"] as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0)){
            
            image = UIImage.gif(data: decodedData)
            result(image)
        }
    }
        
    private func voiceFromData(_ item : NSDictionary, result : (_ voiceData : Data?) -> Void) {
        
        if let decodedData = Data(base64Encoded: (item["audio"] as? String)!, options: NSData.Base64DecodingOptions(rawValue : 0)){
            result(decodedData)
        }
    }
    
    private func videoFromData(_ item : NSDictionary, result : (_ videoData : URL?) -> Void) {
        let str = item["video"] as? String
        let filePath = self.documentsPathForFileName("/\(str!.substring(with: str!.characters.index(str!.endIndex, offsetBy: -33) ..< str!.characters.index(str!.endIndex, offsetBy: -1)))).mov")

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            let videoFileURL = URL(fileURLWithPath: filePath)
            result(videoFileURL)
        } else {
            if let decodedData = Data(base64Encoded: str!, options: NSData.Base64DecodingOptions(rawValue : 0)){
                if(str!.characters.count > 50){
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
        
        if senderId == user_id.stringValue {
            //outgoings
            return true
        } else {
            return false
        }
    }
}
