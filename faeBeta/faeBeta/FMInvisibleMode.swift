//
//  FMInvisibleMode.swift
//  faeBeta
//
//  Created by Yue on 12/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
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
        labelNoteInvisible.text = "You are Hidden...\nNo one can see you and you\ncan't be discovered!"
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
}
