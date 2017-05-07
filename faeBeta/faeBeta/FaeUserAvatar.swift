//
//  FaeUserAvatar.swift
//  faeBeta
//
//  Created by Yue on 5/6/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SDWebImage

class FaeUserAvatar: UIImageView {

    var userID = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
