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
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let colorPlaceHolder = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    var buttonCancel: UIButton!
    var buttonSave: UIButton!
    var labelTitle: UILabel!
    var uiviewLine: UIView!
    var textViewUpdateComment: UITextView!
    var lableTextViewPlaceholder: UILabel!
    
    var commentID = ""
    var previousCommentContent = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        loadEditCommentPinItems()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textViewUpdateComment.text = previousCommentContent
        textViewUpdateComment.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadEditCommentPinItems() {
        buttonCancel = UIButton()
        buttonCancel.setImage(UIImage(named: "cancelEditCommentPin"), forState: .Normal)
        self.view.addSubview(buttonCancel)
        self.view.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonCancel)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonCancel)
        buttonCancel.addTarget(self,
                               action: #selector(EditCommentPinViewController.actionCancelCommentPinEditing(_:)),
                               forControlEvents: .TouchUpInside)
        
        buttonSave = UIButton()
        buttonSave.setImage(UIImage(named: "saveEditCommentPin"), forState: .Normal)
        self.view.addSubview(buttonSave)
        self.view.addConstraintsWithFormat("H:[v0(38)]-15-|", options: [], views: buttonSave)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonSave)
        buttonSave.addTarget(self,
                               action: #selector(EditCommentPinViewController.actionUpdateCommentPinEditing(_:)),
                               forControlEvents: .TouchUpInside)
        
        labelTitle = UILabel()
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitle.text = "Edit Comment"
        labelTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.view.addSubview(labelTitle)
        self.view.addConstraintsWithFormat("H:[v0(133)]", options: [], views: labelTitle)
        self.view.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelTitle)
        NSLayoutConstraint(item: labelTitle, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        uiviewLine = UIView(frame: CGRectMake(0, 64, screenWidth, 1))
        uiviewLine.layer.borderWidth = screenWidth
        uiviewLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
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
        
        textViewUpdateComment = UITextView(frame: CGRectMake(27, 84, textViewWidth, 100))
        textViewUpdateComment.text = ""
        textViewUpdateComment.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textViewUpdateComment.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textViewUpdateComment.textContainerInset = UIEdgeInsetsZero
        textViewUpdateComment.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.view.addSubview(textViewUpdateComment)
        UITextView.appearance().tintColor = colorFae
    }
    
    func actionCancelCommentPinEditing(sender: UIButton) {
        print(textViewUpdateComment.text)
        textViewUpdateComment.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func actionUpdateCommentPinEditing(sender: UIButton) {
        if previousCommentContent == textViewUpdateComment.text {
            textViewUpdateComment.endEditing(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            let updateComment = FaeMap()
            updateComment.whereKey("content", value: textViewUpdateComment.text)
            updateComment.updateComment(commentID) {(status: Int, message: AnyObject?) in
                if status / 100 == 2 {
                    print("Success -> Update Comment")
                    self.delegate?.reloadCommentContent()
                    self.textViewUpdateComment.endEditing(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    print("Fail -> Update Comment")
                }
            }

        }
    }
    
    func tapOutsideToDismissKeyboard(sender: UITapGestureRecognizer) {
        textViewUpdateComment.endEditing(true)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == textViewUpdateComment {
            let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            if textViewUpdateComment.text.stringByTrimmingCharactersInSet(spacing).isEmpty == false {
                buttonSave.enabled = true
                lableTextViewPlaceholder.hidden = true
            }
            else {
                buttonSave.enabled = false
                lableTextViewPlaceholder.hidden = false
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewUpdateComment {
            if (text == "\n")  {
                textViewUpdateComment.resignFirstResponder()
                return false
            }
        }
        return true
    }
}
