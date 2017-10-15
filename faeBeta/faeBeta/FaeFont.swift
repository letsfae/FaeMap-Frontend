//
//  FaeFont.swift
//  faeBeta
//
//  Created by Yue Shen on 9/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

enum FaeLabelFontType: String {
    case regular = "Regular"
    case medium = "Medium"
    case demiBold = "DemiBold"
    case bold = "Bold"
    case mediumItalic = "MediumItalic"
    case demiBoldItalic = "DemiBoldItalic"
}

func FaeFont(fontType: FaeLabelFontType, size: CGFloat) -> UIFont {
    return UIFont(name: "AvenirNext-\(fontType)", size: size)!
}
