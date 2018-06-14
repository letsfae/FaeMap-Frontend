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
    
    private var btnDistIndicator: FMDistIndicator!
    private var uiviewChooseLocs: FMChooseLocs!
    public var mode = CollectionTableMode.place
    
    // Routes Calculator
    private var arrRoutes = [MKOverlay]()
    private var tempFaePins = [FaePinAnnotation]()
    private var addressAnnotations = [AddressAnnotation]()
    private var routeAddress: RouteAddress!
    
    public var startPointAddr: RouteAddress!
    public var destinationAddr: RouteAddress!
    public var destPlaceInfo: PlacePin!
    public var destLocationInfo: LocationPin!
    
    // Top Bar
    private var imgAddressIcon: UIImageView!
    private var lblSearchContent: UILabel!
    
    // Selecting Mode
    private var imgSelectPin: UIImageView!
    private var modeSelecting = FaeMode.off {
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
    private var isRoutingCancelled = false
    
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
    private func setupRoutingPart() {
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
        
        imgSelectPin = UIImageView(frame: CGRect(x: 0, y: 0, w: 48, h: 52))
        imgSelectPin.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 26)
        imgSelectPin.image = #imageLiteral(resourceName: "icon_destination")
        imgSelectPin.contentMode = .scaleAspectFit
        view.addSubview(imgSelectPin)
        imgSelectPin.isHidden = true
    }
    
    private func updateRoutingInfo() {
        if mode == .place {
            let pin = FaePinAnnotation(type: .place, cluster: placeClusterManager, data: destPlaceInfo as AnyObject)
            tempFaePins.append(pin)
            PIN_INSTANT_SHOWUP = true
            placeClusterManager.addAnnotations(tempFaePins, withCompletionHandler: {
                self.PIN_INSTANT_SHOWUP = false
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
    @objc private func handleSelectLocationTap(_ tap: UITapGestureRecognizer) {
        guard routeAddress != nil else { return }
        sendLocationBack(address: routeAddress)
        uiviewChooseLocs.show()
        modeSelecting = .off
    }
    
    @objc private func handleStartPointTap(_ tap: UITapGestureRecognizer) {
        BoardsSearchViewController.boolToDestination = false
        routingHandleTap()
    }
    
    @objc private func handleDestinationTap(_ tap: UITapGestureRecognizer) {
        BoardsSearchViewController.boolToDestination = true
        routingHandleTap()
    }
    
    private func routingHandleTap() {
        let chooseLocsVC = BoardsSearchViewController()
        chooseLocsVC.enterMode = .location
        chooseLocsVC.delegate = self
        chooseLocsVC.boolCurtLocSelected = uiviewChooseLocs.lblStartPoint.text == "Current Location" || uiviewChooseLocs.lblDestination.text == "Current Location"
        chooseLocsVC.boolFromRouting = true
        navigationController?.pushViewController(chooseLocsVC, animated: false)
        modeSelecting = .off
        uiviewChooseLocs.show(animated: false)
    }
    
    @objc private func actionCancelSelection() {
        routingHandleTap()
        modeSelecting = .off
    }
    
    // MARK: - Routing Tools
    private func routeCalculator(startPoint: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate, destination: CLLocationCoordinate2D) {
        
        removeAllRoutes()
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPoint, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        btnDistIndicator.lblDistance.isHidden = true
        btnDistIndicator.activityIndicator.startAnimating()
        
        isRoutingCancelled = false
        doRouting(request)
    }
    
    private func doRouting(_ request: MKDirectionsRequest) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let cancelRouting = self?.isRoutingCancelled else {
                self?.btnDistIndicator.activityIndicator.stopAnimating()
                return
            }
            guard !cancelRouting else {
                self?.btnDistIndicator.activityIndicator.stopAnimating()
                return
            }
            MKDirections(request: request).calculate { [weak self] response, error in
                self?.btnDistIndicator.activityIndicator.stopAnimating()
                guard let cancelRouting = self?.isRoutingCancelled else { return }
                guard !cancelRouting else { return }
                guard let unwrappedResponse = response else {
                    showAlert(title: "Sorry! This route is too long to draw.", message: "please try again", viewCtrler: self)
                    return
                }
                var totalDistance: CLLocationDistance = 0
                for route in unwrappedResponse.routes {
                    self?.arrRoutes.append(route.polyline)
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
                self?.showRouteCalculatorComponents(distance: totalDistance)
                // fit all route overlays
                if let first = self?.arrRoutes.first {
                    guard let rect = self?.arrRoutes.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)}) else { return }
                    self?.faeMapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 150, left: 50, bottom: 90, right: 50), animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
                    guard let cancelRouting = self?.isRoutingCancelled else { return }
                    guard !cancelRouting else { return }
                    guard let routes = self?.arrRoutes else { return }
                    self?.faeMapView.addOverlays(routes, level: MKOverlayLevel.aboveRoads)
                })
            }
        }
    }
    
    private func showRouteCalculatorComponents(distance: CLLocationDistance) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
        btnDistIndicator.updateDistance(distance: distance)
    }
    
    private func removeAllRoutes() {
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

    }
    
}
