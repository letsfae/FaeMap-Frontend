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

extension FaeMapViewController: PlacePinAnnotationDelegate, AddPlacetoCollectionDelegate {
    
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
    
    func loadPlaceListView() {
        uiviewCollectedList = AddPlaceToCollectionView()
        uiviewCollectedList.delegate = self
        view.addSubview(uiviewCollectedList)
        
        uiviewAfterAdded = AfterAddedToListView()
        view.addSubview(uiviewAfterAdded)
        
        uiviewCollectedList.uiviewAfterAdded = uiviewAfterAdded
    }
    
    // PlacePinAnnotationDelegate
    func placePinAction(action: PlacePinAction) {
        switch action {
        case .detail:
            guard let ann = selectedPlace else { return }
            guard let placePin = ann.pinInfo as? PlacePin else { return }
            let vcPlaceDetail = PlaceDetailViewController()
            vcPlaceDetail.place = placePin
            navigationController?.pushViewController(vcPlaceDetail, animated: true)
            break
        case .collect:
            uiviewCollectedList.show()
            guard let ann = selectedPlace else { return }
            guard let placePin = ann.pinInfo as? PlacePin else { return }
            let pinId = placePin.id
            let collectPlace = FaePinAction()
            collectPlace.saveThisPin("place", pinID: "\(pinId)", completion: { (status, message) in
                guard status / 100 == 2 || status == 400 else { return }
                self.selectedPlaceView?.showCollectedNoti()
            })
            break
        case .route:
            guard let placeData = selectedPlace?.pinInfo as? PlacePin else { return }
            let pin = FaePinAnnotation(type: "place", cluster: placeClusterManager, data: placeData)
            pin.animatable = false
            tempFaePins.append(pin)
            HIDE_AVATARS = true
            PLACE_ENABLE = false
            placeClusterManager.removeAnnotations(faePlacePins, withCompletionHandler: {
                self.placeClusterManager.addAnnotations([pin], withCompletionHandler: nil)
                self.routeCalculator(destination: pin.coordinate)
            })
            for user in self.faeUserPins {
                user.isValid = false
            }
            userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
            startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
            if let placeInfo = selectedPlace?.pinInfo as? PlacePin {
                uiviewChooseLocs.updateDestination(name: placeInfo.name)
                destinationAddr = RouteAddress(name: placeInfo.name, coordinate: placeInfo.coordinate)
            }
            break
        case .share:
            guard let ann = selectedPlace else { return }
            guard let placePin = ann.pinInfo as? PlacePin else { return }
            let vcSharePlace = NewChatShareController(chatOrShare: "share")
            vcSharePlace.placeDetail = placePin
            navigationController?.pushViewController(vcSharePlace, animated: true)
            break
        }
    }

    func viewForPlace(annotation: MKAnnotation, first: FaePinAnnotation, animated: Bool = true) -> MKAnnotationView {
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
        if animated {
            if first.animatable {
                let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    anView.imgIcon.frame = CGRect(x: 28, y: 56, width: 0, height: 0)
                    UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
                        anView.alpha = 1
                    }, completion: nil)
                }
            } else {
                anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
                anView.alpha = 1
            }
        } else {
            anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
            anView.alpha = 1
        }
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
//            anView.layer.zPosition = 2
            anView.imgIcon.layer.zPosition = 2
            let idx = firstAnn.class_2_icon_id
            firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
            anView.assignImage(firstAnn.icon)
            if firstSelectPlace { self.selectedPlace = firstAnn }
            if let slcAnno = selectedPlace {
                faeMapView.removeAnnotation(slcAnno)
                placeClusterManager.addAnnotations([slcAnno], withCompletionHandler: {
                    self.selectedPlace = firstAnn
                    firstAnn.selected = true
                    self.faeMapView.addAnnotation(firstAnn)
                })
            }
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
    
    fileprivate func refreshPlacePins(radius: Int, all: Bool = true) {
        
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
        getPlaceInfo.whereKey("max_count", value: "200")
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
