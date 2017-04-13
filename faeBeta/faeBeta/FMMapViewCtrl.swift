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
                for marker in mapPinsArray {
                    marker.map = nil
                }
            } else {
                for marker in mapPinsArray {
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
        // 0.0012
        var offset: Double = 0.001 * pow(2, Double(17 - zoomLv))
        self.renewSelfLocation()
        var camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude+offset,
                                              longitude: marker.position.longitude, zoom: zoomLv)

        if type == 0 { // fae map pin
            guard let mapPin = userData.values.first as? MapPin else {
                return false
            }
            if !self.canOpenAnotherPin {
                return true
            }
            
            invalidateAllTimer()
            offset = 0.00117 * pow(2, Double(17 - zoomLv))
            camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude+offset,
                                              longitude: marker.position.longitude, zoom: zoomLv)
            mapView.animate(to: camera)
            self.canOpenAnotherPin = false
            let pinDetailVC = PinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.selectedMarkerPosition = marker.position
            pinDetailVC.pinMarker = marker
            pinDetailVC.delegate = self
            pinDetailVC.pinTypeEnum = PinDetailViewController.PinType(rawValue: "\(mapPin.type)")!
            pinDetailVC.pinStatus = mapPin.status
            pinDetailVC.pinStateEnum = self.selectPinState(pinState: mapPin.status)
            pinDetailVC.pinIdSentBySegue = "\(mapPin.pinId)"
            pinDetailVC.pinUserId = mapPin.userId
            
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
            mapView.animate (to: camera)
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
            
            invalidateAllTimer()
            // 0.00148 Los Angeles
            offset = 0.00117 * pow(2, Double(17 - zoomLv))
            camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude+offset,
                                              longitude: marker.position.longitude, zoom: zoomLv)
            mapView.animate(to: camera)
            
            let pinDetailVC = PinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.selectedMarkerPosition = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
            pinDetailVC.pinMarker = marker
            pinDetailVC.delegate = self
            var pinTypeID = ""
            let category = placePin.primaryCate
            let title = placePin.name
            let street = placePin.address1
            let city = placePin.address2
            pinDetailVC.pinTypeEnum = .place
            
            pinDetailVC.placeType = category
            pinDetailVC.strPlaceTitle = title
            pinDetailVC.strPlaceStreet = street
            pinDetailVC.strPlaceCity = city
            pinDetailVC.strPlaceImageURL = placePin.imageURL
            
            let opinListElem = OPinListElem()
            opinListElem.pinContent = title
            opinListElem.category = category
            opinListElem.street = street
            opinListElem.city = city
            opinListElem.imageURL = placePin.imageURL
            opinListElem.pinLat = marker.position.latitude
            opinListElem.pinLon = marker.position.longitude
            opinListElem.pinTime = "\(street), \(city)"
            opinListElem.pinTypeId = "\(title)\(street)"
            
            // for opened pin list
            if let storedList = readByKey("openedPinList"){
                var openedPinListArray = storedList as! [String]
                pinTypeID = "\(title)\(street)%\(category)"
                print("[didTap] pinTypeID:", pinTypeID)
                if openedPinListArray.contains(pinTypeID) == false {
                    openedPinListArray.insert(pinTypeID, at: 0)
                }
                self.storageForOpenedPinList.set(openedPinListArray, forKey: "openedPinList")
            }
            
            // write in realm swift
            let realm = try! Realm()
            try! realm.write {
                realm.add(opinListElem, update: true)
            }
            
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
