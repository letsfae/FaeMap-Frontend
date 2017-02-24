//
//  CMPToolBarDelegate.swift
//  faeBeta
//
//  Created by Jacky on 1/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension CreateMomentPinViewController: CreatePinInputToolbarDelegate, SendStickerDelegate, CreatePinTextViewDelegate {
    
    func inputToolbarFinishButtonTapped(inputToolbar: CreatePinInputToolbar)
    {
        self.view.endEditing(true)
        if(isShowingEmoji){
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: true)
        }
    }
    
    func inputToolbarEmojiButtonTapped(inputToolbar: CreatePinInputToolbar) {
        if inputToolbar.mode == .emoji {
            if(!isShowingEmoji){
                isShowingEmoji = true
                self.view.endEditing(true)
                showEmojiViewAnimated(animated: true)
            }else{
                isShowingEmoji = false
                hideEmojiViewAnimated(animated: false)
                self.textViewForMediaPin.becomeFirstResponder()
            }
        }else if inputToolbar.mode == .tag {
            textAddTags.addLastInputTag()
        }
    }
    
    func sendStickerWithImageName(_ name: String) {
        
    }
    
    func appendEmojiWithImageName(_ name: String) {
        self.textViewForMediaPin.text = self.textViewForMediaPin.text + "[\(name)]"
        self.textViewDidChange(textViewForMediaPin)
    }
    
    func deleteEmoji() {
        self.textViewForMediaPin.text = self.textViewForMediaPin.text.stringByDeletingLastEmoji()
        self.textViewDidChange(self.textViewForMediaPin)
    }
    
    func showEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = screenHeight - 271 - 100
                self.emojiView.frame.origin.y = screenHeight - 271
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIcon_filled"), for: UIControlState())
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 271 - 100
            self.emojiView.frame.origin.y = screenHeight - 271
            self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIcon_filled"), for: UIControlState())
        }
    }
    
    func hideEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = screenHeight - 100
                self.inputToolbar.alpha = 0
                self.emojiView.frame.origin.y = screenHeight
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGesture_filled"), for: UIControlState())
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 100
            self.inputToolbar.alpha = 0
            self.emojiView.frame.origin.y = screenHeight
            self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGesture_filled"), for: UIControlState())
        }
    }
    
    func textView(_ textView: CreatePinTextView, numberOfCharactersEntered num: Int) {
        if(inputToolbar != nil){
            inputToolbar.numberOfCharactersEntered = max(0,num)
        }
    }
    
}
