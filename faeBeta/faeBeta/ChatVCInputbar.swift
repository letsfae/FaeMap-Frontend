//
//  ChatVCInputbar.swift
//  faeBeta
//
//  Created by Jichao on 2018/5/30.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit
/*
extension ChatViewController {
    func loadInputBarComponent() {
        inputToolbar.removeFromSuperview()
        let contentView = inputToolbar.contentView
        contentView?.backgroundColor = UIColor.white
        contentView?.textView.placeHolder = "Type Something..."
        contentView?.textView.contentInset = UIEdgeInsetsMake(3.0, 0.0, 1.0, 0.0)
        contentView?.textView.delegate = self
        
        let contentOffset = (screenWidth - 42 - 29 * 7) / 6 + 29
        btnKeyBoard = UIButton(frame: CGRect(x: 21, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        btnKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        btnKeyBoard.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
        contentView?.addSubview(btnKeyBoard)
        
        btnSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnSticker.setImage(UIImage(named: "sticker"), for: UIControlState())
        btnSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
        btnSticker.addTarget(self, action: #selector(showStikcer), for: .touchUpInside)
        contentView?.addSubview(btnSticker)
        
        btnImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnImagePicker.setImage(UIImage(named: "imagePicker"), for: UIControlState())
        btnImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
        contentView?.addSubview(btnImagePicker)
        btnImagePicker.addTarget(self, action: #selector(showLibrary), for: .touchUpInside)
        
        let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        buttonCamera.setImage(UIImage(named: "camera"), for: UIControlState())
        buttonCamera.setImage(UIImage(named: "camera"), for: .highlighted)
        contentView?.addSubview(buttonCamera)
        buttonCamera.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
        
        btnVoiceRecorder = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: UIControlState())
        btnVoiceRecorder.setImage(UIImage(named: "voiceMessage"), for: .highlighted)
        btnVoiceRecorder.addTarget(self, action: #selector(showRecord), for: .touchUpInside)
        contentView?.addSubview(btnVoiceRecorder)
        
        btnLocation = UIButton(frame: CGRect(x: 21 + contentOffset * 5, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnLocation.setImage(UIImage(named: "shareLocation"), for: UIControlState())
        btnLocation.showsTouchWhenHighlighted = false
        btnLocation.addTarget(self, action: #selector(showMiniMap), for: .touchUpInside)
        contentView?.addSubview(btnLocation)
        
        btnSend = UIButton(frame: CGRect(x: 21 + contentOffset * 6, y: inputToolbar.frame.height - 36, width: 29, height: 29))
        btnSend.setImage(UIImage(named: "cannotSendMessage"), for: .disabled)
        btnSend.setImage(UIImage(named: "cannotSendMessage"), for: .highlighted)
        btnSend.setImage(UIImage(named: "canSendMessage"), for: .normal)
        
        contentView?.addSubview(btnSend)
        btnSend.isEnabled = false
        btnSend.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
        
        btnSet.append(btnKeyBoard)
        btnSet.append(btnSticker)
        btnSet.append(btnImagePicker)
        btnSet.append(buttonCamera)
        btnSet.append(btnLocation)
        btnSet.append(btnVoiceRecorder)
        btnSet.append(btnSend)
        
        for button in btnSet {
            button.autoresizingMask = [.flexibleTopMargin]
        }
        
        contentView?.heartButtonHidden = false
        contentView?.heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        contentView?.heartButton.addTarget(self, action: #selector(actionHoldingLikeButton(_:)), for: .touchDown)
        contentView?.heartButton.addTarget(self, action: #selector(actionLeaveLikeButton(_:)), for: .touchDragOutside)
        
        automaticallyAdjustsScrollViewInsets = false
    }
 
    
}
*/
