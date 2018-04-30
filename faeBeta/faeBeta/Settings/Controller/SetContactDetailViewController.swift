//
//  SetContactDetailViewController.swift
//  faeBeta
//
//  Created by Jichao on 2017/11/12.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

enum SetContactDetailType: Int {
    case supportHelp = 1
    case problem = 2
    case feedback = 3
    case question = 4
}

class SetContactDetailViewController: UIViewController {
    // MARK: - Properties
    var detailType: SetContactDetailType = .supportHelp
    private var btnBack: UIButton!
    private var lblTitle: UILabel!
    private var textField: UITextField!
    private var btnSend: UIButton!
    private var boolWillDisappear: Bool = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addObersers()
        view.backgroundColor = .white
        
        btnBack = UIButton(frame: CGRect(x: 0, y: 21 + device_offset_top, width: 48, height: 48))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        lblTitle = UILabel(frame: CGRect(x: 0, y: 72 + device_offset_top, width: screenWidth, height: 60))
        setTitleText()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textColor = UIColor._898989()
        lblTitle.textAlignment = .center
        lblTitle.numberOfLines = 0
        view.addSubview(lblTitle)
        
        textField = FAETextField(frame: CGRect(x: 0, y: 157 + device_offset_top, width: screenWidth - 50, height: 32))
        textField.center.x = screenWidth / 2
        textField.textAlignment = .left
        setPlaceholder()
        view.addSubview(textField)
        
        btnSend = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 - device_offset_bot, width: 300, height: 50))
        btnSend.center.x = screenWidth / 2
        view.addSubview(btnSend)
        btnSend.titleLabel?.textColor = .white
        btnSend.titleLabel?.textAlignment = .center
        btnSend.setTitle("Send", for: .normal)
        btnSend.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnSend.backgroundColor = UIColor._2499090()
        btnSend.layer.cornerRadius = 25
        btnSend.addTarget(self, action: #selector(actionSend(_ :)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        boolWillDisappear = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        boolWillDisappear = true
    }
    
    private func addObersers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setTitleText() {
        switch detailType {
        case .supportHelp:
            lblTitle.text = "We’re here to help! Please let us\nknow what you need support on."
        case .problem:
            lblTitle.text = "Experiencing a Problem? Please\nlet us know & we’ll look into it."
        case .question:
            lblTitle.text = "Got a Question for us? We’ll try\nour best to answer it!"
        case .feedback:
            lblTitle.text = "See somewhere that needs\nimprovement? Please let us know!"
        }
    }
    
    private func setPlaceholder() {
        switch detailType {
        case .supportHelp:
            textField.placeholder = "How can we help you?"
        case .problem:
            textField.placeholder = "Describe the problem…"
        case .question:
            textField.placeholder = "What’s your Question?"
        case .feedback:
            textField.placeholder = "Your Feedback…"
        }
    }
    
    // MARK: - Button actions
    @objc private func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionSend(_ sender: UIButton) {
        
    }
    
    // MARK: - Keyboard observer
    @objc func keyboardWillShow(_ notification: Notification) {
        if boolWillDisappear {
            return
        }
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnSend.frame.origin.y = screenHeight - frameKeyboard.height - 14 - 50
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if boolWillDisappear {
            return
        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnSend.frame.origin.y = screenHeight - 30 - 50 - device_offset_bot
        })
    }
}
