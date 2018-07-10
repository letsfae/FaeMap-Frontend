//
//  MBPlaceTabRightViewModel.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class BoardPlaceTabRightViewModel {
    var update: Bool = true
    var location: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate {
        didSet {
//            let from = CLLocation(latitude: oldValue.latitude, longitude: oldValue.longitude)
//            let to = CLLocation(latitude: location.latitude, longitude: location.longitude)
//            if to.distance(from: from) > 282 {
//            places.removeAll(keepingCapacity: true)
            if update {
                if category == "All Places" {
                    getPlaceInfo(latitude: location.latitude, longitude: location.longitude)
                } else {
                    searchByCategories(content: category, latitude: location.latitude, longitude: location.longitude)
                }
            } else {
                update = true
            }
//            }
        }
    }
    
    var category = "" {
        didSet {
            if oldValue != category || category == "All Places" {
                //                places.removeAll(keepingCapacity: true)
                if category == "All Places" {
                    getPlaceInfo(latitude: location.latitude, longitude: location.longitude)
                } else {
                    searchByCategories(content: category, latitude: location.latitude, longitude: location.longitude)
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
    
    var dataOffset: Int = 0
    
    var searchRequest: DataRequest?
    
    var fetchMoreDataStatus: ((Bool, String) -> ())?
    
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
        Key.shared.radius_board = 100000
        dataOffset = 0
        let placesAgent = FaeMap()
        placesAgent.whereKey("geo_latitude", value: "\(latitude)")
        placesAgent.whereKey("geo_longitude", value: "\(longitude)")
        placesAgent.whereKey("radius", value: "\(Key.shared.radius_board)")
        placesAgent.whereKey("type", value: "place")
        placesAgent.whereKey("max_count", value: "30")
        placesAgent.getMapPins { [weak self] (status: Int, message: Any?) in
            guard let `self` = self else { return }
            self.loaded = true
            if status / 100 != 2 || message == nil {
                print("[loadMBPlaceInfo] status/100 != 2")
                self.places = []
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfo = placeInfoJSON.array else {
                print("[loadMBPlaceInfo] fail to parse mapboard place info")
                self.places = []
                return
            }
            if placeInfo.count <= 0 {
                print("[loadMBPlaceInfo] array is nil")
                self.places = []
                return
            }
            
            for info in placeInfo {
                let placeData = PlacePin(json: info)
                places.append(placeData)
            }
//            self.places.sort { $0.dis < $1.dis }
            self.dataOffset += places.count
            self.places = places
        }
    }
    
    func searchByCategories(content: String, source: String = "categories", latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        var places: [PlacePin] = []
        let sort = source == "name" ? [["_score": "desc"], ["geo_location": "asc"]] : [["geo_location": "asc"]]
        loaded = false
        Key.shared.searchContent_board = content
        Key.shared.searchSource_board = source
        Key.shared.radius_board = 100000
        dataOffset = 0
        let searchAgent = FaeSearch()
        searchAgent.whereKey("content", value: content)
        searchAgent.whereKey("source", value: source)
        searchAgent.whereKey("type", value: "place")
        searchAgent.whereKey("size", value: "30")
        searchAgent.whereKey("radius", value: "\(Key.shared.radius_board)")
        searchAgent.whereKey("offset", value: "0")
        searchAgent.whereKey("sort", value: sort)
        searchAgent.whereKey("location", value: ["latitude": latitude,
                                                      "longitude": longitude])
        searchRequest?.cancel()
        searchRequest = searchAgent.search { [weak self] (status: Int, message: Any?) in
            guard let `self` = self else { return }
            self.loaded = true
            guard status / 100 == 2 else {
                return
            }
            guard message != nil else {
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfo = placeInfoJSON.array else {

                return
            }
            places = placeInfo.map({ PlacePin(json: $0) })
            self.dataOffset += places.count
            self.places = places
        }
    }
    
    func fetchMoreAllPlaces() {
        fetchMoreDataStatus?(true, "")
//        vickyprint("fetch \(dataOffset)")
        guard loaded else { return }
        guard dataOffset >= 30 else { return }
        guard dataOffset % 30 == 0 else {
            fetchMoreDataStatus?(true, "No more data")
            return
        }
        fetchMoreDataStatus?(false, "")
        Key.shared.radius_board = 100000
        let locToSearch = LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate
        let placesAgent = FaeMap()
        placesAgent.whereKey("geo_latitude", value: "\(locToSearch.latitude)")
        placesAgent.whereKey("geo_longitude", value: "\(locToSearch.longitude)")
        placesAgent.whereKey("radius", value: "\(Key.shared.radius_board)")
        placesAgent.whereKey("type", value: "place")
        placesAgent.whereKey("max_count", value: "30")
        placesAgent.whereKey("offset", value: "\(dataOffset)")
        searchRequest?.cancel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchRequest = placesAgent.getMapPins { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                guard status / 100 == 2 else {
                    self.fetchMoreDataStatus?(true, "Network error!")
                    return
                }
                guard message != nil else {
                    self.fetchMoreDataStatus?(true, "Network error!")
                    return
                }
                let placeInfoJSON = JSON(message!)
                guard let placeInfo = placeInfoJSON.array else {
                    self.fetchMoreDataStatus?(true, "No more data")
                    return
                }
                let searchPlaces = placeInfo.map({ PlacePin(json: $0) })
                guard searchPlaces.count > 0 else {
                    self.fetchMoreDataStatus?(true, "No more data")
                    return
                }
                self.dataOffset += searchPlaces.count
                self.places += searchPlaces
            }
        }
    }
    
    func fetchMoreSearchedPlaces() {
        fetchMoreDataStatus?(true, "")
        //        vickyprint("fetch \(dataOffset)")
        guard loaded else { return }
        guard dataOffset >= 30 else { return }
        guard dataOffset % 30 == 0 else {
            fetchMoreDataStatus?(true, "No more data")
            return
        }
        fetchMoreDataStatus?(false, "")
        Key.shared.radius_board = 100000
        let locToSearch = LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate
        let searchAgent = FaeSearch()
        searchAgent.whereKey("content", value: Key.shared.searchContent_board)
        searchAgent.whereKey("source", value: Key.shared.searchSource_board)
        searchAgent.whereKey("type", value: "place")
        searchAgent.whereKey("size", value: "30")
        searchAgent.whereKey("radius", value: "\(Key.shared.radius_board)")
        searchAgent.whereKey("offset", value: "\(dataOffset)")
        searchAgent.whereKey("sort", value: [["geo_location": "asc"]])
        searchAgent.whereKey("location", value: ["latitude": locToSearch.latitude,
                                                 "longitude": locToSearch.longitude])
        searchRequest?.cancel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchRequest = searchAgent.search { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                guard status / 100 == 2 else {
                    self.fetchMoreDataStatus?(true, "Network error!")
                    return
                }
                guard message != nil else {
                    self.fetchMoreDataStatus?(true, "Network error!")
                    return
                }
                let placeInfoJSON = JSON(message!)
                guard let placeInfo = placeInfoJSON.array else {
                    self.fetchMoreDataStatus?(true, "No more data")
                    return
                }
                let searchPlaces = placeInfo.map({ PlacePin(json: $0) })
                guard searchPlaces.count > 0 else {
                    self.fetchMoreDataStatus?(true, "No more data")
                    return
                }
                self.dataOffset += searchPlaces.count
                self.places += searchPlaces
            }
        }
    }
}
