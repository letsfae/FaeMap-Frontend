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
    
    func reloadAddressCompleterRegion() {
        if let region = faeRegion {
            addressCompleter.region = region
        }
    }
    
    func getAddresses(content searchText: String) {
        activityStatus(isOn: true)
        flagAddrFetched = false
        addressCompleter.cancel()
        addressCompleter.queryFragment = searchText
    }
    
    // MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard previousVC != .board else { return }
        print("addresses fetched")
        flagAddrFetched = true
        searchedAddresses = completer.results.filter({ $0.subtitle != "Search Nearby" })
        print("addresses fetched - count:", searchedAddresses.count)
        showOrHideViews(searchText: completer.queryFragment)
    }
    
    // MKLocalSearchCompleterDelegate
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
        guard previousVC != .board else { return }
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
        guard !content.isEmpty else {
            showOrHideViews(searchText: content)
            return
        }
        var radius: Int = 16666
        var locationToSearch = CLLocationCoordinate2D(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        
        switch previousVC {
        case .map:
            locationToSearch = faeMapView.centerCoordinate
            if let locToSearch = LocManager.shared.locToSearch_map {
                locationToSearch = locToSearch
            }
            if let locText = schLocationBar.txtSchField.text {
                print("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    print("[searchArea] Current Location")
                case "Current Map View":
                    locationToSearch = faeMapView.centerCoordinate
                    // radius: degree 69 * 1609.34 * 2, 4 times bigger of current map
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    print("[searchArea] Current Map View")
                default:
                    print("[searchArea] other")
                    break
                }
            }
        case .board:
            radius = 160934
            if let locToSearch = LocManager.shared.locToSearch_board {
                locationToSearch = locToSearch
            }
            if let locText = schLocationBar.txtSchField.text {
                print("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    print("[searchArea] Current Location")
                default:
                    print("[searchArea] other")
                    break
                }
            }
        case .chat:
            locationToSearch = faeMapView.centerCoordinate
            if let locToSearch = LocManager.shared.locToSearch_chat {
                locationToSearch = locToSearch
            }
            if let locText = schLocationBar.txtSchField.text {
                print("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    print("[searchArea] Current Location")
                case "Current Map View":
                    locationToSearch = faeMapView.centerCoordinate
                    // radius: degree 69 * 1609.34 * 2, 4 times bigger of current map
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    print("[searchArea] Current Map View")
                default:
                    print("[searchArea] other")
                    break
                }
            }
        }
        
        flagPlaceFetched = false
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "20")
        FaeSearch.shared.whereKey("radius", value: "\(radius)")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
        FaeSearch.shared.whereKey("location", value: ["latitude": locationToSearch.latitude,
                                                      "longitude": locationToSearch.longitude])
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
