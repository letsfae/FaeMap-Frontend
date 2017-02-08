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
    private var address1 : String!
    private var address2 : String!
    private var name : String!
    private var position : CLLocation!
    private var category = [String]() // Added by Yue Shen - 02.07.17
    
    init(url : String, add1 : String, add2 : String, name : String, lat : String, long : String, cate : [String]) {
        imageURL = url
        address1 = add1
        address2 = add2
        self.name = name
        position = CLLocation(latitude: Double(lat)!, longitude: Double(long)!)
        category = cate
    }
    
    func getImageURL() -> String {
        return imageURL
    }
    
    func getAddress1() -> String {
        return address1
    }
    
    func getAddress2() -> String {
        return address2
    }
    
    func getName() -> String {
        return name
    }
    
    func getPosition() -> CLLocation {
        return position
    }
    
    // Added by Yue Shen - 02.07.17
    func getCategory() -> [String] {
        return category
    }
}
