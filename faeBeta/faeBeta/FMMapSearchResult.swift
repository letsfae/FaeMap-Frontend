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
        placeResultBar.load(for: place)
        PLACE_ENABLE = false
        let camera = faeMapView.camera
        camera.centerCoordinate = place.coordinate
        faeMapView.setCamera(camera, animated: false)
        mapClusterManager.removeAnnotations(faePlacePins) {
            self.faePlacePins.removeAll()
            let pin = FaePinAnnotation(type: "place", cluster: self.mapClusterManager)
            pin.pinInfo = place as AnyObject
            pin.id = place.id
            pin.class_2_icon_id = place.class_2_icon_id
            pin.icon = UIImage(named: "place_map_\(place.class_2_icon_id)s") ?? #imageLiteral(resourceName: "place_map_48s")
            pin.coordinate = place.coordinate
            self.faePlacePins.append(pin)
            self.mapClusterManager.addAnnotations([pin], withCompletionHandler: nil)
        }
    }
    
    func jumpToPlaces(searchText: String, places: [PlacePin], selectedLoc: CLLocation) {
        updateUI(searchText: searchText)
        PLACE_ENABLE = false
        placeResultTbl.arrPlaces = places
        placeResultTbl.tblResults.reloadData()
        placeResultTbl.lblNumResults.text = places.count == 1 ? "1 Result" : "\(places.count) Results"
        placeResultBar.places = places
        if let firstPlacePin = places.first {
            placeResultBar.loading(current: firstPlacePin)
        }
        btnTapToShowResultTbl.alpha = 1
        mapClusterManager.removeAnnotations(faePlacePins) {
            self.faePlacePins.removeAll()
            for place in places {
                let pin = FaePinAnnotation(type: "place", cluster: self.mapClusterManager)
                pin.pinInfo = place as AnyObject
                pin.id = place.id
                pin.class_2_icon_id = place.class_2_icon_id
                pin.icon = UIImage(named: "place_map_\(place.class_2_icon_id)") ?? #imageLiteral(resourceName: "place_map_48")
                pin.coordinate = place.coordinate
                self.faePlacePins.append(pin)
            }
            self.mapClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: nil)
            self.zoomToFitAllAnnotations(annotations: self.faePlacePins)
        }
    }
    
    func zoomToFitAllAnnotations(annotations: [MKPointAnnotation]) {
        mapClusterManager.maxZoomLevelForClustering = 0
        let point = MKMapPointForCoordinate(LocManager.shared.curtLoc.coordinate)
        var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        let edgePadding = UIEdgeInsetsMake(60, 40, 60, 40)
        faeMapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: true)
    }
    
    func backToMainMapFromMapSearch() {
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textColor = UIColor._182182182()
        btnClearSearchRes.isHidden = true
    }
    // MapSearchDelegate End
    
    func updateUI(searchText: String) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        lblSearchContent.textColor = UIColor._898989()
    }
}
