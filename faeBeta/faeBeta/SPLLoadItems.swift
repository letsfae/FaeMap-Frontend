//
//  SPLLoadItems.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit

extension SelectLocationViewController {
    
    func loadMapView() {
        slMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        slMapView.showsUserLocation = true
        slMapView.delegate = self
        slMapView.showsPointsOfInterest = false
        slMapView.showsCompass = false
        view.addSubview(slMapView)
        
        imgPinOnMap = UIImageView(frame: CGRect(x: screenWidth/2-25, y: screenHeight/2-54, width: 50, height: 54))
        imgPinOnMap.image = UIImage(named: "\(pinType)MarkerWhenCreated")
        view.addSubview(imgPinOnMap)
    }
    
    func loadButtons() {
        btnCancel = UIButton(frame: CGRect(x: 0, y: 0, width: 59, height: 59))
        btnCancel.setImage(UIImage(named: "cancelSelectLocation"), for: UIControlState())
        view.addSubview(btnCancel)
        btnCancel.addTarget(self, action: #selector(SelectLocationViewController.actionCancelSelectLocation(_:)), for: .touchUpInside)
        view.addConstraintsWithFormat("H:|-18-[v0(59)]", options: [], views: btnCancel)
        view.addConstraintsWithFormat("V:[v0(59)]-77-|", options: [], views: btnCancel)
        
        btnLocat = UIButton()
        self.view.addSubview(btnLocat)
        btnLocat.setImage(UIImage(named: "mainScreenSelfPosition"), for: UIControlState())
        btnLocat.addTarget(self, action: #selector(SelectLocationViewController.actionSelfPosition(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(59)]-18-|", options: [], views: btnLocat)
        self.view.addConstraintsWithFormat("V:[v0(59)]-77-|", options: [], views: btnLocat)
        
        buttonSetLocationOnMap = UIButton()
        buttonSetLocationOnMap.setTitle("Set Location", for: UIControlState())
        buttonSetLocationOnMap.setTitle("Set Location", for: .highlighted)
        buttonSetLocationOnMap.setTitleColor(UIColor.faeAppRedColor(), for: UIControlState())
        buttonSetLocationOnMap.setTitleColor(UIColor.lightGray, for: .highlighted)
        buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        self.view.addSubview(buttonSetLocationOnMap)
        buttonSetLocationOnMap.addTarget(self, action: #selector(SelectLocationViewController.actionSetLocationForComment(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonSetLocationOnMap)
        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonSetLocationOnMap)
    }
    
    func loadFaeSearchController() {
        let searchBarSubview = UIView(frame: CGRect(x: 8, y: 23, width: resultTableWidth, height: 48))
        
        faeSearchController = FaeSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 10, y: 6, width: resultTableWidth-11, height: 38), searchBarFont: UIFont(name: "AvenirNext-Medium", size: 18)!, searchBarTextColor: UIColor.faeAppInputTextGrayColor(), searchBarTintColor: UIColor.white)
        faeSearchController.faeSearchBar.placeholder = "Search Address or Place                               "
        faeSearchController.faeDelegate = self
        faeSearchController.faeSearchBar.layer.borderWidth = 2.0
        faeSearchController.faeSearchBar.layer.borderColor = UIColor.white.cgColor
        
        searchBarSubview.addSubview(faeSearchController.faeSearchBar)
        searchBarSubview.backgroundColor = UIColor.white
        self.view.addSubview(searchBarSubview)
        
        let uiviewDeleteSub = UIView()
        uiviewDeleteSub.backgroundColor = UIColor.white
        uiviewDeleteSub.layer.cornerRadius = 2
        searchBarSubview.addSubview(uiviewDeleteSub)
        searchBarSubview.addConstraintsWithFormat("H:[v0(20)]-10-|", options: [], views: uiviewDeleteSub)
        searchBarSubview.addConstraintsWithFormat("V:[v0(48)]-0-|", options: [], views: uiviewDeleteSub)
        let btnDeleteAll = UIButton()
        btnDeleteAll.setImage(#imageLiteral(resourceName: "locationExtendCancel"), for: .normal)
        btnDeleteAll.addTarget(self, action: #selector(self.actionClearSearchBar(_:)), for: .touchUpInside)
        searchBarSubview.addSubview(btnDeleteAll)
        searchBarSubview.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: btnDeleteAll)
        searchBarSubview.addConstraintsWithFormat("V:[v0(48)]-0-|", options: [], views: btnDeleteAll)
        
        let uiviewMagnifierSub = UIView()
        uiviewMagnifierSub.backgroundColor = UIColor.white
        uiviewMagnifierSub.layer.cornerRadius = 2
        searchBarSubview.addSubview(uiviewMagnifierSub)
        searchBarSubview.addConstraintsWithFormat("H:|-9-[v0(33)]", options: [], views: uiviewMagnifierSub)
        searchBarSubview.addConstraintsWithFormat("V:[v0(48)]-0-|", options: [], views: uiviewMagnifierSub)
        let btnMagnifier = UIButton()
        btnMagnifier.setImage(#imageLiteral(resourceName: "searchMagnifier"), for: .normal)
        searchBarSubview.addSubview(btnMagnifier)
        searchBarSubview.addConstraintsWithFormat("H:|-9-[v0(33)]", options: [], views: btnMagnifier)
        searchBarSubview.addConstraintsWithFormat("V:[v0(48)]-0-|", options: [], views: btnMagnifier)
        
        searchBarSubview.layer.borderColor = UIColor.white.cgColor
        searchBarSubview.layer.borderWidth = 1.0
        searchBarSubview.layer.cornerRadius = 2.0
        searchBarSubview.layer.shadowOpacity = 0.5
        searchBarSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        searchBarSubview.layer.shadowRadius = 5.0
        searchBarSubview.layer.shadowColor = UIColor.black.cgColor
    }
    
    func loadTableView() {
        uiviewTableSubview = UIView(frame: CGRect(x: 8, y: 78, width: resultTableWidth, height: 0))
        tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.register(FaeCellForMainScreenSearch.self, forCellReuseIdentifier: "faeCellForAddressSearch")
        tblSearchResults.isScrollEnabled = false
        tblSearchResults.layer.masksToBounds = true
        tblSearchResults.separatorInset = UIEdgeInsets.zero
        tblSearchResults.layoutMargins = UIEdgeInsets.zero
        uiviewTableSubview.layer.borderColor = UIColor.white.cgColor
        uiviewTableSubview.layer.borderWidth = 1.0
        uiviewTableSubview.layer.cornerRadius = 2.0
        uiviewTableSubview.layer.shadowOpacity = 0.5
        uiviewTableSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        uiviewTableSubview.layer.shadowRadius = 5.0
        uiviewTableSubview.layer.shadowColor = UIColor.black.cgColor
        uiviewTableSubview.addSubview(tblSearchResults)
        self.view.addSubview(uiviewTableSubview)
    }
}
