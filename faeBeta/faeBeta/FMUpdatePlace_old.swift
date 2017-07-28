//
//  FMUpdatePlace_old.swift
//  faeBeta
//
//  Created by Yue Shen on 7/26/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

/*
 
 func placesPinIconImage(categoryList: [String]) -> UIImage {
 var iconImage = UIImage()
 if categoryList.contains("burgers") {
 iconImage = placeBurger
 }
 else if categoryList.contains("pizza") {
 iconImage = placePizza
 }
 else if categoryList.contains("coffee") {
 iconImage = placeCoffee
 }
 else if categoryList.contains("desserts") {
 iconImage = placeDessert
 }
 else if categoryList.contains("icecream") {
 iconImage = placeDessert
 }
 else if categoryList.contains("movietheaters") {
 iconImage = placeCinema
 }
 else if categoryList.contains("museums") {
 iconImage = placeArt
 }
 else if categoryList.contains("galleries") {
 iconImage = placeArt
 }
 else if categoryList.contains("spas") {
 iconImage = placeBeauty
 }
 else if categoryList.contains("barbers") {
 iconImage = placeBeauty
 }
 else if categoryList.contains("skincare") {
 iconImage = placeBeauty
 }
 else if categoryList.contains("massage") {
 iconImage = placeBeauty
 }
 else if categoryList.contains("playgrounds") {
 iconImage = placeSport
 }
 else if categoryList.contains("countryclubs") {
 iconImage = placeSport
 }
 else if categoryList.contains("sports_clubs") {
 iconImage = placeSport
 }
 else if categoryList.contains("bubbletea") {
 iconImage = placeBoba
 }
 else if categoryList.contains("juicebars") {
 iconImage = placeBoba
 }
 return iconImage
 }
 
 fileprivate func refreshYelpPlacePins(radius: Int, all: Bool) {
 
 guard PLACE_ENABLE else { return }
 
 placePins.removeAll()
 placeNames.removeAll()
 
 let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
 let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
 yelpQuery.setLatitude(lat: Double(mapCenterCoordinate.latitude))
 yelpQuery.setLongitude(lon: Double(mapCenterCoordinate.longitude))
 yelpQuery.setRadius(radius: Int(Double(radius)))
 yelpQuery.setSortRule(sort: "best_match")
 
 func checkPlaceExist(_ result: YelpPlacePin) -> Bool {
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 if placeNames.contains(latPlusLon) {
 return true
 }
 return false
 }
 
 if !all {
 yelpQuery.setResultLimit(count: 10)
 self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
 self.placePins = results
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 }
 self.pinPlacesOnMap(results: self.placePins)
 })
 } else {
 
 let count = 16
 let count_1 = count/2
 
 yelpQuery.setResultLimit(count: count)
 yelpQuery.setCatagoryToRestaurant()
 yelpManager.query(request: yelpQuery, completion: { (results) in
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 self.placePins.append(result)
 }
 //                self.pinPlacesOnMap(results: self.placePins)
 //                self.placePins.removeAll(keepingCapacity: true)
 
 self.yelpQuery.setResultLimit(count: count_1)
 self.yelpQuery.setCatagoryToDessert()
 self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 self.placePins.append(result)
 }
 //                    self.pinPlacesOnMap(results: self.placePins)
 //                    self.placePins.removeAll(keepingCapacity: true)
 
 self.yelpQuery.setCatagoryToCafe()
 self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 self.placePins.append(result)
 }
 //                        self.pinPlacesOnMap(results: self.placePins)
 //                        self.placePins.removeAll(keepingCapacity: true)
 
 self.yelpQuery.setCatagoryToCinema()
 self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 self.placePins.append(result)
 }
 //                            self.pinPlacesOnMap(results: self.placePins)
 //                            self.placePins.removeAll(keepingCapacity: true)
 
 self.yelpQuery.setCatagoryToSport()
 self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 self.placePins.append(result)
 }
 //                                self.pinPlacesOnMap(results: self.placePins)
 //                                self.placePins.removeAll(keepingCapacity: true)
 
 self.yelpQuery.setCatagoryToBeauty()
 self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 self.placePins.append(result)
 }
 //                                    self.pinPlacesOnMap(results: self.placePins)
 //                                    self.placePins.removeAll(keepingCapacity: true)
 
 self.yelpQuery.setCatagoryToArt()
 self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 self.placePins.append(result)
 }
 //                                        self.pinPlacesOnMap(results: self.placePins)
 //                                        self.placePins.removeAll(keepingCapacity: true)
 
 self.yelpQuery.setCatagoryToJuice()
 self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
 for result in results {
 if checkPlaceExist(result) {
 continue
 }
 let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
 self.placeNames.append(latPlusLon)
 self.placePins.append(result)
 }
 self.pinPlacesOnMap(results: self.placePins)
 self.placePins.removeAll(keepingCapacity: true)
 
 })
 })
 })
 })
 })
 })
 })
 })
 }
 }
 */
