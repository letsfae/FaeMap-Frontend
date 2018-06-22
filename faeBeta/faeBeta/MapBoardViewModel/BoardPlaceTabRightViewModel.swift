//
//  MBPlaceTabRightViewModel.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class BoardPlaceTabRightViewModel {
    var location: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate {
        didSet {
            if category == "All Places" {
                getPlaceInfo(latitude: location.latitude, longitude: location.longitude)
            } else {
                searchByCategories(content: category, source: "categories", latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    var category = "" {
        didSet {
            if oldValue != category {
                if category == "All Places" {
                    getPlaceInfo(latitude: location.latitude, longitude: location.longitude)
                } else {
                    searchByCategories(content: category, source: "categories", latitude: location.latitude, longitude: location.longitude)
                }
            }
        }
    }
    
    var boolDataLoaded: ((Bool) -> ())?
    var placesDataLoaded: (([PlacePin]) -> ())?
    
    private var loaded: Bool = true {
        didSet {
            boolDataLoaded?(loaded)
        }
    }
    
    var places: [PlacePin] = [] {
        didSet {
            placesDataLoaded?(places)
        }
    }
    
    var numberOfPlaces: Int {
        return places.count
    }
    
    var hasPlaces: Bool {
        return numberOfPlaces > 0
    }
    
    var title: String = ""
    
    // MARK: - Methods
    private func place(at index: Int) -> PlacePin? {
        guard index < places.count else { return nil }
        return places[index]
    }
    
    func viewModel(for index: Int) -> BoardPlaceViewModel? {
        guard let place = place(at: index) else { return nil }
        return BoardPlaceViewModel(place: place)
    }
    
    private func getPlaceInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        var places: [PlacePin] = []
        loaded = false
        
        FaeMap.shared.whereKey("geo_latitude", value: "\(latitude)")
        FaeMap.shared.whereKey("geo_longitude", value: "\(longitude)")
        FaeMap.shared.whereKey("radius", value: "100000")
        FaeMap.shared.whereKey("type", value: "place")
        FaeMap.shared.whereKey("max_count", value: "200")
        FaeMap.shared.getMapInformation { [weak self] (status: Int, message: Any?) in
            self?.loaded = true
            
            if status / 100 != 2 || message == nil {
                print("[loadMBPlaceInfo] status/100 != 2")
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfo = placeInfoJSON.array else {
                print("[loadMBPlaceInfo] fail to parse mapboard place info")
                return
            }
            if placeInfo.count <= 0 {
                print("[loadMBPlaceInfo] array is nil")
                return
            }
            
            for info in placeInfo {
                let placeData = PlacePin(json: info)
                places.append(placeData)
            }
//            self.places.sort { $0.dis < $1.dis }
            self?.places = places
        }
    }
    
    private func searchByCategories(content: String, source: String = "categories", latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        var places: [PlacePin] = []
        loaded = false
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "200")
        FaeSearch.shared.whereKey("radius", value: "100000")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
        FaeSearch.shared.whereKey("location", value: ["latitude": latitude,
                                                      "longitude": longitude])
        FaeSearch.shared.search { [weak self] (status: Int, message: Any?) in
            self?.loaded = true
            
            if status / 100 != 2 || message == nil {
//                self.showOrHideViews(searchText: content)
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfo = placeInfoJSON.array else {
//                self.showOrHideViews(searchText: content)
                return
            }
            
            places = placeInfo.map({ PlacePin(json: $0) })
            self?.places = places
            
            if source == "name" {
//                self.showOrHideViews(searchText: content)
            } else {
//                self.delegate?.jumpToPlaces?(searchText: content, places: self.filteredPlaces)
//                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
