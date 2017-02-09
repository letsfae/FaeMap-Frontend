//
//  RegisterConfirmViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterConfirmViewController: RegisterBaseViewController {
    
    // MARK: - Variables
    
    var faeUser: FaeUser!
    var isFirstTimeLogin = false
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createView()
    }
    
    // MARK: Functions
    
    func createView() {
        
        let viewHeight = view.frame.size.height
        let viewWidth = view.frame.size.width
        
        
        let backButton = UIButton(frame: CGRect(x: 10, y: 25, width: 40, height: 40))
        backButton.setImage(UIImage(named: "NavigationBackNew"), for: UIControlState())
        backButton.setTitleColor(UIColor.blue, for: UIControlState())
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: viewHeight * 95/736.0, width: viewWidth, height: 35))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel.textAlignment = .center
        titleLabel.text = "Welcome to Fae!"
        
        let imageView = UIImageView(frame: CGRect(x: 30, y: viewHeight * 185/736.0, width: viewWidth - 60, height: (viewWidth - 60) * 300/351.0))
        imageView.image = UIImage(named: "FaePic")

        let finishButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 20 - 36 - (25 + 50) * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        finishButton.layer.cornerRadius = 25 * screenHeightFactor
        finishButton.layer.masksToBounds = true
        finishButton.center.x = screenWidth / 2
        
        finishButton.setTitle("Finish!", for: UIControlState())
        finishButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 20)
        
        finishButton.backgroundColor = UIColor(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        finishButton.addTarget(self, action: #selector(self.finishButtonPressed), for: .touchUpInside)
        
        
        let termsOfServiceLabel = UILabel(frame: CGRect(x: 0, y: 514 * screenHeightFactor, width: screenWidth, height: 50))
        termsOfServiceLabel.numberOfLines = 2
        termsOfServiceLabel.textAlignment = .center
        
        let myString = "I agree to Fae's Terms of Service\nand Privacy Policy."
        let myAttribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
        myAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 138/255.0, green: 138/255.0, blue: 138/255.0, alpha: 1.0), range: NSRange(location: 0, length: myString.characters.count))
        
        
        let myRange1 = NSRange(location: 17, length: 16)
        let myRange2 = NSRange(location: 38, length: 14)
        
        myAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 253/255.0, green: 114/255.0, blue: 109/255.0, alpha: 1.0), range: myRange1)
        myAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 253/255.0, green: 114/255.0, blue: 109/255.0, alpha: 1.0), range: myRange2)
        
        
        myAttrString.addAttribute(NSFontAttributeName, value:UIFont(name: "AvenirNext-Bold", size: 16)!, range: myRange1)
        myAttrString.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-Bold", size: 16)!, range: myRange2)
        
        termsOfServiceLabel.attributedText = myAttrString
        
        let termOfServiceButton = UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 25))
        termOfServiceButton.center = CGPoint(x: screenWidth / 2 + 60, y: termsOfServiceLabel.frame.origin.y + 13)
        termOfServiceButton.addTarget(self, action: #selector(self.termOfServiceButtonTapped(_:)), for: .touchUpInside)
        
        let privacyPolicyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 110, height: 25))
        privacyPolicyButton.center = CGPoint(x: screenWidth / 2 + 13, y: termsOfServiceLabel.frame.origin.y + 37)
        privacyPolicyButton.addTarget(self, action: #selector(self.privacyPolicyButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(finishButton)
        view.addSubview(termsOfServiceLabel)
        view.addSubview(termOfServiceButton)
        view.addSubview(privacyPolicyButton)
        
        view.bringSubview(toFront: backButton)
        
    }
    
    func termOfServiceButtonTapped(_ sender: UIButton)
    {
        let vc = TermsOfServiceViewController()
        self.present(vc, animated: true, completion: {
            completed in
        })
    }
    
    func privacyPolicyButtonTapped(_ sender: UIButton)
    {
        let vc = PrivacyPolicyViewController()
        self.present(vc, animated: true, completion: {
            completed in
        })
    }
    
    override func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func finishButtonPressed() {
        signUpUser()
    }
    
    func signUpUser() {
        showActivityIndicator()
        print(faeUser.keyValue)
        faeUser.signUpInBackground { (status, message) in
            DispatchQueue.main.async(execute: {
                self.hideActivityIndicator()
                if status/100 == 2 {
                    // 01-22-2017 Add first login check
                    self.loginUser()
                }
            })
        }
    }
    
    func loginUser() {
        showActivityIndicator()
        faeUser.logInBackground({(status: Int, message: Any?) in
            DispatchQueue.main.async(execute: {
                self.hideActivityIndicator()
                if status / 100 == 2 {
                    print("login success")
                    let messageJSON = JSON(message!)
                    if let _ = messageJSON["last_login_at"].string {
                        
                    }
                    else {
                        self.isFirstTimeLogin = true
                        firebaseWelcome()
                        print("[loginUser] is first time login!")
                    }
                    self.jumpToEnableLocation()
                }
            })
        })
    }
    
    func jumpToEnableLocation() {
        let authstate = CLLocationManager.authorizationStatus()
        
        if authstate != CLAuthorizationStatus.authorizedAlways {
            let vc: UIViewController = UIStoryboard(name: "EnableLocationAndNotification", bundle: nil) .instantiateViewController(withIdentifier: "EnableLocationViewController")as! EnableLocationViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let notificationType = UIApplication.shared.currentUserNotificationSettings
            if notificationType?.types == UIUserNotificationType() {
                self.navigationController?.pushViewController(UIStoryboard(name: "EnableLocationAndNotification",bundle: nil).instantiateViewController(withIdentifier: "EnableNotificationViewController") , animated: true)
            } else {
                self.dismiss(animated: true, completion: {
                    if self.isFirstTimeLogin {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isFirstLogin"), object: nil)
                    }
                })
            }
        }
    }
    
    // MARK: Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
