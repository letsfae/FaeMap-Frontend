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
    
    func sendBackLocationText() {
        guard previousVC == .board else { return }
        guard let locText = Key.shared.selectedSearchedCity_board else { return }
        changeLocBarText?(locText, locText != "Current Location")
    }
    
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
        joshprint("addresses fetched")
        flagAddrFetched = true
        searchedAddresses = completer.results.filter({ $0.subtitle != "Search Nearby" })
        joshprint("addresses fetched - count:", searchedAddresses.count)
        showOrHideViews(searchText: completer.queryFragment)
    }
    
    // MKLocalSearchCompleterDelegate
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
        guard previousVC != .board else { return }
        joshprint("addr fetching failed", error.localizedDescription)
        flagAddrFetched = true
        searchedAddresses = completer.results
        joshprint("addr fetching failed - count:", searchedAddresses.count)
        showOrHideViews(searchText: completer.queryFragment)
    }
    
    // Look for coordinate
    func lookUpForCoordinate(cityData: String) {
        activityIndicatorLocationSearch.startAnimating()
        cityDetailRequest = CitySearcher.shared.cityDetail(cityData) { [weak self] (status, location) in
            self?.activityIndicatorLocationSearch.stopAnimating()
            guard let `self` = self else { return }
            guard status / 100 == 2 else {
                return
            }
            guard let location = location as? CLLocation else {
                return
            }
            switch self.previousVC {
            case .map:
                LocManager.shared.locToSearch_map = location.coordinate
            case .board:
                LocManager.shared.locToSearch_board = location.coordinate
            case .chat:
                LocManager.shared.locToSearch_chat = location.coordinate
            }
            self.faeRegion = calculateRegion(miles: 100, coordinate: location.coordinate)
            self.reloadAddressCompleterRegion()
            guard self.schPlaceBar != nil else { return }
            guard let searchText = self.schPlaceBar.txtSchField.text else { return }
            guard searchText != "Search Fae Map" else { return }
            guard searchText != "Search Place or Address" else { return }
            self.getPlaceInfo(content: searchText, source: "name")
        }
    }
    
    // Geobytes City Search AutocompleteFilter
    func placeAutocomplete(_ searchText: String) {
        activityIndicatorLocationSearch.startAnimating()
        switch previousVC {
        case .map:
            Key.shared.selectedSearchedCity_map = nil
        case .board:
            Key.shared.selectedSearchedCity_board = nil
        case .chat:
            Key.shared.selectedSearchedCity_chat = nil
        }
        citySearchRequest = CitySearcher.shared.cityAutoComplete(searchText) { [weak self] (status, result) in
            self?.activityIndicatorLocationSearch.stopAnimating()
            guard let `self` = self else { return }
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
        if source == "categories" {
            isCategorySearching = true
        }
        activityStatus(isOn: true)
        guard !content.isEmpty else {
            showOrHideViews(searchText: content)
            return
        }
        var radius: Int = 100000
        var locationToSearch = CLLocationCoordinate2D(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        
        switch previousVC {
        case .map:
            locationToSearch = faeMapView.centerCoordinate
            if let locToSearch = LocManager.shared.locToSearch_map {
                locationToSearch = locToSearch
            }
            if let locText = schLocationBar.txtSchField.text {
                //joshprint("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    //joshprint("[searchArea] Current Location")
                case "Current Map View":
                    locationToSearch = faeMapView.centerCoordinate
                    // radius: degree 69 * 1609.34 * 2, 4 times bigger of current map
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    //joshprint("[searchArea] Current Map View")
                default:
                    //joshprint("[searchArea] other")
                    break
                }
            }
            LocManager.shared.locToSearch_map = locationToSearch
            Key.shared.radius_map = radius
            Key.shared.searchContent_map = content
            Key.shared.searchSource_map = source
        case .board:
            //radius = 160934
            if let locToSearch = LocManager.shared.locToSearch_board {
                locationToSearch = locToSearch
            }
            if let locText = schLocationBar.txtSchField.text {
                //joshprint("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    //joshprint("[searchArea] Current Location")
                default:
                    //joshprint("[searchArea] other")
                    break
                }
            }
            LocManager.shared.locToSearch_board = locationToSearch
        case .chat:
            locationToSearch = faeMapView.centerCoordinate
            if let locToSearch = LocManager.shared.locToSearch_chat {
                locationToSearch = locToSearch
            }
            if let locText = schLocationBar.txtSchField.text {
                //joshprint("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    //joshprint("[searchArea] Current Location")
                case "Current Map View":
                    locationToSearch = faeMapView.centerCoordinate
                    // radius: degree 69 * 1609.34 * 2, 4 times bigger of current map
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    //joshprint("[searchArea] Current Map View")
                default:
                    //joshprint("[searchArea] other")
                    break
                }
            }
            LocManager.shared.locToSearch_chat = locationToSearch
            Key.shared.radius_chat = radius
            Key.shared.searchContent_chat = content
            Key.shared.searchSource_chat = source
        }
        joshprint("[getPlaceInfo] places fetched")
        joshprint("Content:", content)
        joshprint("Source:", source)
        joshprint("Radius:", radius)
        flagPlaceFetched = false
        let searchAgent = FaeSearch()
        searchAgent.whereKey("content", value: content)
        searchAgent.whereKey("source", value: source)
        searchAgent.whereKey("type", value: "place")
        searchAgent.whereKey("size", value: "20")
        searchAgent.whereKey("radius", value: "\(radius)")
        searchAgent.whereKey("offset", value: "0")
        searchAgent.whereKey("sort", value: [["_score": "desc"], ["geo_location": "asc"]])
        searchAgent.whereKey("location", value: ["latitude": locationToSearch.latitude,
                                                 "longitude": locationToSearch.longitude])
        searchRequest = searchAgent.search { [weak self] (status: Int, message: Any?) in
            //joshprint("places fetched")
            guard let `self` = self else { return }
            self.flagPlaceFetched = true
            guard status / 100 == 2 else {
                self.isCategorySearching = false
                self.searchedPlaces.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: content)
                return
            }
            guard message != nil else {
                self.isCategorySearching = false
                self.searchedPlaces.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: content)
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                self.isCategorySearching = false
                self.searchedPlaces.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: content)
                return
            }
            let places = placeInfoJsonArray.map({ PlacePin(json: $0) })
            joshprint("Count:", self.searchedPlaces.count)
            joshprint("[getPlaceInfo] end")
            print("")
            if source == "name" {
                self.searchedPlaces = places
                self.showOrHideViews(searchText: content)
            } else {
                self.searchedPlaces = places
                // if source == "categories"
//                self.searchedPlaces.removeAll(keepingCapacity: true)
//                for place in places {
//                    if place.category.lowercased().contains(content.lowercased()) {
//                        self.searchedPlaces.append(place)
//                    }
//                }
                self.isCategorySearching = false
                self.delegate?.jumpToPlaces?(searchText: content, places: self.searchedPlaces)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
