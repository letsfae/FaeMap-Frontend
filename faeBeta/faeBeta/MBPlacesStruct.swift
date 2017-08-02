//
//  MBPlacesStruct.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/6/5.
//  Copyright © 2017年 Yue. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

extension MBPlacesStruct: Equatable {
    static func ==(lhs: MBPlacesStruct, rhs: MBPlacesStruct) -> Bool {
        return lhs.placeId == rhs.placeId
    }
}

struct MBPlacesStruct {
    let placeId: Int
    let name: String
    let address: String
    let position: CLLocation
    var distance: String
    let dis: Double
    let classTwo: String
    let class_2_icon_id: Int
    var icon: UIImage?
    
    init(json: JSON) {
        placeId = json["place_id"].intValue
        name = json["name"].stringValue
        address = json["location"]["address"].stringValue + ", " + json["location"]["city"].stringValue + ", " + json["location"]["country"].stringValue + ", " + json["location"]["zip_code"].stringValue + ", " + json["location"]["state"].stringValue
        
        position = CLLocation(latitude: json["geolocation"]["latitude"].doubleValue,
                             longitude: json["geolocation"]["longitude"].doubleValue)
        
        let curtPos = CLLocation(latitude: LocManager.shared.curtLat, longitude: LocManager.shared.curtLong)

        dis = curtPos.distance(from: position) / 1000
        if dis < 0.1 {
            distance = "< 0.1 km"
        } else if dis > 999 {
            distance = "> 999 km"
        } else {
            distance = String(format: "%.1f", dis) + " km"
        }
        
        self.classTwo = json["categories"]["class2"].stringValue
        self.class_2_icon_id = json["categories"]["class2_icon_id"].intValue
        self.icon = UIImage(named: "place_result_\(self.class_2_icon_id)") ?? #imageLiteral(resourceName: "Awkward")
    }
}
