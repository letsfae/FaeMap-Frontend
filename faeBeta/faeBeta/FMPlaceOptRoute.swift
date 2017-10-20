//
//  FMPlaceOptRoute.swift
//  faeBeta
//
//  Created by Yue Shen on 8/3/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import IVBezierPathRenderer

class RouteAddress: NSObject {
    var name: String
    var coordinate: CLLocationCoordinate2D
    init(name: String, coordinate: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate) {
        self.name = name
        self.coordinate = coordinate
    }
}

extension FaeMapViewController: FMRouteCalculateDelegate, BoardsSearchDelegate {
    
    func loadDistanceComponents() {
        btnDistIndicator = FMDistIndicator()
        view.addSubview(btnDistIndicator)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectLocationTap(_:)))
        btnDistIndicator.addGestureRecognizer(tapGesture)
        
        uiviewChooseLocs = FMChooseLocs()
        uiviewChooseLocs.delegate = self
        view.addSubview(uiviewChooseLocs)
        
        let tapGes_0 = UITapGestureRecognizer(target: self, action: #selector(handleStartPointTap(_:)))
        let tapGes_1 = UITapGestureRecognizer(target: self, action: #selector(handleDestinationTap(_:)))
        uiviewChooseLocs.lblStartPoint.addGestureRecognizer(tapGes_0)
        uiviewChooseLocs.lblDestination.addGestureRecognizer(tapGes_1)
        
        imgPinOnMap = UIImageView(frame: CGRect(x: screenWidth / 2 - 24, y: screenHeight / 2 - 52, width: 48, height: 52))
        view.addSubview(imgPinOnMap)
        imgPinOnMap.isHidden = true
    }
    
    func handleStartPointTap(_ tap: UITapGestureRecognizer) {
        BoardsSearchViewController.boolToDestination = false
        routingHandleTap()
    }
    
    func handleDestinationTap(_ tap: UITapGestureRecognizer) {
        BoardsSearchViewController.boolToDestination = true
        routingHandleTap()
    }
    
    func routingHandleTap() {
        imgPinOnMap.image = BoardsSearchViewController.boolToDestination ? #imageLiteral(resourceName: "icon_destination") : #imageLiteral(resourceName: "icon_startpoint")
        let chooseLocsVC = BoardsSearchViewController()
        chooseLocsVC.enterMode = .location
        chooseLocsVC.delegate = self
        chooseLocsVC.boolCurtLocSelected = uiviewChooseLocs.lblStartPoint.text == "Current Location" || uiviewChooseLocs.lblDestination.text == "Current Location"
        navigationController?.pushViewController(chooseLocsVC, animated: false)
    }
    
    func handleSelectLocationTap(_ tap: UITapGestureRecognizer) {
        guard routeAddress != nil else { return }
        sendLocationBack(address: routeAddress)
    }
    
    // BoardsSearchDelegate
    func chooseLocationOnMap() {
//        let selectLocVC = SelectLocationViewController()
//        selectLocVC.delegate = self
//        Key.shared.dblAltitude = faeMapView.camera.altitude
//        Key.shared.selectedLoc = faeMapView.camera.centerCoordinate
//        navigationController?.pushViewController(selectLocVC, animated: false)
        uiviewChooseLocs.hide(animated: false)
        mapMode = .selecting
        mapView(faeMapView, regionDidChangeAnimated: false)
    }
    
    // BoardsSearchDelegate
    func sendLocationBack(address: RouteAddress) {
        faeMapView.removeAnnotations(addressAnnotations)
        if BoardsSearchViewController.boolToDestination {
            destinationAddr = address
            uiviewChooseLocs.lblDestination.text = address.name
            
            if addressAnnotations.count > 0 {
                var index = 0
                var found = false
                for i in 0..<addressAnnotations.count {
                    if !addressAnnotations[i].isStartPoint {
                        index = i
                        found = true
                        break
                    }
                }
                if found { addressAnnotations.remove(at: index) }
            }
            if address.name != "Current Location" {
                let end = AddressAnnotation()
                end.isStartPoint = false
                end.coordinate = destinationAddr.coordinate
                addressAnnotations.append(end)
            }
        } else {
            startPointAddr = address
            uiviewChooseLocs.lblStartPoint.text = address.name
            
            if addressAnnotations.count > 0 {
                var index = 0
                var found = false
                for i in 0..<addressAnnotations.count {
                    if addressAnnotations[i].isStartPoint {
                        index = i
                        found = true
                        break
                    }
                }
                if found { addressAnnotations.remove(at: index) }
            }
            
            if address.name != "Current Location" {
                let start = AddressAnnotation()
                start.isStartPoint = true
                start.coordinate = startPointAddr.coordinate
                addressAnnotations.append(start)
            }
        }
        if startPointAddr.name == "Current Location" {
            routeCalculator(startPoint: LocManager.shared.curtLoc.coordinate, destination: destinationAddr.coordinate)
        } else if destinationAddr.name == "Current Location" {
            routeCalculator(startPoint: startPointAddr.coordinate, destination: LocManager.shared.curtLoc.coordinate)
        } else {
            routeCalculator(startPoint: startPointAddr.coordinate, destination: destinationAddr.coordinate)
        }
        faeMapView.addAnnotations(addressAnnotations)
    }
    
    func showRouteCalculatorComponents(distance: CLLocationDistance) {
        
        mapMode = .routing
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
        
        btnDistIndicator.show()
        btnDistIndicator.updateDistance(distance: distance)
        
        uiviewPlaceBar.hide()
        uiviewChooseLocs.show()
        
        animateMainItems(show: true)
        deselectAllAnnotations()
    }
    
    // FMRouteCalculateDelegate
    func hideRouteCalculatorComponents() {
        mapMode = .normal
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
        
        removeAllRoutes()
        btnDistIndicator.hide()
        uiviewChooseLocs.hide()
        animateMainItems(show: false)
        faeMapView.removeAnnotations(addressAnnotations)
        locationPinClusterManager.removeAnnotations(tempFaePins) {
            for user in self.faeUserPins {
                user.isValid = true
            }
            self.userClusterManager.addAnnotations(self.faeUserPins, withCompletionHandler: nil)
            self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: nil)
        }
        HIDE_AVATARS = false
        PLACE_ENABLE = true
    }
    
    func animateMainItems(show: Bool, animated: Bool = true) {
        btnCompass.savedTransform = btnCompass.transform
        btnCompass.transform = CGAffineTransform.identity
        if show {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnCompass.frame.origin.y = 664 * screenHeightFactor
                    self.btnLocateSelf.frame.origin.y = 664 * screenHeightFactor
                    self.btnOpenChat.frame.origin.y = screenHeight + 10
                    self.btnDiscovery.frame.origin.y = screenHeight + 10
                    self.btnFilterIcon.frame.origin.y = screenHeight + 10
                }, completion: { _ in
                    self.btnCompass.boolLowPos = true
//                    self.btnCompass.transform = self.btnCompass.savedTransform
                    if self.btnCompass != nil { self.btnCompass.rotateCompass() }
                })
            } else {
                self.btnCompass.frame.origin.y = 664 * screenHeightFactor
//                self.btnCompass.transform = self.btnCompass.savedTransform
                if self.btnCompass != nil { self.btnCompass.rotateCompass() }
                self.btnLocateSelf.frame.origin.y = 664 * screenHeightFactor
                self.btnOpenChat.frame.origin.y = screenHeight + 10
                self.btnDiscovery.frame.origin.y = screenHeight + 10
                self.btnFilterIcon.frame.origin.y = screenHeight + 10
                self.btnCompass.boolLowPos = true
            }
        } else {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnCompass.frame.origin.y = 582 * screenHeightFactor
                    self.btnLocateSelf.frame.origin.y = 582 * screenHeightFactor
                    self.btnOpenChat.frame.origin.y = 646 * screenHeightFactor
                    self.btnDiscovery.frame.origin.y = 646 * screenHeightFactor
                    self.btnFilterIcon.center.y = screenHeight - 25
                }, completion: { _ in
                    self.btnCompass.boolLowPos = false
//                    self.btnCompass.transform = self.btnCompass.savedTransform
//                    self.mapView(self.faeMapView, regionDidChangeAnimated: false)
                    if self.btnCompass != nil { self.btnCompass.rotateCompass() }
                })
            } else {
                self.btnCompass.frame.origin.y = 582 * screenHeightFactor
                self.btnLocateSelf.frame.origin.y = 582 * screenHeightFactor
                self.btnOpenChat.frame.origin.y = 646 * screenHeightFactor
                self.btnDiscovery.frame.origin.y = 646 * screenHeightFactor
                self.btnFilterIcon.center.y = screenHeight - 25
                self.btnCompass.boolLowPos = false
//                self.btnCompass.transform = self.btnCompass.savedTransform
//                self.mapView(self.faeMapView, regionDidChangeAnimated: false)
                if self.btnCompass != nil { self.btnCompass.rotateCompass() }
            }
        }
    }
    
    func removeAllRoutes() {
        for route in arrRoutes {
            faeMapView.remove(route)
        }
        arrRoutes.removeAll()
    }
    
    func routeCalculator(startPoint: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate, destination: CLLocationCoordinate2D) {
        
        removeAllRoutes()
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPoint, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            var totalDistance: CLLocationDistance = 0
            for route in unwrappedResponse.routes {
                self.arrRoutes.append(route.polyline)
                totalDistance += route.distance
            }
            totalDistance /= 1000
            totalDistance *= 0.621371
            self.showRouteCalculatorComponents(distance: totalDistance)
            // fit all route overlays
            if let first = self.arrRoutes.first {
                let rect = self.arrRoutes.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
                self.faeMapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 150, left: 50, bottom: 90, right: 50), animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.faeMapView.addOverlays(self.arrRoutes, level: MKOverlayLevel.aboveRoads)
            })
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = IVBezierPathRenderer(overlay: overlay)
        renderer.strokeColor = UIColor._206184231()
        renderer.lineWidth = 8
        renderer.lineCap = .round
        renderer.lineJoin = .round
        renderer.borderColor = UIColor._182150210()
        renderer.borderMultiplier = 1.5
        return renderer
    }
}
