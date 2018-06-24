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
                switch indexPath.section {
                case 0:
                    // category
                    break
                case 1:
                    // place
                    let selectedPlace = searchedPlaces[indexPath.row]
                    delegate?.selectPlace?(place: selectedPlace)
                    navigationController?.popViewController(animated: false)
                case 2:
                    // address
                    let address = searchedAddresses[indexPath.row]
                    let coder = CLGeocoder()
                    coder.geocodeAddressString(address.title+", "+address.subtitle, in: nil) { [weak self] (results, error) in
                        guard let `self` = self else {
                            return
                        }
                        guard error == nil else {
                            showAlert(title: "Unexpected Error", message: "please try again later", viewCtrler: self)
                            return
                        }
                        guard let placeMarks = results else { return }
                        guard let first = placeMarks.first else { return }
                        guard let loc = first.location else { return }
                        self.delegate?.selectLocation?(location: loc)
                        self.navigationController?.popViewController(animated: false)
                    }
                default:
                    break
                }
            } else {
                // not from chat
                switch indexPath.section {
                case 0:
                    // category
                    let selectedCat = filteredCategory[indexPath.row].key
                    if previousVC == .board {
                        delegate?.jumpToCategory?(category: selectedCat)
                        navigationController?.popViewController(animated: false)
                    } else {
                        getPlaceInfo(content: selectedCat, source: "categories")
                    }
                case 1:
                    // place
                    let selectedPlace = searchedPlaces[indexPath.row]
                    schPlaceBar.txtSchField.resignFirstResponder()
                    let vc = PlaceDetailViewController()
                    vc.place = selectedPlace
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    // address
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
                lookUpForCoordinate(cityData: geobytesCityData[indexPath.row])
            } else {
                // fixed cell - "Use my Current Location", "Use Current Map View"
                schLocationBar.txtSchField.attributedText = nil
                schLocationBar.txtSchField.text = indexPath.row == 0 ? "Current Location" : "Current Map View"
                Key.shared.selectedSearchedCity = indexPath.row == 0 ? "Current Location" : "Current Map View"
                schLocationBar.txtSchField.resignFirstResponder()
                schLocationBar.btnClose.isHidden = true
                if indexPath.row == 0 {
                    let curLoc = LocManager.shared.curtLoc.coordinate
                    updateSavedLocationToSearchInEachViewController(coordinate: curLoc)
                    faeRegion = calculateRegion(miles: 100, coordinate: curLoc)
                } else {
                    updateSavedLocationToSearchInEachViewController(coordinate: faeMapView.centerCoordinate)
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

extension MapSearchViewController {
    
    /*
    func gotoChatViewController() {
        guard var arrCtrlers = navigationController?.viewControllers else {
            showAlert(title: "Unexpected Error", message: "please try again later", viewCtrler: self)
            return
        }
        arrCtrlers.removeLast()
        arrCtrlers.removeLast()
        guard arrCtrlers.last is ChatViewController else {
            showAlert(title: "Unexpected Error", message: "please try again later", viewCtrler: self)
            return
        }
        navigationController?.setViewControllers(arrCtrlers, animated: false)
    }
    */
 
    func updateSavedLocationToSearchInEachViewController(coordinate: CLLocationCoordinate2D) {
        switch previousVC {
        case .map:
            LocManager.shared.locToSearch_map = coordinate
        case .board:
            LocManager.shared.locToSearch_board = coordinate
        case .chat:
            LocManager.shared.locToSearch_chat = coordinate
        }
    }
    
}
