//
//  FMLoadingMapFilter.swift
//  MapFilterIcon
//
//  Created by Yue on 1/24/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    func loadMapFilter() {
        guard FILTER_ENABLE else { return }
        
        btnFilterIcon = MapFilterIcon(frame: CGRect.zero)
        btnFilterIcon.layer.zPosition = 601
        view.addSubview(btnFilterIcon)
        view.bringSubview(toFront: btnFilterIcon)
        
        uiviewFilterMenu = MapFilterMenu(frame: CGRect(x: 0, y: 736, w: 414, h: 471))
        uiviewFilterMenu.btnHideMFMenu.addTarget(self, action: #selector(self.actionHideFilterMenu(_:)), for: .touchUpInside)
        uiviewFilterMenu.layer.zPosition = 601
        view.addSubview(uiviewFilterMenu)
        view.bringSubview(toFront: uiviewFilterMenu)
        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
        btnFilterIcon.addGestureRecognizer(draggingGesture)
//        uiviewFilterMenu.addGestureRecognizer(draggingGesture)
        
        
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
//            if self.mapFilterArrow != nil {
//                self.mapFilterArrow.removeFromSuperview()
//            }
            let location = pan.location(in: view)
            if uiviewFilterMenu.frame.origin.y == screenHeight {
                sizeFrom = screenHeight
                sizeTo = screenHeight - floatFilterHeight
                spaceFilter = location.y - screenHeight + 52
                spaceMenu = screenHeight - location.y
                end = location.y
            }
            else {
                sizeFrom = screenHeight - floatFilterHeight
                sizeTo = screenHeight
                spaceFilter = location.y - screenHeight + floatFilterHeight + 52
                spaceMenu = screenHeight - floatFilterHeight - location.y
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
            }
            else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewFilterMenu.frame.origin.y = self.sizeFrom
                    self.btnFilterIcon.center.y = self.sizeFrom - 25
                })
            }
        } else {
            if self.uiviewFilterMenu.frame.origin.y >= screenHeight - floatFilterHeight {
                let location = pan.location(in: view)
                self.btnFilterIcon.frame.origin.y = location.y - spaceFilter
                self.uiviewFilterMenu.frame.origin.y = location.y + spaceMenu
                percent = abs(Double(CGFloat(end - location.y) / floatFilterHeight))
            }
        }
    }
    
}
