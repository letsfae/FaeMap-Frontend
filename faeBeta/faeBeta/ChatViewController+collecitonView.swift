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

extension ChatViewController {
    // MARK: - collection view delegate
    
    // JSQMessage delegate not only should handle chat bubble itself, it should handle photoQuickSelect cell
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == photoQuickCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoQuickCollectionReuseIdentifier, forIndexPath: indexPath) as! PhotoPickerCollectionViewCell
            return cell
        }
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCellCustom
        
        let data = messages[indexPath.row]
        
        if data.senderId == user_id.stringValue {
            cell.textView?.textColor = UIColor.whiteColor()
            cell.textView?.font = UIFont(name: "Avenir Next", size: 16)
        } else {
            cell.textView?.textColor = UIColor(red: 107.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
            cell.textView?.font = UIFont(name: "Avenir Next", size: 16)
        }
        cell.avatarImageView.layer.cornerRadius = 17.5
        
        let object = objects[indexPath.row]
        switch (object["type"] as! String) {
            case "text":
                cell.contentType = Text
                break
            case "picture":
                cell.contentType = Picture
                break
            case "sticker":
                cell.contentType = Sticker
                break
            case "location":
                cell.contentType = Location
                break
            case "audio":
                cell.contentType = Audio
                break
            default:
                break
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView && indexPath.row == messages.count - 1{
            clearRecentCounter(chat_id)
        }else if collectionView == self.photoQuickCollectionView {
            let cell = cell as! PhotoPickerCollectionViewCell
            //get image from PHFetchResult
            let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section] as! PHAsset
            cell.loadImage(asset, requestOption: requestOption)
            
            if photoPicker.assetIndexDict[asset] != nil {
                cell.chosenFrameImageView.hidden = false
                cell.chosenFrameImageView.image = UIImage(named: self.frameImageName[photoPicker.assetIndexDict[asset]!])
            }else{
                cell.chosenFrameImageView.hidden = true
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoQuickCollectionView {
            return 1
        }
        return messages.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == photoQuickCollectionView && photoPicker.cameraRoll != nil{
            return photoPicker.cameraRoll.albumCount
        }
        return super.numberOfSectionsInCollectionView(collectionView)
    }
    
    //this delegate is used to tell which bubble image should be used on current message
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == user_id.stringValue {
            if data.isMediaMessage {
                outgoingBubble = JSQMessagesBubbleImageFactoryCustom(bubbleImage: UIImage(named: "avatarPlaceholder"), capInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)).outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleRedColor())
            }
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    //this is used to edit top label of every cell
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let object = objects[indexPath.row]
        if object["hasTimeStamp"] as! Bool {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayoutCustom!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let object = objects[indexPath.row]
        if object["hasTimeStamp"] as! Bool  {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayoutCustom!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0.0
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
        let status = message["status"] as! String
        
        if indexPath.row == messages.count - 1 {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
        
    }
    // bind avatar image
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    //photoes preview delegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == photoQuickCollectionView {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoPickerCollectionViewCell
            let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section] as! PHAsset
            
            if cell.chosenFrameImageView.hidden {
                if photoPicker.indexAssetDict.count == 10 {
                    showAlertView()
                } else {
                    photoPicker.assetIndexDict[asset] = photoPicker.indexImageDict.count
                    photoPicker.indexAssetDict[photoPicker.indexImageDict.count] = asset
                    let count = self.photoPicker.indexImageDict.count
                    let highQRequestOption = PHImageRequestOptions()
                    highQRequestOption.resizeMode = .Exact //resize time fast
                    requestOption.deliveryMode = .HighQualityFormat //high pixel
                    requestOption.synchronous = true
                    PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(1500,1500), contentMode: .AspectFill, options: highQRequestOption) { (result, info) in
                        self.photoPicker.indexImageDict[count] = result
                    }
                    cell.chosenFrameImageView.image = UIImage(named: frameImageName[photoPicker.indexImageDict.count - 1])
                    cell.chosenFrameImageView.hidden = false
                }
            } else {
                cell.chosenFrameImageView.hidden = true
                let deselectedIndex = photoPicker.assetIndexDict[asset]
                photoPicker.assetIndexDict.removeValueForKey(asset)
                photoPicker.indexAssetDict.removeValueForKey(deselectedIndex!)
                photoPicker.indexImageDict.removeValueForKey(deselectedIndex!)
                shiftChosenFrameFromIndex(deselectedIndex! + 1)
            }
            //            print("imageDict has \(imageDict.count) images")
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
    }
    //photoes preview layout
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    //taped bubble
    // function when user tap the bubble, like image, location
    override func collectionView(collectionView: JSQMessagesCollectionViewCustom!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        closeStickerPanel()
        closeQuickPhotoPanel()
        
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQPhotoMediaItemCustom
            
            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
        }
        
        if object["type"] as! String == "location" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQLocationMediaItemCustom
            
            let vc = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewControllerWithIdentifier("ChatMapViewController")as! ChatMapViewController
            
            vc.chatLatitude = mediaItem.coordinate.latitude
            vc.chatLongitude = mediaItem.coordinate.longitude
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
//        if object["type"] as! String == "audio" {
//            let message = messages[indexPath.row]
//            
//            let mediaItem = message.media as! JSQAudioMediaItemCustom
//            
//            let data = mediaItem.audioData
//            
//            preparePlayer(data!)
//            
//            soundPlayer.play()
//        }
    }
    
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        var returnValue = false
        
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" || object["type"] as! String == "text" || object["type"] as! String == "sticker"{
            returnValue = true
        }
        self.selectedIndexPathForMenu = indexPath;
        return returnValue
    }

}
