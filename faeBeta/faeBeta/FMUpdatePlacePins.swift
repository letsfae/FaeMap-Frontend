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
    
    func visiblePlaces() -> [CCHMapClusterAnnotation] {
        var mapRect = faeMapView.visibleMapRect
        mapRect.origin.y += mapRect.size.height * 0.2
        mapRect.size.height = mapRect.size.height * 0.8
        let visibleAnnos = faeMapView.annotations(in: mapRect)
        var places = [CCHMapClusterAnnotation]()
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let place = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
                guard faeMapView.view(for: place) is PlacePinAnnotationView else { continue }
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
        if let anView = view as? PlacePinAnnotationView {
            let idx = firstAnn.class_two_idx
            firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
            anView.assignImage(firstAnn.icon)
            selectedAnnView = anView
            selectedAnn = firstAnn
        }
        
        guard let _ = firstAnn.pinInfo as? PlacePin else { return }
        placeResultBar.fadeIn()
        placeResultBar.resetSubviews()
        placeResultBar.tag = 1
        mapView(faeMapView, regionDidChangeAnimated: true)
        placeResultBar.loadingData(current: cluster)
    }
    
    func updateTimerForLoadRegionPlacePin() {
        loadCurrentRegionPlacePins()
    }
    
    func loadCurrentRegionPlacePins() {
        let coorDistance = cameraDiagonalDistance()
        guard boolCanUpdatePlacePin else { return }
        boolCanUpdatePlacePin = false
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
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
        getPlaceInfo.whereKey("max_count", value: "100")
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
