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
    
    func actionMainScreenSearch(_ sender: UIButton) {
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
        let searchVC = MapSearchViewController()
        searchVC.faeMapView = self.faeMapView
        searchVC.delegate = self
        searchVC.strSearchedPlace = lblSearchContent.text
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    func actionClearSearchResults(_ sender: UIButton) {
        if createLocation == .create {
            createLocation = .cancel
            return
        }
        PLACE_ENABLE = true
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textColor = UIColor._182182182()
        btnClearSearchRes.isHidden = true
        uiviewPlaceBar.alpha = 0
        uiviewPlaceBar.state = .map
        tblPlaceResult.alpha = 0
        btnTapToShowResultTbl.alpha = 0
        btnLocateSelf.isHidden = false
        btnCompass.isHidden = false
        btnTapToShowResultTbl.center.y = 181
        mapGesture(isOn: true)
        deselectAllAnnotations()
        placeClusterManager.removeAnnotations(placesFromSearch) {
            self.placesFromSearch.removeAll(keepingCapacity: true)
        }
        placeClusterManager.addAnnotations(faePlacePins, withCompletionHandler: nil)
        placeClusterManager.addAnnotations(faeUserPins, withCompletionHandler: nil)
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
    
    func actionLeftWindowShow(_ sender: UIButton) {
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        let leftMenuVC = LeftSlidingMenuViewController()
        leftMenuVC.delegate = self
        leftMenuVC.displayName = Key.shared.nickname ?? "Someone"
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        present(leftMenuVC, animated: false, completion: nil)
    }
    
    func actionShowResultTbl(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            tblPlaceResult.show {
                self.btnTapToShowResultTbl.center.y = screenHeight - 164 * screenHeightFactor + 15 + 68
            }
            btnCompass.isHidden = true
            btnLocateSelf.isHidden = true
            btnTapToShowResultTbl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        } else {
            sender.tag = 0
            tblPlaceResult.hide()
            btnCompass.isHidden = false
            btnLocateSelf.isHidden = false
            btnTapToShowResultTbl.center.y = 181
            btnTapToShowResultTbl.transform = CGAffineTransform.identity
        }
    }
    
    func actionChatWindowShow(_ sender: UIButton) {
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        UINavigationBar.appearance().shadowImage = imgNavBarDefaultShadow
        // check if the user's logged in the backendless
        //let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()! as! RecentViewController
        let chatVC = RecentViewController()
        chatVC.backClosure = {
            (backNum: Int) -> Void in
            //self.count = backNum
        }
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func actionOpenExplore(_ sender: UIButton) {
        uiviewNameCard.hide {}
        let vcExp = ExploreViewController()
        vcExp.delegate = self
        navigationController?.pushViewController(vcExp, animated: true)
    }
    
    func actionCancelSelecting() {
        mapMode = .routing
        uiviewChooseLocs.show()
    }
    
    func actionBackToExp(_ sender: UIButton) {
        if mapMode == .explore {
            let vcExp = ExploreViewController()
            vcExp.delegate = self
            navigationController?.pushViewController(vcExp, animated: false)
        } else if mapMode == .pinDetail {
            if let ann = selectedPlace {
                guard let placePin = ann.pinInfo as? PlacePin else { return }
                selectedPlaceView?.hideButtons()
                let vcPlaceDetail = PlaceDetailViewController()
                vcPlaceDetail.place = placePin
                vcPlaceDetail.delegate = self
                navigationController?.pushViewController(vcPlaceDetail, animated: true)
            }
            animateMainItems(show: false, animated: false)
            uiviewPlaceBar.hide()
        }
        mapMode = .normal
        faeMapView.blockTap = false
//        placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        placeClusterManager.addAnnotations(faeUserPins, withCompletionHandler: nil)
        placeClusterManager.addAnnotations(faePlacePins, withCompletionHandler: nil)
        arrExpPlace.removeAll(keepingCapacity: true)
        clctViewMap.reloadData()
    }
}
