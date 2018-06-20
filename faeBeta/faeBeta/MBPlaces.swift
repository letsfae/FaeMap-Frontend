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
extension MapBoardViewController: SeeAllPlacesDelegate, MapBoardPlaceTabDelegate, BoardCategorySearchDelegate {

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
    }
    
    func loadPlaceTabView() {
        uiviewPlaceTab = PlaceTabView()
        uiviewPlaceTab.delegate = self
        uiviewPlaceTab.addGestureRecognizer(setGestureRecognizer())
        view.addSubview(uiviewPlaceTab)
    }
    
    func getPlaceInfo(content: String = "", source: String = "categories") {
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "200")
        FaeSearch.shared.whereKey("radius", value: "99999999")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
        FaeSearch.shared.whereKey("location", value: ["latitude": LocManager.shared.searchedLoc.coordinate.latitude,
                                                      "longitude": LocManager.shared.searchedLoc.coordinate.longitude])
        FaeSearch.shared.search { [weak self] (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                return
            }
            guard let `self` = self else { return }
            self.mbPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
            
            self.lblSearchContent.text = content
            self.uiviewPlaceTab.btnPlaceTabLeft.isSelected = false
            self.uiviewPlaceTab.btnPlaceTabRight.isSelected = true
            self.jumpToSearchPlaces()
        }
    }
    
    @objc func searchAllPlaces(_ sender: UIButton) {
        /*
        let searchVC = BoardsSearchViewController()
        searchVC.enterMode = .place
        searchVC.delegate = self
        searchVC.strSearchedPlace = lblSearchContent.text
        searchVC.strPlaceholder = lblSearchContent.text
        navigationController?.pushViewController(searchVC, animated: true)
         */
    }
    
    @objc func actionClearSearchResults(_ sender: UIButton) {
        lblSearchContent.text = "All Places"
        btnClearSearchRes.isHidden = true
        mbPlaces = arrAllPlaces
        tblMapBoard.reloadData()
    }
    
    // SeeAllPlacesDelegate
    func jumpToAllPlaces(places: [PlacePin], title: String) {
        let vc = AllPlacesViewController()
        vc.recommendedPlaces = places
        vc.strTitle = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToPlaceDetail(place: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = place
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // SeeAllPlacesDelegate End
    
    // MapBoardPlaceTabDelegate
    func jumpToRecommendedPlaces() {
        placeTableMode = .recommend
        btnNavBarMenu.isHidden = false
        btnClearSearchRes.isHidden = true
        btnSearchAllPlaces.isHidden = true
        tblMapBoard.tableHeaderView = uiviewPlaceHeader
        reloadTableMapBoard()
    }
    
    func jumpToSearchPlaces() {
        placeTableMode = .search
        btnNavBarMenu.isHidden = true
        btnSearchAllPlaces.isHidden = false
        if lblSearchContent.text != "All Places" {
            btnClearSearchRes.isHidden = false
        }
        tblMapBoard.tableHeaderView = nil
        reloadTableMapBoard()
    }
    // MapBoardPlaceTabDelegate End

    // BoardsSearchDelegate
    
    func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation) {
        LocManager.shared.searchedLoc = location
        lblCurtLoc.text = searchText
        imgCurtLoc.image = icon
        if lblSearchContent.text == "All Places" || lblSearchContent.text == "" {
            getMBPlaceInfo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            getPlaceInfo(content: lblSearchContent.text!, source: "name")
        }
        tblMapBoard.reloadData()
    }
    
    // MARK: - BoardCategorySearchDelegate
    func searchByCategories(category: String) {
        var content = category
        
        if category ==  "Coffee Shop" {
            content = "Coffee"
        }
        
        getPlaceInfo(content: content)
        
        if catDict[content] == nil {
            catDict[content] = 0
        } else {
            catDict[content] = catDict[content]! + 1;
        }
        favCategoryCache.setObject(catDict as AnyObject, forKey: Key.shared.user_id as AnyObject)
    }
}

