//
//  MSVSearchBar.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension MapSearchViewController {
    
    // show or hide uiviews/tableViews, change uiviews/tableViews size & origin.y
    func showOrHideViews(searchText: String) {
        // search places
        if cellStatus == 0 {
            uiviewSchLocResBg.isHidden = true
            // for uiviewPics & uiviewSchResBg
            if searchText != "" && filteredPlaces.count != 0 {
                uiviewPics.isHidden = true
                uiviewSchResBg.isHidden = false
                uiviewSchResBg.frame.origin.y = 124 + device_offset_top
                uiviewSchResBg.frame.size.height = min(screenHeight - 139 - device_offset_top - device_offset_bot_v2, CGFloat(68 * filteredPlaces.count))
                tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            } else {
                uiviewPics.isHidden = false
                uiviewSchResBg.isHidden = true
                if searchText == "" {
                    uiviewPics.frame.origin.y = 124 + device_offset_top
                } else {
                    uiviewPics.frame.origin.y = 124 + uiviewNoResults.frame.height + 5 + device_offset_top
                }
            }
            
            // for uiviewNoResults
            if searchText != "" && filteredPlaces.count == 0 {
                uiviewNoResults.isHidden = false
            } else {
                uiviewNoResults.isHidden = true
            }
            tblPlacesRes.isScrollEnabled = true
        } else {  // search location
            uiviewPics.isHidden = true
            uiviewNoResults.isHidden = true
            uiviewSchResBg.isHidden = false
            uiviewSchResBg.frame.size.height = CGFloat(arrCurtLocList.count * 48)
            tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            
            if searchText == "" || googlePredictions.count == 0 {
                uiviewSchResBg.frame.origin.y = 124 + device_offset_top
                uiviewSchLocResBg.isHidden = true
            } else {
                uiviewSchLocResBg.isHidden = false
                uiviewSchLocResBg.frame.size.height = min(screenHeight - 240 - device_offset_top - device_offset_bot_v2, CGFloat(48 * googlePredictions.count))
                tblLocationRes.frame.size.height = uiviewSchLocResBg.frame.size.height
                uiviewSchResBg.frame.origin.y = 124 + uiviewSchLocResBg.frame.height + 5 + device_offset_top
            }
            tblPlacesRes.isScrollEnabled = false
            tblLocationRes.reloadData()
        }
        tblPlacesRes.reloadData()
    }
    
    // FaeSearchBarTestDelegate
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        if searchBar == schPlaceBar {   // search places
            cellStatus = 0
        } else {   // search locations
            cellStatus = 1
            if searchBar.txtSchField.text == "Current Location" || searchBar.txtSchField.text == "Current Map View" {
                searchBar.txtSchField.placeholder = searchBar.txtSchField.text
                searchBar.txtSchField.text = ""
                searchBar.btnClose.isHidden = true
            }
        }
        showOrHideViews(searchText: searchBar.txtSchField.text!)
    }
    
    // FaeSearchBarTestDelegate
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        if searchBar == schLocationBar {
            cellStatus = 1
            if searchText == "" {
                showOrHideViews(searchText: searchText)
            }
            //            searchCompleter.queryFragment = searchText
            placeAutocomplete(searchText)
        } else {
            cellStatus = 0
            getPlaceInfo(content: searchText.lowercased())
        }
    }
    
    // FaeSearchBarTestDelegate
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        if searchBar == schPlaceBar {
            searchBar.txtSchField.resignFirstResponder()
            if searchBar.txtSchField.text == "" {
                lookUpForCoordinate()
            } else {
                delegate?.jumpToPlaces?(searchText: searchBar.txtSchField.text!, places: filteredPlaces, selectedLoc: searchedLoc)
                navigationController?.popViewController(animated: false)
            }
        } else {
            if googlePredictions.count > 0 {
                schLocationBar.txtSchField.attributedText = googlePredictions[0].faeSearchBarAttributedText()
                Key.shared.selectedPrediction = googlePredictions[0]
                googlePredictions.removeAll()
                showOrHideViews(searchText: "")
                schPlaceBar.txtSchField.becomeFirstResponder()
            }
        }
    }
    
    // FaeSearchBarTestDelegate
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.becomeFirstResponder()
    }
    
}
