//
//  PasswordTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 23/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol PasswordCellProtocol {
    func textViewShouldReturn(indexPath: NSIndexPath)
    func textViewDidBeginEditing(indexPath: NSIndexPath)
    func textViewDidChange(text: String, indexPath: NSIndexPath)
}

class PasswordTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    // MARK: - Variables
    
    var delegate: PasswordCellProtocol?
    var indexPath: NSIndexPath!
    var isCharacterLimit = true
    var textEntered: String = ""
    var spaceText: String = ""
    var imageName: String = "WeakPassword"
    var showText = false
    var showPasswordButtonImageName = "check_eye_close_yellow"
    
    // MARK: - Awake Function
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Functions
    
    func setPlaceholderLabelText(indexPath: NSIndexPath)  {
        self.indexPath = indexPath
    }
    
    func makeFirstResponder() {
        textView.becomeFirstResponder()
    }
    
    func endAsResponder() {
        textView.resignFirstResponder()
    }
    
    // MARK: - IBAction
    
    @IBAction func showPasswordButtonTapped(sender: AnyObject) {
        showPasswordButton.selected = !showPasswordButton.selected
        showText = !showText
        let font = UIFont(name: "AvenirNext-Regular", size:22)
        
        let myAttribute = [ NSFontAttributeName: font!]
        
        if showText {
            textView.text = textEntered
            textView.font = font
        } else {
            
            let textAttachment = NSTextAttachment()
            changeColorOFImage(textEntered)
            
            textAttachment.image = UIImage(named: imageName)!
            
            let attributedStringWithImage = NSMutableAttributedString()
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)

            for _ in 0..<textEntered.characters.count {
                attributedStringWithImage.appendAttributedString(attrStringWithImage)
                attributedStringWithImage.appendAttributedString(NSAttributedString(string: " "))
            }
            

                attributedStringWithImage.addAttributes(myAttribute, range: NSRange.init(location: 0, length: attributedStringWithImage.length))
                
                self.textView.attributedText = attributedStringWithImage;
            
        }
    }
    
    // MARK: - Selection
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension PasswordTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        delegate?.textViewDidBeginEditing(indexPath)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if textEntered.characters.count > 16 && text != "" {
            return false
        }
        
        if text == "\n" {
            delegate?.textViewShouldReturn(indexPath)
            return false
        }
        
        if text != "" {
            textEntered = "\(textEntered)\(text)"
        } else {
            textEntered = String(textEntered.characters.dropLast())
        }
        
        delegate?.textViewDidChange(textEntered, indexPath: indexPath)
        
        changeColorOFImage(textEntered)
        showPasswordButton.setImage(UIImage(named: showPasswordButtonImageName), forState: .Normal)        
        if !showText {
            setTextToDot(text)
            return false
        }
        return true
    }
    
    func setTextToDot(text: String) {
        
        let font = UIFont(name: "AvenirNext-Regular", size:22)

        let myAttribute = [ NSFontAttributeName: font!]
        
        let textAttachment = NSTextAttachment()
        print(imageName)
        textAttachment.image = UIImage(named: imageName)
        
        var attributedString = NSMutableAttributedString()
        let attributedStringWithImage = NSMutableAttributedString()
        
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        for _ in 0..<textEntered.characters.count {
            attributedStringWithImage.appendAttributedString(attrStringWithImage)
            attributedStringWithImage.appendAttributedString(NSAttributedString(string: " "))
        }
        
        if text != "" {
            
            attributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            
            attributedString.appendAttributedString(NSAttributedString(string: text, attributes: myAttribute))
            textView.attributedText = attributedString
            
            attributedStringWithImage.addAttributes(myAttribute, range: NSRange.init(location: 0, length: attributedStringWithImage.length))
            delay(0.1) {
                self.textView.attributedText = attributedStringWithImage;
            }
        } else {
            
            attributedStringWithImage.addAttributes(myAttribute, range: NSRange.init(location: 0, length: attributedStringWithImage.length))
            
            self.textView.attributedText = attributedStringWithImage;
        }
        self.textView.font = font
    }
    
    func changeColorOFImage(testStr:String) {
        var uppercase = 0
        var symbol = 0
        var digit = 0
        for i in testStr.characters {
            if(i <= "9" && i >= "0") {
                digit = 1
            } else if (i <= "z" && i >= "a") {
                
            } else if (i <= "Z" && i >= "A") {
                uppercase = 1
            } else {
                symbol = 1
            }
        }
        
        if (uppercase + digit + symbol >= 2)  {
            imageName = "StrongPassword"
            showPasswordButtonImageName = showText ? "check_eye_open_red" : "check_eye_close_red"
        } else if (uppercase + digit + symbol == 1) {
            imageName = "OkPassword"
            showPasswordButtonImageName = showText ? "check_eye_open_orange" : "check_eye_close_orange"
        } else if (uppercase + digit + symbol < 1) {
            imageName = "WeakPassword"
            showPasswordButtonImageName = showText ? "check_eye_open_yellow" : "check_eye_close_yellow"
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}

