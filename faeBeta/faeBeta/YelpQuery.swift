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
    
    fileprivate var customCategory = ""
    
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
    func setResultLimit(count: Int) {
        dict["limit"] = "\(count)";
    }
    
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
    
    func setCatagoryToAll() {
        customCategory = ""
        setCatagory(cata: "pizza,burgers,desserts,coffee,internetcafe,museums,galleries,beautysvc,playgrounds,countryclubs,sports_clubs,juicebars,movietheaters")
    }
    
    func setCustomCategory(to: String) {
        if customCategory == "" {
            customCategory = to
        }
        else {
            customCategory = "\(customCategory),\(to)"
        }
        setCatagory(cata: to)
    }
    
    func setCatagoryToRestaurant() {
        setCatagory(cata: "pizza,burgers")
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
        setCatagory(cata: "museums,galleries")
    }
    
    func setCatagoryToBeauty() {
        setCatagory(cata: "beautysvc")
    }
    
    func setCatagoryToSport() {
        setCatagory(cata: "playgrounds,countryclubs,sports_clubs")
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
