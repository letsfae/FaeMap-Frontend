//
//  EnableLocationViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class EnableLocationViewController: UIViewController {
    // MARK: - Interface 
    fileprivate var imageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var infoLabel: UILabel!
    fileprivate var enableLocationButton: UIButton!
    fileprivate var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setup() {
        self.view.backgroundColor = .white
        imageView = UIImageView(frame: CGRect(x: 68, y: 159, w: 291, h: 255))
        imageView.image = #imageLiteral(resourceName: "EnableLocationImage")
        imageView.contentMode = .center
        self.view.addSubview(imageView)
        
        titleLabel = UILabel(frame: CGRect(x: 15, y: 460 * screenHeightFactor, width: screenWidth - 30, height: 27))
        titleLabel.attributedText = NSAttributedString(string: "Location Access", attributes: [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRect(x: 15, y: 514 * screenHeightFactor, width: screenWidth - 30, height: 44))
        descriptionLabel.numberOfLines = 2
        descriptionLabel.attributedText = NSAttributedString(string: "Fae Map is a Map Based Platform,\nit needs to use Location to work.", attributes: [NSForegroundColorAttributeName: UIColor._138138138(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!])
        descriptionLabel.textAlignment = .center
        view.addSubview(descriptionLabel)
        
        infoLabel = UILabel(frame: CGRect(x: 15, y: screenHeight - 20 - 36, width: screenWidth - 30, height: 36))
        infoLabel.numberOfLines = 2
        infoLabel.attributedText = NSAttributedString(string: "Fae Map’s Shadow Location System always\nProtects your Location Information.", attributes: [NSForegroundColorAttributeName: UIColor._138138138(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!])
        infoLabel.textAlignment = .center
        self.view.addSubview(infoLabel)
        
        enableLocationButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 20 - 36 - (25 + 50) * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        enableLocationButton.center.x = screenWidth / 2
        enableLocationButton.setAttributedTitle(NSAttributedString(string: "Enable Location", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for: UIControlState())
        enableLocationButton.layer.cornerRadius = 25 * screenHeightFactor
        enableLocationButton.backgroundColor = UIColor._2499090()
        enableLocationButton.addTarget(self, action: #selector(self.enableLocationButtonTapped), for: .touchUpInside)
        self.view.addSubview(enableLocationButton)

    }
    
    func enableLocationButtonTapped() {
        let authstate = CLLocationManager.authorizationStatus()
        if authstate != CLAuthorizationStatus.authorizedAlways {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
}
