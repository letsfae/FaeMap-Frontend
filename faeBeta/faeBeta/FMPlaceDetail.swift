//
//  FMPlaceDetail.swift
//  faeBeta
//
//  Created by Yue Shen on 7/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController: PlaceViewDelegate {
    func loadPlaceDetail() {
        view.addSubview(placeResultBar)
        placeResultBar.isHidden = true
        placeResultBar.delegate = self
    }
    
    func goToNext(view: MKAnnotationView?) {
        guard let anView = view else { return }
        tapPlacePin(didSelect: anView)
    }
    
    func goToPrev(view: MKAnnotationView?) {
        guard let anView = view else { return }
        tapPlacePin(didSelect: anView)
    }
    
    func animateTo(view: MKAnnotationView?) {
        guard let anView = view else { return }
        tapPlacePin(didSelect: anView)
    }
}
