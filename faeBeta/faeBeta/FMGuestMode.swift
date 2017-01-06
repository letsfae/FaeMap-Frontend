//
//  FMGuestMode.swift
//  faeBeta
//
//  Created by Yue on 12/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    func guestMode()    {
        let uiViewGuestMode = UIView(frame:CGRect(x: 62*screenWidthFactor, y: 155*screenWidthFactor, width: 290*screenWidthFactor, height: 380*screenWidthFactor))
        uiViewGuestMode.backgroundColor = UIColor.white
        uiViewGuestMode.layer.cornerRadius = 16*screenWidthFactor
        self.view.addSubview(uiViewGuestMode)
        
        let labelTitleGuest = UILabel(frame: CGRect(x: 73*screenWidthFactor, y: 27*screenWidthFactor, width: 144*screenWidthFactor, height: 44*screenWidthFactor))
        labelTitleGuest.text = "You are currently in\n Guest Mode!"
        labelTitleGuest.numberOfLines = 0
        labelTitleGuest.textAlignment = NSTextAlignment.center
        labelTitleGuest.textColor = UIColor(red: 89/255, green: 89.0/255, blue: 89.0/255, alpha: 1.0)
        labelTitleGuest.font = UIFont(name: "AvenirNext-Medium",size: 16*screenWidthFactor)
        uiViewGuestMode.addSubview(labelTitleGuest)
        
        let imageAvatarGuest = UIImageView(frame: CGRect(x: 55*screenWidthFactor, y: 101*screenWidthFactor, width: 180*screenWidthFactor, height: 139*screenWidthFactor))
        imageAvatarGuest.image = UIImage(named: "GuestMode")
        uiViewGuestMode.addSubview(imageAvatarGuest)
        
        let buttonGuestLogIn = UIButton(frame: CGRect(x: 40*screenWidthFactor, y: 263*screenWidthFactor, width:210*screenWidthFactor, height: 40*screenWidthFactor))
        buttonGuestLogIn.setTitle("Log In", for: .normal)
        buttonGuestLogIn.layer.cornerRadius = 20*screenWidthFactor
        buttonGuestLogIn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16*screenWidthFactor)
        buttonGuestLogIn.backgroundColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        buttonGuestLogIn.addTarget(self, action: #selector(self.buttonGuestLogInClicked(_:)), for: .touchUpInside)
        uiViewGuestMode.addSubview(buttonGuestLogIn)
        
        let buttonGuestCreateCount = UIButton(frame: CGRect(x: 40*screenWidthFactor, y: 315*screenWidthFactor, width: 210*screenWidthFactor, height: 40*screenWidthFactor))
        buttonGuestCreateCount.setTitle("Create a Fae Count", for: .normal)
        buttonGuestCreateCount.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 16*screenWidthFactor)
        buttonGuestCreateCount.setTitleColor(UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0), for: .normal)
        //buttonGuestCreateCount.titleLabel?.textColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0) 改变不了button title的颜色
        buttonGuestCreateCount.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).cgColor
        buttonGuestCreateCount.layer.cornerRadius = 20*screenWidthFactor
        buttonGuestCreateCount.backgroundColor = UIColor.white
        buttonGuestCreateCount.layer.borderWidth = 2.5
        buttonGuestCreateCount.addTarget(self, action: #selector(self.buttonGuestCreateCountClicked(_:)), for: .touchUpInside)
        uiViewGuestMode.addSubview(buttonGuestCreateCount)
    }
    
    func buttonGuestLogInClicked(_ sender: UIButton) {
        print("guest log in")
    }
    func buttonGuestCreateCountClicked(_ sender: UIButton) {
        print("Create an account")
    }
}
