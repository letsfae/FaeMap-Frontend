//
//  YelpQuery.swift
//  GooglePicker
//
//  Created by User on 23/01/2017.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation
import CoreLocation

class YelpQuery {
    
    var dict = [String : String]()
    
    init() {
        dict["limit"] = "10";
    }
    
    private func setCatagory(cata : String) {
        dict["categories"] = cata
    }
    
    func setRadius(radius : Int) {
        if(radius > 40000) {
            dict["radius"] = "40000";
        } else {
            dict["radius"] = "\(radius)"
        }
    }
    
    //IMPORTANT: you must provide (lat & lon) or location string
    
    func setLocation(location : String) {
        dict["location"] = location
    }
    
    func setLatitude(lat : Double) {
        dict["latitude"] = "\(lat)"
    }
    
    func setLongitude(lon : Double) {
        dict["longitude"] = "\(lon)"
    }
    
    func setSortRule(sort : String) {
        //candidate : best_match(default), rating, review_count or distance
        dict["sort_by"] = sort
    }
    
    func setTerm(term : String) {
        dict["term"] = term
    }
    
    func clearDict() {
        dict = [:]
    }
    
    func setCatagoryToDessert() {
        setCatagory(cata: "desserts")
    }
    
    func setCatagoryToCafe() {
        setCatagory(cata: "coffee,internetcafe")
    }
    
    func setCatagoryToPizza() {
        setCatagory(cata: "pizza")
    }
    
    func setCatagoryToArt() {
        setCatagory(cata: "artmuseums,galleries")
    }
    
    func setCatagoryToBeauty() {
        setCatagory(cata: "beautysvc")
    }
    
    func setCatagoryToSport() {
        setCatagory(cata: "playgrounds,countryclubs,sports_clubs,sportswear,sportgoods")
    }
    
    func setCatagoryToBurger() {
        setCatagory(cata: "burgers")
    }
    
    func setCatagoryToFoodtruck() {
        setCatagory(cata: "foodtrucks")
    }
    
    func setCatagoryToJuice() {
        setCatagory(cata: "juicebars")
    }
    
    func setCatagoryToCinema() {
        setCatagory(cata: "movietheaters")
    }
    
    func getDict() -> [String : String] {
        return self.dict
    }
}
