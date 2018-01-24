//
//  StringExtension.swift
//  faeBeta
//
//  Created by Yue on 11/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

extension String {
    
    func removeSpecialChars() -> String {
        let okayChars: Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(self.filter { okayChars.contains($0) })
    }
    
    func onlyNumbers() -> String {
        let okayChars: Set<Character> = Set("1234567890")
        return String(self.filter { okayChars.contains($0) })
    }
    
    // Trim newline in the beginning and ending of string
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.newlines)
    }
    
    // Calculate text height in all cases
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func formatFaeDate() -> String {
        // convert to NSDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let myDate = dateFormatter.date(from: self)
        if myDate != nil {
            dateFormatter.dateFormat = "MMMM dd, YYYY"
            let localTimeZone = NSTimeZone.local.abbreviation()
            let elapsed = Int(Date().timeIntervalSince(myDate!))
            if localTimeZone != nil {
                dateFormatter.timeZone = TimeZone(abbreviation: "\(localTimeZone!)")
                let normalFormat = dateFormatter.string(from: myDate!)
                dateFormatter.dateFormat = "EEEE, HH:mm"
                let dayFormat = dateFormatter.string(from: myDate!)
                // Greater than or equal to one day
                if elapsed >= 604800 {
                    return "\(normalFormat)"
                } else if elapsed >= 172800 {
                    return "\(dayFormat)"
                } else if elapsed >= 86400 {
                    return "Yesterday"
                } else if elapsed >= 7200 {
                    let hoursPast = Int(elapsed / 3600)
                    return "\(hoursPast) hours ago"
                } else if elapsed >= 3600 {
                    return "1 hour ago"
                } else if elapsed >= 120 {
                    let minsPast = Int(elapsed / 60)
                    return "\(minsPast) mins ago"
                } else if elapsed >= 60 {
                    return "1 min ago"
                } else {
                    return "Just Now"
                }
            }
        }
        // convert to required string
        return "Invalid Date"
    }
    
    func formatLeftOnMap(durationOnMap: Int) -> String {
        // convert to NSDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let myDate = dateFormatter.date(from: self)
        if myDate != nil {
            let elapsed = Int(Date().timeIntervalSince(myDate!))
            if elapsed >= durationOnMap * 3600 {
                return "Map Time Expired"
            } else if (durationOnMap * 3600 - elapsed) >= 3600 {
                let hoursLeft = Int((durationOnMap * 3600 - elapsed) / 3600)
                return "\(hoursLeft + 1) hours left on Map"
            } else if (durationOnMap * 3600 - elapsed) >= 60 {
                let minsLeft = Int((durationOnMap * 3600 - elapsed) / 60)
                return "\(minsLeft + 1) mins left on Map"
            } else if (durationOnMap * 3600 - elapsed) >= 0 {
                let secsLeft = Int((durationOnMap * 3600 - elapsed))
                return "\(secsLeft + 1) seconds left on Map"
            }
        }
        return "Map Time Expired"
    }
    
    func formatNSDate() -> String {
        // convert to NSDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let myDate = dateFormatter.date(from: self)
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        let localTimeZone = NSTimeZone.local.abbreviation()
        if localTimeZone != nil {
            formatter.timeZone = TimeZone(abbreviation: "\(localTimeZone!)")
        }
        return formatter.string(from: myDate!)
    }
    
    func isNewPin() -> Bool {
        // convert to NSDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let myDate = dateFormatter.date(from: self)
        
        if myDate != nil {
            dateFormatter.dateFormat = "MMMM dd, YYYY"
            let localTimeZone = NSTimeZone.local.abbreviation()
            let elapsed = Int(Date().timeIntervalSince(myDate!))
            if localTimeZone != nil {
                // Greater than or equal to one day
                if elapsed >= 300 {
                    return false
                } else {
                    return true
                }
            }
        }
        return false
    }
    
    func formatPinCommentsContent() -> NSMutableAttributedString {
        
        //        var content = "<a>@maplestory06</a> comment and like testing"
        var username = ""
        var endIndex = 0
        
        if let match = self.range(of: "(?<=<a>@)[^.]+(?=</a>)", options: .regularExpression) {
            username = "@\(String(self[match]))"
            endIndex = username.count + 8
        }
        //        else {
        //            print("parse formatPinCommentsContent fails")
        //        }
        
        let index = self.index(self.startIndex, offsetBy: endIndex)
        let restContent = " \(self[index...])"
        
        let attrsUsername = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18.0)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()]
        
        let usernameString = NSMutableAttributedString(string: username, attributes: attrsUsername)
        let regularString = restContent.convertStringWithEmoji()
        usernameString.append(regularString)
        
        return usernameString
    }
    
    func getFaeStickerName() -> String? {
        if let match = self.range(of: "(?<=<faeSticker>)[^.]+(?=</faeSticker>)", options: .regularExpression) {
            return String(self[match])
        }
        return nil
    }
    
    func getFaeImageName() -> String? {
        if let match = self.range(of: "(?<=<faeImg>)[^.]+(?=</faeImg>)", options: .regularExpression) {
            return String(self[match])
        }
        return nil
    }
    
    func stringByDeletingLastEmoji() -> String {
        let previous = self
        var finalString = ""
        
        if previous.count > 0 && previous.last != "]" {
            finalString = String(previous[..<previous.index(previous.endIndex, offsetBy: -1)])
        } else if previous.count > 0 && previous.last == "]" {
            var i = 1
            var findEmoji = false
            while i <= previous.count {
                if previous[previous.index(previous.endIndex, offsetBy: -i)] == "[" {
                    let between = String(previous[previous.index(previous.endIndex, offsetBy: -(i - 1)) ..< previous.index(previous.endIndex, offsetBy: -1)])
                    if (StickerInfoStrcut.stickerDictionary["faeEmoji"]?.contains(between))! {
                        findEmoji = true
                        break
                    }
                }
                i += 1
            }
            
            if findEmoji {
                finalString = String(previous[..<previous.index(previous.endIndex, offsetBy: -i)])
            } else {
                finalString = String(previous[..<previous.index(previous.endIndex, offsetBy: -1)])
            }
        }
        return finalString
    }
    
    func convertStringWithEmoji() -> NSMutableAttributedString {
        var content = self
        var emojiText = ""
        var startIndex = 0
        var endIndex = 0
        var finalText = ""
        let retString = NSMutableAttributedString()
        //        var isProcessed = false
        
        while true {
            if let range = content.range(of: "[") {
                //                isProcessed = true
                let tmpContent = content
                startIndex = content.distance(from: content.startIndex, to: range.lowerBound)
                let index = content.index(content.startIndex, offsetBy: startIndex)
                finalText = "\(finalText)\(tmpContent[...index])"
                content = "\(tmpContent[index...])"
                let attrStringWithString = NSAttributedString(string: "\(tmpContent[...index])", attributes: [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 18)!])
                retString.append(attrStringWithString)
            }
            if let match = content.range(of: "(?<=\\[)(.*?)(?=\\])", options: .regularExpression) {
                //                isProcessed = true
                let tmpContent = content
                emojiText = String(content[match])
                //                print("Target: \(emojiText)")
                endIndex = emojiText.count + 2
                let index = tmpContent.index(tmpContent.startIndex, offsetBy: endIndex)
                content = "\(tmpContent[index...])"
                //                print("  Rest: \(content)")
                finalText = "\(finalText)\(emojiText)"
                
                let emojiImage = UIImage(named: "\(emojiText)")
                let textAttachment = InlineTextAttachment()
                textAttachment.fontDescender = -6
                textAttachment.image = UIImage(cgImage: (emojiImage?.cgImage)!, scale: 4, orientation: .up)
                let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                retString.append(attrStringWithImage)
            } else {
                //                print("  Done!")
                break
            }
        }
        finalText = finalText + content
        let attrStringWithString = NSAttributedString(string: content, attributes: [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 18)!])
        retString.append(attrStringWithString)
        return retString
    }
}

class InlineTextAttachment: NSTextAttachment {
    var fontDescender: CGFloat = 0
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        var superRect = super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
        
        superRect.origin.y = fontDescender
        
        return superRect
    }
    
}
