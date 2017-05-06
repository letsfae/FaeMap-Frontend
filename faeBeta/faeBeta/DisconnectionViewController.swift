//
//  DisconnectionViewController.swift
//  faeBeta
//
//  Created by Yue on 1/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class DisconnectionViewController: UIViewController {
    
    var uiviewNavBar: UIView!
    var btnNavBar: UIButton!
    var lblFailMessage: UILabel!
    var btnReconnect: UIButton!
    private var reachability: Reachability!
    
    var uiviewNavBarMenu: UIView!
    var preStatusBarStyle = UIStatusBarStyle.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reachability = Reachability.init()
        do {
            try self.reachability.startNotifier()
        } catch {
        }
        self.view.backgroundColor = UIColor.white
        let img = UIImageView(frame: CGRect(x: 0*screenWidthFactor, y: 157*screenHeightFactor, width: screenWidth, height: 498*screenHeightFactor))
        img.image = #imageLiteral(resourceName: "disconnectionPic-1")
        img.contentMode = .scaleAspectFit
        view.addSubview(img)
        btnReconnect = UIButton(frame: CGRect(x: 57*screenWidthFactor, y: 603*screenWidthFactor, width: 300*screenWidthFactor, height: 50*screenWidthFactor))
        btnReconnect.layer.cornerRadius = 25*screenWidthFactor
        btnReconnect.setImage(#imageLiteral(resourceName: "btnReconnect"), for: .normal)
        self.view.addSubview(btnReconnect)
        btnReconnect.addTarget(self, action: #selector(self.actionReconnect(_:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = preStatusBarStyle
    }
    
    func actionReconnect(_ sender: UIButton) {
        if reachability.isReachable {
            print("[reachabilityChanged] Network reachable")
            self.dismiss(animated: true, completion: nil)
        } else {
            print("[reachabilityChanged] Network not reachable")
            if lblFailMessage != nil {
                lblFailMessage.removeFromSuperview()
            }
            lblFailMessage = UILabel(frame: CGRect(x: 70*screenWidthFactor, y: 72*screenHeightFactor, width: 275*screenWidthFactor, height: 60*screenHeightFactor))
            lblFailMessage.text = "Sorry… Reconnection failed…\nPlease try again!"
            lblFailMessage.numberOfLines = 2
            lblFailMessage.textAlignment = .center
            lblFailMessage.font = UIFont(name: "AvenirNext-Medium", size: 20*screenWidthFactor)
            lblFailMessage.textColor = UIColor.faeAppInputTextGrayColor()
            self.view.addSubview(lblFailMessage)
        }
    }
}
