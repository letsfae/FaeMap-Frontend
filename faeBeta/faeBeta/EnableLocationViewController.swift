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
    private var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup()
    {
        imageView = UIImageView(frame: CGRectMake(68 * screenWidthFactor, 159 * screenHeightFactor, 291 * screenWidthFactor, 255 * screenHeightFactor))
        imageView.image = UIImage(named: "EnableLocationImage")
        self.view.addSubview(imageView)
        
        titleLabel = UILabel(frame: CGRectMake(15,469 * screenHeightFactor,screenWidth - 30,27))
        titleLabel.attributedText = NSAttributedString(string:"Location Access", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .Center
        view.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRectMake(15,514 * screenHeightFactor ,screenWidth - 30,44))
        descriptionLabel.numberOfLines = 2
        descriptionLabel.attributedText = NSAttributedString(string:"Fae Map is a Social Map Platform,\nit needs to use Location to work.", attributes: [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!])
        descriptionLabel.textAlignment = .Center
        view.addSubview(descriptionLabel)
        
        infoLabel = UILabel(frame: CGRectMake(15,605 * screenHeightFactor,screenWidth - 30,18))
        infoLabel.attributedText = NSAttributedString(string:"Fae’s Ninja System always protects your location.", attributes: [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!])
        infoLabel.textAlignment = .Center
        self.view.addSubview(infoLabel)
        
        enableLocationButton = UIButton(frame: CGRectMake(0, screenHeight - 30 - 50 * screenHeightFactor, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor))
        enableLocationButton.center.x = screenWidth / 2
        enableLocationButton.setAttributedTitle(NSAttributedString(string: "Enable Location", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), forState:.Normal)
        enableLocationButton.layer.cornerRadius = 25 * screenHeightFactor
        enableLocationButton.backgroundColor = UIColor.faeAppRedColor()
        enableLocationButton.addTarget(self, action: #selector(EnableLocationViewController.enableLocationButtonTapped), forControlEvents: .TouchUpInside)
        self.view.addSubview(enableLocationButton)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.checkLocationEnabled), userInfo: nil, repeats: true)
    }
    
    func enableLocationButtonTapped()
    {
        let authstate = CLLocationManager.authorizationStatus()
        if(authstate != CLAuthorizationStatus.AuthorizedAlways){
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
    func checkLocationEnabled()
    {
        let authstate = CLLocationManager.authorizationStatus()
        let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if(authstate == CLAuthorizationStatus.AuthorizedAlways){
            timer.invalidate()
            if (notificationType?.types == UIUserNotificationType.None && self.navigationController != nil) {
                self.navigationController?.pushViewController(UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("EnableNotificationViewController") , animated: true)
            }else{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
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
