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
        
        btnMapFilter = MapFilterIcon(frame: CGRect.zero)
        btnMapFilter.layer.zPosition = 601
        view.addSubview(btnMapFilter)
//        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
//        self.btnMapFilter.addGestureRecognizer(draggingGesture)
    }
    
    /*
    func actionHideFilterMenu(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.uiviewFilterMenu.frame.origin.y = screenHeight
            self.btnMapFilter.center.y = screenHeight - 25
        })
    }
    
    func panGesMenuDragging(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            self.hideNameCard(btnCardClose)
            if self.mapFilterArrow != nil {
                self.mapFilterArrow.removeFromSuperview()
            }
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
                    self.btnMapFilter.center.y = self.sizeTo - 25
                }, completion: nil)
            }
            else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewFilterMenu.frame.origin.y = self.sizeFrom
                    self.btnMapFilter.center.y = self.sizeFrom - 25
                })
            }
        } else {
            if self.uiviewFilterMenu.frame.origin.y >= screenHeight - floatFilterHeight {
                let location = pan.location(in: view)
                self.btnMapFilter.frame.origin.y = location.y - spaceFilter
                self.uiviewFilterMenu.frame.origin.y = location.y + spaceMenu
                percent = abs(Double(CGFloat(end - location.y) / floatFilterHeight))
            }
        }
    }
    */
}
