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
            if boolFromChat {
                let selectedPlace = searchedPlaces[indexPath.row]
                delegate?.selectPlace?(place: selectedPlace)
                navigationController?.popViewController(animated: false)
            } else {
                switch indexPath.section {
                case 0:
                    let selectedCat = filteredCategory[indexPath.row].key
                    getPlaceInfo(content: selectedCat, source: "categories")
                case 1:
                    let selectedPlace = searchedPlaces[indexPath.row]
                    schPlaceBar.txtSchField.resignFirstResponder()
                    let vc = PlaceDetailViewController()
                    vc.place = selectedPlace
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    let address = searchedAddresses[indexPath.row]
                    let coder = CLGeocoder()
                    coder.geocodeAddressString(address.title+", "+address.subtitle, in: nil) { [weak self] (results, error) in
                        guard let `self` = self else { return }
                        guard error == nil else {
                            print("[MSVC][geocodeAddressString]", error!.localizedDescription)
                            return
                        }
                        guard let placeMarks = results else { return }
                        guard let first = placeMarks.first else { return }
                        guard let loc = first.location else { return }
                        self.delegate?.selectLocation?(location: loc)
                        self.navigationController?.popViewController(animated: false)
                    }
                    
                    break
                }
            }
        case .location:
            if tableView == tblLocationRes {
                // search location
                schLocationBar.txtSchField.attributedText = geobytesCityData[indexPath.row].faeSearchBarAttributedText()
                Key.shared.selectedSearchedCity = geobytesCityData[indexPath.row]
                schLocationBar.txtSchField.resignFirstResponder()
                schPlaceBar.txtSchField.becomeFirstResponder()
                schLocationBar.btnClose.isHidden = true
                CitySearcher.shared.cityDetail(geobytesCityData[indexPath.row]) { [weak self] (status, location) in
                    guard let `self` = self else { return }
                    guard status / 100 == 2 else {
                        return
                    }
                    guard let location = location as? CLLocation else {
                        return
                    }
                    LocManager.shared.locToSearch_map = location.coordinate
                    self.faeRegion = calculateRegion(miles: 100, coordinate: location.coordinate)
                    self.reloadAddressCompleterRegion()
                    guard self.schPlaceBar != nil else { return }
                    guard let searchText = self.schPlaceBar.txtSchField.text else { return }
                    guard searchText != "Search Fae Map" else { return }
                    guard searchText != "Search Place or Address" else { return }
                    self.getPlaceInfo(content: searchText, source: "name")
                }
            } else {
                // fixed cell - "Use my Current Location", "Use Current Map View"
                schLocationBar.txtSchField.attributedText = nil
                schLocationBar.txtSchField.text = indexPath.row == 0 ? "Current Location" : "Current Map View"
                Key.shared.selectedSearchedCity = indexPath.row == 0 ? "Current Location" : "Current Map View"
                schLocationBar.txtSchField.resignFirstResponder()
                schLocationBar.btnClose.isHidden = true
                if indexPath.row == 0 {
                    let curLoc = LocManager.shared.curtLoc.coordinate
                    LocManager.shared.locToSearch_map = curLoc
                    faeRegion = calculateRegion(miles: 100, coordinate: curLoc)
                } else {
                    LocManager.shared.locToSearch_map = faeMapView.centerCoordinate
                    faeRegion = calculateRegion(miles: 100, coordinate: faeMapView.centerCoordinate)
                }
                reloadAddressCompleterRegion()
                guard let searchText = schPlaceBar.txtSchField.text else { return }
                guard searchText != "Search Fae Map" else { return }
                guard searchText != "Search Place or Address" else { return }
                self.getPlaceInfo(content: searchText, source: "name")
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
