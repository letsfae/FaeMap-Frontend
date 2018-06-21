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
    //var hours = [String: [String]]()
    var memo: String = ""
    var hoursJson: JSON!
    lazy var hours: [String: [String]] = {
        var val = [String: [String]]()
        for (key, subJson) in hoursJson {
            val = val + processHours(day: key, hour: subJson)
        }
        return val
    }()
    lazy var hoursToday: [String] = {
        if let hoursToday = hours[getDayToday()] {
            return hoursToday
        }
        return ["N/A"]
    }()
    
    lazy var openOrClose: String = {
        var val = "Closed"
        if let hoursToday = hours[getDayToday()] {
            val = closeOrOpen(hoursToday)
        } else {
            val = "N/A"
        }
        return val
    }()
    
    init(json: JSON) {
        id = json["place_id"].intValue
        name = json["name"].stringValue
        address1 = json["location"]["address"].stringValue
        address2 = json["location"]["city"].stringValue == "" ? "" : json["location"]["city"].stringValue + ", "
        address2 += json["location"]["state"].stringValue == "" ? "" : json["location"]["state"].stringValue + " "
        address2 += json["location"]["zip_code"].string == nil || json["location"]["zip_code"].stringValue == "" ? "" : json["location"]["zip_code"].stringValue + ", "
        address2 += json["location"]["country"].stringValue == "" ? "" : json["location"]["country"].stringValue
        
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
        hoursJson = json["hour"]
        /*for (key, subJson) in json["hour"] {
            hours = hours + processHours(day: key, hour: subJson)
//            if subJson.string != nil {
//                print("String \(subJson.stringValue)")
//            } else {
//                print("Array \(subJson.arrayValue)")
//            }
        }*/
        
        memo = json["user_pin_operations"]["memo"].stringValue
    }
    
    override init() {
        super.init()
    }
    
    private func processHours(day: String, hour: JSON) -> [String: [String]] {
        //    var real_hour = hour
        //    if hour.count == 0 {
        //        real_hour.append("N/A")
        //    }
        var dayDict = [String: [String]]()
        
        for days_raw in day.split(separator: ",") {
            let days = String(days_raw).trimmingCharacters(in: .whitespaces).split(separator: "–")
            if days.count == 1 {
                let d = String(days[0])
                var list = dayDict[d] ?? []
                if hour.string != nil {
                    list.append(hour.stringValue)
                    dayDict[d] = list
                } else if hour.array != nil {
                    for h in hour.arrayValue {
                        if h != "" {
                            list.append(h.stringValue)
                            dayDict[d] = list
                        }
                    }
                } else {
                    list.append("N/A")
                    dayDict[d] = list
                }
            } else if days.count == 2 {
                let day_0 = String(days[0])
                let day_1 = String(days[1])
                let arrDays = getDays(day_0, day_1)
                for d in arrDays {
                    var list = dayDict[d] ?? []
                    if hour.string != nil {
                        list.append(hour.stringValue)
                        dayDict[d] = list
                    } else if hour.array != nil {
                        for h in hour.arrayValue {
                            list.append(h.stringValue)
                            dayDict[d] = list
                        }
                    } else {
                        list.append("N/A")
                        dayDict[d] = list
                    }
                }
            }
        }
        
        /*
         if days_raw.count == 1 {
         let days = String(days_raw[0]).split(separator: "–")
         if days.count == 1 {
         dayDict = getHour(String(days[0]), hour)
         } else if days.count == 2 {
         let day_0 = String(days[0])
         let day_1 = String(days[1])
         let arrDays = getDays(day_0, day_1)
         for d in arrDays {
         dayDict = getHour(d, hour)
         }
         }
         } else if days_raw.count == 2 {
         var days = String(days_raw[0]).split(separator: "–")
         if days.count == 1 {
         dayDict = getHour(day, hour)
         } else if days.count == 2 {
         let day_0 = String(days[0])
         let day_1 = String(days[1])
         let arrDays = getDays(day_0, day_1)
         for d in arrDays {
         dayDict = getHour(d, hour)
         }
         }
         days = String(days_raw[1]).trim().split(separator: "–")
         if days.count == 1 {
         dayDict = getHour(day, hour)
         } else if days.count == 2 {
         let day_0 = String(days[0])
         let day_1 = String(days[1])
         let arrDays = getDays(day_0, day_1)
         for d in arrDays {
         dayDict = getHour(d, hour)
         }
         }
         }
         */
        
        return dayDict
    }
    
    // Get a continuous list of days, ex. Mon-Wed will be returned as [Mon, Tue, Wed]
    private func getDays(_ day_0: String, _ day_1: String) -> [String] {
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
    
    private func closeOrOpen(_ todayHour: [String]) -> String {
        
        // MARK: - Jichao fix: bug here, if todayHour is "24 hours", need a check for this case
        
        for hour in todayHour {
            if hour == "N/A" || hour == "None" {
                return "N/A"
            }
            
            if hour == "24 Hours" {
                return "Open"
            }
            
            var startHour: String = String(hour.split(separator: "–")[0])
            var endHour: String = String(hour.split(separator: "–")[1])
            if startHour == "Noon" {
                startHour = "12:00 PM"
            }
            if endHour == "Noon" {
                endHour = "12:00 PM"
            } else if endHour == "Midnight" {
                endHour = "00:00 AM"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "h:mm a"
            let dateStart = dateFormatter.date(from: startHour)
            let dateEnd = dateFormatter.date(from: endHour)
            dateFormatter.dateFormat = "HH:mm"
            
            let date24Start = dateFormatter.string(from: dateStart!)
            let date24End = dateFormatter.string(from: dateEnd!)
            
            let hourStart = Int(date24Start.split(separator: ":")[0])!
            var hourEnd = Int(date24End.split(separator: ":")[0])!
            if endHour.contains("AM") {
                hourEnd = hourEnd + 24
            }
            
            let hourCurrent = Calendar.current.component(.hour, from: Date())
            
            if hourCurrent >= hourStart && hourCurrent < hourEnd {
                return "Open"
            }
        }
        return "Closed"
    }
    
    private func getDayToday() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        let arrDay = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
        var dayIndex = 0
        if let weekday = components.weekday {
            dayIndex = weekday
            
            if weekday == 7 {
                dayIndex = 0
            } else if weekday == 8 {
                dayIndex = 1
            }
        }
        return arrDay[dayIndex]
    }

}

// Make dictionary type 'plusable' or 'addable'
func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    rhs.forEach{ result[$0] = $1 }
    return result
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
