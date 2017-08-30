//
//  FMPlaceOptRoute.swift
//  faeBeta
//
//  Created by Yue Shen on 8/3/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import IVBezierPathRenderer

struct RouteAddress {
    var name: String
    var coordinate: CLLocationCoordinate2D
}

extension FaeMapViewController: FMRouteCalculateDelegate, BoardsSearchDelegate, SelectLocationDelegate {
    
    func loadDistanceComponents() {
        imgDistIndicator = FMDistIndicator()
        view.addSubview(imgDistIndicator)
        
        uiviewChooseLocs = FMChooseLocs()
        uiviewChooseLocs.delegate = self
        view.addSubview(uiviewChooseLocs)
        
        let tapGes_0 = UITapGestureRecognizer(target: self, action: #selector(handleStartPointTap(_:)))
        let tapGes_1 = UITapGestureRecognizer(target: self, action: #selector(handleDestinationTap(_:)))
        uiviewChooseLocs.lblStartPoint.addGestureRecognizer(tapGes_0)
        uiviewChooseLocs.lblDestination.addGestureRecognizer(tapGes_1)
    }
    
    func handleStartPointTap(_ tap: UITapGestureRecognizer) {
        let chooseLocsVC = BoardsSearchViewController()
        chooseLocsVC.enterMode = .location
        BoardsSearchViewController.boolToDestination = false
        chooseLocsVC.delegate = self
        chooseLocsVC.boolCurtLocSelected = uiviewChooseLocs.lblStartPoint.text == "Current Location" || uiviewChooseLocs.lblDestination.text == "Current Location"
        navigationController?.pushViewController(chooseLocsVC, animated: false)
    }
    
    func handleDestinationTap(_ tap: UITapGestureRecognizer) {
        let chooseLocsVC = BoardsSearchViewController()
        chooseLocsVC.enterMode = .location
        BoardsSearchViewController.boolToDestination = true
        chooseLocsVC.delegate = self
        chooseLocsVC.boolCurtLocSelected = uiviewChooseLocs.lblStartPoint.text == "Current Location" || uiviewChooseLocs.lblDestination.text == "Current Location"
        navigationController?.pushViewController(chooseLocsVC, animated: false)
    }
    
    // SelectLocationDelegate
    func sendAddress(_ address: RouteAddress) {
        if BoardsSearchViewController.boolToDestination {
            destinationAddr = address
            uiviewChooseLocs.lblDestination.text = address.name
        } else {
            startPointAddr = address
            uiviewChooseLocs.lblStartPoint.text = address.name
        }
        if startPointAddr.name == "Current Location" {
            routeCalculator(startPoint: LocManager.shared.curtLoc.coordinate, destination: destinationAddr.coordinate)
        } else if destinationAddr.name == "Current Location" {
            routeCalculator(startPoint: startPointAddr.coordinate, destination: LocManager.shared.curtLoc.coordinate)
        } else {
            routeCalculator(startPoint: startPointAddr.coordinate, destination: destinationAddr.coordinate)
        }
    }
    
    // BoardsSearchDelegate
    func chooseLocationOnMap() {
        let selectLocVC = SelectLocationViewController()
        selectLocVC.delegate = self
        Key.shared.dblAltitude = faeMapView.camera.altitude
        Key.shared.selectedLoc = faeMapView.camera.centerCoordinate
        navigationController?.pushViewController(selectLocVC, animated: false)
    }
    // BoardsSearchDelegate
    func sendLocationBack(destination: Bool, text: String) {
        if destination {
            uiviewChooseLocs.lblDestination.text = text
        } else {
            uiviewChooseLocs.lblStartPoint.text = text
        }
    }
    
    func showRouteCalculatorComponents(distance: CLLocationDistance) {
        imgDistIndicator.show()
        imgDistIndicator.updateDistance(distance: distance)
        
        uiviewPlaceBar.hide()
        uiviewChooseLocs.show()
        
        animateMainItems(show: true)
        deselectAllAnnotations()
    }
    
    // FMRouteCalculateDelegate
    func hideRouteCalculatorComponents() {
        removeAllRoutes()
        imgDistIndicator.hide()
        uiviewChooseLocs.hide()
        animateMainItems(show: false)
        mapClusterManager.removeAnnotations(tempFaePins) {
            for user in self.faeUserPins {
                user.isValid = true
            }
            self.mapClusterManager.addAnnotations(self.faeUserPins, withCompletionHandler: nil)
            self.mapClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: nil)
        }
        HIDE_AVATARS = false
        PLACE_ENABLE = true
    }
    
    func animateMainItems(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.btnCompass.frame.origin.y = 664 * screenHeightFactor
                self.btnLocateSelf.frame.origin.y = 664 * screenHeightFactor
                self.btnOpenChat.frame.origin.y = screenHeight + 10
                self.btnDiscovery.frame.origin.y = screenHeight + 10
                self.btnFilterIcon.frame.origin.y = screenHeight + 10
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.btnCompass.frame.origin.y = 582 * screenHeightFactor
                self.btnLocateSelf.frame.origin.y = 582 * screenHeightFactor
                self.btnOpenChat.frame.origin.y = 646 * screenHeightFactor
                self.btnDiscovery.frame.origin.y = 646 * screenHeightFactor
                self.btnFilterIcon.center.y = screenHeight - 25
            })
        }
    }
    
    func removeAllRoutes() {
        for route in mkOverLay {
            faeMapView.remove(route)
        }
        mkOverLay.removeAll()
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
                self.mkOverLay.append(route.polyline)
                totalDistance += route.distance
            }
            totalDistance /= 1000
            totalDistance *= 0.621371
            self.showRouteCalculatorComponents(distance: totalDistance)
            // fit all route overlays
            if let first = self.mkOverLay.first {
                let rect = self.mkOverLay.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
                self.faeMapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 150, left: 50, bottom: 90, right: 50), animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.faeMapView.addOverlays(self.mkOverLay, level: MKOverlayLevel.aboveRoads)
            })
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = IVBezierPathRenderer(overlay: overlay)
        renderer.strokeColor = UIColor._174224255()
        renderer.lineWidth = 8
        renderer.lineCap = .round
        renderer.lineJoin = .round
        renderer.borderColor = UIColor._137200241()
        renderer.borderMultiplier = 1.5
        return renderer
    }
}
