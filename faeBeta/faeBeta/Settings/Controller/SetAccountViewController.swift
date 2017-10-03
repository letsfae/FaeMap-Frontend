//
//  SetAccountViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/11.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uiviewNavBar: FaeNavBar!
    var arrTitle: [String] = ["Name", "Birthday", "Gender", "Email", "Username", "Phone", "Change Password", "Deactivate Account", "Close Account"]
    var tblAccount: UITableView!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        uiviewNavBar = FaeNavBar(frame:.zero)
        self.navigationController?.isNavigationBarHidden = true
        view.addSubview(uiviewNavBar)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.lblTitle.text = "Fae Account"
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
        
        tblAccount = UITableView()
        view.addSubview(tblAccount)
        tblAccount.delegate = self
        tblAccount.dataSource = self
        tblAccount.register(SetAccountCell.self, forCellReuseIdentifier: "accountCell")
        tblAccount.separatorStyle = .none
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: tblAccount)
        view.addConstraintsWithFormat("V:|-65-[v0]-0-|", options: [], views: tblAccount)
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath as IndexPath) as!SetAccountCell
        cell.lblTitle.text = arrTitle[indexPath.row]
        cell.lblContent.text = arrTitle[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 7:
            navigationController?.pushViewController(SetDeactiveViewController(), animated: true)
            break
        case 8:
            navigationController?.pushViewController(SetCloseViewController(), animated: true)
            break
        default:
            break
        }
    }
}
