//
//  YingNav.swift
//  FaeContacts
//
//  Created by ying chen on 2017/6/13.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit
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
        btnNavBarSetTitle()
    }
    
    func loadDropDownMenu() {
        blurViewDropDownMenu = UIVisualEffectView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 103))
        if #available(iOS 10.0, *) {
            blurViewDropDownMenu.effect = UIBlurEffect(style: .regular)
        } else {
            // Fallback on earlier versions
            blurViewDropDownMenu.effect = UIBlurEffect(style: .light)
        }
        view.addSubview(blurViewDropDownMenu)
        blurViewDropDownMenu.frame.origin.y = -39 // 64 - 103
        
        // Line at y = 103 inside the blurViewDropDownMenu
        let bottomLine = UIView(frame: CGRect(x: 0, y: 103, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = screenWidth
        bottomLine.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
        blurViewDropDownMenu.addSubview(bottomLine)
        
        btnTop = UIButton(frame: CGRect(x: (screenWidth - 200) / 2, y: 3, width: 200, height: 45))
        blurViewDropDownMenu.addSubview(btnTop)
        btnTop.tag = 0
        btnTop.setTitle(titleArray[0], for: .normal)
        btnTop.setTitleColor(UIColor.faeAppInputTextGrayColor(), for: .normal)
        btnTop.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnTop.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnBottom = UIButton(frame: CGRect(x: (screenWidth - 200) / 2, y: 55, width: 200, height: 45))
        blurViewDropDownMenu.addSubview(btnBottom)
        btnBottom.tag = 1
        btnBottom.setTitle(titleArray[1], for: .normal)
        btnBottom.setTitleColor(UIColor.faeAppInputTextGrayColor(), for: .normal)
        btnBottom.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnBottom.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        let uiviewDropMenuLineTop = UIView(frame: CGRect(x: (screenWidth - 280) / 2, y: 51, width: 280, height: 1))
        blurViewDropDownMenu.addSubview(uiviewDropMenuLineTop)
        uiviewDropMenuLineTop.backgroundColor = UIColor(red: 206 / 255, green: 203 / 255, blue: 203 / 255, alpha: 1)

    }
    
    // function for drop down menu button, to show / hide the drop down menu (UIVisualView)
    func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            UIView.animate(withDuration: 0.2, animations: {
                self.blurViewDropDownMenu.frame.origin.y = 64
            })
            btnNavBarSetTitle()
            navBarMenuBtnClicked = true
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.blurViewDropDownMenu.frame.origin.y = -39
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // function for buttons in drop down menu
    func dropDownMenuAct(_ sender: UIButton) {
        
        /* Comment from Joshua:
         I comment the following codes you wrote, and replace them by the following 3 lines for efficiency
         */
        let temp = titleArray[sender.tag]
        titleArray[sender.tag] = curtTitle
        curtTitle = temp
        
//        if sender.tag == 0 {
//            let temp = titleArray[0]
//            titleArray[0] = curtTitle
//            curtTitle = temp
//        } else if sender.tag == 1 {
//            let temp = titleArray[1]
//            titleArray[1] = curtTitle
//            curtTitle = temp
//        }
        
        titleArray.sort { $0.characters.count < $1.characters.count }
        btnTop.setTitle(titleArray[0], for: .normal)
        btnBottom.setTitle(titleArray[1], for: .normal)
        btnNavBarSetTitle()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.blurViewDropDownMenu.frame.origin.y = -92
        })
        
        navBarMenuBtnClicked = false
    }
    
    fileprivate func btnNavBarSetTitle() {
        let curtTitleAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "btn_down")
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnNavBarMenu.setAttributedTitle(curtTitlePlusImg, for: .normal)
        if curtTitle == "Friends" {
            uiviewNavBar.rightBtn.isHidden = false
        } else {
            uiviewNavBar.rightBtn.isHidden = true
        }
    }
}
