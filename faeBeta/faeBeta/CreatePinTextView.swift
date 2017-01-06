//
//  CreatePinTextView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit


/// This is a general textview used in create pin pages. Can update its size according to its text
protocol CreatePinTextViewDelegate:class {
    
    /// delegate method to handle event when a specific numebr of characters entered. Should update the inputtoolbar count label in this method
    ///
    /// - Parameters:
    ///   - textView: the textView using
    ///   - num: the number of chars entered
    func textView(_ textView:CreatePinTextView, numberOfCharactersEntered num: Int)
}

class CreatePinTextView: UITextView, UITextViewDelegate {
    
    //MARK: - properties
    private var textViewPlaceholderLabel: UILabel!
    
    weak var observerDelegate: CreatePinTextViewDelegate!
    var placeHolder: String? {
        get{
            return textViewPlaceholderLabel.text
        }
        set{
            textViewPlaceholderLabel.text = newValue
            textViewPlaceholderLabel.sizeToFit()
        }
    }
    
    //MARK: - life cycles
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK: - setup
    private func setup(){
        self.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.textColor = UIColor.white
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.white
        self.delegate = self
        self.isScrollEnabled = false
        self.clipsToBounds = false
        textViewPlaceholderLabel = UILabel(frame: CGRect(x: 5, y: 8, width: 290, height: 47))
        textViewPlaceholderLabel.numberOfLines = 2
        textViewPlaceholderLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        textViewPlaceholderLabel.textColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        self.addSubview(textViewPlaceholderLabel)
    }

    //MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.observerDelegate?.textView(self, numberOfCharactersEntered: textView.text.characters.count)
    }
    
    func textViewDidChange(_ textView: UITextView) { // This is for chat pin --add description
        let spacing = CharacterSet.whitespacesAndNewlines
        if textView.text.trimmingCharacters(in: spacing).isEmpty == false {
            textViewPlaceholderLabel.isHidden = true
        }
        else {
            textViewPlaceholderLabel.isHidden = false
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool //Example: range of text(which is 3) needs to be changed by replaecmentText (which is 10 length), if textView.length is 194, then we do not replace the text, because 194+10-3>200
    {
        if (text == "\n")  {
            self.resignFirstResponder()
            return false
        }
        let countChars = textView.text.characters.count + (text.characters.count - range.length)
        return countChars <= 200
    }
}
