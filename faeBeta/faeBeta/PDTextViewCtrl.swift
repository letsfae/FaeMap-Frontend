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
                self.strReplyTo = ""
            }
            
            if textView.text.characters.count == 0 {
                // when text has no char, cannot send message
                btnCommentSend.isEnabled = false
                btnCommentSend.setImage(UIImage(named: "cannotSendMessage"), for: .normal)
            } else {
                btnCommentSend.isEnabled = true
                btnCommentSend.setImage(UIImage(named: "canSendMessage"), for: .normal)
            }
            
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            let numlineOnDevice = 4
            var keyboardHeight: CGFloat = screenHeight - self.uiviewInputToolBarSub.frame.origin.y - self.uiviewInputToolBarSub.frame.size.height
            if emojiView.tag == 1 {
                keyboardHeight = 271
            }
            if numLines <= numlineOnDevice {
                let txtHeight = ceil(textView.contentSize.height)
                textView.frame.size.height = txtHeight
                uiviewInputToolBarSub.frame.size.height = txtHeight + 26
                uiviewInputToolBarSub.frame.origin.y = screenHeight - txtHeight - 26 - keyboardHeight
                tblMain.frame.size.height = screenHeight - txtHeight - 26 - 65 - keyboardHeight
                textView.setContentOffset(CGPoint.zero, animated: false)
            } else {
                textView.frame.size.height = 98
                uiviewInputToolBarSub.frame.size.height = 124
                uiviewInputToolBarSub.frame.origin.y = screenHeight - 124 - keyboardHeight
                tblMain.frame.size.height = screenHeight - 124 - 65 - keyboardHeight
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
}
