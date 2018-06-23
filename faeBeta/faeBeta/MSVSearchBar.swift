//
//  MSVSearchBar.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension MapSearchViewController {
    
    func calculateTableHeight() -> Int {
        let cateCnt = filteredCategory.count > 2 ? 2 : filteredCategory.count
        var placeCnt =  searchedPlaces.count > 13 ? 13 : searchedPlaces.count
        var addrCnt = searchedAddresses.count > 13 ? 13 : searchedAddresses.count
        
        if cateCnt == 0 && addrCnt == 0 {
            
        } else if cateCnt == 0 && addrCnt > 0 {
            placeCnt = placeCnt > 8 ? 8 : placeCnt
        } else if cateCnt > 0 && addrCnt == 0 {
            if cateCnt + placeCnt > 13 {
                placeCnt = 13 - cateCnt
            }
        } else {
            placeCnt = placeCnt > 6 ? 6 : placeCnt
        }
        
        if placeCnt > 0 {
            addrCnt = addrCnt > 5 ? 5 : addrCnt
        } else if cateCnt > 0 && placeCnt == 0 {
            if cateCnt + addrCnt > 13 {
                addrCnt = 13 - cateCnt
            }
        }
        
        return cateCnt + placeCnt + addrCnt
    }
    
    // show or hide uiviews/tableViews, change uiviews/tableViews size & origin.y
    func showOrHideViews(searchText: String) {
        switch schBarType {
        case .place:
            uiviewSchLocResBg.isHidden = true
            // for uiviewPics & uiviewSchResBg
            let cellCnt = calculateTableHeight()
            if searchText != "" && cellCnt > 0 {
                uiviewPics.isHidden = true || boolNoCategory
                uiviewSchResBg.isHidden = false
                uiviewSchResBg.frame.origin.y = 124 + device_offset_top
                uiviewSchResBg.frame.size.height = min(screenHeight - 139 - device_offset_top - device_offset_bot, CGFloat(68 * cellCnt))
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
            if searchText != "" && cellCnt == 0 {
                uiviewNoResults.isHidden = false
                uiviewSchResBg.isHidden = true
                uiviewSchLocResBg.isHidden = true
            } else if searchText == "" {
                uiviewPics.isHidden = false
                uiviewNoResults.isHidden = true
                uiviewSchResBg.isHidden = true
                uiviewSchLocResBg.isHidden = true
            } else {
                uiviewNoResults.isHidden = true
                uiviewPics.isHidden = true
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
        activityStatus(isOn: false)
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
            if searchText == "" {
                placeThrottler.cancelCurrentJob()
                filteredCategory.removeAll(keepingCapacity: true)
                searchedPlaces.removeAll(keepingCapacity: true)
                searchedAddresses.removeAll(keepingCapacity: true)
                tblPlacesRes.reloadData()
                showOrHideViews(searchText: "")
                flagPlaceFetched = false
                flagAddrFetched = false
            } else {
                activityStatus(isOn: true)
                placeThrottler.throttle {
                    DispatchQueue.main.async {
                        self.filterPlaceCat(searchText: searchText)
                        self.getPlaceInfo(content: searchText.lowercased())
                        self.getAddresses(content: searchText)
                    }
                }
            }
        case schLocationBar:
            schBarType = .location
            if searchText == "" {
                locThrottler.cancelCurrentJob()
                geobytesCityData.removeAll(keepingCapacity: true)
                showOrHideViews(searchText: searchText)
            } else {
                locThrottler.throttle {
                    self.placeAutocomplete(searchText)
                }
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
