//
//  MapFilter.swift
//  faeBeta
//
//  Created by Yue Shen on 7/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class MapFilterIcon: UIButton {
    
    var polygonInside: UIImageView!
    
    var filterCircle_1: UIImageView!
    var filterCircle_2: UIImageView!
    var filterCircle_3: UIImageView!
    var filterCircle_4: UIImageView!
    
    var mapFilterArrow: UIImageView!
    
    var boolHideInsides: Bool = false {
        didSet {
            guard filterCircle_1 != nil else { return }
            guard filterCircle_2 != nil else { return }
            guard filterCircle_3 != nil else { return }
            guard filterCircle_4 != nil else { return }
            filterCircle_1.isHidden = boolHideInsides
            filterCircle_2.isHidden = boolHideInsides
            filterCircle_3.isHidden = boolHideInsides
            filterCircle_4.isHidden = boolHideInsides
        }
    }
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        loadMapFilter()
        NotificationCenter.default.addObserver(self, selector: #selector(self.filterCircleAnimation), name: NSNotification.Name(rawValue: "willEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateMapFilterArrow), name: NSNotification.Name(rawValue: "willEnterForeground"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "willEnterForeground"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadMapFilter() {
        setImage(#imageLiteral(resourceName: "mapFilterHexagon"), for: .normal)
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
        center.x = screenWidth / 2
        center.y = screenHeight - 25
        filterCircleAnimation()
        animateMapFilterArrow()
    }
    
    func filterCircleAnimation() {
        
        func createFilterCircle() -> UIImageView {
            let xAxis: CGFloat = 22
            let yAxis: CGFloat = 22
            let imgView = UIImageView(frame: CGRect.zero)
            imgView.center = CGPoint(x: xAxis, y: yAxis)
            imgView.image = #imageLiteral(resourceName: "mapFilterInnerCircle")
            return imgView
        }
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
        filterCircle_1 = createFilterCircle()
        addSubview(filterCircle_1)
        filterCircle_2 = createFilterCircle()
        addSubview(filterCircle_2)
        filterCircle_3 = createFilterCircle()
        addSubview(filterCircle_3)
        filterCircle_4 = createFilterCircle()
        addSubview(filterCircle_4)
        
        let animateTime: Double = 4
        let radius: CGFloat = 50
        let xAxisAfter: CGFloat = -3
        let newFrame = CGRect(x: xAxisAfter, y: xAxisAfter, width: radius, height: radius)
        
        UIView.animate(withDuration: animateTime, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            self.filterCircle_1.alpha = 0.0
            self.filterCircle_1.frame = newFrame
        }), completion: nil)
        
        UIView.animate(withDuration: animateTime, delay: 1, options: [.repeat, .curveEaseIn], animations: ({
            self.filterCircle_2.alpha = 0.0
            self.filterCircle_2.frame = newFrame
        }), completion: nil)
        
        UIView.animate(withDuration: animateTime, delay: 2, options: [.repeat, .curveEaseIn], animations: ({
            self.filterCircle_3.alpha = 0.0
            self.filterCircle_3.frame = newFrame
        }), completion: nil)
        
        UIView.animate(withDuration: animateTime, delay: 3, options: [.repeat, .curveEaseIn], animations: ({
            self.filterCircle_4.alpha = 0.0
            self.filterCircle_4.frame = newFrame
        }), completion: nil)
    }
    
    func stopIconSpin() {
        layer.removeAllAnimations()
        if polygonInside != nil {
            polygonInside.layer.removeAllAnimations()
        }
        boolHideInsides = false
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            if self.polygonInside != nil {
                self.polygonInside.alpha = 0
            }
            if self.center.y == screenHeight - 25 {
                self.frame = CGRect(x: screenWidth / 2 - 22, y: screenHeight - 47, width: 44, height: 44)
                return
            }
        }, completion: { _ in
            self.isEnabled = true
            self.transform = CGAffineTransform(rotationAngle: 0)
            if self.polygonInside != nil {
                self.polygonInside.removeFromSuperview()
            }
        })
    }
    
    func startIconSpin() {
        
        if center.y != screenHeight - 25 {
            return
        }
        
        self.isEnabled = false
        
        polygonInside = UIImageView(frame: CGRect(x: 0, y: 0, width: 19.41, height: 21.71))
        polygonInside.center = CGPoint(x: 22, y: 22)
        polygonInside.image = #imageLiteral(resourceName: "mapFilterAnimateInside")
        polygonInside.contentMode = .scaleAspectFit
        addSubview(polygonInside)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.frame = CGRect(x: screenWidth / 2 - 25, y: screenHeight - 50, width: 50, height: 50)
            self.polygonInside.center = CGPoint(x: 25, y: 25)
        }, completion: nil)
        
        if mapFilterArrow != nil {
            mapFilterArrow.removeFromSuperview()
        }
        
        boolHideInsides = true
        
        UIView.animate(withDuration: 1, delay: 0, options: .repeat, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            self.polygonInside.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * 0.999))
        }, completion: nil)
    }
    
    func animateMapFilterArrow() {
        
        if mapFilterArrow != nil {
            mapFilterArrow.removeFromSuperview()
        }
        
        mapFilterArrow = UIImageView(frame: CGRect(x: 0, y: -8, width: 16, height: 8))
        mapFilterArrow.center.x = 22
        mapFilterArrow.image = #imageLiteral(resourceName: "mapFilterArrow")
        mapFilterArrow.contentMode = .scaleAspectFit
        addSubview(mapFilterArrow)
        
        UIView.animate(withDuration: 0.75, delay: 0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(5)
            self.mapFilterArrow.frame.origin.y = -13
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 6.2, options: [], animations: {
            self.mapFilterArrow.alpha = 0
        }, completion: { _ in
            if self.mapFilterArrow != nil {
                self.mapFilterArrow.removeFromSuperview()
            }
        })
    }
}
