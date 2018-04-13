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
    
    // MARK: - setup UI
    func loadNavBar() {
        loadDropDownMenu()
        
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.addConstraintsWithFormat("H:|-0-[v0(40.5)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(22+device_offset_top)-[v0(38)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(17+device_offset_top)-[v0(48)]", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(backToMenu(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(goToAddFriendView(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.addGestureRecognizer(tapDismissGestureOnDropdownMenu())
        
        btnNavBarMenu = UIButton()
        uiviewNavBar.addSubview(btnNavBarMenu)
        view.addConstraintsWithFormat("H:|-100-[v0]-100-|", options: [], views: btnNavBarMenu)
        view.addConstraintsWithFormat("V:|-\(28+device_offset_top)-[v0(27)]", options: [], views: btnNavBarMenu)
        btnNavBarMenu.addTarget(self, action: #selector(toggleNavBarMenu(_:)), for: .touchUpInside)
        btnNavBarSetTitle()
    }
    
    func loadDropDownMenu() {
        uiviewDropDownMenu = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 101))
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
        btnTop.addTarget(self, action: #selector(dropDownMenuAct(_:)), for: .touchUpInside)
        btnTop.backgroundColor = .clear
        
        btnBottom = UIButton(frame: CGRect(x: 0, y: 51, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnBottom)
        btnBottom.tag = 1
        btnBottom.addTarget(self, action: #selector(dropDownMenuAct(_:)), for: .touchUpInside)
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
        
        imgDot = UIImageView(frame: CGRect(x: 30, y: 74, width: 8, height: 8))
        imgDot.image = #imageLiteral(resourceName: "verification_dot")
        uiviewDropDownMenu.addSubview(imgDot)
        imgDot.isHidden = true
        
        lblBottom = UILabel(frame: CGRect(x: 104, y: 15, width: 150, height: 25))
        lblBottom.textColor = UIColor._898989()
        lblBottom.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnBottom.addSubview(lblBottom)
        updateUserCount()
        
        let uiviewDropMenuLineTop = UIView(frame: CGRect(x: 41, y: 50, width: screenWidth - 82, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuLineTop)
        uiviewDropMenuLineTop.backgroundColor = UIColor._206203203()
        
        imgTick = UIImageView(frame: CGRect(x: screenWidth - 70, y: 20, width: 16, height: 16))
        imgTick.image = #imageLiteral(resourceName: "mb_tick")
        uiviewDropDownMenu.addSubview(imgTick)
    }
    
    // MARK: - helper functions
    // left button action
    @objc fileprivate func backToMenu(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // right button action
    @objc fileprivate func goToAddFriendView(_ sender: UIButton) {
        let vc = AddFriendViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // a tap gesture to hide drop down menu
    func tapDismissGestureOnDropdownMenu() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rollUpDropDownMenu(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        return tapRecognizer
    }
    
    @objc func rollUpDropDownMenu(_ sender: UITapGestureRecognizer) {
        hideDropdowmMenu()
    }
    
    // nav bar menu action
    @objc fileprivate func toggleNavBarMenu(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = 65 + device_offset_top
            })
            navBarMenuBtnClicked = true
            btnNavBarSetTitle()
            updateUserCount()
        } else {
            hideDropdowmMenu()
        }
        schbarContacts.txtSchField.resignFirstResponder()
    }
    
    func hideDropdowmMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -36 + device_offset_top
        })
        navBarMenuBtnClicked = false
        btnNavBarSetTitle()
    }
    
    // drop down menu action
    @objc func dropDownMenuAct(_ sender: UIButton) {
        curtTitle = titleArray[sender.tag]
        
        if sender.tag == 0 {
            imgTick.frame.origin.y = 20
            uiviewNavBar.rightBtn.isHidden = false
            uiviewBottomNav.isHidden = true
            uiviewSchbar.isHidden = false
            cellStatus = 0
            tblContacts.frame = CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - device_offset_top)
            faeScrollBar?.isHidden = false
        } else {
            imgTick.frame.origin.y = 71
            uiviewNavBar.rightBtn.isHidden = true
            uiviewBottomNav.isHidden = false
            uiviewSchbar.isHidden = true
            cellStatus = btnFFF.isSelected ? 1 : 2
            tblContacts.frame = CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - 49 - device_offset_top - device_offset_bot)
            faeScrollBar?.isHidden = true
        }
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -92
        })
        navBarMenuBtnClicked = false
        btnNavBarSetTitle()
        switchRealmObserverTarget()
        //tblContacts.reloadData()
        //tblContacts.scrollToTop(animated: false)
        //tblContacts.setContentOffset(CGPoint.zero, animated: false)
    }
    
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
    
    // update the count in the drop down menu
    fileprivate func updateUserCount() {
        let attributedStr = NSMutableAttributedString()
        let strFriends = NSAttributedString(string: "Friends ", attributes: [NSAttributedStringKey.foregroundColor : UIColor._898989()])
        let count = NSAttributedString(string: "(\(realmFriends.count))", attributes: [NSAttributedStringKey.foregroundColor : UIColor._155155155()])
        attributedStr.append(strFriends)
        attributedStr.append(count)
        
        lblTop.attributedText = attributedStr
        
        let attributedStr2 = NSMutableAttributedString()
        if cellStatus == 1 {
            countRequests = realmReceivedRequests.count
        } else if cellStatus == 2 {
            countRequests = realmSentRequests.count
        } else {
            countRequests = realmReceivedRequests.count + realmSentRequests.count
        }
        let strRequests = NSAttributedString(string: "Requests ", attributes: [NSAttributedStringKey.foregroundColor : UIColor._898989()])
        let strTotal = NSAttributedString(string: "(\(countRequests))", attributes: [NSAttributedStringKey.foregroundColor : UIColor._155155155()])
        attributedStr2.append(strRequests)
        attributedStr2.append(strTotal)
        
        lblBottom.attributedText = attributedStr2
        
        imgDot.isHidden = realmReceivedRequests.count == 0
    }
}
