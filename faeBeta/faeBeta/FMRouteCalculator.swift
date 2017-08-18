//
//  FMRouteCalculator.swift
//  faeBeta
//
//  Created by Yue Shen on 8/3/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import IVBezierPathRenderer

extension FaeMapViewController {
    
    func loadDistanceComponents() {
        imgDistIndicator = FMDistIndicator()
        imgDistIndicator.faeMapCtrler = self
        view.addSubview(imgDistIndicator)
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
                self.faeMapView.add(route.polyline)
                totalDistance += route.distance
            }
            totalDistance /= 1000
            totalDistance *= 0.621371
            self.imgDistIndicator.updateDistance(distance: totalDistance)
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
