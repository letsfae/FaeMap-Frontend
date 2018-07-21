//
//  BoardAvatarWaves.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-20.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class BoardAvatarWaves: UIView {
    fileprivate var imgAvatar: FaeAvatarView!
    fileprivate var filterCircle_1: UIImageView!
    fileprivate var filterCircle_2: UIImageView!
    fileprivate var filterCircle_3: UIImageView!
    fileprivate var filterCircle_4: UIImageView!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 114))
        backgroundColor = .white
        loadAvatar()
        loadWaves()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadAvatar() {
        let xAxis: CGFloat = screenWidth / 2
        let yAxis: CGFloat = (screenHeight - 114 - device_offset_top - device_offset_bot) / 2
//        yAxis += screenHeight == 812 ? 80 : 0
        center = CGPoint(x: xAxis, y: yAxis)
        alpha = 0
        
        let imgAvatarSub = UIImageView(frame: CGRect(x: 0, y: 0, width: 98, height: 98))
        imgAvatarSub.contentMode = .scaleAspectFill
        imgAvatarSub.image = #imageLiteral(resourceName: "exp_avatar_border")
        imgAvatarSub.center = CGPoint(x: xAxis, y: xAxis)
        addSubview(imgAvatarSub)
        
        imgAvatar = FaeAvatarView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        imgAvatar.layer.cornerRadius = 43
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.center = CGPoint(x: xAxis, y: xAxis)
        imgAvatar.isUserInteractionEnabled = false
        imgAvatar.clipsToBounds = true
        addSubview(imgAvatar)
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
        addSubview(filterCircle_1)
        addSubview(filterCircle_2)
        addSubview(filterCircle_3)
        addSubview(filterCircle_4)
        sendSubview(toBack: filterCircle_1)
        sendSubview(toBack: filterCircle_2)
        sendSubview(toBack: filterCircle_3)
        sendSubview(toBack: filterCircle_4)
        
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
        self.alpha = 1
        loadWaves()
//        UIView.animate(withDuration: 0.3, animations: {
//            self.alpha = 1
//        })
    }
    
    func hideWaves() {
        UIView.animate(withDuration: 0, delay: 1, options: .curveEaseOut, animations: {
//        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        })
    }
}
