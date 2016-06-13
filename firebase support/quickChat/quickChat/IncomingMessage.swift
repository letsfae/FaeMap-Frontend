//
//  IncomingMessage.swift
//  quickChat
//
//  Created by User on 6/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    var collectionView : JSQMessagesCollectionView
    init(collectionView_ : JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(dictionary : NSDictionary) -> JSQMessage? {
        
        var message : JSQMessage?
//        print(dictionary)
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
        
        if let mes = message {
            return mes
        } else {
            return nil
        }
    }
    
    func createTextMessage(item : NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        let text = item["message"] as? String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
        
    }
    
    func createLocationMessage(item : NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        
        let latitude = item["latitude"] as? Double
        let longitude = item["longitude"] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
        
        mediaItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        mediaItem.setLocation(location) { 
            //update collectionView
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func returnOutgoingStatusFromUser(senderId : String) -> Bool {
        
        if senderId == backendless.userService.currentUser.objectId {
            //outgoings
            return true
        } else {
            return false
        }
    }
    
    func createPictureMessage(item : NSDictionary) -> JSQMessage {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        
        let mediaItem = JSQPhotoMediaItem(image: nil)
        
        mediaItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image) in
            mediaItem.image = image
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    func imageFromData(item : NSDictionary, result : (image : UIImage?) -> Void) {
        var image : UIImage?
        
        let decodedData = NSData(base64EncodedString: (item["picture"] as? String)!, options: NSDataBase64DecodingOptions(rawValue : 0))
        
        image = UIImage(data: decodedData!)
        
        result(image: image)
    }
}