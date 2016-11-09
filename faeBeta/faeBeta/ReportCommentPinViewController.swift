//
//  ReportCommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/31/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class ReportCommentPinViewController: UIViewController, UITextViewDelegate {

    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let colorPlaceHolder = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
    
    var buttonBackToCommentDetail: UIButton!
    var imageDescription: UIImageView!
    var textViewReportContent: UITextView!
    var buttonSendReport: UIButton!
    var lableTextViewPlaceholder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        loadBasicItems()
        addObservers()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textViewReportContent.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadBasicItems() {
        buttonBackToCommentDetail = UIButton()
        buttonBackToCommentDetail.setImage(UIImage(named: "reportCommentBackToMap"), forState: .Normal)
        self.view.addSubview(buttonBackToCommentDetail)
        self.view.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: buttonBackToCommentDetail)
        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonBackToCommentDetail)
        buttonBackToCommentDetail.addTarget(self,
                               action: #selector(ReportCommentPinViewController.actionBackToCommentPinDetail(_:)),
                               forControlEvents: .TouchUpInside)
        
        imageDescription = UIImageView(frame: CGRectMake(0, 72, 279, 50))
        imageDescription.image = UIImage(named: "reportViewDescription")
        imageDescription.center.x = screenWidth/2
        self.view.addSubview(imageDescription)
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreatePinViewController.tapOutsideToDismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapToDismissKeyboard)
        
        let font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        buttonSendReport = UIButton(frame: CGRectMake(0, screenHeight - 176 * screenHeightFactor, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor))
        buttonSendReport.center.x = screenWidth / 2
        buttonSendReport.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font! ]), forState: .Normal)
        buttonSendReport.layer.cornerRadius = 25 * screenHeightFactor
        buttonSendReport.backgroundColor = UIColor.faeAppRedColor()
        buttonSendReport.addTarget(self, action: #selector(ReportCommentPinViewController.actionSendReport(_:)), forControlEvents: .TouchUpInside)
        self.view.insertSubview(buttonSendReport, atIndex: 0)
        self.view.bringSubviewToFront(buttonSendReport)
        
        textViewReportContent = UITextView()
        textViewReportContent.font = UIFont(name: "AvenirNext-Regular", size: 20)
        textViewReportContent.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textViewReportContent.backgroundColor = UIColor.clearColor()
        textViewReportContent.tintColor = UIColor.faeAppRedColor()
        textViewReportContent.delegate = self
        textViewReportContent.scrollEnabled = false
        self.view.addSubview(textViewReportContent)
        self.view.addConstraintsWithFormat("H:[v0(294)]", options: [], views: textViewReportContent)
        self.view.addConstraintsWithFormat("V:|-157-[v0(44)]", options: [], views: textViewReportContent)
        NSLayoutConstraint(item: textViewReportContent, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        lableTextViewPlaceholder = UILabel(frame: CGRectMake(5, 8, 294, 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lableTextViewPlaceholder.textColor = colorPlaceHolder
        lableTextViewPlaceholder.text = "Describe to us the case..."
        textViewReportContent.addSubview(lableTextViewPlaceholder)
    }
    
    func actionBackToCommentPinDetail(sender: UIButton) {
        textViewReportContent.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func actionSendReport(sender: UIButton) {
        textViewReportContent.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleTap() {
        self.view.endEditing(true)
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.buttonSendReport.frame.origin.y += (self.screenHeight - keyboardFrame.height) - self.buttonSendReport.frame.origin.y - 50 * screenHeightFactor - 14
        })
    }
    
    func keyboardWillHide(notification:NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.buttonSendReport.frame.origin.y = self.screenHeight - 30 - 50 * screenHeightFactor
        })
    }
    
    func tapOutsideToDismissKeyboard(sender: UITapGestureRecognizer) {
        textViewReportContent.endEditing(true)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == textViewReportContent {
            let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            if textViewReportContent.text.stringByTrimmingCharactersInSet(spacing).isEmpty == false {
                buttonSendReport.enabled = true
                lableTextViewPlaceholder.hidden = true
                buttonSendReport.backgroundColor = UIColor.faeAppRedColor()
            }
            else {
                buttonSendReport.enabled = false
                lableTextViewPlaceholder.hidden = false
                buttonSendReport.backgroundColor = UIColor.faeAppDisabledRedColor()
            }
        }
        let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
        if numLines <= 8 {
            let fixedWidth = textView.frame.size.width
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            textView.frame = newFrame
            textView.scrollEnabled = false
        }
        else if numLines > 8 {
            textView.scrollEnabled = true
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewReportContent {
            if (text == "\n")  {
                textViewReportContent.resignFirstResponder()
                return false
            }
        }
        return true
    }
}
