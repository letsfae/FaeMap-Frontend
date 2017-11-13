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
    var arrTitle = ["00":"Go Invisible", "10":"Shadow Location System", "11":"Minimal Effect", "12":"Normal Effect", "13":"Maximum Effect", "20":"Blocked List", "30":"Clear Chat History"]
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
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        loadNavBar()
        loadTableView()
        loadBackground()
        loadHiddenView()
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
        uiviewHidden = UIView(frame: CGRect(x: 62, y: 155, w: 290, h: 380))
        uiviewHidden.backgroundColor = .white
        uiviewHidden.layer.cornerRadius = 16 * screenWidthFactor
        uiviewBackground.addSubview(uiviewHidden)
        
        let lblTitle = UILabel(frame: CGRect(x: 73, y: 27, w: 144, h: 44))
        lblTitle.text = "You're now in\n Invisible Mode!"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        lblTitle.numberOfLines = 0
        lblTitle.textAlignment = NSTextAlignment.center
        lblTitle.textColor = UIColor(red: 89 / 255, green: 89.0 / 255, blue: 89.0 / 255, alpha: 1.0)
        uiviewHidden.addSubview(lblTitle)
        
        let imgInvisible = UIImageView(frame: CGRect(x: 89, y: 87, w: 117, h: 139))
        imgInvisible.image = UIImage(named: "InvisibleMode")
        uiviewHidden.addSubview(imgInvisible)
        
        let lblNote = UILabel(frame: CGRect(x: 41, y: 236, w: 209, h: 66))
        lblNote.numberOfLines = 0
        lblNote.text = "You are Hidden...\nNo one can see you and you\ncan't be discovered!"
        lblNote.textAlignment = NSTextAlignment.center
        lblNote.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1)
        lblNote.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        uiviewHidden.addSubview(lblNote)
        
        btnGot = UIButton(frame: CGRect(x: 41, y: 315, w: 209, h: 40))
        uiviewHidden.addSubview(btnGot)
        btnGot.setTitle("Got it!", for: .normal)
        btnGot.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        btnGot.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        btnGot.layer.cornerRadius = 20 * screenWidthFactor
        btnGot.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
    }
    
    func loadBackground() {
        btnBackground = UIButton(frame: self.view.frame)
        //btnBackground.addTarget(self, action: #selector(notouch(_:)), for: .touchUpInside)
        view.addSubview(btnBackground)
        
        uiviewBackground = UIView(frame: self.view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        uiviewBackground.addSubview(btnBackground)
        
        uiviewBackground.isHidden = true
    }
    
    func loaduiviewAlert() {
        //let uiviewAlertX = 290/414*screenWidth
        //uiviewAlert = UIView(frame: CGRect(x: (screenWidth-uiviewAlertX)/2, y: 200/736*screenHeight, width: 290/414*screenWidth, height: 161))
        uiviewAlert = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 161))
        uiviewAlert.center.x = screenWidth / 2
        uiviewAlert.backgroundColor = .white
        uiviewAlert.layer.cornerRadius = 19 * screenHeightFactor
        uiviewBackground.addSubview(uiviewAlert)
        
        //let btnAlertX = 210/414*screenWidth
        lblAlert = UILabel(frame: CGRect(x: 0, y: 30, w: 205, h: 50))
        lblAlert.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(lblAlert)
        if tag == 0 {
            lblAlert.text = "Are you sure you want to\nclear your Chat History?"
        }
        else {
            lblAlert.text = "Your Chat History has\nbeen cleared!"
        }
        lblAlert.textAlignment = .center
        lblAlert.textColor = UIColor._898989()
        lblAlert.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenWidthFactor)
        lblAlert.numberOfLines = 0
        lblAlert.lineBreakMode = .byWordWrapping
        
        //btnAlert = UIButton(frame: CGRect(x: (uiviewAlertX-btnAlertX)/2, y: 102/736*screenHeight, width: btnAlertX, height: 39))
        btnAlert = UIButton(frame: CGRect(x: 0, y: 102, w: 210, h: 39))
        btnAlert.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(btnAlert)
        btnAlert.titleLabel?.textColor = .white
        btnAlert.titleLabel?.textAlignment = .center
        btnAlert.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        if tag == 0 {
            btnAlert.setTitle("Yes", for: .normal)
            btnAlert.addTarget(self, action: #selector(getintoNextClear(_:)), for: .touchUpInside)
        }
        else {
            btnAlert.setTitle("Ok!", for: .normal)
            btnAlert.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        }
        btnAlert.backgroundColor = UIColor._2499090()
        btnAlert.layer.cornerRadius = 19 * screenHeightFactor
        
        //btnDelete = UIButton(frame: CGRect(x: 15/414*screenWidth, y: 15/736*screenHeight, width: 17/414*screenWidth, height: 17/414*screenWidth))
        btnDelete = UIButton(frame: CGRect(x: 0, y: 0, w: 47, h: 45))
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as! GeneralSubTitleCell
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as! GeneralTitleCell
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
        if section == 0 { // TODO
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! GeneralTitleCell
            if cell.switchIcon.isOn == false {
                //show main map and uiviewAlert, need to add mainscreen map here
                cell.switchIcon.isOn = true
                uiviewBackground.isHidden = false
                uiviewAlert.isHidden = true
                uiviewHidden.isHidden = false
            }
        }
        else if section == 3 { // TODO
            uiviewBackground.isHidden = false
            uiviewHidden.isHidden = true
            uiviewAlert.isHidden = false
            tag = 0
            //need to clear chat history later
            clearCharHistory()
        }
    }
    
    @objc func getintoHiddenModel(_ sender: UISwitch) {
        if sender.isOn == true {
            sender.isOn = false
        }
        else {
            //show main map and uiviewAlert, need to add mainscreen map here
            sender.isOn = true
            uiviewHidden.isHidden = false
        }
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showMainView(_ sender: UIButton) {
        uiviewHidden.isHidden = true
        uiviewBackground.isHidden = true
    }
    
    func invisibleModeDimClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 0
        }, completion: { _ in
            sender.removeFromSuperview()
        })
    }
    
    func clearCharHistory() {
        
    }
    
    @objc func getintoNextClear(_ sender: UIButton) {
        tag = 1
        loaduiviewAlert()
    }
}
