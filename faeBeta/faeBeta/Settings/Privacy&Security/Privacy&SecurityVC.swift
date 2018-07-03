//
//  SetPrivacyViewController2.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/25.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class SetPrivacyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    private var uiviewNavBar: FaeNavBar!
    private var tblPrivacy: UITableView!
    private var arrTitle = ["00":"Go Invisible", "10":"Shadow Location System", "11":"Minimal Effect", "12":"Normal Effect", "13":"Maximum Effect", "20":"Blocked List", "30":"Clear Chat History"]
    private var arrDetail: [String] = ["Hide your own Map Avatar and all other Avatars. You can't see others and others can't see you.", "Now you see me, now you don't! S.L.S is used to protect your true location in public.", "List for all the users you blocked. Banned users will no longer appear in the list.", "Clears all chat contents excluding those with Official Accounts. This does not delete the chat itself."]
    
    private var uiviewInvisible: UIView!
    private var lblHiddenModel: UILabel!
    private var imgviewHidden: UIImageView!
    private var lblHiddenDes: UILabel!
    private var lblHiddenDes2: UILabel!
    private var btnGot: UIButton!
    
    private var btnBackground: UIButton!
    private var uiviewBackground: UIView!
    
    private var uiviewAlert: UIView!
    private var lblAlert: UILabel!
    private var btnAlert: UIButton!
    private var btnDelete: UIButton!
    
    //tag = 0 means ask clear chat history view; tag = 1 means chat history has been cleared
    private var tag = 0
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        loadNavBar()
        loadTableView()
        loadBackground()
        loadInvisibleView()
        loaduiviewAlert()
    }
    
    // MARK: - Set up
    private func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "Privacy"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    private func loadTableView() {
        tblPrivacy = UITableView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top))
        view.addSubview(tblPrivacy)
        tblPrivacy.delegate = self
        tblPrivacy.dataSource = self
        tblPrivacy.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
        tblPrivacy.register(GeneralSubTitleCell.self, forCellReuseIdentifier: "GeneralSubTitleCell")
        tblPrivacy.estimatedRowHeight = 110
        tblPrivacy.rowHeight = UITableViewAutomaticDimension
    }
    
    private func loadInvisibleView() {
        uiviewInvisible = UIView(frame: CGRect(x: 62, y: 155, w: 290, h: 380))
        uiviewInvisible.backgroundColor = .white
        uiviewInvisible.center.y = view.center.y - device_offset_top
        uiviewInvisible.layer.cornerRadius = 16 * screenWidthFactor
        uiviewBackground.addSubview(uiviewInvisible)
        
        let lblTitle = UILabel(frame: CGRect(x: 73, y: 27, w: 144, h: 44))
        lblTitle.text = "You're now in\n Invisible Mode!"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        lblTitle.numberOfLines = 0
        lblTitle.textAlignment = NSTextAlignment.center
        lblTitle.textColor = UIColor(red: 89 / 255, green: 89.0 / 255, blue: 89.0 / 255, alpha: 1.0)
        uiviewInvisible.addSubview(lblTitle)
        
        let imgInvisible = UIImageView(frame: CGRect(x: 89, y: 87, w: 117, h: 139))
        imgInvisible.image = UIImage(named: "InvisibleMode")
        uiviewInvisible.addSubview(imgInvisible)
        
        let lblNote = UILabel(frame: CGRect(x: 41, y: 236, w: 209, h: 66))
        lblNote.numberOfLines = 0
        lblNote.text = "You are Hidden...\nNo one can see you and you\ncan't be discovered!"
        lblNote.textAlignment = NSTextAlignment.center
        lblNote.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1)
        lblNote.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        uiviewInvisible.addSubview(lblNote)
        
        btnGot = UIButton(frame: CGRect(x: 41, y: 315, w: 209, h: 40))
        uiviewInvisible.addSubview(btnGot)
        btnGot.setTitle("Got it!", for: .normal)
        btnGot.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        btnGot.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        btnGot.layer.cornerRadius = 20 * screenWidthFactor
        btnGot.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
    }
    
    private func loadBackground() {
        btnBackground = UIButton(frame: self.view.frame)
        view.addSubview(btnBackground)
        
        uiviewBackground = UIView(frame: self.view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        uiviewBackground.addSubview(btnBackground)
        
        uiviewBackground.alpha = 0
    }
    
    private func loaduiviewAlert() {
        uiviewAlert = UIView(frame: CGRect(x: 0, y: alert_offset_top, w: 290, h: 161))
        uiviewAlert.center.x = screenWidth / 2
        uiviewAlert.backgroundColor = .white
        uiviewAlert.layer.cornerRadius = 19 * screenHeightFactor
        uiviewBackground.addSubview(uiviewAlert)
        
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
        
        btnAlert = UIButton(frame: CGRect(x: 0, y: 102, w: 210, h: 39))
        btnAlert.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(btnAlert)
        btnAlert.titleLabel?.textColor = .white
        btnAlert.titleLabel?.textAlignment = .center
        btnAlert.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        if tag == 0 {
            btnAlert.setTitle("Yes", for: .normal)
            btnAlert.addTarget(self, action: #selector(getintoNextClear(_:)), for: .touchUpInside)
        } else {
            btnAlert.setTitle("Ok!", for: .normal)
            btnAlert.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        }
        btnAlert.backgroundColor = UIColor._2499090()
        btnAlert.layer.cornerRadius = 19 * screenHeightFactor

        btnDelete = UIButton(frame: CGRect(x: 0, y: 0, w: 47, h: 45))
        uiviewAlert.addSubview(btnDelete)
        btnDelete.setImage(#imageLiteral(resourceName: "Settings_delete"), for: .normal)
        btnDelete.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
    }
    
    // MARK: - Button & switch actions
    @objc private func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func showMainView(_ sender: UIButton) {
        showOrHideInvisibleCard(show: false)
    }
    
    private func showOrHideInvisibleCard(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.3) {
                self.uiviewInvisible.alpha = 1
                self.uiviewBackground.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.uiviewInvisible.alpha = 0
                self.uiviewBackground.alpha = 0
            }
        }
    }
    
    private func clearChatHistory(completion: @escaping ((Bool) -> Void)) {
        let realm = try! Realm()
        let allMessages = realm.objects(RealmMessage.self).filter("login_user_id == %@", "\(Key.shared.user_id)")
        let allRecents = realm.objects(RealmRecentMessage.self).filter("login_user_id == %@", "\(Key.shared.user_id)")
        try! realm.write {
            realm.delete(allMessages)
            realm.delete(allRecents)
        }
        completion(true)
    }
    
    @objc private func getintoNextClear(_ sender: UIButton) {
        tag = 1
        loaduiviewAlert()
    }
    
    @objc private func actionInvisibleModeSwitch(_ sender: UISwitch) {
        if sender.isOn {
            FaeUser.shared.whereKey("status", value: "5")
            FaeUser.shared.setSelfStatus({ status, _ in
                if status / 100 == 2 {
                    Key.shared.onlineStatus = 5
                    let storageForUserStatus = UserDefaults.standard
                    storageForUserStatus.set(Key.shared.onlineStatus, forKey: "userStatus")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
                    self.showOrHideInvisibleCard(show: true)
                } else {
                    print("Fail to switch to invisible")
                }
            })
        } else {
            FaeUser.shared.whereKey("status", value: "1")
            FaeUser.shared.setSelfStatus({ status, _ in
                if status / 100 == 2 {
                    Key.shared.onlineStatus = 1
                    let storageForUserStatus = UserDefaults.standard
                    storageForUserStatus.set(Key.shared.onlineStatus, forKey: "userStatus")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
                } else {
                    print("Fail to switch to online")
                }
            })
        }
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 4
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section == 1 && (row == 1 || row == 2 || row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as! GeneralSubTitleCell
            cell.btnSelect.isHidden = false
            switch row {
            case 1:
                cell.btnSelect.isSelected = Key.shared.shadowLocationEffect == "min"
                break
            case 2:
                cell.btnSelect.isSelected = Key.shared.shadowLocationEffect == "normal"
                break
            case 3:
                cell.btnSelect.isSelected = Key.shared.shadowLocationEffect == "max"
                break
            default:
                break
            }
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
            cell.switchIcon.setOn(Key.shared.onlineStatus == 5, animated: false)
            cell.switchIcon.addTarget(self, action: #selector(actionInvisibleModeSwitch(_:)), for: .valueChanged)
            cell.topGrayLine.isHidden = true
        } else if section == 1 {
            cell.imgView.isHidden = true
            cell.switchIcon.isHidden = true
            cell.topGrayLine.isHidden = false
        } else {
            cell.imgView.isHidden = false
            cell.switchIcon.isHidden = true
            cell.topGrayLine.isHidden = false
        }
        cell.lblName.isHidden = false
        cell.lblDes.isHidden = false
        cell.setContraintsForDes()
        cell.lblName.text = arrTitle["\(section)\(row)"]
        cell.lblDes.text = arrDetail[section]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 { // TODO
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! GeneralTitleCell
            if cell.switchIcon.isOn == false {
                uiviewAlert.isHidden = true
                cell.switchIcon.setOn(true, animated: true)
            } else {
                cell.switchIcon.setOn(false, animated: true)
            }
            vibrate(type: 4)
            cell.switchIcon.sendActions(for: .valueChanged)
        } else if section == 1 {
            var effect = "normal"
            switch row {
            case 1:
                effect = "min"
                let cell = tableView.cellForRow(at: indexPath) as! GeneralSubTitleCell
                cell.btnSelect.isSelected = true
                let cell2 = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! GeneralSubTitleCell
                cell2.btnSelect.isSelected = false
                let cell3 = tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as! GeneralSubTitleCell
                cell3.btnSelect.isSelected = false
                break
            case 2:
                let cell = tableView.cellForRow(at: indexPath) as! GeneralSubTitleCell
                cell.btnSelect.isSelected = true
                let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! GeneralSubTitleCell
                cell2.btnSelect.isSelected = false
                let cell3 = tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as! GeneralSubTitleCell
                cell3.btnSelect.isSelected = false
            case 3:
                effect = "max"
                let cell = tableView.cellForRow(at: indexPath) as! GeneralSubTitleCell
                cell.btnSelect.isSelected = true
                let cell2 = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! GeneralSubTitleCell
                cell2.btnSelect.isSelected = false
                let cell3 = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! GeneralSubTitleCell
                cell3.btnSelect.isSelected = false
                break
            default:
                break
            }
            Key.shared.shadowLocationEffect = effect
            FaeUser.shared.whereKey("shadow_location_system_effect", value: effect)
            FaeUser.shared.setUserSettings { (status, message) in
                guard status / 100 == 2 else { return }
            }
        } else if section == 2 {
            FaeContact().getBlockList({ [unowned self] (status, message) in
                felixprint(status)
                let json = JSON(message!)
                if json.count != 0 {
                    for i in 0..<json.count {
                        let user_id = json[i]["user_id"].stringValue
                        let user_name = json[i]["user_name"].stringValue
                        let realm = try! Realm()
                        if realm.filterUser(id: user_id) == nil {
                            let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", String(Key.shared.user_id), user_id, user_name, "", BLOCKED, "", "", "", ""])
                            try! realm.write {
                                realm.add(realmUser, update: true)
                            }
                        }
                    }
                }
                self.navigationController?.pushViewController(SetBlockListViewController(), animated: true)
            })
        } else if section == 3 { // TODO
            //need to clear chat history later
            clearChatHistory() { success in
                self.uiviewBackground.alpha = 1
                self.uiviewInvisible.alpha = 0
                self.uiviewAlert.isHidden = false
                self.tag = 0
            }
        }
    }
}
