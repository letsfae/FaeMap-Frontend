//
//  CreatePinAddTagsTextView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreatePinAddTagsTextView: CreatePinTextView {

    
    func appendNewTags(tagName: String){
        let attributtedString: NSMutableAttributedString = NSMutableAttributedString()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 37))
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.cornerRadius = 8
        label.attributedText = NSAttributedString(string:tagName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20)!])
        label.numberOfLines = 1
        label.sizeToFit()
        
        var image: UIImage? = nil
        
        UIGraphicsBeginImageContext(CGSize(width:label.frame.size.width * 4, height: label.frame.size.height * 4))
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext(){
            image = screenShotImage
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        
        let tagString = NSAttributedString(attachment: attachment)
        attributtedString.append(tagString)
        
        self.isScrollEnabled = false
        self.attributedText = attributtedString
        self.isScrollEnabled = true
    }

}
