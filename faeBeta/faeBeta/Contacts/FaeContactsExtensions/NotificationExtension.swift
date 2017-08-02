//
//  NotificationExtension.swift
//  FaeContacts
//
//  Created by Justin He on 6/26/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

/* NotificationExtension.swift
 
 This is an extension for ContactsViewController.swift. This is primarily responsible for 
 the pop-up notifications when users deal with friend requests they have recieved AND sent.
 
 */

extension ContactsViewController {
    
    
    // calls other main functions. Contains and configures uiviewOverlayGrayOpaque variable to 
    // set up the "background blur effect" when the pop-up menu occurs.
    func setupViews() {
        setupChooseAnActionAlert()
        setupNoti()
        uiviewOverlayGrayOpaque = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewOverlayGrayOpaque.backgroundColor = UIColor._107107107()
        uiviewOverlayGrayOpaque.alpha = 0
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (closeBoth))
        uiviewOverlayGrayOpaque.addGestureRecognizer(gesture)
        self.view.addSubview(uiviewOverlayGrayOpaque)
    }
    
    // this function reveals the "noti" UI, and changes texts depending on the type needed/requested.
    // 0 is for block, 1 is for withdrawing a request, and 2 is to resend a request.
    func showNoti(type: Int) {
        closeChooseNoti()
        self.uiviewOverlayGrayOpaque.alpha = 0.7
        self.view.bringSubview(toFront: uiviewOverlayGrayOpaque)
        self.view.bringSubview(toFront: uiviewNotification)
        UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.uiviewNotification.alpha = 1
            self.uiviewOverlayGrayOpaque.alpha = 0.7
        }, completion: nil)
        if (type == 0){
            notiContraint = view.returnConstraintsWithFormat("V:|-200-[v0(208)]", options: [], views: uiviewNotification)
            lblNotificationText.text = "Are you sure you want to block this person?"
            btnYes.tag = 0
            lblBlockSetting.alpha = 1
        } else if(type == 1) {
            lblBlockSetting.alpha = 0
            notiContraint = view.returnConstraintsWithFormat("V:|-200-[v0(161)]", options: [], views: uiviewNotification)
            lblNotificationText.text = "Are you sure you want to withdraw this request?"
            btnYes.tag = 1
        } else if(type == 2) {
            lblBlockSetting.alpha = 0
            notiContraint = view.returnConstraintsWithFormat("V:|-200-[v0(161)]", options: [], views: uiviewNotification)
            lblNotificationText.text = "Are you sure you want to resend this request?"
            btnYes.tag = 2
        }
    }
    
    // this function stops revealing both the "noti" UI and the "chooseNoti" UI by calling both functions.
    func closeBoth() {
        closeNoti()
        closeChooseNoti()
    }
    
    // this function stops revealing the "noti" UI, and makes it invisible.
    func closeNoti() {
        uiviewNotification.alpha = 0
        uiviewOverlayGrayOpaque.alpha = 0
    }
    
    // this function stops revealing the "chooseNoti" UI, and makes it invisible.
    func closeChooseNoti() {
        uiviewChooseAction.alpha = 0
        uiviewOverlayGrayOpaque.alpha = 0
    }
    
    // this function configures the "noti" UI.
    func setupNoti() {
        uiviewNotification = UIView()
        uiviewNotification.backgroundColor = .white
        uiviewNotification.layer.cornerRadius = 19
        uiviewNotification.alpha = 0
        view.addSubview(uiviewNotification)
        view.addConstraintsWithFormat("H:|-62-[v0(290)]|", options: [], views: uiviewNotification)
        view.addConstraintsWithFormat("V:|-200-[v0(208)]", options: [], views: uiviewNotification)
        
        // For the close button.
        btnClose = UIButton()
        btnClose.setImage(#imageLiteral(resourceName: "btn_close"), for: .normal)
        uiviewNotification.addSubview(btnClose)
        view.addConstraintsWithFormat("H:|-0-[v0(47)]|", options: [], views: btnClose)
        view.addConstraintsWithFormat("V:|-0-[v0(45)]", options: [], views: btnClose)
        
        // adding trigger for btnClose (calls closeNoti()).
        btnClose.addTarget(
            self,
            action: #selector(self.closeNoti),
            for: .touchUpInside)
        
        // configuring the text/pop-up for "confirming you want to block this person"
        lblNotificationText = UILabel()
        lblNotificationText.text = "Are you sure you want to block this person?"
        lblNotificationText.textAlignment = .center
        lblNotificationText.textColor = UIColor(r: 89, g: 89, b: 89, alpha: 100)
        lblNotificationText.numberOfLines = 2
        lblNotificationText.font = UIFont(name: "AvenirNext-Medium", size: 18)
        uiviewNotification.addSubview(lblNotificationText)
        view.addConstraintsWithFormat("H:|-41-[v0(210)]|", options: [], views: lblNotificationText)
        view.addConstraintsWithFormat("V:|-30-[v0(50)]", options: [], views: lblNotificationText)
        
        // configuring description for blocking mechanism
        lblBlockSetting = UILabel()
        lblBlockSetting.text = "He/She will be found in your Blocked List in Settings > AccountOptions."
        lblBlockSetting.textAlignment = .center
        lblBlockSetting.textColor = UIColor(r: 138, g: 138, b: 138, alpha: 100)
        lblBlockSetting.numberOfLines = 2
        lblBlockSetting.font = UIFont(name: "AvenirNext-Medium", size: 13)
        uiviewNotification.addSubview(lblBlockSetting)
        view.addConstraintsWithFormat("H:|-34.5-[v0(222)]|", options: [], views: lblBlockSetting)
        view.addConstraintsWithFormat("V:|-93-[v0(36)]", options: [], views: lblBlockSetting)
        
        // the "yes" button
        btnYes = UIButton()
        uiviewNotification.addSubview(btnYes)
        btnYes.layer.cornerRadius = 19
        let titleAttrForBtnYes = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18), NSForegroundColorAttributeName: UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 100)]
        let attributedTitleForBtnYes = NSAttributedString(string: "Yes", attributes: titleAttrForBtnYes as Any as? [String : Any])
        btnYes.setAttributedTitle(attributedTitleForBtnYes, for: .normal)
        btnYes.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1)
        view.addConstraintsWithFormat("H:|-41-[v0(209)]|", options: [], views: btnYes)
        view.addConstraintsWithFormat("V:[v0(39)]-20-|", options: [], views: btnYes)
        
        // adding trigger for btnYes (calls yesButtonFunction).
        btnYes.addTarget(
            self,
            action: #selector(yesButtonFunction(button:)),
            for: .touchUpInside)
    }
    
    // this function configures the "choose an action" UI.
    func setupChooseAnActionAlert() {
        uiviewChooseAction = UIView(frame: CGRect(x: 62, y: 200, width: 290, height: 302))
        uiviewChooseAction.backgroundColor = .white
        uiviewChooseAction.layer.cornerRadius = 20
        uiviewChooseAction.alpha = 0
        view.addSubview(uiviewChooseAction)
        
        // For the title"choose an action"
        lblTitleInActions = UILabel()
        uiviewChooseAction.addSubview(lblTitleInActions)
        lblTitleInActions.textAlignment = .center
        lblTitleInActions.text = "Choose an action"
        lblTitleInActions.font = UIFont(name: "AvenirNext-Medium", size: 18)
        view.addConstraintsWithFormat("H:|-13-[v0(263.5)]|", options: [], views: lblTitleInActions)
        view.addConstraintsWithFormat("V:|-20-[v0(25)]", options: [], views: lblTitleInActions)
        
        // For the first action "Ignore"
        btnForIgnore = UIButton()
        uiviewChooseAction.addSubview(btnForIgnore)
        btnForIgnore.layer.cornerRadius = 25
        // we need the api request here to ignore the current request
        btnForIgnore.addTarget(self, action: #selector(ignoreRequest), for: .touchUpInside)
        let titleAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18), NSForegroundColorAttributeName: UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 100)]
        let attributedTitleForIgnore = NSAttributedString(string: "Ignore", attributes: titleAttr as Any as? [String : Any])
        btnForIgnore.setAttributedTitle(attributedTitleForIgnore, for: .normal)
        btnForIgnore.layer.borderWidth = 2
        btnForIgnore.layer.borderColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 100).cgColor
        view.addConstraintsWithFormat("H:|-41-[v0(208)]|", options: [], views: btnForIgnore)
        view.addConstraintsWithFormat("V:|-65-[v0(50)]", options: [], views: btnForIgnore)
        
        //For the second action "Block"
        btnForBlock = UIButton()
        uiviewChooseAction.addSubview(btnForBlock)
        btnForBlock.layer.cornerRadius = 25
        btnForBlock.addTarget(self, action: #selector(confirmBlockRequest), for: .touchUpInside)
        let attributedTitleForBlock = NSAttributedString(string: "Block", attributes: titleAttr as Any as? [String : Any])
        btnForBlock.setAttributedTitle(attributedTitleForBlock, for: .normal)
        btnForBlock.setTitleColor(UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1), for: .normal)
        btnForBlock.layer.borderWidth = 2
        btnForBlock.layer.borderColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1).cgColor
        view.addConstraintsWithFormat("H:|-41-[v0(208)]|", options: [], views: btnForBlock)
        view.addConstraintsWithFormat("V:|-130-[v0(50)]", options: [], views: btnForBlock)
        
        //For the third action "Report"
        btnForReport = UIButton()
        uiviewChooseAction.addSubview(btnForReport)
        btnForReport.layer.cornerRadius = 25
        let attributedTitleForReport = NSAttributedString(string: "Report", attributes: titleAttr as Any as? [String : Any])
        btnForReport.setAttributedTitle(attributedTitleForReport, for: .normal)
        btnForReport.setTitleColor(UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1), for: .normal)
        btnForReport.layer.borderWidth = 2
        btnForReport.layer.borderColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1).cgColor
        view.addConstraintsWithFormat("H:|-41-[v0(208)]|", options: [], views: btnForReport)
        view.addConstraintsWithFormat("V:|-195-[v0(50)]", options: [], views: btnForReport)
        
        //For the fourth action "Cancel"
        btnForCancel = UIButton()
        uiviewChooseAction.addSubview(btnForCancel)
        let attributedTitleForCancel = NSAttributedString(string: "Cancel", attributes: titleAttr as Any as? [String : Any])
        btnForCancel.setAttributedTitle(attributedTitleForCancel, for: .normal)
        btnForCancel.setTitleColor(UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1), for: .normal)
        view.addConstraintsWithFormat("H:|-41-[v0(208)]|", options: [], views: btnForCancel)
        view.addConstraintsWithFormat("V:|-262-[v0(50)]", options: [], views: btnForCancel)
        btnForCancel.addTarget(
            self,
            action: #selector(self.closeChooseNoti),
            for: .touchUpInside)
    }
    
    // this function shows the "choose an action" UI
    func chooseAnAction() {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.uiviewChooseAction.alpha = 1.0
            self.uiviewOverlayGrayOpaque.alpha = 0.7
        }, completion: nil)
        self.view.bringSubview(toFront: uiviewOverlayGrayOpaque)
        self.view.bringSubview(toFront: uiviewChooseAction)
    }
    
    // triggered when "yes" button is clicked.
    // 0 is for block, 1 is for withdrawing a request, and 2 is to resend a request.
    func yesButtonFunction(button: UIButton) {
        closeNoti()
        if (button.tag == 0) {
            blockRequest()
        }
        else if (button.tag == 1) {
            withdrawRequest()
        }
        else if (button.tag == 2) {
        }
    }
    
    func withdrawRequest() {
        // call api to withdraw this request
        animateWithdrawal(listType: 2)
    }
    
    func ignoreRequest() {
        //api request here
        animateWithdrawal(listType: 1)
        closeChooseNoti()
    }
    
    func confirmBlockRequest() {
        self.showNoti(type: 0)
    }
    
    func blockRequest() {
        // api request
        animateWithdrawal(listType: 1)
    }
}
