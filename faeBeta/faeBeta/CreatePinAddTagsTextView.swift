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
        let attributtedString = self.attributedText.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 37))

        label.attributedText = NSAttributedString(string:tagName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20)!])
        label.numberOfLines = 1
        
        //calculate the size of the image
        label.sizeToFit()
        var size = label.frame.size
        label.frame = CGRect(x: 0, y: 0, width: size.width + 18, height: size.height + 8)
        label.textAlignment = .center
        size = label.frame.size
        
        //get a high quality image
        label.attributedText = NSAttributedString(string:tagName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 48)!])
        label.sizeToFit()
        var size2 = label.frame.size
        label.frame = CGRect(x: 0, y: 0, width: size2.width + 48, height: size2.height + 22)
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
        attachment.bounds = CGRect(x: 0, y: 0, width: size.width + 13, height: size.height)
        
        let tagString = NSAttributedString(attachment: attachment)
        attributtedString.append(tagString)
        
        self.isScrollEnabled = false
        self.attributedText = attributtedString
        self.isScrollEnabled = true
    }

}
