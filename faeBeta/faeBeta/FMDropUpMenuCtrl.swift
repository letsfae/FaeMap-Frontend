//
//  FMDropUpMenuCtrl.swift
//  MapFilterIcon
//
//  Created by Yue on 1/24/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON
//import CCHMapClusterController

extension FaeMapViewController: MapFilterMenuDelegate {
    
    func loadMapFilter() {
        guard FILTER_ENABLE else { return }
        
        btnFilterIcon = FMFilterIcon()
        btnFilterIcon.addTarget(self, action: #selector(self.actionFilterIcon(_:)), for: .touchUpInside)
        btnFilterIcon.layer.zPosition = 601
        view.addSubview(btnFilterIcon)
        view.bringSubview(toFront: btnFilterIcon)
        
        // new menu design
        uiviewDropUpMenu = FMDropUpMenu()
        uiviewDropUpMenu.layer.zPosition = 601
        uiviewDropUpMenu.delegate = self
        view.addSubview(uiviewDropUpMenu)
        let panGesture_menu = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
        uiviewDropUpMenu.addGestureRecognizer(panGesture_menu)
    }
    
    @objc func actionFilterIcon(_ sender: UIButton) {
        PLACE_ENABLE = true
        guard boolCanUpdatePlaces && boolCanUpdateUsers else { return }
        btnFilterIcon.startIconSpin()
        removePlaceUserPins({
            self.faePlacePins.removeAll(keepingCapacity: true)
            self.setPlacePins.removeAll(keepingCapacity: true)
            self.updatePlacePins()
        }) {
            self.faeUserPins.removeAll(keepingCapacity: true)
            self.updateTimerForUserPin()
        }
    }
    
    // MapFilterMenuDelegate
    func autoReresh(isOn: Bool) {
        AUTO_REFRESH = isOn
        Key.shared.autoRefresh = isOn
        FaeCoreData.shared.save("autoRefresh", value: isOn)
    }
    
    // MapFilterMenuDelegate
    func autoCyclePins(isOn: Bool) {
        AUTO_CIRCLE_PINS = isOn
        placeClusterManager.canUpdate = isOn
        Key.shared.autoCycle = isOn
        FaeCoreData.shared.save("autoCycle", value: isOn)
    }
    
    /*
    func findMatches() {
        var arrFaePins = [FaePinAnnotation]()
        for pin in faeMapView.annotations {
            guard let cluster = pin as? CCHMapClusterAnnotation else { continue }
            guard let faePin = cluster.annotations.first as? FaePinAnnotation else { continue }
            if faePin.type == "place" {
                arrFaePins.append(faePin)
            }
        }
        var restFaePins = [FaePinAnnotation]()
        for pin in mapClusterManager.annotations {
            guard let faePin = pin as? FaePinAnnotation else { continue }
            if faePin.type != "place" { continue }
            if arrFaePins.contains(faePin) {
                continue
            } else {
                restFaePins.append(faePin)
            }
        }
        mapClusterManager.removeAnnotations(restFaePins, withCompletionHandler: nil)
    }
     */
    
    // MapFilterMenuDelegate
    func hideAvatars(isOn: Bool) {
        HIDE_AVATARS = isOn
        Key.shared.hideAvatars = isOn
        FaeCoreData.shared.save("hideAvatars", value: isOn)
        if isOn {
            timerUserPin?.invalidate()
            timerUserPin = nil
            for faeUser in faeUserPins {
                faeUser.isValid = false
            }
            userClusterManager.removeAnnotations(faeUserPins) {
                self.faeUserPins.removeAll()
            }
        } else {
            updateTimerForUserPin()
        }
    }
    
    // MapFilterMenuDelegate
    func showSavedPins(type: String, savedPinIds: [Int], isCollections: Bool, colName: String) {
        if isCollections {
            mapMode = .collection
            setCollectionTitle(type: colName)
        }
        animateMainItems(show: true, animated: false)
        guard savedPinIds.count > 0 else {
            // 判断:
            return
        }
        PLACE_ENABLE = false
        self.desiredCount = savedPinIds.count
        self.completionCount = 0
        placeClusterManager.removeAnnotations(faePlacePins, withCompletionHandler: nil)
        placeClusterManager.removeAnnotations(placesFromSearch, withCompletionHandler: {
            self.placesFromSearch.removeAll(keepingCapacity: true)
            for id in savedPinIds {
                FaeMap.shared.getPin(type: type, pinId: String(id), completion: { (status, message) in
                    guard status / 100 == 2 else { return }
                    guard message != nil else { return }
                    let resultJson = JSON(message!)
                    if type == "place" {
                        let pinData = PlacePin(json: resultJson)
                        let pin = FaePinAnnotation(type: type, cluster: self.placeClusterManager, data: pinData as AnyObject)
                        self.placesFromSearch.append(pin)
                        self.placeClusterManager.addAnnotations([pin], withCompletionHandler: nil)
                    } else if type == "location" {
                        let pinData = LocationPin(json: resultJson)
                        let pin = FaePinAnnotation(type: type, cluster: self.placeClusterManager, data: pinData as AnyObject)
                        self.placesFromSearch.append(pin)
                        self.placeClusterManager.addAnnotations([pin], withCompletionHandler: nil)
                    }
                    
                    self.completionCount += 1
                })
            }
        })
        for user in faeUserPins {
            user.isValid = false
        }
        userClusterManager.removeAnnotations(faeUserPins, withCompletionHandler: nil)
    }
    
    @objc func panGesMenuDragging(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            uiviewNameCard.hide() {
                self.mapGesture(isOn: true)
            }
            let location = pan.location(in: view)
            if uiviewDropUpMenu.frame.origin.y == screenHeight {
                uiviewDropUpMenu.panCtrlParaSetting(showed: false)
            } else {
                uiviewDropUpMenu.panCtrlParaSetting(showed: true)
            }
            end = location.y
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: view)
            let location = pan.location(in: view)
            resumeTime = abs(Double(CGFloat(end - location.x) / velocity.x))
            if resumeTime > 0.3 {
                resumeTime = 0.3
            }
            if percent > 0.1 {
                // reload collection data
                if uiviewDropUpMenu.frame.origin.y < screenHeight {
                    uiviewDropUpMenu.loadCollectionData()
                }
                btnDropUpMenu.isSelected = false
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewDropUpMenu.frame.origin.y = self.uiviewDropUpMenu.sizeTo
                }, completion: { _ in
                    self.uiviewDropUpMenu.smallMode()
                })
            } else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewDropUpMenu.frame.origin.y = self.uiviewDropUpMenu.sizeFrom
                })
            }
        } else {
            guard uiviewDropUpMenu.frame.origin.y >= screenHeight - uiviewDropUpMenu.frame.size.height - device_offset_bot_main else { return }
            let location = pan.location(in: view)
            percent = abs(Double(CGFloat(end - location.y) / uiviewDropUpMenu.frame.size.height))
            let translation = pan.translation(in: view)
            uiviewDropUpMenu.center.y = uiviewDropUpMenu.center.y + translation.y
            pan.setTranslation(CGPoint.zero, in: view)
        }
    }
}
