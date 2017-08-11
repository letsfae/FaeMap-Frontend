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
        let dimBackground = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dimBackground.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 50)
        dimBackground.alpha = 0
        dimBackground.layer.zPosition = 999
        view.addSubview(dimBackground)
        dimBackground.addTarget(self, action: #selector(invisibleModeDimClicked(_:)), for: .touchUpInside)
        
        let uiviewInvisible = UIView(frame: CGRect(x: 62, y: 155, w: 290, h: 380))
        uiviewInvisible.backgroundColor = .white
        uiviewInvisible.layer.cornerRadius = 16 * screenWidthFactor
        dimBackground.addSubview(uiviewInvisible)
        
        let lblTitle = UILabel(frame: CGRect(x: 73, y: 27, w: 144, h: 44))
        lblTitle.text = "You're now in\n Invisible Mode!"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        lblTitle.numberOfLines = 0
        lblTitle.textAlignment = NSTextAlignment.center
        lblTitle.textColor = UIColor(red: 89 / 255, green: 89.0 / 255, blue: 89.0 / 255, alpha: 1.0)
        uiviewInvisible.addSubview(lblTitle)
        
        let imgInvisible = UIImageView(frame: CGRect(x: 89, y: 87, w: 117, h: 139))
        imgInvisible.image = UIImage(named: "InvisibleMode")
        uiviewInvisible.addSubview(imgInvisible)
        
        let lblNote = UILabel(frame: CGRect(x: 41, y: 236, w: 209, h: 66))
        lblNote.numberOfLines = 0
        lblNote.text = "You are Hidden...\nNo one can see you and you\ncan't be discovered!"
        lblNote.textAlignment = NSTextAlignment.center
        lblNote.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1)
        lblNote.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        uiviewInvisible.addSubview(lblNote)
        
        let btnOkay = UIButton(frame: CGRect(x: 41, y: 315, w: 209, h: 40))
        btnOkay.setTitle("Got it!", for: .normal)
        btnOkay.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        btnOkay.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        btnOkay.layer.cornerRadius = 20 * screenWidthFactor
        btnOkay.addTarget(self, action: #selector(self.invisibleModeGotItClicked(_:)), for: .touchUpInside)
        uiviewInvisible.addSubview(btnOkay)
        
        UIView.animate(withDuration: 0.3) {
            dimBackground.alpha = 1
        }
    }
    
    func invisibleModeDimClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 0
        }, completion: { _ in
            sender.removeFromSuperview()
        })
    }
    
    func invisibleModeGotItClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.superview?.superview?.alpha = 0
        }, completion: { _ in
            sender.superview?.superview?.removeFromSuperview()
        })
    }
}
