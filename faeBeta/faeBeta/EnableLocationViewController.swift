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
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var infoLabel: UILabel!
    private var enableLocationButton: UIButton!
    private var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    private func setup() {
        self.view.backgroundColor = .white
        imageView = UIImageView(frame: CGRect(x: 68, y: 159, w: 291, h: 255))
        imageView.image = #imageLiteral(resourceName: "EnableLocationImage")
        imageView.contentMode = .center
        self.view.addSubview(imageView)
        
        titleLabel = UILabel(frame: CGRect(x: 15, y: 460 * screenHeightFactor, width: screenWidth - 30, height: 27))
        titleLabel.attributedText = NSAttributedString(string: "Location Access", attributes: [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRect(x: 15, y: 514 * screenHeightFactor, width: screenWidth - 30, height: 44))
        descriptionLabel.numberOfLines = 2
        descriptionLabel.attributedText = NSAttributedString(string: "Fae Map is a Map Based Platform,\nit needs to use Location to work.", attributes: [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!])
        descriptionLabel.textAlignment = .center
        view.addSubview(descriptionLabel)
        
        infoLabel = UILabel(frame: CGRect(x: 15, y: screenHeight - 20 - 36, width: screenWidth - 30, height: 36))
        infoLabel.numberOfLines = 2
        infoLabel.attributedText = NSAttributedString(string: "Fae Map’s Shadow Location System always\nProtects your Location Information.", attributes: [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!])
        infoLabel.textAlignment = .center
        self.view.addSubview(infoLabel)
        
        enableLocationButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 20 - 36 - (25 + 50) * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        enableLocationButton.center.x = screenWidth / 2
        enableLocationButton.setAttributedTitle(NSAttributedString(string: "Enable Location", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for: UIControlState())
        enableLocationButton.layer.cornerRadius = 25 * screenHeightFactor
        enableLocationButton.backgroundColor = UIColor._2499090()
        enableLocationButton.addTarget(self, action: #selector(self.enableLocationButtonTapped), for: .touchUpInside)
        self.view.addSubview(enableLocationButton)

    }
    
    @objc func enableLocationButtonTapped() {
        let authstate = CLLocationManager.authorizationStatus()
        if authstate != CLAuthorizationStatus.authorizedAlways {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
}
