//
//  FMAllPlacesFromBoard.swift
//  faeBeta
//
//  Created by Yue Shen on 11/24/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController: AllPlacesDelegate {
    
    // MARK: - AllPlacesDelegate
    
    func jumpToAllPlaces(places: [PlacePin]) {
        guard places.count > 0 else { return }
        PLACE_ENABLE = false
        placesFromSearch = places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
        removePlaceUserPins({
            self.placeClusterManager.addAnnotations(self.placesFromSearch, withCompletionHandler: {
                self.visibleClusterPins = self.visiblePlaces(full: true)
                self.arrExpPlace = places
                self.clctViewMap.reloadData()
                self.highlightPlace(0)
            })
            self.zoomToFitAllAnnotations(annotations: self.placesFromSearch)
        }, nil)
        modeAllPlaces = .on
        animateMainItems(show: true, animated: false)
        uiviewPlaceBar.places = places
        uiviewPlaceBar.hide(animated: false)
        lblExpContent.text = Key.shared.mapHeadTitle
        
        btnBackToExp.removeTarget(nil, action: nil, for: .touchUpInside)
        btnBackToExp.addTarget(self, action: #selector(actionBackToAllPlaces), for: .touchUpInside)
        
    }
    
    @objc func actionBackToAllPlaces() {
        modeAllPlaces = .off
        PLACE_ENABLE = true
        faeMapView.blockTap = false
        placeClusterManager.removeAnnotations(placesFromSearch, withCompletionHandler: {
            self.reAddPlacePins()
        })
        animateMainItems(show: false, animated: false)
        reAddUserPins()
        navigationController?.setViewControllers(arrCtrlers, animated: false)
    }
    
}

