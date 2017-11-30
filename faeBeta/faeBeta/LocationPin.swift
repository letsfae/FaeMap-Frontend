//
//  LocationPin.swift
//  faeBeta
//
//  Created by Yue Shen on 10/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class LocationPin: NSObject {
    var id: Int = -1
    var content: String?
    var location = CLLocation()
    let coordinate: CLLocationCoordinate2D
    let address1: String = ""
    let address2: String = ""
    var icon: UIImage?
    var fileId: Int = -1
    var arrListSavedThisPin = [Int]()
    var optionsReady = false
    var memo: String = ""
    
    init(json: JSON) {
        id = json["location_id"].intValue
        fileId = json["file_ids"].intValue
        
        let lat = json["geolocation"]["latitude"].doubleValue
        let lon = json["geolocation"]["longitude"].doubleValue
        location = CLLocation(latitude: lat, longitude: lon)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        memo = json["user_pin_operations"]["memo"].stringValue
    }
    
    init(position: CLLocationCoordinate2D) {
        coordinate = position
    }
}

