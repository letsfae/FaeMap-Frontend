//
//  PDAnimations.swift
//  faeBeta
//
//  Created by Yue on 5/2/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension PinDetailViewController {
    
    func animateHeart() {
        btnPinLike.tag = 0
        animatingHeart = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 22))
        animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        animatingHeart.layer.zPosition = 108
        uiviewInteractBtnSub.addSubview(animatingHeart)
        
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        let transform: CGAffineTransform = CGAffineTransform(translationX: btnPinLike.center.x, y: btnPinLike.center.y)
        let path =  CGMutablePath()
        path.move(to: CGPoint(x:0,y:0), transform: transform)
        path.addLine(to: CGPoint(x:randomX-75, y:-randomY), transform: transform)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue(caTransform3D: CATransform3DMakeScale(randomSize, randomSize, 1))]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.duration = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.3
        fadeAnimation.beginTime = CACurrentMediaTime() + 0.72
        
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = path
        orbit.calculationMode = kCAAnimationPaced
        animatingHeart.layer.add(orbit, forKey:"Move")
        animatingHeart.layer.add(fadeAnimation, forKey: "Opacity")
        animatingHeart.layer.add(scaleAnimation, forKey: "Scale")
        animatingHeart.layer.position = CGPoint(x: btnPinLike.center.x, y: btnPinLike.center.y)
    }
    
    func animatePinCtrlBtnsAndFeeling() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.btnGrayBackToMap.alpha = 1
            self.btnNextPin.alpha = 1
            self.btnPrevPin.alpha = 1
            self.imgPinIcon.alpha = 1
            
            self.uiviewMain.frame.origin.x = 0
            self.uiviewMain.frame.origin.y = 0
            
            self.uiviewInputToolBarSub.frame.origin.x = 0
        }, completion: { (_) in
            if PinDetailViewController.pinTypeEnum != .place {
                self.delegate?.changeIconImage()
            }
        })
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            if PinDetailViewController.pinTypeEnum == .comment || PinDetailViewController.pinTypeEnum == .media {
                self.uiviewFeelingBar.frame = CGRect(x: (screenWidth-281)/2, y: 409*screenHeightFactor, width: 281*screenWidthFactor, height: 52*screenWidthFactor)
                let yAxis = 11 * screenHeightFactor
                let width = 32 * screenHeightFactor
                for i in 0..<self.btnFeelingArray.count {
                    self.btnFeelingArray[i].frame = CGRect(x: CGFloat(20+52*i), y: yAxis, width: width, height: width)
                }
            }
            self.btnPrevPin.frame = CGRect(x: 15*screenHeightFactor, y: 477*screenHeightFactor, width: 52*screenHeightFactor, height: 52*screenHeightFactor)
            self.btnNextPin.frame = CGRect(x: 347*screenHeightFactor, y: 477*screenHeightFactor, width: 52*screenHeightFactor, height: 52*screenHeightFactor)
        }, completion: {(_) in
            self.checkCurUserFeeling()
        })
    }
    
    fileprivate func checkCurUserFeeling() {
        if PinDetailViewController.pinTypeEnum != .comment && PinDetailViewController.pinTypeEnum != .media {
            return
        }
        let getPinById = FaeMap()
        getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) {(status: Int, message: Any?) in
            let pinInfoJSON = JSON(message!)
            // Has posted feeling or not
            if let chosenFeel = pinInfoJSON["user_pin_operations"]["feeling"].int {
                self.intChosenFeeling = chosenFeel
                if chosenFeel < 5 && chosenFeel >= 0 {
                    UIView.animate(withDuration: 0.2, animations: {
                        let xOffset = Int(chosenFeel * 52 + 12)
                        self.btnFeelingArray[chosenFeel].frame = CGRect(x: xOffset, y: 3, width: 48, height: 48)
                    })
                }
            } else {
                self.intChosenFeeling = -1
            }
        }
    }
}
