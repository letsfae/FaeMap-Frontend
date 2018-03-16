//
//  FMMapSearchResult.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-01.
//  Copyright © 2017 fae. All rights reserved.
//

//import CCHMapClusterController

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
            // mapMode = .pinDetail
            modePinDetail = .on
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
        tblPlaceResult.load(for: place)
        removePlaceUserPins({
            self.placeClusterManager.addAnnotations([pin], withCompletionHandler: nil)
        }, nil)
    }
    
    // TODO YUE - DONE
    /*
     按搜索返回地图不显示category了就直接显示具体地点等其他results
     跟如果用户搜了乱码比如 ‘esjufah’ 一样，按搜索前显示无结果因为没有符合包括用户输入内容的任何东西，这时用户点search还是可以返回地图但是什么都没有
     
     以上是老板原话。我把你的return注释掉了，但存在问题，你试试搜索b，下面不会出来place数据，点击search，出现的页面，根据该页面修改一下？
    */
    func jumpToPlaces(searchText: String, places: [PlacePin]) {
        PLACE_ENABLE = false
        /*
        placesFromSearch = places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
        removePlaceUserPins({
            self.placeClusterManager.addAnnotations(self.placesFromSearch, withCompletionHandler: {
                if searchText == "fromEXP" {
                    self.visibleClusterPins = self.visiblePlaces(full: true)
                    self.arrExpPlace = places
                    self.clctViewMap.reloadData()
                    self.highlightPlace(0)
                }
                if let first = places.first {
                    self.goTo(annotation: nil, place: first)
                }
            })
            self.zoomToFitAllAnnotations(annotations: self.placesFromSearch)
        }, nil)
        */
        updateUI(searchText: searchText)
        
        btnTapToShowResultTbl.isHidden = places.count <= 1
        if let _ = places.first {
            swipingState = .multipleSearch
            tblPlaceResult.places = tblPlaceResult.updatePlacesArray(places: places)
            tblPlaceResult.loading(current: places[0])
            placesFromSearch = tblPlaceResult.places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
            removePlaceUserPins({
                self.placeClusterManager.addAnnotations(self.placesFromSearch, withCompletionHandler: {
                    if let first = places.first {
                        self.goTo(annotation: nil, place: first, animated: true)
                    }
                })
                self.zoomToFitAllAnnotations(annotations: self.placesFromSearch)
            }, nil)
            placeClusterManager.maxZoomLevelForClustering = 0
        } else {
            swipingState = .map
            tblPlaceResult.hide(animated: false)
            placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
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
        } else if mapMode == .pinDetail || modePinDetail == .on {
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
