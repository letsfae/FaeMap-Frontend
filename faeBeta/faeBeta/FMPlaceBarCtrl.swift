//
//  FMPlaceDetail.swift
//  faeBeta
//
//  Created by Yue Shen on 7/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
//import CCHMapClusterController

extension FaeMapViewController: PlaceViewDelegate, FMPlaceTableDelegate {
    
    // FMPlaceTableDelegate
    func selectPlaceFromTable(_ placeData: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = placeData
        vcPlaceDetail.featureDelegate = self
        vcPlaceDetail.delegate = self
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // FMPlaceTableDelegate
    func reloadPlacesOnMap(places: [PlacePin]) {
        self.PLACE_INSTANT_SHOWUP = true
        //self.placeClusterManager.marginFactor = 10000
        let camera = faeMapView.camera
        camera.altitude = tblPlaceResult.altitude
        faeMapView.setCamera(camera, animated: false)
        reloadPlacePinsOnMap(places: places) {
            self.goTo(annotation: nil, place: self.tblPlaceResult.getGroupLastSelected(), animated: true)
            self.PLACE_INSTANT_SHOWUP = false
        }
    }
    
    func loadPlaceDetail() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapPlaceBar))
        tblPlaceResult.addGestureRecognizer(tapGesture)
        
        tblPlaceResult.tblDelegate = self
        tblPlaceResult.barDelegate = self
        view.addSubview(tblPlaceResult)
        
        btnTapToShowResultTbl = UIButton()
        btnTapToShowResultTbl.setImage(#imageLiteral(resourceName: "tapToShowResultTbl"), for: .normal)
        btnTapToShowResultTbl.frame.size = CGSize(width: 58, height: 30)
        btnTapToShowResultTbl.center.x = screenWidth / 2
        btnTapToShowResultTbl.center.y = 181 + device_offset_top
        view.addSubview(btnTapToShowResultTbl)
        btnTapToShowResultTbl.alpha = 0
        btnTapToShowResultTbl.addTarget(self, action: #selector(self.actionShowResultTbl(_:)), for: .touchUpInside)
    }
    
    @objc func handleTapPlaceBar() {
        placePinAction(action: .detail, mode: .location)
    }
    
    // PlaceViewDelegate
    func goTo(annotation: CCHMapClusterAnnotation? = nil, place: PlacePin? = nil, animated: Bool = true) {
        
        func findAnnotation() {
            if let placePin = place {
                swipingState = .multipleSearch
                var desiredAnno: CCHMapClusterAnnotation!
                for anno in faeMapView.annotations {
                    guard let cluster = anno as? CCHMapClusterAnnotation else { continue }
                    guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { continue }
                    guard let placeInfo = firstAnn.pinInfo as? PlacePin else { continue }
                    if placeInfo == placePin {
                        desiredAnno = cluster
                        break
                    }
                }
                if animated {
                    faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: placePin.coordinate)
                }
                if desiredAnno != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.faeMapView.selectAnnotation(desiredAnno, animated: false)
                    }
                }
            }
        }
        
        deselectAllAnnotations()
        if let anno = annotation {
            swipingState = .map
            boolPreventUserPinOpen = true
            faeMapView.selectAnnotation(anno, animated: false)
            boolPreventUserPinOpen = false
            if animated {
                faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: anno.coordinate)
            }
        }
        
        // If going to prev or next group
        if tblPlaceResult.goingToNextGroup {
            tblPlaceResult.configureCurrentPlaces(goingNext: true)
            self.PLACE_INSTANT_SHOWUP = true
            reloadPlacePinsOnMap(places: tblPlaceResult.places) {
                findAnnotation()
                self.tblPlaceResult.goingToNextGroup = false
                self.PLACE_INSTANT_SHOWUP = false
            }
            return
        } else if tblPlaceResult.goingToPrevGroup {
            self.PLACE_INSTANT_SHOWUP = true
            tblPlaceResult.configureCurrentPlaces(goingNext: false)
            reloadPlacePinsOnMap(places: tblPlaceResult.places) {
                findAnnotation()
                self.tblPlaceResult.goingToPrevGroup = false
                self.PLACE_INSTANT_SHOWUP = false
            }
            return
        } else {
            findAnnotation()
        }
        if let placePin = place { // 必须放在最末尾
            tblPlaceResult.loading(current: placePin)
        }
    }
}
