//
//  UserPin.swift
//  faeBeta
//
//  Created by Yue on 3/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

struct UserPin {
    let userId: Int
    let type: String
    let position: CLLocationCoordinate2D
    
    init(json: JSON) {
        self.type = json["type"].stringValue
        self.userId = json["user_id"].intValue
        let random = Int(arc4random_uniform(5))
        self.position = CLLocationCoordinate2D(latitude: json["geolocation"][random]["latitude"].doubleValue,
                                               longitude: json["geolocation"][random]["longitude"].doubleValue)
        
    }
}
