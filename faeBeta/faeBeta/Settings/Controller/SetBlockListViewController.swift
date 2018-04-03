//
//  SetBlockListViewController.swift
//  faeBeta
//
//  Created by Jichao on 2018/3/28.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class SetBlockListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FaeSearchBarTestDelegate {
    
    var uiviewNavBar: FaeNavBar!
    var uiviewSearchBar: UIView!
    var schbarBlocked: FaeSearchBarTest!
    var tblBlockList: UITableView!
    
    var arrRealmBlocked: Results<RealmUser>!
    var arrFiltered: [RealmUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBlockedList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(UIImage(), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
        uiviewNavBar.lblTitle.text = "Blocked List"
        
        uiviewSearchBar = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 49))
        view.addSubview(uiviewSearchBar)
        
        schbarBlocked = FaeSearchBarTest(frame: CGRect(x: 5, y: 0, width: screenWidth, height: 48))
        schbarBlocked.txtSchField.placeholder = "Search Blocked"
        schbarBlocked.delegate = self
        uiviewSearchBar.addSubview(schbarBlocked)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 48, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = 1
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewSearchBar.addSubview(bottomLine)
        
        tblBlockList = UITableView()
        tblBlockList.frame = CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - device_offset_top)
        tblBlockList.dataSource = self
        tblBlockList.delegate = self
        tblBlockList.separatorStyle = .none
        tblBlockList.showsVerticalScrollIndicator = false
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(tblBlockList)
        tblBlockList.register(FaeContactsCell.self, forCellReuseIdentifier: "FaeBlockedCell")
    }
    
    @objc func actionBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func loadBlockedList() {
        let realm = try! Realm()
        arrRealmBlocked = realm.objects(RealmUser.self).filter("login_user_id == %@ AND relation == %@", "\(Key.shared.user_id)", BLOCKED)
    }
    
    // MARK: FaeSearchBarTestDelegate
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        schbarBlocked.txtSchField.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        /*arrFiltered.removeAll()
        for user in arrRealmBlocked {
            if user.display_name.lowercased().range(of: searchText.lowercased()) != nil {
                arrFiltered.append(user)
            }
        }*/
        let realm = try! Realm()
        if schbarBlocked.txtSchField.text == "" {
            arrRealmBlocked = realm.objects(RealmUser.self).filter("login_user_id == %@ AND relation == %@", "\(Key.shared.user_id)", BLOCKED)
        } else {
            arrRealmBlocked = realm.objects(RealmUser.self).filter("login_user_id == %@ AND relation == %@ AND display_name CONTAINS[c] %@", "\(Key.shared.user_id)", BLOCKED, searchText.lowercased())
        }
        tblBlockList.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        schbarBlocked.txtSchField.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        schbarBlocked.txtSchField.resignFirstResponder()
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if schbarBlocked.txtSchField.text != "" {
            return arrFiltered.count
        }*/
        return arrRealmBlocked.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaeBlockedCell", for: indexPath) as! FaeContactsCell
        let dataSource = arrRealmBlocked!
        /*var dataSource: [RealmUser] = []
        if schbarBlocked.txtSchField.text != "" {
            dataSource = arrFiltered
        } else {
            for user in arrRealmBlocked {
                dataSource.append(user)
            }
        }*/
        cell.userId = Int(dataSource[indexPath.row].id)!
        if let data = dataSource[indexPath.row].avatar?.userSmallAvatar {
            cell.imgAvatar.image = UIImage(data: data as Data)
        }
        General.shared.avatar(userid: Int(dataSource[indexPath.row].id)!, completion: { (avatarImage) in
            //cell.imgAvatar.image = avatarImage
        })
        let display_name = dataSource[indexPath.row].display_name
        if display_name == "" {
            getFromURL("users/\(cell.userId)/name_card", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
                if status / 100 == 2 && result != nil {
                    let profileJSON = JSON(result!)
                    let newUser = RealmUser(value: ["\(Key.shared.user_id)_\(cell.userId)", String(Key.shared.user_id), "\(cell.userId)", profileJSON["user_name"].stringValue, profileJSON["nick_name"].stringValue, BLOCKED, profileJSON["age"].stringValue, profileJSON["gender"].stringValue, "", "", ""])
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(newUser, update: true)
                    }
                    cell.lblUserName.text = profileJSON["nick_name"].stringValue
                }
            }
        } else {
            cell.lblUserName.text = display_name
        }
        cell.lblUserSaying.text = dataSource[indexPath.row].user_name
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}
