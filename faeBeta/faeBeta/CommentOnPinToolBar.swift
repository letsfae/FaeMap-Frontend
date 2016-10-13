//
//  CommentOnPinToolBar.swift
//  faeBeta
//
//  Created by Yue on 10/12/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController {
    func loadInputToolbar() {
        commentInputToolbar = JSQMessagesInputToolbarCustom(frame: CGRectMake(0, screenHeight-90, screenWidth, 90))
        loadInputBarComponent()
        self.view.addSubview(commentInputToolbar)
        self.view.bringSubviewToFront(commentInputToolbar)
    }
    
    func loadInputBarComponent() {
        var buttonSet = [UIButton]()
        //        let camera = Camera(delegate_: self)
        let contentView = self.commentInputToolbar.contentView
        let contentOffset = (screenWidth - 42 - 29 * 6) / 5 + 29
        let buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.commentInputToolbar.frame.height - 36, width: 29, height: 29))
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
//        buttonKeyBoard.addTarget(self, action: #selector(keyboardButtonClicked), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonKeyBoard)
        
        let buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: 54, width: 29, height: 29))
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
//        buttonSticker.addTarget(self, action: #selector(ChatViewController.showStikcer), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonSticker)
        
        buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: 54, width: 29, height: 29))
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
        contentView.addSubview(buttonImagePicker)
        
//        buttonImagePicker.addTarget(self, action: #selector(ChatViewController.showLibrary), forControlEvents: .TouchUpInside)
        
        let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: 54, width: 29, height: 29))
        buttonCamera.setImage(UIImage(named: "camera"), forState: .Normal)
        contentView.addSubview(buttonCamera)
        
//        buttonCamera.addTarget(self, action: #selector(ChatViewController.showCamera), forControlEvents: .TouchUpInside)
        
        let buttonLocation = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: 54, width: 29, height: 29))
        buttonLocation.setImage(UIImage(named: "shareLocation"), forState: .Normal)
        //add a function
//        buttonLocation.addTarget(self, action: #selector(ChatViewController.sendLocation), forControlEvents: .TouchUpInside)
        contentView.addSubview(buttonLocation)
        
//        buttonLocation.addTarget(self, action: #selector(ChatViewController.initializeStickerView), forControlEvents: .TouchUpInside)
        
        let buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 5, y: 54, width: 29, height: 29))
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
        contentView.addSubview(buttonSend)
        buttonSend.enabled = false
//        buttonSend.addTarget(self, action: #selector(ChatViewController.sendMessageButtonTapped), forControlEvents: .TouchUpInside)
        
        buttonSet.append(buttonKeyBoard)
        buttonSet.append(buttonSticker)
        buttonSet.append(buttonImagePicker)
        buttonSet.append(buttonCamera)
        buttonSet.append(buttonLocation)
        buttonSet.append(buttonSend)
        
        for button in buttonSet{
            button.autoresizingMask = [.FlexibleTopMargin]
        }
    }
}
