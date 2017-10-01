//
//  EditMemoViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-30.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol EditMemoDelegate: class {
    func saveMemo(memo: String)
}

class EditMemoViewController: UIViewController, UITextViewDelegate {
    var uiviewMemo: UIView!
    var uiviewEditMemo: UIView!
    var btnCancelMemo: UIButton!
    var btnSaveMemo: UIButton!
    var textviewMemo: UITextView!
    var lblRemainTxt: UILabel!
    var txtCount: Int!
    let placeholder = "Type a short memo..."
    var indexPath: IndexPath!
    var txtMemo: String = ""
    weak var delegate: EditMemoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 115, g: 115, b: 115, alpha: 30)
        loadMemoView()
    }
    
    func loadMemoView() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
//        view.addGestureRecognizer(tapGesture)
        
        uiviewEditMemo = UIView()
        uiviewEditMemo.backgroundColor = .white
        view.addSubview(uiviewEditMemo)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewEditMemo)
        view.addConstraintsWithFormat("V:[v0(180)]-\(286*screenHeightFactor)-|", options: [], views: uiviewEditMemo)
        
        let uiviewBlank = UIView()
        uiviewBlank.backgroundColor = .white
        view.addSubview(uiviewBlank)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewBlank)
        view.addConstraintsWithFormat("V:[v0(\(286*screenHeightFactor))]-0-|", options: [], views: uiviewBlank)
        
        btnCancelMemo = UIButton(frame: CGRect(x: 0, y: 5, width: 87, height: 42))
        uiviewEditMemo.addSubview(btnCancelMemo)
        btnCancelMemo.setTitle("Cancel", for: .normal)
        btnCancelMemo.setTitleColor(UIColor._115115115(), for: .normal)
        btnCancelMemo.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        btnCancelMemo.addTarget(self, action: #selector(self.actionCancel(_:)), for: .touchUpInside)
        
        btnSaveMemo = UIButton(frame: CGRect(x: screenWidth - 66, y: 5, width: 66, height: 42))
        uiviewEditMemo.addSubview(btnSaveMemo)
        btnSaveMemo.setTitle("Create", for: .normal)
        btnSaveMemo.setTitleColor(UIColor._2499090(), for: .normal)
        btnSaveMemo.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        btnSaveMemo.addTarget(self, action: #selector(self.actionSave(_:)), for: .touchUpInside)
        
        textviewMemo = UITextView(frame: CGRect(x: 29, y: 50, width: screenWidth - 58, height: 100))
        textviewMemo.text = txtMemo == "" ? placeholder : txtMemo
        textviewMemo.delegate = self
        textviewMemo.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textviewMemo.textColor = txtMemo == "" ? UIColor._182182182() : UIColor._898989()
        textviewMemo.tintColor = UIColor._2499090()
        uiviewEditMemo.addSubview(textviewMemo)
        textviewMemo.becomeFirstResponder()
        
        txtCount = 75 - txtMemo.characters.count
        lblRemainTxt = FaeLabel(CGRect.zero, .right, .medium, 16, UIColor._155155155())
        lblRemainTxt.text = String(txtCount)
        uiviewEditMemo.addSubview(lblRemainTxt)
        view.addConstraintsWithFormat("H:[v0(22)]-15-|", options: [], views: lblRemainTxt)
        view.addConstraintsWithFormat("V:[v0(22)]-9-|", options: [], views: lblRemainTxt)
    }
    
    
    func actionCancel(_ sender: Any) {
        hideMemoView()
    }
    
    func actionSave(_ sender: UIButton) {
        txtMemo = textviewMemo.textColor == UIColor._182182182() ? "" : textviewMemo.text
        delegate?.saveMemo(memo: txtMemo)
        hideMemoView()
    }
    
    func hideMemoView() {
        textviewMemo.resignFirstResponder()
        dismiss(animated: false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtMemo == "" {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.textColor == UIColor._182182182() {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        if newText.isEmpty {
            lblRemainTxt.text = "75"
            textView.text = placeholder
            textView.textColor = UIColor._182182182()
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        } else if textView.textColor == UIColor._182182182() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor._898989()
        }
        return newText.characters.count <= 75
    }
    
    func textViewDidChange(_ textView: UITextView) {
        txtCount = 75 - textView.text.characters.count
        lblRemainTxt.text = String(txtCount)
        
        if textView.text.characters.count == 0 {
            textView.text = placeholder
            textView.textColor = UIColor._182182182()
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
}
