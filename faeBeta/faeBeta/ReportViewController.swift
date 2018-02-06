//
//  ReportViewController.swift
//  faeBeta
//
//  Created by Yue on 10/31/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController, UITextViewDelegate {
    
    /*  Report type
     *  0 == report pin
     *  1 == feedback
     *  2 == tag
     */
    var reportType: Int = 0
    let REPORT = 0
    let FEEDBACK = 1
    let TAG = 2
    let colorPlaceHolder = UIColor(r: 155, g: 155, b: 155, alpha: 100)
    
    var btnBack: UIButton!
    var imgDesc: UIImageView!
    var txtViewContent: UITextView!
    var btnSend: UIButton!
    var lblPlaceholder: UILabel!
    var preStatusBarStyle = UIStatusBarStyle.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        loadBasicItems()
        addObservers()
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtViewContent.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = preStatusBarStyle
    }
    
    func loadBasicItems() {
        btnBack = UIButton()
        btnBack.setImage(UIImage(named: "reportCommentBackToMap"), for: UIControlState())
        view.addSubview(btnBack)
        view.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: btnBack)
        view.addConstraintsWithFormat("V:|-\(21+device_offset_top)-[v0(48)]", options: [], views: btnBack)
        btnBack.addTarget(self,
                                            action: #selector(ReportViewController.actionBackToCommentPinDetail(_:)),
                                            for: .touchUpInside)
        
        imgDesc = UIImageView(frame: CGRect(x: 0, y: 72 + device_offset_top, width: 361 * screenWidthFactor, height: 54 * screenHeightFactor))
        imgDesc.center.x = screenWidth / 2
        imgDesc.contentMode = .scaleAspectFit
        view.addSubview(imgDesc)
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(ReportViewController.tapOutsideToDismissKeyboard(_:)))
        view.addGestureRecognizer(tapToDismissKeyboard)
        
        let font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnSend = UIButton(frame: CGRect(x: 0, y: screenHeight - 176 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnSend.center.x = screenWidth / 2
        btnSend.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: font!]), for: UIControlState())
        btnSend.layer.cornerRadius = 25 * screenHeightFactor
        btnSend.backgroundColor = UIColor._2499090()
        btnSend.addTarget(self, action: #selector(ReportViewController.actionSendReport(_:)), for: .touchUpInside)
        view.insertSubview(btnSend, at: 0)
        view.bringSubview(toFront: btnSend)
        
        txtViewContent = UITextView()
        txtViewContent.font = UIFont(name: "AvenirNext-Regular", size: 20)
        txtViewContent.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        txtViewContent.backgroundColor = UIColor.clear
        txtViewContent.tintColor = UIColor._2499090()
        txtViewContent.delegate = self
        txtViewContent.isScrollEnabled = false
        view.addSubview(txtViewContent)
        view.addConstraintsWithFormat("H:[v0(294)]", options: [], views: txtViewContent)
        view.addConstraintsWithFormat("V:|-\(157+device_offset_top)-[v0(44)]", options: [], views: txtViewContent)
        NSLayoutConstraint(item: txtViewContent, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        lblPlaceholder = UILabel(frame: CGRect(x: 5, y: 8, width: 294, height: 27))
        lblPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lblPlaceholder.textColor = UIColor._155155155()
        if reportType == REPORT {
            lblPlaceholder.text = "Describe to us the case..."
            imgDesc.image = UIImage(named: "reportViewDescription")
        } else if reportType == FEEDBACK {
            lblPlaceholder.text = "Your Feedback..."
            imgDesc.image = UIImage(named: "reportYourFeedback")
        } else if reportType == TAG {
            lblPlaceholder.text = "New Tag(s)..."
            imgDesc.image = UIImage(named: "reportNewTags")
        }
        
        txtViewContent.addSubview(lblPlaceholder)
    }
    
    @objc func actionBackToCommentPinDetail(_ sender: UIButton) {
        txtViewContent.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func actionSendReport(_ sender: UIButton) {
        txtViewContent.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var y_offset = (screenHeight - keyboardFrame.height)
        y_offset += -self.btnSend.frame.origin.y
        y_offset +=  -50 * screenHeightFactor - 14
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnSend.frame.origin.y += y_offset
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnSend.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor
        })
    }
    
    @objc func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        txtViewContent.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == txtViewContent {
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if txtViewContent.text.trimmingCharacters(in: spacing).isEmpty == false {
                btnSend.isEnabled = true
                lblPlaceholder.isHidden = true
                btnSend.backgroundColor = UIColor._2499090()
            } else {
                btnSend.isEnabled = false
                lblPlaceholder.isHidden = false
                btnSend.backgroundColor = UIColor._255160160()
            }
        }
        let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
        if numLines <= 8 {
            let fixedWidth = textView.frame.size.width
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            textView.frame = newFrame
            textView.isScrollEnabled = false
        } else if numLines > 8 {
            textView.isScrollEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == txtViewContent {
            if text == "\n" {
                txtViewContent.resignFirstResponder()
                return false
            }
        }
        return true
    }
}
