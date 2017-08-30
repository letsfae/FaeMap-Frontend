//
//  EnableNotificationViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class EnableNotificationViewController: UIViewController {
    fileprivate var imageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var enableNotificationButton: UIButton!
    fileprivate var notNowButton: UIButton!
    // bool value used to check whether the current ViewController is EnableNotificationViewController
    static var boolCurtVCisNoti = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        EnableNotificationViewController.boolCurtVCisNoti = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        EnableNotificationViewController.boolCurtVCisNoti = false
    }
    
    fileprivate func setup() {
        self.view.backgroundColor = .white
        imageView = UIImageView(frame: CGRect(x: 68, y: 159, w: 291, h: 255))
        imageView.image = #imageLiteral(resourceName: "EnableNotificationImage")
        self.view.addSubview(imageView)
        
        titleLabel = UILabel(frame: CGRect(x: 15, y: 460 * screenHeightFactor, width: screenWidth - 30, height: 27))
        titleLabel.attributedText = NSAttributedString(string:"Stay Updated with Notifications", attributes: [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        titleLabel.center.x = screenWidth / 2
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRect(x: 15, y: 514 * screenHeightFactor, width: screenWidth - 30, height: 44))
        descriptionLabel.numberOfLines = 2
        descriptionLabel.attributedText = NSAttributedString(string: "Get Notified for Chats, interesting \nPlaces nearby, and More!", attributes: [NSForegroundColorAttributeName: UIColor._138138138(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!])
        descriptionLabel.textAlignment = .center
        descriptionLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(descriptionLabel)

        enableNotificationButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 20 - 36 - (25 + 50) * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        enableNotificationButton.center.x = screenWidth / 2

        enableNotificationButton.setAttributedTitle(NSAttributedString(string: "Enable Notifications", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for:UIControlState())
        enableNotificationButton.layer.cornerRadius = 25 * screenHeightFactor
        enableNotificationButton.backgroundColor = UIColor._2499090()
        enableNotificationButton.addTarget(self, action: #selector(enableNotificationButtonTapped), for: .touchUpInside)
        self.view.addSubview(enableNotificationButton)
        
        notNowButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 38 * screenHeightFactor - 18, width: 60, height: 18))
        notNowButton.center.x = screenWidth / 2
        notNowButton.setAttributedTitle(NSAttributedString(string: "Not Now", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 13)!]), for: UIControlState())
        notNowButton.addTarget(self, action: #selector(self.notNowButtonTapped), for: .touchUpInside)
        self.view.addSubview(notNowButton)
    }
    
    func enableNotificationButtonTapped() {
        let notificationType = UIApplication.shared.currentUserNotificationSettings
        if notificationType?.types == UIUserNotificationType() {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }

    func notNowButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
