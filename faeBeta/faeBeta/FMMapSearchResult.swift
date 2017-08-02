//
//  FMMapSearchResult.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-01.
//  Copyright © 2017 fae. All rights reserved.
//

extension FaeMapViewController {
    // MapSearchDelegate
    func jumpToOnePlace(searchText: String, place: PlacePin) {
        updateUI(searchText: searchText)
        let camera = faeMapView.camera
        camera.centerCoordinate = place.coordinate
        faeMapView.setCamera(camera, animated: true)
    }
    
    func jumpToPlaces(searchText: String, places: [PlacePin], selectedLoc: CLLocation) {
        updateUI(searchText: searchText)
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
