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
            break
        case 1:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let date = dateFormatter.date(from: Key.shared.userBirthday)
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormatter.string(from: date!)
            
            cell.lblContent.text = dateString
            break
        case 2:
            cell.lblContent.text = Key.shared.gender
            break
        case 3:
            cell.lblContent.text = Key.shared.userEmail
            if !Key.shared.userEmailVerified {
                let txt = NSMutableAttributedString()
                txt.append(NSAttributedString(attachment: excla))
                let str = NSAttributedString(string: "  \(Key.shared.userEmail)", attributes: attr)
                txt.append(NSAttributedString(attributedString: str))
                
                cell.lblContent.attributedText = txt
            }
            break
        case 4:
            cell.lblContent.text = Key.shared.username
            break
        case 5:
            print("verify \(Key.shared.userPhoneVerified)")
            if !Key.shared.userPhoneVerified { //Key.shared.userPhoneNumber == "" {
                let txt = NSMutableAttributedString()
                txt.append(NSAttributedString(attachment: excla))
                let str = NSAttributedString(string: "  Link", attributes: attr)
                txt.append(NSAttributedString(attributedString: str))
                
                cell.lblContent.attributedText = txt
            } else {
                print("\(String(describing: Key.shared.userPhoneNumber))")
                let arrPhone = Key.shared.userPhoneNumber?.split(separator: "(")[0].split(separator: ")")
                let phoneNumber = "+" + arrPhone![0] + " " + arrPhone![1]
                cell.lblContent.text = phoneNumber
            }
            break
        default:
            cell.lblContent.text = ""
            break
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
            break
        case 1:
            let vc = SetNameViewController()
            vc.delegate = self
            vc.enterMode = .birth
            vc.dateOfBirth = cell.lblContent.text
            navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            let vc = SetNameViewController()
            vc.delegate = self
            vc.enterMode = .gender
            vc.gender = Key.shared.gender
            navigationController?.pushViewController(vc, animated: true)
            break
        case 3:
            let vc = UpdateUsrnameEmailViewController()
            vc.delegate = self
            vc.strEmail = Key.shared.userEmail
            vc.enterMode = .email
            navigationController?.pushViewController(vc, animated: true)
            break
        case 4:
            let vc = UpdateUsrnameEmailViewController()
            //            vc.delegate = self
            vc.strUsername = cell.lblContent.text
            vc.enterMode = .usrname
            navigationController?.pushViewController(vc, animated: true)
            break
        case 5:
            if !Key.shared.userPhoneVerified {
                let vc = SignInPhoneViewController()
//                vc.delegate = self
                vc.enterMode = .settings
                navigationController?.pushViewController(vc, animated: true)
                break
            } else {
                let vc = UpdateUsrnameEmailViewController()
                vc.delegate = self
                let arrPhone = cell.lblContent.text?.split(separator: " ")
                vc.strPhone = "\(arrPhone![1])"
                vc.enterMode = .phone
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 6:
            let vc = SetNameViewController()
            vc.enterMode = .password
            vc.pswdEnterMode = .password
            navigationController?.pushViewController(vc, animated: true)
            break
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
    
    // SetNameBirthGenderDelegate
    func updateInfo() {
        faeUser.getAccountBasicInfo({(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully get basic info")
                print(message!)
                self.tblAccount.reloadData()
            }
            else {
                print("Fail to get basic info")
            }
        })
    }
    
    // UpdateUsrnameEmailDelegate
    func updateEmail() {
        print("updateEmail")
        tblAccount.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
    }
    
    func updatePhone() {
        print("updatePhone")
        tblAccount.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)
    }
}
