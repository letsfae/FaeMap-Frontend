//
//  FMSelfPositionAnimation.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension FaeMapViewController {
    func loadPositionAnimateImage() {
        if myPositionIconFirstLoaded {
            myPositionIconFirstLoaded = false
        }
        else {
            if myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.removeFromSuperview()
            }
            if myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.removeFromSuperview()
            }
            if myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.removeFromSuperview()
            }
            if myPositionIcon != nil {
                self.myPositionIcon.removeFromSuperview()
            }
        }
        if userStatus == 5 {
            self.faeMapView.isMyLocationEnabled = true
            if myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.isHidden = true
            }
            if myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.isHidden = true
            }
            if myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.isHidden = true
            }
            if myPositionIcon != nil {
                self.myPositionIcon.isHidden = true
            }
            return
        }
        else {
            self.faeMapView.isMyLocationEnabled = false
            if self.myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.isHidden = false
            }
            if self.myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.isHidden = false
            }
            if self.myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.isHidden = false
            }
            if self.myPositionIcon != nil {
                self.myPositionIcon.isHidden = false
            }
        }
        myPositionOutsideMarker_1 = UIImageView(frame: CGRect(x: screenWidth/2-12, y: screenHeight/2-12, width: 24, height: 24))
        myPositionOutsideMarker_2 = UIImageView(frame: CGRect(x: screenWidth/2-12, y: screenHeight/2-12, width: 24, height: 24))
        myPositionOutsideMarker_3 = UIImageView(frame: CGRect(x: screenWidth/2-12, y: screenHeight/2-12, width: 24, height: 24))
        self.view.addSubview(myPositionOutsideMarker_1)
        myPositionOutsideMarker_1.layer.zPosition = 0
        self.view.addSubview(myPositionOutsideMarker_2)
        myPositionOutsideMarker_2.layer.zPosition = 0
        self.view.addSubview(myPositionOutsideMarker_3)
        myPositionOutsideMarker_3.layer.zPosition = 0
        myPositionIcon = UIButton(frame: CGRect(x: screenWidth/2-22, y: screenHeight/2-22, width: 44, height: 44))
        myPositionIcon.adjustsImageWhenHighlighted = false
        self.myPositionIcon.isHidden = true
        self.myPositionOutsideMarker_1.isHidden = true
        self.myPositionOutsideMarker_2.isHidden = true
        self.myPositionOutsideMarker_3.isHidden = true
        //        myPositionIcon.addTarget(self, action: #selector(FaeMapViewController.showOpenUserPinAnimation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(myPositionIcon)
        myPositionIcon.layer.zPosition = 0
        myPositionAnimation()
    }
    
    func myPositionAnimation() {
        UIView.animate(withDuration: 2.4, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.alpha = 0.0
                self.myPositionOutsideMarker_1.frame = CGRect(x: self.screenWidth/2-60, y: self.screenHeight/2-60, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_1 != nil {
                
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 0.8, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.alpha = 0.0
                self.myPositionOutsideMarker_2.frame = CGRect(x: self.screenWidth/2-60, y: self.screenHeight/2-60, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 2.3, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_2 != nil {
                
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 1.6, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.alpha = 0.0
                self.myPositionOutsideMarker_3.frame = CGRect(x: self.screenWidth/2-60, y: self.screenHeight/2-60, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 3.1, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_3 != nil {
                
            }
        }), completion: nil)
    }
    
    // Get self avatar on map
    func getSelfAccountInfo() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({(status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            let selfUserInfoJSON = JSON(message!)
            if let firstName = selfUserInfoJSON["first_name"].string {
                userFirstname = firstName
            }
            if let lastName = selfUserInfoJSON["last_name"].string {
                userLastname = lastName
            }
            if let birthday = selfUserInfoJSON["birthday"].string {
                userBirthday = birthday
            }
            if let gender = selfUserInfoJSON["gender"].string {
                userUserGender = gender
            }
            if let userName = selfUserInfoJSON["user_name"].string {
                userUserName = userName
            }
            if let miniAvatar = selfUserInfoJSON["mini_avatar"].int {
                if userStatus == 5 {
                    return
                }
                userMiniAvatar = miniAvatar
                self.myPositionOutsideMarker_1.image = UIImage(named: "myPosition_outside")
                self.myPositionOutsideMarker_2.image = UIImage(named: "myPosition_outside")
                self.myPositionOutsideMarker_3.image = UIImage(named: "myPosition_outside")
                if let miniAvatar = userMiniAvatar {
                    self.myPositionIcon.setImage(UIImage(named: "mapAvatar_\(miniAvatar+1)"), for: UIControlState())
                }
                else {
                    self.myPositionIcon.setImage(UIImage(named: "mapAvatar_1"), for: UIControlState())
                }
            }
        })
    }
}
