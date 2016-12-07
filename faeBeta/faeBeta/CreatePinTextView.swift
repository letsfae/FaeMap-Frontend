//
//  CreatePinTextView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol CreatePinTextViewDelegate:class {
    func textView(_ textView:CreatePinTextView, numberOfCharactersEntered num: Int)
}

class CreatePinTextView: UITextView, UITextViewDelegate {
    private var lableTextViewPlaceholder: UILabel!
    weak var observerDelegate: CreatePinTextViewDelegate!
    var placeHolder: String? {
        get{
            return lableTextViewPlaceholder.text
        }
        set{
            lableTextViewPlaceholder.text = newValue
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        self.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.textColor = UIColor.white
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.white
        self.delegate = self
        self.isScrollEnabled = false

        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 5, y: 8, width: 171, height: 27))
        lableTextViewPlaceholder.numberOfLines = 0
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lableTextViewPlaceholder.textColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        self.addSubview(lableTextViewPlaceholder)
    }

    func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.observerDelegate?.textView(self, numberOfCharactersEntered: textView.text.characters.count)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        
        if textView.text.trimmingCharacters(in: spacing).isEmpty == false {
//            buttonCommentSubmit.isEnabled = true
            lableTextViewPlaceholder.isHidden = true
//            buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1.0)
//            buttonCommentSubmit.setTitleColor(UIColor.white, for: UIControlState())
        }
        else {
//            buttonCommentSubmit.isEnabled = false
            lableTextViewPlaceholder.isHidden = false
//            buttonCommentSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 0.65)
//            buttonCommentSubmit.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
        }
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
        
        self.observerDelegate?.textView(self, numberOfCharactersEntered: textView.text.characters.count)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n")  {
            self.resignFirstResponder()
            return false
        }
        let countChars = textView.text.characters.count + (text.characters.count - range.length)
//        if countChars <= 200 {
//            self.labelCountChars.text = "\(200-countChars)"
//        }
        return countChars <= 200
    }
}
