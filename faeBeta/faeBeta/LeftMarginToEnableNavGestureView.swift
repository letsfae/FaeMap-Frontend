//
//  LeftMarginToEnableNavGestureView.swift
//  faeBeta
//
//  Created by Yue Shen on 11/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class LeftMarginToEnableNavGestureView: UIView {
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 65 + device_offset_top, width: 15, height: screenHeight - 65 - device_offset_top))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
