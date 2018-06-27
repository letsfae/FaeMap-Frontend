//
//  UpdateUsrnameEmailViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-10-07.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol UpdateUsrnameEmailDelegate: class {
    func updateEmail()
    func updatePhone()
}

class UpdateUsrnameEmailViewController: UIViewController, VerifyCodeDelegate {
    // MARK: - Properties
    private var lblTitle: FaeLabel!
    private var lblHint: FaeLabel!
    private var btnUpdate: UIButton!
    private var lblHintRed: FaeLabel!
    private var lblHintHead: FaeLabel!
    
    var strEmail: String? = ""
    var strUsername: String? = ""
    var strPhone: String? = ""
    var strCountry: String? = "United States +1"
    private var indicatorView: UIActivityIndicatorView!
    private var uiviewShadowBG: UIView!
    private var uiviewMsg: UIView!
    
    private var faeUser = FaeUser()
    weak var delegate: UpdateUsrnameEmailDelegate?
    
    enum SettingEnterMode {
        case email
        case usrname
        case phone
    }
    
    var enterMode: SettingEnterMode = .email
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadContent()
    }
    
    // MARK: - Set up
    private func loadNavBar() {
        let btnBack = UIButton(frame: CGRect(x: 0, y: 21 + device_offset_top, width: 48, height: 48))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
    }
    
    private func loadContent() {
        lblTitle = FaeLabel(CGRect(x: 0, y: 99, width: screenWidth, height: 27), .center, .medium, 20, UIColor._898989())
        lblTitle.numberOfLines = 0
        view.addSubview(lblTitle)
        lblHint = FaeLabel(CGRect(x: 0, y: 355 * screenHeightFactor, width: screenWidth, height: 36), .center, .medium, 13, UIColor._138138138())
        lblHint.numberOfLines = 0
        view.addSubview(lblHint)
        btnUpdate = UIButton(frame: CGRect(x: 0, y: screenHeight - 176 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnUpdate.center.x = screenWidth / 2
        btnUpdate.layer.cornerRadius = 25 * screenHeightFactor
        btnUpdate.layer.masksToBounds = true
        btnUpdate.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnUpdate.backgroundColor = UIColor._2499090()
        btnUpdate.addTarget(self, action: #selector(actionUpdate(_:)), for: .touchUpInside)
        view.addSubview(btnUpdate)
        
        switch enterMode {
        case .email:
            loadEmail()
        case .usrname:
            loadUserName()
        case .phone:
            loadPhone()
        }
    }
    
    private func loadEmail() {
        lblTitle.text = "Your Primary Email:"
        btnUpdate.setTitle("Change Email", for: UIControlState())
        lblHint.text = "You can use your Email for Log in,\nSubscriptions, and Verifications."
        
        let lblEmail = FaeLabel(CGRect(x: 20, y: 177 * screenHeightFactor, width: screenWidth - 40, height: 30), .center, .regular, 22, UIColor._898989())
        view.addSubview(lblEmail)
        lblEmail.text = strEmail!
        
        lblHintHead = FaeLabel(CGRect(x: 0, y: 337 * screenHeightFactor, width: screenWidth, height: 18), .center, .medium, 13, UIColor._898989())
        view.addSubview(lblHintHead)
        lblHintHead.text = "After you Verify your Email:"
        
        lblHintRed = FaeLabel(CGRect(x: 0, y: 230 * screenHeightFactor, width: screenWidth, height: 18), .center, .medium, 13, UIColor._2499090())
        view.addSubview(lblHintRed)
        
        setHintRedLabel()
        createActivityIndicator()
    }
    
    private func setHintRedLabel() {
        let attr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]
        let attrBold = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 13)!]
        let txt = NSMutableAttributedString()
        
        if !Key.shared.userEmailVerified {
            txt.append(NSAttributedString(attributedString: NSAttributedString(string: "Please", attributes: attr)))
            txt.append(NSAttributedString(attributedString: NSAttributedString(string: " Verify ", attributes: attrBold)))
            txt.append(NSAttributedString(attributedString: NSAttributedString(string: "your Email!", attributes: attr)))
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionVerifyEmail(_:)))
            lblHintRed.addGestureRecognizer(tapGesture)
            lblHintRed.isUserInteractionEnabled = true
        } else {
            let tick = InlineTextAttachment()
            tick.image = #imageLiteral(resourceName: "mb_tick")
            txt.append(NSAttributedString(attachment: tick))
            txt.append(NSAttributedString(attributedString: NSAttributedString(string: " Email Verified", attributes: attrBold)))
            lblHintHead.isHidden = true
        }
        lblHintRed.attributedText = txt
    }
    
    private func loadUserName() {
        lblTitle.text = "Your Faevorite Username:"
        //btnUpdate.setTitle("Request Reset", for: UIControlState())
        btnUpdate.setTitle("Change Username", for: UIControlState())
        lblHint.text = "You can use your Username for Log In,\nAdding People, and Starting Chats."
        
        let lblUsrname = FaeLabel(CGRect(x: 0, y: 213 * screenHeightFactor, width: screenWidth, height: 30), .center, .regular, 22, UIColor._155155155())
        view.addSubview(lblUsrname)
        let attr = [NSAttributedStringKey.foregroundColor: UIColor._155155155()]
        let attrEmail = [NSAttributedStringKey.foregroundColor: UIColor._898989()]
        
        let txt = NSMutableAttributedString()
        txt.append(NSAttributedString(string: "@", attributes: attr))
        txt.append(NSAttributedString(string: strUsername!, attributes: attrEmail))
        lblUsrname.attributedText = txt
        
        let lblBelowHint = FaeLabel(CGRect(x: 0, y: screenHeight - 231 * screenHeightFactor, width: screenWidth, height: 36), .center, .regular, 13, UIColor._138138138())
        lblBelowHint.numberOfLines = 0
        view.addSubview(lblBelowHint)
        //lblBelowHint.text = "If you want to change your Username,\nPlease request a Username Reset."
        let strHint = "You can change your Username\n2 times per year - 2 left"
        let attributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]
        let strAttributed =  NSMutableAttributedString(string: strHint, attributes: attributes)
        strAttributed.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor._138138138(), range: NSRange(location: 0, length: strHint.count))
        strAttributed.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor._2499090(), range: NSRange(location: strHint.count - 6, length: 6))
        lblBelowHint.attributedText = strAttributed
        
        loadUserNameShadow()
    }
    
    private func loadUserNameShadow() {
        uiviewShadowBG = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewShadowBG.backgroundColor = UIColor._107105105_a50()
        view.addSubview(uiviewShadowBG)
        
        uiviewMsg = UIView(frame: CGRect(x: 0, y: alert_offset_top, width: 290, height: 208))
        uiviewMsg.center.x = screenWidth / 2
        uiviewMsg.backgroundColor = .white
        uiviewMsg.layer.cornerRadius = 20
        uiviewShadowBG.addSubview(uiviewMsg)
        uiviewShadowBG.alpha = 0
        uiviewMsg.alpha = 0
        
        let lblMsgTitle = FaeLabel(CGRect(x: 0, y: 20, width: 290, height: 50), .center, .medium, 18, UIColor._898989())
        lblMsgTitle.numberOfLines = 0
        lblMsgTitle.text = "A Username Reset needs\nsome time to complete."
        uiviewMsg.addSubview(lblMsgTitle)
        
        let lblMsgContent = FaeLabel(CGRect(x: 0, y: 90 * screenHeightFactor, width: 290, height: 36), .center, .medium, 13, UIColor._138138138())
        lblMsgContent.numberOfLines = 0
        lblMsgContent.text = "Until you set a new Username,\nyour current one will remain active."
        uiviewMsg.addSubview(lblMsgContent)
        
        let btnYes = UIButton()
        uiviewMsg.addSubview(btnYes)
        btnYes.setTitle("Yes", for: .normal)
        btnYes.setTitleColor(.white, for: .normal)
        btnYes.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnYes.backgroundColor = UIColor._2499090()
        btnYes.layer.cornerRadius = 19
        btnYes.addTarget(self, action: #selector(actionYes(_:)), for: .touchUpInside)
        let padding = (290 - 208) / 2
        view.addConstraintsWithFormat("H:|-\(padding)-[v0]-\(padding)-|", options: [], views: btnYes)
        view.addConstraintsWithFormat("V:[v0(39)]-20-|", options: [], views: btnYes)
        
        let btnCancel = UIButton(frame: CGRect(x: 0, y: 0, width: 42, height: 40))
        btnCancel.setImage(#imageLiteral(resourceName: "check_cross_red"), for: .normal)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        uiviewMsg.addSubview(btnCancel)
    }
    
    private func loadPhone() {
        lblTitle.text = "Your Linked Phone Number"
        btnUpdate.setTitle("Change Number", for: UIControlState())
        lblHint.text = "You can use your Phone Number for,\nAdding Contacts and Verifications."
        
        let lblCountry = FaeLabel(CGRect(x: 0, y: 170 * screenHeightFactor, width: screenWidth, height: 30), .center, .medium, 22, UIColor._898989())
        lblCountry.text = strCountry!
        view.addSubview(lblCountry)
        
        let lblPhone = FaeLabel(CGRect(x: 0, y: 250 * screenHeightFactor, width: screenWidth, height: 34), .center, .regular, 25, UIColor._898989())
        lblPhone.text = strPhone!
        view.addSubview(lblPhone)
    }
    
    private func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        
        view.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
    }
    
    // MARK: - Button & gesture actions
    @objc private func actionBack(_ sender: UIButton) {
        if enterMode == .email {
            delegate?.updateEmail()
        } else if enterMode == .phone {
            faeUser.getAccountBasicInfo{  [weak delegate = self.delegate!] (statusCode, result) in
                if statusCode / 100 == 2 {
                    print("Successfully get account info \(statusCode) \(result!)")
                    delegate?.updatePhone()
                } else {
                    print("Fail to get account info \(statusCode) \(result!)")
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
        
    @objc private func actionUpdate(_ sender: UIButton) {
        switch enterMode {
        case .email:
            let vc = SetUpdateAccountViewController()
            vc.enterMode = .newEmail
            navigationController?.pushViewController(vc, animated: true)
        case .usrname:
            //animationShowView()
            break
        case .phone:
            let vc = SignInPhoneViewController()
            vc.enterMode = .settingsUpdate
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func actionCancel(_ sender: UIButton) {
        animationHideView()
    }
    
    @objc private func actionYes(_ sender: UIButton) {
        animationHideView()
    }

    @objc private func actionVerifyEmail(_ sender: UITapGestureRecognizer) {
        let vc = VerifyCodeViewController()
        vc.delegate = self
        vc.enterMode = .email
        vc.enterEmailMode = .settings
        vc.strVerified = strEmail!
        indicatorView.startAnimating()
        faeUser.whereKey("email", value: strEmail!)
        faeUser.updateEmail{ [unowned self] (statusCode, result) in
            if statusCode / 100 == 2 {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                print("Sent code fail")
            }
            self.indicatorView.stopAnimating()
        }
    }
    
    // MARK: - Animations
    private func animationShowView() {
        uiviewShadowBG.alpha = 0
        uiviewMsg.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewShadowBG.alpha = 1
            self.uiviewMsg.alpha = 1
        })
    }
    
    private func animationHideView() {
        uiviewShadowBG.alpha = 1
        uiviewMsg.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewMsg.alpha = 0
            self.uiviewShadowBG.alpha = 0
        })
    }

    // MARK: - VerifyCodeDelegate
    func verifyEmailSucceed() {
        setHintRedLabel()
    }
}
