//
//  PasswordTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 23/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol PasswordCellProtocol {
    func textViewShouldReturn(_ indexPath: IndexPath)
    func textViewDidBeginEditing(_ indexPath: IndexPath)
    func textViewDidChange(_ text: String, indexPath: IndexPath)
}

class PasswordTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    // MARK: - Variables
    
    var delegate: PasswordCellProtocol?
    var indexPath: IndexPath!
    var isCharacterLimit = true
    var textEntered: String = ""
    var spaceText: String = ""
    var imageName: String = "verification_dot"
    var showText = false
    var showPasswordButtonImageName = "check_eye_close_yellow"
    
    // MARK: - Awake Function
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Functions
    
    func setPlaceholderLabelText(_ indexPath: IndexPath)  {
        self.indexPath = indexPath
        textView.autocorrectionType = .no
    }
    
    func makeFirstResponder() {
        textView.becomeFirstResponder()
    }
    
    func endAsResponder() {
        textView.resignFirstResponder()
    }
    
    // MARK: - IBAction
    
    @IBAction func showPasswordButtonTapped(_ sender: AnyObject) {
        
        showText = !showText
        
        changeColorOFImage(textEntered)
        showPasswordButton.setImage(UIImage(named: showPasswordButtonImageName), for: UIControlState())
        
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
                attributedStringWithImage.append(attrStringWithImage)
                attributedStringWithImage.append(NSAttributedString(string: " "))
            }
            
            
            attributedStringWithImage.addAttributes(myAttribute, range: NSRange.init(location: 0, length: attributedStringWithImage.length))
            
            self.textView.attributedText = attributedStringWithImage;
            
        }
    }
    
    // MARK: - Selection
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension PasswordTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing(indexPath)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
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
        showPasswordButton.setImage(UIImage(named: showPasswordButtonImageName), for: UIControlState())
        if !showText {
            setTextToDot(text)
            return false
        }
        return true
    }
    
    func setTextToDot(_ text: String) {
        
        let font = UIFont(name: "AvenirNext-Regular", size:22)
        
        let myAttribute = [ NSFontAttributeName: font!]
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: imageName)!
        
        var attributedString = NSMutableAttributedString()
        let attributedStringWithImage = NSMutableAttributedString()
        
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        for _ in 0..<textEntered.characters.count {
            attributedStringWithImage.append(attrStringWithImage)
            attributedStringWithImage.append(NSAttributedString(string: " "))
        }
        
        if text != "" {
            
            attributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            
            attributedString.append(NSAttributedString(string: text, attributes: myAttribute))
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
    
    func changeColorOFImage(_ testStr:String) {
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
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
