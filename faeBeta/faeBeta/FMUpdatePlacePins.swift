//
//  FMUpdatePlacePins.swift
//  faeBeta
//
//  Created by Yue on 3/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import RealmSwift

extension FaeMapViewController {
    
    func updateTimerForLoadRegionPlacePin() {
        self.loadCurrentRegionPlacePins()
        if timerLoadRegionPlacePins != nil {
            timerLoadRegionPlacePins.invalidate()
        }
        timerLoadRegionPlacePins = Timer.scheduledTimer(timeInterval: 750, target: self, selector: #selector(self.loadCurrentRegionPlacePins), userInfo: nil, repeats: true)
    }
    
    func loadCurrentRegionPlacePins() {
        clearMap(type: "place")
        let coorDistance = cameraDiagonalDistance()
        let placeAllType = allTypePlacesPin()
        if self.canDoNextPlacePinUpdate {
            self.canDoNextPlacePinUpdate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.refreshPlacePins(radius: coorDistance, all: placeAllType)
                self.canDoNextPlacePinUpdate = true
            })
        }
    }
    
    fileprivate func pinPlacesOnMap(results: [PlacePin]) {
        for result in results {
            var iconImage = UIImage()
            let categoryList = result.category
            iconImage = self.placesPinIconImage(categoryList: categoryList)
            let pinMap = GMSMarker()
            let iconSub = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 64))
            let icon = UIImageView(frame: CGRect(x: 30, y: 64, width: 0, height: 0))
            iconSub.addSubview(icon)
            icon.contentMode = .scaleAspectFit
            icon.image = iconImage
            pinMap.iconView = iconSub
            let delay: Double = Double(arc4random_uniform(200)) / 100
            pinMap.groundAnchor = CGPoint(x: 0.5, y: 1)
            pinMap.position = result.position
            pinMap.userData = [2: result]
            pinMap.map = self.faeMapView
            self.mapPlacePinsDic.append(pinMap)
            UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                icon.frame = CGRect(x: 6, y: 10, width: 48, height: 54)
            }, completion: {(done: Bool) in
                if done {
                    pinMap.iconView = nil
                    pinMap.icon = iconImage
                }
            })
        }
    }
    
    fileprivate func refreshPlacePins(radius: Int, all: Bool) {
        return
        mapPlacePinsDic.removeAll()
        mapPlaces.removeAll()
        placeNames.removeAll()
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        yelpQuery.setLatitude(lat: Double(mapCenterCoordinate.latitude))
        yelpQuery.setLongitude(lon: Double(mapCenterCoordinate.longitude))
        yelpQuery.setRadius(radius: Int(Double(radius)))
        yelpQuery.setSortRule(sort: "best_match")
        
        func checkPlaceExist(_ result: PlacePin) -> Bool {
            let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
            if placeNames.contains(latPlusLon) {
                return true
            }
            return false
        }
        
        if !all {
            yelpQuery.setResultLimit(count: 10)
            self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                self.mapPlaces = results
                for result in results {
                    if checkPlaceExist(result) {
                        continue
                    }
                    let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                    self.placeNames.append(latPlusLon)
                }
                self.pinPlacesOnMap(results: self.mapPlaces)
                //                self.calculateZoomLevel(results: self.mapPlaces)
            })
        } else {
            yelpQuery.setResultLimit(count: 4)
            yelpQuery.setCatagoryToRestaurant()
            yelpManager.query(request: yelpQuery, completion: { (results) in
                for result in results {
                    if checkPlaceExist(result) {
                        continue
                    }
                    let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                    self.placeNames.append(latPlusLon)
                    self.mapPlaces.append(result)
                    self.pinPlacesOnMap(results: [result])
                }
                
                self.yelpQuery.setResultLimit(count: 2)
                self.yelpQuery.setCatagoryToDessert()
                self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                    for result in results {
                        if checkPlaceExist(result) {
                            continue
                        }
                        let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                        self.placeNames.append(latPlusLon)
                        self.mapPlaces.append(result)
                        self.pinPlacesOnMap(results: [result])
                    }
                    self.yelpQuery.setCatagoryToCafe()
                    self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                        for result in results {
                            if checkPlaceExist(result) {
                                continue
                            }
                            let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                            self.placeNames.append(latPlusLon)
                            self.mapPlaces.append(result)
                            self.pinPlacesOnMap(results: [result])
                        }
                        self.yelpQuery.setCatagoryToCinema()
                        self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                            for result in results {
                                if checkPlaceExist(result) {
                                    continue
                                }
                                let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                                self.placeNames.append(latPlusLon)
                                self.mapPlaces.append(result)
                                self.pinPlacesOnMap(results: [result])
                            }
                            self.yelpQuery.setCatagoryToSport()
                            self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                                for result in results {
                                    if checkPlaceExist(result) {
                                        continue
                                    }
                                    let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                                    self.placeNames.append(latPlusLon)
                                    self.mapPlaces.append(result)
                                    self.pinPlacesOnMap(results: [result])
                                }
                                self.yelpQuery.setCatagoryToBeauty()
                                self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                                    for result in results {
                                        if checkPlaceExist(result) {
                                            continue
                                        }
                                        let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                                        self.placeNames.append(latPlusLon)
                                        self.mapPlaces.append(result)
                                        self.pinPlacesOnMap(results: [result])
                                    }
                                    self.yelpQuery.setCatagoryToArt()
                                    self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                                        for result in results {
                                            if checkPlaceExist(result) {
                                                continue
                                            }
                                            let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                                            self.placeNames.append(latPlusLon)
                                            self.mapPlaces.append(result)
                                            self.pinPlacesOnMap(results: [result])
                                        }
                                        self.yelpQuery.setCatagoryToJuice()
                                        self.yelpManager.query(request: self.yelpQuery, completion: { (results) in
                                            for result in results {
                                                if checkPlaceExist(result) {
                                                    continue
                                                }
                                                let latPlusLon = Double(result.position.latitude) + Double(result.position.longitude)
                                                self.placeNames.append(latPlusLon)
                                                self.mapPlaces.append(result)
                                                self.pinPlacesOnMap(results: [result])
                                            }
//                                            self.calculateZoomLevel(results: self.mapPlaces)
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
    
    fileprivate func calculateZoomLevel(results: [PlacePin]) {
        var latArr = [Double]()
        var lonArr = [Double]()
        for result in results {
            latArr.append(result.position.latitude)
            lonArr.append(result.position.longitude)
        }
        
        let minLat = latArr.min()!
        let maxLat = latArr.max()!
        let minLon = lonArr.min()!
        let maxLon = lonArr.max()!
        let northWestCor = CLLocationCoordinate2DMake(maxLat, minLon)
        let southEastCor = CLLocationCoordinate2DMake(minLat, maxLon)
        let geoBounds = GMSCoordinateBounds(coordinate: northWestCor, coordinate: southEastCor)
        let cameraUpdate = GMSCameraUpdate.fit(geoBounds, withPadding: 25.0)
        faeMapView.animate(with: cameraUpdate)
    }
    
    fileprivate func allTypePlacesPin() -> Bool {
        if btnMFilterPlacesAll.tag == 1 || btnMFilterShowAll.tag == 1 {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func placesPinIconImage(categoryList: [String]) -> UIImage {
        var iconImage = UIImage()
        if categoryList.contains("burgers") {
            iconImage = #imageLiteral(resourceName: "placePinBurger")
        }
        else if categoryList.contains("pizza") {
            iconImage = #imageLiteral(resourceName: "placePinPizza")
        }
        else if categoryList.contains("coffee") {
            iconImage = #imageLiteral(resourceName: "placePinCoffee")
        }
        else if categoryList.contains("desserts") {
            iconImage = #imageLiteral(resourceName: "placePinDesert")
        }
        else if categoryList.contains("icecream") {
            iconImage = #imageLiteral(resourceName: "placePinDesert")
        }
        else if categoryList.contains("movietheaters") {
            iconImage = #imageLiteral(resourceName: "placePinCinema")
        }
        else if categoryList.contains("museums") {
            iconImage = #imageLiteral(resourceName: "placePinArt")
        }
        else if categoryList.contains("galleries") {
            iconImage = #imageLiteral(resourceName: "placePinArt")
        }
        else if categoryList.contains("spas") {
            iconImage = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if categoryList.contains("barbers") {
            iconImage = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if categoryList.contains("skincare") {
            iconImage = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if categoryList.contains("massage") {
            iconImage = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if categoryList.contains("playgrounds") {
            iconImage = #imageLiteral(resourceName: "placePinSport")
        }
        else if categoryList.contains("countryclubs") {
            iconImage = #imageLiteral(resourceName: "placePinSport")
        }
        else if categoryList.contains("sports_clubs") {
            iconImage = #imageLiteral(resourceName: "placePinSport")
        }
        else if categoryList.contains("bubbletea") {
            iconImage = #imageLiteral(resourceName: "placePinBoba")
        }
        else if categoryList.contains("juicebars") {
            iconImage = #imageLiteral(resourceName: "placePinBoba")
        }
        return iconImage
    }
}
