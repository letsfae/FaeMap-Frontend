//
//  SetDeactiveViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/10/1.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetDeactiveViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollview: UIScrollView!
    
    var btnBack: UIButton!
    var lblTitle: UILabel!
    var lblContent: UILabel!
    
    var lblInfo: UILabel!
    var lblContent2: UILabel!
    
    var btnDeactive: UIButton!
    
    var uiviewBackground: UIView!
    var btnBackground: UIButton!
    var uiviewAlert: UIView!
    var lblAlert: UILabel!
    var btnAlert: UIButton!
    var btnDelete: UIButton!
    
    override func viewDidLoad() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        scrollview = UIScrollView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        view.addSubview(scrollview)
        scrollview.isPagingEnabled = false
        scrollview.contentSize.height = 600
        scrollview.delegate = self
        
        loadContent()
        
        loaduiviewBackground()
        loadAlertDeactive()
    }
    
    func loadContent() {
        //btnBack = UIButton(frame: CGRect(x: 15/414*screenWidth, y: 36/736*screenHeight, width: 18, height: 18))
        btnBack = UIButton(frame: CGRect(x: 0, y: 25, width: 48, height: 40))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        //let contentX = 305/414*screenWidth
        
        //lblTitle = UILabel(frame:CGRect(x: 0, y: 72/736*screenHeight, width: screenWidth, height: 28))
        lblTitle = UILabel(frame: CGRect(x: 0, y: 7, width: screenWidth, height: 27))
        lblTitle.center.x = screenWidth / 2
        scrollview.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.text = "Deactivate your Faevorite Account"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textColor = UIColor._898989()
        
        //lblContent = UILabel(frame: CGRect(x: (screenWidth-contentX)/2, y: 119/736*screenHeight, width: contentX, height: 150))
        lblContent = UILabel(frame: CGRect(x: 0, y: 54, width: 270, height: 108))
        lblContent.center.x = screenWidth / 2
        scrollview.addSubview(lblContent)
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblContent.textColor = UIColor._138138138()
        lblContent.textAlignment = .center
        lblContent.text = "If you're having an issue on Fae Map,\nplease contact us, we might be able to help!\n\nIf you want to deactivate your account,\nplease go through the information below.\nWe'll miss you while you're gone! 😟"
        lblContent.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblContent.numberOfLines = 0
        
        //lblInfo = UILabel(frame: CGRect(x: (screenWidth-contentX)/2, y: 295, width: contentX, height: 22))
        lblInfo = UILabel(frame: CGRect(x: 0, y: 230, width: 167, height: 22))
        lblInfo.center.x = screenWidth / 2
        scrollview.addSubview(lblInfo)
        lblInfo.textAlignment = .center
        lblInfo.text = "Important Information:"
        lblInfo.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblInfo.textColor = UIColor._898989()
        
        //lblContent2 = UILabel(frame: CGRect(x: (screenWidth-contentX)/2, y: 332, width: contentX, height: 228))
        lblContent2 = UILabel(frame: CGRect(x: 0, y: 267, width: 287, height: 207))
        lblContent2.center.x = screenWidth / 2
        scrollview.addSubview(lblContent2)
        lblContent2.text = "-You will be logged out right away and your\naccount will be fully deactivated.\n\n-While your Account is deactivated, other users\nwon’t be able to contact or interact with you.\n\n-You can Log In anytime during deactivation\nperiod to reactivate your Account.\n\nNote: You won’t be able to change your Log In\ninfo while your account is deactivated, so please\nkeep your current Log In info handy."
        lblContent2.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblContent2.textColor = UIColor._138138138()
        lblContent2.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblContent2.numberOfLines = 0
        
        //btnDeactive = UIButton(frame: CGRect(x: (screenWidth-contentX)/2, y: 560, width: contentX, height: 50))
        btnDeactive = UIButton(frame: CGRect(x: 0, y: 495, width: 300, height: 50))
        btnDeactive.center.x = screenWidth / 2
        scrollview.addSubview(btnDeactive)
        btnDeactive.titleLabel?.textColor = .white
        btnDeactive.titleLabel?.textAlignment = .center
        btnDeactive.setTitle("Deactivate Account", for: .normal)
        btnDeactive.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnDeactive.backgroundColor = UIColor._2499090()
        btnDeactive.layer.cornerRadius = 19
        btnDeactive.addTarget(self, action: #selector(showAlertDeactive(_:)), for: .touchUpInside)

    }
    
    func loaduiviewBackground() {
        btnBackground = UIButton(frame: self.view.frame)
        
        uiviewBackground = UIView(frame: self.view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor(red: 107.0 / 255.0, green: 105.0 / 255.0, blue: 105.0 / 255.0, alpha: 0.5)
        uiviewBackground.addSubview(btnBackground)
        uiviewBackground.isHidden = true
    }
    
    func loadAlertDeactive() {
        //let uiviewAlertX = 290/414*screenWidth
        //uiviewAlert = UIView(frame: CGRect(x: (screenWidth-uiviewAlertX)/2, y: 200/736*screenHeight, width: uiviewAlertX, height: 161))
        uiviewAlert = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 161))
        uiviewAlert.center.x = screenWidth / 2
        uiviewBackground.addSubview(uiviewAlert)
        uiviewAlert.backgroundColor = .white
        uiviewAlert.layer.cornerRadius = 19 * screenHeightFactor
        
        //lblAlert = UILabel(frame: CGRect(x: 30/414*screenWidth, y: 30/736*screenHeight, width: 250/414*screenWidth, height: 50))
        lblAlert = UILabel(frame: CGRect(x: 0, y: 30, w: 200, h: 50))
        lblAlert.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(lblAlert)
        lblAlert.numberOfLines = 0
        lblAlert.lineBreakMode = .byWordWrapping
        lblAlert.text = "Are you sure you want\nto deactive the Account?"
        lblAlert.textAlignment = .center
        lblAlert.textColor = UIColor._898989()
        lblAlert.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        //btnDelete = UIButton(frame: CGRect(x: 12/414*screenWidth, y: 12/736*screenHeight, width: 21/414*screenWidth, height: 21/414*screenWidth))
        btnDelete = UIButton(frame: CGRect(x: 0, y: 0, w: 47, h: 45))
        uiviewAlert.addSubview(btnDelete)
        btnDelete.setImage(#imageLiteral(resourceName: "Settings_delete"), for: .normal)
        btnDelete.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        
        //btnAlert = UIButton(frame: CGRect(x: 40/414*screenWidth, y: 102/736*screenHeight, width: 208/414*screenWidth, height: 39))
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indicator = scrollView.subviews.last as? UIImageView {
            indicator.backgroundColor = UIColor._2499090()
            indicator.tintAdjustmentMode = .normal
            indicator.tintColor = UIColor._2499090()
            indicator.image = indicator.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    func showAlertDeactive(_ sender: UIButton) {
        uiviewBackground.isHidden = false
    }
    
    func showMainView(_ sender: UIButton) {
        uiviewBackground.isHidden = true
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func DeactiveAccount(_ sender: UIButton) {
        
    }
}
