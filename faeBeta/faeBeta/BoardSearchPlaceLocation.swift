//
//  BoardSearchPlaceLocation.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-22.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation

extension MapBoardViewController: SelectLocationDelegate {
    // MARK: - Button actions
    // function for select loation or unfold people filter page
    @objc func selectLocation(_ sender: UIButton) {
        // in people page
        if sender.tag == 1 {
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_rightArrow")
            sender.tag = 0
            uiviewLineBelowLoc.frame.origin.x = 14
            uiviewLineBelowLoc.frame.size.width = screenWidth - 28
            uiviewPeopleNearyFilter.animateShow()
            
            self.tblPeople.delaysContentTouches = false
        } else {
            // in both place & people
            let vc = SelectLocationViewController()
            vc.delegate = self
            vc.mode = .part
            vc.boolFromExplore = true
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    // MARK: - Button actions
    // function for search places
    @objc func searchAllPlaces(_ sender: UIButton) {
        let searchVC = MapSearchViewController()
        searchVC.delegate = self
        searchVC.previousVC = .board
        if let text = lblSearchContent.text {
            searchVC.strSearchedPlace = text
        }
        if let text = locToSearchTextRaw {
            searchVC.strSearchedLocation = text
        }
        searchVC.changeLocBarText = { [weak self] (locText, shouldChangeStyle) in
            guard let `self` = self else { return }
            if shouldChangeStyle {
                self.lblCurtLoc.attributedText = locText.faeSearchBarAttributedText()
                self.imgCurtLoc.image = #imageLiteral(resourceName: "place_location")
            } else {
                self.lblCurtLoc.attributedText = nil
                self.lblCurtLoc.text = locText
                self.imgCurtLoc.image = #imageLiteral(resourceName: "mb_iconBeforeCurtLoc")
            }
        }
        //searchVC.searchedPlaces = viewModelPlaces.places
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    // MARK: - MapSearchDelegate
    func jumpToPlaces(searchText: String, places: [PlacePin]) {
        updateSearchRes(searchText: searchText, fromCategory: false)
    }
    
    func jumpToCategory(category: String) {
        updateSearchRes(searchText: category)
    }
    
    // check whether category and location changed, then get corresponding response
    private func updateSearchRes(searchText: String, fromCategory: Bool = true) {
        // update UI first
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        tblPlaceRight.scrollToTop(animated: false)
        
        // check whether category and location changed
        var locationChanged = false
        let location = LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate
        let from = CLLocation(latitude: viewModelPlaces.location.latitude, longitude: viewModelPlaces.location.longitude)
        let to = CLLocation(latitude: location.latitude, longitude: location.longitude)
//        vickyprint("distance \(to.distance(from: from))")
        if to.distance(from: from) > 100 {
            locationChanged = true
        }
        
        if fromCategory {
            let categoryChanged = searchText != viewModelPlaces.category
//            vickyprint("searchText \(searchText) viewModelPlaces.category \(viewModelPlaces.category)")
//            vickyprint("categoryChanged \(categoryChanged) locationChanged \(locationChanged)")
            if categoryChanged && locationChanged {
                viewModelPlaces.update = false
                updateLocationInViewModel(location)
                viewModelPlaces.category = searchText
            } else if categoryChanged {
                viewModelPlaces.category = searchText
            } else if locationChanged {
                updateLocationInViewModel(location)
            }
        } else {
            viewModelPlaces.searchByCategories(content: searchText, source: "name", latitude: location.latitude, longitude: location.longitude)
            viewModelPlaces.update = false
            updateLocationInViewModel(location)
        }
    }
    
    // MARK: - SelectLocationDelegate
    func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation) {
        LocManager.shared.locToSearch_board = location.coordinate
        locToSearchTextRaw = searchText
        joshprint("[jumpToLocationSearchResult]", searchText)
        if let attrText = processLocationName(separator: "@", text: searchText, size: 16) {
            lblCurtLoc.attributedText = attrText
        } else {
            fatalError("Processing Location Name Fail, Need To Check Function")
        }
        imgCurtLoc.image = icon
        
        updateLocationInViewModel(LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate)
        rollUpFilter()
    }
    
    private func updateLocationInViewModel(_ location: CLLocationCoordinate2D) {
        viewModelCategories.location = location
        tblPlaceLeft.scrollToTop(animated: false)

        viewModelPlaces.location = location
        tblPlaceRight.scrollToTop(animated: false)

        viewModelPeople.location = location
        tblPeople.scrollToTop(animated: false)
    }
    
    func sendLocationBack(address: RouteAddress) {
        var arrNames = address.name.split(separator: ",")
        var array = [String]()
        guard arrNames.count >= 1 else { return }
        for i in 0..<arrNames.count {
            let name = String(arrNames[i]).trimmingCharacters(in: CharacterSet.whitespaces)
            array.append(name)
        }
        if array.count >= 3 {
            reloadBottomText(array[0], array[1] + ", " + array[2])
        } else if array.count == 1 {
            reloadBottomText(array[0], "")
        } else if array.count == 2 {
            reloadBottomText(array[0], array[1])
        }
    }
    
    func reloadBottomText(_ city: String, _ state: String) {
        let fullAttrStr = NSMutableAttributedString()
        //        let firstImg = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        //        let first_attch = InlineTextAttachment()
        //        first_attch.fontDescender = -2
        //        first_attch.image = UIImage(cgImage: (firstImg.cgImage)!, scale: 3, orientation: .up)
        //        let firstImg_attach = NSAttributedString(attachment: first_attch)
        //
        //        let secondImg = #imageLiteral(resourceName: "exp_bottom_loc_arrow")
        //        let second_attch = InlineTextAttachment()
        //        second_attch.fontDescender = -1
        //        second_attch.image = UIImage(cgImage: (secondImg.cgImage)!, scale: 3, orientation: .up)
        //        let secondImg_attach = NSAttributedString(attachment: second_attch)
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_0_attr = NSMutableAttributedString(string: "  " + city + " ", attributes: attrs_0)
        
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
        
        //        fullAttrStr.append(firstImg_attach)
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
        //        fullAttrStr.append(secondImg_attach)
        DispatchQueue.main.async {
            self.lblCurtLoc.attributedText = fullAttrStr
        }
    }
}
