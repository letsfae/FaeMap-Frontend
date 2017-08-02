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
    
    func maintainPlaceBarData(for annotation: CCHMapClusterAnnotation) -> [CCHMapClusterAnnotation] {
//        let annotations = visiblePlaces(except: annotation)
//        let count = annotations.count
//        joshprint("[maintainPlaceBarData], count = \(count)")
        let annos = [CCHMapClusterAnnotation]()
//        guard count > 0 else { return annos }
//        let idx_1st = Int(arc4random_uniform(UInt32(count)))
//        let idx_2nd = Int(arc4random_uniform(UInt32(count)))
//        let first = annotations[idx_1st]
//        annos.append(first)
//        annos.append(annotation)
//        let last = annotations[idx_2nd]
//        annos.append(last)
        return annos
    }
    
    func visiblePlaces() -> [CCHMapClusterAnnotation] {
        let visibleAnnos = faeMapView.annotations(in: faeMapView.visibleMapRect)
        var places = [CCHMapClusterAnnotation]()
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let place = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
                guard firstAnn.type == "place" else { continue }
                places.append(place)
            } else {
                continue
            }
        }
        return places
    }
    
    func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
//        boolCanOpenPin = false
        if let anView = view as? PlacePinAnnotationView {
            let idx = firstAnn.class_two_idx
            firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
            anView.assignImage(firstAnn.icon)
            selectedAnnView = anView
            selectedAnn = firstAnn
        }
        
        guard let _ = firstAnn.pinInfo as? PlacePin else { return }
        placeResultBar.isHidden = false
        placeResultBar.resetSubviews()
        placeResultBar.loadingData(current: cluster)
//        boolCanOpenPin = true
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
                    self.mapClusterManager.addAnnotations(placePins, withCompletionHandler: {
                        self.placeResultBar.tag = 1
                        self.mapView(self.faeMapView, regionDidChangeAnimated: true)
                    })
                    self.boolCanUpdatePlacePin = true
                }
            }
        }
    }
}
