//
//  FMUpdatePlacePins.swift
//  faeBeta
//
//  Created by Yue on 3/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

extension FaeMapViewController {
    
    func updateTimerForLoadRegionPlacePin() {
        self.loadCurrentRegionPlacePins()
        if timerLoadRegionPlacePins != nil {
            timerLoadRegionPlacePins.invalidate()
        }
//        timerLoadRegionPlacePins = Timer.scheduledTimer(timeInterval: 750, target: self, selector: #selector(self.loadCurrentRegionPlacePins), userInfo: nil, repeats: true)
    }
    
    func loadCurrentRegionPlacePins() {
        clearMap(type: "place", animated: true)
        let coorDistance = cameraDiagonalDistance()
        if self.boolCanUpdatePlacePin {
            self.boolCanUpdatePlacePin = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.refreshPlacePins(radius: coorDistance)
                self.boolCanUpdatePlacePin = true
            })
        }
    }
    
    fileprivate func pinPlacesOnMap(results: [PlacePin]) {
        var pins = [FaePinAnnotation]()
        DispatchQueue.global(qos: .default).async {
            for result in results {
                let pinMap = FaePinAnnotation(type: "place")
                pinMap.coordinate = result.coordinate
                pinMap.icon = result.icon
                pinMap.pinInfo = result as AnyObject
                pins.append(pinMap)
            }
            DispatchQueue.main.async {
                self.mapClusterManager.addAnnotations(pins, withCompletionHandler: nil)
            }
        }
    }
    
    fileprivate func refreshPlacePins(radius: Int, all: Bool = true) {
        boolCanUpdatePlacePin = false
        self.renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        let getPlaceInfo = FaeMap()
        getPlaceInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getPlaceInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getPlaceInfo.whereKey("radius", value: "500000")
        getPlaceInfo.whereKey("type", value: "place")
        getPlaceInfo.whereKey("max_count", value: "1000")
        getPlaceInfo.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("DEBUG: getMapUserInfo status/100 != 2")
                self.boolCanUpdatePlacePin = true
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                print("[getMapUserInfo] fail to parse pin comments")
                self.boolCanUpdatePlacePin = true
                return
            }
            if mapPlaceJsonArray.count <= 0 {
                self.boolCanUpdatePlacePin = true
                return
            }
            var placePins = [FaePinAnnotation]()
            DispatchQueue.global(qos: .default).async {
                for placeJson in mapPlaceJsonArray {
                    var place: FaePinAnnotation? = FaePinAnnotation(type: "place", cluster: self.mapClusterManager, json: placeJson)
                    guard place != nil else { continue }
                    if self.faePlacePins.contains(place!) {
                        guard let index = self.faeUserPins.index(of: place!) else { continue }
                        self.faePlacePins[index].positions = (place?.positions)!
                        place = nil
                    } else {
                        self.faePlacePins.append(place!)
                        placePins.append(place!)
                    }
                }
                guard placePins.count > 0 else {
                    self.boolCanUpdatePlacePin = true
                    return
                }
                DispatchQueue.main.async {
                    self.mapClusterManager.addAnnotations(placePins, withCompletionHandler: nil)
                    self.boolCanUpdatePlacePin = true
                }
            }
        }
    }
    
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
}
