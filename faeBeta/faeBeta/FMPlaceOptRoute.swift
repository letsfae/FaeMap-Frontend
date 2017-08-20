//
//  FMPlaceOptRoute.swift
//  faeBeta
//
//  Created by Yue Shen on 8/3/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import IVBezierPathRenderer

extension FaeMapViewController: FMRouteCalculateDelegate {
    
    func loadDistanceComponents() {
        imgDistIndicator = FMDistIndicator()
        view.addSubview(imgDistIndicator)
        
        uiviewChooseLocs = FMChooseLocs()
        uiviewChooseLocs.delegate = self
        view.addSubview(uiviewChooseLocs)
    }
    
    func showRouteCalculatorComponents(distance: CLLocationDistance) {
        imgDistIndicator.show()
        imgDistIndicator.updateDistance(distance: distance)
        
        uiviewPlaceBar.hide()
        uiviewChooseLocs.show()
        if let placeInfo = selectedAnn?.pinInfo as? PlacePin {
            uiviewChooseLocs.updateDestination(name: placeInfo.name)
        }
        
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
    
    func routeCalculator(destination: CLLocationCoordinate2D) {
        
        removeAllRoutes()
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: LocManager.shared.curtLoc.coordinate, addressDictionary: nil))
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
            self.faeMapView.addOverlays(self.mkOverLay, level: MKOverlayLevel.aboveRoads)
            totalDistance /= 1000
            totalDistance *= 0.621371
            self.showRouteCalculatorComponents(distance: totalDistance)
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
