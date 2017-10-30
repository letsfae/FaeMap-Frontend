//
//  AddFriendViewController.swift
//  FaeContacts
//
//  Created by Justin He on 6/14/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let optionsArray: [String] = ["Add by Username", "From Contacts", "Scan Nearby", "Share Username"]
    let recommendedFriendsArray: [Friends] = []
    let optionsImagesArray = [#imageLiteral(resourceName: "searchUsernamesIcon"), #imageLiteral(resourceName: "fromContactsIcon"), #imageLiteral(resourceName: "scanNearbyIcon"), #imageLiteral(resourceName: "shareUsernameIcon")]
    var tblOptions: UITableView!
    var contactStore = CNContactStore()
    var uiviewNavBar: FaeNavBar!
    var imgCity: UIImageView!
    var arrFriends = [Friends]()
    var arrReceivedRequests = [Friends]()
    var arrRequested = [Friends]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        loadTable()
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /* Joshua: 06/15/17
     load the top nav bar
     */
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = "New Friends"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
    }
    
    func loadTable() {
        tblOptions = UITableView()
        tblOptions.separatorStyle = .none
        tblOptions.frame = CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65)
        tblOptions.dataSource = self
        tblOptions.delegate = self
        tblOptions.register(FaeAddFriendOptionsCell.self, forCellReuseIdentifier: "FaeAddFriendOptionsCell")
        tblOptions.register(FaeRecommendedCell.self, forCellReuseIdentifier: "myRecommendedCell")
        view.addSubview(tblOptions)
        
        imgCity = UIImageView()
        imgCity.frame = CGRect(x: 0, y: screenHeight - 256 * screenHeightFactor, width: screenWidth, height: 256 * screenHeightFactor)
        imgCity.contentMode = .scaleToFill
        imgCity.image = #imageLiteral(resourceName: "contact_city")
        view.addSubview(imgCity)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return recommendedFriendsArray.count
        }
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeAddFriendOptionsCell", for: indexPath as IndexPath) as! FaeAddFriendOptionsCell
            cell.lblOption.text = "\(optionsArray[indexPath.row])"
            cell.imgIcon.image = optionsImagesArray[indexPath.row]
            if indexPath.row == optionsArray.count-1 {
                cell.bottomLine.isHidden = true
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myRecommendedCell", for: indexPath as IndexPath) as! FaeRecommendedCell
            cell.lblUserName.text = recommendedFriendsArray[indexPath.row].displayName
            cell.lblUserSaying.text = recommendedFriendsArray[indexPath.row].userName
            cell.lblUserRecommendReason.text = "through Contacts."
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let vc = AddUsernameController()
                vc.arrFriends = arrFriends
                vc.arrReceivedRequests = arrReceivedRequests
                vc.arrRequested = arrRequested
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {
                getContacts()
            } else if indexPath.row == 2 {
                let vc = AddNearbyController()
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let activityVC = UIActivityViewController(activityItems: ["Discover amazing places with me on Fae Maps! Add my Username: linlin https://www.xxx.com"], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            if (recommendedFriendsArray.count != 0) {
                imgCity.isHidden = true;
                return 25
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 93
        }
        return 53
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = UIView()
            header.backgroundColor = UIColor._248248248()
            header.frame = CGRect(x: 0, y: 0, width: screenWidth + 2, height: 25)
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            topLine.layer.borderWidth = 1
            topLine.layer.borderColor = UIColor._200199204cg()
            header.addSubview(topLine)
            let bottomLine = UIView(frame: CGRect(x: 0, y: 24, width: screenWidth, height: 1))
            bottomLine.layer.borderWidth = 1
            bottomLine.layer.borderColor = UIColor._200199204cg()
            header.addSubview(bottomLine)
            let label = UILabel()
            label.text = "Recommended"
            label.textColor = UIColor._155155155()
            label.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
            label.sizeToFit()
            header.addSubview(label)
            header.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: label)
            header.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: label)
            return header
        }
        return nil
    }
    
    func getContacts() {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)

        let vc = AddFromContactsController()
        if authStatus == .denied {
            vc.boolAllowAccess = false
            self.navigationController?.pushViewController(vc, animated: true)
            // showAlert(title: "Denied Access to Contacts", message: "It seems that you have earlier denied FaeMap access to your Contacts. In order to grant this app access to your contacts, please go to your Settings > Privacy > Contacts and change accordingly.")
        } else if authStatus == .authorized {
            vc.boolAllowAccess = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

