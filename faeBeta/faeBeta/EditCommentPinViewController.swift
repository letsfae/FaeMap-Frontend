//
//  EditCommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/30/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol EditCommentPinViewControllerDelegate {
    func reloadCommentContent()
}

class EditCommentPinViewController: UIViewController, UITextViewDelegate {
    
    var delegate: EditCommentPinViewControllerDelegate?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let colorPlaceHolder = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    
    var buttonCancel: UIButton!
    var buttonSave: UIButton!
    var labelTitle: UILabel!
    var uiviewLine: UIView!
    var textViewUpdateComment: UITextView!
    var lableTextViewPlaceholder: UILabel!
    
    var pinID = ""
    var previousCommentContent = ""
    
    var pinGeoLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        loadEditCommentPinItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textViewUpdateComment.text = previousCommentContent
        textViewUpdateComment.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadEditCommentPinItems() {
        buttonCancel = UIButton()
        buttonCancel.setImage(UIImage(named: "cancelEditCommentPin"), for: UIControlState())
        self.view.addSubview(buttonCancel)
        self.view.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonCancel)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonCancel)
        buttonCancel.addTarget(self,
                               action: #selector(self.actionCancelCommentPinEditing(_:)),
                               for: .touchUpInside)
        
        buttonSave = UIButton()
        buttonSave.setImage(UIImage(named: "saveEditCommentPin"), for: UIControlState())
        self.view.addSubview(buttonSave)
        self.view.addConstraintsWithFormat("H:[v0(38)]-15-|", options: [], views: buttonSave)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonSave)
        buttonSave.addTarget(self,
                               action: #selector(self.actionUpdateCommentPinEditing(_:)),
                               for: .touchUpInside)
        
        labelTitle = UILabel()
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitle.text = "Edit Comment"
        labelTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.view.addSubview(labelTitle)
        self.view.addConstraintsWithFormat("H:[v0(133)]", options: [], views: labelTitle)
        self.view.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelTitle)
        NSLayoutConstraint(item: labelTitle, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        uiviewLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewLine.layer.borderWidth = screenWidth
        uiviewLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        self.view.addSubview(uiviewLine)
        
        var textViewWidth: CGFloat = 0
        if screenWidth == 414 { // 5.5
            textViewWidth = 360
        }
        else if screenWidth == 320 { // 4.0
            textViewWidth = 266
        }
        else if screenWidth == 375 { // 4.7
            textViewWidth = 321
        }
        
        textViewUpdateComment = UITextView(frame: CGRect(x: 27, y: 84, width: textViewWidth, height: 100))
        textViewUpdateComment.text = ""
        textViewUpdateComment.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textViewUpdateComment.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textViewUpdateComment.textContainerInset = UIEdgeInsets.zero
        textViewUpdateComment.indicatorStyle = UIScrollViewIndicatorStyle.white
        self.view.addSubview(textViewUpdateComment)
        UITextView.appearance().tintColor = UIColor.faeAppRedColor()
    }
    
    func actionCancelCommentPinEditing(_ sender: UIButton) {
        print(textViewUpdateComment.text)
        textViewUpdateComment.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func actionUpdateCommentPinEditing(_ sender: UIButton) {
        if previousCommentContent == textViewUpdateComment.text {
            textViewUpdateComment.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            let updateComment = FaeMap()
            print("[updatePin] \(pinGeoLocation.latitude), \(pinGeoLocation.longitude)")
            updateComment.whereKey("geo_latitude", value: "\(pinGeoLocation.latitude)")
            updateComment.whereKey("geo_longitude", value: "\(pinGeoLocation.longitude)")
            updateComment.whereKey("content", value: textViewUpdateComment.text)
            updateComment.updateComment(pinID) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Success -> Update Comment")
                    self.delegate?.reloadCommentContent()
                    self.textViewUpdateComment.endEditing(true)
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    print("Fail -> Update Comment")
                }
            }

        }
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        textViewUpdateComment.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == textViewUpdateComment {
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if textViewUpdateComment.text.trimmingCharacters(in: spacing).isEmpty == false {
                buttonSave.isEnabled = true
                lableTextViewPlaceholder.isHidden = true
            }
            else {
                buttonSave.isEnabled = false
                lableTextViewPlaceholder.isHidden = false
            }
        }
//        let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
//        if numLines <= 8 {
//            let fixedWidth = textView.frame.size.width
//            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//            var newFrame = textView.frame
//            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//            textView.frame = newFrame
//            textView.scrollEnabled = false
//        }
//        else if numLines > 8 {
//            textView.scrollEnabled = true
//        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewUpdateComment {
            if (text == "\n")  {
                textViewUpdateComment.resignFirstResponder()
                return false
            }
        }
        return true
    }
}
