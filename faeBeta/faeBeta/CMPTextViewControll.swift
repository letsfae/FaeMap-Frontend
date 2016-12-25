//
//  CMPTextViewControll.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreateMomentPinViewController: UITextViewDelegate {
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        textViewForMediaPin.endEditing(true)
        textViewForMediaPin.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == textViewForMediaPin {
//            let spacing = CharacterSet.whitespacesAndNewlines 
//            if textViewForMediaPin.text.trimmingCharacters(in: spacing).isEmpty == false {
//                buttonMediaSubmit.isEnabled = true
//                lableTextViewPlaceholder.isHidden = true
//                buttonMediaSubmit.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1.0)
//                buttonMediaSubmit.setTitleColor(UIColor.white, for: UIControlState())
//            }
//            else {
//                buttonMediaSubmit.isEnabled = false
//                lableTextViewPlaceholder.isHidden = false
//                buttonMediaSubmit.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 0.65)
//                buttonMediaSubmit.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
//            }
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            var numlineOnDevice = 3
            if screenWidth == 375 {
                numlineOnDevice = 4
            }
            else if screenWidth == 414 {
                numlineOnDevice = 7
            }
            if numLines <= numlineOnDevice {
                let fixedWidth = textView.frame.size.width
                textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = textView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                textView.frame = newFrame
                textView.isScrollEnabled = false
            }
            else if numLines > numlineOnDevice {
                textView.isScrollEnabled = true
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewForMediaPin {
            if (text == "\n")  {
                textViewForMediaPin.resignFirstResponder()
                return false
            }
            let countChars = textView.text.characters.count + (text.characters.count - range.length)
            if countChars <= 200 {
                self.labelCountChars.text = "\(200-countChars)"
            }
            return countChars <= 200
        }
        return true
    }
}
