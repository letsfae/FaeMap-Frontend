//
//  FMMapNameCard.swift
//  faeBeta
//
//  Created by Yue on 12/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    
    func loadNameCard() {
        uiViewNameCard = UIView(frame: CGRect(x: 73*screenWidthFactor, y: 158*screenWidthFactor, width:268*screenWidthFactor, height: 293*screenWidthFactor))
        imageBackground = UIImageView(frame: CGRect(x: 0*screenWidthFactor, y: 0*screenWidthFactor, width:268*screenWidthFactor, height: 293*screenWidthFactor))
        imageBackground.image = UIImage(named: "NameCard")
        imageBackground.contentMode = UIViewContentMode.scaleAspectFit
        uiViewNameCard.addSubview(imageBackground)
        uiViewNameCard.layer.shadowColor = UIColor.gray.cgColor
        uiViewNameCard.layer.shadowOffset = CGSize.zero
        uiViewNameCard.layer.shadowOpacity = 1
        uiViewNameCard.layer.shadowRadius = 25
        self.view.addSubview(uiViewNameCard)
        uiViewNameCard.alpha = 0
        
        imageCover = UIImageView(frame: CGRect(x: 0, y:0, width:268*screenWidthFactor, height: 125*screenWidthFactor))
        imageCover.image = UIImage(named: "Cover")
        self.uiViewNameCard.addSubview(imageCover)
        
        imageAvatarNameCard = UIImageView(frame: CGRect(x: 103*screenWidthFactor, y: 88*screenWidthFactor, width: 62*screenWidthFactor, height: 62*screenWidthFactor))
        imageAvatarNameCard.image = UIImage(named: "AvatarMen")
        self.uiViewNameCard.addSubview(imageAvatarNameCard)
        
        imageGenderMen = UIImageView(frame: CGRect(x: 15*screenWidthFactor, y: 134*screenWidthFactor, width: 28*screenWidthFactor, height: 18*screenWidthFactor))
        imageGenderMen.image = UIImage(named: "GenderMen")
        self.uiViewNameCard.addSubview(imageGenderMen)
        
        buttonTalk = UIButton(frame: CGRect(x: 221*screenWidthFactor, y: 134*screenWidthFactor, width: 32*screenWidthFactor, height: 18*screenWidthFactor))
        buttonTalk.setImage(UIImage(named: "Talk"), for: .normal)
        self.uiViewNameCard.addSubview(buttonTalk)
        
        labelTitle = UILabel(frame: CGRect(x: 41*screenWidthFactor, y: 165*screenWidthFactor, width: 186*screenWidthFactor, height: 25*screenWidthFactor))
        labelTitle.text = "LinLinLinLinLinLinLinLin"
        labelTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 18*screenWidthFactor)
        labelTitle.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.uiViewNameCard.addSubview(labelTitle)
        
        labelChat = UILabel(frame: CGRect(x: 49*screenWidthFactor, y: 191*screenWidthFactor, width: 171*screenWidthFactor, height: 18*screenWidthFactor))
        labelChat.text = "Let’s Chat Let’s Chat Let’s Chat"
        labelChat.font = UIFont(name: "AvenirNext-Medium", size: 13*screenWidthFactor)
        labelChat.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
        self.uiViewNameCard.addSubview(labelChat)
        
        imageOneLine = UIImageView(frame: CGRect(x: 0*screenWidthFactor, y: 222.5*screenWidthFactor, width: 268*screenWidthFactor, height: 1*screenWidthFactor))
        imageOneLine.backgroundColor = UIColor(red: 206/255, green: 203/255, blue: 203/255, alpha: 1.0)
        self.uiViewNameCard.addSubview(imageOneLine)
        
        buttonFavorite = UIButton(frame: CGRect(x: 43*screenWidthFactor, y: 235*screenWidthFactor, width: 27*screenWidthFactor, height: 27*screenWidthFactor))
        buttonFavorite.setImage(UIImage(named: "Favorite"), for: .normal)
        self.uiViewNameCard.addSubview(buttonFavorite)
        
        buttonInfo = UIButton(frame: CGRect(x: 120.5*screenWidthFactor, y: 235*screenWidthFactor, width: 27*screenWidthFactor, height: 27*screenWidthFactor))
        buttonInfo.setImage(UIImage(named: "Info"), for: .normal)
        self.uiViewNameCard.addSubview(buttonInfo)
        
        buttonEmoji = UIButton(frame: CGRect(x: 198*screenWidthFactor, y: 235*screenWidthFactor, width: 27*screenWidthFactor, height: 27*screenWidthFactor))
        buttonEmoji.setImage(UIImage(named: "Emoji"), for: .normal)
        self.uiViewNameCard.addSubview(buttonEmoji)
    }
    
    func invisibleMode() {
        let dimBackgroundInvisibleMode = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dimBackgroundInvisibleMode.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        dimBackgroundInvisibleMode.alpha = 0
        dimBackgroundInvisibleMode.layer.zPosition = 599
        self.view.addSubview(dimBackgroundInvisibleMode)
        dimBackgroundInvisibleMode.addTarget(self, action: #selector(FaeMapViewController.invisibleModeDimClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let uiViewInvisibleMode = UIView(frame:CGRect(x: 62*screenWidthFactor, y: 155*screenWidthFactor, width: 290*screenWidthFactor, height: 380*screenWidthFactor))
        uiViewInvisibleMode.backgroundColor = UIColor.white
        uiViewInvisibleMode.layer.cornerRadius = 16*screenWidthFactor
        dimBackgroundInvisibleMode.addSubview(uiViewInvisibleMode)
        
        let labelTitleInvisible = UILabel(frame: CGRect(x: 73*screenWidthFactor, y: 27*screenWidthFactor, width: 144*screenWidthFactor, height: 44*screenWidthFactor))
        labelTitleInvisible.text = "You're now in\n Invisible Mode!"
        labelTitleInvisible.font = UIFont(name: "AvenirNext-Medium", size: 16*screenWidthFactor)
        labelTitleInvisible.numberOfLines = 0
        labelTitleInvisible.textAlignment = NSTextAlignment.center
        labelTitleInvisible.textColor = UIColor(red: 89/255, green: 89.0/255, blue: 89.0/255, alpha: 1.0)
        uiViewInvisibleMode.addSubview(labelTitleInvisible)
        
        let imageAvatarInvisible = UIImageView(frame: CGRect(x: 89*screenWidthFactor, y: 87*screenWidthFactor, width: 117*screenWidthFactor, height: 139*screenWidthFactor))
        imageAvatarInvisible.image = UIImage(named: "InvisibleMode")
        uiViewInvisibleMode.addSubview(imageAvatarInvisible)
        
        let labelNoteInvisible = UILabel(frame: CGRect(x: 41*screenWidthFactor, y: 236*screenWidthFactor, width: 209*screenWidthFactor, height: 66*screenWidthFactor))
        labelNoteInvisible.numberOfLines = 0
        labelNoteInvisible.text = "You are Hidden,\nNo one can see you and you\ncan't be discovered"
        labelNoteInvisible.textAlignment = NSTextAlignment.center
        labelNoteInvisible.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        labelNoteInvisible.font = UIFont(name: "AvenirNext-Medium", size: 16*screenWidthFactor)
        uiViewInvisibleMode.addSubview(labelNoteInvisible)
        
        let buttonInvisibleGotIt = UIButton(frame: CGRect(x: 41*screenWidthFactor, y:315*screenWidthFactor, width: 209*screenWidthFactor, height: 40*screenWidthFactor))
        buttonInvisibleGotIt.setTitle("Got it!", for: .normal)
        buttonInvisibleGotIt.titleLabel?.font = UIFont(name:"AvenirNext-DemiBold", size:16*screenWidthFactor)
        buttonInvisibleGotIt.backgroundColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        buttonInvisibleGotIt.layer.cornerRadius = 20*screenWidthFactor
        buttonInvisibleGotIt.addTarget(self, action: #selector(self.invisibleModeGotItClicked(_:)), for: .touchUpInside)
        uiViewInvisibleMode.addSubview(buttonInvisibleGotIt)
        
        UIView.animate(withDuration: 0.3) { 
            dimBackgroundInvisibleMode.alpha = 1
        }
    }
    
    func invisibleModeDimClicked (_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: ({
            sender.alpha = 0
        })) { (done: Bool) in
            sender.removeFromSuperview()
        }
    }
    
    func invisibleModeGotItClicked (_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: ({
            sender.superview?.superview?.alpha = 0
        })) { (done: Bool) in
            sender.superview?.superview?.removeFromSuperview()
        }
    }
    
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
