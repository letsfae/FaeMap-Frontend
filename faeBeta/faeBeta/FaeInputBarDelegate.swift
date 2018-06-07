//
//  FaeInputBarDelegate.swift
//  faeBeta
//
//  Created by Jichao on 2018/6/2.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit

/// A protocol that can receive different event notifications from the MessageInputBar.
protocol FaeInputBarDelegate: AnyObject {
    
    /// Called when the default send button has been selected.
    ///
    /// - Parameters:
    ///   - inputBar: The `MessageInputBar`.
    ///   - text: The current text in the `InputTextView` of the `MessageInputBar`.
    func faeInputBar(_ inputBar: FaeInputBar, didPressSendButtonWith text: String, with pinView: InputBarTopPinView?)
    
    /// Called when the instrinsicContentSize of the MessageInputBar has changed.
    /// Can be used for adjusting content insets on other views to make sure
    /// the MessageInputBar does not cover up any other view.
    ///
    /// - Parameters:
    ///   - inputBar: The `MessageInputBar`.
    ///   - size: The new instrinsic content size.
    func faeInputBar(_ inputBar: FaeInputBar, didChangeIntrinsicContentTo size: CGSize)
    
    /// Called when the `MessageInputBar`'s `InputTextView`'s text has changed.
    /// Useful for adding your own logic without the need of assigning a delegate or notification.
    ///
    /// - Parameters:
    ///   - inputBar: The MessageInputBar
    ///   - text: The current text in the MessageInputBar's InputTextView
    func faeInputBar(_ inputBar: FaeInputBar, textViewTextDidChangeTo text: String)
    
    func faeInputBar(_ inputBar: FaeInputBar, didSendStickerWith name: String, isFaeHeart faeHeart: Bool)
    
    func faeInputBar(_ inputBar: FaeInputBar, showFullAlbumWith photoPicker: FaePhotoPicker)
    
    func faeInputBar(_ inputBar: FaeInputBar, didPressQuickSendImages images: [FaePHAsset])
    
    func faeInputBar(_ inputBar: FaeInputBar, showFullView type: String, with object: Any)
    
    func faeInputBar(_ inputBar: FaeInputBar, needToSendAudioData data: Data)
    
    func faeInputBar(_ inputBar: FaeInputBar, showFullLocation show: Bool)
    
    
}
