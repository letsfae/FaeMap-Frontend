//
//  SetAccountViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/11.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SetNameBirthGenderDelegate, UpdateUsrnameEmailDelegate {
    
    var uiviewNavBar: FaeNavBar!
    var arrTitle: [String] = ["Name", "Birthday", "Gender", "Email", "Username", "Phone", "Change Password", "Deactivate Account", "Close Account"]
    var tblAccount: UITableView!
    let faeUser = FaeUser()
    var boolResetPswd = false
    var uiviewGrayBG: UIView!
    var uiviewMsgSent: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        view.addConstraintsWithFormat("V:|-\(65+device_offset_top)-[v0]-0-|", options: [], views: tblAccount)
        
        if boolResetPswd {
            loadResetPswdSucceedPage()
            animationShowMsgHint()
        }
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath as IndexPath) as! SetAccountCell
        cell.lblTitle.text = arrTitle[indexPath.row]
        
        let excla = InlineTextAttachment()
        excla.fontDescender = -2
        excla.image = #imageLiteral(resourceName: "Settings_exclamation")
        
        let attr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 15)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()]
        
        switch indexPath.row {
        case 0:
            cell.lblContent.text = Key.shared.userFirstname + " " + Key.shared.userLastname
        case 1:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let date = dateFormatter.date(from: Key.shared.userBirthday)
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormatter.string(from: date!)
            
            cell.lblContent.text = dateString
        case 2:
            cell.lblContent.text = Key.shared.gender
        case 3:
            cell.lblContent.text = Key.shared.userEmail
            if !Key.shared.userEmailVerified {
                let txt = NSMutableAttributedString()
                txt.append(NSAttributedString(attachment: excla))
                let str = NSAttributedString(string: "  \(Key.shared.userEmail)", attributes: attr)
                txt.append(NSAttributedString(attributedString: str))
                
                cell.lblContent.attributedText = txt
            }
        case 4:
            cell.lblContent.text = Key.shared.username
        case 5:
            if !Key.shared.userPhoneVerified { //Key.shared.userPhoneNumber == "" {
                let txt = NSMutableAttributedString()
                txt.append(NSAttributedString(attachment: excla))
                let str = NSAttributedString(string: "  Link", attributes: attr)
                txt.append(NSAttributedString(attributedString: str))
                
                cell.lblContent.attributedText = txt
            } else {
                let arrPhone = Key.shared.userPhoneNumber?.split(separator: "(")[0].split(separator: ")")
                let phoneNumber = "+" + arrPhone![0] + " " + arrPhone![1]
                cell.lblContent.text = phoneNumber
            }
        default:
            cell.lblContent.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SetAccountCell
        switch indexPath.row {
        case 0:
            let vc = SetNameViewController()
            vc.delegate = self
            vc.enterMode = .name
            vc.fName = Key.shared.userFirstname
            vc.lName = Key.shared.userLastname
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = SetNameViewController()
            vc.delegate = self
            vc.enterMode = .birth
            vc.dateOfBirth = cell.lblContent.text
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = SetNameViewController()
            vc.delegate = self
            vc.enterMode = .gender
            vc.gender = cell.lblContent.text
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = UpdateUsrnameEmailViewController()
            vc.delegate = self
            vc.strEmail = Key.shared.userEmail
            vc.enterMode = .email
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = UpdateUsrnameEmailViewController()
            //            vc.delegate = self
            vc.strUsername = cell.lblContent.text
            vc.enterMode = .usrname
            navigationController?.pushViewController(vc, animated: true)
        case 5:
            if !Key.shared.userPhoneVerified {
                let vc = SignInPhoneViewController()
//                vc.delegate = self
                vc.enterMode = .settings
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = UpdateUsrnameEmailViewController()
                vc.delegate = self
                let arrPhone = cell.lblContent.text?.split(separator: " ")
                vc.strPhone = "\(arrPhone![1])"
                vc.enterMode = .phone
                navigationController?.pushViewController(vc, animated: true)
            }
        case 6:
            let vc = SetNameViewController()
            vc.enterMode = .password
            vc.pswdEnterMode = .password
            navigationController?.pushViewController(vc, animated: true)
        case 7:
            navigationController?.pushViewController(SetDeactiveViewController(), animated: true)
        case 8:
            navigationController?.pushViewController(SetCloseViewController(), animated: true)
        default: break
        }
    }
    
    // SetNameBirthGenderDelegate
    func updateInfo(target: String?) {
        if target == "name" {
            tblAccount.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else if target == "birth" {
            tblAccount.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        } else if target == "gender" {
            tblAccount.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        }
    }
    
    // UpdateUsrnameEmailDelegate
    func updateEmail() {
        tblAccount.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
    }
    
    func updatePhone() {
        tblAccount.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)
    }
    
    fileprivate func loadResetPswdSucceedPage() {
        uiviewGrayBG = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewGrayBG.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 70)
        view.addSubview(uiviewGrayBG)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionOK(_:)))
        uiviewGrayBG.addGestureRecognizer(tapGesture)
        
        uiviewMsgSent = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 161))
        uiviewMsgSent.backgroundColor = .white
        uiviewMsgSent.center.x = screenWidth / 2
        uiviewMsgSent.layer.cornerRadius = 20 * screenWidthFactor
        uiviewGrayBG.addSubview(uiviewMsgSent)
        
        let btnCancel = UIButton(frame: CGRect(x: 0, y: 0, w: 42, h: 40))
        btnCancel.tag = 0
        btnCancel.setImage(#imageLiteral(resourceName: "check_cross_red"), for: .normal)
        btnCancel.addTarget(self, action: #selector(actionOK(_:)), for: .touchUpInside)
        uiviewMsgSent.addSubview(btnCancel)
        
        let lblMsgSent = FaeLabel(CGRect(x: 0, y: 30, w: 290, h: 50), .center, .medium, 18 * screenHeightFactor, UIColor._898989())
        lblMsgSent.numberOfLines = 2
        lblMsgSent.text = "Your Password has been\nReset Successfully!"
        uiviewMsgSent.addSubview(lblMsgSent)
        
        let btnOK = UIButton()
        uiviewMsgSent.addSubview(btnOK)
        btnOK.setTitleColor(.white, for: .normal)
        btnOK.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnOK.backgroundColor = UIColor._2499090()
        btnOK.layer.cornerRadius = 19 * screenWidthFactor
        btnOK.addTarget(self, action: #selector(actionOK(_:)), for: .touchUpInside)
        btnOK.setTitle("OK", for: .normal)
        let padding = (290 - 208) / 2 * screenWidthFactor
        uiviewMsgSent.addConstraintsWithFormat("H:|-\(padding)-[v0]-\(padding)-|", options: [], views: btnOK)
        uiviewMsgSent.addConstraintsWithFormat("V:[v0(\(39 * screenHeightFactor))]-\(20 * screenHeightFactor)-|", options: [], views: btnOK)
        
        uiviewGrayBG.alpha = 0
        uiviewMsgSent.alpha = 0
    }
    
    @objc func actionOK(_ sender: Any) {
        animationHideMsgHint()
    }
    
    func animationShowMsgHint() {
        uiviewGrayBG.alpha = 0
        uiviewMsgSent.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewGrayBG.alpha = 1
            self.uiviewMsgSent.alpha = 1
        })
    }
    
    func animationHideMsgHint() {
        uiviewGrayBG.alpha = 1
        uiviewMsgSent.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewGrayBG.alpha = 0
            self.uiviewMsgSent.alpha = 0
        })
    }
}
