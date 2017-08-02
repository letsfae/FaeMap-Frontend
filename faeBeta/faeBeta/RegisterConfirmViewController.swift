//
//  RegisterConfirmViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterConfirmViewController: RegisterBaseViewController {
    var faeUser: FaeUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createView()
    }
    
    // MARK: Functions
    func createView() {
        let viewHeight = view.frame.size.height
        let viewWidth = view.frame.size.width
        
        let btnBack = UIButton(frame: CGRect(x: 10, y: 25, width: 40, height: 40))
        btnBack.setImage(UIImage(named: "NavigationBackNew"), for: UIControlState())
        btnBack.setTitleColor(UIColor.blue, for: UIControlState())
        btnBack.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: viewHeight * 95 / 736.0, width: viewWidth, height: 35))
        lblTitle.textColor = UIColor.init(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 25)
        lblTitle.textAlignment = .center
        lblTitle.text = "Welcome to Fae!"
        
        let imgFaePic = UIImageView(frame: CGRect(x: 30, y: viewHeight * 185 / 736.0, width: viewWidth - 60, height: (viewWidth - 60) * 300 / 351.0))
        imgFaePic.image = UIImage(named: "FaePic")
        
        let btnFinish = UIButton(frame: CGRect(x: 0, y: screenHeight - 20 - 36 - (25 + 50) * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnFinish.layer.cornerRadius = 25 * screenHeightFactor
        btnFinish.layer.masksToBounds = true
        btnFinish.center.x = screenWidth / 2
        
        btnFinish.setTitle("Finish!", for: UIControlState())
        btnFinish.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        
        btnFinish.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        btnFinish.addTarget(self, action: #selector(self.finishButtonPressed), for: .touchUpInside)
        
        let lblTermsOfService = UILabel(frame: CGRect(x: 0, y: 514 * screenHeightFactor, width: screenWidth, height: 50))
        lblTermsOfService.numberOfLines = 2
        lblTermsOfService.textAlignment = .center
        
        let strTermofService = "I agree to Fae's Terms of Service\nand Privacy Policy."
        let attrTermofService = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let attrAgreeString = NSMutableAttributedString(string: strTermofService, attributes: attrTermofService)
        attrAgreeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1.0), range: NSRange(location: 0, length: strTermofService.characters.count))
        
        let rangeAttr1 = NSRange(location: 17, length: 16)
        let rangeAttr2 = NSRange(location: 38, length: 14)
        
        attrAgreeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 253 / 255, green: 114 / 255, blue: 109 / 255, alpha: 1.0), range: rangeAttr1)
        attrAgreeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 253 / 255, green: 114 / 255, blue: 109 / 255, alpha: 1.0), range: rangeAttr2)
        
        attrAgreeString.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-Bold", size: 16)!, range: rangeAttr1)
        attrAgreeString.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-Bold", size: 16)!, range: rangeAttr2)
        
        lblTermsOfService.attributedText = attrAgreeString
        
        let btnTerm = UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 25))
        btnTerm.center = CGPoint(x: screenWidth / 2 + 60, y: lblTermsOfService.frame.origin.y + 13)
        btnTerm.addTarget(self, action: #selector(self.termOfServiceButtonTapped(_:)), for: .touchUpInside)
        
        let btnPrivacyPolicy = UIButton(frame: CGRect(x: 0, y: 0, width: 110, height: 25))
        btnPrivacyPolicy.center = CGPoint(x: screenWidth / 2 + 13, y: lblTermsOfService.frame.origin.y + 37)
        btnPrivacyPolicy.addTarget(self, action: #selector(self.privacyPolicyButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(btnBack)
        view.addSubview(lblTitle)
        view.addSubview(imgFaePic)
        view.addSubview(btnFinish)
        view.addSubview(lblTermsOfService)
        view.addSubview(btnTerm)
        view.addSubview(btnPrivacyPolicy)
        
        view.bringSubview(toFront: btnBack)
    }
    
    func termOfServiceButtonTapped(_ sender: UIButton) {
        let vcTermsofService = TermsOfServiceViewController()
        self.present(vcTermsofService, animated: true, completion: {
            _ in
        })
    }
    
    func privacyPolicyButtonTapped(_ sender: UIButton) {
        let vcPrivacy = PrivacyPolicyViewController()
        self.present(vcPrivacy, animated: true, completion: {
            _ in
        })
    }
    
    override func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func finishButtonPressed() {
        self.signUpUser()
    }
    
    func signUpUser() {
        showActivityIndicator()
        print(self.faeUser.keyValue)
        self.faeUser.signUpInBackground { status, _ in
            DispatchQueue.main.async(execute: {
                self.hideActivityIndicator()
                if status / 100 == 2 {
                    self.loginUser()
                }
            })
        }
    }
    
    func loginUser() {
        showActivityIndicator()
        self.faeUser.logInBackground({ (status: Int, message: Any?) in
            DispatchQueue.main.async(execute: {
                self.hideActivityIndicator()
                if status / 100 == 2 {
                    print("login success")
                    let messageJSON = JSON(message!)
                    if let _ = messageJSON["last_login_at"].string {
                    } else {
                        firebaseWelcome()
                        print("[loginUser] is first time login!")
                    }
                    self.jumpToEnableLocation()
                }
            })
        })
    }
    
    func jumpToEnableLocation() {
        let statusAuth = CLLocationManager.authorizationStatus()
        
        if statusAuth != CLAuthorizationStatus.authorizedAlways {
            let uivcNoti = EnableLocationViewController()
                //UIViewController = UIStoryboard(name: "EnableLocationAndNotification", bundle: nil).instantiateViewController(withIdentifier: "EnableLocationViewController") as! EnableLocationViewController
            self.navigationController?.pushViewController(uivcNoti, animated: true)
        } else {
            let notificationType = UIApplication.shared.currentUserNotificationSettings
            if notificationType?.types == UIUserNotificationType() {
                let vc = EnableNotificationViewController()
                self.navigationController?.pushViewController(vc, animated: true)
//                self.navigationController?.pushViewController(UIStoryboard(name: "EnableLocationAndNotification", bundle: nil).instantiateViewController(withIdentifier: "EnableNotificationViewController"), animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: false)
                if let vcRoot = UIApplication.shared.keyWindow?.rootViewController {
                    if vcRoot is InitialPageController {
                        if let vc = vcRoot as? InitialPageController {
                            vc.goToFaeMap()
                        }
                    }
                }
            }
        }
    }
}
