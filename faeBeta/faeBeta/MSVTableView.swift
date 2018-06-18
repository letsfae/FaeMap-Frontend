//
//  MSVTableCtrl.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schPlaceBar.txtSchField.resignFirstResponder()
        schLocationBar.txtSchField.resignFirstResponder()
    }
    
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
                cell.configureCell(filteredCategory[indexPath.row], last: isLast && searchedPlaces.count == 0)
                return cell
            } else
            if section == 1 {
                // search places
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaces", for: indexPath) as! PlacesListCell
                cell.configureCell(searchedPlaces[indexPath.row], last: isLast && searchedAddresses.count == 0)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch schBarType {
        case .place:
            switch section {
            case 0:
                return filteredCategory.count >= 2 ? 2 : filteredCategory.count
            case 1:
                return searchedPlaces.count
            default:
                return searchedAddresses.count
            }
        case .location:
            return tableView == tblLocationRes ? geobytesCityData.count : fixedLocOptions.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return schBarType == .place ? 68 : 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch schBarType {
        case .place:
            let selectedPlace = searchedPlaces[indexPath.row]
            if boolFromChat {
                delegate?.selectPlace?(place: selectedPlace)
                navigationController?.popViewController(animated: false)
            } else {
                switch indexPath.section {
                case 0:
                    let selectedCat = filteredCategory[indexPath.row].key
                    getPlaceInfo(content: selectedCat, source: "categories")
                case 1:
                    schPlaceBar.txtSchField.resignFirstResponder()
                    let vc = PlaceDetailViewController()
                    vc.place = selectedPlace
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    let vc = LocDetailViewController()
                    navigationController?.pushViewController(vc, animated: true)
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
                CitySearcher.shared.cityDetail(geobytesCityData[indexPath.row]) { (status, location) in
                    guard status / 100 == 2 else {
                        return
                    }
                    guard let location = location as? CLLocation else {
                        return
                    }
                    LocManager.shared.searchedLoc = location
                    if self.schPlaceBar == nil || self.schPlaceBar.txtSchField.text == "Search Fae Map"
                        || self.schPlaceBar.txtSchField.text == "Search Place or Address" {
                        return
                    }
                    self.getPlaceInfo(content: self.schPlaceBar.txtSchField.text!, source: "name")
                }
            } else {
                // fixed cell - "Use my Current Location", "Use Current Map View"
                schLocationBar.txtSchField.attributedText = nil
                schLocationBar.txtSchField.text = indexPath.row == 0 ? "Current Location" : "Current Map View"
                Key.shared.selectedSearchedCity = nil
                schLocationBar.txtSchField.resignFirstResponder()
                schLocationBar.btnClose.isHidden = true
                
                if indexPath.row == 0 {
                    LocManager.shared.searchedLoc = LocManager.shared.curtLoc
                } else {
                    let mapCenter_point = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
                    LocManager.shared.searchedLoc = CLLocation(latitude: faeMapView.convert(mapCenter_point, toCoordinateFrom: nil).latitude,
                                                               longitude: faeMapView.convert(mapCenter_point, toCoordinateFrom: nil).longitude)
                }
                getPlaceInfo()
            }
        }
    }
}
