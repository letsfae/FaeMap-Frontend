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
        searchVC.boolNoCategory = false
        searchVC.boolFromBoard = true
        searchVC.boolFromChat = false
        searchVC.delegate = self
        searchVC.previousVC = .board
        if let text = lblSearchContent.text {
            searchVC.strSearchedPlace = text
        }
        if let text = locToSearchTextRaw {
            searchVC.strSearchedLocation = text
        }
        //searchVC.searchedPlaces = viewModelPlaces.places
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    // MARK: - MapSearchDelegate
    // TODO JOSHUA - 从search返回board的数据请求全部交给我。只需要给我搜索的source(name或categories)以及搜索的content就够了。还有更新location的文字。
    // 意思就是 进入搜索有三种选择，1：点击category搜索button，此时只需返回给我category是什么（不要做数据请求）。2. 输入一些字符后点击search，此时只需返回给我searchText即可。3. 点击cell进入place detail，无需给我返回东西。
    func jumpToPlaces(searchText: String, places: [PlacePin]) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        let location = LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate
        viewModelPlaces.searchByCategories(content: searchText, source: "name", latitude: location.latitude, longitude: location.longitude)
        print("name")
        updateLocationInViewModel(updatePlaces: false)
        // TODO VICKY - MAPSEARCH
        // 搜索name, 回传的参数里places没有用
        // 使用LocManager.shared.locToSearch_board, it's an optional value, safely unwrapp it
        // if nil, then use LocManager.shared.curtLoc
    }
    
    func jumpToCategory(category: String) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = category
        tblPlaceRight.scrollToTop(animated: false)
        viewModelPlaces.category = category
        print("category")
        updateLocationInViewModel(updatePlaces: false)
        // TODO VICKY - MAPSEARCH
        // 搜索category
        // 使用LocManager.shared.locToSearch_board, it's an optional value, safely unwrapp it
        // if nil, then use LocManager.shared.curtLoc
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
        
        updateLocationInViewModel()
        rollUpFilter()
        
        if lblSearchContent.text == "All Places" || lblSearchContent.text == "" {
            //            getMBPlaceInfo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            //            getPlaceInfo(content: lblSearchContent.text!, source: "name")
        }
        //        tblMapBoard.reloadData()
    }
    
    private func updateLocationInViewModel(updateCategory: Bool = true, updatePlaces: Bool = true, updatePeople: Bool = true) {
        if updateCategory {
            viewModelCategories.location = LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate
            tblPlaceLeft.scrollToTop(animated: false)
        }
        if updatePlaces {
            viewModelPlaces.location = LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate
            tblPlaceRight.scrollToTop(animated: false)
        }
        if updatePeople {
            viewModelPeople.location = LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate
            tblPeople.scrollToTop(animated: false)
        }
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
