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
        updateUI(searchText: searchText)
        PLACE_ENABLE = false
        swipingState = .multipleSearch
        uiviewPlaceBar.places = placeResultTbl.updatePlacesArray(places: places)
        if let firstPlacePin = places.first {
            uiviewPlaceBar.loading(current: firstPlacePin)
        }
        btnTapToShowResultTbl.alpha = 1
        placeClusterManager.removeAnnotations(faePlacePins) {
            self.faePlacePins.removeAll()
            for place in self.uiviewPlaceBar.places {
                let pin = FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: place)
                self.faePlacePins.append(pin)
            }
            self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: nil)
            self.zoomToFitAllAnnotations(annotations: self.faePlacePins)
        }
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
        let edgePadding = UIEdgeInsetsMake(60, 40, 60, 40)
        faeMapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: true)
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
