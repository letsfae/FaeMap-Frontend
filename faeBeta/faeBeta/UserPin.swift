//
//  UserPin.swift
//  faeBeta
//
//  Created by Yue Shen on 8/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class UserPin: NSObject {
    
    let id: Int
    var miniAvatar: Int
    var showOptions: Bool
    var positions = [CLLocationCoordinate2D]()
    
    init(json: JSON) {
        self.id = json["user_id"].intValue
        self.miniAvatar = json["mini_avatar"].intValue
        self.showOptions = json["show_name_card_options"].boolValue
        guard let posArr = json["geolocation"].array else { return }
        for pos in posArr {
            let pos_i = CLLocationCoordinate2DMake(pos["latitude"].doubleValue, pos["longitude"].doubleValue)
            self.positions.append(pos_i)
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? UserPin else { return false }
        return self.id == rhs.id
    }
    
    static func ==(lhs: UserPin, rhs: UserPin) -> Bool {
        return lhs.isEqual(rhs)
    }
}

