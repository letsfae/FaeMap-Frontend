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
        locationPin = FaePinAnnotation(type: "location", data: coordinate as AnyObject)
        faeMapView.addAnnotation(locationPin!)
        imgLocationBar.show()
        General.shared.getAddress(location: cllocation, original: true) { (original) in
            guard let first = original as? CLPlacemark else { return }
            
            var name = ""
            var subThoroughfare = ""
            var thoroughfare = ""
            var locality = ""
            var administrativeArea = ""
            var postalCode = ""
            var country = ""
            
            if let n = first.name {
                name = n
            }
            if let s = first.subThoroughfare {
                subThoroughfare = s
            }
            if let t = first.thoroughfare {
                thoroughfare = t
            }
            if let l = first.locality {
                locality = l
            }
            if let a = first.administrativeArea {
                administrativeArea = a
            }
            if let s = first.postalCode {
                postalCode = s
            }
            if let c = first.country {
                country = c
            }
            
            if name == subThoroughfare + " " + thoroughfare {
                self.locationPin?.address_1 = name
                self.locationPin?.address_2 = locality + ", " + administrativeArea + postalCode + ", " + country
                DispatchQueue.main.async {
                    self.imgLocationBar.updateLocationBar(name: name, address: locality + ", " + administrativeArea + postalCode + ", " + country)
                    self.lblSearchContent.text = name
                }
            } else {
                self.locationPin?.address_1 = name + ", " + subThoroughfare + " " + thoroughfare
                self.locationPin?.address_2 = locality + ", " + administrativeArea + postalCode + ", " + country
                DispatchQueue.main.async {
                    self.imgLocationBar.updateLocationBar(name: name + ", " + subThoroughfare + " " + thoroughfare, address: locality + ", " + administrativeArea + postalCode + ", " + country)
                    self.lblSearchContent.text = name + ", " + subThoroughfare + " " + thoroughfare
                }
            }
        }
    }
}
