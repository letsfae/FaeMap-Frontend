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

extension FaeMapViewController: GMSMapViewDelegate, GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    // Setup Cluster Manager
    func setupClusterManager() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: faeMapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        renderer.animatesClusters = false
        clusterManager = GMUClusterManager(map: faeMapView, algorithm: algorithm, renderer: renderer)
    }
    
    // MARK: - GMUClusterRendererDelegate
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        let pinInfo = JSON(marker.userData!)
        if let type = pinInfo["type"].string {
            if type != "user" && type != "comment" && type != "media" {
                
            }
        }
        marker.icon = #imageLiteral(resourceName: "markerRainbow")
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: faeMapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        faeMapView.moveCamera(update)
    }
    
    func clearMap(type: String) {
        if type == "all" || type == "pin" {
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
        if type == "all" || type == "user" {
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
        if type == "all" || type == "place" {
            for marker in mapPlacePinsDic {
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
    
    func clearMapNonAnimated(type: String) {
        if type == "all" || type == "pin" {
            for marker in mapPinsArray {
                marker.map = nil
            }
        }
        if type == "all" || type == "user" {
            for marker in mapUserPinsDic {
                marker.map = nil
            }
        }
        if type == "all" || type == "place" {
            for marker in mapPlacePinsDic {
                marker.map = nil
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let directionMap = position.bearing
        let direction: CGFloat = CGFloat(directionMap)
        let angle: CGFloat = ((360.0 - direction) * 3.14 / 180.0) as CGFloat
        buttonToNorth.transform = CGAffineTransform(rotationAngle: angle)
        
        if !didLoadFirstLoad && self.subviewSelfMarker != nil {
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let points = self.faeMapView.projection.point(for: position)
            self.subviewSelfMarker.center = points
        }
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
        
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let currentPosition = mapCenterCoordinate
        let currentZoomLevel = mapView.camera.zoom
 
        if currentZoomLevel >= 11 {
//            self.updateTimerForAllPins()
            let coorDistance = Double(cameraDiagonalDistance()) / 1000
            
            if let curPosition = previousPosition {
                let latitudeOffset = abs(currentPosition.latitude-curPosition.latitude)
                let longitudeOffset = abs(currentPosition.longitude-curPosition.longitude)
                var coorOffset = pow(latitudeOffset, 2.0) + pow(longitudeOffset, 2.0)
                coorOffset = pow(coorOffset, 0.5)*111
                if coorOffset > coorDistance {
                    self.previousPosition = currentPosition
                    print("DEBUG: Position offset \(coorOffset)km > \(coorDistance)km")
                    self.updateTimerForAllPins()
                }
                else {
                    print("DEBUG: Position offset = \(coorOffset)km <= \(coorDistance)km")
                }
            }
        }
        else {
            invalidateAllTimer()
            faeMapView.clear()
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
        
        let zoomLv = mapView.camera.zoom
        var offset: Double = 0.0012 * pow(2, Double(17 - zoomLv))
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
            offset = 0.00148 * pow(2, Double(17 - zoomLv))
            camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude+offset,
                                              longitude: marker.position.longitude, zoom: zoomLv)
            mapView.animate(to: camera)
            self.canOpenAnotherPin = false
            let pinDetailVC = PinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.selectedMarkerPosition = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
            pinDetailVC.pinMarker = marker
            pinDetailVC.delegate = self
            pinDetailVC.pinTypeEnum = PinDetailViewController.PinType(rawValue: "\(mapPin.type)")!
            pinDetailVC.pinStatus = mapPin.status
            pinDetailVC.pinStateEnum = self.selectPinState(pinState: mapPin.status)
            pinDetailVC.pinIdSentBySegue = "\(mapPin.pinId)"
            pinDetailVC.pinUserId = mapPin.userId
            
            self.clearMap(type: "user")
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
            
            camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude+0.00148,
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
            opinListElem.pinTypeId = "\(type)\(title)\(street)"
            
            // for opened pin list
            if let storedList = readByKey("openedPinList"){
                var openedPinListArray = storedList as! [String]
                pinTypeID = "\(type)%\(title)\(street)%\(category)"
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
            
            self.clearMap(type: "user")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
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
