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

class SetShortIntro: UIViewController, UITextViewDelegate {
    
    weak var delegate: ViewControllerIntroDelegate?
    var btnBack: UIButton!
    var lblTitle: UILabel!
    var lblPlaceholder: UILabel!
    var textView: UITextView!
    var lblEditIntro: UILabel!
    var btnSave: UIButton!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        
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
        
        textView = UITextView(frame: CGRect(x: 0, y: 174, width: 244, height: 105))
        textView.center.x = screenWidth / 2
        view.addSubview(textView)
        textView.textAlignment = .left
        textView.textColor = UIColor._898989()
        textView.tintColor = UIColor._2499090()
        textView.font = UIFont(name: "AvenirNext-Regular", size: 25)
        textView.delegate = self
        
        lblPlaceholder = UILabel(frame: CGRect(x: 0, y: 0, width: 244, height: 34))
        textView.addSubview(lblPlaceholder)
        lblPlaceholder.frame.origin.y = (textView.font?.pointSize)! / 3
        lblPlaceholder.text = "Write a Short Intro"
        lblPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 25)
        lblPlaceholder.textColor = UIColor._155155155()
        lblPlaceholder.textAlignment = .center
        
        lblEditIntro = UILabel(frame: CGRect(x: 0, y: 365, width: screenWidth, height: 18))
        view.addSubview(lblEditIntro)
        lblEditIntro.text = "30 Characters"
        lblEditIntro.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblEditIntro.textColor = UIColor._138138138()
        lblEditIntro.textAlignment = .center
        
        btnSave = UIButton(frame: CGRect(x: 0, y: 399, width: 300, height: 50))
        btnSave.center.x = screenWidth / 2
        view.addSubview(btnSave)
        btnSave.setImage(#imageLiteral(resourceName: "settings_save"), for: .normal)
        btnSave.addTarget(self, action: #selector(actionSaveIntro(_: )), for: .touchUpInside)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxCharacter: Int = 30
        return (textView.text?.utf16.count ?? 0) + text.utf16.count - range.length <= maxCharacter
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.utf16.count
        lblEditIntro.text = "\(30-(count)) Characters"
        if count == 30 {
            lblEditIntro.textColor = UIColor._2499090()
        }
        lblPlaceholder.isHidden = count != 0
    }
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            textView.resignFirstResponder()
        }
    }
    
    @objc func actionSaveIntro(_ sender: UIButton) {
        delegate?.protSaveIntro(txtIntro: textView.text)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
