//
//  StringExtension.swift
//  faeBeta
//
//  Created by Yue on 11/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

extension String {
    func formatFaeDate() -> String {
        // convert to NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let myDate = dateFormatter.dateFromString(self)
        
        if myDate != nil {
            dateFormatter.dateFormat = "MMMM dd, YYYY"
            let localTimeZone = NSTimeZone.localTimeZone().abbreviation
            let elapsed = Int(NSDate().timeIntervalSinceDate(myDate!))
            print("DEBUG TIMEE")
            print(elapsed)
            if localTimeZone != nil {
                dateFormatter.timeZone = NSTimeZone(abbreviation: "\(localTimeZone!)")
                let normalFormat = dateFormatter.stringFromDate(myDate!)
                // Greater than or equal to one day
                if elapsed >= 172800 {
                    return "\(normalFormat)"
                }
                else if elapsed >= 86400 {
                    return "Yesterday"
                }
                else if elapsed >= 7200 {
                    let hoursPast = Int(elapsed/3600)
                    return "\(hoursPast) hours"
                }
                else if elapsed >= 3600 {
                    return "1 hour"
                }
                else if elapsed >= 120 {
                    let minsPast = Int(elapsed/60)
                    return "\(minsPast) mins"
                }
                else if elapsed >= 60 {
                    return "1 min"
                }
                else {
                    return "Just Now"
                }
            }
        }
        // convert to required string
        return "Invalid Date"
    }
}
