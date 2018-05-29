//
//  DisconnectionViewController.swift
//  faeBeta
//
//  Created by Yue on 1/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class DisconnectionViewController: UIViewController {
    
    static let shared = DisconnectionViewController()
    
    private var uiviewNavBar: UIView!
    private var btnNavBar: UIButton!
    private var lblFailMessage: UILabel!
    private var btnReconnect: UIButton!
    private var reachability: Reachability!
    
    private var uiviewNavBarMenu: UIView!
    private var preStatusBarStyle = UIStatusBarStyle.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachability = Reachability.init()
        do {
            try reachability.startNotifier()
        } catch {}
        view.backgroundColor = UIColor.white
        let img = UIImageView(frame: CGRect(x: 0 * screenWidthFactor, y: 157 * screenHeightFactor, width: screenWidth, height: 498 * screenHeightFactor))
        img.image = #imageLiteral(resourceName: "disconnectionPic-1")
        img.contentMode = .scaleAspectFit
        view.addSubview(img)
        btnReconnect = UIButton(frame: CGRect(x: 57 * screenWidthFactor, y: 603 * screenWidthFactor, width: 300 * screenWidthFactor, height: 50 * screenWidthFactor))
        btnReconnect.layer.cornerRadius = 25 * screenWidthFactor
        btnReconnect.setImage(#imageLiteral(resourceName: "btnReconnect"), for: .normal)
        view.addSubview(btnReconnect)
        btnReconnect.addTarget(self, action: #selector(actionReconnect(_:)), for: .touchUpInside)
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
    
    @objc private func actionReconnect(_ sender: UIButton) {
        if reachability.isReachable {
            print("[reachabilityChanged] Network reachable")
            dismiss(animated: true, completion: nil)
        } else {
            print("[reachabilityChanged] Network not reachable")
            if lblFailMessage != nil {
                lblFailMessage.removeFromSuperview()
            }
            lblFailMessage = UILabel(frame: CGRect(x: 70 * screenWidthFactor, y: 72 * screenHeightFactor, width: 275 * screenWidthFactor, height: 60 * screenHeightFactor))
            lblFailMessage.text = "Sorry… Reconnection failed…\nPlease try again!"
            lblFailMessage.numberOfLines = 2
            lblFailMessage.textAlignment = .center
            lblFailMessage.font = UIFont(name: "AvenirNext-Medium", size: 20 * screenWidthFactor)
            lblFailMessage.textColor = UIColor._898989()
            view.addSubview(lblFailMessage)
        }
    }
}
