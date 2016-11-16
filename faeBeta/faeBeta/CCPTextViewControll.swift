//
//  CCPTextViewControll.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreateCommentPinViewController: UITextViewDelegate {
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        textViewForCommentPin.endEditing(true)
        textViewForCommentPin.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == textViewForCommentPin {
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if textViewForCommentPin.text.trimmingCharacters(in: spacing).isEmpty == false {
                buttonCommentSubmit.isEnabled = true
                lableTextViewPlaceholder.isHidden = true
                buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
            }
            else {
                buttonCommentSubmit.isEnabled = false
                lableTextViewPlaceholder.isHidden = false
                buttonCommentSubmit.backgroundColor = UIColor.lightGray
            }
        }
        let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
        if numLines <= 8 {
            let fixedWidth = textView.frame.size.width
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            textView.frame = newFrame
            textView.isScrollEnabled = false
        }
        else if numLines > 8 {
            textView.isScrollEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewForCommentPin {
            if (text == "\n")  {
                textViewForCommentPin.resignFirstResponder()
                return false
            }
            return textView.text.characters.count + (text.characters.count - range.length) <= 200
        }
        return true
    }
}
