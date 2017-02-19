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
    private var reachability: Reachability!
    
    var uiviewNavBarMenu: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reachability = Reachability.init()
        do {
            try self.reachability.startNotifier()
        } catch {
        }
        view.backgroundColor = UIColor.white
        let img = UIImageView(frame: CGRect(x: -49*screenWidthFactor, y: 157*screenHeightFactor, width: 507*screenWidthFactor, height: 422*screenHeightFactor))
        img.image = #imageLiteral(resourceName: "disconnectionPic")
        img.contentMode = .scaleAspectFit
        view.addSubview(img)
        let btnReconnect = UIButton(frame: CGRect(x: 57*screenWidthFactor, y: 605*screenWidthFactor, width: 300*screenWidthFactor, height: 50*screenWidthFactor))
        btnReconnect.layer.cornerRadius = 25*screenWidthFactor
        btnReconnect.setTitle("Reconnect", for: .normal)
        btnReconnect.setTitleColor(UIColor.white, for: .normal)
        btnReconnect.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20*screenWidthFactor)
        btnReconnect.backgroundColor = UIColor.faeAppRedColor()
        view.addSubview(btnReconnect)
        btnReconnect.addTarget(self, action: #selector(self.actionReconnect(_:)), for: .touchUpInside)
        
        lblFailMessage = UILabel(frame: CGRect(x: 70*screenWidthFactor, y: 72*screenHeightFactor, width: 275*screenWidthFactor, height: 60*screenHeightFactor))
        lblFailMessage.text = "Sorry… Reconnection failed…\nPlease try again!"
        lblFailMessage.numberOfLines = 2
        lblFailMessage.textAlignment = .center
        lblFailMessage.font = UIFont(name: "AvenirNext-Medium", size: 20*screenWidthFactor)
        lblFailMessage.textColor = UIColor.faeAppInputTextGrayColor()
        view.addSubview(lblFailMessage)
        lblFailMessage.isHidden = true
    }
    
    func actionReconnect(_ sender: UIButton) {
        if reachability.isReachable {
            print("[reachabilityChanged] Network reachable")
            self.dismiss(animated: true, completion: nil)
        } else {
            print("[reachabilityChanged] Network not reachable")
            lblFailMessage.isHidden = false
        }
    }
}
