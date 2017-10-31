//
//  FMMapSearchResult.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-01.
//  Copyright © 2017 fae. All rights reserved.
//

import CCHMapClusterController

extension FaeMapViewController: MapSearchDelegate {
    
    func jumpToLocation(region: MKCoordinateRegion) {
        faeMapView.setRegion(region, animated: true)
    }
    
    // MapSearchDelegate
    func jumpToOnePlace(searchText: String, place: PlacePin) {
        PLACE_ENABLE = false
        let pin = FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: place)
        placesFromSearch.append(pin)
        if searchText == "fromPlaceDetail" {
            mapMode = .pinDetail
            let pin_self = FaePinAnnotation(type: "place", data: place)
            pin_self.coordinate = LocManager.shared.curtLoc.coordinate
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(place.coordinate, 3000, 3000)
            faeMapView.setRegion(coordinateRegion, animated: false)
            animateMainItems(show: true, animated: false)
            faeMapView.blockTap = true
            lblExpContent.text = "Map View"
        } else {
            updateUI(searchText: searchText)
            let camera = faeMapView.camera
            camera.centerCoordinate = place.coordinate
            faeMapView.setCamera(camera, animated: false)
        }
        uiviewPlaceBar.load(for: place)
        placeClusterManager.removeAnnotations(faePlacePins) {
            self.placeClusterManager.addAnnotations([pin], withCompletionHandler: nil)
        }
        for user in faeUserPins {
            user.isValid = false
        }
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
    }
    
    func jumpToPlaces(searchText: String, places: [PlacePin], selectedLoc: CLLocation) {
        guard places.count > 0 else { return }
        PLACE_ENABLE = false
        placesFromSearch = places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
        placeClusterManager.removeAnnotations(faePlacePins) {
            self.placeClusterManager.addAnnotations(self.placesFromSearch, withCompletionHandler: nil)
            self.zoomToFitAllAnnotations(annotations: self.placesFromSearch)
        }
        for user in faeUserPins {
            user.isValid = false
        }
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
        if searchText == "fromEXP" {
            mapMode = .explore
            setTitle(type: "Random")
            arrExpPlace = places
            clctViewMap.reloadData()
        } else {
            updateUI(searchText: searchText)
            swipingState = .multipleSearch
            uiviewPlaceBar.places = tblPlaceResult.updatePlacesArray(places: places)
            if let firstPlacePin = places.first {
                uiviewPlaceBar.loading(current: firstPlacePin)
            }
            uiviewPlaceBar.places = places
        }
    }
    
    func zoomToFitAllAnnotations(annotations: [MKPointAnnotation]) {
        guard let firstAnn = annotations.first else { return }
//        placeClusterManager.maxZoomLevelForClustering = 0
        let point = MKMapPointForCoordinate(firstAnn.coordinate)
        var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        var edgePadding = UIEdgeInsetsMake(240, 40, 100, 40)
        if mapMode == .explore {
            edgePadding = UIEdgeInsetsMake(120, 40, 300, 40)
        } else if mapMode == .pinDetail {
            edgePadding = UIEdgeInsetsMake(220, 80, 120, 80)
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
