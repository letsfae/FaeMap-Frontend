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
    
    func loadSelfMarker() {
        
        self.subviewSelfMarker = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        
        selfMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        selfMarkerIcon.contentMode = .scaleAspectFit
        let point = CGPoint(x: 60, y: 60)
        selfMarkerIcon.center = point
        
        myPositionCircle_1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_1.center = point
        myPositionCircle_2.center = point
        myPositionCircle_3.center = point
        
        self.subviewSelfMarker.addSubview(myPositionCircle_3)
        self.subviewSelfMarker.addSubview(myPositionCircle_2)
        self.subviewSelfMarker.addSubview(myPositionCircle_1)
        self.subviewSelfMarker.addSubview(selfMarkerIcon)
        
        selfMarker.iconView = subviewSelfMarker
        selfMarker.position.latitude = currentLatitude
        selfMarker.position.longitude = currentLongitude
        selfMarker.map = faeMapView
        selfMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        selfMarkerAnimation()
    }
    
    func selfMarkerAnimation() {
        UIView.animate(withDuration: 2.4, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_1 != nil {
                self.myPositionCircle_1.alpha = 0.0
                self.myPositionCircle_1.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 0.8, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_2 != nil {
                self.myPositionCircle_2.alpha = 0.0
                self.myPositionCircle_2.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 1.6, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_3 != nil {
                self.myPositionCircle_3.alpha = 0.0
                self.myPositionCircle_3.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
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
                print("[getSelfAccountInfo] gender: \(gender)")
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
//                self.myPositionOutsideMarker_1.image = UIImage(named: "myPosition_outside")
//                self.myPositionOutsideMarker_2.image = UIImage(named: "myPosition_outside")
//                self.myPositionOutsideMarker_3.image = UIImage(named: "myPosition_outside")
                self.myPositionCircle_1.image = UIImage(named: "myPosition_outside")
                self.myPositionCircle_2.image = UIImage(named: "myPosition_outside")
                self.myPositionCircle_3.image = UIImage(named: "myPosition_outside")
                if let miniAvatar = userMiniAvatar {
//                    self.myPositionIcon.setImage(UIImage(named: "miniAvatar_\(miniAvatar+1)"), for: UIControlState())
                    self.selfMarkerIcon.image = UIImage(named: "miniAvatar_\(miniAvatar+1)")
                }
                else {
//                    self.myPositionIcon.setImage(UIImage(named: "miniAvatar_1"), for: UIControlState())
                    self.selfMarkerIcon.image = UIImage(named: "miniAvatar_\(miniAvatar+1)")
                }
            }
        })
    }
    /*
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
        self.myPositionIcon.addTarget(self, action: #selector(self.getSelfNameCard(_:)), for: .touchUpInside)
        self.view.addSubview(myPositionIcon)
        myPositionIcon.layer.zPosition = 0
        myPositionAnimation()
    }
    
    func myPositionAnimation() {
        UIView.animate(withDuration: 2.4, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_1 != nil {
                self.myPositionOutsideMarker_1.alpha = 0.0
                self.myPositionOutsideMarker_1.frame = CGRect(x: screenWidth/2-60, y: screenHeight/2-60, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_1 != nil {
                
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 0.8, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_2 != nil {
                self.myPositionOutsideMarker_2.alpha = 0.0
                self.myPositionOutsideMarker_2.frame = CGRect(x: screenWidth/2-60, y: screenHeight/2-60, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 2.3, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_2 != nil {
                
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 1.6, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_3 != nil {
                self.myPositionOutsideMarker_3.alpha = 0.0
                self.myPositionOutsideMarker_3.frame = CGRect(x: screenWidth/2-60, y: screenHeight/2-60, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 3.1, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionOutsideMarker_3 != nil {
                
            }
        }), completion: nil)
    }
     */
}
