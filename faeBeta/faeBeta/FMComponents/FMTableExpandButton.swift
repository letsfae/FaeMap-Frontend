//
//  FMTableExpandButton.swift
//  faeBeta
//
//  Created by Yue Shen on 6/30/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class FMTableExpandButton: UIButton {
    
    var before: CGFloat = 181 + device_offset_top
    var after: CGFloat = 0
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        switch screenHeight {
        case 812:
            after = 700
            break
        case 736:
            after = 645
            break
        case 667:
            after = 579
            break
        case 568:
            after = 484
            break
        default:
            break
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
