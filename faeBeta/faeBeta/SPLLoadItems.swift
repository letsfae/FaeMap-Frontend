//
//  SPLLoadItems.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension SelectLocationViewController {
    
    func loadMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
        self.mapSelectLocation = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapSelectLocation.isMyLocationEnabled = true
        mapSelectLocation.delegate = self
        self.view = mapSelectLocation
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        
        imagePinOnMap = UIImageView(frame: CGRect(x: screenWidth/2-25, y: screenHeight/2-54, width: 50, height: 54))
        imagePinOnMap.image = UIImage(named: "commentMarkerWhenCreated")
        self.view.addSubview(imagePinOnMap)
        // Default is true, if true, panGesture could not be detected
        self.mapSelectLocation.settings.consumesGesturesInView = false
    }
    
    func loadButtons() {
        buttonCancelSelectLocation = UIButton(frame: CGRect(x: 0, y: 0, width: 59, height: 59))
        buttonCancelSelectLocation.setImage(UIImage(named: "cancelSelectLocation"), for: UIControlState())
        self.view.addSubview(buttonCancelSelectLocation)
        buttonCancelSelectLocation.addTarget(self, action: #selector(SelectLocationViewController.actionCancelSelectLocation(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-18-[v0(59)]", options: [], views: buttonCancelSelectLocation)
        self.view.addConstraintsWithFormat("V:[v0(59)]-77-|", options: [], views: buttonCancelSelectLocation)
        
        buttonSelfPosition = UIButton()
        self.view.addSubview(buttonSelfPosition)
        buttonSelfPosition.setImage(UIImage(named: "mainScreenSelfPosition"), for: UIControlState())
        buttonSelfPosition.addTarget(self, action: #selector(SelectLocationViewController.actionSelfPosition(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(59)]-18-|", options: [], views: buttonSelfPosition)
        self.view.addConstraintsWithFormat("V:[v0(59)]-77-|", options: [], views: buttonSelfPosition)
        
        buttonSetLocationOnMap = UIButton()
        buttonSetLocationOnMap.setTitle("Set Location", for: UIControlState())
        buttonSetLocationOnMap.setTitle("Set Location", for: .highlighted)
        buttonSetLocationOnMap.setTitleColor(colorFae, for: UIControlState())
        buttonSetLocationOnMap.setTitleColor(UIColor.lightGray, for: .highlighted)
        buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        self.view.addSubview(buttonSetLocationOnMap)
        buttonSetLocationOnMap.addTarget(self, action: #selector(SelectLocationViewController.actionSetLocationForComment(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonSetLocationOnMap)
        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonSetLocationOnMap)
    }
    
    func loadCustomSearchController() {
        let searchBarSubview = UIView(frame: CGRect(x: 8, y: 23, width: resultTableWidth, height: 48.0))
        
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0, y: 5, width: resultTableWidth, height: 38.0), searchBarFont: UIFont(name: "AvenirNext-Medium", size: 18.0)!, searchBarTextColor: colorFae, searchBarTintColor: UIColor.white)
        customSearchController.customSearchBar.placeholder = "Search Address or Place                                  "
        customSearchController.customDelegate = self
        customSearchController.customSearchBar.layer.borderWidth = 2.0
        customSearchController.customSearchBar.layer.borderColor = UIColor.white.cgColor
        
        searchBarSubview.addSubview(customSearchController.customSearchBar)
        searchBarSubview.backgroundColor = UIColor.white
        self.view.addSubview(searchBarSubview)
        
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
        tblSearchResults.register(CustomCellForAddressSearch.self, forCellReuseIdentifier: "customCellForAddressSearch")
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
