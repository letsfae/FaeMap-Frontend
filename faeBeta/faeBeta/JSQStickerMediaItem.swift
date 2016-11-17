//
//  JSQStickerMediaItem.swift
//  quickChat
//
//  Created by User on 7/24/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import JSQMessagesViewController

//this is a class that subclass JSQPhotoMediaItem, to show sticker in a chat bubble.
// it overrided the size of chat bubble
class JSQStickerMediaItem: JSQPhotoMediaItem {
    //inheritance from JSQPhoto
    var cachedImageView : UIImageView!
    
    override func mediaView() -> UIView! {
        if self.image == nil {
            return nil
        }
        if self.cachedImageView == nil {
            let imageSize = self.mediaViewDisplaySize()
            let imageView = UIImageView(image: self.image)
            imageView.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            imageView.contentMode = .scaleAspectFit
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedImageView = imageView
        }
        return cachedImageView
    }
    
    //overridde the photo size to the stick size
    override func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 120, height: 90)
    }
    
}
