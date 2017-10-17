//
//  SetInfoViewController2.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/24.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GeneralTitleCellDelegate {
    
    var tblInfo: UITableView!
    var uiviewNavBar: FaeNavBar!
    var arrTitle: [String] = ["Edit NameCard", "Hide NameCard Options", "Disable Gender", "Disable Age"]
    var arrDetail: [String] = ["Preview and Edit Information on your NameCard.", "Hide the bottom NameCad Options for you and other users. Contacts are excluded.", "Gender will be hidden for you and all other users. You will no longer be able to use Gender Filters.", "Age will be hidden for you and all other users. You will no longer be able to use Age Filters."]
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        loadNavBar()
        loadTableView()
        loadActivityIndicator()
    }
    
    // GeneralTitleCellDelegate
    func startUpdating() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    // GeneralTitleCellDelegate
    func stopUpdating() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "My Information"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    func loadTableView() {
        tblInfo = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        view.addSubview(tblInfo)
        tblInfo.separatorStyle = .none
        tblInfo.delegate = self
        tblInfo.dataSource = self
        tblInfo.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
        tblInfo.estimatedRowHeight = 110
        tblInfo.rowHeight = UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let uiview = UIView()
        uiview.backgroundColor = UIColor(r: 241, g: 241, b: 241, alpha: 100)
        return uiview
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as! GeneralTitleCell
        cell.lblName.isHidden = false
        cell.lblDes.isHidden = false
        cell.setContraintsForDes()
        cell.delegate = self
        if indexPath.section == 0 {
            cell.switchIcon.isHidden = true
            cell.imgView.isHidden = false
        }
        else {
            cell.switchIcon.isHidden = false
            cell.switchIcon.tag = indexPath.section + 100
            if indexPath.section == 2 {
                cell.switchIcon.setOn(Key.shared.disableGender, animated: false)
            } else if indexPath.section == 3 {
                cell.switchIcon.setOn(Key.shared.disableAge, animated: false)
            }
            cell.imgView.isHidden = true
        }
        cell.lblDes.text = arrDetail[indexPath.section]
        cell.lblName.text = arrTitle[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            navigationController?.pushViewController(SetInfoNamecard(), animated: true)
            break
        default:
            break
        }
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
