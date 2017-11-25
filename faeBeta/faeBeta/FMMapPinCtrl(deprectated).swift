//
//  UpdateMapPins.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
//import CCHMapClusterController

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

extension FaeMapViewController {
    
    func viewForSocial(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "social"
        var anView: SocialPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SocialPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = SocialPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.icon)
        let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
        DispatchQueue.main.async {
            anView.imageView.frame = CGRect(x: 30, y: 61, width: 0, height: 0)
            UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                anView.imageView.frame = CGRect(x: 6, y: 10, width: 48, height: 51)
            }, completion: nil)
        }
        return anView
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
    
    func tapSocialPin(didSelect view: MKAnnotationView) {
        /*
        guard let clusterAnn = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return }
        guard let mapPin = firstAnn.pinInfo as? MapPin else { return }
        dismissMainBtns()
        boolCanOpenPin = false
        openMapPin(annotation: firstAnn, mapPin: mapPin, animated: true)
        animateToCoordinate(type: 2, coordinate: clusterAnn.coordinate, animated: true)
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
        */
    }
    
    func updateTimerForLoadRegionPin() {
        /*
        self.loadCurrentRegionPins()
        if timerLoadRegionPins != nil {
            timerLoadRegionPins.invalidate()
        }
        timerLoadRegionPins = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.loadCurrentRegionPins), userInfo: nil, repeats: true)
     */
    }
    
    // MARK: -- Load Pins based on the Current Region Camera
    func loadCurrentRegionPins() {
        /*
        let coorDistance = cameraDiagonalDistance()
        if self.boolCanUpdateSocialPin {
            self.boolCanUpdateSocialPin = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.refreshMapPins(radius: coorDistance, completion: { results in
                    self.pinMapPinsOnMap(results: results)
                    self.boolCanUpdateSocialPin = true
                })
            })
        }
         */
    }
    
    fileprivate func refreshMapPins(radius: Int, completion: @escaping ([MapPin]) -> ()) {
        /*
        self.mapPins.removeAll()
        
        // Get screen center's coordinate
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        
        // Get social pins data from Fae Back-End
        let loadPinsByZoomLevel = FaeMap()
        loadPinsByZoomLevel.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        loadPinsByZoomLevel.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        loadPinsByZoomLevel.whereKey("radius", value: "\(radius)")
        loadPinsByZoomLevel.whereKey("type", value: stringFilterValue)
        loadPinsByZoomLevel.whereKey("in_duration", value: "true")
        loadPinsByZoomLevel.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadCurrentRegionPins] status/100 != 2")
                // Sent noti to stop filter icon spinning, 2 seconds
                completion(self.mapPins)
                return
            }
            let mapInfoJSON = JSON(message!)
            guard let mapPinJsonArray = mapInfoJSON.array else {
                // Sent noti to stop filter icon spinning, 2 seconds
                print("[loadCurrentRegionPins] fail to parse pin comments")
                completion(self.mapPins)
                return
            }
            if mapPinJsonArray.count <= 0 {
                // Sent noti to stop filter icon spinning, 2 seconds
                completion(self.mapPins)
                return
            }
            self.processMapPins(results: mapPinJsonArray)
            // Sent noti to stop filter icon spinning, 2 seconds
            completion(self.mapPins)
        }
         */
    }
    
    fileprivate func processMapPins(results: [JSON]) {
        /*
        for result in results {
            let mapPin = MapPin(json: result)
            if self.mapPins.contains(mapPin) {
                continue
            } else {
                self.mapPins.append(mapPin)
            }
        }
         */
    }
    
    fileprivate func pinMapPinsOnMap(results: [MapPin]) {
        /*
        for result in results {
            DispatchQueue.global(qos: .default).async {
                let pinMap = FaePinAnnotation(type: result.type)
                pinMap.id = result.pinId
                pinMap.coordinate = result.position
                pinMap.icon = self.pinIconSelector(type: result.type, status: result.status)
                pinMap.pinInfo = result as AnyObject
                DispatchQueue.main.async {
                    self.mapClusterManager.addAnnotations([pinMap], withCompletionHandler: nil)
                }
            }
        }
         */
    }
    
    // Animation for pin logo
    func animatePinWhenItIsCreated(pinID: String, type: String) {
        /*
        tempMarker = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 128))
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 25.5)
        tempMarker.center = mapCenter
        if type == "comment" {
            tempMarker.image = UIImage(named: "commentMarkerWhenCreated")
        } else if type == "media" {
            tempMarker.image = UIImage(named: "momentMarkerWhenCreated")
        } else if type == "chat_room" {
            tempMarker.image = UIImage(named: "chatMarkerWhenCreated")
        }
        view.addSubview(tempMarker)
        let markerMask = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.addSubview(markerMask)
        UIView.animate(withDuration: 0.783, delay: 0.15, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.tempMarker.frame.size.width = 48
            self.tempMarker.frame.size.height = 51
            self.tempMarker.center = mapCenter
        }, completion: { (done: Bool) in
            if done {
                markerMask.removeFromSuperview()
                self.loadMarkerWithpinID(pinID: pinID, type: type, tempMaker: self.tempMarker)
            }
        })
     */
    }
    
    fileprivate func loadMarkerWithpinID(pinID: String, type: String, tempMaker: UIImageView) {
        /*
        let loadPin = FaeMap()
        loadPin.getPin(type: type, pinId: pinID) { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMarkerWithpinID] status/100 != 2")
                return
            }
            guard let mapInfo = message else {
                print("[loadMarkerWithpinID] fail to parse pin info")
                return
            }
            let mapPinJson = JSON(mapInfo)
            // Just init an empty MapPin class instance, GET /map isn't used here.
            var mapPin = MapPin(json: mapPinJson)
            // Add the info manually here
            mapPin.pinId = Int(pinID)!
            mapPin.type = type
            mapPin.userId = mapPinJson["user_id"].intValue
            mapPin.status = "normal"
            mapPin.position.latitude = mapPinJson["geolocation"]["latitude"].doubleValue
            mapPin.position.longitude = mapPinJson["geolocation"]["longitude"].doubleValue
            self.mapPins.append(mapPin)
            let pinMap = FaePinAnnotation(type: mapPin.type)
            pinMap.icon = self.pinIconSelector(type: type, status: mapPin.status)
            pinMap.coordinate = mapPin.position
            pinMap.pinInfo = mapPin as AnyObject
            self.mapClusterManager.addAnnotations([pinMap], withCompletionHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                self.tempMarker.removeFromSuperview()
            })
        }
     */
    }
    
    func cameraDiagonalDistance() -> Int {
        guard faeMapView != nil else { return 8000 }
        let centerCoor: CLLocationCoordinate2D = getCenterCoordinate()
        // init center location from center coordinate
        let centerLocation = CLLocation(latitude: centerCoor.latitude, longitude: centerCoor.longitude)
        let topCenterCoor: CLLocationCoordinate2D = getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoor.latitude, longitude: topCenterCoor.longitude)
        let radius: CLLocationDistance = centerLocation.distance(from: topCenterLocation)
        return Int(radius * 4)
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        return faeMapView.centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        return faeMapView.convert(CGPoint(x: screenWidth / 2, y: 0), toCoordinateFrom: nil)
    }

    
    func pinIconSelector(type: String, status: String) -> UIImage {
        switch type {
        case "comment":
            if status == "hot" {
                return #imageLiteral(resourceName: "markerCommentHot")
            } else if status == "new" {
                return #imageLiteral(resourceName: "markerCommentNew")
            } else if status == "hotRead" {
                return #imageLiteral(resourceName: "markerCommentHotRead")
            } else if status == "read" {
                return #imageLiteral(resourceName: "markerCommentRead")
            } else {
                return #imageLiteral(resourceName: "commentPinMarker")
            }
        case "chat_room":
            if status == "hot" {
                return #imageLiteral(resourceName: "markerChatHot")
            } else if status == "new" {
                return #imageLiteral(resourceName: "markerChatNew")
            } else if status == "hotRead" {
                return #imageLiteral(resourceName: "markerChatHotRead")
            } else if status == "read" {
                return #imageLiteral(resourceName: "markerChatRead")
            } else {
                return #imageLiteral(resourceName: "chatPinMarker")
            }
        case "media":
            if status == "hot" {
                return #imageLiteral(resourceName: "markerMomentHot")
            } else if status == "new" {
                return #imageLiteral(resourceName: "markerMomentNew")
            } else if status == "hotRead" {
                return #imageLiteral(resourceName: "markerMomentHotRead")
            } else if status == "read" {
                return #imageLiteral(resourceName: "markerMomentRead")
            } else {
                return #imageLiteral(resourceName: "momentPinMarker")
            }
        default:
            return UIImage()
        }
    }
}
