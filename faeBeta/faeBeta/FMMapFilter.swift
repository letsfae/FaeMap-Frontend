//
//  FMMapFilter.swift
//  MapFilterIcon
//
//  Created by Yue on 1/24/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import CCHMapClusterController

extension FaeMapViewController: MapFilterMenuDelegate {
    func loadMapFilter() {
        guard FILTER_ENABLE else { return }
        
        btnFilterIcon = MapFilterIcon()
        btnFilterIcon.addTarget(self, action: #selector(self.actionFilterIcon(_:)), for: .touchUpInside)
        btnFilterIcon.layer.zPosition = 601
        view.addSubview(btnFilterIcon)
        view.bringSubview(toFront: btnFilterIcon)
        
        uiviewFilterMenu = MapFilterMenu(frame: CGRect(x: 0, y: 736, w: 414, h: 471))
        uiviewFilterMenu.delegate = self
        uiviewFilterMenu.btnFilterIcon = btnFilterIcon
        uiviewFilterMenu.layer.zPosition = 601
        view.addSubview(uiviewFilterMenu)
        view.bringSubview(toFront: uiviewFilterMenu)
        let panGesture_icon = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
        btnFilterIcon.addGestureRecognizer(panGesture_icon)
        let panGesture_menu = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
        uiviewFilterMenu.addGestureRecognizer(panGesture_menu)
    }
    
    func actionFilterIcon(_ sender: UIButton) {
        updateTimerForUserPin()
        updateTimerForLoadRegionPlacePin()
    }
    
    // MapFilterMenuDelegate
    func autoReresh(isOn: Bool) {
        AUTO_REFRESH = isOn
    }
    
    // MapFilterMenuDelegate
    func autoCyclePins(isOn: Bool) {
        AUTO_CIRCLE_PINS = isOn
        if isOn {
            
        } else {
            
        }
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
        if isOn {
            timerUserPin?.invalidate()
            timerUserPin = nil
            for faeUser in faeUserPins {
                faeUser.isValid = false
            }
            mapClusterManager.removeAnnotations(faeUserPins) {
                self.faeUserPins.removeAll()
            }
        } else {
            updateTimerForUserPin()
        }
    }
    
    func actionHideFilterMenu(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.uiviewFilterMenu.frame.origin.y = screenHeight
            self.btnFilterIcon.center.y = screenHeight - 25
        })
    }
    
    func panGesMenuDragging(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            uiviewNameCard.hide() {
                self.mapGesture(isOn: true)
            }
            let location = pan.location(in: view)
            if uiviewFilterMenu.frame.origin.y == screenHeight {
                sizeFrom = screenHeight
                sizeTo = screenHeight - floatFilterHeight
                end = location.y
            } else {
                sizeFrom = screenHeight - floatFilterHeight
                sizeTo = screenHeight
                end = location.y
            }
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: view)
            let location = pan.location(in: view)
            resumeTime = abs(Double(CGFloat(end - location.x) / velocity.x))
            if resumeTime > 0.3 {
                resumeTime = 0.3
            }
            if percent > 0.1 {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewFilterMenu.frame.origin.y = self.sizeTo
                    self.btnFilterIcon.center.y = self.sizeTo - 25
                }, completion: nil)
            } else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewFilterMenu.frame.origin.y = self.sizeFrom
                    self.btnFilterIcon.center.y = self.sizeFrom - 25
                })
            }
        } else {
            guard uiviewFilterMenu.frame.origin.y >= screenHeight - floatFilterHeight else { return }
            let location = pan.location(in: view)
            percent = abs(Double(CGFloat(end - location.y) / floatFilterHeight))
            let translation = pan.translation(in: view)
            btnFilterIcon.center.y = btnFilterIcon.center.y + translation.y
            uiviewFilterMenu.center.y = uiviewFilterMenu.center.y + translation.y
            pan.setTranslation(CGPoint.zero, in: view)
        }
    }
    
}
