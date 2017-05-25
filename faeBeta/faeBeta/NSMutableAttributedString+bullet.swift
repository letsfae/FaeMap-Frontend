//
//  NSMutableAttributedString+bullet.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/19/16.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
extension NSMutableAttributedString {
    func appendDefaultString(_ string: String, bold: Bool) {
        let astrContent = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: bold ? "AvenirNext-DemiBold": "AvenirNext-Medium", size: 12)!])
        self.append(astrContent)
    }
    
    func appendRegularBullet(_ string: String, attributes: [String:Any]? = nil, level: Int, boldFirstSentence: Bool = false) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.firstLineHeadIndent = CGFloat(level * 24 - 24)
        paragraphStyle.headIndent = CGFloat((level-1) * 24 + 24)
        
        var attr = self.attributes(at: 0, effectiveRange: nil)
        attr[NSFontAttributeName] = UIFont(name: "AvenirNext-Medium", size: 12)!
        if let attributes = attributes {
            attr = attributes
        }
        attr[NSParagraphStyleAttributeName] = paragraphStyle
        let title = NSMutableAttributedString(string: "\(string)\n",
            attributes: attr)
        
        if boldFirstSentence {
            var length = 0
            let startIndex = title.string.characters.index(title.string.startIndex, offsetBy: 0)
            
            for c in title.string.substring(from: startIndex).characters {
                if c != "."{
                    length += 1
                } else {
                    break
                }
            }
            let range = NSRange(location: 0, length: length)
            title.addAttributes([NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 12)!], range: range)
        }
        self.append(title)
    }
    
    func appendDotBullet(_ string: String, attributes: [String:Any]? = nil, level: Int, oneLine: Bool = false) {
        let bulletPoints  = "  •    "
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.firstLineHeadIndent = CGFloat(level * 24 - 24)
        paragraphStyle.headIndent = CGFloat((level-1) * 24 + 24)
        
        var attr = self.attributes(at: 0, effectiveRange: nil)
        attr[NSFontAttributeName] = UIFont(name:"AvenirNext-Medium", size: 12)!
        if let attributes = attributes {
            attr = attributes
        }
        attr[NSParagraphStyleAttributeName] = paragraphStyle
        let changeLineSymbol = oneLine ? "\n" : "\n\n"
        let title = NSMutableAttributedString(string: "\(bulletPoints)\(string)\(changeLineSymbol)", attributes: attr)
        self.append(title)
    }
    
    func appendIndexBullet(_ string: String, index: Int, attributes: [String:Any]? = nil, level: Int, underlineFirstSentence: Bool = false) {
        let bulletPoints  = "\(index).   "
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.firstLineHeadIndent = CGFloat(level * 24 - 24)
        paragraphStyle.headIndent = CGFloat((level-1) * 24 + 24)
        
        var attr = self.attributes(at: 0, effectiveRange: nil)
        attr[NSFontAttributeName] = UIFont(name:"AvenirNext-Medium", size: 12)!
        if let attributes = attributes {
            attr = attributes
        }
        attr[NSParagraphStyleAttributeName] = paragraphStyle
        let title = NSMutableAttributedString(string: "\(bulletPoints)\(string)\n\n",
            attributes: attr)
        
        if underlineFirstSentence {
            var length = 0
            let startIndex = title.string.characters.index(title.string.startIndex, offsetBy: 5)

            for c in title.string.substring(from: startIndex).characters {
                if c != "." {
                    length += 1
                } else {
                    break
                }
            }
            let range = NSRange(location: 5, length: length)
            title.addAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue], range: range)
        }
        self.append(title)
    }
    
    func appendLetterBullet(_ string: String, letter: String, attributes: [String:Any]? = nil , level: Int, underlineFirstSentence: Bool = false) {
        let bulletPoints  = "  \(letter).   "
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.firstLineHeadIndent = CGFloat(level * 24 - 24)
        paragraphStyle.headIndent = CGFloat((level-1)*24 + 24)
        
        var attr = self.attributes(at: 0, effectiveRange: nil)
        attr[NSFontAttributeName] = UIFont(name:"AvenirNext-Medium", size: 12)!
        if let attributes = attributes {
            attr = attributes
        }
        attr[NSParagraphStyleAttributeName] = paragraphStyle
        let title = NSMutableAttributedString(string: "\(bulletPoints)\(string)\n\n",
            attributes: attr)
        
        if underlineFirstSentence {
            var length = 0
            let startIndex = title.string.characters.index(title.string.startIndex, offsetBy: 5)
            
            for c in title.string.substring(from: startIndex).characters {
                if c != "." {
                    length += 1
                } else {
                    break
                }
            }
            let range = NSRange(location: 5, length: length)
            title.addAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue], range: range)
        }
        self.append(title)
    }
}
