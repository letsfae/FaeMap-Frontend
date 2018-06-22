//
//  SetDisplayName.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/17.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol PassDisplayNameBackDelegate: class {
    func protSaveDisplayName(txtName: String?)
}

class SetDisplayName: UIViewController, UITextViewDelegate {
    // MARK: - Properties
    weak var delegate: PassDisplayNameBackDelegate?
    private var btnBack: UIButton!
    private var lblTitle: UILabel!
    private var textField: FAETextField!
    private var lblEditIntro: UILabel!
    private var lblRequestResult: UILabel!
    private var btnSave: UIButton!
    private var txtName: String!
    private var boolWillDisappear: Bool = false
    var strFieldText: String = ""
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addObersers()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        
        btnBack = UIButton(frame: CGRect(x: 0, y: 21 + device_offset_top, width: 48, height: 48))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        lblTitle = UILabel(frame: CGRect(x: 0, y: 99 + device_offset_top, width: screenWidth, height: 27))
        view.addSubview(lblTitle)
        lblTitle.text = "Display Name"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textColor = UIColor._898989()
        lblTitle.textAlignment = .center
        
        textField = FAETextField(frame: CGRect(x: 0, y: 174 + device_offset_top, width: screenWidth - 70, height: 34))
        textField.center.x = screenWidth / 2
        view.addSubview(textField)
        textField.textAlignment = .center
        textField.placeholder = "Display Name"
        if strFieldText != "" {
            textField.text = strFieldText
        }
        
        lblRequestResult = UILabel(frame: CGRect(x: 0, y: 230 + device_offset_top, width: screenWidth, height: 20))
        lblRequestResult.center.x = screenWidth / 2
        lblRequestResult.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblRequestResult.textColor = UIColor._2499090()
        lblRequestResult.textAlignment = .center
        view.addSubview(lblRequestResult)
        lblRequestResult.isHidden = true
        
        lblEditIntro = UILabel(frame: CGRect(x: 0, y: screenHeight - 99 - 36 - device_offset_bot, width: 248, height: 36))
        lblEditIntro.center.x = screenWidth / 2
        view.addSubview(lblEditIntro)
        lblEditIntro.text = "Unlike your Username, a Display Name is\njust for show. You can change it anytime!"
        lblEditIntro.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblEditIntro.textColor = UIColor._138138138()
        lblEditIntro.textAlignment = .center
        lblEditIntro.lineBreakMode = .byWordWrapping
        lblEditIntro.numberOfLines = 0
        
        btnSave = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 - device_offset_bot, width: 300, height: 50))
        btnSave.center.x = screenWidth / 2
        view.addSubview(btnSave)
        btnSave.setImage(#imageLiteral(resourceName: "settings_save"), for: .normal)
        btnSave.addTarget(self, action: #selector(actionSaveName(_ :)), for: .touchUpInside)
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        lblRequestResult.isHidden = true
    }
    
    // MARK: - Button & gesture actions
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            textField.resignFirstResponder()
        }
    }
    
    @objc private func actionGoBack(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            textField.resignFirstResponder()
            dismiss(animated: true)
        }
    }
    
    @objc private func actionSaveName(_ sender: UIButton) {
        let user = FaeUser()
        user.whereKey("nick_name", value: textField.text!)
        user.updateNameCard { [unowned self, weak delegate = self.delegate!] (status, message) in
            if status / 100 == 2 { // TODO: error code undecided
                delegate?.protSaveDisplayName(txtName: self.textField.text)
                self.actionGoBack(sender)
            } else if status == 500 {
                self.setRequestResult("Internal Service Error!")
            } else {
                felixprint("update display name failed")
                let messageJSON = JSON(message!)
                if let error_code = messageJSON["error_code"].string {
                    handleErrorCode(.auth, error_code, { [weak self] (prompt) in
                        self?.setRequestResult("Save Failed! Please try later!")
                    })
                }
            }
        }
    }
    
    private func setRequestResult(_ prompt: String) {
        lblRequestResult.text = prompt
        lblRequestResult.isHidden = false
    }
    
    // MARK: - Keyboard observer
    @objc func keyboardWillShow(_ notification: Notification) {
        if boolWillDisappear {
            return
        }
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.3, animations: {
            self.lblEditIntro.frame.origin.y = screenHeight - frameKeyboard.height - 119
            self.btnSave.frame.origin.y = screenHeight - frameKeyboard.height - 64
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if boolWillDisappear {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.lblEditIntro.frame.origin.y = screenHeight - 99 - 36 - device_offset_bot
            self.btnSave.frame.origin.y = screenHeight - 30 - 50 - device_offset_bot
        })
    }
}
