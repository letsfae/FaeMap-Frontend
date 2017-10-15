//
//  MemoViewController.swift
//  PinsColSearch
//
//  Created by Shiqi Wei on 3/30/17.
//  Edited by Sophie Wang
//  Copyright © 2017 Shiqi Wei. All rights reserved.
//

import UIKit

protocol MemoDelegate: class {
    func memoContent(save: Bool, content: String)
}

class MemoViewController: UIViewController, UITextViewDelegate {

    weak var delegate: MemoDelegate?
    var uiviewBlurMemo : UIView!
    var uiviewMemo : UIView!
    var txtMemo: UITextView!
    var lblPlaceholder : UILabel!
    var keyboardHeight : CGFloat = 0
    var lblWordsCount: UILabel!
    var btnSave : UIButton!
    var btnCancel : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        loadBlurView()
        loadMemo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.txtMemo.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, animations: ({
            self.uiviewBlurMemo.backgroundColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 0.3)
        }))
    }

    func loadBlurView() {
        uiviewBlurMemo = UIView()
        uiviewBlurMemo.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        uiviewBlurMemo.backgroundColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 0)
        self.view.addSubview(uiviewBlurMemo)
    }
    // override textViewDidChange function to limit the length of chars
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceholder.isHidden = !textView.text.isEmpty
        let leftcharscount = 50 - textView.text.count
        if leftcharscount < 0 {
            lblWordsCount.textColor = UIColor._2499090()
            btnSave.isEnabled = false
            btnSave.alpha = 0.6
        }
        else {
            lblWordsCount.textColor = UIColor._155155155()
            btnSave.isEnabled = true
            btnSave.alpha = 1
        }
        lblWordsCount.text = String(leftcharscount)
    }
    
    func loadMemo() {
        uiviewMemo = UIView(frame: CGRect(x: 0, y: screenHeight-keyboardHeight-180, width: screenWidth, height: 180))
        uiviewMemo.backgroundColor = .white
        self.view.addSubview(uiviewMemo)
        txtMemo = UITextView(frame: CGRect(x: 20, y: 50, width: screenWidth-40, height: screenHeight/2-keyboardHeight-50))
        txtMemo.delegate = self
        txtMemo.isEditable = true
        txtMemo.tintColor = UIColor._2499090()
        txtMemo.font = UIFont(name: "AvenirNext-Regular", size: 18)
        txtMemo.textColor = UIColor._898989()
        //placeholder
        lblPlaceholder = UILabel()
        lblPlaceholder.text = "Type a short memo..."
        lblPlaceholder.font = txtMemo.font
        lblPlaceholder.sizeToFit()
        txtMemo.addSubview(lblPlaceholder)
        lblPlaceholder.frame.origin = CGPoint(x: 5, y: (txtMemo.font?.pointSize)!/2)
        lblPlaceholder.textColor = UIColor.lightGray
        lblPlaceholder.isHidden = !txtMemo.text.isEmpty
        uiviewMemo.addSubview(txtMemo)
        
        btnCancel = UIButton(frame: CGRect(x: 15, y: 15, width: 51, height: 22))
        btnSave = UIButton(frame: CGRect(x: screenWidth-51, y: 15, width: 36, height: 22))
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        btnCancel.setTitleColor(UIColor(r: 49, g: 63, b: 72, alpha: 100), for: .normal)
        btnCancel.backgroundColor = .clear
        btnCancel.addTarget(self, action: #selector(self.actionDismissCurrentView(_:)), for: .touchUpInside)
        uiviewMemo.addSubview(btnCancel)
        
        btnSave.setTitle("Save", for: .normal)
        btnSave.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        btnSave.setTitleColor(UIColor._2499090(), for: .normal)
        btnSave.backgroundColor = .clear
        btnSave.addTarget(self, action: #selector(self.actionSaveBtn(_:)), for: .touchUpInside)
        uiviewMemo.addSubview(btnSave)
        
        lblWordsCount = UILabel(frame: CGRect(x: screenWidth-54, y: self.uiviewMemo.frame.height-30, width: 40, height: 22))
        lblWordsCount.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblWordsCount.textAlignment = .right
        lblWordsCount.textColor = UIColor._155155155()
        lblWordsCount.text = "50"
        uiviewMemo.addSubview(lblWordsCount)
    }
    
    //dismiss current view
    func actionDismissCurrentView(_ sender: UIButton) {
        self.delegate?.memoContent(save: false, content: "")
        self.txtMemo.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    // save button action
    func actionSaveBtn(_ sender: UIButton) {
        self.delegate?.memoContent(save: true, content: txtMemo.text)
        self.txtMemo.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //resize the height of the view when the keyboard will show
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            self.uiviewMemo.frame = CGRect(x: 0, y: screenHeight-keyboardHeight-180, width: screenWidth, height: 180)
            self.txtMemo.frame = CGRect(x: 20, y: 50, width: screenWidth-40, height: self.uiviewMemo.frame.height-50)
            self.lblWordsCount.frame = CGRect(x: screenWidth-54, y: self.uiviewMemo.frame.height-30, width: 40, height: 22)
        }
    }
}
