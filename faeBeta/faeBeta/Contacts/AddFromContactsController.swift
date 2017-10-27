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

class AddFromContactsController: UIViewController, UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate, SignInPhoneDelegate {
    var uiviewNavBar: FaeNavBar!
    var uiviewSchbar: UIView!
    var schbarFromContacts: FaeSearchBarTest!
    var tblFromContacts: UITableView!
    var filtered: [UserNameCard] = [] // for search bar results
    var testArray = [UserNameCard]()
    var uiviewNotAllowed: UIView!
    var imgGhost: UIImageView!
    var lblPrompt: UILabel!
    var lblInstructions: UILabel!
    var btnAllowAccess: UIButton!
    var boolAllowAccess = false
    var contactStore = CNContactStore()
    var phoneNumbers: String = ""
    var arrCountries = [CountryCodeStruct]()
    
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
        filtered = testArray.filter { text in
            (text.userName.lowercased()).range(of: searchText.lowercased()) != nil
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeAddUsernameCell", for: indexPath) as! FaeAddUsernameCell
            if schbarFromContacts.txtSchField.text != "" {
                cell.lblUserName.text = filtered[indexPath.row].displayName
                cell.lblUserSaying.text = filtered[indexPath.row].userName
            } else {
                cell.lblUserName.text = testArray[indexPath.row].displayName
            }
            if indexPath.row == tblFromContacts.numberOfRows(inSection: 0)-1 {
                cell.bottomLine.isHidden = true
            }
            return cell
        }
        else {
            let cell = FaeInviteCell(style: UITableViewCellStyle.default, reuseIdentifier: "myInviteCell")
            cell.lblName.text = testArray[indexPath.row].displayName
            cell.lblTel.text = testArray[indexPath.row].userName
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
        let path = Bundle.main.path(forResource: "CountryCode", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        let phoneJson = JSON(data: jsonData! as Data)["data"]
        
        for each in phoneJson.array! {
            let country = CountryCodeStruct(json: each)
            arrCountries.append(country)
        }
        
        let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey]
        let req = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        self.testArray = []
        
        try! CNContactStore().enumerateContacts(with: req) {
            contact, error in
            /*
            for phone in contact.phoneNumbers {
                let code = phone.value.value(forKey: "countryCode")
                let phoneNo = phone.value.value(forKey: "digits")
//                print("\(code!) \(phone!)")
                
                let data = self.arrCountries.filter{$0.countryCode.uppercased() == "\(code!)".uppercased()}
                var areaCode: String! = ""
                if data.count != 0 {
                    areaCode = data[0].phoneCode
                }
                
                if "\(phoneNo!)".first == "+" {
                    let sub = ("\(phoneNo!)" as NSString).substring(from: areaCode.count + 1)
                    self.phoneNumbers.append("(\(areaCode!))\(sub);")
                } else {
                    self.phoneNumbers.append("(\(areaCode!))\(phoneNo!);")
                }
            }
            print(self.phoneNumbers)
            
            let val = (self.phoneNumbers as NSString).substring(to: self.phoneNumbers.count - 1)
            let faeUser = FaeUser()
            faeUser.whereKey("phone", value: "(1)15927250906;(1)13397190906;(1)18086104610;(86)15810139390;(1)18009152660;(1)13309152660;(1)09157823181;(1)18681860625;(1)6197015409;(1)2134222248;(1)18511548911;(1)4086697450;(1)6155126877;(1)2135509641;(1)2138809613;(1)2134488701;(1)2139097189;(1)18609155011;(1)09153223213;(1)13209152660;(1)15909155536;(1)13892020000;(1)15600562736;(1)13552061643;(1)8615929152966;(1)15389159588;(1)6505565282;(1)8007770133;(1)3103517509;(1)18943414640;(1)6263478822;(1)15769256167;(1)18600576775;(1)18665834932;(1)3144203487;(1)18801467552;(1)8476246433;(1)2483089714;(1)18600795079;(1)15600562735;(1)15600562737;(1)2134466132;(1)2137061882;(1)13981713014;(1)01058812234;(1)18911897053;(1)15991361518;(1)15510010269;(1)18622185660;(1)15210584712;(1)13991555355;(1)13426004657;(1)13520915968;(1)13401175061;(1)15633817204;(1)18511184170;(1)0909146492;(1)18910111793;(1)18996359040;(1)2136753980;(86)13891581281;(1)09157810190;(1)13810217585;(1)18109156180;(1)3107177181;(1)8478684308;(1)09153115819;(1)5106106322;(1)01058812272;(1)2136753980;(1)2133092068;(1)2135198036;(1)15201294776;(1)15210902168;(1)2138106174;(1)12138060545;(1)6692460575;(1)13242786234")
            faeUser.checkPhoneExistence {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    let json = JSON(message!)
                    for i in 0..<json.count {
                        let id = json[i]["user_id"].stringValue
                        print(id)
                    }
                } else {
                    print("check phone existence failed \(status) \(message!)")
                }
            }
            */
            let contactName = contact.givenName + " " + contact.familyName
            if contact.phoneNumbers.count <= 0 {
                return
            }
            
            let phoneStr = contact.phoneNumbers[0].value.value(forKey: "digits")
            
            let arrInfo = UserNameCard(user_id: -1, nick_name: contactName.trim(), user_name: "\(phoneStr!)")
            self.testArray.append(arrInfo)
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
    
    // SignInPhoneDelegate
    func backToContacts() {
        navigationController?.popViewController(animated: false)
    }
    
    func backToAddFromContacts() {
        showView()
    }
}
