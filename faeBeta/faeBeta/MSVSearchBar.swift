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
                uiviewPics.isHidden = true
                uiviewSchResBg.isHidden = false
                uiviewSchResBg.frame.origin.y = 124 + device_offset_top
                uiviewSchResBg.frame.size.height = min(screenHeight - 139 - device_offset_top - device_offset_bot, CGFloat(68 * cellCnt))
                tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            } else {
                uiviewPics.isHidden = false
                uiviewSchResBg.isHidden = true
                if searchText == "" {
                    uiviewPics.frame.origin.y = 124 + device_offset_top
                } else {
                    uiviewPics.frame.origin.y = 124 + uiviewNoResult.frame.height + 5 + device_offset_top
                }
            }
            
            // for uiviewNoResults
            if searchText != "" && cellCnt == 0 {
                uiviewNoResult.isHidden = false
                uiviewSchResBg.isHidden = true
                uiviewSchLocResBg.isHidden = true
            } else if searchText == "" {
                uiviewPics.isHidden = false
                uiviewNoResult.isHidden = true
                uiviewSchResBg.isHidden = true
                uiviewSchLocResBg.isHidden = true
            } else {
                uiviewNoResult.isHidden = true
                uiviewPics.isHidden = true
            }
            tblPlacesRes.isScrollEnabled = true
        case .location:
            uiviewPics.isHidden = true
            uiviewNoResult.isHidden = true
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
        activityStatus(isOn: false)
    }
    
    func filterPlaceCat(searchText: String, scope: String = "All") {
        var filtered = Category.shared.categories.filter({ ($0.key).lowercased().hasPrefix(searchText.lowercased()) })
        
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
        cancelAllRequests()
        switch searchBar {
        case schPlaceBar:
            if schLocationBar.txtSchField.text == "" {
                if schLocationBar.txtSchField.placeholder != "Current Location" || schLocationBar.txtSchField.placeholder != "Current Map View" {
                    schLocationBar.txtSchField.text = strPreviousFixedOptionSelection
                } else {
                    schLocationBar.txtSchField.text = schLocationBar.txtSchField.placeholder
                }
            }
            if schLocationBar.txtSchField.text == "Current Location" || schLocationBar.txtSchField.text == "Current Map View" {
                schLocationBar.btnClear.isHidden = true
            } else {
                schLocationBar.btnClear.isSelected = !isCityDataChosen
                schLocationBar.btnClear.isUserInteractionEnabled = !schLocationBar.btnClear.isSelected
                schLocationBar.btnClear.isHidden = isCityDataChosen
            }
            schBarType = .place
            if searchBar.txtSchField.text == "" {
                if let text = searchBar.txtSchField.text {
                    showOrHideViews(searchText: text)
                } else {
                    showOrHideViews(searchText: "")
                }
            } else {
                schPlaceBar.btnClear.isHidden = false
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
        case schLocationBar:
            schPlaceBar.btnClear.isHidden = true
            schBarType = .location
            if schLocationBar.txtSchField.text == "Current Location" || schLocationBar.txtSchField.text == "Current Map View" {
                //searchBar.txtSchField.placeholder = searchBar.txtSchField.text
                schLocationBar.txtSchField.placeholder = "Enter a Location"
                schLocationBar.txtSchField.text = ""
                schLocationBar.btnClear.isHidden = true
                schLocationBar.reloadTextFieldAttributes()
            } else {
                if schLocationBar.txtSchField.text != "" {
                    schLocationBar.btnClear.isHidden = false
                    schLocationBar.btnClear.isSelected = false
                    schLocationBar.btnClear.isUserInteractionEnabled = true
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
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
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
                    DispatchQueue.main.async { [weak self] in
                        self?.placeAutocomplete(searchText)
                    }
                }
            }
        default:
            break
        }
    }
    
    // FaeSearchBarTestDelegate
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        guard !isCategorySearching else {
            return
        }
        switch searchBar {
        case schPlaceBar:
            joshprint("[schPlaceBar] clicked")
            schPlaceBar.txtSchField.resignFirstResponder()
            if schPlaceBar.txtSchField.text == "" {
                if isCityDetailFetched {
                    if let cityData = fetchedCityDetail {
                        gotoCity?(cityData)
                        navigationController?.popViewController(animated: false)
                    } else {
                        showAlert(title: "We are fetching the city data for you...", message: "please wait", viewCtrler: self)
                    }
                } else {
                    showAlert(title: "We are fetching the city data for you...", message: "please wait", viewCtrler: self)
                }
            } else {
                sendBackLocationText()
                if flagPlaceFetched {
                    delegate?.jumpToPlaces?(searchText: schPlaceBar.txtSchField.text!, places: searchedPlaces)
                } else {
                    delegate?.continueSearching?(searchText: schPlaceBar.txtSchField.text!, zoomToFit: true)
                }
                navigationController?.popViewController(animated: false)
            }
        case schLocationBar:
            joshprint("[schLocationBar] clicked")
            if geobytesCityData.count > 0 {
                schLocationBar.txtSchField.attributedText = geobytesCityData[0].faeSearchBarAttributedText()
                switch previousVC {
                case .map:
                    Key.shared.selectedSearchedCity_map = geobytesCityData[0]
                case .board:
                    Key.shared.selectedSearchedCity_board = geobytesCityData[0]
                case .chat:
                    Key.shared.selectedSearchedCity_chat = geobytesCityData[0]
                }
                isCityDataChosen = true
                lookUpForCoordinate(cityName: geobytesCityData[0])
                geobytesCityData.removeAll()
                showOrHideViews(searchText: "")
                schPlaceBar.txtSchField.becomeFirstResponder()
            }
        default:
            break
        }
    }
    
    // FaeSearchBarTestDelegate
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        if searchBar == schLocationBar {
            isCityDetailFetched = false
            switch previousVC {
            case .map:
                Key.shared.selectedSearchedCity_map = nil
            case .board:
                Key.shared.selectedSearchedCity_board = nil
            case .chat:
                Key.shared.selectedSearchedCity_chat = nil
            }
        }
        searchBar.txtSchField.becomeFirstResponder()
    }
    
    // FaeSearchBarTestDelegate
    func backspacePressed(_ searchBar: FaeSearchBarTest, isBackspace: Bool) {
        if searchBar == schLocationBar {
            if isBackspace && isCityDetailFetched {
                isCityDetailFetched = false
                schLocationBar.txtSchField.placeholder = "Enter a Location"
                schLocationBar.txtSchField.text = ""
                schLocationBar.reloadTextFieldAttributes()
                schLocationBar.btnClear.isHidden = true
            }
        }
    }
    
}
