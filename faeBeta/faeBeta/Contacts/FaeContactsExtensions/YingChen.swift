//
//  YingNav.swift
//  FaeContacts
//
//  Created by ying chen on 2017/6/13.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

extension ContactsViewController {
    
    func loadNavBar() {
        loadDropDownMenu()
        
        // Initialize the navigation bar.
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
//        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.addConstraintsWithFormat("H:|-0-[v0(40.5)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-17-[v0(48)]", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
        
        // Initialize the navigation bar menu
        //        btnNavBarMenu = UIButton(frame: CGRect(x: (screenWidth-140)/2, y: 24, width: 140, height: 42))
        btnNavBarMenu = UIButton()
        uiviewNavBar.addSubview(btnNavBarMenu)
        view.addConstraintsWithFormat("H:|-100-[v0]-100-|", options: [], views: btnNavBarMenu)
        view.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: btnNavBarMenu)
        btnNavBarMenu.addTarget(self, action: #selector(navBarMenuAct(_:)), for: .touchUpInside)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.backToMenu(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(self.goToAddFriendView(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.addGestureRecognizer(setTapDismissDropdownMenu())
        btnNavBarSetTitle()
    }
    
    func loadDropDownMenu() {
        uiviewDropDownMenu = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 101))
        uiviewDropDownMenu.backgroundColor = .white
        view.addSubview(uiviewDropDownMenu)
        uiviewDropDownMenu.frame.origin.y = -36 // 65 - 101
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 100, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = screenWidth
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewDropDownMenu.addSubview(bottomLine)
        
        btnTop = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnTop)
        btnTop.tag = 0
        btnTop.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        btnTop.backgroundColor = .clear
        
        btnBottom = UIButton(frame: CGRect(x: 0, y: 51, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnBottom)
        btnBottom.tag = 1
        btnBottom.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        btnBottom.backgroundColor = .clear
        
        let imgTop = UIImageView(frame: CGRect(x: 56, y: 14, width: 28, height: 28))
        let imgBottom = UIImageView(frame: CGRect(x: 56, y: 14, width: 28, height: 28))
        imgTop.image = #imageLiteral(resourceName: "contact_friends")
        imgBottom.image = #imageLiteral(resourceName: "contact_requests")
        btnTop.addSubview(imgTop)
        btnBottom.addSubview(imgBottom)
        
        lblTop = UILabel(frame: CGRect(x: 104, y: 15, width: 150, height: 25))
        lblTop.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnTop.addSubview(lblTop)
        
        lblBottom = UILabel(frame: CGRect(x: 104, y: 15, width: 150, height: 25))
        lblBottom.textColor = UIColor._898989()
        lblBottom.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnBottom.addSubview(lblBottom)
        updateFriendCount()
        
        let uiviewDropMenuLineTop = UIView(frame: CGRect(x: 41, y: 50, width: screenWidth - 82, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuLineTop)
        uiviewDropMenuLineTop.backgroundColor = UIColor._206203203()
        
        imgTick = UIImageView(frame: CGRect(x: screenWidth - 70, y: 20, width: 16, height: 16))
        imgTick.image = #imageLiteral(resourceName: "mb_tick")
        uiviewDropDownMenu.addSubview(imgTick)
        
        imgDot = UIImageView(frame: CGRect(x: 30, y: 74, width: 8, height: 8))
        imgDot.image = #imageLiteral(resourceName: "verification_dot")
        uiviewDropDownMenu.addSubview(imgDot)
        imgDot.isHidden = true
    }
    
    fileprivate func updateFriendCount() {
        let attributedStr = NSMutableAttributedString()
        let strFriends = NSAttributedString(string: "Friends ", attributes: [NSAttributedStringKey.foregroundColor : UIColor._898989()])
        let count = NSAttributedString(string: "(\(countFriends))", attributes: [NSAttributedStringKey.foregroundColor : UIColor._155155155()])
        attributedStr.append(strFriends)
        attributedStr.append(count)
        
        lblTop.attributedText = attributedStr
        
        let attributedStr2 = NSMutableAttributedString()
        if cellStatus == 1 {
            countRequests = countReceived
        } else if cellStatus == 2 {
            countRequests = countSent
        } else {
            countRequests = countReceived + countSent
        }
        let strRequests = NSAttributedString(string: "Requests ", attributes: [NSAttributedStringKey.foregroundColor : UIColor._898989()])
        let strTotal = NSAttributedString(string: "(\(countRequests))", attributes: [NSAttributedStringKey.foregroundColor : UIColor._155155155()])
        attributedStr2.append(strRequests)
        attributedStr2.append(strTotal)
        
        lblBottom.attributedText = attributedStr2
    }
    
    func setTapDismissDropdownMenu() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rollUpDropDownMenu(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        return tapRecognizer
    }
    
    @objc func rollUpDropDownMenu(_ sender: UITapGestureRecognizer) {
        hideDropdowmMenu()
    }
    
    // function for drop down menu button, to show / hide the drop down menu (UIVisualView)
    @objc func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = 65
            })
            navBarMenuBtnClicked = true
            btnNavBarSetTitle()
            updateFriendCount()
        } else {
            hideDropdowmMenu()
        }
        schbarContacts.txtSchField.resignFirstResponder()
    }
    
    func hideDropdowmMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -36
        })
        navBarMenuBtnClicked = false
        btnNavBarSetTitle()
    }
    
    @objc func backToMenu(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // function to move onto addFriendViewController swift scene
    @objc func goToAddFriendView(_ sender: UIButton) {
        let vc = AddFriendViewController()
        vc.arrFriends = arrFriends
        vc.arrReceivedRequests = arrReceivedRequests
        vc.arrRequested = arrRequested
        self.navigationController?.pushViewController(vc, animated: true)
        getContacts()
    }
    
    fileprivate func getContacts() {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        if (authStatus == CNAuthorizationStatus.notDetermined) {
            contactStore.requestAccess(for: entityType, completionHandler: {_,_ in })
        }
    }
    
    // function for buttons in drop down menu
    @objc func dropDownMenuAct(_ sender: UIButton) {
        curtTitle = titleArray[sender.tag]
        
        if sender.tag == 0 {
            getFriendsList()
            imgTick.frame.origin.y = 20
            uiviewNavBar.rightBtn.isHidden = false
            uiviewBottomNav.isHidden = true
            uiviewSchbar.isHidden = false
            tblContacts.frame.origin.y = 114
            cellStatus = 0
        } else {
            imgTick.frame.origin.y = 71
            uiviewNavBar.rightBtn.isHidden = true
            uiviewBottomNav.isHidden = false
            uiviewSchbar.isHidden = true
            tblContacts.frame.origin.y = 65
            cellStatus = btnFFF.isSelected ? 1 : 2
        }
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -92
        })
        navBarMenuBtnClicked = false
        btnNavBarSetTitle()
        
//        switchFriendsAndFollows()
        tblContacts.reloadData()
    }
    
//    fileprivate func switchFriendsAndFollows() {
//        if curtTitle == "Friends" {
//
//        } else if curtTitle == "Followers" {
//
//        } else {   // curtTitle == "Following"
//
//        }
//    }
    
    fileprivate func btnNavBarSetTitle() {
        let curtTitleAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        if navBarMenuBtnClicked {
            downAttachment.image = #imageLiteral(resourceName: "btn_up")
        } else {
            downAttachment.image = #imageLiteral(resourceName: "btn_down")
        }
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnNavBarMenu.setAttributedTitle(curtTitlePlusImg, for: .normal)
    }
}
