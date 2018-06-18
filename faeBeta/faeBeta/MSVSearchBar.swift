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
        switch schBarType {
        case .place:
            uiviewSchLocResBg.isHidden = true
            // for uiviewPics & uiviewSchResBg
            let placeCnt = searchedPlaces.count
            let catCnt = filteredCategory.count >= 2 ? 2 : filteredCategory.count
            let addrCnt = searchedAddresses.count
            if searchText != "" && (placeCnt + catCnt + addrCnt) > 0 {
                uiviewPics.isHidden = true || boolNoCategory
                uiviewSchResBg.isHidden = false
                uiviewSchResBg.frame.origin.y = 124 + device_offset_top
                uiviewSchResBg.frame.size.height = min(screenHeight - 139 - device_offset_top - device_offset_bot, CGFloat(68 * (placeCnt + catCnt + addrCnt)))
                tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            } else {
                uiviewPics.isHidden = false || boolNoCategory
                uiviewSchResBg.isHidden = true
                if searchText == "" {
                    uiviewPics.frame.origin.y = 124 + device_offset_top
                } else {
                    uiviewPics.frame.origin.y = 124 + uiviewNoResults.frame.height + 5 + device_offset_top
                }
            }
            
            // for uiviewNoResults
            if searchText != "" && (placeCnt + catCnt + addrCnt) == 0 {
                uiviewNoResults.isHidden = false
            } else {
                uiviewNoResults.isHidden = true
            }
            tblPlacesRes.isScrollEnabled = true
        case .location:
            uiviewPics.isHidden = true || boolNoCategory
            uiviewNoResults.isHidden = true
            uiviewSchResBg.isHidden = false
            uiviewSchResBg.frame.size.height = CGFloat(fixedLocOptions.count * 48)
            tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            
            if searchText == "" || geobytesCityData.count == 0 {
                uiviewSchResBg.frame.origin.y = 124 + device_offset_top
                uiviewSchLocResBg.isHidden = true
            } else {
                uiviewSchLocResBg.isHidden = false
                uiviewSchLocResBg.frame.size.height = min(screenHeight - 240 - device_offset_top - device_offset_bot, CGFloat(48 * geobytesCityData.count))
                tblLocationRes.frame.size.height = uiviewSchLocResBg.frame.size.height
                uiviewSchResBg.frame.origin.y = 124 + uiviewSchLocResBg.frame.height + 5 + device_offset_top
            }
            tblPlacesRes.isScrollEnabled = false
            tblLocationRes.reloadData()
        }
        tblPlacesRes.reloadData()
        if boolFromChat {
            uiviewPics.isHidden = true || boolNoCategory
        }
    }
    
    func filterPlaceCat(searchText: String, scope: String = "All") {
        guard !boolFromChat else {
            filteredCategory = []
            return
        }
        var filtered = Key.shared.categories.filter({ ($0.key).lowercased().hasPrefix(searchText.lowercased()) })
        
        if filtered.count == 0 {
            filteredCategory = []
        } else
            if filtered.count == 1 {
            filteredCategory = [filtered.popFirst()!]
        } else if filtered.count >= 2 {
            filteredCategory = [filtered.popFirst()!, filtered.popFirst()!]
        }
    }
    
    // FaeSearchBarTestDelegate
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        switch searchBar {
        case schPlaceBar:
            schLocationBar.btnClose.isHidden = true
            schBarType = .place
            if searchBar.txtSchField.text == "" {
                if let text = searchBar.txtSchField.text {
                    showOrHideViews(searchText: text)
                } else {
                    showOrHideViews(searchText: "")
                }
            } else {
                schPlaceBar.btnClose.isHidden = false
                if let text = searchBar.txtSchField.text {
                    filterPlaceCat(searchText: text.lowercased())
                    showOrHideViews(searchText: text.lowercased())
                    activityStatus(isOn: true)
                    placeThrottler.throttle {
                        DispatchQueue.main.async {
                            if text.lowercased() == "all places" {
                                
                            } else {
                                self.getPlaceInfo(content: text.lowercased())
                            }
                        }
                    }
                } else {
                    filterPlaceCat(searchText: "")
                    getPlaceInfo(content: "")
                }
            }
            if schLocationBar.txtSchField.text == "" {
                schLocationBar.txtSchField.text = schLocationBar.txtSchField.placeholder
            }
        case schLocationBar:
            schPlaceBar.btnClose.isHidden = true
            schBarType = .location
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
        default:
            break
        }
    }
    
    // FaeSearchBarTestDelegate
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        switch searchBar {
        case schPlaceBar:
            schBarType = .place
            filterPlaceCat(searchText: searchText)
            showOrHideViews(searchText: searchText)
            activityStatus(isOn: true)
            placeThrottler.throttle {
                DispatchQueue.main.async {
                    self.getPlaceInfo(content: searchText.lowercased())
                    self.addressCompleter.queryFragment = searchText
                }
            }
            if searchText == "" {
                searchedPlaces.removeAll(keepingCapacity: true)
                tblPlacesRes.reloadData()
            }
        case schLocationBar:
            schBarType = .location
            if searchText == "" {
                showOrHideViews(searchText: searchText)
            }
            locThrottler.throttle {
                self.placeAutocomplete(searchText)
            }
        default:
            break
        }
    }
    
    // FaeSearchBarTestDelegate
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        if searchBar == schPlaceBar {
            searchBar.txtSchField.resignFirstResponder()
            if searchBar.txtSchField.text == "" {
                // TODO Vicky - 为空一直都是按搜索返回地图，不搜出任何东西，就是原本的地图主页效果，但是地图当前的view会根据第二行的地点
                lookUpForCoordinate()
            } else {
                delegate?.jumpToPlaces?(searchText: searchBar.txtSchField.text!, places: searchedPlaces)
                navigationController?.popViewController(animated: false)
            }
        } else {
            if geobytesCityData.count > 0 {
                schLocationBar.txtSchField.attributedText = geobytesCityData[0].faeSearchBarAttributedText()
                Key.shared.selectedSearchedCity = geobytesCityData[0]
                geobytesCityData.removeAll()
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
