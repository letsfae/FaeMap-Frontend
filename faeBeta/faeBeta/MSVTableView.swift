//
//  MSVTableCtrl.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import GooglePlaces

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schPlaceBar.txtSchField.resignFirstResponder()
        schLocationBar.txtSchField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // search location
        if cellStatus == 1 {
            if tableView == tblLocationRes {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocation", for: indexPath as IndexPath) as! LocationListCell
//                cell.lblLocationName.attributedText = geobytesCityData[indexPath.row].faeSearchBarAttributedText()
                if let vm = viewModel.viewModelForLocation(at: indexPath.row) {
                    cell.lblLocationName.attributedText = vm.faeSearchBarAttributedText()
                }
                cell.bottomLine.isHidden = false
                if indexPath.row == tblLocationRes.numberOfRows(inSection: 0) - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyFixedCell", for: indexPath as IndexPath) as! LocationListCell
                cell.lblLocationName.text = arrCurtLocList[indexPath.row]
                cell.bottomLine.isHidden = false
                if indexPath.row == arrCurtLocList.count - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            }
        } else {  // cellStatus == 0
            if indexPath.section == 0 {  // search category
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCategories", for: indexPath as IndexPath) as! CategoryListCell
                if filteredCategory.isEmpty {
                    return cell
                }

                cell.setValueForCategory(filteredCategory[indexPath.row])
                cell.bottomLine.isHidden = false
                if indexPath.row == tblPlacesRes.numberOfRows(inSection: 0) - 1 && filteredPlaces.count == 0 {
                    cell.bottomLine.isHidden = true
                }
                
                return cell
            } else {   // search places
                // search places - cellStatus == 0
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaces", for: indexPath as IndexPath) as! PlacesListCell
                let place = filteredPlaces[indexPath.row]
                
                cell.setValueForPlace(place)
                cell.bottomLine.isHidden = false
                
                if indexPath.row == tblPlacesRes.numberOfRows(inSection: 1) - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if cellStatus == 0 && tableView == tblPlacesRes {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cellStatus == 0 {
            return section == 1 ? filteredPlaces.count : (filteredCategory.count >= 2 ? 2 : filteredCategory.count)
        } else {
//            return tableView == tblLocationRes ? googlePredictions.count : arrCurtLocList.count
            return tableView == tblLocationRes ? viewModel.numberOfLocations : arrCurtLocList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellStatus == 0 ? 68 : 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // search location
        if cellStatus == 1 {
            if tableView == tblLocationRes {
                schLocationBar.txtSchField.attributedText = geobytesCityData[indexPath.row].faeSearchBarAttributedText()
                Key.shared.selectedSearchedCity = geobytesCityData[indexPath.row]
                schLocationBar.txtSchField.resignFirstResponder()
                schPlaceBar.txtSchField.becomeFirstResponder()
                schLocationBar.btnClose.isHidden = true
                // TODO VICKY
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
                // 以下为Google Place API
//                General.shared.lookUpForCoordinate({ (place) in
//                    LocManager.shared.searchedLoc = CLLocation(latitude: place.coordinate.latitude,
//                                                               longitude: place.coordinate.longitude)
//                    if self.schPlaceBar == nil || self.schPlaceBar.txtSchField.text == "Search Fae Map"
//                        || self.schPlaceBar.txtSchField.text == "Search Place or Address" {
//                        return
//                    }
//                    self.getPlaceInfo(content: self.schPlaceBar.txtSchField.text!, source: "name")
//                })
                
            } else {  // fixed cell - "Use my Current Location", "Use Current Map View"
                schLocationBar.txtSchField.attributedText = nil
                schLocationBar.txtSchField.text = indexPath.row == 0 ? "Current Location" : "Current Map View"
//                Key.shared.selectedPrediction = nil
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
        } else {
            if indexPath.section == 1 { // search places
                let selectedPlace = filteredPlaces[indexPath.row]
    //            delegate?.jumpToOnePlace?(searchText: selectedPlace.name, place: selectedPlace)
    //            navigationController?.popViewController(animated: false)
                schPlaceBar.txtSchField.resignFirstResponder()
                let vc = PlaceDetailViewController()
                vc.place = selectedPlace
                navigationController?.pushViewController(vc, animated: false)
            } else {  // search categories
                //let cell = tableView.cellForRow(at: indexPath) as! CategoryListCell
                let selectedCat = filteredCategory[indexPath.row].key
                getPlaceInfo(content: selectedCat, source: "categories")
            }
        }
    }
}
