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

class AllPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, MapBoardPlaceTabDelegate {
    
    weak var delegate: AllPlacesDelegate?
    
    var uiviewNavBar: FaeNavBar!
    var tblAllPlaces: UITableView!
    var strTitle: String! = ""
    var recommendedPlaces = [PlacePin]()
    var searchedPlaces = [PlacePin]()
    var uiviewFooterTab: PlaceTabView!
    var placeTableMode: PlaceTableMode = .recommend
    var arrAllPlaces = [PlacePin]()
    var searchedLoc: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
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
        vc.arrPins = placeTableMode == .recommend ? recommendedPlaces : searchedPlaces
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func actionClearSearchResults(_ sender: UIButton) {
        searchedPlaces = arrAllPlaces
        tblAllPlaces.reloadData()
    }
    
    // MapBoardPlaceTabDelegate
    func jumpToRecommendedPlaces() {
        placeTableMode = .recommend
        uiviewNavBar.lblTitle.isHidden = false
        uiviewNavBar.rightBtn.isHidden = false
        tblAllPlaces.frame.origin.y = 65 + device_offset_top
        tblAllPlaces.frame.size.height = screenHeight - 114 - device_offset_top - device_offset_bot
        tblAllPlaces.reloadData()
    }
    
    func jumpToSearchPlaces() {
        placeTableMode = .search
        uiviewNavBar.lblTitle.isHidden = true
        uiviewNavBar.rightBtn.isHidden = true
        tblAllPlaces.frame.origin.y = 114 + device_offset_top
        tblAllPlaces.frame.size.height = screenHeight - 114 - 49 - device_offset_top - device_offset_bot
        tblAllPlaces.reloadData()
    }
    // MapBoardPlaceTabDelegate End
    
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
        placesList.getMapInformation { [weak self] (status: Int, message: Any?) in
            guard let `self` = self else { return }
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
