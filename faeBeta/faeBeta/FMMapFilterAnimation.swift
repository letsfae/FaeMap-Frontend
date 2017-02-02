//
//  FMMapFilterAnimation.swift
//  MapFilterIcon
//
//  Created by Yue on 1/24/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    
    func filterCircleAnimation() {
        if filterCircle_1 != nil {
            filterCircle_1.removeFromSuperview()
        }
        if filterCircle_2 != nil {
            filterCircle_2.removeFromSuperview()
        }
        if filterCircle_3 != nil {
            filterCircle_3.removeFromSuperview()
        }
        if filterCircle_4 != nil {
            filterCircle_4.removeFromSuperview()
        }
        let xAxis: CGFloat = 22
        let yAxis: CGFloat = 22
        let xAxisAfter: CGFloat = 7
        let yAxisAfter: CGFloat = 7
        filterCircle_1 = UIImageView(frame: CGRect.zero)
        filterCircle_1.center = CGPoint(x: xAxis, y: yAxis)
        filterCircle_1.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
        btnMapFilter.addSubview(filterCircle_1)
        filterCircle_2 = UIImageView(frame: CGRect.zero)
        filterCircle_2.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
        filterCircle_2.center = CGPoint(x: xAxis, y: yAxis)
        btnMapFilter.addSubview(filterCircle_2)
        filterCircle_3 = UIImageView(frame: CGRect.zero)
        filterCircle_3.center = CGPoint(x: xAxis, y: yAxis)
        filterCircle_3.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
        btnMapFilter.addSubview(filterCircle_3)
        filterCircle_4 = UIImageView(frame: CGRect.zero)
        filterCircle_4.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
        filterCircle_4.center = CGPoint(x: xAxis, y: yAxis)
        btnMapFilter.addSubview(filterCircle_4)
        UIView.animate(withDuration: 4, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            self.filterCircle_1.alpha = 0.0
            self.filterCircle_1.frame = CGRect(x: xAxisAfter, y: yAxisAfter, width: 30, height: 30)
        }), completion: nil)
        
        UIView.animate(withDuration: 4, delay: 1, options: [.repeat, .curveEaseIn], animations: ({
            self.filterCircle_2.alpha = 0.0
            self.filterCircle_2.frame = CGRect(x: xAxisAfter, y: yAxisAfter, width: 30, height: 30)
        }), completion: nil)
        
        UIView.animate(withDuration: 4, delay: 2, options: [.repeat, .curveEaseIn], animations: ({
            self.filterCircle_3.alpha = 0.0
            self.filterCircle_3.frame = CGRect(x: xAxisAfter, y: yAxisAfter, width: 30, height: 30)
        }), completion: nil)
        
        UIView.animate(withDuration: 4, delay: 3, options: [.repeat, .curveEaseIn], animations: ({
            self.filterCircle_4.alpha = 0.0
            self.filterCircle_4.frame = CGRect(x: xAxisAfter, y: yAxisAfter, width: 30, height: 30)
        }), completion: nil)
    }
    
    func actionHideFilterMenu(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.uiviewFilterMenu.frame.origin.y = screenHeight
            self.btnMapFilter.center.y = screenHeight - 25
        })
    }
    
    func panGesMenuDragging(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            if self.mapFilterArrow != nil {
                self.mapFilterArrow.removeFromSuperview()
            }
            let location = pan.location(in: view)
            if uiviewFilterMenu.frame.origin.y == screenHeight {
                sizeFrom = screenHeight
                sizeTo = screenHeight - filterMenuHeight
                spaceFilter = location.y - screenHeight + 52
                spaceMenu = screenHeight - location.y
                end = location.y
            }
            else {
                sizeFrom = screenHeight - filterMenuHeight
                sizeTo = screenHeight
                spaceFilter = location.y - screenHeight + filterMenuHeight + 52
                spaceMenu = screenHeight - filterMenuHeight - location.y
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
            if self.uiviewFilterMenu.frame.origin.y >= screenHeight - filterMenuHeight {
                let location = pan.location(in: view)
                self.btnMapFilter.frame.origin.y = location.y - spaceFilter
                self.uiviewFilterMenu.frame.origin.y = location.y + spaceMenu
                percent = abs(Double(CGFloat(end - location.y) / filterMenuHeight))
            }
        }
    }
    
    func animateMapFilterArrow() {
        if mapFilterArrow != nil {
            mapFilterArrow.removeFromSuperview()
        }
        mapFilterArrow = UIImageView(frame: CGRect(x: 0, y: screenHeight-55, width: 16, height: 8))
        mapFilterArrow.center.x = screenWidth / 2
        mapFilterArrow.image = #imageLiteral(resourceName: "mapFilterArrow")
        mapFilterArrow.contentMode = .scaleAspectFit
        self.view.addSubview(mapFilterArrow)
        
        UIView.animate(withDuration: 0.75, delay: 0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(5)
            self.mapFilterArrow.frame.origin.y = screenHeight - 60
        }, completion: nil)
        
        UIView.animate(withDuration: 0.583, delay: 6.2, options: [], animations: {
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
        
        refreshMap(pins: true, users: true, places: true)
        
    }
    
    func stopMapFilterSpin() {
        btnMapFilter.layer.removeAllAnimations()
        if polygonInside != nil {
            polygonInside.layer.removeAllAnimations()
        }
        if !didLoadFirstLoad {
            self.filterCircleAnimation()
        }
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            if self.polygonInside != nil {
                self.polygonInside.alpha = 0
            }
            self.btnMapFilter.frame = CGRect(x: screenWidth / 2 - 22, y: screenHeight - 47, width: 44, height: 44)
        }, completion: {(done: Bool) in
            self.btnMapFilter.isEnabled = true
            self.btnMapFilter.transform = CGAffineTransform(rotationAngle: 0)
            if self.polygonInside != nil {
                self.polygonInside.removeFromSuperview()
            }
        })
    }
}
