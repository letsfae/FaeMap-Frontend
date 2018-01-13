//
//  SetContactViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/11.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uiviewNavbar: FaeNavBar!
    var tblContact: UITableView!
    var arrContact: [String] = ["Say Hello", "Support & Help", "Report Problem", "Provide Feedback", "Questions", "Join Us"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        uiviewNavbar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavbar)
        self.navigationController?.isNavigationBarHidden = true
        uiviewNavbar.lblTitle.text = "Contact"
        uiviewNavbar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavbar.loadBtnConstraints()
        uiviewNavbar.rightBtn.setImage(nil, for: .normal)
        
        tblContact = UITableView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top))
        view.addSubview(tblContact)
        tblContact.delegate = self
        tblContact.dataSource = self
        tblContact.separatorStyle = .none
        tblContact.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrContact.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as! GeneralTitleCell
        cell.imgView.isHidden = false
        cell.setContraintsForDes(desp: false)
        cell.lblDes.isHidden = true
        cell.switchIcon.isHidden = true
        cell.lblName.text = arrContact[indexPath.row]
        cell.topGrayLine.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vcChat = ChatViewController()
            vcChat.arrUserIDs.append("\(Key.shared.user_id)")
            vcChat.arrUserIDs.append("1")
            vcChat.strChatId = "1"
            navigationController?.pushViewController(vcChat, animated: true)
        case 1, 2, 3, 4:
            let vcDetail = SetContactDetailViewController()
            vcDetail.detailType = SetContactDetailType(rawValue: indexPath.row)!
            navigationController?.pushViewController(vcDetail, animated: true)
        case 5:
            let vcJoin = SetWebViewController()
            vcJoin.strURL = "https://www.faemaps.com/career/"
            navigationController?.pushViewController(vcJoin, animated: true)
        default: break
        }
    }
}
