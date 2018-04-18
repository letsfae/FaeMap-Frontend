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
    var activityIndicator: UIActivityIndicatorView!
    var mode = CollectionTableMode.place
    
    // Routes Calculator
    var arrRoutes = [MKOverlay]()
    var tempFaePins = [FaePinAnnotation]()
    var startPointAddr: RouteAddress!
    var destinationAddr: RouteAddress!
    var addressAnnotations = [AddressAnnotation]()
    var routeAddress: RouteAddress!
    var destPlaceInfo: PlacePin!
    var destLocationInfo: LocationPin!
    
    // Top Bar
    var imgAddressIcon: UIImageView!
    var lblSearchContent: UILabel!
    
    // Selecting Mode
    var imgSelectPin: UIImageView!
    var modeSelecting = FaeMode.off {
        didSet {
            guard fullyLoaded else { return }
            if modeSelecting == .on {
                btnDistIndicator.lblDistance.text = "Select"
            } else {
                btnDistIndicator.lblDistance.text = btnDistIndicator.strDistance
            }
            btnDistIndicator.isUserInteractionEnabled = modeSelecting == .on
            imgSelectPin.isHidden = modeSelecting == .off
        }
    }
    
    // Routing GCD Control
    var routingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "routing queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullyLoaded = false
        loadTopBar()
        setupRoutingPart()
        updateRoutingInfo()
        fullyLoaded = true
    }
    
    override func loadTopBar() {
        super.loadTopBar()
        imgAddressIcon = UIImageView()
        imgAddressIcon.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        uiviewTopBar.addSubview(imgAddressIcon)
        uiviewTopBar.addConstraintsWithFormat("H:|-48-[v0(15)]", options: [], views: imgAddressIcon)
        uiviewTopBar.addConstraintsWithFormat("V:|-17-[v0(15)]", options: [], views: imgAddressIcon)
        
        lblSearchContent = UILabel()
        lblSearchContent.text = ""
        lblSearchContent.textAlignment = .left
        lblSearchContent.lineBreakMode = .byTruncatingTail
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = UIColor._898989()
        uiviewTopBar.addSubview(lblSearchContent)
        uiviewTopBar.addConstraintsWithFormat("H:|-72-[v0]-15-|", options: [], views: lblSearchContent)
        uiviewTopBar.addConstraintsWithFormat("V:|-13-[v0(25)]", options: [], views: lblSearchContent)
        
        btnBack.removeTarget(nil, action: nil, for: .allEvents)
        btnBack.addTarget(self, action: #selector(actionCancelSelection), for: .touchUpInside)
    }
    
    // MARK: - Loading Part
    func setupRoutingPart() {
        uiviewChooseLocs = FMChooseLocs()
        uiviewChooseLocs.show(animated: false)
        uiviewChooseLocs.delegate = self
        view.addSubview(uiviewChooseLocs)
        
        let tapGes_0 = UITapGestureRecognizer(target: self, action: #selector(handleStartPointTap(_:)))
        let tapGes_1 = UITapGestureRecognizer(target: self, action: #selector(handleDestinationTap(_:)))
        uiviewChooseLocs.lblStartPoint.addGestureRecognizer(tapGes_0)
        uiviewChooseLocs.lblDestination.addGestureRecognizer(tapGes_1)
        
        btnDistIndicator = FMDistIndicator()
        view.addSubview(btnDistIndicator)
        btnDistIndicator.show(animated: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectLocationTap(_:)))
        btnDistIndicator.addGestureRecognizer(tapGesture)
        activityIndicator = createActivityIndicator(large: true)
        btnDistIndicator.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: btnDistIndicator.frame.width / 2, y: btnDistIndicator.frame.height / 2)
        
        imgSelectPin = UIImageView(frame: CGRect(x: 0, y: 0, w: 48, h: 52))
        imgSelectPin.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 26)
        imgSelectPin.image = #imageLiteral(resourceName: "icon_destination")
        imgSelectPin.contentMode = .scaleAspectFit
        view.addSubview(imgSelectPin)
        imgSelectPin.isHidden = true
    }
    
    func updateRoutingInfo() {
        if mode == .place {
            let pin = FaePinAnnotation(type: "place", cluster: placeClusterManager, data: destPlaceInfo as AnyObject)
            tempFaePins.append(pin)
            PLACE_INSTANT_SHOWUP = true
            placeClusterManager.addAnnotations(tempFaePins, withCompletionHandler: {
                self.PLACE_INSTANT_SHOWUP = false
            })
        } else {
            let end = AddressAnnotation()
            end.isStartPoint = false
            end.coordinate = destinationAddr.coordinate
            addressAnnotations.append(end)
            faeMapView.addAnnotations(addressAnnotations)
        }
        uiviewChooseLocs.updateStartPoint(name: startPointAddr.name)
        uiviewChooseLocs.updateDestination(name: destinationAddr.name)
        routeCalculator(destination: destinationAddr.coordinate)
    }
    
    // MARK: - Actions
    @objc func handleSelectLocationTap(_ tap: UITapGestureRecognizer) {
        guard routeAddress != nil else { return }
        sendLocationBack(address: routeAddress)
        uiviewChooseLocs.show()
        modeSelecting = .off
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
        modeSelecting = .off
        uiviewChooseLocs.show(animated: false)
    }
    
    @objc func actionCancelSelection() {
        routingHandleTap()
        modeSelecting = .off
    }
    
    // MARK: - Routing Tools
    func routeCalculator(startPoint: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate, destination: CLLocationCoordinate2D) {
        
        removeAllRoutes()
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPoint, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        btnDistIndicator.lblDistance.text = ""
        activityIndicator.startAnimating()
        
        routingQueue.cancelAllOperations()
        let routingOp = RoutingOperation()
        routingOp.completionBlock = {
            self.doRouting(routingOp, request)
        }
        routingQueue.addOperation(routingOp)
    }
    
    func doRouting(_ operation: RoutingOperation, _ request: MKDirectionsRequest) {
        let directions = MKDirections(request: request)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            directions.calculate { [unowned self] response, error in
                self.activityIndicator.stopAnimating()
                if operation.isCancelled {
                    return
                }
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
                if operation.isCancelled {
                    self.activityIndicator.stopAnimating()
                    return
                }
                self.showRouteCalculatorComponents(distance: totalDistance)
                // fit all route overlays
                if let first = self.arrRoutes.first {
                    let rect = self.arrRoutes.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
                    self.faeMapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 150, left: 50, bottom: 90, right: 50), animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    if operation.isCancelled {
                        return
                    }
                    self.faeMapView.addOverlays(self.arrRoutes, level: MKOverlayLevel.aboveRoads)
                })
            }
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
    
    // MARK: - Selecting Location
    override func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        super.mapView(mapView, regionDidChangeAnimated: animated)
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = mapView.convert(mapCenter, toCoordinateFrom: nil)
        let location = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
        General.shared.getAddress(location: location) { (address) in
            guard let addr = address as? String else { return }
            DispatchQueue.main.async {
                self.lblSearchContent.text = addr
                self.routeAddress = RouteAddress(name: addr, coordinate: location.coordinate)
            }
        }
    }
    
    // MARK: - FMRouteCalculateDelegate
    func hideRouteCalculatorComponents() {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - BoardsSearchDelegate
    func chooseLocationOnMap() {
        uiviewChooseLocs.hide(animated: false)
        modeSelecting = .on
    }
    
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

class RoutingOperation: Operation {
    
    override func main() {
        if self.isCancelled {
            return
        }
    }
    
}
