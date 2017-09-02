//
//  FaeFont.swift
//  faeBeta
//
//  Created by Yue Shen on 9/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

func FaeFont(fontType: FaeLabelFontType, size: CGFloat) -> UIFont {
    return UIFont(name: "AvenirNext-\(fontType)", size: size)!
}
