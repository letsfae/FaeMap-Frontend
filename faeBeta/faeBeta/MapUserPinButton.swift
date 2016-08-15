//
//  MapUserPinButton.swift
//  faeBeta
//
//  Created by Yue on 7/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MapUserPinButton: UIButton {
    
    var userID: Int!
    
    var createdAt: String!
    
    var geoArray = Array<Array<Double>>()
    
    var avatar = "maleHappy"
    
    var type: String!
    
    // var Timer
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 35, height: 41))
        self.setImage(UIImage(named: "\(avatar)"), forState: .Normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
