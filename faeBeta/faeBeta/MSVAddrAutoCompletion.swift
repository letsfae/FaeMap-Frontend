//
//  MSVAddrAutoCompletion.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces

extension MapSearchViewController: MKLocalSearchCompleterDelegate {
    
    // GMSLookUpPlaceForCoordinate
    func lookUpForCoordinate() {
        General.shared.lookUpForCoordinate { (place) in
            let region = MKCoordinateRegionMakeWithDistance(place.coordinate, 20000, 20000)
            self.delegate?.jumpToLocation?(region: region)
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    // GMSAutocompleteFilter
    func placeAutocomplete(_ searchText: String) {
        Key.shared.selectedSearchedCity = nil
        CitySearcher.shared.cityAutoComplete(searchText) { (status, result) in
            self.geobytesCityData.removeAll()
            guard status / 100 == 2 else {
                // TODO YUE
                self.showOrHideViews(searchText: searchText)
                return
            }
            guard let result = result else {
                // TODO YUE
                self.showOrHideViews(searchText: searchText)
                return
            }
            let value = JSON(result)
            let citys = value.arrayValue
            for city in citys {
                joshprint(city.stringValue)
                if city.stringValue == "%s" || city.stringValue == "" {
                    break
                }
                self.geobytesCityData.append(city.stringValue)
                
            }
            self.showOrHideViews(searchText: searchText)
        }
        // 以下为Google Place API 使用的代码
//        Key.shared.selectedPrediction = nil
//        googleFilter.type = .city
//        GMSPlacesClient.shared().autocompleteQuery(searchText, bounds: nil, filter: googleFilter, callback: {(results, error) -> Void in
//            if let error = error {
//                joshprint("Autocomplete error \(error)")
//                self.googlePredictions.removeAll(keepingCapacity: true)
//                self.showOrHideViews(searchText: searchText)
//                return
//            }
//            if let results = results {
//                self.googlePredictions = results
//            }
//            self.showOrHideViews(searchText: searchText)
//        })
    }
    
    // MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        filteredLocations = searchResults.map({ $0.title })
        tblLocationRes.reloadData()
        showOrHideViews(searchText: completer.queryFragment)
    }
    
    // MKLocalSearchCompleterDelegate
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}
