//
//  BoardPlaceViewModel.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-19.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

struct BoardPlaceViewModel {
    let place: PlacePin
    
    var name: String {
        return place.name
    }
    
    var address: String {
        var addr = place.address1 == "" ? "" : place.address1 + ", "
        addr += place.address2
        return addr
    }
    
    var openingHour: String {
        var opening = ""
        
        let hoursToday = place.hoursToday
        let openOrClose = place.openOrClose
        if openOrClose == "N/A" {
            opening = "N/A"
        } else {
            var hours = " "
            for (index, hour) in hoursToday.enumerated() {
                if hour == "24 Hours" {
                    hours += hour
                    break
                } else {
                    if index == hoursToday.count - 1 {
                        hours += hour
                    } else {
                        hours += hour + ", "
                    }
                }
            }
            opening = openOrClose + hours
        }
        
        return opening
    }
    
    var price: String {
        return place.price
    }
    
    var imageURL: String {
        return place.imageURL
    }
}
