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

class ContactsNotAllowedController: UIViewController {
    
    var uiviewNavBar: FaeNavBar!
    var uiviewSchbar: UIView!
    var imgGhost: UIImageView!
    var lblPrompt: UILabel!
    var lblInstructions: UILabel!
    var btnAllowAccess: UIButton!
    var contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        loadMain()
        definesPresentationContext = true
        view.backgroundColor = .white
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = "Add From Contacts"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
    }
    
    func loadMain() {
        imgGhost = UIImageView()
        imgGhost.frame = CGRect(x: (screenWidth - 252) / 2, y: 184 * screenHeightFactor, width: 252, height: 209)
        imgGhost.contentMode = .scaleAspectFit
        imgGhost.image = #imageLiteral(resourceName: "ghostContacts")
        view.addSubview(imgGhost)
        
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
        
        view.addSubview(lblPrompt)
        view.addSubview(lblInstructions)
        view.addSubview(btnAllowAccess)
        
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblPrompt)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblInstructions)
        let padding = (screenWidth - 300 * screenWidthFactor) / 2
        view.addConstraintsWithFormat("H:|-\(padding)-[v0(\(300 * screenWidthFactor))]", options: [], views: btnAllowAccess)
        
        view.addConstraintsWithFormat("V:[v0(56)]-23-[v1(44)]-59-[v2(50)]-36-|", options: [], views: lblPrompt, lblInstructions, btnAllowAccess)
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func actionAllowAccess(_ sender: UIButton) {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        print(authStatus)
        if (authStatus == CNAuthorizationStatus.notDetermined) {
            contactStore.requestAccess(for: entityType, completionHandler: { (success, nil) in
                if success {
                    print("success")
                    let vc = AddFromContactsController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = ContactsNotAllowedController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        } else if (authStatus == CNAuthorizationStatus.denied) {
            let vc = ContactsNotAllowedController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if authStatus == CNAuthorizationStatus.authorized {
            let vc = AddFromContactsController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


