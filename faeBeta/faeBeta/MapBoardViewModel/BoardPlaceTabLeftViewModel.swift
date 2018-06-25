//
//  MBPlaceTabLeftViewModel.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class BoardPlaceTabLeftViewModel {
    let arrCategories: [String] = ["Food", "Drinks", "Shopping", "Outdoors", "Recreation"]
    var arrCategory: [String] = []
    
    var location: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate {
        didSet {
            categoryToPlaces = [:]
            for category in arrCategories {
                searchByCategories(content: category, latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    var categoryToPlaces: [String : [PlacePin]] = [:] {
        didSet {
            categoriesDataLoaded?(categoryToPlaces)
        }
    }
    var categoriesDataLoaded: (([String : [PlacePin]]) -> ())?
    
    var numberOfCategories: Int {
        return categoryToPlaces.count
    }
    
    // MARK: - Methods
    private func categoryPlaces(at index: Int) -> (String, [PlacePin]?) {
        guard index < categoryToPlaces.count else { return ("", nil) }
        let category = arrCategory[index]
        if categoryToPlaces[category] == nil {
            return ("", nil)
        }
        
        return (category, categoryToPlaces[category])
    }
    
    func viewModel(for index: Int) -> BoardPlaceCategoryViewModel? {
        let (title, categoryPlaces) = self.categoryPlaces(at: index)
        guard let places = categoryPlaces else { return nil }
        return BoardPlaceCategoryViewModel(title: "Nearby \(title)", places: places)
    }
    
    
    private func searchByCategories(content: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        var placePins: [PlacePin] = []
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: "categories")
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "20")
        FaeSearch.shared.whereKey("radius", value: "100000")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
        FaeSearch.shared.whereKey("location", value: ["latitude": latitude,
                                                      "longitude": longitude])
        FaeSearch.shared.search { [weak self] (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfo = placeInfoJSON.array else {
                return
            }
            
            placePins = placeInfo.map({ PlacePin(json: $0) })
            guard let `self` = self else { return }
            
            if placePins.count > 0 {
                self.arrCategory.append(content)
                self.categoryToPlaces[content] = placePins
            }
        }
    }
}

struct BoardPlaceCategoryViewModel {
    var title: String
    var places: [PlacePin]
    var numberOfPlaces: Int {
        return places.count
    }
    
    // MARK: - Methods
    private func place(at index: Int) -> PlacePin? {
        guard index < places.count else { return nil }
        return places[index]
    }
    
    func viewModel(for index: Int) -> BoardPlaceViewModel? {
        guard let place = place(at: index) else { return nil }
        return BoardPlaceViewModel(place: place)
    }
}
