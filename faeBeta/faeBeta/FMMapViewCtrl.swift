//
//  FMMapViewDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import RealmSwift

extension FaeMapViewController: GMSMapViewDelegate {
    
    func clearMap(type: String, animated: Bool) {
        if type == "all" || type == "pin" {
            if !animated {
                for marker in mapPinsMarkers {
                    marker.map = nil
                }
            } else {
                for marker in mapPinsMarkers {
                    let delay: Double = Double(arc4random_uniform(100)) / 100
                    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 51))
                    icon.image = marker.icon
                    icon.contentMode = .scaleAspectFit
                    icon.alpha = 1
                    marker.iconView = icon
                    marker.icon = nil
                    UIView.animate(withDuration: 0.3, delay: delay, animations: {
                        icon.alpha = 0
                    }, completion: {(done: Bool) in
                        marker.map = nil
                    })
                }
            }
        }
        if type == "all" || type == "user" {
            if !animated {
                for marker in mapUserPinsDic {
                    marker.map = nil
                }
            } else {
                for marker in mapUserPinsDic {
                    let delay: Double = Double(arc4random_uniform(100)) / 100
                    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                    icon.image = marker.icon
                    icon.contentMode = .scaleAspectFit
                    icon.alpha = 1
                    marker.iconView = icon
                    marker.icon = nil
                    UIView.animate(withDuration: 0.3, delay: delay, animations: {
                        icon.alpha = 0
                    }, completion: {(done: Bool) in
                        marker.map = nil
                    })
                }
            }
        }
        if type == "all" || type == "place" {
            if !animated {
                for marker in placeMarkers {
                    marker.map = nil
                }
            } else {
                for marker in placeMarkers {
                    let delay: Double = Double(arc4random_uniform(100)) / 100
                    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 54))
                    icon.image = marker.icon
                    icon.contentMode = .scaleAspectFit
                    icon.alpha = 1
                    marker.iconView = icon
                    marker.icon = nil
                    UIView.animate(withDuration: 0.3, delay: delay, animations: {
                        icon.alpha = 0
                    }, completion: {(done: Bool) in
                        marker.map = nil
                    })
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let directionMap = position.bearing
        if directionMap != prevBearing {
            let direction: CGFloat = CGFloat(directionMap)
            let angle: CGFloat = ((360.0 - direction) * .pi / 180.0) as CGFloat
            btnToNorth.transform = CGAffineTransform(rotationAngle: angle)
            prevBearing = position.bearing
        }
        
        let points = self.faeMapView.projection.point(for: currentLocation2D)
        self.uiviewDistanceRadius.center = points
        
        if !didLoadFirstLoad && self.subviewSelfMarker != nil {
            self.subviewSelfMarker.center = points
        }
        
        if placeMarkers.count == 0 {
            return
        }
        
        let currentZoom = mapView.camera.zoom
        let coord_1 = mapView.projection.coordinate(for: CGPoint(x: 0, y: 0))
        let coord_2 = mapView.projection.coordinate(for: CGPoint(x: 0, y: 50))
        let absDistance = GMSGeometryDistance(coord_1, coord_2)
        
        if currentZoom == previousZoom {
            return
        } else if currentZoom > previousZoom {
            for i in 0..<placeMarkers.count {
                if placeMarkers[i].map != nil {
                    continue
                }
                var conflict = false
                for j in 0..<placeMarkers.count {
                    if j == i {
                        continue
                    }
                    let distance = GMSGeometryDistance(placeMarkers[i].position, placeMarkers[j].position)
                    if distance <= absDistance && placeMarkers[j].map != nil {
                        conflict = true
                        break
                    }
                }
                if !conflict {
                    placePinAnimation(marker: placeMarkers[i], animated: true)
                }
            }
        } else {
            for i in 0..<placeMarkers.count {
                if placeMarkers[i].map == nil {
                    continue
                }
                for j in i+1..<placeMarkers.count {
                    if placeMarkers[j].map == nil {
                        continue
                    }
                    if placeMarkers[j] == markerFakeUser {
                        print("[didChange] can find markerFakeUser")
                    }
                    let distance = GMSGeometryDistance(placeMarkers[i].position, placeMarkers[j].position)
                    // Collision occurs
                    
                    if distance <= absDistance {
                        placeMarkers[j].map = nil
                    }
                }
            }
        }
        previousZoom = mapView.camera.zoom
    }
    
    fileprivate func regionContainsMarker(marker: GMSMarker) {
        let region = GMSCoordinateBounds(region: faeMapView.projection.visibleRegion())
        if region.contains(marker.position) && marker.map == nil {
            animateMarkerIn(marker: marker)
        } else if region.contains(marker.position) && marker.map != nil {
            
        } else if !region.contains(marker.position) && marker.map != nil {
            animateMarkerOut(marker: marker)
        }
    }
    
    fileprivate func animateMarkerIn(marker: GMSMarker) {
        guard let userData = marker.userData as? [Int: AnyObject] else {
            return
        }
        guard let placePin = userData.values.first as? PlacePin else {
            return
        }
        marker.map = faeMapView
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 54))
        let iconImage = placePin.markerAvatar
        icon.image = iconImage
        marker.iconView = icon
        icon.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            icon.alpha = 1
        }, completion: {(done: Bool) in
            marker.iconView = nil
            marker.icon = iconImage
        })
    }
    
    fileprivate func animateMarkerOut(marker: GMSMarker) {
        guard let userData = marker.userData as? [Int: AnyObject] else {
            return
        }
        guard let placePin = userData.values.first as? PlacePin else {
            return
        }
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 54))
        icon.image = placePin.markerAvatar
        icon.contentMode = .scaleAspectFit
        icon.alpha = 1
        marker.iconView = icon
        marker.icon = nil
        UIView.animate(withDuration: 0.3, animations: {
            icon.alpha = 0
        }, completion: {(done: Bool) in
            marker.map = nil
        })
    }
    
    func openMapPin(marker: GMSMarker, mapPin: MapPin, animated: Bool) {
        
        self.animateToCoordinate(type: 0, marker: marker, animated: animated)
        
        PinDetailViewController.selectedMarkerPosition = marker.position
        PinDetailViewController.pinMarker = marker
        PinDetailViewController.pinTypeEnum = PinDetailViewController.PinType(rawValue: "\(mapPin.type)")!
        PinDetailViewController.pinStatus = mapPin.status
        PinDetailViewController.pinStateEnum = self.selectPinState(pinState: mapPin.status)
        PinDetailViewController.pinUserId = mapPin.userId
    }
    
    func openPlacePin(marker: GMSMarker, placePin: PlacePin, animated: Bool) {
        
        self.animateToCoordinate(type: 2, marker: marker, animated: animated)
        
        PinDetailViewController.selectedMarkerPosition = CLLocationCoordinate2D(latitude: marker.position.latitude,
                                                                                longitude: marker.position.longitude)
        PinDetailViewController.pinMarker = marker
        PinDetailViewController.pinTypeEnum = .place
        PinDetailViewController.placeType = placePin.primaryCate
        PinDetailViewController.strPlaceTitle = placePin.name
        PinDetailViewController.strPlaceStreet = placePin.address1
        PinDetailViewController.strPlaceCity = placePin.address2
        PinDetailViewController.strPlaceImageURL = placePin.imageURL
        
        let opPlace = OpenedPlace(title: placePin.name, category: placePin.primaryCate,
                                  street: placePin.address1, city: placePin.address2,
                                  imageURL: placePin.imageURL,
                                  position: marker.position)
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
            self.btnMapFilter.frame = CGRect(x: screenWidth/2, y: screenHeight-25, width: 0, height: 0)
            self.btnToNorth.frame = CGRect(x: 51.5, y: 611.5*screenWidthFactor, width: 0, height: 0)
            self.btnSelfLocation.frame = CGRect(x: 362.5*screenWidthFactor, y: 611.5*screenWidthFactor, width: 0, height: 0)
            self.btnChatOnMap.frame = CGRect(x: 51.5, y: 685.5*screenWidthFactor, width: 0, height: 0)
            self.labelUnreadMessages.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.btnPinOnMap.frame = CGRect(x: 362.5*screenWidthFactor, y: 685.5*screenWidthFactor, width: 0, height: 0)
        }, completion: nil)
    }
    
    fileprivate func animateToCoordinate(type: Int, marker: GMSMarker, animated: Bool) {
        
        // Default is for user pin
        var offset = 500*screenHeightFactor - screenHeight/2
        
        if type == 0 { // Map pin
            offset = 530*screenHeightFactor - screenHeight/2
        } else if type == 2 { // Place pin
            offset = 534*screenHeightFactor - screenHeight/2
        }
        
        var curPoint = faeMapView.projection.point(for: marker.position)
        curPoint.y -= offset
        let newCoor = faeMapView.projection.coordinate(for: curPoint)
        let camera = GMSCameraPosition.camera(withTarget: newCoor, zoom: faeMapView.camera.zoom, bearing: faeMapView.camera.bearing, viewingAngle: faeMapView.camera.viewingAngle)
        
        if animated {
            faeMapView.animate(to: camera)
        } else {
            faeMapView.camera = camera
        }
    }
    
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

        if type == 0 { // fae map pin
            guard let mapPin = userData.values.first as? MapPin else {
                return false
            }
            if !canOpenAnotherPin {
                return true
            }

            pauseAllUserPinTimers()
            dismissMainBtns()
            canOpenAnotherPin = false
            invalidateAllTimer()
            openMapPin(marker: marker, mapPin: mapPin, animated: true)
            
            let vcPinDetail = PinDetailViewController()
            vcPinDetail.delegate = self
            vcPinDetail.modalPresentationStyle = .overCurrentContext
            vcPinDetail.strPinId = "\(mapPin.pinId)"
            
            clearMap(type: "user", animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.present(vcPinDetail, animated: false, completion: {
                    self.canOpenAnotherPin = true
                })
            })
            
            return true
        } else if type == 1 { // user pin
            guard let userPin = userData.values.first as? FaeUserPin else {
                return false
            }
            pauseAllUserPinTimers()
            selectedUserMarker = marker
            canDoNextUserUpdate = false
            animateToCoordinate(type: type, marker: marker, animated: true)
            updateNameCard(withUserId: userPin.userId)
            animateNameCard()
            invalidateAllTimer()
            UIView.animate(withDuration: 0.25, delay: 0.3, animations: {
                self.btnTransparentClose.alpha = 1
            })
            return true
        } else if type == 2 { // place pin
            guard let placePin = userData.values.first as? PlacePin else {
                return false
            }
            if !canOpenAnotherPin {
                return true
            }
            
            pauseAllUserPinTimers()
            dismissMainBtns()
            canOpenAnotherPin = false
            invalidateAllTimer()
            openPlacePin(marker: marker, placePin: placePin, animated: true)
            
            let vcPinDetail = PinDetailViewController()
            vcPinDetail.modalPresentationStyle = .overCurrentContext
            vcPinDetail.delegate = self
            
            clearMap(type: "user", animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.present(vcPinDetail, animated: false, completion: {
                    self.canOpenAnotherPin = true
                })
            })
            return true
        }
        return true
    }
    
    func pauseAllUserPinTimers() {
        for user in faeUserPins {
            user.pause = true
        }
    }
    
    func resumeAllUserPinTimers() {
        for user in faeUserPins {
            user.pause = false
        }
    }
    
    fileprivate func selectPinState(pinState: String) -> PinDetailViewController.PinState {
        switch pinState {
        case "hot":
            return .hot
        case "read":
            return .read
        case "hot and read":
            return .hotRead
        default:
            return .normal
        }
    }
}
