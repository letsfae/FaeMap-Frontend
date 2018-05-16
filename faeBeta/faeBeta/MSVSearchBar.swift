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
            if searchText != "" && (filteredPlaces.count != 0 || filteredCategory.count != 0) {
                uiviewPics.isHidden = true
                uiviewSchResBg.isHidden = false
                uiviewSchResBg.frame.origin.y = 124 + device_offset_top
                let catCnt = filteredCategory.count >= 2 ? 2 : filteredCategory.count
                uiviewSchResBg.frame.size.height = min(screenHeight - 139 - device_offset_top - device_offset_bot, CGFloat(68 * (filteredPlaces.count + catCnt)))
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
            if searchText != "" && filteredPlaces.count == 0 && filteredCategory.count == 0 {
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
                uiviewSchLocResBg.frame.size.height = min(screenHeight - 240 - device_offset_top - device_offset_bot, CGFloat(48 * googlePredictions.count))
                tblLocationRes.frame.size.height = uiviewSchLocResBg.frame.size.height
                uiviewSchResBg.frame.origin.y = 124 + uiviewSchLocResBg.frame.height + 5 + device_offset_top
            }
            tblPlacesRes.isScrollEnabled = false
            tblLocationRes.reloadData()
        }
        tblPlacesRes.reloadData()
        if boolFromChat {
            uiviewPics.isHidden = true
        }
    }
    
    func filterPlaceCat(searchText: String, scope: String = "All") {
        // TODO VICKY 为什么造成crash?
        var filtered = categories.filter({ ($0.key).lowercased().hasPrefix(searchText.lowercased()) })
        
        if filtered.count == 0 {
            filteredCategory = []
        } else
            if filtered.count == 1 {
            filteredCategory = [filtered.popFirst()!]
        } else if filtered.count >= 2 {
            filteredCategory = [filtered.popFirst()!, filtered.popFirst()!]
        }
    }
    
    // MARK: - FaeSearchBarTestDelegate
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        if searchBar == schPlaceBar {   // search places
            schLocationBar.btnClose.isHidden = true
            cellStatus = 0
            if searchBar.txtSchField.text == "" {
                if let text = searchBar.txtSchField.text {
                    showOrHideViews(searchText: text)
                } else {
                    showOrHideViews(searchText: "")
                }
            } else {
                schPlaceBar.btnClose.isHidden = false
                if let text = searchBar.txtSchField.text {
                    showOrHideViews(searchText: text)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.filterPlaceCat(searchText: text)  // crash when entering from map
                        self.getPlaceInfo(content: text)
                    }
                } else {
                    filterPlaceCat(searchText: "")
                    getPlaceInfo(content: "")
                }
            }
        } else {   // search locations
            schPlaceBar.btnClose.isHidden = true
            cellStatus = 1
            if searchBar.txtSchField.text == "Current Location" || searchBar.txtSchField.text == "Current Map View" {
                searchBar.txtSchField.placeholder = searchBar.txtSchField.text
                searchBar.txtSchField.text = ""
                searchBar.btnClose.isHidden = true
            } else {
                if searchBar.txtSchField.text != "" {
                    searchBar.btnClose.isHidden = false
                }
            }
            showOrHideViews(searchText: searchBar.txtSchField.text!)
        }
    }
    
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
            filterPlaceCat(searchText: searchText)
            getPlaceInfo(content: searchText.lowercased())
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        if searchBar == schPlaceBar {
            searchBar.txtSchField.resignFirstResponder()
            if searchBar.txtSchField.text == "" {
                // TODO Vicky - 为空一直都是按搜索返回地图，不搜出任何东西，就是原本的地图主页效果，但是地图当前的view会根据第二行的地点
                lookUpForCoordinate()
            } else {
                delegate?.jumpToPlaces?(searchText: searchBar.txtSchField.text!, places: filteredPlaces)
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
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.becomeFirstResponder()
    }
    
}
