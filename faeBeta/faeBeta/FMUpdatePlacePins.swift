//
//  FMUpdatePlacePins.swift
//  faeBeta
//
//  Created by Yue on 3/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CCHMapClusterController

extension FaeMapViewController {
    
    func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let clusterAnn = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return }
        boolCanOpenPin = false
        animateToCoordinate(type: 2, coordinate: clusterAnn.coordinate, animated: true)
        if let anView = view as? PlacePinAnnotationView {
            let idx = firstAnn.class_two_idx
            firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? UIImage()
            anView.assignImage(firstAnn.icon)
            selectedAnnView = anView
            selectedAnn = firstAnn
        }
        
        guard let placePin = firstAnn.pinInfo as? PlacePin else { return }
        placeResultBar.isHidden = false
        placeResultBar.resetSubviews()
        placeResultBar.loadingData(for: 1, data: placePin)
        boolCanOpenPin = true
    }
    
    func updateTimerForLoadRegionPlacePin() {
        loadCurrentRegionPlacePins()
//        if timerLoadRegionPlacePins != nil {
//            timerLoadRegionPlacePins.invalidate()
//        }
//        timerLoadRegionPlacePins = Timer.scheduledTimer(timeInterval: 750, target: self, selector: #selector(self.loadCurrentRegionPlacePins), userInfo: nil, repeats: true)
    }
    
    func loadCurrentRegionPlacePins() {
        let coorDistance = cameraDiagonalDistance()
        guard boolCanUpdatePlacePin else { return }
        boolCanUpdatePlacePin = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.refreshPlacePins(radius: coorDistance)
            self.boolCanUpdatePlacePin = true
        })
    }
    
    fileprivate func refreshPlacePins(radius: Int, all: Bool = true) {
        boolCanUpdatePlacePin = false
        renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        let getPlaceInfo = FaeMap()
        getPlaceInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getPlaceInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getPlaceInfo.whereKey("radius", value: "500000")
        getPlaceInfo.whereKey("type", value: "place")
        getPlaceInfo.whereKey("max_count", value: "1000")
        getPlaceInfo.getMapInformation { (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                print("DEBUG: getMapUserInfo status/100 != 2")
                self.boolCanUpdatePlacePin = true
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                print("[getMapUserInfo] fail to parse pin comments")
                self.boolCanUpdatePlacePin = true
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                self.boolCanUpdatePlacePin = true
                return
            }
            var placePins = [FaePinAnnotation]()
            DispatchQueue.global(qos: .default).async {
                for placeJson in mapPlaceJsonArray {
                    var place: FaePinAnnotation? = FaePinAnnotation(type: "place", cluster: self.mapClusterManager, json: placeJson)
                    guard place != nil else { continue }
                    if self.faePlacePins.contains(place!) {
                        guard let index = self.faeUserPins.index(of: place!) else { continue }
                        self.faePlacePins[index].positions = (place?.positions)!
                        place = nil
                    } else {
                        self.faePlacePins.append(place!)
                        placePins.append(place!)
                    }
                }
                guard placePins.count > 0 else {
                    self.boolCanUpdatePlacePin = true
                    return
                }
                DispatchQueue.main.async {
                    self.mapClusterManager.addAnnotations(placePins, withCompletionHandler: nil)
                    self.boolCanUpdatePlacePin = true
                }
            }
        }
    }
}
