//
//  AddFromContactsController.swift
//  FaeContacts
//
//  Created by Justin He on 6/22/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class AddFromContactsController: UIViewController, UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate {
    
    var uiviewNavBar: FaeNavBar!
    var uiviewSchbar: UIView!
    var schbarFromContacts: FaeSearchBarTest!
    var tblFromContacts: UITableView!
    var filtered: [String] = [] // for search bar results
    var testArray = [String]()
    var uiviewNotAllowed: UIView!
    var imgGhost: UIImageView!
    var lblPrompt: UILabel!
    var lblInstructions: UILabel!
    var btnAllowAccess: UIButton!
    var boolAllowAccess = false
    var contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        definesPresentationContext = true
        view.backgroundColor = .white
        loadSearchTable()
        tblFromContacts.separatorStyle = .none
        
        loadNotAllowedView()
        showView()
    }
    
    func showView() {
        if boolAllowAccess {
            openContacts()
            uiviewNotAllowed.isHidden = true
            uiviewSchbar.isHidden = false
            tblFromContacts.isHidden = false
        } else {
            uiviewSchbar.isHidden = true
            tblFromContacts.isHidden = true
            uiviewNotAllowed.isHidden = false
        }
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = "Add From Contacts"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadSearchTable() {
        uiviewSchbar = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 50))
        schbarFromContacts = FaeSearchBarTest(frame: CGRect(x: 5, y: 1, width: screenWidth, height: 48))
        schbarFromContacts.txtSchField.placeholder = "Search Contacts"
        schbarFromContacts.delegate = self
        uiviewSchbar.addSubview(schbarFromContacts)

        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        topLine.layer.borderWidth = 1
        topLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(topLine)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 49, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = 1
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(bottomLine)
        
        view.addSubview(uiviewSchbar)

        tblFromContacts = UITableView()
        tblFromContacts.frame = CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 65 - 50)
        tblFromContacts.dataSource = self
        tblFromContacts.delegate = self
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
        tblFromContacts.addGestureRecognizer(tapToDismissKeyboard)
        tblFromContacts.register(FaeAddUsernameCell.self, forCellReuseIdentifier: "FaeAddUsernameCell")
        tblFromContacts.register(FaeInviteCell.self, forCellReuseIdentifier: "myInviteCell")
        tblFromContacts.isHidden = false
        tblFromContacts.indicatorStyle = .white
        view.addSubview(tblFromContacts)
    }
    
    // FaeSearchBarTestDelegate
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        filter(searchText: searchText)
    }
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        schbarFromContacts.txtSchField.becomeFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        schbarFromContacts.txtSchField.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        schbarFromContacts.txtSchField.resignFirstResponder()
    }
    // End of FaeSearchBarTestDelegate
    
    func filter(searchText: String, scope: String = "All") {
        filtered = testArray.filter { text in
            (text.lowercased()).range(of: searchText.lowercased()) != nil
        }
        tblFromContacts.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if schbarFromContacts.txtSchField.text != "" {
            return filtered.count
        } else {
            return testArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = FaeAddUsernameCell(style: UITableViewCellStyle.default, reuseIdentifier: "FaeAddUsernameCell", isFriend: false)
            if schbarFromContacts.txtSchField.text != "" {
                cell.lblUserName.text = filtered[indexPath.row]
                cell.lblUserSaying.text = filtered[indexPath.row]
                cell.isFriend = true // enabled manual togging for testing; for real, we implement API calls.
            } else {
                cell.lblUserName.text = testArray[indexPath.row]
            }
            if indexPath.row == tblFromContacts.numberOfRows(inSection: 0)-1 {
                cell.bottomLine.isHidden = true
            }
            return cell
        }
        else {
            let cell = FaeInviteCell(style: UITableViewCellStyle.default, reuseIdentifier: "myInviteCell")
            cell.lblName.text = testArray[indexPath.row]
            cell.lblTel.text = testArray[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected table row \(indexPath.row) and item \(testArray[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func openContacts() {
        let req = CNContactFetchRequest(keysToFetch: [
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor
            ])
        self.testArray = []
        try! CNContactStore().enumerateContacts(with: req) {
            contact, stop in
            self.testArray.append(contact.givenName + " " + contact.familyName)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        if schbarFromContacts.txtSchField.text != "" && filtered.count == 0 {
            return headerView
        }
        headerView.backgroundColor = UIColor._248248248()
        if section != 0 {
            let borderTop = UIView()
            borderTop.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 1)
            borderTop.layer.borderWidth = 1
            borderTop.layer.borderColor = UIColor._200199204cg()
            headerView.addSubview(borderTop)
        }
        let borderBottom = UIView()
        borderBottom.frame = CGRect(x: 0, y: 25, width: tableView.bounds.size.width, height: 1)
        borderBottom.layer.borderWidth = 1
        borderBottom.layer.borderColor = UIColor._200199204cg()
        headerView.addSubview(borderBottom)
        
        let label = UILabel()
        label.textColor = UIColor._155155155()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        headerView.addSubview(label)
        if section == 0 {
            label.text = "Already on Faevorite"
        } else {
            label.text = "Invite to Faevorite"
        }
        headerView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: label)
        headerView.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: label)
        return headerView
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        schbarFromContacts.txtSchField.resignFirstResponder()
    }

    func loadNotAllowedView() {
        uiviewNotAllowed = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        imgGhost = UIImageView()
        imgGhost.frame = CGRect(x: (screenWidth - 252) / 2, y: 119 * screenHeightFactor, width: 252, height: 209)
        imgGhost.contentMode = .scaleAspectFit
        imgGhost.image = #imageLiteral(resourceName: "ghostContacts")
        uiviewNotAllowed.addSubview(imgGhost)
        
        lblPrompt = UILabel()
        lblPrompt.textAlignment = .center
        lblPrompt.numberOfLines = 2
        lblPrompt.text = "Start adding your Friends \nfrom your contacts!"
        lblPrompt.textColor = UIColor._898989()
        lblPrompt.font = UIFont(name: "AvenirNext-Medium", size: 20)
        
        lblInstructions = UILabel()
        lblInstructions.textAlignment = .center
        lblInstructions.numberOfLines = 2
        lblInstructions.text = "Find Fae Maps in Settings and toggle \non Contacts Access, that's it!"
        lblInstructions.textColor = UIColor._155155155()
        lblInstructions.font = UIFont(name: "AvenirNext-Medium", size: 16)
        
        btnAllowAccess = UIButton()
        btnAllowAccess.backgroundColor = UIColor._2499090()
        btnAllowAccess.layer.cornerRadius = 25
        btnAllowAccess.setTitle("Allow Access", for: .normal)
        btnAllowAccess.setTitleColor(.white, for: .normal)
        btnAllowAccess.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnAllowAccess.addTarget(self, action: #selector(actionAllowAccess(_:)), for: .touchUpInside)
        
        uiviewNotAllowed.addSubview(lblPrompt)
        uiviewNotAllowed.addSubview(lblInstructions)
        uiviewNotAllowed.addSubview(btnAllowAccess)
        
        uiviewNotAllowed.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblPrompt)
        uiviewNotAllowed.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblInstructions)
        let padding = (screenWidth - 300 * screenWidthFactor) / 2
        uiviewNotAllowed.addConstraintsWithFormat("H:|-\(padding)-[v0(\(300 * screenWidthFactor))]", options: [], views: btnAllowAccess)
        
        uiviewNotAllowed.addConstraintsWithFormat("V:[v0(56)]-23-[v1(44)]-59-[v2(50)]-36-|", options: [], views: lblPrompt, lblInstructions, btnAllowAccess)
        
        view.addSubview(uiviewNotAllowed)
    }
    
    func actionAllowAccess(_ sender: UIButton) {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        if authStatus == .denied {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
}
