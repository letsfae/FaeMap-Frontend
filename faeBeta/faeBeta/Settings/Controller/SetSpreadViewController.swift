//
//  SetSpreadViewController2.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/24.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetSpreadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uiviewNavBar: FaeNavBar!
    var tblSpLove: UITableView!
    var arrStr: [String: String] = ["00":"Invite Friends!", "01":"From Contacts", "02":"From Facebook", "10":"Share Fae Map!", "11":"Send Message", "12":"Send Email", "13":"Share on Facebook", "14":"Share on Twitter", "15":"Other Options"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        loadNavBar()
        loadTableView()
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "Spread Love"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    func loadTableView() {
        tblSpLove = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        view.addSubview(tblSpLove)
        tblSpLove.separatorStyle = .none
        tblSpLove.delegate = self
        tblSpLove.dataSource = self
        tblSpLove.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
        tblSpLove.register(GeneralSubTitleCell.self, forCellReuseIdentifier: "GeneralSubTitleCell")
        tblSpLove.estimatedRowHeight = 60
        tblSpLove.rowHeight = UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let uiview = UIView()
        uiview.backgroundColor = UIColor._241241241()
        return uiview
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return 6
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as!GeneralTitleCell
                cell.switchIcon.isHidden = true
                cell.imgView.isHidden = true
                cell.lblDes.isHidden = false
                cell.setContraintsForDes()
                cell.lblName.text = arrStr["\(section)\(row)"]
                cell.lblDes.text = "Fae Map is better with friends! Invite your friends to share and discover amazing places together!"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as!GeneralSubTitleCell
            cell.switchIcon.isHidden = true
            cell.imgView.isHidden = false
            cell.btnSelect.isHidden = true
            cell.removeContraintsForDes()
            cell.lblName.textColor = UIColor._107105105()
            cell.lblName.text = arrStr["\(section)\(row)"]
            return cell
        }
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as!GeneralTitleCell
            cell.switchIcon.isHidden = true
            cell.imgView.isHidden = true
            cell.addConstraintsWithFormat("V:|-20-[v0(25)]-20-|", options: [], views: cell.lblName)
            cell.lblName.text = arrStr["\(section)\(row)"]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as!GeneralSubTitleCell
        cell.switchIcon.isHidden = true
        cell.imgView.isHidden = false
        cell.btnSelect.isHidden = true
        cell.removeContraintsForDes()
        cell.lblName.text = arrStr["\(section)\(row)"]
        cell.lblName.textColor = UIColor._107105105()
        return cell
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
