//
//  CreatePlaceColListViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class CreateColListViewController: UIViewController, UITextViewDelegate {
    var enterMode: EnterMode!
    var uiviewNavBar: UIView!
    var btnCancel: UIButton!
    var btnCreate: UIButton!
    var lblNameRemainChars: UILabel!
    var lblDespRemainChars: UILabel!
    var lblDescription: UILabel!
    var nameRemainChars: Int = 60
    var despRemainChars: Int = 300
    var textviewListName: UITextView!
    var textviewDesp: UITextView!
    let placeholder = ["List Name", "Describe your list (Optional)"]
    var keyboardHeight: CGFloat = 0
    var numLinesName = 1 {
        didSet {
            guard textviewDesp != nil else { return }
            var numLines = 4 - numLinesName
            if screenWidth == 375 {
                numLines = 6 - numLinesName
            } else if screenWidth == 414 {
                numLines = 8 - numLinesName
            }
            textviewDesp.frame.size.height = CGFloat(numLines * 30)
        }
    }
    var numLinesDesp = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadContent()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
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
        btnCancel.addTarget(self, action: #selector(self.actionCancel(_:)), for: .touchUpInside)
        
        btnCreate = UIButton(frame: CGRect(x: screenWidth - 85, y: 21, width: 85, height: 43))
        uiviewNavBar.addSubview(btnCreate)
        btnCreate.setTitle("Create", for: .normal)
        btnCreate.setTitleColor(UIColor._255160160(), for: .normal)
        btnCreate.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnCreate.addTarget(self, action: #selector(self.actionCreateList(_:)), for: .touchUpInside)
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
        view.addSubview(uiviewContent)
        
        let lblListName = UILabel(frame: CGRect(x: 20, y: 20, width: 195, height: 22))
        lblListName.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblListName.textColor = UIColor._138138138()
        lblListName.text = "Enter a Name for your List"
        uiviewContent.addSubview(lblListName)
        
        lblDescription = UILabel(frame: CGRect(x: 20, y: 122, width: 195, height: 22))
        lblDescription.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDescription.textColor = UIColor._138138138()
        lblDescription.text = "Enter a Description"
        uiviewContent.addSubview(lblDescription)
        
        lblNameRemainChars = UILabel(frame: CGRect(x: screenWidth - 50, y: 20, width: 30, height: 22))
        lblNameRemainChars.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblNameRemainChars.textColor = UIColor._155155155()
        lblNameRemainChars.text = String(nameRemainChars)
        lblNameRemainChars.textAlignment = .right
        uiviewContent.addSubview(lblNameRemainChars)
        
        lblDespRemainChars = UILabel(frame: CGRect(x: screenWidth - 50, y: 122, width: 30, height: 22))
        lblDespRemainChars.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDespRemainChars.textColor = UIColor._155155155()
        lblDespRemainChars.text = String(despRemainChars)
        lblDespRemainChars.textAlignment = .right
        uiviewContent.addSubview(lblDespRemainChars)
        
        textviewListName = UITextView(frame: CGRect(x: 20, y: 57, width: screenWidth - 40, height: 40))
        textviewListName.delegate = self
        textviewListName.font = UIFont(name: "AvenirNext-Regular", size: 22 )
        textviewListName.textColor = UIColor._155155155()
        textviewListName.tintColor = UIColor._2499090()
        textviewListName.text = placeholder[0]
        uiviewContent.addSubview(textviewListName)
        
        textviewDesp = UITextView(frame: CGRect(x: 20, y: 159, width: screenWidth - 40, height: screenHeight - 159 - 65))
        textviewDesp.delegate = self
        textviewDesp.font = UIFont(name: "AvenirNext-Regular", size: 22 )
        textviewDesp.textColor = UIColor._155155155()
        textviewDesp.tintColor = UIColor._2499090()
        textviewDesp.text = placeholder[1]
        uiviewContent.addSubview(textviewDesp)
        
        textviewListName.becomeFirstResponder()
    }
    
    @objc func actionCancel(_ sender: UIButton) {
        textviewListName.resignFirstResponder()
        textviewDesp.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc func actionCreateList(_ sender: UIButton) {
        print("create list")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.textColor == UIColor._155155155() {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        if newText.isEmpty {
            btnCreate.setTitleColor(UIColor._255160160(), for: .normal)
            btnCreate.isEnabled = false
            if textView == textviewListName {
                lblNameRemainChars.text = "60"
            } else {
                lblDespRemainChars.text = "300"
            }
            textView.text = textView == textviewListName ? placeholder[0] : placeholder[1]
            textView.textColor = UIColor._155155155()
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        } else if textView.textColor == UIColor._155155155() && !text.isEmpty {
            btnCreate.setTitleColor(UIColor._2499090(), for: .normal)
            btnCreate.isEnabled = true
            textView.text = nil
            textView.textColor = UIColor._898989()
        }
        return textView == textviewListName ? newText.characters.count <= 60 : newText.characters.count <= 300
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == textviewListName {
            nameRemainChars = 60 - textView.text.characters.count
            lblNameRemainChars.text = String(nameRemainChars)
            if screenWidth >= 375 {
                let txtHeight = ceil(textView.contentSize.height)
                textView.frame.size.height = txtHeight
                textView.setContentOffset(CGPoint.zero, animated: false)
                let offset: CGFloat = 47
                lblDescription.frame.origin.y = 122 - offset + txtHeight
                lblDespRemainChars.frame.origin.y = 122 - offset + txtHeight
                textviewDesp.frame.origin.y = 159 - offset + txtHeight
                numLinesName = Int(textView.contentSize.height / textView.font!.lineHeight)
            }
        } else {
            numLinesDesp = 4 - numLinesName
            if screenWidth == 375 {
                numLinesDesp = 6 - numLinesName
            } else if screenWidth == 414 {
                numLinesDesp = 8 - numLinesName
            }
            despRemainChars = 300 - textView.text.characters.count;
            lblDespRemainChars.text = String(despRemainChars)
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            if numLines >= numLinesDesp {
                textView.frame.size.height = CGFloat(numLinesDesp * 30)
            } else {
                let txtHeight = ceil(textView.contentSize.height)
                textView.frame.size.height = txtHeight
                textView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
        
        if textView.text.characters.count == 0 {
            btnCreate.setTitleColor(UIColor._255160160(), for: .normal)
            btnCreate.isEnabled = false
            textView.text = textView == textviewListName ? placeholder[0] : placeholder[1]
            textView.textColor = UIColor._155155155()
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
    }
}
