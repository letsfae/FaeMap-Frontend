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

class EditCommentPinViewController: UIViewController, UITextViewDelegate, CreatePinInputToolbarDelegate, SendStickerDelegate {
    
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
    
    //input toolbar
    var inputToolbar: CreatePinInputToolbar!
    var buttonOpenFaceGesPanel: UIButton!
    var buttonFinishEdit: UIButton!
    var labelCountChars: UILabel!
    var editOption: UIButton!
    var lineOnToolbar: UIView!
    
    //Emoji View
    var emojiView: StickerPickView!
    var isShowingEmoji: Bool = false
    
    var previousFirstResponder: AnyObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        loadEditCommentPinItems()
        addObservers()
        loadKeyboardToolBar()
        loadEmojiView()
        
        textViewUpdateComment.text = previousCommentContent
        textViewUpdateComment.delegate = self
        textViewDidChange(textViewUpdateComment)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 2, y: 0, width: 171, height: 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lableTextViewPlaceholder.textColor = colorPlaceHolder
        lableTextViewPlaceholder.text = "Type a comment..."
        textViewUpdateComment.addSubview(lableTextViewPlaceholder)

    }
    
    private func loadKeyboardToolBar() {
        inputToolbar = CreatePinInputToolbar()
        inputToolbar.delegate = self
        inputToolbar.darkBackgroundView.backgroundColor = UIColor.white
        inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
        inputToolbar.buttonOpenFaceGesPanel.setTitle("", for: UIControlState())
        inputToolbar.buttonFinishEdit.setImage(UIImage(), for: UIControlState())
        
        //Line on the toolbar
        lineOnToolbar = UIView(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 1))
        lineOnToolbar.layer.borderWidth = screenWidth
        lineOnToolbar.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        inputToolbar.darkBackgroundView.addSubview(lineOnToolbar)
        
        inputToolbar.buttonFinishEdit.isHidden = true
        buttonFinishEdit = UIButton()
        buttonFinishEdit.setTitle("Edit Options", for: UIControlState())
        buttonFinishEdit.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        inputToolbar.addSubview(buttonFinishEdit)
        inputToolbar.addConstraintsWithFormat("H:[v0(105)]-14-|", options: [], views: buttonFinishEdit)
        inputToolbar.addConstraintsWithFormat("V:[v0(25)]-11-|", options: [], views: buttonFinishEdit)
        buttonFinishEdit.addTarget(self, action: #selector(self.moreOptions(_ :)), for: .touchUpInside)
        buttonFinishEdit.setTitleColor(UIColor(red: 155/255, green: 155/255, blue:155/255, alpha: 1), for: UIControlState())
        inputToolbar.darkBackgroundView.addSubview(buttonFinishEdit)

        inputToolbar.labelCountChars.textColor = UIColor(red: 155/255, green: 155/255, blue:155/255, alpha: 1)
        
        self.view.addSubview(inputToolbar)
        
        inputToolbar.alpha = 1
        self.view.layoutIfNeeded()
    }
    
    private func loadEmojiView(){
        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
        emojiView.sendStickerDelegate = self
        self.view.addSubview(emojiView)
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
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification)
    {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        inputToolbar.alpha = 1
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.inputToolbar.frame.origin.y = self.screenHeight - keyboardHeight - 100
        }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        if(!isShowingEmoji){
            UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
                Void in
                self.inputToolbar.frame.origin.y = self.screenHeight - 100
                self.inputToolbar.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func inputToolbarFinishButtonTapped(inputToolbar: CreatePinInputToolbar)
    {
        self.view.endEditing(true)
        if(isShowingEmoji){
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: true)
        }
    }
    
    func inputToolbarEmojiButtonTapped(inputToolbar: CreatePinInputToolbar) {
        if(!isShowingEmoji){
            isShowingEmoji = true
            self.view.endEditing(true)
            showEmojiViewAnimated(animated: true)
        }else{
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: false)
            _ = self.previousFirstResponder?.becomeFirstResponder()
        }
    }
    
    func moreOptions(_ sender: UIButton) {
        print("option")
    }
    
    func sendStickerWithImageName(_ name : String)
    {
        // do nothing here, won't send sticker
    }
    func appendEmojiWithImageName(_ name: String)
    {
        if let previousFirstResponder = previousFirstResponder
        {
            if previousFirstResponder is UITextView{
//                let textView = previousFirstResponder as! UITextView
//                textView.text = textView.text as String + "[\(name)]"
//                textView.textViewDidChange(textView)
                self.textViewUpdateComment.text = self.textViewUpdateComment.text + "[\(name)]"
            }else if previousFirstResponder is UITextField{
//                let textField = previousFirstResponder as! UITextField
//                textField.text = textField.text! as String + "[\(name)]"
            }
            self.textViewDidChange(textViewUpdateComment) //Don't forget adding this line, otherwise there will be a little bug if textfield is null while appending Emoji
        }
    }
    func deleteEmoji()
    {
        if let previousFirstResponder = previousFirstResponder
        {
            var previous = ""
            if previousFirstResponder is UITextView{
                let textView = previousFirstResponder as! UITextView
                previous = textView.text
            }else if previousFirstResponder is UITextField{
                let textField = previousFirstResponder as! UITextField
                previous = textField.text!
            }
            let finalString = previous.stringByDeletingLastEmoji()
            if previousFirstResponder is UITextView{
                let textView = previousFirstResponder as! UITextView
                textView.text = finalString
                self.textViewDidChange(textView)
            }else if previousFirstResponder is UITextField{
                let textField = previousFirstResponder as! UITextField
                textField.text = finalString
            }
        }
    }
    
    func showEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = self.screenHeight - 271 - 100
                self.emojiView.frame.origin.y = self.screenHeight - 271
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIconFilledRed"), for: UIControlState())
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 271 - 100
            self.emojiView.frame.origin.y = screenHeight - 271
            self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIconFilledRed"), for: UIControlState())
        }
        //textViewUpdateComment.becomeFirstResponder()
    }
    
    func hideEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = self.screenHeight - 100
                self.inputToolbar.alpha = 0
                self.emojiView.frame.origin.y = self.screenHeight
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 100
            self.inputToolbar.alpha = 0
            self.emojiView.frame.origin.y = screenHeight
            self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
        }
        //textViewUpdateComment.becomeFirstResponder()
    }
    
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        textViewUpdateComment.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        if textView == textViewUpdateComment {
//            let spacing = CharacterSet.whitespacesAndNewlines
//            
//            if textViewUpdateComment.text.trimmingCharacters(in: spacing).isEmpty == false {
//                buttonSave.isEnabled = true
//                lableTextViewPlaceholder.isHidden = true
//            }
//            else {
//                buttonSave.isEnabled = false
//                lableTextViewPlaceholder.isHidden = false
//            }
//        }
        
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
        if textView == textViewUpdateComment {
            let spacing = CharacterSet.whitespacesAndNewlines
            print(textViewUpdateComment.text)
            if textViewUpdateComment.text.trimmingCharacters(in: spacing).isEmpty == false {
                buttonSave.isEnabled = true
                lableTextViewPlaceholder.isHidden = true
            }else {
                buttonSave.isEnabled = false
                lableTextViewPlaceholder.isHidden = false
            }
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            var numlineOnDevice = 3
            if screenWidth == 375 {
                numlineOnDevice = 4
            }
            else if screenWidth == 414 {
                numlineOnDevice = 7
            }
            if numLines <= numlineOnDevice {
                let fixedWidth = textView.frame.size.width
                textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = textView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                textView.frame = newFrame
                textView.isScrollEnabled = false
            }
            else if numLines > numlineOnDevice {
                textView.isScrollEnabled = true
            }
            inputToolbar.numberOfCharactersEntered = max(0,textView.text.characters.count)
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputToolbar.numberOfCharactersEntered = max(0,textView.text.characters.count)
        self.previousFirstResponder = textView
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewUpdateComment {
            if (text == "\n")  {
                textViewUpdateComment.resignFirstResponder()
                return false
            }
            let countChars = textView.text.characters.count + (text.characters.count - range.length)
            return countChars <= 200
        }
        return true
    }
}
