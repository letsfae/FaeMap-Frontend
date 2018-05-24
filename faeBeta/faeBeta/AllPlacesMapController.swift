//
//  AllPlacesMapController.swift
//  faeBeta
//
//  Created by Yue Shen on 5/17/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class AllPlacesMapController: BasicMapController {
    
    var strTitle = ""
    var arrPlaces = [PlacePin]()
    private var placeAnnos = [FaePinAnnotation]()
    private var uiviewPinActionDisplay: FMPinActionDisplay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTopBar()
        loadAnnotations(places: arrPlaces)
        setTitle(title: strTitle)
        faeMapView.singleTap.isEnabled = true
        faeMapView.doubleTap.isEnabled = true
        faeMapView.longPress.isEnabled = true
        faeMapView.mapDelegate = self
        btnZoom.isHidden = false
        btnLocat.isHidden = false
    }
    
    override func loadTopBar() {
        super.loadTopBar()
        lblTopBarCenter = FaeLabel(.zero, .center, .medium, 18, ._898989())
        uiviewTopBar.addSubview(lblTopBarCenter)
        uiviewTopBar.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblTopBarCenter)
        uiviewTopBar.addConstraintsWithFormat("V:|-12.5-[v0(25)]", options: [], views: lblTopBarCenter)
        
        uiviewPinActionDisplay = FMPinActionDisplay()
        uiviewTopBar.addSubview(uiviewPinActionDisplay)
        uiviewTopBar.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewPinActionDisplay)
        uiviewTopBar.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewPinActionDisplay)
    }
    
    override func tapPlacePin(didSelect view: MKAnnotationView) {
        super.tapPlacePin(didSelect: view)
        guard let anView = view as? PlacePinAnnotationView else { return }
        faeMapView.selectedPlaceAnno = anView
    }
    
    private func loadAnnotations(places: [PlacePin]) {
        placeAnnos = places.map { FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: $0) }
        placeClusterManager.addAnnotations(placeAnnos, withCompletionHandler: {
            
        })
        zoomToFitAllAnnotations(annotations: placeAnnos)
    }
    
    // MARK: - 辅助函数
    private func zoomToFitAllAnnotations(annotations: [MKPointAnnotation]) {
        guard let firstAnn = annotations.first else { return }
        let point = MKMapPointForCoordinate(firstAnn.coordinate)
        var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        var edgePadding = UIEdgeInsetsMake(240, 40, 100, 40)
        edgePadding = UIEdgeInsetsMake(120, 40, 300, 40)
        faeMapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
    }
    
    private func setTitle(title: String) {
        let title_1 = title
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        
        lblTopBarCenter.attributedText = title_1_attr
    }
    
    private func deselectAllPlaceAnnos(full: Bool = true) {
        
        uiviewPinActionDisplay.hide()
        
        if let idx = selectedPlace?.class_2_icon_id {
            if full {
                selectedPlace?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
                selectedPlace?.isSelected = false
                guard let img = selectedPlace?.icon else { return }
                selectedPlaceAnno?.assignImage(img)
                selectedPlaceAnno?.hideButtons()
                selectedPlaceAnno?.superview?.sendSubview(toBack: selectedPlaceAnno!)
                selectedPlaceAnno?.zPos = 7
                selectedPlaceAnno?.optionsReady = false
                selectedPlaceAnno?.optionsOpened = false
                selectedPlaceAnno = nil
                selectedPlace = nil
            } else {
                selectedPlaceAnno?.hideButtons()
                selectedPlaceAnno?.optionsOpened = false
            }
        }
    }
}

extension AllPlacesMapController: MapAction {
    
    func changeIconStyle(action: Int, isPlace: Bool) {
        if isPlace {
            guard let anView = selectedPlaceAnno else { return }
            switch action {
            case 1:
                anView.action(anView.btnDetail, animated: true)
            case 2:
                anView.action(anView.btnCollect, animated: true)
            case 3:
                anView.action(anView.btnRoute, animated: true)
            case 4:
                anView.action(anView.btnShare, animated: true)
            default:
                anView.optionsToNormal()
                break
            }
        } else {
            
        }
        if action == 0 {
            uiviewPinActionDisplay.hide()
        } else {
            uiviewPinActionDisplay.changeStyle(action: PlacePinAction(rawValue: action)!, isPlace)
        }
    }
    
    func placePinTap(view: MKAnnotationView) {
        tapPlacePin(didSelect: view)
    }
    
    func deselectAllPlaces(_ full: Bool) {
        deselectAllPlaceAnnos(full: full)
    }
}
