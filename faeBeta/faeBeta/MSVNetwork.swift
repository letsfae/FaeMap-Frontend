//
//  MSVNetwork.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension MapSearchViewController: MKLocalSearchCompleterDelegate {
    
    func loadAddressCompleter() {
        addressCompleter.delegate = self
    }
    
    func getAddresses(content searchText: String) {
        activityStatus(isOn: true)
        flagAddrFetched = false
        addressCompleter.cancel()
        addressCompleter.queryFragment = searchText
    }
    
    // MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("addresses fetched")
        flagAddrFetched = true
        searchedAddresses = completer.results
        print("addresses fetched - count:", searchedAddresses.count)
        showOrHideViews(searchText: completer.queryFragment)
    }
    
    // MKLocalSearchCompleterDelegate
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
        print("addr fetching failed", error.localizedDescription)
        flagAddrFetched = true
        searchedAddresses = completer.results
        print("addr fetching failed - count:", searchedAddresses.count)
        showOrHideViews(searchText: completer.queryFragment)
    }
    
    //
    func lookUpForCoordinate() {
        
    }
    
    // GMSAutocompleteFilter
    func placeAutocomplete(_ searchText: String) {
        Key.shared.selectedSearchedCity = nil
        CitySearcher.shared.cityAutoComplete(searchText) { (status, result) in
            self.geobytesCityData.removeAll()
            guard status / 100 == 2 else {
                self.showOrHideViews(searchText: searchText)
                return
            }
            guard let result = result else {
                self.showOrHideViews(searchText: searchText)
                return
            }
            joshprint("got data from geobytes")
            let value = JSON(result)
            let citys = value.arrayValue
            for city in citys {
                if city.stringValue == "%s" || city.stringValue == "" {
                    break
                }
                self.geobytesCityData.append(city.stringValue)
                
            }
            self.showOrHideViews(searchText: searchText)
        }
    }
    
    func getPlaceInfo(content: String = "", source: String = "name") {
        activityStatus(isOn: true)
        guard content != "" else {
            showOrHideViews(searchText: content)
            return
        }
        flagPlaceFetched = false
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "5")
        FaeSearch.shared.whereKey("radius", value: "10000")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
        FaeSearch.shared.whereKey("location", value: ["latitude": LocManager.shared.searchedLoc.coordinate.latitude,
                                                      "longitude": LocManager.shared.searchedLoc.coordinate.longitude])
        FaeSearch.shared.search { [weak self] (status: Int, message: Any?) in
            print("places fetched")
            guard let `self` = self else { return }
            self.flagPlaceFetched = true
            if status / 100 != 2 || message == nil {
                self.searchedPlaces.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: content)
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                self.searchedPlaces.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: content)
                return
            }
            self.searchedPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
            if source == "name" {
                self.showOrHideViews(searchText: content)
            } else {
                self.delegate?.jumpToPlaces?(searchText: content, places: self.searchedPlaces)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
