//
//  CreatePinAddTagsTextView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreatePinAddTagsTextView: CreatePinTextView, NSLayoutManagerDelegate {
    //MARK: - properties
    var tagNames =  [String]()
    {
        didSet{
            self.observerDelegate?.textView(self, numberOfCharactersEntered: tagNames.count)
        }
    }
    
    //MARK: - life cycles
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.layoutManager.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutManager.delegate = self

    }
    
    //MARK: - add tags
    
    /// abstract the user's input from textView add call appendNewTags()
    func addLastInputTag()
    {
        var str = String(self.text.characters.filter() { $0 <= "~" })
        str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if str.characters.count == 0{
            return
        }
        
        let remain = self.attributedText.attributedSubstring(from: NSMakeRange(0, tagNames.count))
        self.attributedText = remain
        
        if str.characters.count > 0{
            appendNewTags(tagName: str)
        }
    }
    
    
    /// create an UIImage with the tag's name and add it into the textView
    ///
    /// - Parameter tagName: the name of the tag
    func appendNewTags(tagName: String){
        let attributtedString = self.attributedText.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 37))
        label.attributedText = NSAttributedString(string:tagName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20)!])
        label.numberOfLines = 1
        
        //calculate the size of the image
        label.sizeToFit()
        var size = label.frame.size
        label.frame = CGRect(x: 0, y: 0, width: min(size.width + 18, 280), height: size.height + 8)
        label.textAlignment = .center
        size = label.frame.size
        
        //get a high quality image
        label.attributedText = NSAttributedString(string:tagName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 48)!])
        label.sizeToFit()
        var size2 = label.frame.size
        label.frame = CGRect(x: 0, y: 0, width: min(size2.width + 48, 750), height: size2.height + 22)
        label.layer.borderWidth = 4
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.cornerRadius = 24
        size2 = label.frame.size
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(CGSize(width: size2.width + 35, height: size2.height))
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext(){
            image = screenShotImage
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: -11, width: size.width + 13, height: size.height)
        
        let tagString = NSAttributedString(attachment: attachment)
        attributtedString.append(tagString)
        
        self.isScrollEnabled = false
        self.attributedText = attributtedString
        self.isScrollEnabled = true
        tagNames.append(tagName)
        
        self.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.textColor = UIColor.white
        self.observerDelegate?.textView(self, numberOfCharactersEntered: tagNames.count)

    }
    
    //MARK: - NSLayoutManagerDelegate
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 12
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect
    {
        var originalRect = super.caretRect(for: position)
        originalRect.size.height = self.font!.pointSize - self.font!.descender
        // "descender" is expressed as a negative value,
        // so to add its height you must subtract its value
        originalRect.origin.y = originalRect.origin.y + (tagNames.count != 0 ? 5 : 0)
        return originalRect
    }
    
    //MARK: - textView delegate
    override func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.observerDelegate?.textView(self, numberOfCharactersEntered: tagNames.count)
    }
    
    override func textViewDidChange(_ textView: UITextView)
    {
        super.textViewDidChange(textView)
        self.observerDelegate?.textView(self, numberOfCharactersEntered: tagNames.count)
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text != ""
        {
            return super.textView(textView, shouldChangeTextIn:range, replacementText: text) && tagNames.count < 5 && range.location >= tagNames.count
        }else{
            if range.location < tagNames.count{
                var length = range.length
                while(length > 0 && tagNames.count > range.location){
                    tagNames.remove(at: range.location)
                    length -= 1
                }
            }
        }
        return super.textView(textView, shouldChangeTextIn:range, replacementText: text)
    }
}
