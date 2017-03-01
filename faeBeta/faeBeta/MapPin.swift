//
//  MapPin.swift
//  faeBeta
//
//  Created by Yue on 2/28/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MapPin {
    let pinId: Int
    let userId: Int
    let type: String
    let status: String
    let position: CLLocationCoordinate2D
    
    init(json: JSON) {
        let tmp_type = json["type"].stringValue
        self.type = tmp_type
        self.pinId = json["\(tmp_type)_id"].intValue
        self.userId = json["user_id"].intValue
        self.status = "normal"
        self.position = CLLocationCoordinate2D(latitude: json["geolocation"]["latitude"].doubleValue,
                                               longitude: json["geolocation"]["longitude"].doubleValue)
        
    }
}
