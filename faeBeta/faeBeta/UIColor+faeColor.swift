//
//  File.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/21.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int, alpha: Int) {
        let newRed = CGFloat(r) / 255
        let newGreen = CGFloat(g) / 255
        let newBlue = CGFloat(b) / 255
        let newAlpha = CGFloat(alpha) / 100
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
    
    class func _2499090() -> UIColor {
        return UIColor(r: 249, g: 90, b: 90, alpha: 100)
    }
    
    class func _255160160() -> UIColor {
        return UIColor(r: 255, g: 160, b: 160, alpha: 100)
    }
    
    class func _898989() -> UIColor {
        return UIColor(r: 89, g: 89, b: 89, alpha: 100)
    }
    
    class func _182182182() -> UIColor {
        return UIColor(r: 182, g: 182, b: 182, alpha: 100)
    }
    
    class func _155155155() -> UIColor {
        return UIColor(r: 155, g: 155, b: 155, alpha: 100)
    }
    
    class func _138138138() -> UIColor {
        return UIColor(r: 138, g: 138, b: 138, alpha: 100)
    }
    
    class func _107107107() -> UIColor {
        return UIColor(r: 107, g: 107, b: 107, alpha: 100)
    }
    
    class func _107105105() -> UIColor {
        return UIColor(r: 107, g: 105, b: 105, alpha: 100)
    }
    
    class func _210210210() -> UIColor {
        return UIColor(r: 210, g: 210, b: 210, alpha: 100)
    }
    
    class func _234234234() -> UIColor {
        return UIColor(r: 234, g: 234, b: 234, alpha: 100)
    }
    
    class func _149207246() -> UIColor {
        return UIColor(r: 149, g: 207, b: 246, alpha: 100)
    }
    
    class func _253175222() -> UIColor {
        return UIColor(r: 253, g: 175, b: 222, alpha: 100)
    }
    
    class func _200199204cg() -> CGColor {
        return UIColor(r: 200, g: 199, b: 204, alpha: 100).cgColor
    }
    
    class func _200199204() -> UIColor {
        return UIColor(r: 200, g: 199, b: 204, alpha: 100)
    }
    
    class func _225225225() -> UIColor {
        return UIColor(r: 225, g: 225, b: 225, alpha: 100)
    }
    
    class func _146146146() -> UIColor {
        return UIColor(r: 146, g: 146, b: 146, alpha: 100)
    }
    
    class func _248248248() -> UIColor {
        return UIColor(r: 248, g: 248, b: 248, alpha: 100)
    }
    
    class func _115115115() -> UIColor {
        return UIColor(r: 115, g: 115, b: 115, alpha: 100)
    }
    
    class func _496372() -> UIColor {
        return UIColor(r: 49, g: 63, b: 72, alpha: 100)
    }
    
    class func _585151() -> UIColor {
        return UIColor(r: 58, g: 51, b: 51, alpha: 80)
    }
    
    class func _241241241() -> UIColor {
        return UIColor(r: 241, g: 241, b: 241, alpha: 100)
    }
    
    class func _206203203() -> UIColor {
        return UIColor(r: 206, g: 203, b: 203, alpha: 100)
    }
}
