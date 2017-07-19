
//
//  FMMapViewDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import CCHMapClusterController

extension FaeMapViewController: MKMapViewDelegate, CCHMapClusterControllerDelegate {
    
    func clearMap(type: String, animated: Bool) {
        
    }
    
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
            guard let clusterAnn = view.annotation as? CCHMapClusterAnnotation else { return }
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return }
            dismissMainBtns()
            boolCanOpenPin = false
            openPlacePin(annotation: firstAnn, animated: true)
            animateToCoordinate(type: 2, coordinate: clusterAnn.coordinate, animated: true)
            let vcPinDetail = PinDetailViewController()
            vcPinDetail.modalPresentationStyle = .overCurrentContext
            vcPinDetail.delegate = self
            
            let time: Double = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.present(vcPinDetail, animated: false, completion: {
                    self.boolCanOpenPin = true
                })
            }
        } else if view is SocialPinAnnotationView {
            guard let clusterAnn = view.annotation as? CCHMapClusterAnnotation else { return }
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return }
            
            dismissMainBtns()
            boolCanOpenPin = false
            
            let mapPin = firstAnn.pinInfo as! MapPin
            
            openMapPin(annotation: firstAnn, mapPin: mapPin, animated: true)
            
            let vcPinDetail = PinDetailViewController()
            vcPinDetail.delegate = self
            vcPinDetail.modalPresentationStyle = .overCurrentContext
            vcPinDetail.strPinId = "\(mapPin.pinId)"
            
            let time: Double = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                self.present(vcPinDetail, animated: false, completion: {
                    self.boolCanOpenPin = true
                })
            })
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
            anView.assignImage(#imageLiteral(resourceName: "miniAvatar_7"))
            anView.layer.zPosition = 2
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
        
        PinDetailViewController.selectedMarkerPosition = annotation.coordinate
        PinDetailViewController.pinAnnotation = annotation
        PinDetailViewController.pinTypeEnum = PinDetailViewController.PinType(rawValue: "\(mapPin.type)")!
        PinDetailViewController.pinStatus = mapPin.status
        PinDetailViewController.pinStateEnum = PinDetailViewController.PinState(rawValue: "\(mapPin.status)")!
        PinDetailViewController.pinUserId = mapPin.userId
    }
    
    func openPlacePin(annotation: FaePinAnnotation, animated: Bool) {
        
        guard let placePin = annotation.pinInfo as? PlacePin else { return }
        
        PinDetailViewController.selectedMarkerPosition = annotation.coordinate
        PinDetailViewController.pinAnnotation = annotation
        PinDetailViewController.pinTypeEnum = .place
        PinDetailViewController.placeType = placePin.primaryCate
        PinDetailViewController.strPlaceTitle = placePin.name
        PinDetailViewController.strPlaceStreet = placePin.address1
        PinDetailViewController.strPlaceCity = placePin.address2
        PinDetailViewController.strPlaceImageURL = placePin.imageURL
        
        let opPlace = OpenedPlace(title: placePin.name, category: placePin.primaryCate,
                                  street: placePin.address1, city: placePin.address2,
                                  imageURL: placePin.imageURL,
                                  position: annotation.coordinate)
        if !OpenedPlaces.openedPlaces.contains(opPlace) {
            OpenedPlaces.openedPlaces.append(opPlace)
        }
    }
    
    fileprivate func dismissMainBtns() {
        if mapFilterArrow != nil {
            mapFilterArrow.removeFromSuperview()
        }
        if filterCircle_1 != nil {
            filterCircle_1.removeFromSuperview()
        }
        if filterCircle_2 != nil {
            filterCircle_2.removeFromSuperview()
        }
        if filterCircle_3 != nil {
            filterCircle_3.removeFromSuperview()
        }
        if filterCircle_4 != nil {
            filterCircle_4.removeFromSuperview()
        }
        UIView.animate(withDuration: 0.2, animations: {
            if self.FILTER_ENABLE {
                self.btnMapFilter.frame = CGRect(x: screenWidth/2, y: screenHeight-25, width: 0, height: 0)
            }
            self.btnToNorth.frame = CGRect(x: 51.5, y: 611.5*screenWidthFactor, width: 0, height: 0)
            self.btnSelfLocation.frame = CGRect(x: 362.5*screenWidthFactor, y: 611.5*screenWidthFactor, width: 0, height: 0)
            self.btnChatOnMap.frame = CGRect(x: 51.5, y: 685.5*screenWidthFactor, width: 0, height: 0)
            self.labelUnreadMessages.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.btnPinOnMap.frame = CGRect(x: 362.5*screenWidthFactor, y: 685.5*screenWidthFactor, width: 0, height: 0)
        }, completion: nil)
    }
    
    func animateToCoordinate(type: Int, coordinate: CLLocationCoordinate2D, animated: Bool) {
        
        // Default is for user pin
        var offset = 500*screenHeightFactor - screenHeight/2 // 458
        
        if type == 0 { // Map pin
            offset = 530*screenHeightFactor - screenHeight/2 // 488
        } else if type == 2 { // Place pin
            offset = 492*screenHeightFactor - screenHeight/2 // offset: 42
        }
        
        var curPoint = faeMapView.convert(coordinate, toPointTo: nil)
        curPoint.y -= offset
        let newCoordinate = faeMapView.convert(curPoint, toCoordinateFrom: nil)
        let point: MKMapPoint = MKMapPointForCoordinate(newCoordinate)
        var rect: MKMapRect = faeMapView.visibleMapRect
        rect.origin.x = point.x - rect.size.width * 0.5
        rect.origin.y = point.y - rect.size.height * 0.5
        
        faeMapView.setVisibleMapRect(rect, animated: false)
        
    }
    /*
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if marker.userData == nil {
            return false
        }
        guard let userData = marker.userData as? [Int: AnyObject] else {
            return false
        }
        guard let type = userData.keys.first else {
            return false
        }

        if type == 0 { // fae social pin
     
        } else if type == 1 { // user pin
            guard let userPin = userData.values.first as? FaeUserPin else {
                return false
            }
            pauseAllUserPinTimers()
            boolCanUpdateUserPin = false
            animateToCoordinate(type: type, marker: marker, animated: true)
            updateNameCard(withUserId: userPin.userId)
            animateNameCard()
            invalidateAllTimer()
            UIView.animate(withDuration: 0.25, delay: 0.3, animations: {
                self.btnCardClose.alpha = 1
            })
            return true
        } else if type == 2 { // place pin
     
            return true
        }
        return true
    }
    */
}
