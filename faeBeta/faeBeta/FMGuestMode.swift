//
//  FMGuestMode.swift
//  faeBeta
//
//  Created by Yue on 12/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    func guestMode() {
        let uiViewGuestMode = UIView(frame: CGRect(x: 62, y: 155, w: 290, h: 380))
        uiViewGuestMode.backgroundColor = UIColor.white
        uiViewGuestMode.layer.cornerRadius = 16 * screenWidthFactor
        self.view.addSubview(uiViewGuestMode)
        
        let labelTitleGuest = UILabel(frame: CGRect(x: 73, y: 27, w: 144, h: 44))
        labelTitleGuest.text = "You are currently in\n Guest Mode!"
        labelTitleGuest.numberOfLines = 0
        labelTitleGuest.textAlignment = .center
        labelTitleGuest.textColor = UIColor._898989()
        labelTitleGuest.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        uiViewGuestMode.addSubview(labelTitleGuest)
        
        let imageAvatarGuest = UIImageView(frame: CGRect(x: 55, y: 101, w: 180, h: 139))
        imageAvatarGuest.image = UIImage(named: "GuestMode")
        uiViewGuestMode.addSubview(imageAvatarGuest)
        
        let buttonGuestLogIn = UIButton(frame: CGRect(x: 40, y: 263, w: 210, h: 40))
        buttonGuestLogIn.setTitle("Log In", for: .normal)
        buttonGuestLogIn.layer.cornerRadius = 20 * screenWidthFactor
        buttonGuestLogIn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        buttonGuestLogIn.backgroundColor = UIColor._2499090()
        buttonGuestLogIn.addTarget(self, action: #selector(buttonGuestLogInClicked(_:)), for: .touchUpInside)
        uiViewGuestMode.addSubview(buttonGuestLogIn)
        
        let buttonGuestCreateCount = UIButton(frame: CGRect(x: 40, y: 315, w: 210, h: 40))
        buttonGuestCreateCount.setTitle("Create a Fae Count", for: .normal)
        buttonGuestCreateCount.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        buttonGuestCreateCount.setTitleColor(UIColor._2499090(), for: .normal)
        // buttonGuestCreateCount.titleLabel?.textColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0) 改变不了button title的颜色
        buttonGuestCreateCount.layer.borderColor = UIColor._2499090().cgColor
        buttonGuestCreateCount.layer.cornerRadius = 20 * screenWidthFactor
        buttonGuestCreateCount.backgroundColor = UIColor.white
        buttonGuestCreateCount.layer.borderWidth = 2.5
        buttonGuestCreateCount.addTarget(self, action: #selector(buttonGuestCreateCountClicked(_:)), for: .touchUpInside)
        uiViewGuestMode.addSubview(buttonGuestCreateCount)
    }
    
    func buttonGuestLogInClicked(_ sender: UIButton) {
        print("guest log in")
    }
    
    func buttonGuestCreateCountClicked(_ sender: UIButton) {
        print("Create an account")
    }
}
