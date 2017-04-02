//
//  File.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/21.
//  Copyright © 2016年 fae. All rights reserved.
//

import Foundation
import UIKit

extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    class func faeAppRedColor() -> UIColor {
        return UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1)
    }
    
    class func faeAppWeakPasswordYellowColor() -> UIColor {
        return UIColor(red: 251/255, green: 201/255, blue: 64/255, alpha: 1)
    }
    
    class func faeAppOkPasswordOrangeColor() -> UIColor {
        return UIColor(red: 254/255, green: 171/255, blue: 55/255, alpha: 1)
    }
    
    class func faeAppDisabledRedColor() -> UIColor {
        return UIColor(red: 255/255, green: 160/255, blue: 160/255, alpha: 1)
    }
    
    class func faeAppInputTextGrayColor() -> UIColor {
        return UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
    }
    
    class func faeAppInfoLabelGrayColor() -> UIColor {
        return UIColor(red: 182/255, green: 182/255, blue: 182/255, alpha: 1)
    }
    
    class func faeAppInputPlaceholderGrayColor() -> UIColor {
        return UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
    }
    
    class func faeAppDescriptionTextGrayColor() -> UIColor {
        return UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1)
    }
    
    class func faeAppTimeTextBlackColor() -> UIColor {
        return UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
    }
    
    class func faeAppShadowGrayColor() -> UIColor {
        return UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
    }
    
    class func faeAppTextViewPlaceHolderGrayColor() -> UIColor {
        return UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    }
    
    class func maleBackgroundColor() -> UIColor {
        return UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1)
    }
    
    class func femaleBackgroundColor() -> UIColor {
        return UIColor(red: 253/255, green: 175/255, blue: 222/255, alpha: 1.0)
    }
    
    class func faeAppNavBarBorderGrayColor() -> CGColor
    {
        return UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        
    }
    
}
