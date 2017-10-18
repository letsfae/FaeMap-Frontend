//
//  FMPlacePinsCtrl.swift
//  faeBeta
//
//  Created by Yue on 3/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CCHMapClusterController

extension FaeMapViewController: PlacePinAnnotationDelegate, AddPlacetoCollectionDelegate, AfterAddedToListDelegate {
    
    // AddPlacetoCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .place
        present(vc, animated: true)
    }
    
    // AddPlacetoCollectionDelegate
    func cancelAddPlace() {
        uiviewCollectedList.hide()
    }
    
    // AfterAddedToListDelegate
    func undoCollect() {
        uiviewAfterAdded.hide()
        uiviewCollectedList.show()
    }
    
    // AfterAddedToListDelegate
    func seeList() {
        uiviewAfterAdded.hide()
        handleLocInfoBarTap()
    }
    
    func loadPlaceListView() {
        uiviewCollectedList = AddPlaceToCollectionView()
        uiviewCollectedList.delegate = self
        view.addSubview(uiviewCollectedList)
        
        uiviewAfterAdded = AfterAddedToListView()
        uiviewAfterAdded.delegate = self
        view.addSubview(uiviewAfterAdded)
        
        uiviewCollectedList.uiviewAfterAdded = uiviewAfterAdded
    }
    
    // PlacePinAnnotationDelegate
    func placePinAction(action: PlacePinAction) {
        switch action {
        case .detail:
            if createLocation == .create {
                locAnnoView?.optionsToNormal()
                locAnnoView?.hideButtons()
                let vcLocDetail = LocDetailViewController()
                vcLocDetail.coordinate = locationPin?.coordinate
                vcLocDetail.delegate = self
                vcLocDetail.strLocName = uiviewLocationBar.lblName.text ?? "Invalid Name"
                vcLocDetail.strLocAddr = uiviewLocationBar.lblAddr.text ?? "Invalid Address"
                navigationController?.pushViewController(vcLocDetail, animated: true)
            }
            else {
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else {
                    return
                }
                selectedPlaceView?.hideButtons()
                let vcPlaceDetail = PlaceDetailViewController()
                vcPlaceDetail.place = placeData
                vcPlaceDetail.delegate = self
                navigationController?.pushViewController(vcPlaceDetail, animated: true)
            }
            break
        case .collect:
            uiviewCollectedList.show()
            locAnnoView?.optionsToNormal()
            if createLocation == .create {
                uiviewCollectedList.tableMode = .location
                uiviewCollectedList.loadCollectionData()
                guard let locPin = locationPin else { return }
                uiviewCollectedList.locationPin = locPin
            } else {
                uiviewCollectedList.tableMode = .place
                uiviewCollectedList.loadCollectionData()
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else { return }
                let pinId = placeData.id
                let collectPlace = FaePinAction()
                collectPlace.saveThisPin("place", pinID: "\(pinId)", completion: { (status, message) in
                    guard status / 100 == 2 || status == 400 else { return }
                    self.selectedPlaceView?.showCollectedNoti()
                })
            }
            
            break
        case .route:
            if createLocation == .create {
                guard let coordinate = self.locationPin?.coordinate else {
                    return
                }
                uiviewLocationBar.hide()
                locAnnoView?.hideButtons()
                locAnnoView?.optionsToNormal()
                HIDE_AVATARS = true
                PLACE_ENABLE = false
                // remove place pins but don't delete them
                placeClusterManager.removeAnnotations(faePlacePins, withCompletionHandler: {
                    self.routeCalculator(destination: coordinate)
                })
                // stop user pins changing location and popping up
                for user in self.faeUserPins {
                    user.isValid = false
                }
                // remove user pins but don't delete them
                placeClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
                startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
            }
            if let placeData = selectedPlace?.pinInfo as? PlacePin {
                let pin = FaePinAnnotation(type: "place", cluster: placeClusterManager, data: placeData)
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
                placeClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
                startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
                if let placeInfo = selectedPlace?.pinInfo as? PlacePin {
                    uiviewChooseLocs.updateDestination(name: placeInfo.name)
                    destinationAddr = RouteAddress(name: placeInfo.name, coordinate: placeInfo.coordinate)
                }
            }
            break
        case .share:
            locAnnoView?.optionsToNormal()
            if let placeData = selectedPlace?.pinInfo as? PlacePin {
                let vcSharePlace = NewChatShareController(chatOrShare: "share")
                vcSharePlace.placeDetail = placeData
                navigationController?.pushViewController(vcSharePlace, animated: true)
            }
            break
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
        anView.layer.zPosition = 7
        return anView
    }
    
    func visiblePlaces() -> [CCHMapClusterAnnotation] {
        var mapRect = faeMapView.visibleMapRect
        mapRect.origin.y += mapRect.size.height * 0.3
        mapRect.size.height = mapRect.size.height * 0.7
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
        if let anView = view as? PlacePinAnnotationView {
            anView.layer.zPosition = 2
            anView.imgIcon.layer.zPosition = 2
            let idx = firstAnn.class_2_icon_id
            firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
            anView.assignImage(firstAnn.icon)
//            if firstSelectPlace { self.selectedPlace = firstAnn }
//            if let slcAnno = selectedPlace {
//                faeMapView.removeAnnotation(slcAnno)
//                placeClusterManager.addAnnotations([slcAnno], withCompletionHandler: {
//                    self.selectedPlace = firstAnn
//                    firstAnn.selected = true
//                    self.faeMapView.addAnnotation(firstAnn)
//                })
//            }
            selectedPlace = firstAnn
            selectedPlaceView = anView
        }
        guard firstAnn.type == "place" else { return }
        guard let placePin = firstAnn.pinInfo as? PlacePin else { return }
        uiviewPlaceBar.show()
        uiviewPlaceBar.resetSubviews()
        uiviewPlaceBar.tag = 1
        mapView(faeMapView, regionDidChangeAnimated: false)
        if swipingState == .map {
            uiviewPlaceBar.loadingData(current: cluster)
        } else if swipingState == .multipleSearch {
            uiviewPlaceBar.loading(current: placePin)
        }
    }
    
    func updateTimerForLoadRegionPlacePin() {
        updatePlacePins()
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
        
        guard PLACE_ENABLE else { return }
        btnFilterIcon.startIconSpin()
        let time_0 = DispatchTime.now()
        renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        let getPlaceInfo = FaeMap()
        getPlaceInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getPlaceInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getPlaceInfo.whereKey("radius", value: "500000")
        getPlaceInfo.whereKey("type", value: "place")
        getPlaceInfo.whereKey("max_count", value: "100")
        getPlaceInfo.getMapInformation { (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                stopIconSpin(delay: getDelay(prevTime: time_0))
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
                for placeJson in mapPlaceJsonArray {
                    let placeData = PlacePin(json: placeJson)
                    if self.arrPlaceData.contains(placeData) {
                        continue
                    } else {
                        // MARK: - Bug Here, negative count and malloc problem
                        let place = FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: placeData)
                        self.arrPlaceData.append(placeData)
                        self.faePlacePins.append(place)
                        placePins.append(place)
                    }
                }
                guard placePins.count > 0 else { return }
                DispatchQueue.main.async {
                    self.placeClusterManager.addAnnotations(placePins, withCompletionHandler: nil)
                }
            }
            stopIconSpin(delay: getDelay(prevTime: time_0))
        }
    }
}
