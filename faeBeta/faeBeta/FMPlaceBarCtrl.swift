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
        view.addSubview(uiviewPlaceBar)
        uiviewPlaceBar.delegate = self
        
        view.addSubview(placeResultTbl)
        
        btnTapToShowResultTbl = UIButton()
        btnTapToShowResultTbl.setImage(#imageLiteral(resourceName: "tapToShowResultTbl"), for: .normal)
        btnTapToShowResultTbl.frame.size = CGSize(width: 58, height: 30)
        btnTapToShowResultTbl.center.x = screenWidth / 2
        btnTapToShowResultTbl.center.y = 181
        view.addSubview(btnTapToShowResultTbl)
        btnTapToShowResultTbl.alpha = 0
        btnTapToShowResultTbl.addTarget(self, action: #selector(self.actionShowResultTbl(_:)), for: .touchUpInside)
    }
    
    // PlaceViewDelegate
    func goTo(annotation: CCHMapClusterAnnotation? = nil, place: PlacePin? = nil) {
        deselectAllAnnotations()
        if let anno = annotation {
            swipingState = .map
            boolPreventUserPinOpen = true
            faeMapView.selectAnnotation(anno, animated: false)
            boolPreventUserPinOpen = false
        }
        if let placePin = place {
            swipingState = .multipleSearch
            var desiredAnno: CCHMapClusterAnnotation!
            for anno in faeMapView.annotations {
                guard let cluster = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { continue }
                guard let placeInfo = firstAnn.pinInfo as? PlacePin else { continue }
                if placeInfo == placePin {
                    desiredAnno = cluster
                    break
                }
            }
            if desiredAnno != nil {
                faeMapView.selectAnnotation(desiredAnno, animated: false)
            }
        }
    }
}
