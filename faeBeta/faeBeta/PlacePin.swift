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
    var class_2: String = ""
    var class_2_icon_id: Int = 48
    let address1: String
    let address2: String
    var icon: UIImage?
    var imageURL = ""
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
        imageURL = json["img"].stringValue
        url = json["url"].stringValue
        price = json["priceRange"].stringValue
        phone = json["phone"].stringValue
        for (key, subJson) in json["hour"] {
            hours = hours + processHours(day: key, hour: subJson.stringValue)
            print(subJson.stringValue)
        }
        
        memo = json["user_pin_operations"]["memo"].stringValue
    }
    
    init(string: String) {
        let data = string.data(using: String.Encoding.utf8)
        let placeJSON = JSON(data: data!)
        id = placeJSON["place_id"].intValue
        name = placeJSON["name"].stringValue
        coordinate = CLLocationCoordinate2D(latitude: placeJSON["geolocation"]["latitude"].doubleValue, longitude: placeJSON["geolocation"]["longitude"].doubleValue)
        class_1 = placeJSON["categories"]["class1"].stringValue
        class_2_icon_id = placeJSON["categories"]["class1_icon_id"].intValue
        address1 = placeJSON["location"]["address1"].stringValue
        address2 = placeJSON["location"]["address2"].stringValue
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
