//
//  CreatePlaceColListViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class CreateColListViewController: UIViewController {
    var uiviewNavBar: UIView!
    var btnCancel: UIButton!
    var btnCreate: UIButton!
    var lblListName: UILabel!
    var lblDescription: UILabel!
    var lblNameRemainChars: UILabel!
    var lblDespRemainChars: UILabel!
    var textviewListName: UITextView!
    var textviewDesp: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadContent()
    }
    
    fileprivate func loadNavBar() {
        uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        view.addSubview(uiviewNavBar)
        
        let line = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewNavBar.addSubview(line)
        
        btnCancel = UIButton(frame: CGRect(x: 0, y: 21, width: 87, height: 43))
        uiviewNavBar.addSubview(btnCancel)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._115115115(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        btnCreate = UIButton(frame: CGRect(x: screenWidth - 85, y: 21, width: 85, height: 43))
        uiviewNavBar.addSubview(btnCreate)
        btnCreate.setTitle("Create", for: .normal)
        btnCreate.setTitleColor(UIColor._255160160(), for: .normal)
        btnCreate.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnCreate.addTarget(self, action: #selector(actionCreateList(_:)), for: .touchUpInside)
        btnCreate.isEnabled = false
        
        let lblTitle = UILabel(frame: CGRect(x: (screenWidth - 145) / 2, y: 28, width: 145, height: 27))
        uiviewNavBar.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.text = "Create New List"
    }
    
    func loadContent() {
        let uiviewContent = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
    }
    
    func actionCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func actionCreateList(_ sender: UIButton) {
        
    }
}
