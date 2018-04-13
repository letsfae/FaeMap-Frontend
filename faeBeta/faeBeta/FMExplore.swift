//
//  FMExplore.swift
//  faeBeta
//
//  Created by Yue Shen on 11/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController: ExploreDelegate {
    
    // MARK: - ExploreDelegate
    
    func jumpToExpPlacesCollection(places: [PlacePin], category: String) {
        guard places.count > 0 else { return }
        PLACE_ENABLE = false
        pinsFromSearch = places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
        removePlaceUserPins({
            self.placeClusterManager.addAnnotations(self.pinsFromSearch, withCompletionHandler: {
                self.visibleClusterPins = self.visiblePlaces(full: true)
                self.arrExpPlace = places
                self.clctViewMap.reloadData()
                self.highlightPlace(0)
            })
            self.zoomToFitAllAnnotations(annotations: self.pinsFromSearch)
        }, nil)
        modeExplore = .on
        setTitle(type: category)
        
        btnBackToExp.removeTarget(nil, action: nil, for: .touchUpInside)
        btnBackToExp.addTarget(self, action: #selector(actionBackToExplore), for: .touchUpInside)
        
    }
    
    @objc func actionBackToExplore() {
        mapMode = .normal
        modeExplore = .off
        PLACE_ENABLE = true
        faeMapView.blockTap = false
        placeClusterManager.removeAnnotations(pinsFromSearch, withCompletionHandler: {
            self.reAddPlacePins()
        })
        reAddUserPins()
        navigationController?.setViewControllers(arrCtrlers, animated: false)
    }
    
}
