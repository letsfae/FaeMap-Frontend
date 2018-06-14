//
//  FaeLabel.swift
//  faeBeta
//
//  Created by Yue Shen on 9/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FaeLabel: UILabel {
    
    init(_ frame: CGRect = .zero, _ align: NSTextAlignment = .left, _ fontType: FaeLabelFontType = .regular, _ size: CGFloat, _ color: UIColor = UIColor._898989()) {
        super.init(frame: frame)
        self.textAlignment = align
        self.font = UIFont(name: "AvenirNext-\(fontType)", size: size)
        self.textColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

