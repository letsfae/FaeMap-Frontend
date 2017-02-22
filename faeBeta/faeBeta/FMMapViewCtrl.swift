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
                UIView.animate(withDuration: 0.5, delay: delay, animations: {
                    if marker.iconView != nil {
                        marker.iconView?.alpha = 0
                    }
                    }, completion: {(done: Bool) in
                        marker.map = nil
                })
            }
        }
        
        else if type == "all" || type == "user" {
            for marker in mapUserPinsDic {
                let delay: Double = Double(arc4random_uniform(100)) / 100
                UIView.animate(withDuration: 0.5, delay: delay, animations: {
                    if marker.iconView != nil {
                        marker.iconView?.alpha = 0
                    }
                    }, completion: {(done: Bool) in
                        marker.map = nil
                })
            }
        }
        
        else if type == "all" || type == "place" {
            for marker in mapPlacePinsDic {
                let delay: Double = Double(arc4random_uniform(100)) / 100
                UIView.animate(withDuration: 0.5, delay: delay, animations: {
                    if marker.iconView != nil {
                        marker.iconView?.alpha = 0
                    }
                }, completion: {(done: Bool) in
                    marker.map = nil
                })
            }
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {

        let directionMap = position.bearing
        let direction: CGFloat = CGFloat(directionMap)
        let angle: CGFloat = ((360.0 - direction) * 3.14 / 180.0) as CGFloat
        buttonToNorth.transform = CGAffineTransform(rotationAngle: angle)

//        print("Cur-Zoom Level: \(mapView.camera.zoom)")
//        print("Pre-Zoom Level: \(previousZoomLevel)")
//        if mapView.camera.zoom < 11 && !canLoadMapPin {
//            clearMap(type: "all")
//            canLoadMapPin = true
//            return
//        }
//        
//        if mapView.camera.zoom >= 11 && canLoadMapPin {
//            canLoadMapPin = false
//            let currentZoomLevel = faeMapView.camera.zoom
//            let powFactor: Double = Double(21 - currentZoomLevel)
//            let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
//            // This update also includes updating for user pins updating
//            self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
//            self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
//        }
        
//        let mapTop = CGPoint.zero
//        let mapTopCoor = faeMapView.projection.coordinate(for: mapTop)
//        let mapBottom = CGPoint(x: screenWidth, y: screenHeight)
//        let mapBottomCoor = faeMapView.projection.coordinate(for: mapBottom)
//        let coorWidth = abs(mapBottomCoor.latitude - mapTopCoor.latitude)
//        print("DEBUG Coordinate Width: \(coorWidth)")
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let currentPosition = mapCenterCoordinate
        
        let currentZoomLevel = mapView.camera.zoom
//        let preZoomLevel = previousZoomLevel
//        self.previousZoomLevel = currentZoomLevel
 
        if currentZoomLevel >= 11 {
            let powFactor: Double = Double(21 - currentZoomLevel)
            let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
            
            /*
            if abs(currentZoomLevel-preZoomLevel) >= 1 {
                print("DEBUG: Zoom level diff >= 1")
                self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
                self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
                return
            }
             */
            
            if let curPosition = previousPosition {
                let latitudeOffset = abs(currentPosition.latitude-curPosition.latitude)
                let longitudeOffset = abs(currentPosition.longitude-curPosition.longitude)
                var coorOffset = pow(latitudeOffset, 2.0) + pow(longitudeOffset, 2.0)
                coorOffset = pow(coorOffset, 0.5)*111
                if coorOffset > coorDistance {
                    self.previousPosition = currentPosition
//                    print("DEBUG: Position offset \(coorOffset)km > \(coorDistance)km")
                    if !self.canDoNextUserUpdate {
                        return
                    }
                    self.clearMap(type: "all")
                    self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
                    self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
                    var placesAll = false
                    if btnMFilterPlacesAll.tag == 1 {
                        placesAll = true
                    }
                    self.updateTimerForLoadRegionPlacePin(radius: Int(coorDistance*1500), all: placesAll)
                    return
                }
                else {
//                    print("DEBUG: Position offset = \(coorOffset)km <= \(coorDistance)km")
                }
            }
        }
        else {
            timerUpdateSelfLocation.invalidate()
            timerLoadRegionPins.invalidate()
            timerLoadRegionPlacePins.invalidate()
            clearMap(type: "all")
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if openUserPinActive {
            self.canDoNextUserUpdate = true
            openUserPinActive = false
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.userData == nil {
            return false
        }
        self.renewSelfLocation()
        let latitude = marker.position.latitude
        let longitude = marker.position.longitude
        var camera = GMSCameraPosition.camera(withLatitude: latitude+0.0012, longitude: longitude, zoom: 17)
        let pinLoc = JSON(marker.userData!)
        if let type = pinLoc["type"].string {
            if type == "user" {
                self.canDoNextUserUpdate = false
                mapView.animate (to: camera)
                if let userid = pinLoc["user_id"].int {
                    self.updateNameCard(withUserId: userid)
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.buttonFakeTransparentClosingView.alpha = 1
                    })
                    self.openUserPinActive = true
                }
                return true
            }
            if !self.canOpenAnotherPin {
                return true
            }
            camera = GMSCameraPosition.camera(withLatitude: latitude+0.00148, longitude: longitude, zoom: 17)
            mapView.camera = camera
            self.canOpenAnotherPin = false
            
            let pinDetailVC = PinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.selectedMarkerPosition = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
            pinDetailVC.pinMarker = marker
            pinDetailVC.delegate = self
            self.markerBackFromPinDetail = marker
            if type == "comment" || type == "media" {
                var pinComment = JSON(marker.userData!)
                let pinIDGet = pinComment["\(type)_id"].stringValue
                pinIdToPassBySegue = pinIDGet
                if type == "media" {
                    pinDetailVC.pinTypeEnum = .media
                }
                else if type == "comment" {
                    pinDetailVC.pinTypeEnum = .comment
                }
                if let status = pinLoc["status"].string {
                    pinDetailVC.pinStatus = status
                }
                
                // for opened pin list
                pinDetailVC.pinIdSentBySegue = pinIdToPassBySegue
                if let storedList = readByKey("openedPinList"){
                    var openedPinListArray = storedList as! [String]
                    let pinTypeID = "\(type)%\(pinIDGet)"
                    if openedPinListArray.contains(pinTypeID) == false {
                        openedPinListArray.insert(pinTypeID, at: 0)
                    }
                    self.storageForOpenedPinList.set(openedPinListArray, forKey: "openedPinList")
                }
                
                timerUpdateSelfLocation.invalidate()
                self.clearMap(type: "user")
                self.present(pinDetailVC, animated: false, completion: {
                    self.canOpenAnotherPin = true
                })
                return true
            }
            else if type == "place" {
                var pinTypeID = ""
                var category = "burgers"
                var title = ""
                var street = ""
                var city = ""
                pinDetailVC.pinTypeEnum = .place
                
                let opinListElem = OPinListElem()
                
                if let placeType = pinLoc["category"].string {
                    pinDetailVC.placeType = placeType
                    category = placeType
                    opinListElem.category = placeType
                }
                if let placeTitle = pinLoc["title"].string {
                    pinDetailVC.strPlaceTitle = placeTitle
                    title = placeTitle
                }
                if let placeStreet = pinLoc["street"].string {
                    pinDetailVC.strPlaceStreet = placeStreet
                    street = placeStreet
                    opinListElem.street = placeStreet
                }
                if let placeCity = pinLoc["city"].string {
                    pinDetailVC.strPlaceCity = placeCity
                    city = placeCity
                    opinListElem.city = placeCity
                }
                if let placeImageURL = pinLoc["imageURL"].string {
                    pinDetailVC.strPlaceImageURL = placeImageURL
                    opinListElem.imageURL = placeImageURL
                }
                
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
                
                opinListElem.pinTypeId = "\(type)\(title)\(street)"
                opinListElem.pinContent = title
                opinListElem.pinLat = marker.position.latitude
                opinListElem.pinLon = marker.position.longitude
                opinListElem.pinTime = "\(street), \(city)"
                try! realm.write {
                    realm.add(opinListElem, update: true)
                }
                
                timerUpdateSelfLocation.invalidate()
                self.clearMap(type: "user")
                self.present(pinDetailVC, animated: false, completion: {
                    self.canOpenAnotherPin = true
                })
                return true
            }
        }
        return true
    }
}
