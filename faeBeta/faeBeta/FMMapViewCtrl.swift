
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

extension FaeMapViewController: MKMapViewDelegate, CCHMapClusterControllerDelegate, CCHMapAnimator, CCHMapClusterer {
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, coordinateForAnnotations annotations: Set<AnyHashable>!, in mapRect: MKMapRect) -> CLLocationCoordinate2D {
        guard let firstAnn = annotations.first as? FaePinAnnotation else {
            return CLLocationCoordinate2DMake(0, 0)
        }
        return firstAnn.coordinate
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for annotationView in views {
            guard let anView = annotationView as? PlacePinAnnotationView else { continue }
            guard let annotation = anView.annotation as? FaePinAnnotation else { continue }
            guard annotation.selected else { continue }
            selectedPlaceView = anView
            anView.optionsReady = true
            anView.layer.zPosition = 500
        }
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, didAddAnnotationViews annotationViews: [Any]!) {
        for annotationView in annotationViews {
            if let anView = annotationView as? PlacePinAnnotationView {
                anView.alpha = 0
                anView.imgIcon.frame = CGRect(x: 28, y: 56, width: 0, height: 0)
                let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
                        anView.alpha = 1
                    }, completion: nil)
                }
            } else if let anView = annotationView as? UserPinAnnotationView {
                anView.alpha = 0
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, animations: {
                        anView.alpha = 1
                    })
                }
            } else if let anView = annotationView as? LocPinAnnotationView {
                anView.alpha = 0
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        anView.alpha = 1
                    })
                }
            } else if let anView = annotationView as? MKAnnotationView {
                anView.alpha = 0
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, animations: {
                        anView.alpha = 1
                    })
                }
            }
        }
    }

    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willRemoveAnnotations annotations: [Any]!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        UIView.animate(withDuration: 0.4, animations: {
            for annotation in annotations {
                if let anno = annotation as? MKAnnotation {
                    if let anView = self.faeMapView.view(for: anno) {
                        anView.alpha = 0
                    }
                }
            }
        }) { _ in
            if completionHandler != nil { completionHandler() }
        }
        
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
        } else if firstAnn.type == "location" {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? LocPinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        }
        else {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? SocialPinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard boolCanOpenPin else { return }
        
        if view is PlacePinAnnotationView {
            tapPlacePin(didSelect: view)
        } else if view is UserPinAnnotationView {
            guard boolPreventUserPinOpen == false else { return }
            tapUserPin(didSelect: view)
        } else if view is SelfAnnotationView {
            boolCanOpenPin = false
            mapGesture(isOn: false)
            uiviewNameCard.userId = Key.shared.user_id
            uiviewNameCard.show(avatar: UIImage(named: "miniAvatar_\(userMiniAvatar)") ?? UIImage())  {
                self.boolCanOpenPin = true
            }
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
            if userStatus == 5 {
                anView.invisibleOn()
            }
            return anView
        } else if annotation is CCHMapClusterAnnotation {
            guard let clusterAnn = annotation as? CCHMapClusterAnnotation else { return nil }
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == "place" {
                return viewForPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == "user" {
                return viewForUser(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == "location" {
                return viewForLocation(annotation: annotation, first: firstAnn)
            } else {
                return viewForSocial(annotation: annotation, first: firstAnn)
            }
        } else if annotation is AddressAnnotation {
            guard let addressAnno = annotation as? AddressAnnotation else { return nil }
            let identifier = addressAnno.isStartPoint ? "start_point" : "destination"
            var anView: AddressAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? AddressAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = AddressAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            anView.icon.image = addressAnno.isStartPoint ? #imageLiteral(resourceName: "icon_startpoint") : #imageLiteral(resourceName: "icon_destination")
            return anView
        } else if annotation is FaePinAnnotation {
            guard let firstAnn = annotation as? FaePinAnnotation else { return nil }
            if firstAnn.type == "place" {
                return viewForSelectedPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == "location" {
                return viewForLocation(annotation: annotation, first: firstAnn)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func animateToCoordinate(type: Int, coordinate: CLLocationCoordinate2D, animated: Bool) {
        var offset: CGFloat = 0
        if type == 0 { // Map pin
            offset = 530 * screenHeightFactor - screenHeight / 2 // 488 530
        } else if type == 1 { // Map pin
            offset = 465 * screenHeightFactor - screenHeight / 2 // 458 500
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
        
        uiviewPinActionDisplay.hide()
        boolCanOpenPin = true
        
        if let idx = selectedPlace?.class_2_icon_id {
            selectedPlace?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
            guard let img = selectedPlace?.icon else { return }
            selectedPlaceView?.layer.zPosition = CGFloat(selectedPlaceView?.tag ?? 2)
            selectedPlaceView?.assignImage(img)
            selectedPlaceView?.hideButtons()
            selectedPlaceView?.optionsReady = false
            selectedPlaceView?.optionsOpened = false
            selectedPlaceView = nil
        }
    }
    
    func calculateDistanceOffset() {
        DispatchQueue.global(qos: .userInitiated).async {
            let curtMapCenter = self.faeMapView.camera.centerCoordinate
            let point_a = MKMapPointForCoordinate(self.prevMapCenter)
            let point_b = MKMapPointForCoordinate(curtMapCenter)
            let distance = MKMetersBetweenMapPoints(point_a, point_b)
            guard distance >= self.screenWidthInMeters() else { return }
            self.prevMapCenter = curtMapCenter
            DispatchQueue.main.async {
                self.updatePlacePins()
                self.updateUserPins()
            }
        }
    }
    
    func screenWidthInMeters() -> CLLocationDistance {
        let cgpoint_a = CGPoint(x: 0, y: 0)
        let cgpoint_b = CGPoint(x: screenWidth, y: 0)
        let coor_a = faeMapView.convert(cgpoint_a, toCoordinateFrom: nil)
        let coor_b = faeMapView.convert(cgpoint_b, toCoordinateFrom: nil)
        let point_a = MKMapPointForCoordinate(coor_a)
        let point_b = MKMapPointForCoordinate(coor_b)
        let distance = MKMetersBetweenMapPoints(point_a, point_b)
        return distance * 0.6
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if AUTO_REFRESH {
            calculateDistanceOffset()
        }
        
        if btnCompass != nil { btnCompass.rotateCompass() }
        
        if uiviewPlaceBar.tag > 0 && PLACE_ENABLE { uiviewPlaceBar.annotations = visiblePlaces() }
        
        self.prevBearing = mapView.camera.heading
        
        if mapMode == .selecting {
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
    }
    
    func mapGesture(isOn: Bool) {
        faeMapView.isZoomEnabled = isOn
        faeMapView.isPitchEnabled = isOn
        faeMapView.isRotateEnabled = isOn
        faeMapView.isScrollEnabled = isOn
    }
    
    func dismissMainBtns() {
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
}
