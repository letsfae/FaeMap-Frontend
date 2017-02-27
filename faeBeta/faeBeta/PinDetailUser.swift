//
//  PinDetailUser.swift
//  faeBeta
//
//  Created by Yue on 2/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PinDetailUser {
    
    let userId: Int
    let displayName: String
//    let age: Int?
//    let gender: Bool?
//    let isPinOwner: Bool
//    let profileImage: UIImage
    
    init(id: Int, name: String) {
        self.userId = id
        self.displayName = name
//        self.age = age
//        self.gender = gender
//        self.profileImage = image
    }
}
