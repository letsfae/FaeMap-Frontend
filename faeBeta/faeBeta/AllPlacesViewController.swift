//
//  AllPlacesViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

enum AllPlacesEnterMode: Int {
    case mapboard = 1
    case placeDetail = 2
}

class AllPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
     // MARK: - Properties
    
    var uiviewNavBar: FaeNavBar!
    var tblAllPlaces: UITableView!
    var strTitle: String! = ""
    var viewModelPlaces: BoardPlaceCategoryViewModel!
    var recommendedPlaces = [PlacePin]()
    var searchedPlaces = [PlacePin]()
    var uiviewFooterTab: PlaceTabView!
    var placeTableMode: PlaceTableMode = .left
    var arrAllPlaces = [PlacePin]()
    var searchedLoc: CLLocation!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadTable()
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
    
    // MARK: - Button actions
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
        vc.arrPins = placeTableMode == .left ? viewModelPlaces.places : searchedPlaces
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func actionClearSearchResults(_ sender: UIButton) {
        searchedPlaces = arrAllPlaces
        tblAllPlaces.reloadData()
    }
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if placeTableMode == .left {
//            return recommendedPlaces.count
//        } else {
//            return searchedPlaces.count
//        }
        return viewModelPlaces.numberOfPlaces
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllPlacesCell", for: indexPath) as! AllPlacesCell
//        if placeTableMode == .left {
//            cell.setValueForCell(place: recommendedPlaces[indexPath.row]) //, curtLoc: LocManager.shared.curtLoc)
//        } else {
//            cell.setValueForCell(place: searchedPlaces[indexPath.row])
//        }
        if let viewModelPlace = viewModelPlaces.viewModel(for: indexPath.row) {
            cell.setValueForCell(place: viewModelPlace)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcPlaceDetail = PlaceDetailViewController()
//        if placeTableMode == .left {
//            vcPlaceDetail.place = recommendedPlaces[indexPath.row]
//        } else {
//            vcPlaceDetail.place = searchedPlaces[indexPath.row]
//        }
        if let viewModelPlace = viewModelPlaces.viewModel(for: indexPath.row) {
            vcPlaceDetail.place = viewModelPlace.place
        }
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
}
