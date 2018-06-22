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
    // MARK: - Properties
    var faeUser: FaeUser!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }
    
    private func createView() {
        let btnBack = UIButton(frame: CGRect(x: 10, y: 25 + device_offset_top, width: 40, height: 40))
        btnBack.setImage(UIImage(named: "NavigationBackNew"), for: UIControlState())
        btnBack.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        let imgFaePic = UIImageView(frame: CGRect(x: 32, y: 160 + device_offset_top, w: 350, h: 300))
        imgFaePic.image = #imageLiteral(resourceName: "WelcomeFae")
        
        let lblWelcome = UILabel(frame: CGRect(x: 0, y: 480 * screenHeightFactor + device_offset_top, width: screenWidth, height: 34))
        lblWelcome.text = "Welcome to Faevorite!"
        lblWelcome.textColor = UIColor._898989()
        lblWelcome.font = UIFont(name: "AvenirNext-Medium", size: 25)
        lblWelcome.textAlignment = .center
        
        let btnFinish = UIButton(frame: CGRect(x: 0, y: screenHeight - 20 - 36 - (25 + 50) * screenHeightFactor - device_offset_top - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnFinish.layer.cornerRadius = 25 * screenHeightFactor
        btnFinish.layer.masksToBounds = true
        btnFinish.center.x = screenWidth / 2
        
        btnFinish.setTitle("Start Using Fae Map!", for: UIControlState())
        btnFinish.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        
        btnFinish.backgroundColor = UIColor._2499090()
        btnFinish.addTarget(self, action: #selector(self.finishButtonPressed), for: .touchUpInside)
        
        let lblTermsOfService = UILabel(frame: CGRect(x: 0, y: screenHeight - 56 - device_offset_top - device_offset_bot, width: screenWidth, height: 36))
        lblTermsOfService.numberOfLines = 2
        lblTermsOfService.textAlignment = .center
        
        let strTermofService = "To use Fae Maps, you agree to our\nTerms of Service and Privacy Policy."
        let attrTermofService = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]
        let attrAgreeString = NSMutableAttributedString(string: strTermofService, attributes: attrTermofService)
        attrAgreeString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor._138138138(), range: NSRange(location: 0, length: strTermofService.count))
        
        let rangeAttr1 = NSRange(location: 34, length: 16)
        let rangeAttr2 = NSRange(location: 55, length: 15)
        
        attrAgreeString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor._2499090(), range: rangeAttr1)
        attrAgreeString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor._2499090(), range: rangeAttr2)
        
        attrAgreeString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "AvenirNext-Bold", size: 13)!, range: rangeAttr1)
        attrAgreeString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "AvenirNext-Bold", size: 13)!, range: rangeAttr2)
        
        lblTermsOfService.attributedText = attrAgreeString
        
        let btnTerm = UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 25))
        btnTerm.frame.origin = CGPoint(x: screenWidth / 2 - 140, y: lblTermsOfService.frame.origin.y + 15)
        btnTerm.addTarget(self, action: #selector(self.termOfServiceButtonTapped(_:)), for: .touchUpInside)
        
        let btnPrivacyPolicy = UIButton(frame: CGRect(x: 0, y: 0, width: 110, height: 25))
        btnPrivacyPolicy.frame.origin = CGPoint(x: screenWidth / 2 + 23, y: lblTermsOfService.frame.origin.y + 15)
        btnPrivacyPolicy.addTarget(self, action: #selector(privacyPolicyButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(btnBack)
        view.addSubview(imgFaePic)
        view.addSubview(lblWelcome)
        view.addSubview(btnFinish)
        view.addSubview(lblTermsOfService)
        view.addSubview(btnTerm)
        view.addSubview(btnPrivacyPolicy)
        
        view.bringSubview(toFront: btnBack)
    }
    
    // MARK: - Button actions
    @objc private func termOfServiceButtonTapped(_ sender: UIButton) {
        let vcTermsofService = TermsOfServiceViewController()
        present(vcTermsofService, animated: true, completion: nil)
    }
    
    @objc private func privacyPolicyButtonTapped(_ sender: UIButton) {
        let vcPrivacy = PrivacyPolicyViewController()
        present(vcPrivacy, animated: true, completion: nil)
    }
    
    override func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func finishButtonPressed() {
        jumpToEnableNotification()
        let vcNext = InitialPageController()
        navigationController?.pushViewController(vcNext, animated: true)
        navigationController?.viewControllers = [vcNext]
        for key in ["signup", "signup_first_name", "signup_last_name", "signup_username", "signup_password", "signup_gender", "signup_dateofbirth", "signup_email"] {
            FaeCoreData.shared.removeByKey(key)
        }
    }
    
    // MARK: - Helper methods
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
        faeUser.logInBackground({ [weak self] (status: Int, message: Any?) in
            guard let `self` = self else { return }
            self.hideActivityIndicator()
            if status / 100 == 2 {
                self.jumpToEnableNotification()
                let vcNext = InitialPageController()
                self.navigationController?.pushViewController(vcNext, animated: true)
            }
        })
    }
    
    private func jumpToEnableNotification() {
        let notificationType = UIApplication.shared.currentUserNotificationSettings
        if notificationType?.types == UIUserNotificationType() {
            let vc = EnableNotificationViewController()
            present(vc, animated: true)
        }
    }
}
