//
//  MBPlaceTabLeftViewModel.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class BoardPlaceTabLeftViewModel {
    let realm = try! Realm()
    let arrCategories: [String] = ["Food", "Drinks", "Shopping", "Outdoors", "Recreation"]
    var arrTitles: [String] = []
    
    var location: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate {
        didSet {
//            let from = CLLocation(latitude: oldValue.latitude, longitude: oldValue.longitude)
//            let to = CLLocation(latitude: location.latitude, longitude: location.longitude)
//            if to.distance(from: from) > 282 {
            recommendCategories = []
            arrTitles = []
            
            searchRecommend(latitude: location.latitude, longitude: location.longitude) {
                self.searchByCategories(latitude: self.location.latitude, longitude: self.location.longitude)
            }
//            }
        }
    }
    
    var recommendCategories: [[PlacePin]] = [] {
        didSet {
            categoriesDataLoaded?(recommendCategories)
        }
    }
    var categoriesDataLoaded: (([[PlacePin]]) -> ())?
    
    var numberOfCategories: Int {
        return recommendCategories.count
    }
    
    // MARK: - Methods
    private func categoryPlaces(at index: Int) -> [PlacePin]? {
        guard index < recommendCategories.count else { return nil }
        let category = recommendCategories[index]
        return category
    }
    
    func viewModel(for index: Int) -> BoardPlaceCategoryViewModel? {
        let title = self.arrTitles[index]
        guard let categoryPlace = self.categoryPlaces(at: index) else { return nil }
        return BoardPlaceCategoryViewModel(title: title, places: categoryPlace)
    }
    
    private func searchRecommend(latitude: CLLocationDegrees, longitude: CLLocationDegrees, _ completion: @escaping () -> Void) {
        let realmCategory = realm.filterMyCatDict()
        vickyprint(realmCategory)
        if realmCategory.isEmpty || realmCategory.first!.weight < 0.1 {
            completion()
            return
        }
        var recommendPlaces = [PlacePin]()
        var recommendSet = Set<PlacePin>()
        let count = min(5, realmCategory.count)
        for idx in 0..<count {
            let content = realmCategory[idx].name
            // check whether it belongs to class_one
            let source = Category.shared.class1_to_2[content] == nil ? "categories" : "class_one"
            FaeSearch.shared.whereKey("content", value: content)
            FaeSearch.shared.whereKey("source", value: source)
            FaeSearch.shared.whereKey("type", value: "place")
            FaeSearch.shared.whereKey("size", value: "15")
            FaeSearch.shared.whereKey("radius", value: "100000")
            FaeSearch.shared.whereKey("offset", value: "0")
//            FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
            FaeSearch.shared.whereKey("location", value: ["latitude": latitude,
                                                          "longitude": longitude])
            FaeSearch.shared.searchContent.append(FaeSearch.shared.keyValue)
        }
        
        FaeSearch.shared.searchBulk { [weak self] (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                completion()
                return
            }
            let json = JSON(message!)
//            vickyprint(json)
            guard let placesJson = json.array else { return }
            
            for places in placesJson {
                guard let recommendJson = places.array else { return }
                if recommendJson.isEmpty {
                    continue
                }
                let recommend = recommendJson.map( { PlacePin(json: $0) } )
                recommendSet = recommendSet.union(recommend)
                if recommendSet.count >= 15 {
                    recommendPlaces = Array(recommendSet.prefix(15))
                    break
                }
            }
            
            if recommendPlaces.isEmpty {
                completion()
                return
            }
            self?.arrTitles.append("Recommended")
            self?.recommendCategories.append(recommendPlaces)
            completion()
        }
    }
    
    private func searchByCategories(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        for category in arrCategories {
            FaeSearch.shared.whereKey("content", value: category)
            FaeSearch.shared.whereKey("source", value: "class_one")
            FaeSearch.shared.whereKey("type", value: "place")
            FaeSearch.shared.whereKey("size", value: "15")
            FaeSearch.shared.whereKey("radius", value: "100000")
            FaeSearch.shared.whereKey("offset", value: "0")
            FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
            FaeSearch.shared.whereKey("location", value: ["latitude": latitude,
                                                          "longitude": longitude])
            FaeSearch.shared.searchContent.append(FaeSearch.shared.keyValue)
        }
        
        FaeSearch.shared.searchBulk{ [weak self] (status, message) in
            guard let `self` = self else { return }
            guard status / 100 == 2 && message != nil else {
                print("Board - Get Recommended Places Fail \(status) \(message!)")
                return
            }
            let json = JSON(message!)
            //                vickyprint(json)
            guard let placesJson = json.array else { return }
            vickyprint("placesJson \(placesJson.count)")
            
            for idx in 0..<placesJson.count {
                guard let nearbyJson = placesJson[idx].array else { return }
                
                let nearby = nearbyJson.map( { PlacePin(json: $0) } )
                if nearby.isEmpty {
                    continue
                }
                self.arrTitles.append("Nearby \(self.arrCategories[idx])")
                self.recommendCategories.append(nearby)
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
