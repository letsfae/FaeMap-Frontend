////
////  CCPTextViewControll.swift
////  faeBeta
////
////  Created by Yue on 11/15/16.
////  Copyright © 2016 fae. All rights reserved.
////
//
//import UIKit
//
//extension CreateCommentPinViewController: UITextViewDelegate {
//    
//    override func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
//        textViewForCommentPin.endEditing(true)
//        textViewForCommentPin.resignFirstResponder()
//    }
//    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        inputToolbar.numberOfCharactersEntered = max(0,textView.text.characters.count)
//        if isShowingEmoji == true {
//            isShowingEmoji = false
//            UIView.animate(withDuration: 0.3, animations: {
//                self.emojiView.frame.origin.y = screenHeight
//            }, completion: { (Completed) in
//                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGesture_filled"), for: UIControlState())
//            })
//            self.textViewForCommentPin.becomeFirstResponder()
//        }
//    }
//    
//    func textViewDidChange(_ textView: UITextView) {
//        if textView == textViewForCommentPin {
//            let spacing = CharacterSet.whitespacesAndNewlines
//            
//            if textViewForCommentPin.text.trimmingCharacters(in: spacing).isEmpty == false {
//                btnSubmit.isEnabled = true
//                lableTextViewPlaceholder.isHidden = true
//                btnSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
//                btnSubmit.setTitleColor(UIColor.white, for: UIControlState())
//            }
//            else {
//                btnSubmit.isEnabled = false
//                lableTextViewPlaceholder.isHidden = false
//                btnSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 0.65)
//                btnSubmit.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
//            }
//            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
//            var numlineOnDevice = 3
//            if screenWidth == 375 {
//                numlineOnDevice = 4
//            }
//            else if screenWidth == 414 {
//                numlineOnDevice = 7
//            }
//            if numLines <= numlineOnDevice {
//                let txtHeight = ceil(textView.contentSize.height)
//                textView.frame.size.height = txtHeight
//                textView.setContentOffset(CGPoint.zero, animated: false)
//            }
//            else if numLines > numlineOnDevice {
//                
//            }
//            inputToolbar.numberOfCharactersEntered = max(0,textView.text.characters.count) //This changes the number showed in labelCountChar
//        }
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if textView == textViewForCommentPin {
//            if (text == "\n")  {
//                textViewForCommentPin.resignFirstResponder()
//                return false
//            }
//            let countChars = textView.text.characters.count + (text.characters.count - range.length)
//            return countChars <= 200
//        }
//        return true
//    }
//}
