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
        
        let filterCircle_1 = UIImageView(frame: CGRect.zero)
        filterCircle_1.center = CGPoint(x: 25, y: 23)
        filterCircle_1.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
        btnMapFilter.addSubview(filterCircle_1)
        let filterCircle_2 = UIImageView(frame: CGRect.zero)
        filterCircle_2.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
        filterCircle_2.center = CGPoint(x: 25, y: 23)
        btnMapFilter.addSubview(filterCircle_2)
        let filterCircle_3 = UIImageView(frame: CGRect.zero)
        filterCircle_3.center = CGPoint(x: 25, y: 23)
        filterCircle_3.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
        btnMapFilter.addSubview(filterCircle_3)
        let filterCircle_4 = UIImageView(frame: CGRect.zero)
        filterCircle_4.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
        filterCircle_4.center = CGPoint(x: 25, y: 23)
        btnMapFilter.addSubview(filterCircle_4)
        
        UIView.animate(withDuration: 4, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            filterCircle_1.alpha = 0.0
            filterCircle_1.frame = CGRect(x: 10, y: 9.5, width: 30, height: 30)
        }), completion: nil)
        
        UIView.animate(withDuration: 4, delay: 1, options: [.repeat, .curveEaseIn], animations: ({
            filterCircle_2.alpha = 0.0
            filterCircle_2.frame = CGRect(x: 10, y: 9.5, width: 30, height: 30)
        }), completion: nil)
        
        UIView.animate(withDuration: 4, delay: 2, options: [.repeat, .curveEaseIn], animations: ({
            filterCircle_3.alpha = 0.0
            filterCircle_3.frame = CGRect(x: 10, y: 9.5, width: 30, height: 30)
        }), completion: nil)
        
        UIView.animate(withDuration: 4, delay: 3, options: [.repeat, .curveEaseIn], animations: ({
            filterCircle_4.alpha = 0.0
            filterCircle_4.frame = CGRect(x: 10, y: 9.5, width: 30, height: 30)
        }), completion: nil)
    }
    
    func actionHideFilterMenu(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.uiviewFilterMenu.frame.origin.y = screenHeight
            self.btnMapFilter.center.y = screenHeight - 27
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
                    self.btnMapFilter.center.y = self.sizeTo - 27
                }, completion: nil)
            }
            else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.uiviewFilterMenu.frame.origin.y = self.sizeFrom
                    self.btnMapFilter.center.y = self.sizeFrom - 27
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
        
        if btnMapFilter.center.y != screenHeight - 27 {
            return
        }
        
        btnMapFilter.isEnabled = false
        
        polygonOutside = UIImageView(frame: CGRect(x: 0, y: screenHeight-49, width: 36, height: 40))
        polygonOutside.center.x = screenWidth / 2
        polygonOutside.image = #imageLiteral(resourceName: "mapFilterAnimateOutside")
        polygonOutside.contentMode = .scaleAspectFit
        polygonOutside.layer.shadowColor = UIColor.gray.cgColor
        polygonOutside.layer.shadowOffset = CGSize.zero
        polygonOutside.layer.shadowOpacity = 0.7
        polygonOutside.layer.shadowRadius = 2
        self.view.addSubview(polygonOutside)
        polygonOutside.alpha = 0
        polygonOutside.layer.zPosition = 601
        
        polygonInside = UIImageView(frame: CGRect(x: 0, y: 0, width: 19.41, height: 21.71))
        polygonInside.center.x = screenWidth / 2
        polygonInside.center.y = polygonOutside.center.y
        polygonInside.image = #imageLiteral(resourceName: "mapFilterAnimateInside")
        polygonInside.contentMode = .scaleAspectFit
        self.view.addSubview(polygonInside)
        polygonInside.alpha = 0
        polygonInside.layer.zPosition = 601
        
        if self.mapFilterArrow != nil {
            self.mapFilterArrow.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            self.polygonOutside.alpha = 1
            self.polygonInside.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 0, options: .repeat, animations: {
            self.polygonOutside.transform = CGAffineTransform(rotationAngle: 3.1415926)
            self.polygonInside.transform = CGAffineTransform(rotationAngle: -3.1415926)
        }, completion: nil)
        
        let currentZoomLevel = faeMapView.camera.zoom
        let powFactor: Double = Double(21 - currentZoomLevel)
        let coorDistance: Double = 0.0004*pow(2.0, powFactor)*111
        self.updateTimerForLoadRegionPin(radius: Int(coorDistance*1500))
        self.updateTimerForSelfLoc(radius: Int(coorDistance*1500))
    }
    
    func stopMapFilterSpin() {
        print("[stopMapFilterSpin] outside")
        if polygonInside != nil || polygonOutside != nil {
            polygonOutside.layer.removeAllAnimations()
            polygonInside.layer.removeAllAnimations()
            print("[stopMapFilterSpin] inside")
            UIView.animate(withDuration: 0.583, delay: 0, options: .curveLinear, animations: {
                self.polygonOutside.alpha = 0
                self.polygonInside.alpha = 0
            }, completion: {(done: Bool) in
                self.btnMapFilter.isEnabled = true
                self.polygonInside.removeFromSuperview()
                self.polygonOutside.removeFromSuperview()
                print("[stopMapFilterSpin] complete")
            })
        }
    }
}
