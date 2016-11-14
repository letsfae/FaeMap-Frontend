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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setup()
    {
        imageView = UIImageView(frame: CGRect(x: 68 * screenWidthFactor, y: 159 * screenHeightFactor, width: 291 * screenWidthFactor, height: 255 * screenHeightFactor))
        imageView.image = UIImage(named: "EnableNotificationImage")
        self.view.addSubview(imageView)
        
        titleLabel = UILabel(frame: CGRect(x: 15,y: 469 * screenHeightFactor,width: screenWidth - 30,height: 54))

        titleLabel.numberOfLines = 2
        titleLabel.attributedText = NSAttributedString(string:"Help your Windbell in delivering\nimportant notifications!", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        titleLabel.center.x = screenWidth / 2
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRect(x: 15,y: 547 * screenHeightFactor ,width: screenWidth - 30,height: 44))
        descriptionLabel.numberOfLines = 2
        descriptionLabel.attributedText = NSAttributedString(string:"Take full advantage of Fae’s Real-Time\nPlatform & Never miss out on Anything!", attributes: [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!])
        descriptionLabel.textAlignment = .center
        descriptionLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(descriptionLabel)
        
        enableNotificationButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        enableNotificationButton.center.x = screenWidth / 2

        enableNotificationButton.setAttributedTitle(NSAttributedString(string: "Enable Notifications", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for:UIControlState())
        enableNotificationButton.layer.cornerRadius = 25 * screenHeightFactor
        enableNotificationButton.backgroundColor = UIColor.faeAppRedColor()
        enableNotificationButton.addTarget(self, action: #selector(EnableNotificationViewController.enableNotificationButtonTapped), for: .touchUpInside)
        self.view.addSubview(enableNotificationButton)
    }
    
    func enableNotificationButtonTapped()
    {
        let notificationType = UIApplication.shared.currentUserNotificationSettings
        if notificationType?.types == UIUserNotificationType() {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
