//
//  AllPlacesMapController.swift
//  faeBeta
//
//  Created by Yue Shen on 5/17/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class AllPlacesMapController: BasicMapController {
    
    public var isFromCollection = false
    public var enterMode = CollectionTableMode.place // or .location
    public var strTitle = ""
    
    // Use ids to load pins
    public var arrIds = [Int]() {
        didSet {
            desiredCount = arrIds.count
        }
    }
    var arrPins = [FaePin]()
    private var annos = [FaePinAnnotation]()
    private var uiviewPinActionDisplay: FMPinActionDisplay!
    
    // Pin Saving Ctrl
    private var uiviewSavedList: AddPinToCollectionView!
    private var uiviewAfterAdded: AfterAddedToListView!
    
    // Location Pin Ctrl
    private var selectedLocation: FaePinAnnotation?
    private var selectedLocAnno: LocPinAnnotationView?
    
    // Loc Pin Info Bar
    private var uiviewLocationBar: FMLocationInfoBar!
    private var destinationAddr: RouteAddress!
    
    // For loading pin by ids
    private var desiredCount = 0
    private var completionCount = 0 {
        didSet {
            guard fullyLoaded else { return }
            guard desiredCount > 0 else { return }
            guard desiredCount == completionCount else { return }
            addAnnotations()
        }
    }
    
    static var isBackToLastPlaceDetailVCEnabled: Bool = true
    
    // Guest Mode
    private var uiviewGuestMode: GuestModeView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTopBar()
        loadInfoBar()
        loadAnnotations()
        loadPlaceListView()
        setTitle(title: strTitle)
        faeMapView.singleTap.isEnabled = true
        faeMapView.doubleTap.isEnabled = true
        faeMapView.longPress.isEnabled = true
        faeMapView.isSingleTapOnLocPinEnabled = true
        faeMapView.mapAction = self
        placeClusterManager.isFullMapRectEnabled = true
        btnZoom.isHidden = true
        btnLocat.isHidden = false
        PIN_INSTANT_SHOWUP = true
    }
    
    // MARK: - UI Setups
    
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
    
    private func loadInfoBar() {
        if enterMode == .place {
            loadPlaceInfoBar()
        } else if enterMode == .location {
            loadLocInfoBar()
        }
    }
    
    override func loadPlaceInfoBar() {
        super.loadPlaceInfoBar()
        uiviewPlaceBar.delegate = self
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(actionPlaceBarTap))
        uiviewPlaceBar.addGestureRecognizer(tapGes)
    }
    
    private func loadLocInfoBar() {
        uiviewLocationBar = FMLocationInfoBar()
        view.addSubview(uiviewLocationBar)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(actionLocBarTap))
        uiviewLocationBar.addGestureRecognizer(tapGes)
    }
    
    // MARK: - Load Annotations
    
    private func loadAnnotations() {
        if isFromCollection {
            loadAnnotations(ids: arrIds, type: enterMode)
        } else {
            loadAnnotations(pins: arrPins)
        }
    }
    
    private func addAnnotations() {
        guard let first = annos.first else { return }
        placeClusterManager.addAnnotations(annos, withCompletionHandler: {
            let annotations = visiblePins(mapView: self.faeMapView, type: FaePinType(rawValue: self.enterMode.rawValue)!, returnAll: true)
            switch self.enterMode {
            case .place:
                self.uiviewPlaceBar.annotations = annotations
            case .location:
                let cllocation = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                self.uiviewLocationBar.updateLocationInfo(location: cllocation, { (address_1, address_2) in
                    
                })
            }
            self.goTo(annotation: annotations.first, place: nil, animated: true)
        })
        zoomToFitAllAnnotations(annotations: annos)
    }
    
    private func loadAnnotations(pins: [FaePin]) {
        annos = pins.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0 as! PlacePin) }
        placeClusterManager.addAnnotations(annos, withCompletionHandler: {
            let placePin = self.arrPins.first as? PlacePin
            self.uiviewPlaceBar.annotations = visiblePins(mapView: self.faeMapView, type: .place, returnAll: true)
            self.goTo(annotation: nil, place: placePin, animated: true)
        })
        zoomToFitAllAnnotations(annotations: annos)
    }
    
    private func loadAnnotations(ids: [Int], type: CollectionTableMode) {
        guard isFromCollection else { return }
        completionCount = 0
        func getPin(id: Int, type: CollectionTableMode) {
            FaeMap.shared.getPin(type: type.rawValue, pinId: String(id)) { [weak self] (status, message) in
                guard let `self` = self else { return }
                guard status / 100 == 2 else { return }
                guard message != nil else { return }
                let resultJson = JSON(message!)
                let pinInfo: FaePin
                switch type {
                case .place:
                    pinInfo = PlacePin(json: resultJson)
                    faePlaceInfoCache.setObject(pinInfo as AnyObject, forKey: id as AnyObject)
                case .location:
                    pinInfo = LocationPin(json: resultJson)
                    faeLocationCache.setObject(pinInfo as AnyObject, forKey: id as AnyObject)
                }
                self.arrPins.append(pinInfo)
                let pin = FaePinAnnotation(type: FaePinType(rawValue: type.rawValue)!, cluster: self.placeClusterManager, data: pinInfo as AnyObject)
                self.annos.append(pin)
                self.completionCount += 1
            }
        }
        // For every id, try to get its info from cache, otherwise from server
        for id in ids {
            switch type {
            case .place:
                guard let pinData = faePlaceInfoCache.object(forKey: id as AnyObject) as? PlacePin else {
                    getPin(id: id, type: type)
                    return
                }
                self.arrPins.append(pinData)
                let pin = FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: pinData as AnyObject)
                self.annos.append(pin)
                self.completionCount += 1
            case .location:
                guard let pinData = faeLocationCache.object(forKey: id as AnyObject) as? LocationPin else {
                    getPin(id: id, type: type)
                    return
                }
                self.arrPins.append(pinData)
                let pin = FaePinAnnotation(type: .location, cluster: self.placeClusterManager, data: pinData as AnyObject)
                self.annos.append(pin)
                self.completionCount += 1
            }
        }
    }
    
    // MARK: - Place Pin Ctrl
    
    override func tapPlacePin(didSelect view: MKAnnotationView) {
        super.tapPlacePin(didSelect: view)
        guard let anView = view as? PlacePinAnnotationView else { return }
        faeMapView.selectedPlaceAnno = anView
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard var firstAnn = cluster.representative as? FaePinAnnotation else { return }
        if let sPlace = selectedPlace {
            if faeBeta.coordinateEqual(cluster.coordinate, sPlace.coordinate) {
                firstAnn = sPlace
            }
        }
        guard firstAnn.type == .place else { return }
        guard let placePin = firstAnn.pinInfo as? PlacePin else { return }
        if anView.optionsOpened {
            uiviewSavedList.arrListSavedThisPin.removeAll()
            FaeMap.shared.getPinSavedInfo(id: placePin.id, type: "place") { [weak self] (ids) in
                let placeData = placePin
                placeData.arrListSavedThisPin = ids
                firstAnn.pinInfo = placeData as AnyObject
                self?.uiviewSavedList.arrListSavedThisPin = ids
                anView.boolShowSavedNoti = ids.count > 0
            }
        }
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
        anView.iconIndex = first.category_icon_id
        anView.assignImage(first.icon)
        if first.isSelected {
            let icon = UIImage(named: "place_map_\(anView.iconIndex)s") ?? #imageLiteral(resourceName: "place_map_48s")
            anView.assignImage(icon)
            anView.optionsReady = true
            anView.optionsOpened = false
            selectedPlaceAnno = anView
            anView.superview?.bringSubview(toFront: anView)
            anView.zPos = 199
        }
        anView.delegate = self
        return anView
    }
    
    private func deselectAllPlaceAnnos(full: Bool = true) {
        
        uiviewPinActionDisplay.hide()
        
        if let idx = selectedPlace?.category_icon_id {
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
    
    // MARK: - Loc Pin Ctrl
    
    private func tapLocationPin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? LocPinAnnotationView else { return }
        anView.assignImage(#imageLiteral(resourceName: "icon_destination"))
        selectedLocation = firstAnn
        selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
        selectedLocAnno = anView
        faeMapView.selectedLocAnno = anView
        selectedLocAnno?.zPos = 299
        guard firstAnn.type == .location else { return }
        guard let locationData = firstAnn.pinInfo as? LocationPin else { return }
        if anView.optionsOpened {
            let pinData = locationData
            if pinData.id == -1 {
                pinData.id = anView.locationId
            }
            uiviewSavedList.arrListSavedThisPin.removeAll()
            FaeMap.shared.getPinSavedInfo(id: pinData.id, type: "location") { [weak self] (ids) in
                pinData.arrListSavedThisPin = ids
                firstAnn.pinInfo = pinData as AnyObject
                self?.uiviewSavedList.arrListSavedThisPin = ids
                anView.boolShowSavedNoti = ids.count > 0
            }
        }
        if !anView.optionsReady {
            let cllocation = CLLocation(latitude: locationData.coordinate.latitude, longitude: locationData.coordinate.longitude)
            uiviewLocationBar.updateLocationInfo(location: cllocation) { [weak self] (address_1, address_2) in
                guard let `self` = self else { return }
                self.selectedLocation?.address_1 = address_1
                self.selectedLocation?.address_2 = address_2
                self.destinationAddr = RouteAddress(name: address_1, coordinate: cllocation.coordinate)
            }
        }
        anView.optionsReady = true
        mapView(faeMapView, regionDidChangeAnimated: false)
    }
    
    override func viewForLocation(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "location"
        var anView: LocPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = LocPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(#imageLiteral(resourceName: "icon_startpoint"))
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        return anView
    }
    
    private func deselectAllLocAnnos() {
        guard enterMode == .location else { return }
        uiviewLocationBar.hide()
        uiviewPinActionDisplay.hide()
        uiviewSavedList.arrListSavedThisPin.removeAll()
        uiviewAfterAdded.reset()
        
        selectedLocation?.icon = #imageLiteral(resourceName: "icon_startpoint")
        selectedLocAnno?.assignImage(#imageLiteral(resourceName: "icon_startpoint"))
        selectedLocAnno?.hideButtons()
        selectedLocAnno?.zPos = 8.0
        selectedLocAnno?.optionsReady = false
        selectedLocAnno?.optionsOpened = false
        selectedLocAnno = nil
        selectedLocation = nil
    }
    
    // MARK: - Map View Ctrl
    
    override func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Key.shared.lastChosenLoc = mapView.centerCoordinate
    }
    
    override func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        super.mapView(mapView, didSelect: view)
        if view is LocPinAnnotationView {
            tapLocationPin(didSelect: view)
        }
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
        let edgePadding = UIEdgeInsetsMake(240, 40, 100, 40)
        faeMapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
    }
    
    private func setTitle(title: String) {
        let title_1 = title
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        
        lblTopBarCenter.attributedText = title_1_attr
    }
    
    // MARK: - Info Bar Tapping
    @objc private func actionPlaceBarTap() {
        placePinAction(action: .detail, mode: .place)
    }
    
    @objc private func actionLocBarTap() {
        
    }
}

// MARK: -

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
                } else {
                    let camera = faeMapView.camera
                    camera.centerCoordinate = placeData.coordinate
                    faeMapView.setCamera(camera, animated: false)
                }
                if desiredAnno != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
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

// MARK: -

extension AllPlacesMapController: PlacePinAnnotationDelegate {
    
    func placePinAction(action: PlacePinAction, mode: CollectionTableMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.hide()
        switch action {
        case .detail:
            if enterMode == .place {
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else {
                    return
                }
                let vcPlaceDetail = PlaceDetailViewController()
                vcPlaceDetail.place = placeData
                navigationController?.pushViewController(vcPlaceDetail, animated: true)
            } else if enterMode == .location {
                
            }
        case .collect:
            guard !Key.shared.is_guest else {
                loadGuestMode()
                uiviewPinActionDisplay.hide()
                return
            }
            uiviewSavedList.show()
            uiviewSavedList.tableMode = mode
            uiviewSavedList.tblAddCollection.reloadData()
            if enterMode == .place {
                guard let placePin = selectedPlace else { return }
                uiviewSavedList.pinToSave = placePin
            } else if enterMode == .location {
                
            }
        case .route:
            if enterMode == .place {
                if let place = selectedPlace?.pinInfo as? PlacePin {
                    routingPlace(place)
                }
            } else if enterMode == .location {
                
            }
        case .share:
            guard !Key.shared.is_guest else {
                loadGuestMode()
                uiviewPinActionDisplay.hide()
                return
            }
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

// MARK: - Pin Saving Ctrl

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

// MARK: - Map View Interactions

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
    
    func locPinTap(view: MKAnnotationView) {
        tapLocationPin(didSelect: view)
    }
    
    func allPlacesDeselect(_ full: Bool) {
        deselectAllPlaceAnnos(full: full)
    }
    
    func allLocationsDeselect() {
        deselectAllLocAnnos()
    }
    
    func singleElsewhereTap() {
        uiviewSavedList.hide()
    }
    
    func singleElsewhereTapExceptInfobar() {
        faeMapView.mapGesture(isOn: true)
        uiviewPlaceBar.hide()
        deselectAllPlaceAnnos(full: true)
        deselectAllLocAnnos()
    }
}

extension AllPlacesMapController {
    
    private func loadGuestMode() {
        uiviewGuestMode = GuestModeView()
        view.addSubview(uiviewGuestMode)
        uiviewGuestMode.show()
        uiviewGuestMode.dismissGuestMode = { [weak self] in
            self?.removeGuestMode()
        }
        uiviewGuestMode.guestLogin = { [weak self] in
            Key.shared.navOpenMode = .welcomeFirst
            let viewCtrlers = [WelcomeViewController(), LogInViewController()]
            self?.navigationController?.setViewControllers(viewCtrlers, animated: true)
        }
        uiviewGuestMode.guestRegister = { [weak self] in
            Key.shared.navOpenMode = .welcomeFirst
            let viewCtrlers = [WelcomeViewController(), RegisterNameViewController()]
            self?.navigationController?.setViewControllers(viewCtrlers, animated: true)
        }
    }
    
    private func removeGuestMode() {
        guard uiviewGuestMode != nil else { return }
        uiviewGuestMode.hide {
            self.uiviewGuestMode.removeFromSuperview()
        }
    }
    
}
