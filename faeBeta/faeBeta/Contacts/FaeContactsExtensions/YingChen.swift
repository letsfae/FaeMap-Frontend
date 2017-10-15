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
        uiviewNavBar.loadBtnConstraints()
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
        uiviewDropDownMenu = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 103))
        uiviewDropDownMenu.backgroundColor = .white
        view.addSubview(uiviewDropDownMenu)
        uiviewDropDownMenu.frame.origin.y = -39 // 64 - 103
        
        // Line at y = 103 inside the blurViewDropDownMenu
        let bottomLine = UIView(frame: CGRect(x: 0, y: 103, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = screenWidth
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewDropDownMenu.addSubview(bottomLine)
        
        btnTop = UIButton(frame: CGRect(x: 41, y: 0, width: 200, height: 50))
        uiviewDropDownMenu.addSubview(btnTop)
        btnTop.tag = 0
//        btnTop.setTitle(titleArray[0], for: .normal)
//        btnTop.setTitleColor(UIColor._898989(), for: .normal)
//        btnTop.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnTop.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnBottom = UIButton(frame: CGRect(x: 41, y: 52, width: 200, height: 50))
        uiviewDropDownMenu.addSubview(btnBottom)
        btnBottom.tag = 1
//        btnBottom.setTitle(titleArray[1], for: .normal)
//        btnBottom.setTitleColor(UIColor._898989(), for: .normal)
//        btnBottom.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnBottom.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        let imgTop = UIImageView(frame: CGRect(x: 15, y: 14, width: 28, height: 28))
        let imgBottom = UIImageView(frame: CGRect(x: 15, y: 14, width: 28, height: 28))
        imgTop.image = #imageLiteral(resourceName: "FFFselected")
        imgBottom.image = #imageLiteral(resourceName: "RRselected")
        btnTop.addSubview(imgTop)
        btnBottom.addSubview(imgBottom)
        
        lblTop = UILabel(frame: CGRect(x: 63, y: 16, width: 100, height: 25))
        lblTop.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnTop.addSubview(lblTop)
        updateFriendCount()
        
        lblBottom = UILabel(frame: CGRect(x: 63, y: 16, width: 100, height: 25))
        lblBottom.textColor = UIColor._898989()
        lblBottom.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblBottom.text = "Requests"
        btnBottom.addSubview(lblBottom)
        
        let uiviewDropMenuLineTop = UIView(frame: CGRect(x: (screenWidth - 280) / 2, y: 51, width: 280, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuLineTop)
        uiviewDropMenuLineTop.backgroundColor = UIColor(red: 206 / 255, green: 203 / 255, blue: 203 / 255, alpha: 1)
        
        imgTick = UIImageView(frame: CGRect(x: screenWidth - 75, y: 20, width: 16, height: 16))
        imgTick.image = #imageLiteral(resourceName: "mb_tick")
        uiviewDropDownMenu.addSubview(imgTick)
    }
    
    fileprivate func updateFriendCount() {
        let attributedStr = NSMutableAttributedString()
        let strFriends = NSAttributedString(string: "Friends ", attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        let count = NSAttributedString(string: "(\(countFriends))", attributes: [NSForegroundColorAttributeName : UIColor._155155155()])
        attributedStr.append(strFriends)
        attributedStr.append(count)
        
        lblTop.attributedText = attributedStr
        
        
//        let lastNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[arrSelected.count - 1]].nickName + ",", attributes: [NSForegroundColorAttributeName : UIColor._2499090()])
//        attributedStrM.append(lastNS)
//        strLastTextField = strLastTextField + arrFriends[arrSelected[arrSelected.count - 1]].nickName + ","
//
//        let changeColor : NSAttributedString = NSAttributedString(string: " ", attributes: [NSForegroundColorAttributeName : UIColor._898989()])
//        attributedStrM.append(changeColor)
//
//        let newSearchWord : NSAttributedString = NSAttributedString(string: moreWord, attributes: [NSForegroundColorAttributeName : UIColor._898989()])
//        attributedStrM.append(newSearchWord)
//        strLastTextField = strLastTextField + moreWord
//
//        searchField.attributedText = attributedStrM
    }
    
    func setTapDismissDropdownMenu() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rollUpDropDownMenu(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        return tapRecognizer
    }
    
    func rollUpDropDownMenu(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -39
        })
        navBarMenuBtnClicked = false
        schbarContacts.txtSchField.resignFirstResponder()
    }
    
    // function for drop down menu button, to show / hide the drop down menu (UIVisualView)
    func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = 64
            })
            btnNavBarSetTitle()
            updateFriendCount()
            navBarMenuBtnClicked = true
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = -39
            })
            btnNavBarSetTitle()
            navBarMenuBtnClicked = false
        }
    }
    
    func backToMenu(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // function to move onto addFriendViewController swift scene
    func goToAddFriendView(_ sender: UIButton) {
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
    func dropDownMenuAct(_ sender: UIButton) {
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
            imgTick.frame.origin.y = 62
            uiviewNavBar.rightBtn.isHidden = true
            uiviewBottomNav.isHidden = false
            uiviewSchbar.isHidden = true
            tblContacts.frame.origin.y = 65
            cellStatus = btnFFF.isSelected ? 1 : 2
        }
        
        btnNavBarSetTitle()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -92
        })
        navBarMenuBtnClicked = false
        
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
        let curtTitleAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor._898989()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "btn_down")
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnNavBarMenu.setAttributedTitle(curtTitlePlusImg, for: .normal)
    }
}
