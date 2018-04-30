//
//  FMActions.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    
    func renewSelfLocation() {
        DispatchQueue.global(qos: .default).async {
            guard CLLocationManager.locationServicesEnabled() else { return }
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                break
            case .authorizedAlways, .authorizedWhenInUse:
                let selfLocation = FaeMap()
                selfLocation.whereKey("geo_latitude", value: "\(LocManager.shared.curtLat)")
                selfLocation.whereKey("geo_longitude", value: "\(LocManager.shared.curtLong)")
                selfLocation.renewCoordinate {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        // print("Successfully renew self position")
                    } else {
                        print("[renewSelfLocation] fail")
                    }
                }
            }
        }
    }
    
    @objc func actionMainScreenSearch(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        uiviewDropUpMenu.hide()
        let searchVC = MapSearchViewController()
        searchVC.faeMapView = self.faeMapView
        searchVC.delegate = self
        if let text = lblSearchContent.text {
            searchVC.strSearchedPlace = text
        } else {
            searchVC.strSearchedPlace = ""
        }
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    @objc func actionClearSearchResults(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        if modeLocCreating == .on {
            modeLocCreating = .off
            return
        }
        PLACE_ENABLE = true
        
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textColor = UIColor._182182182()
        
        btnClearSearchRes.isHidden = true
        btnTapToShowResultTbl.alpha = 0
        btnLocateSelf.isHidden = false
        btnZoom.isHidden = false
        btnTapToShowResultTbl.center.y = 181 + device_offset_top
        btnTapToShowResultTbl.tag = 1
        btnTapToShowResultTbl.sendActions(for: .touchUpInside)
        
        tblPlaceResult.state = .map
        swipingState = .map
        tblPlaceResult.hide(animated: false)
        placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        
        tblPlaceResult.alpha = 0
        
        mapGesture(isOn: true)
        deselectAllAnnotations()
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(pinsFromSearch) {
            self.pinsFromSearch.removeAll(keepingCapacity: true)
            self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: {
                self.placeClusterManager.isForcedRefresh = false
            })
        }
        userClusterManager.addAnnotations(faeUserPins, withCompletionHandler: nil)
    }
    
    func cancelSearch() {
        
    }
    
    func actionPlacePinAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        default:
            break
        }
    }
    
    @objc func actionLeftWindowShow(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        let leftMenuVC = LeftSlidingMenuViewController()
        leftMenuVC.delegate = self
        leftMenuVC.displayName = Key.shared.nickname
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        present(leftMenuVC, animated: false, completion: nil)
    }
    
    @objc func actionShowResultTbl(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        if sender.tag == 0 {
            sender.tag = 1
            tblPlaceResult.expand {
                let iphone_x_offset: CGFloat = 70
                self.btnTapToShowResultTbl.center.y = screenHeight - 164 * screenHeightFactor + 15 + 68 + device_offset_top - iphone_x_offset
            }
            btnZoom.isHidden = true
            btnLocateSelf.isHidden = true
            btnTapToShowResultTbl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        } else {
            sender.tag = 0
            tblPlaceResult.shrink {
                self.btnTapToShowResultTbl.center.y = 181 + device_offset_top
            }
            btnZoom.isHidden = false
            btnLocateSelf.isHidden = false
            btnTapToShowResultTbl.transform = CGAffineTransform.identity
        }
    }
    
    @objc func actionChatWindowShow(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        UINavigationBar.appearance().shadowImage = imgNavBarDefaultShadow
        // check if the user's logged in the backendless
        //let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()! as! RecentViewController
        let chatVC = RecentViewController()
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc func actionOpenExplore(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        uiviewNameCard.hide {}
        let vcExp = ExploreViewController()
        vcExp.delegate = self
        navigationController?.pushViewController(vcExp, animated: true)
    }
    
    @objc func actionCancelSelecting() {
        btnZoom.tapToSmallMode()
        mapMode = .routing
        uiviewChooseLocs.show()
    }
    
    @objc func actionBackTo(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        switch mapMode {
        case .explore:
            let vcExp = ExploreViewController()
            vcExp.delegate = self
            navigationController?.pushViewController(vcExp, animated: false)
        case .pinDetail:
            break
        case .collection:
            placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
            tblPlaceResult.hide()
            btnTapToShowResultTbl.alpha = 0
            btnTapToShowResultTbl.tag = 1
            btnTapToShowResultTbl.sendActions(for: .touchUpInside)
            animateMainItems(show: false, animated: boolFromMap)
            if boolFromMap == false {
                boolFromMap = true
                navigationController?.setViewControllers(arrCtrlers, animated: false)
            }
            if let idxPath = uiviewDropUpMenu.selectedIndexPath {
                if let cell = uiviewDropUpMenu.tblPlaceLoc.cellForRow(at: idxPath) as? CollectionsListCell {
                    cell.imgIsIn.isHidden = true
                    uiviewDropUpMenu.selectedIndexPath = nil
                }
            }
        case .allPlaces:
            animateMainItems(show: false, animated: false)
            navigationController?.setViewControllers(arrCtrlers, animated: false)
        default:
            break
        }
        backFromPinDetail()
        PLACE_ENABLE = true
        mapMode = .normal
        faeMapView.blockTap = false
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(pinsFromSearch, withCompletionHandler: {
            self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: {
                self.placeClusterManager.isForcedRefresh = false
            })
        })
        userClusterManager.addAnnotations(faeUserPins, withCompletionHandler: nil)
        arrExpPlace.removeAll()
        clctViewMap.reloadData()
    }
    
    func backFromPinDetail() {
        if modePinDetail == .on {
            if let ann = selectedPlace {
                guard let placePin = ann.pinInfo as? PlacePin else { return }
                selectedPlaceView?.hideButtons()
                let vcPlaceDetail = PlaceDetailViewController()
                vcPlaceDetail.place = placePin
                vcPlaceDetail.delegate = self
                navigationController?.pushViewController(vcPlaceDetail, animated: false)
            }
            animateMainItems(show: false, animated: false)
            tblPlaceResult.hide()
            modePinDetail = .off
            checkIfResultTableAppearred()
        }
    }
}
