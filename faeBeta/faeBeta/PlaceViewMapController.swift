//
//  PlaceViewMapController.swift
//  faeBeta
//
//  Created by Yue Shen on 3/6/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class PlaceViewMapController: BasicMapController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        fullyLoaded = false
        loadTopBar()
        loadPlaceInfoBar()
        if let place = self.placePin {
            addPlaceToMap(pin: place)
        }
        faeMapView.singleTap.isEnabled = false
        faeMapView.doubleTap.isEnabled = false
        faeMapView.longPress.isEnabled = false
        fullyLoaded = true
    }
    
    override func loadTopBar() {
        super.loadTopBar()
        lblTopBarCenter = FaeLabel(.zero, .center, .medium, 18, ._898989())
        lblTopBarCenter.text = "Map View"
        uiviewTopBar.addSubview(lblTopBarCenter)
        uiviewTopBar.addConstraintsWithFormat("H:|-50-[v0]-50-|", options: [], views: lblTopBarCenter)
        uiviewTopBar.addConstraintsWithFormat("V:|-13-[v0(25)]", options: [], views: lblTopBarCenter)
    }
    
    func addPlaceToMap(pin: PlacePin) {
        let anno = FaePinAnnotation(type: "place", cluster: placeClusterManager, data: pin as AnyObject)
        placeClusterManager.addAnnotations([anno], withCompletionHandler: nil)
        
        uiviewPlaceBar.places = [pin]
        uiviewPlaceBar.load(for: pin)
        uiviewPlaceBar.isUserInteractionEnabled = false
    }
    
}
