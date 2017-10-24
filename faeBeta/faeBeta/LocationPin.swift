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
    
    var id: Int = 0
    var content: String = ""
    let coordinate: CLLocationCoordinate2D
    let address1: String = ""
    let address2: String = ""
    var icon: UIImage?
    var fileId: String = ""
    var arrListSavedThisPin = [Int]()
    var optionsReady = false
    
    init(json: JSON) {
        id = json["location_id"].intValue
        // self.imageURL = json["image_url"].stringValue
        fileId = json["content"].stringValue
        
        coordinate = CLLocationCoordinate2D(latitude: json["geolocation"]["latitude"].doubleValue, longitude: json["geolocation"]["longitude"].doubleValue)
        
    }
    
    init(position: CLLocationCoordinate2D) {
        coordinate = position
    }
}

