//
//  MBLoadingWaves.swift
//  faeBeta
//
//  Created by Yue Shen on 2/27/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
/*
extension MapBoardViewController {
    
    func loadAvatar() {
        let xAxis: CGFloat = screenWidth / 2
        var yAxis: CGFloat = 324.5 * screenHeightFactor
        yAxis += screenHeight == 812 ? 80 : 0
        
        uiviewAvatarWaveSub = UIView(frame: CGRect(x: 0, y: 114, width: screenWidth, height: screenWidth))
        uiviewAvatarWaveSub.center = CGPoint(x: xAxis, y: yAxis)
        uiviewAvatarWaveSub.alpha = 0
        view.addSubview(uiviewAvatarWaveSub)
        
        let imgAvatarSub = UIImageView(frame: CGRect(x: 0, y: 0, width: 98, height: 98))
        imgAvatarSub.contentMode = .scaleAspectFill
        imgAvatarSub.image = #imageLiteral(resourceName: "exp_avatar_border")
        imgAvatarSub.center = CGPoint(x: xAxis, y: xAxis)
        uiviewAvatarWaveSub.addSubview(imgAvatarSub)
        
        imgAvatar = FaeAvatarView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        imgAvatar.layer.cornerRadius = 43
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.center = CGPoint(x: xAxis, y: xAxis)
        imgAvatar.isUserInteractionEnabled = false
        imgAvatar.clipsToBounds = true
        uiviewAvatarWaveSub.addSubview(imgAvatar)
        imgAvatar.userID = Key.shared.user_id
        imgAvatar.loadAvatar(id: Key.shared.user_id)
    }
    
    func loadWaves() {
        func createFilterCircle() -> UIImageView {
            let xAxis: CGFloat = screenWidth / 2
            let imgView = UIImageView(frame: CGRect.zero)
            imgView.frame.size = CGSize(width: 98, height: 98)
            imgView.center = CGPoint(x: xAxis, y: xAxis)
            imgView.image = #imageLiteral(resourceName: "exp_wave")
            imgView.tag = 0
            return imgView
        }
        if filterCircle_1 != nil {
            filterCircle_1.removeFromSuperview()
            filterCircle_2.removeFromSuperview()
            filterCircle_3.removeFromSuperview()
            filterCircle_4.removeFromSuperview()
        }
        filterCircle_1 = createFilterCircle()
        filterCircle_2 = createFilterCircle()
        filterCircle_3 = createFilterCircle()
        filterCircle_4 = createFilterCircle()
        uiviewAvatarWaveSub.addSubview(filterCircle_1)
        uiviewAvatarWaveSub.addSubview(filterCircle_2)
        uiviewAvatarWaveSub.addSubview(filterCircle_3)
        uiviewAvatarWaveSub.addSubview(filterCircle_4)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_1)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_2)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_3)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_4)
        
        waveAnimation(circle: filterCircle_1, delay: 0)
        waveAnimation(circle: filterCircle_2, delay: 0.5)
        waveAnimation(circle: filterCircle_3, delay: 2)
        waveAnimation(circle: filterCircle_4, delay: 2.5)
    }
    
    func waveAnimation(circle: UIImageView, delay: Double) {
        let animateTime: Double = 3
        let radius: CGFloat = screenWidth
        let newFrame = CGRect(x: 0, y: 0, width: radius, height: radius)
        
        let xAxis: CGFloat = screenWidth / 2
        circle.frame.size = CGSize(width: 98, height: 98)
        circle.center = CGPoint(x: xAxis, y: xAxis)
        circle.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: animateTime, delay: 0, options: [.curveEaseOut], animations: ({
                circle.alpha = 0.0
                circle.frame = newFrame
            }), completion: { _ in
                self.waveAnimation(circle: circle, delay: 0.75)
            })
        }
    }
    
    func showWaves() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.tblPeople != nil {
                self.tblPeople.alpha = 0
            }
            self.uiviewAvatarWaveSub.alpha = 1
        })
    }
    
    func hideWaves(count: Int) {
        UIView.animate(withDuration: 0.3, animations: {
            self.uiviewAvatarWaveSub.alpha = 0
            if count == 0 {   // self.mbPeople.count == 0
                self.tblPeople.alpha = 0
            } else {
                self.tblPeople.alpha = 1
            }
        })
    }
}
 */
