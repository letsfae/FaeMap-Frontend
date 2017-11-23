//
//  FMLocationPin.swift
//  faeBeta
//
//  Created by Yue Shen on 9/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
//import CCHMapClusterController

extension FaeMapViewController: LocDetailDelegate {
    
    // MARK: - LocDetailDelegate
    func jumpToViewLocation(coordinate: CLLocationCoordinate2D, created: Bool) {
        modeLocation = .on
        if !created {
            createLocationPin(point: CGPoint.zero, position: coordinate)
            modeLocation = .on_create
        } else {
            locAnnoView?.hideButtons()
            selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
            locAnnoView?.assignImage(#imageLiteral(resourceName: "icon_destination"))
        }
        removePlaceUserPins()
        animateMainItems(show: true, animated: boolFromMap)
        btnBackToExp.removeTarget(nil, action: nil, for: .touchUpInside)
        btnBackToExp.addTarget(self, action: #selector(actionBackToLocDetail), for: .touchUpInside)
    }
    
    @objc func actionBackToLocDetail() {
        animateMainItems(show: false, animated: boolFromMap)
        reAddUserPins()
        reAddPlacePins()
        selectedLocation?.icon = #imageLiteral(resourceName: "icon_startpoint")
        locAnnoView?.assignImage(#imageLiteral(resourceName: "icon_startpoint"))
        if modeLocation == .on_create {
            locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: nil)
        }
        modeLocation = .off
        navigationController?.setViewControllers(arrCtrlers, animated: false)
    }
    
    func tapLocationPin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? LocPinAnnotationView else { return }
        anView.assignImage(#imageLiteral(resourceName: "icon_startpoint"))
        selectedLocation = firstAnn
        locAnnoView = anView
        guard firstAnn.type == "location" else { return }
        guard let locationData = firstAnn.pinInfo as? LocationPin else { return }
        uiviewSavedList.arrListSavedThisPin.removeAll()
        getPinSavedInfo(id: locationData.id, type: "location") { (ids) in
            let pinData = locationData
            pinData.arrListSavedThisPin = ids
            firstAnn.pinInfo = pinData as AnyObject
            self.uiviewSavedList.arrListSavedThisPin = ids
            anView.boolShowSavedNoti = true
        }
        let cllocation = CLLocation(latitude: locationData.coordinate.latitude, longitude: locationData.coordinate.longitude)
        updateLocationInfo(location: cllocation)
        mapView(faeMapView, regionDidChangeAnimated: false)
    }
    
    func loadLocationView() {
        uiviewLocationBar = FMLocationInfoBar()
        view.addSubview(uiviewLocationBar)
        uiviewLocationBar.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLocInfoBarTap))
        uiviewLocationBar.addGestureRecognizer(tapGesture)
        
        loadActivityIndicator()
    }
    
    @objc func handleLocInfoBarTap() {
        placePinAction(action: .detail, mode: .location)
    }
    
    func viewForLocation(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "location\(mapMode)"
        var anView: LocPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = LocPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        locAnnoView = anView
        anView.assignImage(first.icon)
        anView.delegate = self
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        if let locationData = first.pinInfo as? LocationPin {
            anView.optionsReady = locationData.optionsReady
        }
        return anView
    }
    
    func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.center = CGPoint(x: screenWidth / 2, y: 110 + device_offset_top)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        activityIndicator.layer.zPosition = 2000
        view.addSubview(activityIndicator)
    }
    
    func createLocationPin(point: CGPoint, position: CLLocationCoordinate2D? = nil) {
        createLocation = .create
        var coordinate: CLLocationCoordinate2D!
        if position == nil {
            coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        } else {
            guard let coor = position else { return }
            coordinate = coor
        }
        let cllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if selectedLocation != nil {
            locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: nil)
            selectedLocation = nil
        }
        uiviewPlaceBar.hide()
        locAnnoView?.hideButtons()
        locAnnoView?.optionsReady = false
        locAnnoView?.optionsOpened = false
        locAnnoView?.optionsOpeing = false
        deselectAllAnnotations()
        let pinData = LocationPin(position: coordinate)
        pinData.optionsReady = true
        selectedLocation = FaePinAnnotation(type: "location", data: pinData as AnyObject)
        selectedLocation?.icon = #imageLiteral(resourceName: "icon_startpoint")
        locationPinClusterManager.addAnnotations([selectedLocation!], withCompletionHandler: nil)
        updateLocationInfo(location: cllocation)
    }
    
    func updateLocationInfo(location: CLLocation) {
        uiviewLocationBar.show()
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        General.shared.getAddress(location: location, original: true) { (original) in
            guard let first = original as? CLPlacemark else { return }
            
            var name = ""
            var subThoroughfare = ""
            var thoroughfare = ""
            
            var address_1 = ""
            var address_2 = ""
            
            if let n = first.name {
                name = n
                address_1 += n
            }
            if let s = first.subThoroughfare {
                subThoroughfare = s
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += s
            }
            if let t = first.thoroughfare {
                thoroughfare = t
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += t
            }
            
            if name == subThoroughfare + " " + thoroughfare {
                address_1 = name
            }
            
            if let l = first.locality {
                address_2 += l
            }
            if let a = first.administrativeArea {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += a
            }
            if let p = first.postalCode {
                address_2 += " " + p
            }
            if let c = first.country {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += c
            }
            
            self.selectedLocation?.address_1 = address_1
            self.selectedLocation?.address_2 = address_2
            DispatchQueue.main.async {
                self.uiviewLocationBar.updateLocationBar(name: address_1, address: address_2)
                self.activityIndicator.stopAnimating()
                self.uiviewChooseLocs.updateDestination(name: address_1)
                self.destinationAddr = RouteAddress(name: address_1, coordinate: location.coordinate)
            }
        }
    }
}
