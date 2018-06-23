//
//  BoardUserInfoViewModel.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-20.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

struct BoardUserInfoViewModel {
    let people: BoardPeopleStruct
    let unit: String
    
    var name: String {
        return people.displayName == "" ? "Someone" : people.displayName
    }
    
    var avatar: UIImage? {
        if people.displayName == "" {
            return #imageLiteral(resourceName: "default_Avatar")
        } else {
            return nil
        }
    }
    
    var shortIntro: String {
        return people.shortIntro == "" ? people.userName : people.shortIntro
    }
    
    var age: String {
        return people.age
    }
    
    var imageGenderAndAge: UIImage? {
        if people.age == "" {
            if people.gender == "female" {
                return #imageLiteral(resourceName: "mb_female")
            } else if people.gender == "male" {
                return #imageLiteral(resourceName: "mb_male")
            } else {
                return nil
            }
        } else {
            if people.gender == "female" {
                return #imageLiteral(resourceName: "mb_femaleWithAge")
            } else if people.gender == "male" {
                return #imageLiteral(resourceName: "mb_maleWithAge")
            } else {
                return nil
            }
        }
    }
    
    var distance: String {
        var distance = ""
        var dis: Double = people.distance
//        var unit: String = " km"
        if Key.shared.measurementUnits == "imperial" {
            dis *= 0.621371
//            unit = " mi"
        }
        
        if dis < 0.1 {
            distance = "< 0.1\(unit)"
        } else if dis > 999 {
            distance = "> 999\(unit)"
        } else {
            distance = String(format: "%.1f", dis) + unit
        }
        
        return distance
    }
    
    
}
