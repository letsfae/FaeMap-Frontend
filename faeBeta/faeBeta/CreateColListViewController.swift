//
//  CreatePlaceColListViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class CreateColListViewController: UIViewController, UITextViewDelegate {
    // MARK: - Properties
    public var enterMode: CollectionTableMode!
    private var uiviewNavBar: UIView!
    private var btnCancel: UIButton!
    private var btnCreate: UIButton!
    private var lblNameRemainChars: UILabel!
    private var lblDespRemainChars: UILabel!
    private var lblDescription: UILabel!
    private var nameRemainChars: Int!
    private var despRemainChars: Int!
    private var textviewListName: UITextView!
    private var textviewDesp: UITextView!
    private let placeholder = ["List Name", "Describe your List"]
    private var keyboardHeight: CGFloat = 0
    public var strListName: String = ""
    public var strListDesp: String = ""
    public var colId: Int = -1
    private let faeCollection = FaeCollection()
    private var uiviewPrivacy: UIView!
    private var fromPlaceLocDetail = false
    private let realm = try! Realm()
    
    private var numLinesName = 1 {
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
    private var numLinesDesp = 1
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadContent()
        loadPrivacyView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func loadNavBar() {
        uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65 + device_offset_top))
        view.addSubview(uiviewNavBar)
        
        let line = UIView(frame: CGRect(x: 0, y: 64 + device_offset_top, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewNavBar.addSubview(line)
        
        btnCancel = UIButton(frame: CGRect(x: 0, y: 21 + device_offset_top, width: 87, height: 43))
        uiviewNavBar.addSubview(btnCancel)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._115115115(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnCancel.addTarget(self, action: #selector(self.actionCancel(_:)), for: .touchUpInside)
        
        btnCreate = UIButton(frame: CGRect(x: screenWidth - 85, y: 21 + device_offset_top, width: 85, height: 43))
        uiviewNavBar.addSubview(btnCreate)
        btnCreate.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnCreate.addTarget(self, action: #selector(self.actionCreateList(_:)), for: .touchUpInside)
        btnCreate.setTitleColor(UIColor._2499090(), for: .normal)
        btnCreate.setTitleColor(UIColor._255160160(), for: .disabled)
        
        let lblTitle = UILabel(frame: CGRect(x: (screenWidth - 145) / 2, y: 28 + device_offset_top, width: 145, height: 27))
        uiviewNavBar.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        if strListName == "" {
            lblTitle.text =  "Create New List"
            btnCreate.setTitle("Create", for: .normal)
            btnCreate.tag = 0
            btnCreate.isEnabled = false
        } else {
            lblTitle.text =  "List Settings"
            btnCreate.setTitle("Save", for: .normal)
            btnCreate.tag = 1
            btnCreate.isEnabled = true
        }
    }
    
    private func loadContent() {
        let uiviewContent = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top))
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
        nameRemainChars = 60 - strListName.count
        lblNameRemainChars.text = String(nameRemainChars)
        lblNameRemainChars.textAlignment = .right
        uiviewContent.addSubview(lblNameRemainChars)
        
        lblDespRemainChars = UILabel(frame: CGRect(x: screenWidth - 50, y: 122, width: 30, height: 22))
        lblDespRemainChars.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDespRemainChars.textColor = UIColor._155155155()
        despRemainChars = 300 - strListDesp.count
        lblDespRemainChars.text = String(despRemainChars)
        lblDespRemainChars.textAlignment = .right
        uiviewContent.addSubview(lblDespRemainChars)
        
        textviewListName = UITextView(frame: CGRect(x: 20, y: 57, width: screenWidth - 40, height: 40))
        textviewListName.delegate = self
        textviewListName.font = UIFont(name: "AvenirNext-Regular", size: 22)
        textviewListName.textColor = strListName == "" ? UIColor._155155155() : UIColor._898989()
        textviewListName.tintColor = UIColor._2499090()
        textviewListName.text = strListName == "" ? placeholder[0] : strListName
        textviewListName.returnKeyType = .next
        uiviewContent.addSubview(textviewListName)
        
        textviewDesp = UITextView(frame: CGRect(x: 20, y: 159, width: screenWidth - 40, height: screenHeight - 159 - 65))
        textviewDesp.delegate = self
        textviewDesp.font = UIFont(name: "AvenirNext-Regular", size: 22)
        textviewDesp.textColor = strListDesp == "" ? UIColor._155155155() : UIColor._898989()
        textviewDesp.tintColor = UIColor._2499090()
        textviewDesp.text = strListDesp == "" ? placeholder[1] : strListDesp
        textviewDesp.returnKeyType = .next
        uiviewContent.addSubview(textviewDesp)
        
        textviewListName.becomeFirstResponder()
    }
    
    private func loadPrivacyView() {
        uiviewPrivacy = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        uiviewPrivacy.backgroundColor = .white
        view.addSubview(uiviewPrivacy)
        
        let upperLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        uiviewPrivacy.addSubview(upperLine)
        upperLine.backgroundColor = UIColor._200199204()
        
        let lowerLine = UIView(frame: CGRect(x: 0, y: 49, width: screenWidth, height: 1))
        uiviewPrivacy.addSubview(lowerLine)
        lowerLine.backgroundColor = UIColor._200199204()
        
        let imgLock = UIImageView(frame: CGRect(x: 15, y: 17, width: 16, height: 18))
        imgLock.image = #imageLiteral(resourceName: "collection_locker")
        imgLock.contentMode = .scaleAspectFill
        uiviewPrivacy.addSubview(imgLock)
        
        let lblPrivacy = FaeLabel(CGRect(x: 41, y: 15, width: screenWidth - 41, height: 25), .left, .medium, 18, UIColor._155155155())
        lblPrivacy.text = "Private List - Shareable"
        uiviewPrivacy.addSubview(lblPrivacy)
    }
    
    // MARK: - Button actions
    @objc private func actionCancel(_ sender: UIButton) {
        textviewListName.resignFirstResponder()
        textviewDesp.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc private func actionCreateList(_ sender: UIButton) {
        strListName = self.textviewListName.textColor == UIColor._155155155() ? "" : self.textviewListName.text
        strListDesp = self.textviewDesp.textColor == UIColor._155155155() ? "" : self.textviewDesp.text
        let curtDate = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let time = dateformatter.string(from: curtDate)
        
        if sender.tag == 0 {  // create
            faeCollection.whereKey("type", value: enterMode.rawValue)
            faeCollection.whereKey("name", value: strListName)
            if strListDesp != "" {
                faeCollection.whereKey("description", value: strListDesp)
            }
            faeCollection.whereKey("is_private", value: "true")
            faeCollection.createCollection { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                if status / 100 == 2 {
                    let colId = JSON(message!)["collection_id"].intValue
                    
                    self.textviewListName.resignFirstResponder()
                    self.textviewDesp.resignFirstResponder()
                    self.dismiss(animated: true)
                    print("[Create Collection] Create Successfully \(status) \(message!)")
                    
                    // store to realm
                    let realmCol = RealmCollection(value: [colId, self.strListName, Key.shared.user_id, self.strListDesp, self.enterMode.rawValue, false, time, 0, time])
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(realmCol, update: false)
                    }
                } else {
                    print("[Create Collection] Fail to Create \(status) \(message!)")
                }
            }
        } else {  // save
            faeCollection.whereKey("name", value: strListName)
            if strListDesp != "" {
                faeCollection.whereKey("description", value: strListDesp)
            }
            faeCollection.whereKey("is_private", value: "true")
            faeCollection.editOneCollection(String(colId)) { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                if status / 100 == 2 {
                    // store to realm
                    let realm = try! Realm()
                    let realmCol = realm.filterCollection(id: self.colId)
                    try! realm.write {
                        realmCol?.name = self.strListName
                        realmCol?.descrip = self.strListDesp
                        realmCol?.last_updated_at = time
                    }
                    self.textviewListName.resignFirstResponder()
                    self.textviewDesp.resignFirstResponder()
                    self.dismiss(animated: true)
                } else {
                    print("[Create Collection] Fail to Create \(status) \(message!)")
                }
            }
        }
    }
    
    // MARK: - UITextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == textviewListName && strListName == "") || (textView == textviewDesp && strListDesp == "") {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.textColor == UIColor._155155155() {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView == textviewListName {
                textviewDesp.becomeFirstResponder()
            } else if textView == textviewDesp {
                textviewDesp.resignFirstResponder()
            }
            return false
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText.isEmpty {
            if textView == textviewListName {
                lblNameRemainChars.text = "60"
                btnCreate.isEnabled = false
            } else {
                lblDespRemainChars.text = "300"
            }
            textView.text = textView == textviewListName ? placeholder[0] : placeholder[1]
            textView.textColor = UIColor._155155155()
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        } else if textView.textColor == UIColor._155155155() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor._898989()
        }
        return textView == textviewListName ? newText.count <= 60 : newText.count <= 300
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == textviewListName {
            btnCreate.isEnabled = textView.text != ""
            nameRemainChars = 60 - textView.text.count
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
            despRemainChars = 300 - textView.text.count
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
        
        if textView.text.count == 0 {
            textView.text = textView == textviewListName ? placeholder[0] : placeholder[1]
            textView.textColor = UIColor._155155155()
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    // MARK: - Keyboard show & hide
    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        
        uiviewPrivacy.frame.origin.y = screenHeight - keyboardHeight - 50
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            uiviewPrivacy.frame.origin.y = screenHeight - 50
        }
    }
}
