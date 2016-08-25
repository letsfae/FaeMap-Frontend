//
//  EnableNotificationViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class EnableNotificationViewController: UIViewController {
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var enableLocationButton: UIButton!
    var screenWidth : CGFloat {
        get{
            return UIScreen.mainScreen().bounds.width
        }
    }
    var screenHeight : CGFloat {
        get{
            return UIScreen.mainScreen().bounds.height
        }
    }
    
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
        imageView = UIImageView(frame: CGRectMake(58, 168, 301, 247))
        imageView.image = UIImage(named: "EnableNotificationImage")
        self.view.addSubview(imageView)
        
        titleLabel = UILabel(frame: CGRectMake(15,470,screenWidth - 30,54))
        titleLabel.numberOfLines = 2
        titleLabel.attributedText = NSAttributedString(string:"Help your Windbell in delivering\nimportant notifications!", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        titleLabel.center.x = screenWidth / 2
        view.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRectMake(15,547,screenWidth - 30,44))
        descriptionLabel.numberOfLines = 2
        descriptionLabel.attributedText = NSAttributedString(string:"Take full advantage of Fae’s Real-Time\nPlatform & Never miss out on Anything!", attributes: [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!])
        descriptionLabel.textAlignment = .Center
        view.addSubview(descriptionLabel)
        
        enableLocationButton = UIButton(frame: CGRectMake(57, 650, 300, 50))
        enableLocationButton.setAttributedTitle(NSAttributedString(string: "Enable Location", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), forState:.Normal)
        enableLocationButton.layer.cornerRadius = 25
        enableLocationButton.backgroundColor = UIColor.faeAppRedColor()
        enableLocationButton.addTarget(self, action: #selector(EnableNotificationViewController.enableNotificationButtonTapped), forControlEvents: .TouchUpInside)
        self.view.addSubview(enableLocationButton)
    }
    
    func enableNotificationButtonTapped()
    {
        
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
