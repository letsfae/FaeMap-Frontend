//
//  ReportCommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/31/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class ReportCommentPinViewController: UIViewController, UITextViewDelegate {

    /*  Report type
     *  0 == report pin
     *  1 == feedback
     *  2 == tag
     */
    var reportType: Int = 0
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let colorPlaceHolder = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
    
    var buttonBackToCommentDetail: UIButton!
    var imageDescription: UIImageView!
    var textViewReportContent: UITextView!
    var buttonSendReport: UIButton!
    var lableTextViewPlaceholder: UILabel!
    var preStatusBarStyle = UIStatusBarStyle.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
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
        textViewReportContent.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = preStatusBarStyle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadBasicItems() {
        buttonBackToCommentDetail = UIButton()
        buttonBackToCommentDetail.setImage(UIImage(named: "reportCommentBackToMap"), for: UIControlState())
        self.view.addSubview(buttonBackToCommentDetail)
        self.view.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: buttonBackToCommentDetail)
        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonBackToCommentDetail)
        buttonBackToCommentDetail.addTarget(self,
                               action: #selector(ReportCommentPinViewController.actionBackToCommentPinDetail(_:)),
                               for: .touchUpInside)
        
        imageDescription = UIImageView(frame: CGRect(x: 0, y: 72, width: 361*screenWidthFactor, height: 54*screenHeightFactor))
        imageDescription.center.x = screenWidth/2
        imageDescription.contentMode = .scaleAspectFit
        self.view.addSubview(imageDescription)
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(ReportCommentPinViewController.tapOutsideToDismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapToDismissKeyboard)
        
        let font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        buttonSendReport = UIButton(frame: CGRect(x: 0, y: screenHeight - 176 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        buttonSendReport.center.x = screenWidth / 2
        buttonSendReport.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font! ]), for: UIControlState())
        buttonSendReport.layer.cornerRadius = 25 * screenHeightFactor
        buttonSendReport.backgroundColor = UIColor._2499090()
        buttonSendReport.addTarget(self, action: #selector(ReportCommentPinViewController.actionSendReport(_:)), for: .touchUpInside)
        self.view.insertSubview(buttonSendReport, at: 0)
        self.view.bringSubview(toFront: buttonSendReport)
        
        textViewReportContent = UITextView()
        textViewReportContent.font = UIFont(name: "AvenirNext-Regular", size: 20)
        textViewReportContent.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textViewReportContent.backgroundColor = UIColor.clear
        textViewReportContent.tintColor = UIColor._2499090()
        textViewReportContent.delegate = self
        textViewReportContent.isScrollEnabled = false
        self.view.addSubview(textViewReportContent)
        self.view.addConstraintsWithFormat("H:[v0(294)]", options: [], views: textViewReportContent)
        self.view.addConstraintsWithFormat("V:|-157-[v0(44)]", options: [], views: textViewReportContent)
        NSLayoutConstraint(item: textViewReportContent, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 5, y: 8, width: 294, height: 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lableTextViewPlaceholder.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        if reportType == 0 {
            lableTextViewPlaceholder.text = "Describe to us the case..."
            imageDescription.image = UIImage(named: "reportViewDescription")
        }
        else if reportType == 1 {
            lableTextViewPlaceholder.text = "Your Feedback..."
            imageDescription.image = UIImage(named: "reportYourFeedback")
        }
        else if reportType == 2 {
            lableTextViewPlaceholder.text = "New Tag(s)..."
            imageDescription.image = UIImage(named: "reportNewTags")
        }
        
        textViewReportContent.addSubview(lableTextViewPlaceholder)
    }
    
    func actionBackToCommentPinDetail(_ sender: UIButton) {
        textViewReportContent.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func actionSendReport(_ sender: UIButton) {
        textViewReportContent.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleTap() {
        self.view.endEditing(true)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.buttonSendReport.frame.origin.y += (self.screenHeight - keyboardFrame.height) - self.buttonSendReport.frame.origin.y - 50 * screenHeightFactor - 14
        })
    }
    
    func keyboardWillHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.buttonSendReport.frame.origin.y = self.screenHeight - 30 - 50 * screenHeightFactor
        })
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        textViewReportContent.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == textViewReportContent {
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if textViewReportContent.text.trimmingCharacters(in: spacing).isEmpty == false {
                buttonSendReport.isEnabled = true
                lableTextViewPlaceholder.isHidden = true
                buttonSendReport.backgroundColor = UIColor._2499090()
            }
            else {
                buttonSendReport.isEnabled = false
                lableTextViewPlaceholder.isHidden = false
                buttonSendReport.backgroundColor = UIColor.faeAppDisabledRedColor()
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
        }
        else if numLines > 8 {
            textView.isScrollEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewReportContent {
            if (text == "\n")  {
                textViewReportContent.resignFirstResponder()
                return false
            }
        }
        return true
    }
}
