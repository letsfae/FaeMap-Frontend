//
//  AllPlacesViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-11.
//  Copyright © 2017 fae. All rights reserved.
//

// This ViewController is currently unused

import UIKit
import SwiftyJSON

enum AllPlacesEnterMode: Int {
    case mapboard = 1
    case placeDetail = 2
}

protocol AllPlacesDelegate: class {
    func jumpToAllPlaces(places: [PlacePin])
}

class AllPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, MapBoardPlaceTabDelegate, BoardsSearchDelegate {
    
    weak var delegate: AllPlacesDelegate?
    
    var uiviewNavBar: FaeNavBar!
    var tblAllPlaces: UITableView!
    var strTitle: String! = ""
    var recommendedPlaces = [PlacePin]()
    var searchedPlaces = [PlacePin]()
    var uiviewFooterTab: PlaceTabView!
    var placeTableMode: PlaceTableMode = .recommend
    var btnSearchAllPlaces:UIButton!
    var lblSearchContent: UILabel!
    var btnClearSearchRes: UIButton!
    var arrAllPlaces = [PlacePin]()
    var uiviewChooseLoc: UIView!
    var lblChooseLoc: UILabel!
    var imgIconChooseLoc: UIImageView!
    var imgPeopleLocDetail: UIImageView!
    var searchedLoc: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
//        loadPlaceSearchHeader()
//        loadSearchLocationView()
        loadTable()
//        loadFooter()
//        searchedLoc = LocManager.shared.curtLoc
        // 如果是从place detail进来的话，以下这行是不是可以做个判断以免加载了未用信息？
//        getPlaceInfo()
    }

    fileprivate func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_allPlaces"), for: .normal)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = strTitle
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(self.jumpToMapPlaces(_:)), for: .touchUpInside)
    }
    
    fileprivate func loadPlaceSearchHeader() {
        btnSearchAllPlaces = UIButton(frame: CGRect(x: 50, y: 20 + device_offset_top, width: screenWidth - 50, height: 43))
        btnSearchAllPlaces.setImage(#imageLiteral(resourceName: "searchBarIcon"), for: .normal)
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
    
    fileprivate func loadSearchLocationView() {
        uiviewChooseLoc = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 49))
        uiviewChooseLoc.backgroundColor = .white
        view.addSubview(uiviewChooseLoc)
        uiviewChooseLoc.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseLocation(_:)))
        uiviewChooseLoc.addGestureRecognizer(tapGesture)
        
        imgIconChooseLoc = UIImageView(frame: CGRect(x: 14, y: 13, width: 24, height: 24))
        imgIconChooseLoc.image = #imageLiteral(resourceName: "mb_iconBeforeCurtLoc")
        imgIconChooseLoc.contentMode = .center
        lblChooseLoc = UILabel(frame: CGRect(x: 50, y: 14.5, width: 300, height: 21))
        lblChooseLoc.text = "Current Location"
        lblChooseLoc.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblChooseLoc.textColor = UIColor._107107107()
        imgPeopleLocDetail = UIImageView()
        imgPeopleLocDetail.contentMode = .center
        imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_rightArrow")
        uiviewChooseLoc.addSubview(imgPeopleLocDetail)
        uiviewChooseLoc.addConstraintsWithFormat("H:[v0(39)]-5-|", options: [], views: imgPeopleLocDetail)
        uiviewChooseLoc.addConstraintsWithFormat("V:|-6-[v0(38)]", options: [], views: imgPeopleLocDetail)
        
        // draw line
        let lblChooseLocLine = UIView(frame: CGRect(x: 0, y: 48, width: screenWidth, height: 1))
        lblChooseLocLine.backgroundColor = UIColor._200199204()
        uiviewChooseLoc.addSubview(lblChooseLocLine)
        
        uiviewChooseLoc.addSubview(imgIconChooseLoc)
        uiviewChooseLoc.addSubview(lblChooseLoc)
    }
    
    fileprivate func loadTable() {
        tblAllPlaces = UITableView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top - device_offset_bot))
        view.addSubview(tblAllPlaces)
        tblAllPlaces.delegate = self
        tblAllPlaces.dataSource = self
        tblAllPlaces.register(AllPlacesCell.self, forCellReuseIdentifier: "AllPlacesCell")
        tblAllPlaces.separatorStyle = .none
        tblAllPlaces.showsVerticalScrollIndicator = false
        var inset = tblAllPlaces.contentInset
        inset.bottom = -1
        tblAllPlaces.contentInset = inset
    }
    
    fileprivate func loadFooter() {
        uiviewFooterTab = PlaceTabView()
        uiviewFooterTab.delegate = self
        view.addSubview(uiviewFooterTab)
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        let mbIsOn = SideMenuViewController.boolMapBoardIsOn
        if mbIsOn {
            Key.shared.initialCtrler?.goToMapBoard(animated: false)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func jumpToMapPlaces(_ sender: UIButton) {
        
        let vc = AllPlacesMapController()
        vc.strTitle = strTitle
        vc.arrPlaces = placeTableMode == .recommend ? recommendedPlaces : searchedPlaces
        navigationController?.pushViewController(vc, animated: false)
        
        return
        
//        var arrCtrlers = navigationController?.viewControllers
//        if let ctrler = Key.shared.FMVCtrler {
//            ctrler.arrCtrlers = arrCtrlers!
//            ctrler.boolFromMap = false
//        }
//        while !(arrCtrlers?.last is InitialPageController) {
//            arrCtrlers?.removeLast()
//        }
//        self.delegate = Key.shared.FMVCtrler
//        delegate?.jumpToAllPlaces(places: placeTableMode == .recommend ? recommendedPlaces : searchedPlaces)
//        Key.shared.initialCtrler?.goToFaeMap(animated: false)
//        navigationController?.setViewControllers(arrCtrlers!, animated: false)
    }
    
    // TODO: Yue
    @objc func chooseLocation(_ sender: UIButton) {
        searchLocation()
    }
    
    func searchLocation() {
        let vc = BoardsSearchViewController()
        vc.strSearchedLocation = lblChooseLoc.text
        vc.enterMode = .location
        vc.isCitySearch = true
        vc.delegate = self
        vc.strPlaceholder = lblChooseLoc.text
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func actionClearSearchResults(_ sender: UIButton) {
        lblSearchContent.text = "All Places"
        btnClearSearchRes.isHidden = true
        searchedPlaces = arrAllPlaces
        tblAllPlaces.reloadData()
    }
    
    @objc func searchAllPlaces(_ sender: UIButton) {
        let searchVC = BoardsSearchViewController()
        searchVC.enterMode = .place
        searchVC.delegate = self
        searchVC.strSearchedPlace = lblSearchContent.text
        searchVC.strPlaceholder = lblSearchContent.text
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    // MapBoardPlaceTabDelegate
    func jumpToRecommendedPlaces() {
        placeTableMode = .recommend
        uiviewNavBar.lblTitle.isHidden = false
        uiviewNavBar.rightBtn.isHidden = false
        btnSearchAllPlaces.isHidden = true
        tblAllPlaces.frame.origin.y = 65 + device_offset_top
        tblAllPlaces.frame.size.height = screenHeight - 114 - device_offset_top - device_offset_bot
        tblAllPlaces.reloadData()
    }
    
    func jumpToSearchPlaces() {
        placeTableMode = .search
        uiviewNavBar.lblTitle.isHidden = true
        uiviewNavBar.rightBtn.isHidden = true
        btnSearchAllPlaces.isHidden = false
        tblAllPlaces.frame.origin.y = 114 + device_offset_top
        tblAllPlaces.frame.size.height = screenHeight - 114 - 49 - device_offset_top - device_offset_bot
        tblAllPlaces.reloadData()
    }
    // MapBoardPlaceTabDelegate End

    // BoardsSearchDelegate
    func jumpToPlaceSearchResult(searchText: String, places: [PlacePin]) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        
        searchedPlaces.removeAll()
        searchedPlaces = places
        tblAllPlaces.reloadData()
    }
    func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation) {
        lblChooseLoc.text = searchText
        imgIconChooseLoc.image = icon
    }
    // BoardsSearchDelegate End
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if placeTableMode == .recommend {
            return recommendedPlaces.count
        } else {
            return searchedPlaces.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllPlacesCell", for: indexPath) as! AllPlacesCell
        if placeTableMode == .recommend {
        cell.setValueForCell(place: recommendedPlaces[indexPath.row]) //, curtLoc: LocManager.shared.curtLoc)
        } else {
            cell.setValueForCell(place: searchedPlaces[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcPlaceDetail = PlaceDetailViewController()
        if placeTableMode == .recommend {
            vcPlaceDetail.place = recommendedPlaces[indexPath.row]
        } else {
            vcPlaceDetail.place = searchedPlaces[indexPath.row]
        }
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    func getPlaceInfo() {
        let placesList = FaeMap()
        placesList.whereKey("geo_latitude", value: "\(searchedLoc.coordinate.latitude)")
        placesList.whereKey("geo_longitude", value: "\(searchedLoc.coordinate.longitude)")
        placesList.whereKey("radius", value: "50000")
        placesList.whereKey("type", value: "place")
        placesList.whereKey("max_count", value: "1000")
        placesList.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMapSearchPlaceInfo] status/100 != 2")
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                print("[loadMapSearchPlaceInfo] fail to parse map search place info")
                return
            }
            if placeInfoJsonArray.count <= 0 {
                print("[loadMapSearchPlaceInfo] array is nil")
                return
            }
            
            self.searchedPlaces.removeAll()
            
            for result in placeInfoJsonArray {
                let placeData = PlacePin(json: result)
                self.searchedPlaces.append(placeData)
            }
            
            self.arrAllPlaces = self.searchedPlaces
        }
    }
}
