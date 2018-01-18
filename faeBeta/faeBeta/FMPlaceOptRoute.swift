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
    }
    
    @objc func handleStartPointTap(_ tap: UITapGestureRecognizer) {
        BoardsSearchViewController.boolToDestination = false
        routingHandleTap()
    }
    
    @objc func handleDestinationTap(_ tap: UITapGestureRecognizer) {
        BoardsSearchViewController.boolToDestination = true
        routingHandleTap()
    }
    
    func routingHandleTap() {
        let chooseLocsVC = BoardsSearchViewController()
        chooseLocsVC.enterMode = .location
        chooseLocsVC.delegate = self
        chooseLocsVC.boolCurtLocSelected = uiviewChooseLocs.lblStartPoint.text == "Current Location" || uiviewChooseLocs.lblDestination.text == "Current Location"
        chooseLocsVC.boolFromRouting = true
        navigationController?.pushViewController(chooseLocsVC, animated: false)
    }
    
    @objc func handleSelectLocationTap(_ tap: UITapGestureRecognizer) {
        guard routeAddress != nil else { return }
        sendLocationBack(address: routeAddress)
    }
    
    // BoardsSearchDelegate
    func chooseLocationOnMap() {
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
        
        if routingMode == .fromPinDetail {
            routingMode = .fromMap
            navigationController?.setViewControllers(arrCtrlers, animated: false)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
        
        removeAllRoutes()
        btnDistIndicator.hide()
        uiviewChooseLocs.hide()
        btnZoom.tapToSmallMode()
        animateMainItems(show: false)
        faeMapView.removeAnnotations(addressAnnotations)
        locationPinClusterManager.removeAnnotations(tempFaePins) {
            self.reAddUserPins()
            self.reAddPlacePins()
            self.deselectAllLocations()
        }
        deselectAllAnnotations()
        HIDE_AVATARS = Key.shared.hideAvatars
        PLACE_ENABLE = true
    }
    
    func animateMainItems(show: Bool, animated: Bool = true) {
        if show {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                    self.btnLocateSelf.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                    self.btnOpenChat.frame.origin.y = screenHeight + 10
                    self.btnDiscovery.frame.origin.y = screenHeight + 10
                    self.btnFilterIcon.frame.origin.y = screenHeight + 10
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                self.btnLocateSelf.frame.origin.y = screenHeight - 72 - device_offset_bot_main
                self.btnOpenChat.frame.origin.y = screenHeight + 10
                self.btnDiscovery.frame.origin.y = screenHeight + 10
                self.btnFilterIcon.frame.origin.y = screenHeight + 10
            }
            faeMapView.cgfloatCompassOffset = 134
            faeMapView.layoutSubviews()
        } else {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                    self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                    self.btnFilterIcon.center.y = screenHeight - 25 - device_offset_bot
                }, completion: nil)
            } else {
                self.btnZoom.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnLocateSelf.frame.origin.y = screenHeight - 154 - device_offset_bot_main
                self.btnOpenChat.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnDiscovery.frame.origin.y = screenHeight - 90 - device_offset_bot_main
                self.btnFilterIcon.center.y = screenHeight - 25 - device_offset_bot
            }
            faeMapView.cgfloatCompassOffset = 215
            faeMapView.layoutSubviews()
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
            guard let unwrappedResponse = response else {
                self.showAlert(title: "Sorry! This route is too long to draw.", message: "please try again")
                return
            }
            var totalDistance: CLLocationDistance = 0
            for route in unwrappedResponse.routes {
                self.arrRoutes.append(route.polyline)
                totalDistance += route.distance
            }
            totalDistance /= 1000
            totalDistance *= 0.621371
            if totalDistance > 3000 {
                self.showAlert(title: "Sorry! This route is too long to draw.", message: "please try again")
                return
            }
            self.showRouteCalculatorComponents(distance: totalDistance)
            // fit all route overlays
            if let first = self.arrRoutes.first {
                let rect = self.arrRoutes.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
                self.faeMapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 150, left: 50, bottom: 90, right: 50), animated: true)
            }
            joshprint("route count:", self.arrRoutes.count)
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
