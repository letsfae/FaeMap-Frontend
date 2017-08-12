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
        
        view.addSubview(placeResultTbl)
        
        btnTapToShowResultTbl = UIButton()
        btnTapToShowResultTbl.setImage(#imageLiteral(resourceName: "tapToShowResultTbl"), for: .normal)
        btnTapToShowResultTbl.frame.size = CGSize(width: 58, height: 30)
        btnTapToShowResultTbl.center.x = screenWidth / 2
        btnTapToShowResultTbl.center.y = 181
        view.addSubview(btnTapToShowResultTbl)
        btnTapToShowResultTbl.alpha = 0
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
