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
        imgLocationBar = LocationView()
        view.addSubview(imgLocationBar)
        imgLocationBar.alpha = 0
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
    
    func createLocationPin(point: CGPoint) {
        createLocation = .create
        let coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        let cllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if locationPin != nil {
            faeMapView.removeAnnotation(locationPin!)
            locationPin = nil
        }
        if locAnnoView != nil {
            locAnnoView?.hideButtons()
            locAnnoView?.optionsReady = false
            locAnnoView?.optionsOpened = false
            locAnnoView?.optionsOpeing = false
        }
        locationPin = FaePinAnnotation(type: "location", data: coordinate as AnyObject)
        faeMapView.addAnnotation(locationPin!)
        imgLocationBar.show()
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
                address_2 += p
            }
            if let c = first.country {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += c
            }
            
            self.locationPin?.address_1 = address_1
            self.locationPin?.address_2 = address_2
            DispatchQueue.main.async {
                self.imgLocationBar.updateLocationBar(name: address_1, address: address_2)
                self.lblSearchContent.text = address_1
                self.lblSearchContent.textColor = UIColor._898989()
            }
        }
    }
}
