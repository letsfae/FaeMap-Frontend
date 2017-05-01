//
//  UserPin.swift
//  faeBeta
//
//  Created by Yue on 3/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMaps

extension UserPin: Equatable {
    static func ==(lhs: UserPin, rhs: UserPin) -> Bool {
        return lhs.userId == rhs.userId
    }
}

struct UserPin {
    let userId: Int
    let type: String
    let miniAvatar: Int
    let position: CLLocationCoordinate2D
    var positions = [CLLocationCoordinate2D]()
    
    init(json: JSON) {
        self.type = json["type"].stringValue
        self.userId = json["user_id"].intValue
        let random = Int(arc4random_uniform(5))
        self.position = CLLocationCoordinate2D(latitude: json["geolocation"][random]["latitude"].doubleValue,
                                               longitude: json["geolocation"][random]["longitude"].doubleValue)
        self.miniAvatar = json["mini_avatar"].intValue
        guard let posArr = json["geolocation"].array else { return }
        for pos in posArr {
            let pos_i = CLLocationCoordinate2DMake(pos["latitude"].doubleValue, pos["longitude"].doubleValue)
            positions.append(pos_i)
        }
    }
}








