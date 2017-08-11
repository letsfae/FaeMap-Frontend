//
//  CGRectExtension.swift
//  faeBeta
//
//  Created by Yue on 6/25/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension CGRect {
    
    /**
     Init a CGRect with auto-layout feature
    */
    init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        let newX = x * screenWidthFactor
        let newY = y * screenHeightFactor
        let newW = w * screenWidthFactor
        let newH = h * screenHeightFactor
        self.init(x: newX, y: newY, width: newW, height: newH)
    }
}
