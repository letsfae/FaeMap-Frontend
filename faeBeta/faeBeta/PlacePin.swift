//
//  PlacePin.swift
//  faeBeta
//
//  Created by Yue Shen on 7/25/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class PlacePin: NSObject {
    
    let id: Int
    var name: String
    let coordinate: CLLocationCoordinate2D
    let class_2: String
    let class_2_icon_id: Int
    // let imageURL: String
    let address1: String
    let address2: String
    var icon: UIImage?
    var imageURL = ""
    let class_1: String
    
    init(json: JSON) {
        id = json["place_id"].intValue
        // self.imageURL = json["image_url"].stringValue
        name = json["name"].stringValue
        address1 = json["location"]["address"].stringValue
        address2 = json["location"]["city"].stringValue + ", " + json["location"]["country"].stringValue + ", " + json["location"]["zip_code"].stringValue + ", " + json["location"]["state"].stringValue
        coordinate = CLLocationCoordinate2D(latitude: json["geolocation"]["latitude"].doubleValue, longitude: json["geolocation"]["longitude"].doubleValue)
        class_2 = json["categories"]["class2"].stringValue
        class_2_icon_id = json["categories"]["class2_icon_id"].intValue
        icon = UIImage(named: "place_map_\(self.class_2_icon_id)") ?? #imageLiteral(resourceName: "place_map_48")
        
        class_1 = json["categories"]["class1"].stringValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? PlacePin else { return false }
        return self.id == rhs.id
    }
    
    static func ==(lhs: PlacePin, rhs: PlacePin) -> Bool {
        return lhs.isEqual(rhs)
    }
}
