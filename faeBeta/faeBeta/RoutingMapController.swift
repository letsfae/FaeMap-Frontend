//
//  RoutingMapController.swift
//  faeBeta
//
//  Created by Yue Shen on 4/16/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import IVBezierPathRenderer

class RoutingMapController: BasicMapController, BoardsSearchDelegate, FMRouteCalculateDelegate {
    
    var btnDistIndicator: FMDistIndicator!
    var uiviewChooseLocs: FMChooseLocs!
    
    // Routes Calculator
    var arrRoutes = [MKOverlay]()
    var tempFaePins = [FaePinAnnotation]()
    var startPointAddr: RouteAddress!
    var destinationAddr: RouteAddress!
    var addressAnnotations = [AddressAnnotation]()
    var routeAddress: RouteAddress!
    var routingMode: RoutingMode = .fromMap
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRoutingPart()
    }
    
    // MARK: - Loading Part
    func setUpRoutingPart() {
        btnDistIndicator = FMDistIndicator()
        view.addSubview(btnDistIndicator)
        btnDistIndicator.show(animated: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectLocationTap(_:)))
        btnDistIndicator.addGestureRecognizer(tapGesture)
        
        uiviewChooseLocs = FMChooseLocs()
        uiviewChooseLocs.show(animated: false)
        uiviewChooseLocs.delegate = self
        view.addSubview(uiviewChooseLocs)
        
        let tapGes_0 = UITapGestureRecognizer(target: self, action: #selector(handleStartPointTap(_:)))
        let tapGes_1 = UITapGestureRecognizer(target: self, action: #selector(handleDestinationTap(_:)))
        uiviewChooseLocs.lblStartPoint.addGestureRecognizer(tapGes_0)
        uiviewChooseLocs.lblDestination.addGestureRecognizer(tapGes_1)
    }
    
    // MARK: - Actions
    @objc func handleSelectLocationTap(_ tap: UITapGestureRecognizer) {
        guard routeAddress != nil else { return }
        sendLocationBack(address: routeAddress)
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
    
    // MARK: - Routing Tools
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
                showAlert(title: "Sorry! This route is too long to draw.", message: "please try again", viewCtrler: self)
                return
            }
            var totalDistance: CLLocationDistance = 0
            for route in unwrappedResponse.routes {
                self.arrRoutes.append(route.polyline)
                totalDistance += route.distance
            }
            totalDistance /= 1000
            if Key.shared.measurementUnits == "imperial" {
                totalDistance *= 0.621371
            }
            if totalDistance > 3000 {
                showAlert(title: "Sorry! This route is too long to draw.", message: "please try again", viewCtrler: self)
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
    
    func showRouteCalculatorComponents(distance: CLLocationDistance) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
        btnDistIndicator.updateDistance(distance: distance)
    }
    
    func removeAllRoutes() {
        for route in arrRoutes {
            faeMapView.remove(route)
        }
        arrRoutes.removeAll()
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
    
    // MARK: - FMRouteCalculateDelegate
    func hideRouteCalculatorComponents() {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - BoardsSearchDelegate
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
}
