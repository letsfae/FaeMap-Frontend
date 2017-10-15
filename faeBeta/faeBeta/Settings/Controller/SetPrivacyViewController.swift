//
//  SetPrivacyViewController2.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/25.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetPrivacyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uiviewNavBar: FaeNavBar!
    var tblPrivacy: UITableView!
    var arrTitle = ["00":"Go Invisible", "10":"Shadow Location System", "11":"Minimal Effect", "12":"Normal Effect", "13":"Maximum Effect", "20":"Blocked List", "30":"Clear Char History"]
    var arrDetail: [String] = ["Hide your own Map Avatar and all other Avatars. You can't see others and others can't see you.", "Now you see me, now you don't! S.L.S is used to protect your true location in public.", "List for all the users you blocked. Banned users will no longer appear in the list.", "Clears all chat contents excluding those with Official Accounts. This does not delete the chat itself."]
    
    var uiviewHidden: UIView!
    var lblHiddenModel: UILabel!
    var imgviewHidden: UIImageView!
    var lblHiddenDes: UILabel!
    var lblHiddenDes2: UILabel!
    var btnGot: UIButton!
    
    var btnBackground: UIButton!
    var uiviewBackground: UIView!
    
    var uiviewAlert: UIView!
    var lblAlert: UILabel!
    var btnAlert: UIButton!
    var btnDelete: UIButton!
    
    //tag = 0 means ask clear chat history view; tag = 1 means chat history has been cleared
    var tag = 0
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        loadNavBar()
        loadTableView()
        loadHiddenView()
        
        loadBackground()
        loaduiviewAlert()
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "Privacy"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    func loadTableView() {
        tblPrivacy = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        view.addSubview(tblPrivacy)
        tblPrivacy.delegate = self
        tblPrivacy.dataSource = self
        tblPrivacy.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
        tblPrivacy.register(GeneralSubTitleCell.self, forCellReuseIdentifier: "GeneralSubTitleCell")
        tblPrivacy.estimatedRowHeight = 110
        tblPrivacy.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadHiddenView() {
        let uiviewHiddenX = 290/414*screenWidth
        uiviewHidden = UIView(frame: CGRect(x: (screenWidth-uiviewHiddenX)/2, y: 155/736*screenHeight, width: 290/414*screenWidth, height: 380))
        uiviewHidden.backgroundColor = .white
        view.addSubview(uiviewHidden)
        uiviewHidden.isHidden = true
        
        lblHiddenModel = UILabel(frame: CGRect(x: 73/414*screenWidth, y: 27/736*screenHeight, width: 144/414*screenWidth, height: 44))
        uiviewHidden.addSubview(lblHiddenModel)
        lblHiddenModel.numberOfLines = 0
        lblHiddenModel.lineBreakMode = .byWordWrapping
        lblHiddenModel.text = "You're now in Invisible Model!"
        lblHiddenModel.textAlignment = .center
        lblHiddenModel.textColor = UIColor._898989()
        lblHiddenModel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        
        imgviewHidden = UIImageView(frame: CGRect(x: 86/414*screenWidth, y: 89/736*screenHeight, width: 129/414*screenWidth, height: 145))
        uiviewHidden.addSubview(imgviewHidden)
        imgviewHidden.image = #imageLiteral(resourceName: "Settings_Invisble")
        
        lblHiddenDes = UILabel(frame: CGRect(x: 56/414*screenWidth, y: 236/736*screenHeight, width: 179/414*screenWidth, height: 66))
        uiviewHidden.addSubview(lblHiddenDes)
        lblHiddenDes.numberOfLines = 0
        lblHiddenDes.lineBreakMode = .byWordWrapping
        lblHiddenDes.text = "You are Hidden.\nYou can't see others and others can't see you."
        lblHiddenDes.textAlignment = .center
        lblHiddenDes.textColor = UIColor._898989()
        lblHiddenDes.font = UIFont(name: "AvenirNext-Medium", size: 16)
        
        btnGot = UIButton(frame: CGRect(x: 40/414*screenWidth, y: 315/736*screenHeight, width: 209/414*screenWidth, height: 40))
        uiviewHidden.addSubview(btnGot)
        btnGot.titleLabel?.textColor = .white
        btnGot.titleLabel?.textAlignment = .center
        btnGot.setTitle("Got it!", for: .normal)
        btnGot.backgroundColor = UIColor._2499090()
        btnGot.layer.cornerRadius = 19
        btnGot.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        
    }
    
    func loadBackground() {
        btnBackground = UIButton(frame: self.view.frame)
        //btnBackground.addTarget(self, action: #selector(notouch(_:)), for: .touchUpInside)
        view.addSubview(btnBackground)
        
        uiviewBackground = UIView(frame: self.view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor(red: 107.0 / 255.0, green: 105.0 / 255.0, blue: 105.0 / 255.0, alpha: 0.5)
        uiviewBackground.addSubview(btnBackground)
        
        uiviewBackground.isHidden = true
    }
    
    func loaduiviewAlert() {
        let uiviewAlertX = 290/414*screenWidth
        uiviewAlert = UIView(frame: CGRect(x: (screenWidth-uiviewAlertX)/2, y: 200/736*screenHeight, width: 290/414*screenWidth, height: 161))
        uiviewAlert.backgroundColor = .white
        uiviewAlert.layer.cornerRadius = 19
        uiviewBackground.addSubview(uiviewAlert)
        
        let btnAlertX = 210/414*screenWidth
        lblAlert = UILabel(frame: CGRect(x: (uiviewAlertX-btnAlertX)/2, y: 30/736*screenHeight, width: 210, height: 50))
        uiviewAlert.addSubview(lblAlert)
        if tag == 0 {
            lblAlert.text = "Are you sure you want to clear your Chat History?"
        }
        else {
            lblAlert.text = "Your Chat History has been cleared!"
        }
        lblAlert.textAlignment = .center
        lblAlert.textColor = UIColor._898989()
        lblAlert.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblAlert.numberOfLines = 0
        lblAlert.lineBreakMode = .byWordWrapping
        
        btnAlert = UIButton(frame: CGRect(x: (uiviewAlertX-btnAlertX)/2, y: 102/736*screenHeight, width: btnAlertX, height: 39))
        uiviewAlert.addSubview(btnAlert)
        btnAlert.titleLabel?.textColor = .white
        btnAlert.titleLabel?.textAlignment = .center
        if tag == 0 {
            btnAlert.setTitle("Yes", for: .normal)
            btnAlert.addTarget(self, action: #selector(getintoNextClear(_:)), for: .touchUpInside)
        }
        else {
            btnAlert.setTitle("Ok!", for: .normal)
            btnAlert.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        }
        btnAlert.backgroundColor = UIColor._2499090()
        btnAlert.layer.cornerRadius = 19
        
        btnDelete = UIButton(frame: CGRect(x: 15/414*screenWidth, y: 15/736*screenHeight, width: 17/414*screenWidth, height: 17/414*screenWidth))
        uiviewAlert.addSubview(btnDelete)
        btnDelete.setImage(#imageLiteral(resourceName: "Settings_delete"), for: .normal)
        btnDelete.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 4
        }
        return 1
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
        let section = indexPath.section
        let row = indexPath.row
        if section == 1 && (row == 1 || row == 2 || row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as!GeneralSubTitleCell
            cell.btnSelect.isHidden = false
            cell.btnSelect.isSelected = row == 1
            cell.imgView.isHidden = true
            cell.lblDes.isHidden = true
            cell.removeContraintsForDes()
            cell.lblName.text = arrTitle["\(section)\(row)"]
            cell.switchIcon.isHidden = true
            cell.lblName.textColor = UIColor._107105105()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as!GeneralTitleCell
        if section == 0 {
            cell.imgView.isHidden = true
            cell.switchIcon.isHidden = false
            cell.switchIcon.addTarget(self, action: #selector(getintoHiddenModel(_:)), for: .valueChanged)
        }
        else if section == 1 {
            cell.imgView.isHidden = true
            cell.switchIcon.isHidden = true
        }
        else {
            cell.imgView.isHidden = false
            cell.switchIcon.isHidden = true
        }
        cell.lblName.isHidden = false
        cell.lblDes.isHidden = false
        cell.setContraintsForDes()
        cell.lblName.text = arrTitle["\(section)\(row)"]
        cell.lblDes.text = arrDetail[section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        //let row = indexPath.row
        if section == 0 {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as!GeneralTitleCell
            if cell.switchIcon.isOn == false {
                //show main map and uiviewAlert, need to add mainscreen map here
                cell.switchIcon.isOn = true
                uiviewHidden.isHidden = false
            }
        }
        else if section == 3 {
            uiviewBackground.isHidden = false
            tag = 0
            //need to clear chat history later
            clearCharHistory()
        }
    }
    
    func getintoHiddenModel(_ sender: UISwitch) {
        if sender.isOn == true {
            sender.isOn = false
        }
        else {
            //show main map and uiviewAlert, need to add mainscreen map here
            sender.isOn = true
            uiviewHidden.isHidden = false
        }
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showMainView(_ sender: UIButton) {
        uiviewHidden.isHidden = true
        uiviewBackground.isHidden = true
    }
    
    func clearCharHistory() {
        
    }
    
    func getintoNextClear(_ sender: UIButton) {
        tag = 1
        loaduiviewAlert()
    }
}
