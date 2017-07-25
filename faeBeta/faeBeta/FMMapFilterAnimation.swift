//
//  FMMapFilterAnimation.swift
//  MapFilterIcon
//
//  Created by Yue on 1/24/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    
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
    
    func animateMapFilterArrow() {
        guard FILTER_ENABLE else { return }
        
        if mapFilterArrow != nil {
            mapFilterArrow.removeFromSuperview()
        }
        mapFilterArrow = UIImageView(frame: CGRect(x: 0, y: screenHeight-55, width: 16, height: 8))
        mapFilterArrow.center.x = screenWidth / 2
        mapFilterArrow.image = #imageLiteral(resourceName: "mapFilterArrow")
        mapFilterArrow.contentMode = .scaleAspectFit
        view.addSubview(mapFilterArrow)
        
        UIView.animate(withDuration: 0.75, delay: 0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(5)
            self.mapFilterArrow.frame.origin.y = screenHeight - 60
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 6.2, options: [], animations: {
            self.mapFilterArrow.alpha = 0
        }, completion: {(done: Bool) in
            if self.mapFilterArrow != nil {
                self.mapFilterArrow.removeFromSuperview()
            }
        })
    }
    
    func animateMapFilterPolygon(_ sender: UIButton) {
        
        if btnMapFilter.center.y != screenHeight - 25 {
            return
        }
        
        boolCanUpdateUserPin = true
        btnMapFilter.isEnabled = false
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.btnMapFilter.frame = CGRect(x: screenWidth / 2 - 25, y: screenHeight - 50, width: 50, height: 50)
        }, completion: nil)
        
        polygonInside = UIImageView(frame: CGRect(x: 0, y: 0, width: 19.41, height: 21.71))
        polygonInside.center.x = screenWidth / 2
        polygonInside.center.y = btnMapFilter.center.y
        polygonInside.image = #imageLiteral(resourceName: "mapFilterAnimateInside")
        polygonInside.contentMode = .scaleAspectFit
        self.view.addSubview(polygonInside)
        polygonInside.alpha = 0
        polygonInside.layer.zPosition = 601
        
        if self.mapFilterArrow != nil {
            self.mapFilterArrow.removeFromSuperview()
        }
        self.filterCircle_1.layer.removeAllAnimations()
        self.filterCircle_2.layer.removeAllAnimations()
        self.filterCircle_3.layer.removeAllAnimations()
        self.filterCircle_4.layer.removeAllAnimations()
        self.polygonInside.alpha = 1
        
        UIView.animate(withDuration: 1, delay: 0, options: .repeat, animations: {
            self.btnMapFilter.transform = CGAffineTransform(rotationAngle: 3.1415926)
            self.polygonInside.transform = CGAffineTransform(rotationAngle: -3.1415926)
        }, completion: nil)
        
        refreshMap(pins: refreshPins, users: refreshUsers, places: refreshPlaces)
        
    }
    
    func stopMapFilterSpin() {
        guard FILTER_ENABLE else { return }
        btnMapFilter.layer.removeAllAnimations()
        if polygonInside != nil {
            polygonInside.layer.removeAllAnimations()
        }
        if !boolIsFirstLoad {
            filterCircleAnimation()
        }
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            if self.polygonInside != nil {
                self.polygonInside.alpha = 0
            }
            if self.btnMapFilter.center.y == screenHeight - 25 {
                self.btnMapFilter.frame = CGRect(x: screenWidth / 2 - 22, y: screenHeight - 47, width: 44, height: 44)
                return
            }
        }, completion: {(done: Bool) in
            self.btnMapFilter.isEnabled = true
            self.btnMapFilter.transform = CGAffineTransform(rotationAngle: 0)
            if self.polygonInside != nil {
                self.polygonInside.removeFromSuperview()
            }
        })
    }
 */
}
