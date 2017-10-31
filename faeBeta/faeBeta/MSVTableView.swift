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
                //                cell.lblLocationName.text = filteredLocations[indexPath.row]
                cell.setValueForLocationPrediction(googlePredictions[indexPath.row])
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
        }
        
        // search places - cellStatus == 0
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaces", for: indexPath as IndexPath) as! PlacesListCell
        let place = filteredPlaces[indexPath.row]
        
        cell.setValueForPlace(place)
        cell.bottomLine.isHidden = false
        
        if indexPath.row == tblPlacesRes.numberOfRows(inSection: 0) - 1 {
            cell.bottomLine.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // cellStatus == 0 -> search places
        //        return cellStatus == 0 ? filteredPlaces.count : (tableView == tblLocationRes ? filteredLocations.count : arrCurtLocList.count)
        return cellStatus == 0 ? filteredPlaces.count : (tableView == tblLocationRes ? googlePredictions.count : arrCurtLocList.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellStatus == 0 ? 68 : 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // search location
        if cellStatus == 1 {
            if tableView == tblLocationRes {
                schLocationBar.txtSchField.attributedText = googlePredictions[indexPath.row].faeSearchBarAttributedText()
                Key.shared.selectedPrediction = googlePredictions[indexPath.row]
                schLocationBar.txtSchField.resignFirstResponder()
                schPlaceBar.txtSchField.becomeFirstResponder()
                schLocationBar.btnClose.isHidden = true
            } else {  // fixed cell - "Use my Current Location", "Use Current Map View"
                schLocationBar.txtSchField.text = indexPath.row == 0 ? "Current Location" : "Current Map View"
                schLocationBar.txtSchField.resignFirstResponder()
                schLocationBar.btnClose.isHidden = true
                
                if indexPath.row == 0 {
                    searchedLoc = LocManager.shared.curtLoc
                } else {
                    let mapCenter_point = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
                    searchedLoc = CLLocation(latitude: faeMapView.convert(mapCenter_point, toCoordinateFrom: nil).latitude,
                                             longitude: faeMapView.convert(mapCenter_point, toCoordinateFrom: nil).longitude)
                }
                getPlaceInfo()
            }
        } else { // search places
            let selectedPlace = filteredPlaces[indexPath.row]
            delegate?.jumpToOnePlace?(searchText: selectedPlace.name, place: selectedPlace)
            navigationController?.popViewController(animated: false)
        }
    }
}
