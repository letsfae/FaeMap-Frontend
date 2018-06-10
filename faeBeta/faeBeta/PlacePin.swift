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

class PlacePin: NSObject, FaePin {
    
    var id: Int = 0
    var name: String = ""
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var class_2: String = ""
    var class_2_icon_id: Int = 48
    var address1: String = ""
    var address2: String = ""
    var icon: UIImage?
    var imageURL = ""
    var imageURLs = [String]()
    var class_1: String = ""
    var url = ""
    var price = ""
    var phone = ""
    var arrListSavedThisPin = [Int]()
    var hours = [String: String]()
    var memo: String = ""
    
    init(json: JSON) {
        id = json["place_id"].intValue
        name = json["name"].stringValue
        address1 = json["location"]["address"].stringValue
        address2 = json["location"]["city"].stringValue + ", " + json["location"]["state"].stringValue + " " + json["location"]["zip_code"].stringValue + ", " + json["location"]["country"].stringValue
        coordinate = CLLocationCoordinate2D(latitude: json["geolocation"]["latitude"].doubleValue, longitude: json["geolocation"]["longitude"].doubleValue)
        if let _3 = json["categories"]["class3"].string {
            class_2 = _3
        } else if let _2 = json["categories"]["class2"].string {
            class_2 = _2
        }
        /**
        if json["categories"]["class2"].stringValue != "" {
            print(json["categories"]["class2"].stringValue)
        }
         */
        if let _3_icon_id = json["categories"]["class3_icon_id"].int {
            class_2_icon_id = _3_icon_id
        } else if let _2_icon_id = json["categories"]["class2_icon_id"].int {
            class_2_icon_id = _2_icon_id
        }
        icon = UIImage(named: "place_map_\(self.class_2_icon_id)") ?? #imageLiteral(resourceName: "place_map_48")
        class_1 = json["categories"]["class1"].stringValue
        
        if let arrImgURLs = json["img"].array {
            for imgURL in arrImgURLs {
                imageURLs.append(imgURL.stringValue)
            }
        }
        if imageURLs.count == 2 { imageURLs.removeLast() }
        if imageURLs.count > 0 { imageURL = imageURLs[0] }
        url = json["url"].stringValue
        price = json["priceRange"].stringValue
        phone = json["phone"].stringValue
        for (key, subJson) in json["hour"] {
            hours = hours + processHours(day: key, hour: subJson.stringValue)
            //print(subJson.stringValue)
        }
        
        memo = json["user_pin_operations"]["memo"].stringValue
    }
    
    override init() {
        super.init()
    }
}

// Make dictionary type 'plusable' or 'addable'
func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    rhs.forEach{ result[$0] = $1 }
    return result
}

func processHours(day: String, hour: String) -> [String: String] {
    var real_hour = hour
    if hour == "" {
        real_hour = "N/A"
    }
    var dayDict = [String: String]()
    let days_raw = day.split(separator: ",")
    if days_raw.count == 1 {
        let days = String(days_raw[0]).split(separator: "–")
        if days.count == 1 {
            dayDict[String(days[0])] = real_hour
        } else if days.count == 2 {
            let day_0 = String(days[0])
            let day_1 = String(days[1])
            let arrDays = getDays(day_0, day_1)
            for d in arrDays {
                dayDict[d] = real_hour
            }
        }
    } else if days_raw.count == 2 {
        var days = String(days_raw[0]).split(separator: "–")
        if days.count == 1 {
            dayDict[day] = real_hour
        } else if days.count == 2 {
            let day_0 = String(days[0])
            let day_1 = String(days[1])
            let arrDays = getDays(day_0, day_1)
            for day in arrDays {
                dayDict[day] = real_hour
            }
        }
        days = String(days_raw[1]).trim().split(separator: "–")
        if days.count == 1 {
            dayDict[day] = real_hour
        } else if days.count == 2 {
            let day_0 = String(days[0])
            let day_1 = String(days[1])
            let arrDays = getDays(day_0, day_1)
            for day in arrDays {
                dayDict[day] = real_hour
            }
        }
    }
    
    return dayDict
}

// Get a continuous list of days, ex. Mon-Wed will be returned as [Mon, Tue, Wed]
func getDays(_ day_0: String, _ day_1: String) -> [String] {
    let fixDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var idx_0 = -1
    var idx_1 = -1
    for i in 0..<fixDays.count {
        if fixDays[i] == day_0 {
            idx_0 = i
        }
        else if fixDays[i] == day_1 {
            idx_1 = i
        }
    }
    if idx_0 == -1 || idx_1 == -1 {
        return []
    }
    var days = [String]()
    for i in idx_0...idx_1 {
        days.append(fixDays[i])
    }
    return days
}

// MARK: - Test PlacePin Data Generator

func generator(_ center: CLLocationCoordinate2D, _ number: Int, _ offset: Int) -> [PlacePin] {
    
    var places = [PlacePin]()
    let start = offset + 1
    let end = number + offset + 1
    
    for i in start..<end {
        let place = PlacePin()
        place.id = i
        place.name = "test_\(i)"
        let x_offset = Double.random(min: -0.321778, max: 0.321778)
        let y_offset = Double.random(min: -0.321778, max: 0.321778)
        place.coordinate = CLLocationCoordinate2D(latitude: center.latitude + y_offset, longitude: center.longitude + x_offset)
        place.class_2_icon_id = Int(arc4random_uniform(91) + 1)
        place.address1 = "address1"
        place.address2 = "address2"
        place.icon = UIImage(named: "place_map_\(place.class_2_icon_id)") ?? #imageLiteral(resourceName: "place_map_48")
        place.price = "$$"
        place.phone = "+1 (213)309-2068"
        
        places.append(place)
    }
    
    return places
    
}
