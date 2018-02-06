//
//  FMPlacePinsCtrl.swift
//  faeBeta
//
//  Created by Yue on 3/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
//import CCHMapClusterController

extension FaeMapViewController: PlacePinAnnotationDelegate, AddPinToCollectionDelegate, AfterAddedToListDelegate, PlaceDetailDelegate {
    
    // PlaceDetailDelegate
    func getRouteToPin(mode: CollectionTableMode, placeInfo: PlacePin?) {
        placePinAction(action: .route(placeInfo: placeInfo), mode: mode)
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
        switch uiviewSavedList.tableMode {
        case .location:
            if uiviewSavedList.arrListSavedThisPin.count <= 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_loc"), object: nil)
            } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_loc"), object: nil)
            }
            break
        case .place:
            if uiviewSavedList.arrListSavedThisPin.count <= 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_place"), object: nil)
            } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_place"), object: nil)
            }
            break
        }
    }
    
    // AfterAddedToListDelegate
    func seeList() {
        // TODO VICKY
        uiviewAfterAdded.hide()
        if let pin = selectedLocation {
            locationPinClusterManager.removeAnnotations([pin], withCompletionHandler: {
                self.deselectAllLocations()
            })
        }
        let vcList = CollectionsListDetailViewController()
        vcList.enterMode = uiviewSavedList.tableMode
        vcList.colId = uiviewAfterAdded.selectedCollection.collection_id
//        vcList.colInfo = uiviewAfterAdded.selectedCollection
//        vcList.arrColDetails = uiviewAfterAdded.selectedCollection
        vcList.featureDelegate = self
        navigationController?.pushViewController(vcList, animated: true)
    }
    
    func loadPlaceListView() {
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
    
    func routingPlace(_ placeInfo: PlacePin) {
        let pin = FaePinAnnotation(type: "place", cluster: placeClusterManager, data: placeInfo)
        pin.animatable = false
        tempFaePins.append(pin)
        HIDE_AVATARS = true
        PLACE_ENABLE = false
        // remove place pins but don't delete them
        placeClusterManager.removeAnnotations(faePlacePins, withCompletionHandler: {
            self.locationPinClusterManager.addAnnotations([pin], withCompletionHandler: nil)
            self.routeCalculator(destination: pin.coordinate)
        })
        // stop user pins changing location and popping up
        for user in self.faeUserPins {
            user.isValid = false
        }
        // remove user pins but don't delete them
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
        startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
        if let placeInfo = selectedPlace?.pinInfo as? PlacePin {
            uiviewChooseLocs.updateDestination(name: placeInfo.name)
            destinationAddr = RouteAddress(name: placeInfo.name, coordinate: placeInfo.coordinate)
        }
    }
    
    func routingLocation() {
        guard let pin = self.selectedLocation else { return }
        uiviewLocationBar.hide()
        locAnnoView?.hideButtons()
        locAnnoView?.optionsToNormal()
        HIDE_AVATARS = true
        PLACE_ENABLE = false
        // remove place pins but don't delete them
        placeClusterManager.removeAnnotations(faePlacePins, withCompletionHandler: nil)
        placeClusterManager.removeAnnotations(placesFromSearch, withCompletionHandler: {
            self.tempFaePins.removeAll()
            self.tempFaePins.append(pin)
            self.locationPinClusterManager.addAnnotations(self.tempFaePins, withCompletionHandler: nil)
            self.routeCalculator(destination: pin.coordinate)
        })
        // stop user pins changing location and popping up
        for user in self.faeUserPins {
            user.isValid = false
        }
        // remove user pins but don't delete them
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
        startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
    }
    
    // PlacePinAnnotationDelegate
    func placePinAction(action: PlacePinAction, mode: CollectionTableMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.hide()
        switch action {
        case .detail:
            if modeLocCreating == .on {
                guard let anView = locAnnoView else { return }
                anView.optionsToNormal()
                let vcLocDetail = LocDetailViewController()
                vcLocDetail.locationId = anView.locationId
                vcLocDetail.coordinate = selectedLocation?.coordinate
                vcLocDetail.delegate = self
                vcLocDetail.featureDelegate = self
                vcLocDetail.strLocName = uiviewLocationBar.lblName.text ?? "Invalid Name"
                vcLocDetail.strLocAddr = uiviewLocationBar.lblAddr.text ?? "Invalid Address"
                vcLocDetail.boolCreated = true
                navigationController?.pushViewController(vcLocDetail, animated: true)
            } else {
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else {
                    return
                }
                let vcPlaceDetail = PlaceDetailViewController()
                vcPlaceDetail.place = placeData
                vcPlaceDetail.featureDelegate = self
                vcPlaceDetail.delegate = self
                navigationController?.pushViewController(vcPlaceDetail, animated: true)
            }
        case .collect:
            uiviewSavedList.show()
            locAnnoView?.optionsToNormal()
            uiviewSavedList.tableMode = mode
            uiviewSavedList.tblAddCollection.reloadData()
            switch mode {
            case .place:
                guard let placePin = selectedPlace else { return }
                uiviewSavedList.pinToSave = placePin
            case .location:
                guard let locPin = selectedLocation else { return }
                uiviewSavedList.pinToSave = locPin
            }
        case .route(let placeInfo):
            if selectedLocation != nil {
                routingLocation()
            }
            if let place = placeInfo {
                routingPlace(place)
            } else {
                if let place = selectedPlace?.pinInfo as? PlacePin {
                    routingPlace(place)
                }
            }
        case .share:
            if modeLocCreating == .on {
                locAnnoView?.optionsToNormal()
                locAnnoView?.hideButtons()
                let vcShareCollection = NewChatShareController(friendListMode: .location)
                let coordinate = selectedLocation?.coordinate
                AddPinToCollectionView().mapScreenShot(coordinate: coordinate!) { (snapShotImage) in
                    vcShareCollection.locationDetail = "\(coordinate?.latitude ?? 0.0),\(coordinate?.longitude ?? 0.0),\(self.uiviewLocationBar.lblName.text ?? "Invalid Name"),\(self.uiviewLocationBar.lblAddr.text ?? "Invalid Address")"
                    vcShareCollection.locationSnapImage = snapShotImage
                    self.navigationController?.pushViewController(vcShareCollection, animated: true)
                }
            } else {
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else { return }
                selectedPlaceView?.hideButtons()
                let vcSharePlace = NewChatShareController(friendListMode: .place)
                vcSharePlace.placeDetail = placeData
                navigationController?.pushViewController(vcSharePlace, animated: true)
            }
        }
    }

    func viewForPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "place"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.idx = first.class_2_icon_id
        anView.assignImage(first.icon)
        anView.delegate = self
        return anView
    }
    
    func viewForSelectedPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "place_selected"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.icon)
        anView.delegate = self
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        return anView
    }
    
    func visiblePlaces(full: Bool = false) -> [CCHMapClusterAnnotation] {
        var mapRect = faeMapView.visibleMapRect
        if !full {
            mapRect.origin.y += mapRect.size.height * 0.3
            mapRect.size.height = mapRect.size.height * 0.7
        }
        let visibleAnnos = faeMapView.annotations(in: mapRect)
        var places = [CCHMapClusterAnnotation]()
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let place = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
                guard faeMapView.view(for: place) is PlacePinAnnotationView else { continue }
                guard firstAnn.type == "place" else { continue }
                places.append(place)
            } else {
                continue
            }
        }
        return places
    }
    
    func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? PlacePinAnnotationView else { return }
        let idx = firstAnn.class_2_icon_id
        firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
        firstAnn.isSelected = true
        anView.assignImage(firstAnn.icon)
        selectedPlace = firstAnn
        selectedPlaceView = anView
        selectedPlaceView?.superview?.bringSubview(toFront: selectedPlaceView!)
        selectedPlaceView?.zPos = 199
        guard mapMode != .explore else {
            scrollTo(firstAnn.id)
            return
        }
        guard firstAnn.type == "place" else { return }
        guard let placePin = firstAnn.pinInfo as? PlacePin else { return }
        if anView.optionsOpened {
            uiviewSavedList.arrListSavedThisPin.removeAll()
            getPinSavedInfo(id: placePin.id, type: "place") { (ids) in
                let placeData = placePin
                placeData.arrListSavedThisPin = ids
                firstAnn.pinInfo = placeData as AnyObject
                self.uiviewSavedList.arrListSavedThisPin = ids
                anView.boolShowSavedNoti = true
            }
        }
        if modeExplore != .on {
            uiviewPlaceBar.show()
            uiviewPlaceBar.resetSubviews()
            uiviewPlaceBar.tag = 1
        }
        mapView(faeMapView, regionDidChangeAnimated: false)
        if swipingState == .map {
            uiviewPlaceBar.loadingData(current: cluster)
        } else if swipingState == .multipleSearch {
            uiviewPlaceBar.loading(current: placePin)
        }
    }
    
    func getPinSavedInfo(id: Int, type: String, _ completion: @escaping ([Int]) -> Void) {
        FaeMap.shared.getPin(type: type, pinId: String(id)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            guard let is_saved = resultJson["user_pin_operations"]["is_saved"].string else { return }
            guard is_saved != "false" else { return }
            var ids = [Int]()
            for colIdRaw in is_saved.split(separator: ",") {
                let strColId = String(colIdRaw)
                guard let colId = Int(strColId) else { continue }
                ids.append(colId)
            }
            completion(ids)
        }
    }
    
    func updatePlacePins() {
        let coorDistance = cameraDiagonalDistance()
        refreshPlacePins(radius: coorDistance)
    }
    
    fileprivate func refreshPlacePins(radius: Int) {
        
        func getDelay(prevTime: DispatchTime) -> Double {
            let standardInterval: Double = 1
            let nowTime = DispatchTime.now()
            let timeDiff = Double(nowTime.uptimeNanoseconds - prevTime.uptimeNanoseconds)
            var delay: Double = 0
            if timeDiff / Double(NSEC_PER_SEC) < standardInterval {
                delay = standardInterval - timeDiff / Double(NSEC_PER_SEC)
            } else {
                delay = timeDiff / Double(NSEC_PER_SEC) - standardInterval
            }
            return delay
        }
        
        func stopIconSpin(delay: Double) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.btnFilterIcon.stopIconSpin()
            })
        }
        let time_0 = DispatchTime.now()
        guard PLACE_ENABLE else {
            stopIconSpin(delay: getDelay(prevTime: time_0))
            return
        }
        guard boolCanUpdatePlaces else {
            stopIconSpin(delay: getDelay(prevTime: time_0))
            return
        }
        boolCanUpdatePlaces = false
        renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        let getPlaceInfo = FaeMap()
        getPlaceInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getPlaceInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getPlaceInfo.whereKey("radius", value: "500000")
        getPlaceInfo.whereKey("type", value: "place")
        getPlaceInfo.whereKey("max_count", value: "500")
        getPlaceInfo.getMapInformation { (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
                self.boolCanUpdatePlaces = true
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
                self.boolCanUpdatePlaces = true
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
                self.boolCanUpdatePlaces = true
                return
            }
            var placePins = [FaePinAnnotation]()
            var serialQueue = DispatchQueue(label: "appendPlaces")
            if #available(iOS 10.0, *) {
                serialQueue = DispatchQueue(label: "appendPlaces", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: nil)
            } else {
                // Fallback on earlier versions
            }
            serialQueue.async {
                var i = 0
                for placeJson in mapPlaceJsonArray {
                    let placeData = PlacePin(json: placeJson)
                    let place = FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: placeData)
                    if self.setPlacePins.contains(placeJson["place_id"].intValue) {
                    } else {
                        self.setPlacePins.insert(placeJson["place_id"].intValue)
                        placePins.append(place)
                        self.faePlacePins.append(place)
                    }
                    i += 1
                }
                self.boolCanUpdatePlaces = true
                guard placePins.count > 0 else {
                    return
                }
                DispatchQueue.main.async {
                    self.placeClusterManager.addAnnotations(placePins, withCompletionHandler: {
                        
                    })
                }
            }
            stopIconSpin(delay: getDelay(prevTime: time_0))
        }
    }
}
