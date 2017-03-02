//
//  PDTextViewCtrl.swift
//  faeBeta
//
//  Created by Yue on 3/2/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController: UITextViewDelegate {
    //MARK: - TEXTVIEW delegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.textViewInput {
            
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if textView.text.trimmingCharacters(in: spacing).isEmpty == false {
                self.lblTxtPlaceholder.isHidden = true
            } else {
                self.lblTxtPlaceholder.isHidden = false
            }
            
            if textView.text.characters.count == 0 {
                // when text has no char, cannot send message
                buttonSend.isEnabled = false
                buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .normal)
            } else {
                buttonSend.isEnabled = true
                buttonSend.setImage(UIImage(named: "canSendMessage"), for: .normal)
            }
            
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            let numlineOnDevice = 4
            var keyboardHeight: CGFloat = screenHeight - self.uiviewToolBar.frame.origin.y - self.uiviewToolBar.frame.size.height
            if emojiView.tag == 1 {
                keyboardHeight = 271
            }
            
            if numLines <= numlineOnDevice {
                let txtHeight = textView.contentSize.height
                textView.frame.size.height = txtHeight
                uiviewToolBar.frame.size.height = txtHeight + 66
                uiviewToolBar.frame.origin.y = screenHeight - txtHeight - 66 - keyboardHeight
                tableCommentsForPin.frame.size.height = screenHeight - txtHeight - 66 - 65 - keyboardHeight
            } else {
                textView.frame.size.height = 98
                uiviewToolBar.frame.size.height = 164
                uiviewToolBar.frame.origin.y = screenHeight - 164 - keyboardHeight
                tableCommentsForPin.frame.size.height = screenHeight - 164 - 65 - keyboardHeight
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
}
