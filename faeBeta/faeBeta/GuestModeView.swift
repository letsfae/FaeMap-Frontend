//
//  GuestModeView.swift
//  faeBeta
//
//  Created by Yue Shen on 7/10/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class GuestModeView: UIView {
    
    var dismissGuestMode: (() -> ())?
    var guestLogin: (() -> ())?
    var guestRegister: (() -> ())?
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        self.frame = CGRect(x: 62, y: 155, w: 290, h: 380)
        loadGuestMode()
        self.layer.zPosition = 3000
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadGuestMode() {
        let uiviewGuestMode = UIView(frame: CGRect(x: 0, y: 0, w: 290, h: 380))
        uiviewGuestMode.backgroundColor = UIColor.white
        uiviewGuestMode.layer.cornerRadius = 16 * screenWidthFactor
        addSubview(uiviewGuestMode)
        
        let lblGuestModeTitle = UILabel(frame: CGRect(x: 73, y: 27, w: 144, h: 44))
        lblGuestModeTitle.text = "You are currently in\n Guest Mode!"
        lblGuestModeTitle.numberOfLines = 0
        lblGuestModeTitle.textAlignment = .center
        lblGuestModeTitle.textColor = UIColor._898989()
        lblGuestModeTitle.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        uiviewGuestMode.addSubview(lblGuestModeTitle)
        
        let imgGuestMode = UIImageView(frame: CGRect(x: 55, y: 101, w: 180, h: 139))
        imgGuestMode.image = UIImage(named: "GuestMode")
        uiviewGuestMode.addSubview(imgGuestMode)
        
        let btnGuestModeLogIn = UIButton(frame: CGRect(x: 40, y: 263, w: 210, h: 40))
        btnGuestModeLogIn.setTitle("Log In", for: .normal)
        btnGuestModeLogIn.layer.cornerRadius = 20 * screenWidthFactor
        btnGuestModeLogIn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        btnGuestModeLogIn.backgroundColor = UIColor._2499090()
        btnGuestModeLogIn.addTarget(self, action: #selector(actionGuestLogin(_:)), for: .touchUpInside)
        uiviewGuestMode.addSubview(btnGuestModeLogIn)
        
        let btnGuestModeCreateAccount = UIButton(frame: CGRect(x: 40, y: 315, w: 210, h: 40))
        btnGuestModeCreateAccount.setTitle("Create a Fae Count", for: .normal)
        btnGuestModeCreateAccount.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        btnGuestModeCreateAccount.setTitleColor(UIColor._2499090(), for: .normal)
        // buttonGuestCreateCount.titleLabel?.textColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0) 改变不了button title的颜色
        btnGuestModeCreateAccount.layer.borderColor = UIColor._2499090().cgColor
        btnGuestModeCreateAccount.layer.cornerRadius = 20 * screenWidthFactor
        btnGuestModeCreateAccount.backgroundColor = UIColor.white
        btnGuestModeCreateAccount.layer.borderWidth = 2.5
        btnGuestModeCreateAccount.addTarget(self, action: #selector(actionGuestCreateAccount(_:)), for: .touchUpInside)
        uiviewGuestMode.addSubview(btnGuestModeCreateAccount)
    }
    
    @objc private func actionGuestLogin(_ sender: UIButton) {
        print("guest log in")
    }
    
    @objc private func actionGuestCreateAccount(_ sender: UIButton) {
        print("Create an account")
    }
}
