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
    private var labelTextViewPlaceholder: UILabel!
    weak var observerDelegate: CreatePinTextViewDelegate!
    var placeHolder: String? {
        get{
            return labelTextViewPlaceholder.text
        }
        set{
            labelTextViewPlaceholder.text = newValue
            labelTextViewPlaceholder.sizeToFit()
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
        self.clipsToBounds = false
        labelTextViewPlaceholder = UILabel(frame: CGRect(x: 5, y: 8, width: 290, height: 47))
        labelTextViewPlaceholder.numberOfLines = 2
        labelTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        labelTextViewPlaceholder.textColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        self.addSubview(labelTextViewPlaceholder)
    }

    func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.observerDelegate?.textView(self, numberOfCharactersEntered: textView.text.characters.count)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        
        if textView.text.trimmingCharacters(in: spacing).isEmpty == false {
            labelTextViewPlaceholder.isHidden = true
        }
        else {
            labelTextViewPlaceholder.isHidden = false
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
        return countChars <= 200
    }
}
