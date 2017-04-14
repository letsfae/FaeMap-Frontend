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
        let direction: CGFloat = CGFloat(directionMap)
        let angle: CGFloat = ((360.0 - direction) * 3.14 / 180.0) as CGFloat
        buttonToNorth.transform = CGAffineTransform(rotationAngle: angle)
        
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
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {

    }
    
    func openMapPin(marker: GMSMarker, mapPin: MapPin) {
        let offset = 0.00148 * pow(2, Double(17 - faeMapView.camera.zoom)) // 0.00148 Los Angeles, 0.00117 Canada
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude+offset,
                                              longitude: marker.position.longitude, zoom: faeMapView.camera.zoom)
        faeMapView.camera = camera
        
        PinDetailViewController.selectedMarkerPosition = marker.position
        PinDetailViewController.pinMarker = marker
        PinDetailViewController.pinTypeEnum = PinDetailViewController.PinType(rawValue: "\(mapPin.type)")!
        PinDetailViewController.pinStatus = mapPin.status
        PinDetailViewController.pinStateEnum = self.selectPinState(pinState: mapPin.status)
        PinDetailViewController.pinIDPinDetailView = "\(mapPin.pinId)"
        PinDetailViewController.pinUserId = mapPin.userId
    }
    
    func openPlacePin(marker: GMSMarker, placePin: PlacePin) {
        let offset = 0.00148 * pow(2, Double(17 - faeMapView.camera.zoom)) // 0.00148 Los Angeles, 0.00117 Canada
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude+offset,
                                              longitude: marker.position.longitude, zoom: faeMapView.camera.zoom)
        faeMapView.camera = camera
        
        PinDetailViewController.selectedMarkerPosition = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
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
        OpenedPlaces.openedPlaces.append(opPlace)
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
        
        let zoomLv = mapView.camera.zoom
        
        let offset: Double = 0.001 * pow(2, Double(17 - zoomLv)) // 0.0012
        self.renewSelfLocation()
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude+offset,
                                              longitude: marker.position.longitude, zoom: zoomLv)

        if type == 0 { // fae map pin
            guard let mapPin = userData.values.first as? MapPin else {
                return false
            }
            
            if !self.canOpenAnotherPin {
                return true
            }
            self.canOpenAnotherPin = false
            
            invalidateAllTimer()
            openMapPin(marker: marker, mapPin: mapPin)
            
            let pinDetailVC = PinDetailViewController()
            pinDetailVC.delegate = self
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            
            self.clearMap(type: "user", animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.present(pinDetailVC, animated: false, completion: {
                    self.canOpenAnotherPin = true
                })
            })
            
            return true
        } else if type == 1 { // user pin
            guard let userPin = userData.values.first as? UserPin else {
                return false
            }
            self.canDoNextUserUpdate = false
            mapView.animate(to: camera)
            self.updateNameCard(withUserId: userPin.userId)
            self.animateNameCard()
            UIView.animate(withDuration: 0.25, delay: 0.3, animations: {
                self.buttonFakeTransparentClosingView.alpha = 1
            })
            return true
        } else if type == 2 { // place pin
            guard let placePin = userData.values.first as? PlacePin else {
                return false
            }
            
            if !self.canOpenAnotherPin {
                return true
            }
            self.canOpenAnotherPin = false
            
            invalidateAllTimer()
            openPlacePin(marker: marker, placePin: placePin)
            
            let pinDetailVC = PinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.delegate = self
            
            self.clearMap(type: "user", animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.present(pinDetailVC, animated: false, completion: {
                    self.canOpenAnotherPin = true
                })
            })
            return true
        }
        return true
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
