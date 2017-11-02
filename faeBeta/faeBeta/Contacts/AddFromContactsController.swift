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
import SwiftyJSON

struct RegisteredUser {
    let userId: Int
    let phone: String
    let relation: Relations
    let nameCard: UserNameCard
    init(userId: Int, phone: String, nameCard: UserNameCard, relation: Relations) {
        self.userId = userId
        self.phone = phone
        self.nameCard = nameCard
        self.relation = relation
    }
}

class AddFromContactsController: UIViewController, UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate, SignInPhoneDelegate, FaeAddUsernameDelegate, FriendOperationFromContactsDelegate {
    var uiviewNavBar: FaeNavBar!
    var uiviewSchbar: UIView!
    var schbarFromContacts: FaeSearchBarTest!
    var tblFromContacts: UITableView!
    var filteredUnregistered = [UserNameCard]()
    var arrUnregistered = [UserNameCard]()
    var filteredRegistered = [RegisteredUser]()
    var arrRegistered = [RegisteredUser]()
    var uiviewNotAllowed: UIView!
    var imgGhost: UIImageView!
    var lblPrompt: UILabel!
    var lblInstructions: UILabel!
    var btnAllowAccess: UIButton!
    var boolAllowAccess = false
    var contactStore = CNContactStore()
    var phoneNumbers: String = ""
    var dictCountryCode: Dictionary = [String : CountryCodeStruct]()
    var dictPhone: Dictionary = [String: UserNameCard]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        definesPresentationContext = true
        view.backgroundColor = .white
        loadSearchTable()
        loadNotAllowedView()
        self.showView()
        linkPhoneNumber()
    }
    
    func linkPhoneNumber() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({(status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            let selfUserInfoJSON = JSON(message!)
            let phone = selfUserInfoJSON["phone_verified"].boolValue
            if phone == false {
                self.uiviewNotAllowed.isHidden = true
                self.uiviewSchbar.isHidden = true
                self.tblFromContacts.isHidden = true
                let vc = SignInPhoneViewController()
                vc.delegate = self
                vc.enterMode = .contacts
                self.present(vc, animated: true)
            }
        })
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
    
    @objc func actionGoBack(_ sender: UIButton) {
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
        tblFromContacts.register(FaeInviteCell.self, forCellReuseIdentifier: "FaeInviteCell")
        tblFromContacts.isHidden = false
        tblFromContacts.indicatorStyle = .white
        tblFromContacts.separatorStyle = .none
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
        filteredUnregistered = arrUnregistered.filter { text in
            (text.displayName.lowercased()).range(of: searchText.lowercased()) != nil
        }
        filteredRegistered = arrRegistered.filter { text in
            (text.nameCard.userName.lowercased()).range(of: searchText.lowercased()) != nil
        }
        tblFromContacts.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return schbarFromContacts.txtSchField.text != "" ? filteredRegistered.count : arrRegistered.count
        } else {
            return schbarFromContacts.txtSchField.text != "" ? filteredRegistered.count : arrUnregistered.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeAddUsernameCell", for: indexPath) as! FaeAddUsernameCell
            let registered = schbarFromContacts.txtSchField.text != "" ? filteredRegistered[indexPath.row] : arrRegistered[indexPath.row]
            cell.delegate = self
            cell.userId = registered.userId
            cell.indexPath = indexPath
            cell.setValueForCell(user: registered.nameCard)
            cell.getFromRelations(id: registered.userId, relation: registered.relation)
            if indexPath.row == tblFromContacts.numberOfRows(inSection: 0)-1 {
                cell.bottomLine.isHidden = true
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeInviteCell", for: indexPath) as! FaeInviteCell
            cell.lblName.text = arrUnregistered[indexPath.row].displayName
            cell.lblTel.text = arrUnregistered[indexPath.row].userName
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        if schbarFromContacts.txtSchField.text != "" && filteredRegistered.count == 0 {
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
    
    func openContacts() {
        let path = Bundle.main.path(forResource: "CountryCode", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        let phoneJson = JSON(data: jsonData! as Data)["data"]
        
        for each in phoneJson.array! {
            let country = CountryCodeStruct(json: each)
            dictCountryCode[country.countryCode] = country
        }
        //        print(dictCountryCode)
        
        let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey]
        let req = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        try! CNContactStore().enumerateContacts(with: req) {
            contact, error in
            
            let contactName = contact.givenName == "" ? contact.familyName : contact.givenName + " " + contact.familyName
            if contact.phoneNumbers.count <= 0 {
                return
            }
            
            let code = contact.phoneNumbers[0].value.value(forKey: "countryCode")
            let phoneNo = contact.phoneNumbers[0].value.value(forKey: "digits")
            
            let countryInfo = self.dictCountryCode["\(code!)".uppercased()]
            var areaCode = ""
            if countryInfo != nil {
                areaCode = (countryInfo?.phoneCode)!
            }
            
            var phoneStr = ""
            if "\(phoneNo!)".first == "+" {
                let sub = ("\(phoneNo!)" as NSString).substring(from: areaCode.count + 1)
                phoneStr = "(\(areaCode))\(sub)"
                self.phoneNumbers.append("\(phoneStr);")
            } else {
                phoneStr = "(\(areaCode))\(phoneNo!)"
                self.phoneNumbers.append("\(phoneStr);")
            }
            
            let arrInfo = UserNameCard(user_id: -1, nick_name: contactName.trim(), user_name: "\(phoneNo!)")
            self.dictPhone[phoneStr] = arrInfo
            
            self.arrUnregistered.append(arrInfo)
        }
        
        let val = (self.phoneNumbers as NSString).substring(to: self.phoneNumbers.count - 1)
        let faeUser = FaeUser()
        faeUser.whereKey("phone", value: val)
        faeUser.checkPhoneExistence {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let phoneJson = JSON(message!)
                
                for i in 0..<phoneJson.count {
                    let userId = phoneJson[i]["user_id"].intValue
                    let phone = phoneJson[i]["phone"].stringValue
                    let relation = Relations(json: phoneJson[i]["relation"])
                    self.dictPhone.removeValue(forKey: phone)
                    
                    faeUser.getUserCard(String(userId)) {(status: Int, message: Any?) in
                        if status / 100 == 2 {
                            let json = JSON(message!)
                            let userInfo = UserNameCard(user_id: userId, nick_name: json["nick_name"].stringValue, user_name: json["user_name"].stringValue)
                            let arrInfo = RegisteredUser(userId: userId, phone: phone, nameCard: userInfo, relation: relation)
                            self.arrRegistered.append(arrInfo)
                            
                            if  self.arrRegistered.count == phoneJson.count {
                                self.tblFromContacts.reloadData()
                            }
                        } else {
                            print("[get user name card fail] \(status) \(message!)")
                        }
                    }
                }
                self.arrUnregistered = self.dictPhone.values.sorted{ $0.displayName < $1.displayName }
                self.tblFromContacts.reloadData()
            } else {
                print("check phone existence failed \(status) \(message!)")
            }
        }
    }
    
    @objc func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
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
    
    @objc func actionAllowAccess(_ sender: UIButton) {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        if authStatus == .denied {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
    // SignInPhoneDelegate
    func backToContacts() {
        navigationController?.popViewController(animated: false)
    }
    
    func backToAddFromContacts() {
        showView()
    }
    
    // FaeAddUsernameDelegate
    func addFriend(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "add"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func resendRequest(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "resend"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func acceptRequest(indexPath: IndexPath, request_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "accept"
        vc.requestId = request_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func ignoreRequest(indexPath: IndexPath, request_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "ignore"
        vc.requestId = request_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func withdrawRequest(indexPath: IndexPath, request_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "withdraw"
        vc.requestId = request_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    // FaeAddUsernameDelegate End
    
    // FriendOperationFromContactsDelegate
    func passFriendStatusBack(indexPath: IndexPath) {
        tblFromContacts.reloadRows(at: [indexPath], with: .none)
    }
    // FriendOperationFromContactsDelegate End
}
