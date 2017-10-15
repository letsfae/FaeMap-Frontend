//
//  SetAboutViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/11.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetAboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var uiviewNavBar: FaeNavBar!
    var arrAboutString: [String] = ["Company", "About Fae Map", "Fae Map Website", "Terms of Service", "Privacy Policy"]
    var tblAbout: UITableView!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        uiviewNavBar = FaeNavBar(frame:.zero)
        view.addSubview(uiviewNavBar)
        self.navigationController?.isNavigationBarHidden = true
        uiviewNavBar.lblTitle.text = "About"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
        
        tblAbout = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        view.addSubview(tblAbout)
        tblAbout.separatorStyle = .none
        tblAbout.delegate = self
        tblAbout.dataSource = self
        tblAbout.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
        tblAbout.estimatedRowHeight = 60
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAboutString.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as!GeneralTitleCell
        cell.switchIcon.isHidden = true
        cell.lblDes.isHidden = true
        cell.imgView.isHidden = false
        cell.setContraintsForDes()
        cell.lblName.text = arrAboutString[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(SetFaeInc(), animated: true)
            break
        case 1:
            navigationController?.pushViewController(SetFaeMap(), animated: true)
            break
        case 2:
            navigationController?.pushViewController(SetDeactiveViewController(), animated: true)
        default:
            break
        }
        
    }
}
