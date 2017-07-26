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
    let name: String
    let coordinate: CLLocationCoordinate2D
    let classTwo: String
    let classTwo_idx: Int
    // let imageURL: String
    let address1: String
    let address2: String
    var icon: UIImage?
    var imageURL = ""
    
    init(json: JSON) {
        self.id = json["place_id"].intValue
        // self.imageURL = json["image_url"].stringValue
        self.name = json["name"].stringValue
        self.address1 = json["address"].stringValue
        self.address2 = json["city"].stringValue + ", " + json["country"].stringValue + ", " + json["zip_code"].stringValue + ", " + json["state"].stringValue
        self.coordinate = CLLocationCoordinate2D(latitude: json["geolocation"]["latitude"].doubleValue, longitude: json["geolocation"]["longitude"].doubleValue)
        self.classTwo = json["class_two"].stringValue
        self.classTwo_idx = json["class_two_idx"].intValue
        self.icon = UIImage(named: "place_map_\(self.classTwo_idx)") ?? UIImage()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? PlacePin else { return false }
        return self.id == rhs.id
    }
    
    static func ==(lhs: PlacePin, rhs: PlacePin) -> Bool {
        return lhs.isEqual(rhs)
    }
}
