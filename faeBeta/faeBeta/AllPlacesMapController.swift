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
    
    // Collecting Pin Control
    private var uiviewSavedList: AddPinToCollectionView!
    private var uiviewAfterAdded: AfterAddedToListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTopBar()
        loadPlaceInfoBar()
        loadAnnotations(places: arrPlaces)
        loadPlaceListView()
        setTitle(title: strTitle)
        faeMapView.singleTap.isEnabled = true
        faeMapView.doubleTap.isEnabled = true
        faeMapView.longPress.isEnabled = true
        faeMapView.mapAction = self
        btnZoom.isHidden = true
        btnLocat.isHidden = false
        PLACE_INSTANT_SHOWUP = true
    }
    
    override func loadPlaceInfoBar() {
        super.loadPlaceInfoBar()
        uiviewPlaceBar.delegate = self
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(actionPlaceBarTap))
        uiviewPlaceBar.addGestureRecognizer(tapGes)
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
    
    override func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Key.shared.lastChosenLoc = mapView.centerCoordinate
    }
    
    override func viewForPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "place"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.icon)
        anView.delegate = self
        return anView
    }
    
    private func loadAnnotations(places: [PlacePin]) {
        placeAnnos = places.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0) }
        placeClusterManager.addAnnotations(placeAnnos, withCompletionHandler: {
            self.goTo(annotation: nil, place: self.arrPlaces.first, animated: true)
            self.uiviewPlaceBar.annotations = visiblePlaces(mapView: self.faeMapView, returnAll: true)
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
    
    @objc private func actionPlaceBarTap() {
        placePinAction(action: .detail, mode: .place)
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

extension AllPlacesMapController: PlaceViewDelegate {
    func goTo(annotation: CCHMapClusterAnnotation?, place: PlacePin?, animated: Bool) {
        func findAnnotation() {
            if let placeData = place {
                var desiredAnno: CCHMapClusterAnnotation!
                for anno in faeMapView.annotations {
                    guard let cluster = anno as? CCHMapClusterAnnotation else { continue }
                    guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { continue }
                    guard let placeInfo = firstAnn.pinInfo as? PlacePin else { continue }
                    if placeInfo == placeData {
                        desiredAnno = cluster
                        break
                    }
                }
                if animated {
                    faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: placeData.coordinate)
                }
                if desiredAnno != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.faeMapView.selectAnnotation(desiredAnno, animated: false)
                    }
                }
            }
        }
        
        deselectAllPlaceAnnos()
        if let anno = annotation {
            faeMapView.selectAnnotation(anno, animated: false)
            if animated {
                faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: anno.coordinate)
            }
        }
        
        findAnnotation()
        if let placePin = place { // 必须放在最末尾
            uiviewPlaceBar.loading(current: placePin)
        }
    }
}

extension AllPlacesMapController: PlacePinAnnotationDelegate {
    
    func placePinAction(action: PlacePinAction, mode: CollectionTableMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.hide()
        switch action {
        case .detail:
            guard let placeData = selectedPlace?.pinInfo as? PlacePin else {
                return
            }
            let vcPlaceDetail = PlaceDetailViewController()
            vcPlaceDetail.place = placeData
            navigationController?.pushViewController(vcPlaceDetail, animated: true)
        case .collect:
            uiviewSavedList.show()
            uiviewSavedList.tableMode = mode
            uiviewSavedList.tblAddCollection.reloadData()
            guard let placePin = selectedPlace else { return }
            uiviewSavedList.pinToSave = placePin
        case .route:
            if let place = selectedPlace?.pinInfo as? PlacePin {
                routingPlace(place)
            }
        case .share:
            guard let placeData = selectedPlace?.pinInfo as? PlacePin else { return }
            selectedPlaceAnno?.hideButtons()
            let vcSharePlace = NewChatShareController(friendListMode: .place)
            vcSharePlace.placeDetail = placeData
            navigationController?.pushViewController(vcSharePlace, animated: true)
        }
    }
    
    private func routingPlace(_ place: PlacePin) {
        let vc = RoutingMapController()
        vc.startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
        vc.destinationAddr = RouteAddress(name: place.name, coordinate: place.coordinate)
        vc.destPlaceInfo = place
        vc.mode = .place
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension AllPlacesMapController: AddPinToCollectionDelegate, AfterAddedToListDelegate {
    
    private func loadPlaceListView() {
        uiviewSavedList = AddPinToCollectionView()
        //        uiviewSavedList.loadCollectionData()
        uiviewSavedList.delegate = self
        uiviewSavedList.tableMode = .place
        view.addSubview(uiviewSavedList)
        
        uiviewAfterAdded = AfterAddedToListView()
        uiviewAfterAdded.delegate = self
        view.addSubview(uiviewAfterAdded)
        
        uiviewSavedList.uiviewAfterAdded = uiviewAfterAdded
    }
    
    // AddPlacetoCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = uiviewSavedList.tableMode
        present(vc, animated: true)
    }
    
    // AfterAddedToListDelegate
    func undoCollect(colId: Int, mode: UndoMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.show()
        switch mode {
        case .save:
            uiviewSavedList.arrListSavedThisPin.append(colId)
        case .unsave:
            if uiviewSavedList.arrListSavedThisPin.contains(colId) {
                let arrListIds = uiviewSavedList.arrListSavedThisPin
                uiviewSavedList.arrListSavedThisPin = arrListIds.filter { $0 != colId }
            }
        }
        if uiviewSavedList.arrListSavedThisPin.count <= 0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_place"), object: nil)
        } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_place"), object: nil)
        }
    }
    
    // AfterAddedToListDelegate
    func seeList() {
        // TODO VICKY
        uiviewAfterAdded.hide()
        let vcList = CollectionsListDetailViewController()
        vcList.enterMode = uiviewSavedList.tableMode
        vcList.colId = uiviewAfterAdded.selectedCollection.collection_id
        navigationController?.pushViewController(vcList, animated: true)
    }
}

extension AllPlacesMapController: MapAction {
    
    func iconStyleChange(action: Int, isPlace: Bool) {
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
    
    func allPlacesDeselect(_ full: Bool) {
        deselectAllPlaceAnnos(full: full)
    }
    
    func singleElsewhereTap() {
        uiviewSavedList.hide()
    }
    
    func singleElsewhereTapExceptInfobar() {
        faeMapView.mapGesture(isOn: true)
        uiviewPlaceBar.hide()
        deselectAllPlaceAnnos(full: true)
    }
}
