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

extension FaeMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //        print("Cur-Zoom Level: \(mapView.camera.zoom)")
        //        print("Pre-Zoom Level: \(previousZoomLevel)")
        let directionMap = position.bearing
        let direction: CGFloat = CGFloat(directionMap)
        let angle:CGFloat = ((360.0 - direction) * 3.14/180.0) as CGFloat
        buttonToNorth.transform = CGAffineTransform(rotationAngle: angle)
        if userStatus == 5 {
            self.faeMapView.isMyLocationEnabled = true
            if myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.isHidden = true
            }
            if myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.isHidden = true
            }
            if myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.isHidden = true
            }
            if myPositionIcon != nil {
                self.myPositionIcon.isHidden = true
            }
            return
        }
        if self.myPositionOutsideMarker_1 != nil {
            self.myPositionOutsideMarker_1.isHidden = false
        }
        if self.myPositionOutsideMarker_2 != nil {
            self.myPositionOutsideMarker_2.isHidden = false
        }
        if self.myPositionOutsideMarker_3 != nil {
            self.myPositionOutsideMarker_3.isHidden = false
        }
        if self.myPositionIcon != nil {
            self.myPositionIcon.isHidden = false
        }
        if startUpdatingLocation {
            currentLocation = locManager.location
            self.currentLatitude = currentLocation.coordinate.latitude
            self.currentLongitude = currentLocation.coordinate.longitude
            let position = CLLocationCoordinate2DMake(self.currentLatitude, self.currentLongitude)
            let selfPositionToPoint = faeMapView.projection.point(for: position)
            myPositionOutsideMarker_3.center = selfPositionToPoint
            myPositionOutsideMarker_2.center = selfPositionToPoint
            myPositionOutsideMarker_1.center = selfPositionToPoint
            myPositionIcon.center = selfPositionToPoint
        }
        
        if mapView.camera.zoom < 11 && !canLoadMapPin {
            mapView.clear()
            canLoadMapPin = true
            return
        }
        
        if mapView.camera.zoom >= 11 && canLoadMapPin {
            canLoadMapPin = false
            let currentZoomLevel = faeMapView.camera.zoom
            let powFactor: Double = Double(21 - currentZoomLevel)
            let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
            // This update also includes updating for user pins updating
            self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
            self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
        }
        
        //        let mapTop = CGPointMake(0, 0)
        //        let mapTopCoor = faeMapView.projection.coordinateForPoint(mapTop)
        //        let mapBottom = CGPointMake(screenWidth, screenHeight)
        //        let mapBottomCoor = faeMapView.projection.coordinateForPoint(mapBottom)
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
                    print("DEBUG: Position offset \(coorOffset)km > \(coorDistance)km")
                    if !self.canDoNextUserUpdate {
                        return
                    }
                    mapView.clear()
                    self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
                    self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
                    return
                }
                else {
                    print("DEBUG: Position offset = \(coorOffset)km <= \(coorDistance)km")
                }
            }
        }
        else {
            timerUpdateSelfLocation.invalidate()
            timerLoadRegionPins.invalidate()
            mapView.clear()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if openUserPinActive {
            self.hideOpenUserPinAnimation()
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
        let camera = GMSCameraPosition.camera(withLatitude: latitude+0.001, longitude: longitude, zoom: 17)
        let pinLoc = JSON(marker.userData!)
        if let type = pinLoc["type"].string {
            if type == "user" {
                self.canDoNextUserUpdate = false
                mapView.animate (to: camera)
                if let userid = pinLoc["user_id"].int {
                    self.currentViewingUserId = userid
                    loadUserPinInformation("\(userid)")
                }
                self.showOpenUserPinAnimation(latitude: latitude, longitude: longitude)
                return true
            }
            if type == "comment" {
                if !self.canOpenAnotherPin {
                    return true
                }
//                camera = GMSCameraPosition.camera(withLatitude: latitude+0.00155, longitude: longitude, zoom: 17)
//                mapView.camera = camera
                self.canOpenAnotherPin = false
                var pinComment = JSON(marker.userData!)
                if let commentIDGet = pinComment["comment_id"].int {
                    commentIdToPassBySegue = commentIDGet
                    var openedPinListArray = [Int]()
                    openedPinListArray.append(commentIDGet)
//                    marker.icon = UIImage(named: "markerCommentPinHeavyShadow")
                    marker.zIndex = 2
                    if let listArray = readByKey("openedPinList") {
                        openedPinListArray.removeAll()
                        openedPinListArray = listArray as! [Int]
                        if openedPinListArray.contains(commentIDGet) == false {
                            openedPinListArray.append(commentIDGet)
                        }
                    }
                    self.storageForOpenedPinList.set(openedPinListArray, forKey: "openedPinList")
                }
                self.markerBackFromCommentDetail = marker
                let commentPinDetailVC = CommentPinDetailViewController()
                commentPinDetailVC.modalPresentationStyle = .overCurrentContext
                commentPinDetailVC.commentIdSentBySegue = commentIdToPassBySegue
                commentPinDetailVC.selectedMarkerPosition = CLLocationCoordinate2D(latitude: latitude+0.00148, longitude: longitude)
                commentPinDetailVC.delegate = self
                self.present(commentPinDetailVC, animated: false, completion: {
                    self.canOpenAnotherPin = true
                })
                return true
            }
            else if type.contains("chat"){
                
            }
        }
        return true
    }
}
