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
        createActivityIndicator()
    }
    
    fileprivate func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        
        view.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
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
        if type == BLOCK {
            btnYes.tag = type
            uiviewNotification.frame.size.height = 208 * screenHeightFactor
            lblNotificationText.text = "Are you sure you want \nto block this person?"
            lblBlockSetting.alpha = 1
        } else {
            btnYes.tag = type
            lblBlockSetting.alpha = 0
            uiviewNotification.frame.size.height = 161 * screenHeightFactor
            if type == WITHDRAW {
                lblNotificationText.text = "Are you sure you want \nto withdraw this request?"
            } else if type == RESEND {
                lblNotificationText.text = "Are you sure you want \nto resend this request?"
            } else {
                btnYes.tag = OK
                btnYes.setTitle("OK", for: .normal)
            }
        }
    }
    
    // this function stops revealing both the "noti" UI and the "chooseNoti" UI by calling both functions.
    @objc func closeBoth() {
        closeNoti()
        closeChooseNoti()
    }
    
    // this function stops revealing the "noti" UI, and makes it invisible.
    @objc func closeNoti() {
        uiviewNotification.alpha = 0
        uiviewOverlayGrayOpaque.alpha = 0
    }
    
    // this function stops revealing the "chooseNoti" UI, and makes it invisible.
    @objc func closeChooseNoti() {
        uiviewChooseAction.alpha = 0
        uiviewOverlayGrayOpaque.alpha = 0
    }
    
    // this function configures the "noti" UI.
    func setupNoti() {
        uiviewNotification = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 208))
        uiviewNotification.center.x = screenWidth / 2
        uiviewNotification.backgroundColor = .white
        uiviewNotification.layer.cornerRadius = 19
        uiviewNotification.alpha = 0
        view.addSubview(uiviewNotification)
        
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
        lblNotificationText = UILabel(frame: CGRect(x: 0, y: 30, w: 290, h: 50))
        lblNotificationText.textAlignment = .center
        lblNotificationText.textColor = UIColor._898989()
        lblNotificationText.numberOfLines = 2
        lblNotificationText.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewNotification.addSubview(lblNotificationText)
        
        // configuring description for blocking mechanism
        lblBlockSetting = UILabel(frame: CGRect(x: 0, y: 93, w: 290, h: 36))
        lblBlockSetting.text = "The User will be found in your \nBlocked List in Settings > Privacy."
        lblBlockSetting.textAlignment = .center
        lblBlockSetting.textColor = UIColor._138138138()
        lblBlockSetting.numberOfLines = 2
        lblBlockSetting.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        uiviewNotification.addSubview(lblBlockSetting)
        
        // the "yes" button
        btnYes = UIButton()
        uiviewNotification.addSubview(btnYes)
        btnYes.layer.cornerRadius = 19 * screenWidthFactor
        btnYes.setTitleColor(.white, for: .normal)
        btnYes.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnYes.backgroundColor = UIColor._2499090()
        btnYes.setTitle("Yes", for: .normal)
        let padding = (290 - 208) / 2 * screenWidthFactor
        uiviewNotification.addConstraintsWithFormat("H:|-\(padding)-[v0]-\(padding)-|", options: [], views: btnYes)
        uiviewNotification.addConstraintsWithFormat("V:[v0(\(39 * screenHeightFactor))]-\(20 * screenHeightFactor)-|", options: [], views: btnYes)
        
        // adding trigger for btnYes (calls yesButtonFunction).
        btnYes.addTarget(
            self,
            action: #selector(yesButtonFunction(button:)),
            for: .touchUpInside)
    }
    
    // this function configures the "choose an action" UI.
    func setupChooseAnActionAlert() {
        uiviewChooseAction = UIView(frame: CGRect(x: 62, y: 200, w: 290, h: 302))
        uiviewChooseAction.backgroundColor = .white
        uiviewChooseAction.layer.cornerRadius = 20
        uiviewChooseAction.alpha = 0
        view.addSubview(uiviewChooseAction)
        
        // For the title"choose an action"
        lblTitleInActions = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 25))
        uiviewChooseAction.addSubview(lblTitleInActions)
        lblTitleInActions.textAlignment = .center
        lblTitleInActions.text = "Choose an Action"
        lblTitleInActions.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        // For the three actions
        btnForIgnore = UIButton(frame: CGRect(x: 41, y: 65, w: 208, h: 50))
        btnForBlock = UIButton(frame: CGRect(x: 41, y: 130, w: 208, h: 50))
        btnForReport = UIButton(frame: CGRect(x: 41, y: 195, w: 208, h: 50))
        btnForIgnore.setTitle("Ignore", for: .normal)
        btnForBlock.setTitle("Block", for: .normal)
        btnForReport.setTitle("Report", for: .normal)
        btnForIgnore.tag = IGNORE
        btnForBlock.tag = BLOCK
        btnForReport.tag = REPORT
        
        var btnActions = [UIButton]()
        btnActions.append(btnForIgnore)
        btnActions.append(btnForBlock)
        btnActions.append(btnForReport)
        
        for i in 0..<btnActions.count {
            btnActions[i].setTitleColor(UIColor._2499090(), for: .normal)
            btnActions[i].titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
            btnActions[i].addTarget(self, action: #selector(sentActRequest(_:)), for: .touchUpInside)
            btnActions[i].layer.borderWidth = 2
            btnActions[i].layer.borderColor = UIColor._2499090().cgColor
            btnActions[i].layer.cornerRadius = 26 * screenWidthFactor
            uiviewChooseAction.addSubview(btnActions[i])
        }
        
        //For the fourth action "Cancel"
        btnForCancel = UIButton()
        btnForCancel.setTitle("Cancel", for: .normal)
        btnForCancel.setTitleColor(UIColor._2499090(), for: .normal)
        btnForCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnForCancel.addTarget(self, action: #selector(closeChooseNoti), for: .touchUpInside)
        uiviewChooseAction.addSubview(btnForCancel)
        view.addConstraintsWithFormat("H:|-80-[v0]-80-|", options: [], views: btnForCancel)
        view.addConstraintsWithFormat("V:[v0(25)]-\(15 * screenHeightFactor)-|", options: [], views: btnForCancel)
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
    @objc func yesButtonFunction(button: UIButton) {
        if button.tag == OK {
            closeNoti()
        } else {
            indicatorView.startAnimating()
            animateWithdrawal(listType: button.tag)
        }
    }
    
    @objc func sentActRequest(_ sender: UIButton) {
        switch sender.tag {
        case IGNORE: // first button - IGNORE
            indicatorView.startAnimating()
            animateWithdrawal(listType: IGNORE)
            break
        case BLOCK: // second button - BLOCK
            self.showNoti(type: BLOCK)
            break
        case REPORT: // third button - REPORT
            let reportPinVC = ReportViewController()
            reportPinVC.reportType = 0
            reportPinVC.modalPresentationStyle = .overCurrentContext
            self.present(reportPinVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
}
