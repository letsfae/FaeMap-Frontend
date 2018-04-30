//
//  SetDeactiveViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/10/1.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetDeactiveViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    private var scrollview: UIScrollView!
    
    private var btnBack: UIButton!
    private var lblTitle: UILabel!
    private var lblContent: UILabel!
    
    private var lblInfo: UILabel!
    private var lblContent2: UILabel!
    
    private var btnDeactive: UIButton!
    
    private var uiviewBackground: UIView!
    private var btnBackground: UIButton!
    private var uiviewAlert: UIView!
    private var lblAlert: UILabel!
    private var btnAlert: UIButton!
    private var btnDelete: UIButton!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        scrollview = UIScrollView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65))
        view.addSubview(scrollview)
        scrollview.isPagingEnabled = false
        scrollview.contentSize.height = 600
        scrollview.delegate = self
        
        loadContent()
        
        loaduiviewBackground()
        loadAlertDeactive()
    }
    
    private func loadContent() {
        btnBack = UIButton(frame: CGRect(x: 0, y: 21 + device_offset_top, width: 48, height: 48))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        lblTitle = UILabel(frame: CGRect(x: 0, y: 7, width: screenWidth, height: 27))
        lblTitle.center.x = screenWidth / 2
        scrollview.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.text = "Deactivate your Faevorite Account"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textColor = UIColor._898989()
        
        lblContent = UILabel(frame: CGRect(x: 0, y: 54, width: 270, height: 108))
        lblContent.center.x = screenWidth / 2
        scrollview.addSubview(lblContent)
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblContent.textColor = UIColor._138138138()
        lblContent.textAlignment = .center
        lblContent.text = "If you're having an issue on Fae Map,\nplease contact us, we might be able to help!\n\nIf you want to deactivate your account,\nplease go through the information below.\nWe'll miss you while you're gone! 😟"
        lblContent.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblContent.numberOfLines = 0
        
        lblInfo = UILabel(frame: CGRect(x: 0, y: 230, width: 167, height: 22))
        lblInfo.center.x = screenWidth / 2
        scrollview.addSubview(lblInfo)
        lblInfo.textAlignment = .center
        lblInfo.text = "Important Information:"
        lblInfo.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblInfo.textColor = UIColor._898989()
        
        lblContent2 = UILabel(frame: CGRect(x: 0, y: 267, width: 287, height: 228))
        lblContent2.center.x = screenWidth / 2
        scrollview.addSubview(lblContent2)
        lblContent2.text = "-You will be logged out right away and your\naccount will be fully deactivated.\n\n-While your Account is deactivated, other users\nwon’t be able to contact or interact with you.\n\n-You can Log In anytime during deactivation\nperiod to reactivate your Account.\n\nNote: You won’t be able to change your Log In\ninfo while your account is deactivated, so please\nkeep your current Log In info handy."
        lblContent2.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblContent2.textColor = UIColor._138138138()
        lblContent2.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblContent2.numberOfLines = 0
        
        btnDeactive = UIButton(frame: CGRect(x: 0, y: 495, width: 300, height: 50))
        btnDeactive.center.x = screenWidth / 2
        scrollview.addSubview(btnDeactive)
        btnDeactive.titleLabel?.textColor = .white
        btnDeactive.titleLabel?.textAlignment = .center
        btnDeactive.setTitle("Deactivate Account", for: .normal)
        btnDeactive.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnDeactive.backgroundColor = UIColor._2499090()
        btnDeactive.layer.cornerRadius = 25
        btnDeactive.addTarget(self, action: #selector(showAlertDeactive(_:)), for: .touchUpInside)

    }
    
    private func loaduiviewBackground() {
        btnBackground = UIButton(frame: self.view.frame)
        
        uiviewBackground = UIView(frame: self.view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        uiviewBackground.addSubview(btnBackground)
        uiviewBackground.isHidden = true
    }
    
    private func loadAlertDeactive() {
        uiviewAlert = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 161))
        uiviewAlert.center.x = screenWidth / 2
        uiviewBackground.addSubview(uiviewAlert)
        uiviewAlert.backgroundColor = .white
        uiviewAlert.layer.cornerRadius = 19 * screenHeightFactor
        
        lblAlert = UILabel(frame: CGRect(x: 0, y: 30, w: 200, h: 50))
        lblAlert.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(lblAlert)
        lblAlert.numberOfLines = 0
        lblAlert.lineBreakMode = .byWordWrapping
        lblAlert.text = "Are you sure you want\nto deactive the Account?"
        lblAlert.textAlignment = .center
        lblAlert.textColor = UIColor._898989()
        lblAlert.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        btnDelete = UIButton(frame: CGRect(x: 0, y: 0, w: 47, h: 45))
        uiviewAlert.addSubview(btnDelete)
        btnDelete.setImage(#imageLiteral(resourceName: "Settings_delete"), for: .normal)
        btnDelete.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        
        btnAlert = UIButton(frame: CGRect(x: 0, y: 102, w: 208, h: 39))
        btnAlert.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(btnAlert)
        btnAlert.titleLabel?.textColor = .white
        btnAlert.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnAlert.titleLabel?.textAlignment = .center
        btnAlert.setTitle("Yes, Deactivate", for: .normal)
        btnAlert.backgroundColor = UIColor._2499090()
        btnAlert.layer.cornerRadius = 19 * screenHeightFactor
        btnAlert.addTarget(self, action: #selector(DeactiveAccount(_:)), for: .touchUpInside)
        
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indicator = scrollView.subviews.last as? UIImageView {
            indicator.backgroundColor = UIColor._2499090()
            indicator.tintAdjustmentMode = .normal
            indicator.tintColor = UIColor._2499090()
            indicator.image = indicator.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    // MARK: - Button actions
    @objc private func showAlertDeactive(_ sender: UIButton) {
        uiviewBackground.isHidden = false
    }
    
    @objc private func showMainView(_ sender: UIButton) {
        uiviewBackground.isHidden = true
    }
    
    @objc private func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func DeactiveAccount(_ sender: UIButton) {
        
    }
}
