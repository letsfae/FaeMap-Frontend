//
//  RequestsViewController.swift
//  FaeContacts
//
//  Created by 子不语 on 2017/6/22.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit

extension ContactsViewController {
    
    func RequestsPressed() {
        uiviewNavBar.lblTitle.text = "Requests"
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
        uiviewNavBar.lblTitle.isHidden = false
        btnNavBarMenu.isHidden = true
        
        tblContacts.tableHeaderView = nil
        tblContacts.frame = CGRect(x: 0, y: 94, width: screenWidth, height: screenHeight - 65)
        loadTabs()
    }
    
    func loadTabs() {
        uiviewTabView = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 30))
        uiviewTabView.backgroundColor = .white
        view.addSubview(uiviewTabView)
        
        btnReceived = UIButton()
        uiviewTabView.addSubview(btnReceived)
        uiviewTabView.addConstraintsWithFormat("H:|-35-[v0(130)]", options: [], views: btnReceived)
        uiviewTabView.addConstraintsWithFormat("V:|-0-[v0(30)]", options: [], views: btnReceived)
        btnReceived.tag = 0
        btnReceived.setTitle("Received", for: .normal)
        btnReceived.setTitleColor(UIColor._2499090(), for: .normal)
        btnReceived.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnReceived.addTarget(self, action: #selector(self.switchTabs(_:)), for: .touchUpInside)
        
        btnRequested = UIButton()
        uiviewTabView.addSubview(btnRequested)
        btnRequested.tag = 1
        btnRequested.setTitle("Requested", for: .normal)
        btnRequested.setTitleColor(UIColor._146146146(), for: .normal)
        btnRequested.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
        uiviewTabView.addConstraintsWithFormat("H:[v0(130)]-35-|", options: [], views: btnRequested)
        uiviewTabView.addConstraintsWithFormat("V:|-0-[v0(30)]", options: [], views: btnRequested)
        btnRequested.addTarget(self, action: #selector(self.switchTabs(_:)), for: .touchUpInside)
        
        uiviewBottomLine = UIView(frame: CGRect(x: 0, y: uiviewTabView.frame.height - 1, width: screenWidth, height: 1))
        uiviewTabView.addSubview(uiviewBottomLine)
        uiviewBottomLine.backgroundColor = UIColor._200199204()
        
        uiviewRedBottomLine = UIView()
        uiviewTabView.addSubview(uiviewRedBottomLine)
        uiviewRedBottomLine.backgroundColor = UIColor._2499090()
        uiviewTabView.addConstraintsWithFormat("H:|-35-[v0(130)]-0-|", options: [], views: uiviewRedBottomLine)
        uiviewTabView.addConstraintsWithFormat("V:[v0(2)]-0-|", options: [], views: uiviewRedBottomLine)
        
    }
    
    @objc func switchTabs(_ sender: UIButton) {
        var targetCenter: CGFloat = 0
        if sender.tag == 1 {
            cellStatus = 3
            btnRequested.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnRequested.setTitleColor(UIColor._2499090(), for: .normal)
            btnReceived.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            btnReceived.setTitleColor(UIColor._146146146(), for: .normal)
            targetCenter = btnRequested.center.x
        } else {
            cellStatus = 2
            btnReceived.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnReceived.setTitleColor(UIColor._2499090(), for: .normal)
            btnRequested.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            btnRequested.setTitleColor(UIColor._146146146(), for: .normal)
            targetCenter = btnReceived.center.x
        }
        
        // Animation of the red sliding line (Received, Requested)
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewRedBottomLine.center.x = targetCenter
        }), completion: { _ in
        })
        tblContacts.reloadData()
    }
    
}
