//
//  MSVTableCtrl.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // search location
        let section = indexPath.section
        let isLast = indexPath.row == tableView.numberOfRows(inSection: section) - 1
        switch schBarType {
        case .place:
            guard tableView == tblPlacesRes else {
                return UITableViewCell()
            }
            if section == 0 {
                // search category
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCategories", for: indexPath) as! CategoryListCell
                if filteredCategory.isEmpty {
                    return cell
                }
                cell.configureCell(filteredCategory[indexPath.row], last: isLast && searchedPlaces.count == 0 && searchedAddresses.count == 0)
                return cell
            } else
            if section == 1 {
                // search places
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaces", for: indexPath) as! PlacesListCell
                cell.configureCell(searchedPlaces[indexPath.row], last: isLast && searchedPlaces.count == 0 && searchedAddresses.count == 0)
                return cell
            } else {
                // search addresses
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchAddresses", for: indexPath) as! PlacesListCell
                cell.configureCell(searchedAddresses[indexPath.row], last: isLast)
                return cell
            }
        case .location:
            if tableView == tblLocationRes {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocation", for: indexPath) as! LocationListCell
                cell.configureCell(geobytesCityData[indexPath.row], last: isLast)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyFixedCell", for: indexPath) as! LocationListCell
                cell.configureCell(fixedLocOptions[indexPath.row], last: isLast)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch schBarType {
        case .place:
            switch indexPath.section {
            case 0:
                // category
                let selectedCat = filteredCategory[indexPath.row].key
                if previousVC == .board {
                    updateLastSearch()
                    delegate?.jumpToCategory?(category: selectedCat)
                    navigationController?.popViewController(animated: false)
                } else {
                    getPlaceInfo(content: selectedCat, source: "categories")
                }
                
                // update Category Dictionary
                guard !Key.shared.is_guest else {
                    return
                }
                Category.shared.visitCategory(category: selectedCat)
            case 1:
                // place
                let selectedPlace = searchedPlaces[indexPath.row]
                if previousVC == .chat {
                    updateLastSearch()
                    delegate?.selectPlace?(place: selectedPlace)
                    navigationController?.popViewController(animated: false)
                } else {
                    schPlaceBar.txtSchField.resignFirstResponder()
                    let vc = PlaceDetailViewController()
                    vc.place = selectedPlace
                    navigationController?.pushViewController(vc, animated: true)
                }
            default:
                // address
                let address = searchedAddresses[indexPath.row]
                clgeocoder.cancelGeocode()
                clgeocoder.geocodeAddressString(address.title+", "+address.subtitle, in: nil) { [weak self] (results, error) in
                    guard let `self` = self else { return }
                    guard error == nil else {
                        showAlert(title: "Unexpected Error", message: "please try again later", viewCtrler: self)
                        return
                    }
                    guard let placeMarks = results else { return }
                    guard let first = placeMarks.first else { return }
                    guard let loc = first.location else { return }
                    self.updateLastSearch()
                    self.delegate?.selectLocation?(location: loc)
                    self.navigationController?.popViewController(animated: false)
                }
            }
        case .location:
            if tableView == tblLocationRes {
                // search location
                schLocationBar.txtSchField.attributedText = geobytesCityData[indexPath.row].faeSearchBarAttributedText()
                temp_search_city_string = geobytesCityData[indexPath.row]
                schLocationBar.btnClear.isHidden = true
                lookUpForCoordinate(cityName: geobytesCityData[indexPath.row])
            } else {
                let row = indexPath.row
                // fixed cell - "Use my Current Location", "Use Current Map View" or "Choose on Map"
                schLocationBar.txtSchField.attributedText = nil
                schLocationBar.reloadTextFieldAttributes()
                if row == 1 && previousVC == .board { // choose on map
                    let vc = SelectLocationViewController()
                    vc.previousVC = .board
                    vc.delegate = self
                    vc.mode = .part
                    navigationController?.pushViewController(vc, animated: false)
                } else {
                    let locText = row == 0 ? "Current Location" : "Current Map View"
                    schLocationBar.txtSchField.text = locText
                    temp_search_city_string = locText
                    strPreviousFixedOptionSelection = locText
                    schLocationBar.txtSchField.resignFirstResponder()
                    schPlaceBar.txtSchField.becomeFirstResponder()
                    schLocationBar.btnClear.isHidden = true
                    if row == 0 {
                        temp_board_chosen_on_map = false
                        let curLoc = LocManager.shared.curtLoc.coordinate
                        temp_search_coordinate = curLoc
                        faeRegion = calculateRegion(miles: 100, coordinate: curLoc)
                    } else {
                        temp_search_coordinate = faeMapView.centerCoordinate
                        faeRegion = calculateRegion(miles: 100, coordinate: faeMapView.centerCoordinate)
                    }
                    reloadAddressCompleterRegion()
                    guard let searchText = schPlaceBar.txtSchField.text else { return }
                    guard searchText != "" else { return }
                    guard searchText != "Search Fae Map" else { return }
                    guard searchText != "Search Place or Address" else { return }
                    self.getPlaceInfo(content: searchText, source: "name")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch schBarType {
        case .place:
            let cateCnt = filteredCategory.count > 2 ? 2 : filteredCategory.count
            let placeCnt =  searchedPlaces.count > 13 ? 13 : searchedPlaces.count
            let addrCnt = searchedAddresses.count > 13 ? 13 : searchedAddresses.count
            switch section {
            case 0:
                return cateCnt
            case 1:
                if cateCnt == 0 && addrCnt == 0 {
                    return placeCnt
                } else if cateCnt == 0 && addrCnt > 0 {
                    return placeCnt > 8 ? 8 : placeCnt
                } else if cateCnt > 0 && addrCnt == 0 {
                    if cateCnt + placeCnt > 13 {
                        return 13 - cateCnt
                    }
                    return placeCnt
                } else {
                    return placeCnt > 6 ? 6 : placeCnt
                }
            default:
                if placeCnt > 0 {
                    return addrCnt > 5 ? 5 : addrCnt
                } else if cateCnt > 0 && placeCnt == 0 {
                    if cateCnt + addrCnt > 13 {
                        return 13 - cateCnt
                    }
                    return addrCnt
                } else {
                    return addrCnt
                }
            }
        case .location:
            return tableView == tblLocationRes ? geobytesCityData.count : fixedLocOptions.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch schBarType {
        case .place:
            if tableView == tblPlacesRes {
                return 3
            }
            return 1
        case .location:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return schBarType == .place ? 68 : 48
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schPlaceBar.txtSchField.resignFirstResponder()
        schLocationBar.txtSchField.resignFirstResponder()
    }
}

extension MapSearchViewController {
 
    func updateLastSearch() {
        updateLastSearchedLocation(coordinate: temp_search_coordinate)
        updateLastSearchedCity(city: temp_search_city_string)
        updateLastSearchedRadius(radius: temp_search_radius)
        updateLastSearchedSource(source: temp_last_search_source)
        updateLastSearchedContent(content: temp_search_content)
        Key.shared.isChosenOnMap = temp_board_chosen_on_map
        sendBackLocationText()
    }
    
    func updateLastSearchedContent(content: String?) {
        switch previousVC {
        case .map:
            Key.shared.searchContent_map = content
        case .board:
            Key.shared.searchContent_board = content
        case .chat:
            Key.shared.searchContent_chat = content
        }
    }
    
    func updateLastSearchedSource(source: String?) {
        switch previousVC {
        case .map:
            Key.shared.searchSource_map = source
        case .board:
            Key.shared.searchSource_board = source
        case .chat:
            Key.shared.searchSource_chat = source
        }
    }
    
    func updateLastSearchedLocation(coordinate: CLLocationCoordinate2D?) {
        switch previousVC {
        case .map:
            LocManager.shared.locToSearch_map = coordinate
        case .board:
            LocManager.shared.locToSearch_board = coordinate
        case .chat:
            LocManager.shared.locToSearch_chat = coordinate
        }
    }
    
    func updateLastSearchedRadius(radius: Int?) {
        switch previousVC {
        case .map:
            Key.shared.radius_map = radius
        case .board:
            Key.shared.radius_board = radius
        case .chat:
            Key.shared.radius_chat = radius
        }
    }
    
    func updateLastSearchedCity(city: String?) {
        switch previousVC {
        case .map:
            Key.shared.selectedSearchedCity_map = city
        case .board:
            Key.shared.selectedSearchedCity_board = city
        case .chat:
            Key.shared.selectedSearchedCity_chat = city
        }
    }
    
    func sendBackLocationText() {
        guard previousVC == .board else { return }
        if let city = temp_search_city_string {
            changeLocBarText?(city, city != "Current Location")
        } else {
            changeLocBarText?("Current Location", false)
        }
    }
}

extension MapSearchViewController: SelectLocationDelegate {
    // MARK: - SelectLocationDelegate
    func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation) {
        temp_search_coordinate = location.coordinate
        isCityDataChosen = true
        isCityDetailFetched = true
        let toArray = searchText.components(separatedBy: "@")
        let backToString = toArray.joined(separator: ",")
        temp_search_city_string = backToString
        temp_board_chosen_on_map = true
        fetchedCityDetail = CityData(coordinate: location.coordinate, name: searchText, attributedName: nil)
        if let attrText = processLocationName(separator: "@", text: searchText, size: 16) {
            schLocationBar.txtSchField.attributedText = attrText
        } else {
            fatalError("Processing Location Name Fail, Need To Check Function")
        }
        schPlaceBar.txtSchField.becomeFirstResponder()
    }
}
