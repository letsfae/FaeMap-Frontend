//
//  FaeInputBarDelegate.swift
//  faeBeta
//
//  Created by Jichao on 2018/6/2.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit

/// A protocol that can receive different event notifications from the FaeInputBar.
protocol FaeInputBarDelegate: AnyObject {
    
    /// Called when the default send button has been selected
    func faeInputBar(_ inputBar: FaeInputBar, didPressSendButtonWith text: String, with pinView: InputBarTopPinView?)
    
    /// Called when the instrinsicContentSize of the MessageInputBar has changed
    func faeInputBar(_ inputBar: FaeInputBar, didChangeIntrinsicContentTo size: CGSize)
    
    /// Called when the `FaeInputBar`'s `InputTextView`'s text has changed
    func faeInputBar(_ inputBar: FaeInputBar, textViewTextDidChangeTo text: String)
    
    /// Called when a sticker has been selected from the sticker keyboard
    func faeInputBar(_ inputBar: FaeInputBar, didSendStickerWith name: String, isFaeHeart faeHeart: Bool)
    
    /// Called when the send button has been selected from the quick photo picker
    func faeInputBar(_ inputBar: FaeInputBar, didPressQuickSendImages images: [FaePHAsset])
    
    /// Called when the recording has finished
    func faeInputBar(_ inputBar: FaeInputBar, needToSendAudioData data: Data)
    
    /// Called when full view of tools needs to be shown, including full map, full photo picker, system camera
    func faeInputBar(_ inputBar: FaeInputBar, showFullView type: String, with object: Any?)
}
