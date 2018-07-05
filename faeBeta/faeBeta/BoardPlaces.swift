//
//  MBPlaces.swift
//  faeBeta
//
//  Created by Vicky on 2017-08-17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

// for new Place page
extension MapBoardViewController: SeeAllPlacesDelegate, MapBoardPlaceTabDelegate, BoardCategorySearchDelegate, MapSearchDelegate {
    // MARK: - Load place part of boards
    func loadPlaceSearchHeader() {
        btnSearchAllPlaces = UIButton(frame: CGRect(x: 50, y: 20 + device_offset_top, width: screenWidth - 50, height: 43))
        btnSearchAllPlaces.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
        btnSearchAllPlaces.addTarget(self, action: #selector(searchAllPlaces(_:)), for: .touchUpInside)
        btnSearchAllPlaces.contentHorizontalAlignment = .left
        uiviewNavBar.addSubview(btnSearchAllPlaces)
        
        lblSearchContent = UILabel(frame: CGRect(x: 24, y: 10, width: 200, height: 25))
        lblSearchContent.textColor = UIColor._898989()
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.text = "All Places"
        btnSearchAllPlaces.addSubview(lblSearchContent)
        
        btnSearchAllPlaces.isHidden = true
        
        // Click to clear search results
        btnClearSearchRes = UIButton()
        btnClearSearchRes.setImage(#imageLiteral(resourceName: "mainScreenSearchClearSearchBar"), for: .normal)
        btnClearSearchRes.isHidden = true
        btnClearSearchRes.addTarget(self, action: #selector(self.actionClearSearchResults(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnClearSearchRes)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(36.45)]-5-|", options: [], views: btnClearSearchRes)
        uiviewNavBar.addConstraintsWithFormat("V:[v0(36.45)]-5.55-|", options: [], views: btnClearSearchRes)
    }
    
    func loadPlaceHeader() {
        uiviewPlaceHeader = BoardCategorySearchView(frame: CGRect.zero)
        uiviewPlaceHeader.delegate = self
    }
    
    func loadPlaceTabView() {
        uiviewPlaceTab = PlaceTabView()
        uiviewPlaceTab.delegate = self
        uiviewPlaceTab.addGestureRecognizer(setGestureRecognizer())
        view.addSubview(uiviewPlaceTab)
    }
    
    // MARK: - Button actions
    @objc func actionClearSearchResults(_ sender: UIButton) {
        lblSearchContent.text = "All Places"
        btnClearSearchRes.isHidden = true
        tblPlaceRight.scrollToTop(animated: false)
        viewModelPlaces.category = "All Places"
    }
    
    // MARK: - SeeAllPlacesDelegate
    func jumpToAllPlaces(places: BoardPlaceCategoryViewModel) {
        let vc = AllPlacesViewController()
        vc.viewModelPlaces = places
        vc.strTitle = places.title
        AllPlacesMapController.isBackToLastPlaceDetailVCEnabled = false
//        vc.recommendedPlaces = places
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToPlaceDetail(place: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = place
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // MARK: - MapBoardPlaceTabDelegate
    func jumpToLeftTab() {
        placeTableMode = .left
        if let btnNavBarMenu = btnNavBarMenu {
            btnNavBarMenu.isHidden = false
        }
        if let btnClearSearchRes = btnClearSearchRes {
            btnClearSearchRes.isHidden = true
        }
        if let btnSearchAllPlaces = btnSearchAllPlaces {
            btnSearchAllPlaces.isHidden = true
        }
        
        tblPlaceLeft.isHidden = false
        tblPlaceRight.isHidden = true
    }
    
    func jumpToRightTab() {
        placeTableMode = .right
        if let btnNavBarMenu = btnNavBarMenu {
            btnNavBarMenu.isHidden = true
        }
        if let btnSearchAllPlaces = btnSearchAllPlaces {
            btnSearchAllPlaces.isHidden = false
        }
        if lblSearchContent.text != "All Places" {
            btnClearSearchRes.isHidden = false
        }
        
        tblPlaceLeft.isHidden = true
        tblPlaceRight.isHidden = false
    }
    
    // MARK: - BoardCategorySearchDelegate
    func searchByCategories(category: String) {
        lblSearchContent.text = category
        uiviewPlaceTab.btnPlaceTabLeft.isSelected = false
        uiviewPlaceTab.btnPlaceTabRight.isSelected = true
        tblPlaceRight.scrollToTop(animated: false)
        jumpToRightTab()
        viewModelPlaces.category = category
        
//        if catDict[category] == nil {
//            catDict[category] = 0
//        } else {
//            catDict[category] = catDict[category]! + 1;
//        }
//        favCategoryCache.setObject(catDict as AnyObject, forKey: Key.shared.user_id as AnyObject)
    }
}

