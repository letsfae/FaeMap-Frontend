//
//  FMLoadMainItems.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit
import CCHMapClusterController

extension FaeMapViewController {
    
    // MARK: -- Load Map
    func loadMapView() {
        faeMapView = FaeMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        faeMapView.delegate = self
        view.addSubview(faeMapView)
        view.sendSubview(toBack: faeMapView)
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = true
        faeMapView.delegate = self
        faeMapView.showsUserLocation = true
        faeMapView.faeMapCtrler = self
        
        placeClusterManager = CCHMapClusterController(mapView: faeMapView)
        placeClusterManager.delegate = self
        placeClusterManager.cellSize = 100
        placeClusterManager.minUniqueLocationsForClustering = 3
        placeClusterManager.clusterer = self
        placeClusterManager.animator = self
        placeClusterManager.marginFactor = 0.0
        
        userClusterManager = CCHMapClusterController(mapView: faeMapView)
        userClusterManager.delegate = self
        userClusterManager.cellSize = 100
        userClusterManager.marginFactor = 0.0
        
        locationPinClusterManager = CCHMapClusterController(mapView: faeMapView)
        locationPinClusterManager.delegate = self
        locationPinClusterManager.cellSize = 60
        locationPinClusterManager.animator = self
        locationPinClusterManager.clusterer = self
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        prevMapCenter = LocManager.shared.curtLoc.coordinate
        refreshMap(pins: false, users: true, places: true)
    }
    
    @objc func firstUpdateLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        refreshMap(pins: false, users: true, places: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
    }
    
    // MARK: -- Load Map Main Screen Buttons
    func loadButton() {
        imgSchbarShadow = UIImageView()
        imgSchbarShadow.frame = CGRect(x: 2, y: 17 + device_offset_top, width: 410 * screenWidthFactor, height: 60)
        imgSchbarShadow.image = #imageLiteral(resourceName: "mapSearchBar")
        view.addSubview(imgSchbarShadow)
        imgSchbarShadow.layer.zPosition = 500
        imgSchbarShadow.isUserInteractionEnabled = true
        
        // Left window on main map to open account system
        btnLeftWindow = UIButton()
        btnLeftWindow.setImage(#imageLiteral(resourceName: "mapLeftMenu"), for: .normal)
        imgSchbarShadow.addSubview(btnLeftWindow)
        btnLeftWindow.addTarget(self, action: #selector(self.actionLeftWindowShow(_:)), for: .touchUpInside)
        imgSchbarShadow.addConstraintsWithFormat("H:|-6-[v0(48)]", options: [], views: btnLeftWindow)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0(48)]", options: [], views: btnLeftWindow)
        
        btnCancelSelect = UIButton()
        btnCancelSelect.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        imgSchbarShadow.addSubview(btnCancelSelect)
        btnCancelSelect.addTarget(self, action: #selector(self.actionCancelSelecting), for: .touchUpInside)
        imgSchbarShadow.addConstraintsWithFormat("H:|-6-[v0(40.5)]", options: [], views: btnCancelSelect)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0(48)]", options: [], views: btnCancelSelect)
        btnCancelSelect.isHidden = true
        
        imgSearchIcon = UIImageView()
        imgSearchIcon.image = #imageLiteral(resourceName: "searchBarIcon")
        imgSchbarShadow.addSubview(imgSearchIcon)
        imgSchbarShadow.addConstraintsWithFormat("H:|-54-[v0(15)]", options: [], views: imgSearchIcon)
        imgSchbarShadow.addConstraintsWithFormat("V:|-23-[v0(15)]", options: [], views: imgSearchIcon)
        
        imgAddressIcon = UIImageView()
        imgAddressIcon.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        imgSchbarShadow.addSubview(imgAddressIcon)
        imgSchbarShadow.addConstraintsWithFormat("H:|-54-[v0(15)]", options: [], views: imgAddressIcon)
        imgSchbarShadow.addConstraintsWithFormat("V:|-23-[v0(15)]", options: [], views: imgAddressIcon)
        imgAddressIcon.isHidden = true
        
        lblSearchContent = UILabel()
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textAlignment = .left
        lblSearchContent.lineBreakMode = .byTruncatingTail
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = UIColor._182182182()
        imgSchbarShadow.addSubview(lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("H:|-78-[v0]-60-|", options: [], views: lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: lblSearchContent)
        
        // Open main map search
        btnMainMapSearch = UIButton()
        imgSchbarShadow.addSubview(btnMainMapSearch)
        imgSchbarShadow.addConstraintsWithFormat("H:|-78-[v0]-60-|", options: [], views: btnMainMapSearch)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0]-6-|", options: [], views: btnMainMapSearch)
        btnMainMapSearch.addTarget(self, action: #selector(self.actionMainScreenSearch(_:)), for: .touchUpInside)
        
        // Click to clear search results
        btnClearSearchRes = UIButton()
        btnClearSearchRes.setImage(#imageLiteral(resourceName: "mainScreenSearchClearSearchBar"), for: .normal)
        btnClearSearchRes.isHidden = true
        btnClearSearchRes.addTarget(self, action: #selector(self.actionClearSearchResults(_:)), for: .touchUpInside)
        imgSchbarShadow.addSubview(btnClearSearchRes)
        imgSchbarShadow.addConstraintsWithFormat("H:[v0(36.45)]-10-|", options: [], views: btnClearSearchRes)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0]-6-|", options: [], views: btnClearSearchRes)
        
        // Click to take an action for place pin
        uiviewPinActionDisplay = FMPinActionDisplay()
        imgSchbarShadow.addSubview(uiviewPinActionDisplay)
        imgSchbarShadow.addConstraintsWithFormat("H:|-5-[v0]-5-|", options: [], views: uiviewPinActionDisplay)
        imgSchbarShadow.addConstraintsWithFormat("V:|-5-[v0]-5-|", options: [], views: uiviewPinActionDisplay)
        
        // Click to back to zoom
        btnZoom = FMZoomButton()
        btnZoom.mapView = faeMapView
        view.addSubview(btnZoom)
        
        // Click to locate the current location
        btnLocateSelf = FMLocateSelf()
        btnLocateSelf.mapView = faeMapView
        view.addSubview(btnLocateSelf)
        btnLocateSelf.nameCard = uiviewNameCard
        
        // Open chat view
        btnOpenChat = UIButton(frame: CGRect(x: 12, y: screenHeight - 90 - device_offset_bot, width: 79, height: 79))
        btnOpenChat.setImage(#imageLiteral(resourceName: "mainScreenNoChat"), for: .normal)
        btnOpenChat.setImage(#imageLiteral(resourceName: "mainScreenHaveChat"), for: .selected)
        btnOpenChat.addTarget(self, action: #selector(self.actionChatWindowShow(_:)), for: .touchUpInside)
        view.addSubview(btnOpenChat)
        btnOpenChat.layer.zPosition = 500
        
        // Show the number of unread messages on main map
        lblUnreadCount = UILabel(frame: CGRect(x: 55, y: 1, width: 25, height: 22))
        lblUnreadCount.backgroundColor = UIColor.init(red: 102 / 255, green: 192 / 255, blue: 251 / 255, alpha: 1)
        lblUnreadCount.layer.cornerRadius = 11
        lblUnreadCount.layer.masksToBounds = true
        lblUnreadCount.layer.opacity = 0.9
        lblUnreadCount.text = "1"
        lblUnreadCount.textAlignment = .center
        lblUnreadCount.textColor = UIColor.white
        lblUnreadCount.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        btnOpenChat.addSubview(lblUnreadCount)
        
        // Create pin on main map
        btnDiscovery = UIButton(frame: CGRect(x: screenWidth - 91, y: screenHeight - 90 - device_offset_bot, width: 79, height: 79))
        btnDiscovery.setImage(UIImage(named: "mainScreenDiscovery"), for: .normal)
        view.addSubview(btnDiscovery)
        btnDiscovery.addTarget(self, action: #selector(self.actionOpenExplore(_:)), for: .touchUpInside)
        btnDiscovery.layer.zPosition = 500
    }
    
    func loadExploreBar() {
        imgExpbarShadow = UIImageView()
        imgExpbarShadow.frame = CGRect(x: 2, y: 17 + device_offset_top, width: 410 * screenWidthFactor, height: 60)
        imgExpbarShadow.image = #imageLiteral(resourceName: "mapSearchBar")
        view.addSubview(imgExpbarShadow)
        imgExpbarShadow.layer.zPosition = 500
        imgExpbarShadow.isUserInteractionEnabled = true
        imgExpbarShadow.isHidden = true
        
        // Left window on main map to open account system
        let btnBackToExp = UIButton()
        btnBackToExp.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        imgExpbarShadow.addSubview(btnBackToExp)
        btnBackToExp.addTarget(self, action: #selector(self.actionBackTo(_:)), for: .touchUpInside)
        imgExpbarShadow.addConstraintsWithFormat("H:|-6-[v0(40.5)]", options: [], views: btnBackToExp)
        imgExpbarShadow.addConstraintsWithFormat("V:|-6-[v0(48)]", options: [], views: btnBackToExp)
        btnBackToExp.adjustsImageWhenDisabled = false
        
        lblExpContent = UILabel()
        lblExpContent.textAlignment = .center
        lblExpContent.numberOfLines = 1
        lblExpContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblExpContent.textColor = UIColor._898989()
        imgExpbarShadow.addSubview(lblExpContent)
        imgExpbarShadow.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblExpContent)
        imgExpbarShadow.addConstraintsWithFormat("V:|-18.5-[v0(25)]", options: [], views: lblExpContent)
    }
    
    func setTitle(type: String) {
        let title_0 = type
        let title_1 = " Around Me"
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        lblExpContent.attributedText = title_0_attr
    }
    
    func setCollectionTitle(type: String) {
        let title_0 = type
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        lblExpContent.attributedText = title_0_attr
    }
}
