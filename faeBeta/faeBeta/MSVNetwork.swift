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
        CitySearcher.shared.cityDetail(cityData) { [weak self] (status, location) in
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
        Key.shared.selectedSearchedCity = nil
        CitySearcher.shared.cityAutoComplete(searchText) { [weak self] (status, result) in
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
                joshprint("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    joshprint("[searchArea] Current Location")
                case "Current Map View":
                    locationToSearch = faeMapView.centerCoordinate
                    // radius: degree 69 * 1609.34 * 2, 4 times bigger of current map
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    joshprint("[searchArea] Current Map View")
                default:
                    joshprint("[searchArea] other")
                    break
                }
            }
            LocManager.shared.locToSearch_map = locationToSearch
        case .board:
            //radius = 160934
            if let locToSearch = LocManager.shared.locToSearch_board {
                locationToSearch = locToSearch
            }
            if let locText = schLocationBar.txtSchField.text {
                joshprint("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    joshprint("[searchArea] Current Location")
                default:
                    joshprint("[searchArea] other")
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
                joshprint("[locText]", locText)
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    joshprint("[searchArea] Current Location")
                case "Current Map View":
                    locationToSearch = faeMapView.centerCoordinate
                    // radius: degree 69 * 1609.34 * 2, 4 times bigger of current map
                    radius = Int(faeMapView.region.span.latitudeDelta * 222090)
                    joshprint("[searchArea] Current Map View")
                default:
                    joshprint("[searchArea] other")
                    break
                }
            }
            LocManager.shared.locToSearch_chat = locationToSearch
        }
        
        flagPlaceFetched = false
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "200")
        FaeSearch.shared.whereKey("radius", value: "\(radius)")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
        FaeSearch.shared.whereKey("location", value: ["latitude": locationToSearch.latitude,
                                                      "longitude": locationToSearch.longitude])
        FaeSearch.shared.search { [weak self] (status: Int, message: Any?) in
            joshprint("places fetched")
            guard let `self` = self else { return }
            //self.flagPlaceFetched = true
            if status / 100 != 2 || message == nil {
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
            self.searchedPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
            if source == "name" {
                self.showOrHideViews(searchText: content)
            } else {
                self.isCategorySearching = false
                self.delegate?.jumpToPlaces?(searchText: content, places: self.searchedPlaces)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
