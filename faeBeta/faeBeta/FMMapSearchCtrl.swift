//
//  FMMapSearchResult.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-01.
//  Copyright © 2017 fae. All rights reserved.
//

import CCHMapClusterController

extension FaeMapViewController: MapSearchDelegate {
    
    // MapSearchDelegate
    func jumpToOnePlace(searchText: String, place: PlacePin) {
        updateUI(searchText: searchText)
        uiviewPlaceBar.load(for: place)
        PLACE_ENABLE = false
        let camera = faeMapView.camera
        camera.centerCoordinate = place.coordinate
        faeMapView.setCamera(camera, animated: false)
        placeClusterManager.removeAnnotations(faePlacePins) {
            self.faePlacePins.removeAll()
            let pin = FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: place)
            self.faePlacePins.append(pin)
            self.placeClusterManager.addAnnotations([pin], withCompletionHandler: nil)
        }
    }
    
    func jumpToPlaces(searchText: String, places: [PlacePin], selectedLoc: CLLocation) {
        if searchText == "fromEXP" {
            mapMode = .explore
            setTitle(type: "Random")
            placeClusterManager.removeAnnotations(faePlacePins) {
                let pins = places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
                self.placeClusterManager.addAnnotations(pins, withCompletionHandler: nil)
                self.zoomToFitAllAnnotations(annotations: pins)
            }
            for user in faeUserPins {
                user.isValid = false
            }
            userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
            arrExpPlace = places
            clctViewMap.reloadData()
        } else {
            updateUI(searchText: searchText)
            swipingState = .multipleSearch
            uiviewPlaceBar.places = placeResultTbl.updatePlacesArray(places: places)
            if let firstPlacePin = places.first {
                uiviewPlaceBar.loading(current: firstPlacePin)
            }
            btnTapToShowResultTbl.alpha = 1
            placeClusterManager.removeAnnotations(faePlacePins) {
                self.faePlacePins.removeAll()
                self.uiviewPlaceBar.places = places
                self.faePlacePins = self.uiviewPlaceBar.places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
                self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: nil)
                self.zoomToFitAllAnnotations(annotations: self.faePlacePins)
            }
        }
        PLACE_ENABLE = false
    }
    
    func zoomToFitAllAnnotations(annotations: [MKPointAnnotation]) {
        guard let firstAnn = annotations.first else { return }
        placeClusterManager.maxZoomLevelForClustering = 0
        let point = MKMapPointForCoordinate(firstAnn.coordinate)
        var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        var edgePadding = UIEdgeInsetsMake(120, 40, 100, 40)
        if mapMode == .explore {
            edgePadding = UIEdgeInsetsMake(120, 40, 300, 40)
        }
        faeMapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
    }
    
//    func backToMainMapFromMapSearch() {
//        lblSearchContent.text = "Search Fae Map"
//        lblSearchContent.textColor = UIColor._182182182()
//        btnClearSearchRes.isHidden = true
//    }
    // MapSearchDelegate End
    
    func updateUI(searchText: String) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        lblSearchContent.textColor = UIColor._898989()
    }
}
