//
//  SetDisplayName.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/17.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

protocol ViewControllerIntroDelegate: class {
    func protSaveIntro(txtIntro: String?)
}

class SetShortIntro: UIViewController {
    
    weak var delegate: ViewControllerIntroDelegate?
    var btnBack: UIButton!
    var lblTitle: UILabel!
    var txtField: FAETextField!
    var lblEditIntro: UILabel!
    var btnSave: UIButton!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        btnBack = UIButton(frame: CGRect(x: 15, y: 36, width: 18, height: 18))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        lblTitle = UILabel(frame: CGRect(x: 0, y: 99, width: screenWidth, height: 27))
        view.addSubview(lblTitle)
        lblTitle.text = "Short Intro"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textColor = UIColor._898989()
        lblTitle.textAlignment = .center
        
        txtField = FAETextField(frame: CGRect(x: screenWidth/2-104, y: 174, width: 207, height: 34))
        view.addSubview(txtField)
        txtField.placeholder = "Write a Short Intro"
        txtField.textAlignment = .center
        //txtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        lblEditIntro = UILabel(frame: CGRect(x: 0, y: screenHeight-371, width: screenWidth, height: 18))
        view.addSubview(lblEditIntro)
        lblEditIntro.text = "30 Characters"
        lblEditIntro.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblEditIntro.textColor = UIColor._138138138()
        lblEditIntro.textAlignment = .center
        
        btnSave = UIButton(frame: CGRect(x: screenWidth/2-150, y: screenHeight-337, width: 300, height: 50))
        view.addSubview(btnSave)
        btnSave.setImage(#imageLiteral(resourceName: "settings_save"), for: .normal)
        btnSave.addTarget(self, action: #selector(actionSaveIntro(_: )), for: .touchUpInside)
    }
    
    func textFieldDidChange(textField: UITextField) {
        lblEditIntro.text = "\(30-(txtField.text?.count)!) Characters"
        lblEditIntro.textColor = UIColor._2499090()
    }
    
    @objc func actionSaveIntro(_ sender: UIButton) {
        delegate?.protSaveIntro(txtIntro: txtField.text)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
