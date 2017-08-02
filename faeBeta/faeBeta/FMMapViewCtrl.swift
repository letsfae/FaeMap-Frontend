
//
//  FMMapViewDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CCHMapClusterController

extension FaeMapViewController: MKMapViewDelegate, CCHMapClusterControllerDelegate {
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willReuse mapClusterAnnotation: CCHMapClusterAnnotation!) {
        let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
        if firstAnn.type == "place" {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? PlacePinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        } else if firstAnn.type == "user" {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? UserPinAnnotationView {
                anView.assignImage(firstAnn.avatar)
            }
        } else {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? SocialPinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard boolCanOpenPin else { return }
        
        if view is PlacePinAnnotationView {
            tapPlacePin(didSelect: view)
        } else if view is SocialPinAnnotationView {
            
        } else if view is UserPinAnnotationView {
            guard preventUserPinOpen == false else { return }
            tapUserPin(didSelect: view)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let identifier = "self"
            var anView: SelfAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SelfAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = SelfAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            //            anView.assignImage(#imageLiteral(resourceName: "miniAvatar_7"))
            return anView
        } else if annotation is CCHMapClusterAnnotation {
            
            let clusterAnn = annotation as! CCHMapClusterAnnotation
            let firstAnn = clusterAnn.annotations.first as! FaePinAnnotation
            if firstAnn.type == "place" {
                let identifier = "place"
                var anView: PlacePinAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
                    dequeuedView.annotation = annotation
                    anView = dequeuedView
                } else {
                    anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
                anView.assignImage(firstAnn.icon)
                let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    anView.imageView.frame = CGRect(x: 30, y: 64, width: 0, height: 0)
                    UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                        anView.imageView.frame = CGRect(x: 6, y: 10, width: 48, height: 54)
                        anView.alpha = 1
                    }, completion: nil)
                }
                return anView
            } else if firstAnn.type == "user" {
                let identifier = "user"
                var anView: UserPinAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? UserPinAnnotationView {
                    dequeuedView.annotation = annotation
                    anView = dequeuedView
                } else {
                    anView = UserPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
                anView.assignImage(firstAnn.avatar)
                return anView
            } else {
                let identifier = "social"
                var anView: SocialPinAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SocialPinAnnotationView {
                    dequeuedView.annotation = annotation
                    anView = dequeuedView
                } else {
                    anView = SocialPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
                anView.assignImage(firstAnn.icon)
                let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    anView.imageView.frame = CGRect(x: 30, y: 61, width: 0, height: 0)
                    UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                        anView.imageView.frame = CGRect(x: 6, y: 10, width: 48, height: 51)
                    }, completion: nil)
                }
                return anView
            }
        } else {
            return nil
        }
    }
    
    func openMapPin(annotation: FaePinAnnotation, mapPin: MapPin, animated: Bool) {
        /*
        PinDetailViewController.selectedMarkerPosition = annotation.coordinate
        PinDetailViewController.pinAnnotation = annotation
        PinDetailViewController.pinTypeEnum = PinDetailViewController.PinType(rawValue: "\(mapPin.type)")!
        PinDetailViewController.pinStatus = mapPin.status
        PinDetailViewController.pinStateEnum = PinDetailViewController.PinState(rawValue: "\(mapPin.status)")!
        PinDetailViewController.pinUserId = mapPin.userId
         */
    }
    
    func openPlacePin(annotation: FaePinAnnotation, animated: Bool) {
        /*
        guard let placePin = annotation.pinInfo as? PlacePin else { return }
        
        PinDetailViewController.selectedMarkerPosition = annotation.coordinate
        PinDetailViewController.pinAnnotation = annotation
        PinDetailViewController.pinTypeEnum = .place
        PinDetailViewController.placeType = placePin.classTwo
        PinDetailViewController.strPlaceTitle = placePin.name
        PinDetailViewController.strPlaceStreet = placePin.address1
        PinDetailViewController.strPlaceCity = placePin.address2
        PinDetailViewController.strPlaceImageURL = placePin.imageURL
        
        let opPlace = OpenedPlace(title: placePin.name, category: placePin.classTwo,
                                  street: placePin.address1, city: placePin.address2,
                                  imageURL: placePin.imageURL,
                                  position: annotation.coordinate)
        if !OpenedPlaces.openedPlaces.contains(opPlace) {
            OpenedPlaces.openedPlaces.append(opPlace)
        }
         */
    }
    
    func dismissMainBtns() {
        //        if mapFilterArrow != nil {
        //            mapFilterArrow.removeFromSuperview()
        //        }
        //        if filterCircle_1 != nil {
        //            filterCircle_1.removeFromSuperview()
        //        }
        //        if filterCircle_2 != nil {
        //            filterCircle_2.removeFromSuperview()
        //        }
        //        if filterCircle_3 != nil {
        //            filterCircle_3.removeFromSuperview()
        //        }
        //        if filterCircle_4 != nil {
        //            filterCircle_4.removeFromSuperview()
        //        }
        UIView.animate(withDuration: 0.2, animations: {
            if self.FILTER_ENABLE {
                self.btnFilterIcon.frame = CGRect(x: screenWidth / 2, y: screenHeight - 25, width: 0, height: 0)
            }
            self.btnCompass.frame = CGRect(x: 51.5, y: 611.5 * screenWidthFactor, width: 0, height: 0)
            self.btnLocateSelf.frame = CGRect(x: 362.5 * screenWidthFactor, y: 611.5 * screenWidthFactor, width: 0, height: 0)
            self.btnOpenChat.frame = CGRect(x: 51.5, y: 685.5 * screenWidthFactor, width: 0, height: 0)
            self.lblUnreadCount.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.btnDiscovery.frame = CGRect(x: 362.5 * screenWidthFactor, y: 685.5 * screenWidthFactor, width: 0, height: 0)
        }, completion: nil)
    }
    
    func animateToCoordinate(type: Int, coordinate: CLLocationCoordinate2D, animated: Bool) {
        
        // Default is for user pin
        var offset = 465 * screenHeightFactor - screenHeight / 2 // 458 500
        
        if type == 0 { // Map pin
            offset = 530 * screenHeightFactor - screenHeight / 2 // 488 530
        } else if type == 2 { // Place pin
            offset = 492 * screenHeightFactor - screenHeight / 2 // offset: 42
        }
        
        var curPoint = faeMapView.convert(coordinate, toPointTo: nil)
        curPoint.y -= offset
        let newCoordinate = faeMapView.convert(curPoint, toCoordinateFrom: nil)
        let point: MKMapPoint = MKMapPointForCoordinate(newCoordinate)
        var rect: MKMapRect = faeMapView.visibleMapRect
        rect.origin.x = point.x - rect.size.width * 0.5
        rect.origin.y = point.y - rect.size.height * 0.5
        
        faeMapView.setVisibleMapRect(rect, animated: animated)
    }
    
    func deselectAllAnnotations() {
        for annotation in faeMapView.selectedAnnotations {
            faeMapView.deselectAnnotation(annotation, animated: false)
        }
        
        boolCanOpenPin = true
        for user in faeUserPins {
            user.isValid = true
        }
        
        if let idx = selectedAnn?.class_two_idx {
            selectedAnn?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
            guard let img = selectedAnn?.icon else { return }
            selectedAnnView?.assignImage(img)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        joshprint("[regionDidChange] altitude = \(faeMapView.camera.altitude)")
        btnCompass.rotateCompass()
        loadCurrentRegionPlacePins()
        guard placeResultBar.tag > 0 else { return }
        placeResultBar.annotations = self.visiblePlaces()
    }
    
    func mapViewTapAt(_ sender: UITapGestureRecognizer) {
        deselectAllAnnotations()
        placeResultBar.fadeOut()
        btnCardClose.sendActions(for: .touchUpInside)
        guard uiviewFilterMenu != nil else { return }
        uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
    }
}
