
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
                anView.invisibleMode()
            }
            return anView
        } else if annotation is CCHMapClusterAnnotation {
            guard let clusterAnn = annotation as? CCHMapClusterAnnotation else { return nil }
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == "place" {
                return viewForPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == "user" {
                return viewForUser(annotation: annotation, first: firstAnn)
            } else {
                return viewForSocial(annotation: annotation, first: firstAnn)
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
        
        btnPlacePinActionOnSrchBar.hide()
        boolCanOpenPin = true
        
        if let idx = selectedAnn?.class_2_icon_id {
            selectedAnn?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
            guard let img = selectedAnn?.icon else { return }
            selectedAnnView?.assignImage(img)
            selectedAnnView?.hideButtons()
            selectedAnnView?.optionsReady = false
            selectedAnnView?.optionsOpened = false
            selectedAnnView = nil
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
        
        // re-start wave animation of self avatar annotation view
        DispatchQueue.global(qos: .userInitiated).async {
            if MKMapRectContainsPoint(self.faeMapView.visibleMapRect, MKMapPointForCoordinate(LocManager.shared.curtLoc.coordinate)) {
                if self.START_WAVE_ANIMATION {
                    self.START_WAVE_ANIMATION = false
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userAvatarAnimationRestart"), object: nil)
                    }
                }
            } else {
                self.START_WAVE_ANIMATION = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if btnPlacePinActionOnSrchBar != nil { btnPlacePinActionOnSrchBar.hide() }
        selectedAnnView?.hideButtons()
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
