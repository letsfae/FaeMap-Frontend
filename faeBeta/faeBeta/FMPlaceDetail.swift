//
//  FMPlaceDetail.swift
//  faeBeta
//
//  Created by Yue Shen on 7/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import CCHMapClusterController

extension FaeMapViewController: PlaceViewDelegate {
    
    func loadPlaceDetail() {
        view.addSubview(placeResultBar)
        placeResultBar.delegate = self
    }
    
    func goToNext(annotation: CCHMapClusterAnnotation?) {
        guard let anno = annotation else { return }
        deselectAllAnnotations()
        boolPreventUserPinOpen = true
        faeMapView.selectAnnotation(anno, animated: false)
        boolPreventUserPinOpen = false
    }
    
    func goToPrev(annotation: CCHMapClusterAnnotation?) {
        guard let anno = annotation else { return }
        deselectAllAnnotations()
        boolPreventUserPinOpen = true
        faeMapView.selectAnnotation(anno, animated: false)
        boolPreventUserPinOpen = false
    }
    
    func animateTo(annotation: CCHMapClusterAnnotation?) {
        guard let anno = annotation else { return }
        deselectAllAnnotations()
        faeMapView.selectAnnotation(anno, animated: false)
    }
}
