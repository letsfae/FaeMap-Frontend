//
//  FMLocationPin.swift
//  faeBeta
//
//  Created by Yue Shen on 9/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    
    func loadLocationView() {
        uiviewLocationBar = LocationView()
        view.addSubview(uiviewLocationBar)
        uiviewLocationBar.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLocInfoBarTap))
        uiviewLocationBar.addGestureRecognizer(tapGesture)
        
        loadActivityIndicator()
    }
    
    func handleLocInfoBarTap() {
        if createLocation == .create {
            locAnnoView?.hideButtons()
            let vcLocDetail = LocDetailViewController()
            vcLocDetail.coordinate = selectedLocation?.coordinate
            vcLocDetail.delegate = self
            vcLocDetail.strLocName = uiviewLocationBar.lblName.text ?? "Invalid Name"
            vcLocDetail.strLocAddr = uiviewLocationBar.lblAddr.text ?? "Invalid Address"
            navigationController?.pushViewController(vcLocDetail, animated: true)
        }
    }
    
    func viewForLocation(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "location"
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
        anView.optionsReady = true
        return anView
    }
    
    func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.center = CGPoint(x: screenWidth / 2, y: 110)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        view.addSubview(activityIndicator)
    }
    
    func createLocationPin(point: CGPoint) {
        createLocation = .create
        let coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        let cllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if selectedLocation != nil {
            locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: nil)
//            faeMapView.removeAnnotation(locationPin!)
            selectedLocation = nil
        }
        uiviewPlaceBar.hide()
        locAnnoView?.hideButtons()
        locAnnoView?.optionsReady = false
        locAnnoView?.optionsOpened = false
        locAnnoView?.optionsOpeing = false
        deselectAllAnnotations()
        selectedLocation = FaePinAnnotation(type: "location", data: coordinate as AnyObject)
        locationPinClusterManager.addAnnotations([selectedLocation!], withCompletionHandler: nil)
//        faeMapView.addAnnotation(locationPin!)
        uiviewLocationBar.show()
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        General.shared.getAddress(location: cllocation, original: true) { (original) in
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
                self.destinationAddr = RouteAddress(name: address_1, coordinate: coordinate)
            }
        }
    }
}
