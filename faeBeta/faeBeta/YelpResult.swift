//
//  YelpResult.swift
//  GooglePicker
//
//  Created by User on 23/01/2017.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation
import CoreLocation

class YelpResult {
    
    private var imageURL : String!
    private var address : String!
    private var name : String!
    private var position : CLLocation!
    
    init(url : String, add : String, name : String, lat : String, long : String) {
        imageURL = url
        address = add
        self.name = name
        self.position = CLLocation(latitude: Double(lat)!, longitude: Double(long)!)
    }
    
    func getImageURL() -> String {
        return imageURL
    }
    
    func getAddress() -> String {
        return address
    }
    
    func getName() -> String {
        return name
    }
    
    func getPosition() -> CLLocation {
        return position
    }
}
