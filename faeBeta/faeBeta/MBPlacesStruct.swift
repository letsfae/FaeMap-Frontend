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
//    var curtLatitude: CLLocationDegrees = MapBoardViewController().currentLatitude  //34.0205378
//    var curtLongitude: CLLocationDegrees = MapBoardViewController().currentLongitude  //-118.2854081
    let dis: Double
    
    init(json: JSON) {
        placeId = json["place_id"].intValue
        name = json["name"].stringValue
        address = json["address"].stringValue
        
//        let mbVC = MapBoardViewController()
//        mbVC.updateCurtLoc()
//        curtLatitude = mbVC.currentLatitude
//        curtLongitude = mbVC.currentLongitude
//        print("PlaceStruct curtLat \(curtLatitude) curtLon \(curtLongitude)")
        
        position = CLLocation(latitude: json["geolocation"]["latitude"].doubleValue,
                             longitude: json["geolocation"]["longitude"].doubleValue)
        
        let curtPos = CLLocation(latitude: LocManage.shared.curtLat, longitude: LocManage.shared.curtLong)

        dis = curtPos.distance(from: position) / 1000
        if dis < 0.1 {
            distance = "< 0.1 km"
        } else if dis > 999 {
            distance = "> 999 km"
        } else {
            distance = String(format: "%.1f", dis) + " km"
        }
    }
}
