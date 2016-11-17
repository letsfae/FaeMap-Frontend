//
//  PinMenuAnimation.swift
//  faeBeta
//
//  Created by Yue on 10/20/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinMenuViewController {
    private func initialCGRectForButton(_ button: UIButton, x: CGFloat, y: CGFloat) {
        button.frame = CGRect(x: x, y: y, width: 0, height: 0)
    }
    
    private func reCreateCGRectForButton(_ button: UIButton, x: CGFloat, y: CGFloat) {
        let width: CGFloat = 90/414 * screenWidth
        button.frame = CGRect(x: x, y: y, width: width, height: width)
    }
    
    func pinSelectionShowAnimation() {
        // post-animated position of buttons for cool animation
        let buttonOriginX_1: CGFloat = 34/414 * screenWidth
        let buttonOriginX_2: CGFloat = 163/414 * screenWidth
        let buttonOriginX_3: CGFloat = 292/414 * screenWidth
        
        let buttonOriginY_1: CGFloat = 160/736 * screenHeight
        /*
        let buttonOriginY_2: CGFloat = 302/736 * screenHeight
        let buttonOriginY_3: CGFloat = 444/736 * screenHeight
         */
        
        // post-animated position of labels for cool animation
        let labelDiff: CGFloat = 33/736 * screenHeight
        let labelTitleDiff: CGFloat = 66/736 * screenHeight
        
        UIView.animate(withDuration: 0.2, delay: 0.35, options: .transitionFlipFromBottom, animations: {
            self.buttonClosePinBlurView.alpha = 1.0
            self.buttonClosePinBlurView.frame = CGRect(x: 0, y: screenHeight-65, width: screenWidth, height: 65)
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.15, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.labelMenuTitle.center.y -= labelTitleDiff
            self.labelMenuTitle.alpha = 1.0
            self.reCreateCGRectForButton(self.buttonMedia, x: buttonOriginX_1, y: buttonOriginY_1)
            self.labelMenuMedia.center.y += labelDiff
            self.labelMenuMedia.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.25, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonChats, x: buttonOriginX_2, y: buttonOriginY_1)
            self.labelMenuChats.center.y += labelDiff
            self.labelMenuChats.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonComment, x: buttonOriginX_3, y: buttonOriginY_1)
            self.labelMenuComment.center.y += labelDiff
            self.labelMenuComment.alpha = 1.0
            }, completion: nil)
        /*
        UIView.animate(withDuration: 0.883, delay: 0.25, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonEvent, x: buttonOriginX_1, y: buttonOriginY_2)
            self.labelMenuEvent.center.y += labelDiff
            self.labelMenuEvent.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonFaevor, x: buttonOriginX_2, y: buttonOriginY_2)
            self.labelMenuFaevor.center.y += labelDiff
            self.labelMenuFaevor.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.45, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonNow, x: buttonOriginX_3, y: buttonOriginY_2)
            self.labelMenuNow.center.y += labelDiff
            self.labelMenuNow.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonJoinMe, x: buttonOriginX_1, y: buttonOriginY_3)
            self.labelMenuJoinMe.center.y += labelDiff
            self.labelMenuJoinMe.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.45, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonSell, x: buttonOriginX_2, y: buttonOriginY_3)
            self.labelMenuSell.center.y += labelDiff
            self.labelMenuSell.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.55, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonLive, x: buttonOriginX_3, y: buttonOriginY_3)
            self.labelMenuLive.center.y += labelDiff
            self.labelMenuLive.alpha = 1.0
            }, completion: nil)
        */
    }
}
