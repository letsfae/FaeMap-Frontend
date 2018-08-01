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
    func lookUpForCoordinate(cityName: String) {
        temp_board_chosen_on_map = false
        isCityDataChosen = false
        isCityDetailFetched = false
        fetchedCityDetail = nil
        cityDetailRequest?.cancel()
        activityIndicatorLocationSearch.startAnimating()
        cityDetailRequest = CitySearcher.shared.cityDetail(cityName) { [weak self] (status, location) in
            self?.activityIndicatorLocationSearch.stopAnimating()
            guard let `self` = self else { return }
            guard status / 100 == 2 else {
                return
            }
            guard let location = location as? CLLocation else {
                return
            }
            self.isCityDetailFetched = true
            self.isCityDataChosen = true
            self.temp_search_coordinate = location.coordinate
            self.fetchedCityDetail = CityData(coordinate: location.coordinate, name: cityName, attributedName: nil)
            self.faeRegion = calculateRegion(miles: 100, coordinate: location.coordinate)
            self.reloadAddressCompleterRegion()
            self.schLocationBar.txtSchField.resignFirstResponder()
            self.schPlaceBar.txtSchField.becomeFirstResponder()
            guard self.schPlaceBar != nil else { return }
            guard let searchText = self.schPlaceBar.txtSchField.text else { return }
            guard searchText != "" else { return }
            guard searchText != "Search Fae Map" else { return }
            guard searchText != "Search Place or Address" else { return }
            self.getPlaceInfo(content: searchText, source: "name")
        }
    }
    
    // Geobytes City Search AutocompleteFilter
    func placeAutocomplete(_ searchText: String) {
        citySearchRequest?.cancel()
        activityIndicatorLocationSearch.startAnimating()
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
        var radius: Int = 16100
        var locationToSearch = LocManager.shared.curtLoc.coordinate
        
        switch previousVC {
        case .map:
            locationToSearch = faeMapView.centerCoordinate
            if let locText = schLocationBar.txtSchField.text {
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                case "Current Map View":
                    locationToSearch = faeMapView.centerCoordinate
                    // radius: degree 69 * 1609.34 * 0.5
                    radius = Int(faeMapView.region.span.latitudeDelta * 55522)
                default:
                    break
                }
            }
        case .board:
            if let locText = schLocationBar.txtSchField.text {
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                default:
                    break
                }
            }
        case .chat:
            locationToSearch = faeMapView.centerCoordinate
            if let locText = schLocationBar.txtSchField.text {
                switch locText {
                case "Current Location":
                    locationToSearch = LocManager.shared.curtLoc.coordinate
                case "Current Map View":
                    locationToSearch = faeMapView.centerCoordinate
                    // radius: degree 69 * 1609.34 * 0.5
                    radius = Int(faeMapView.region.span.latitudeDelta * 55522)
                default:
                    break
                }
            }
        }
        temp_last_search_source = source
        temp_search_content = content
        temp_search_radius = radius
        temp_search_coordinate = locationToSearch
        //joshprint("[getPlaceInfo] places fetched")
        //joshprint("Content:", content)
        //joshprint("Source:", source)
        //joshprint("Radius:", radius)
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
        searchRequest?.cancel()
        searchRequest = searchAgent.search { [weak self] (status: Int, message: Any?) in
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
            //joshprint("Count:", self.searchedPlaces.count)
            //joshprint("[getPlaceInfo] end")
            if source == "name" {
                self.searchedPlaces = places
                self.showOrHideViews(searchText: content)
            } else {
                self.searchedPlaces = places
                self.isCategorySearching = false
                self.updateLastSearch()
                self.delegate?.jumpToPlaces?(searchText: content, places: self.searchedPlaces)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
