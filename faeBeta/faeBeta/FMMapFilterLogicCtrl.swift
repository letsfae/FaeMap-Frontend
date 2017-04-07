//
//  FMMapFilterLogicCtrl.swift
//  MapFilterIcon
//
//  Created by Yue on 1/25/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    func actionFilterBtnCtrl(_ sender: MFilterButton) {
        switch sender.filterType {
        case .showAll:
            checkFilterShowAll(sender)
            uncheckFilterMyPins()
            uncheckFilterSavedPins()
            stringFilterValue = "comment,chat_room,media"
            refreshMap(pins: true, users: true, places: true)
            refreshPins = true
            refreshUsers = true
            refreshPlaces = true
//            refreshPlacesAll = true
            break
        case .distance:
            checkFilterDistance(sender)
            break
        case .people:
            clearMap(type: "pin", animated: false)
            timerLoadRegionPins.invalidate()
            checkFilterPeople(sender)
            refreshMap(pins: false, users: true, places: false)
            refreshPins = false
            refreshUsers = true
            refreshPlaces = false
//            refreshPlacesAll = false
            break
            
        case .pinAll:
            checkFilterPinTypeAll(sender)
            stringFilterValue = "comment,chat_room,media"
            refreshMap(pins: true, users: false, places: false)
            refreshPins = true
            refreshUsers = false
            refreshPlaces = false
//            refreshPlacesAll = false
            break
        case .comment, .chat_room, .media:
            uncheckFilterShowAll()
            checkFilterPinType(sender)
            break
            
        case .statusAll:
            checkFilterPinStatusAll(sender)
            refreshMap(pins: true, users: false, places: false)
            refreshPins = true
            refreshUsers = false
            refreshPlaces = false
//            refreshPlacesAll = false
            break
        case .hot, .new, .unread, .read:
            uncheckFilterShowAll()
            checkFilterPinStatus(sender)
            refreshMap(pins: true, users: false, places: false)
            refreshPins = true
            refreshUsers = false
            refreshPlaces = false
//            refreshPlacesAll = false
            break
            
        case .placeAll:
            checkFilterPlaceAll(sender)
            yelpQuery.setCatagoryToAll()
            refreshMap(pins: false, users: false, places: true)
            refreshPins = false
            refreshUsers = false
            refreshPlaces = true
//            refreshPlacesAll = true
            break
        case .restaurant:
            yelpQuery.setCustomCategory(to: "pizza,burgers")
            filterPlaceSwitch(sender)
            break
        case .cafe:
            yelpQuery.setCustomCategory(to: "coffee,internetcafe")
            filterPlaceSwitch(sender)
            break
        case .dessert:
            yelpQuery.setCustomCategory(to: "desserts")
            filterPlaceSwitch(sender)
            break
        case .cinema:
            yelpQuery.setCustomCategory(to: "movietheaters")
            filterPlaceSwitch(sender)
            break
        case .beauty:
            yelpQuery.setCustomCategory(to: "beautysvc")
            filterPlaceSwitch(sender)
            break
        case .sports:
            yelpQuery.setCustomCategory(to: "playgrounds,countryclubs,sports_clubs")
            filterPlaceSwitch(sender)
            break
        case .gallery:
            yelpQuery.setCustomCategory(to: "museums,galleries")
            filterPlaceSwitch(sender)
            break
        case .myPins:
            checkFilterMyPins(sender)
            break
        case .savedPins:
            checkFilterSavedPins(sender)
            break
            
        default:
            break
        }
    }
    
    // Filter convert place dic to category
    fileprivate func convertPlaceDicToCategory() {
        var category = ""
        for (key, _) in filterPlaceDic {
            if category == "" {
                category = "\(key)"
                continue
            }
            category = "\(category),\(key)"
        }
        print("[convertPlaceDicToCategory] \(category)")
    }
    
    // Filter place button action
    fileprivate func filterPlaceSwitch(_ sender: MFilterButton) {
        uncheckFilterShowAll()
        checkFilterPlace(sender)
        convertPlaceDicToCategory()
        refreshMap(pins: false, users: false, places: true)
        refreshPins = false
        refreshUsers = false
        refreshPlaces = true
//        refreshPlacesAll = false
    }
    
    // Clear pin type, pin status, and places
    fileprivate func clearTypeStatusPlaces() {
        clearFilterTypeBtnArr()
        clearFilterStatusBtnArr()
        clearFilterPlaceBtnArr()
    }
    
    // Filter show all
    func checkFilterShowAll(_ sender: MFilterButton) {
        makeFilterBtnRed(sender)
        clearTypeStatusPlaces()
        uncheckFilterPeople()
    }
    fileprivate func uncheckFilterShowAll() {
        if btnMFilterShowAll.tag == 1 {
            makeFilterBtnGray(btnMFilterShowAll)
        }
    }
    fileprivate func checkIfCanShowAll() {
        if btnMFilterTypeAll.tag == 1 && btnMFilterStatusAll.tag == 1 && btnMFilterPlacesAll.tag == 1 {
            makeFilterBtnRed(btnMFilterShowAll)
        }
    }
    
    fileprivate func checkFilterDistance(_ sender: MFilterButton) {
        if sender.tag == 0 {
            makeFilterBtnRed(sender)
            filterSlider.isHidden = false
        }
        else {
            makeFilterBtnGray(sender)
            filterSlider.isHidden = true
        }
    }
    
    // Filter only people
    fileprivate func checkFilterPeople(_ sender: MFilterButton) {
        makeFilterBtnRed(sender)
        clearTypeStatusPlaces()
        uncheckFilterShowAll()
    }
    fileprivate func uncheckFilterPeople() {
        if btnMFilterPeople.tag == 1 {
            makeFilterBtnGray(btnMFilterPeople)
        }
    }
    
    // Filter pin type
    fileprivate func checkFilterPinTypeAll(_ sender: MFilterButton) {
        if filterPinTypeDic.count == 0 && btnMFilterMyPins.tag != 1 {
            self.filterPinStatusDic["all"] = btnMFilterStatusAll
            makeFilterBtnRed(btnMFilterStatusAll)
            uncheckFilterShowAll()
        }
        clearFilterTypeBtnArr()
        self.filterPinTypeDic["comment,chat_room,media"] = btnMFilterTypeAll
        makeFilterBtnRed(sender)
        uncheckFilterShowAll()
    }
    fileprivate func checkFilterPinType(_ sender: MFilterButton) {
        if filterPinTypeDic.count == 0 {
            checkFilterPinStatusAll(btnMFilterStatusAll)
        }
        if sender.tag == 1 && filterPinTypeDic.count != 1 {
            filterPinTypeDic.removeValue(forKey: "\(sender.filterType)")
            makeFilterBtnGray(sender)
        }
        else {
            if let _ = filterPinTypeDic["comment,chat_room,media"] {
                filterPinTypeDic.removeValue(forKey: "comment,chat_room,media")
                makeFilterBtnGray(btnMFilterTypeAll)
            }
            filterPinTypeDic["\(sender.filterType)"] = sender
            makeFilterBtnRed(sender)
            if filterPinTypeDic.count == 3 {
                checkFilterPinTypeAll(btnMFilterTypeAll)
            }
            var string = ""
            var firstOne = true
            for (key, _) in filterPinTypeDic {
                if firstOne {
                    firstOne = false
                    string = "\(key)"
                    print("[checkFilterPinType] \(string)")
                    continue
                }
                string = "\(string),\(key)"
                print("[checkFilterPinType] \(string)")
            }
            stringFilterValue = string
            refreshMap(pins: true, users: false, places: false)
            refreshPins = true
            refreshUsers = false
            refreshPlaces = false
//            refreshPlacesAll = false
        }
    }
    
    // Filter pin status
    fileprivate func checkFilterPinStatusAll(_ sender: MFilterButton) {
        if filterPinStatusDic.count == 0 {
            self.filterPinTypeDic["comment,chat_room,media"] = btnMFilterTypeAll
            makeFilterBtnRed(btnMFilterTypeAll)
            uncheckFilterShowAll()
        }
        clearFilterStatusBtnArr()
        self.filterPinStatusDic["all"] = btnMFilterStatusAll
        makeFilterBtnRed(sender)
        uncheckFilterShowAll()
    }
    fileprivate func checkFilterPinStatus(_ sender: MFilterButton) {
        if filterPinStatusDic.count == 0 {
            checkFilterPinTypeAll(btnMFilterTypeAll)
        }
        if sender.tag == 1 && filterPinStatusDic.count != 1 {
            filterPinStatusDic.removeValue(forKey: "\(sender.filterType)")
            makeFilterBtnGray(sender)
        }
        else {
            if let _ = filterPinStatusDic["all"] {
                filterPinStatusDic.removeValue(forKey: "all")
                makeFilterBtnGray(btnMFilterStatusAll)
            }
            filterPinStatusDic["\(sender.filterType)"] = sender
            makeFilterBtnRed(sender)
            if filterPinStatusDic.count == 4 {
                checkFilterPinStatusAll(btnMFilterStatusAll)
            }
        }
    }
    
    // Filter place pin type
    fileprivate func checkFilterPlaceAll(_ sender: MFilterButton) {
        clearFilterPlaceBtnArr()
        self.filterPlaceDic["all"] = btnMFilterPlacesAll
        makeFilterBtnRed(sender)
        uncheckFilterShowAll()
    }
    fileprivate func checkFilterPlace(_ sender: MFilterButton) {
        if sender.tag == 1 && filterPlaceDic.count != 1 {
            filterPlaceDic.removeValue(forKey: "\(sender.filterType)")
            makeFilterBtnGray(sender)
        }
        else {
            if let _ = filterPlaceDic["all"] {
                filterPlaceDic.removeValue(forKey: "all")
                makeFilterBtnGray(btnMFilterPlacesAll)
            }
            filterPlaceDic["\(sender.filterType)"] = sender
            makeFilterBtnRed(sender)
            if filterPlaceDic.count == 7 {
                checkFilterPlaceAll(btnMFilterPlacesAll)
            }
        }
    }
    
    // My pins
    fileprivate func checkFilterMyPins(_ sender: MFilterButton) {
        makeFilterBtnRed(sender)
        uncheckFilterShowAll()
        checkFilterPinTypeAll(btnMFilterTypeAll)
        if btnMFilterSavedPins.tag == 1 {
            makeFilterBtnGray(btnMFilterSavedPins)
        }
        if btnMFilterHot.tag == 1 {
            makeFilterBtnGray(btnMFilterHot)
        }
        
        disableFilterBtn(btnMFilterPeople)
        disableFilterBtn(btnMFilterStatusAll)
        disableFilterBtn(btnMFilterNew)
        disableFilterBtn(btnMFilterUnread)
        disableFilterBtn(btnMFilterRead)
        disableFilterBtn(btnMFilterPlacesAll)
        disableFilterBtn(btnMFilterRestr)
        disableFilterBtn(btnMFilterCafe)
        disableFilterBtn(btnMFilterDessert)
        disableFilterBtn(btnMFilterCinema)
        disableFilterBtn(btnMFilterBeauty)
        disableFilterBtn(btnMFilterSports)
        disableFilterBtn(btnMFilterGallery)
    }
    fileprivate func uncheckFilterMyPins() {
        if btnMFilterMyPins.tag == 1 {
            makeFilterBtnGray(btnMFilterMyPins)
            
            enableFilterBtn(btnMFilterPeople)
            enableFilterBtn(btnMFilterStatusAll)
            enableFilterBtn(btnMFilterNew)
            enableFilterBtn(btnMFilterUnread)
            enableFilterBtn(btnMFilterRead)
            enableFilterBtn(btnMFilterPlacesAll)
            enableFilterBtn(btnMFilterRestr)
            enableFilterBtn(btnMFilterCafe)
            enableFilterBtn(btnMFilterDessert)
            enableFilterBtn(btnMFilterCinema)
            enableFilterBtn(btnMFilterBeauty)
            enableFilterBtn(btnMFilterSports)
            enableFilterBtn(btnMFilterGallery)
        }
    }
    
    // My pins
    fileprivate func checkFilterSavedPins(_ sender: MFilterButton) {
        makeFilterBtnRed(sender)
        uncheckFilterShowAll()
        checkFilterPinTypeAll(btnMFilterTypeAll)
        if btnMFilterMyPins.tag == 1 {
            makeFilterBtnGray(btnMFilterMyPins)
        }
        if btnMFilterHot.tag == 1 {
            makeFilterBtnGray(btnMFilterHot)
        }
        
        disableFilterBtn(btnMFilterPeople)
        disableFilterBtn(btnMFilterStatusAll)
        disableFilterBtn(btnMFilterNew)
        disableFilterBtn(btnMFilterUnread)
        disableFilterBtn(btnMFilterRead)
        disableFilterBtn(btnMFilterPlacesAll)
        disableFilterBtn(btnMFilterRestr)
        disableFilterBtn(btnMFilterCafe)
        disableFilterBtn(btnMFilterDessert)
        disableFilterBtn(btnMFilterCinema)
        disableFilterBtn(btnMFilterBeauty)
        disableFilterBtn(btnMFilterSports)
        disableFilterBtn(btnMFilterGallery)
    }
    fileprivate func uncheckFilterSavedPins() {
        if btnMFilterSavedPins.tag == 1 {
            makeFilterBtnGray(btnMFilterSavedPins)
            
            enableFilterBtn(btnMFilterPeople)
            enableFilterBtn(btnMFilterStatusAll)
            enableFilterBtn(btnMFilterNew)
            enableFilterBtn(btnMFilterUnread)
            enableFilterBtn(btnMFilterRead)
            enableFilterBtn(btnMFilterPlacesAll)
            enableFilterBtn(btnMFilterRestr)
            enableFilterBtn(btnMFilterCafe)
            enableFilterBtn(btnMFilterDessert)
            enableFilterBtn(btnMFilterCinema)
            enableFilterBtn(btnMFilterBeauty)
            enableFilterBtn(btnMFilterSports)
            enableFilterBtn(btnMFilterGallery)
        }
    }
    
    
    
    // Change filter btn color or disable
    fileprivate func makeFilterBtnGray(_ sender: MFilterButton) {
        sender.tag = 0
        sender.setTitleColor(UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1), for: .normal)
        sender.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18 * screenHeightFactor)
    }
    fileprivate func makeFilterBtnRed(_ sender: MFilterButton) {
        sender.tag = 1
        sender.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        sender.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
    }
    fileprivate func disableFilterBtn(_ sender: MFilterButton) {
        sender.tag = 0
        sender.setTitleColor(UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1), for: .normal)
        sender.isEnabled = false
    }
    fileprivate func enableFilterBtn(_ sender: MFilterButton) {
        sender.setTitleColor(UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1), for: .normal)
        sender.isEnabled = true
    }
    
    // Clear filterBtn array
    fileprivate func clearFilterTypeBtnArr() {
        for (_, button) in self.filterPinTypeDic {
            makeFilterBtnGray(button)
        }
        filterPinTypeDic.removeAll(keepingCapacity: false)
    }
    fileprivate func clearFilterStatusBtnArr() {
        for (_, button) in self.filterPinStatusDic {
            makeFilterBtnGray(button)
        }
        filterPinStatusDic.removeAll(keepingCapacity: false)
    }
    fileprivate func clearFilterPlaceBtnArr() {
        for (_, button) in self.filterPlaceDic {
            makeFilterBtnGray(button)
        }
        filterPlaceDic.removeAll(keepingCapacity: false)
    }
    
    // Print array status, will be deleted in the future
    fileprivate func printPinTypeDic() {
        print("[filterPinTypeDic]")
        for (key, _) in filterPinTypeDic {
            print("[filterPinTypeDic] \(key)")
        }
    }
    
    fileprivate func printPinStatusDic() {
        print("[filterPinStatusDic]")
        for (key, _) in filterPinStatusDic {
            print("[filterPinStatusDic] \(key)")
        }
    }
    
    fileprivate func printPlaceDic() {
        print("[filterPlaceDic]")
        for (key, _) in filterPlaceDic {
            print("[filterPlaceDic] \(key)")
        }
    }
}
