//
//  CreatePinBaseViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

@objc protocol CreatePinBaseDelegate {
    func backFromCMP(back: Bool)
    func closePinMenuCMP(close: Bool)
    @objc optional func sendChatPinGeoInfo(chatID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)

}


class CreatePinBaseViewController: UIViewController, UITextFieldDelegate, CreatePinInputToolbarDelegate, CreatePinTextViewDelegate, SendStickerDelegate {
    //MARK: - properties
    weak var delegate : CreatePinBaseDelegate!
    var submitButton: UIButton!
    var titleImageView: UIImageView!
    var titleLabel: UILabel!
    
    var anonymousButton: UIButton!
    private var anonymousBoxImageView: UIImageView!
    var isAnonymous: Bool = false
    
    //input toolbar
    var inputToolbar: CreatePinInputToolbar!
    var buttonOpenFaceGesPanel: UIButton!
    var buttonFinishEdit: UIButton!
    var labelCountChars: UILabel!
    
    //pin location
    var selectedLatitude: String!
    var selectedLongitude: String!
    var currentLocation: CLLocation! = CLLocation(latitude: 37 , longitude: 114)
    
    //emoji
    var isShowingEmoji: Bool = false
    var emojiView: StickerPickView!
    
    var previousFirstResponder: AnyObject? = nil
    
    //MARK: - life cycles
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupBaseUI()
        addObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadKeyboardToolBar()
        loadEmojiView()
    }
    
    //MARK: - setup
    private func setupBaseUI()
    {
        func createAnonymousButton()
        {
            anonymousButton = UIButton()
            self.view.addSubview(anonymousButton)
            self.view.addConstraintsWithFormat("H:[v0(135)]-15-|", options: [], views: anonymousButton)
            self.view.addConstraintsWithFormat("V:[v0(25)]-77-|", options: [], views: anonymousButton)
            anonymousButton.addTarget(self, action: #selector(self.anonymousButtonTapped(_:)), for: .touchUpInside)
            let anonymousLabel = UILabel(frame: CGRect(x:35,y:0, width:100, height:25))
            anonymousLabel.attributedText = NSAttributedString(string:"Anonymous", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!])
            anonymousButton.addSubview(anonymousLabel)
            
            anonymousBoxImageView = UIImageView(frame: CGRect(x: 0, y: 1, width: 22, height: 22))
            anonymousBoxImageView.image = #imageLiteral(resourceName: "anonymousBox_unchecked")
            anonymousButton.addSubview(anonymousBoxImageView)
        }
        
        //back button
        let buttonBackToPinSelection = UIButton()
        buttonBackToPinSelection.setImage(UIImage(named: "backToPinMenu"), for: UIControlState())
        self.view.addSubview(buttonBackToPinSelection)
        self.view.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: buttonBackToPinSelection)
        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonBackToPinSelection)
        buttonBackToPinSelection.addTarget(self, action: #selector(self.actionBackToPinSelections(_:)), for: UIControlEvents.touchUpInside)
        
        //close button
        let buttonCloseCreateComment = UIButton()
        buttonCloseCreateComment.setImage(UIImage(named: "closePinCreation"), for: UIControlState())
        self.view.addSubview(buttonCloseCreateComment)
        self.view.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: buttonCloseCreateComment)
        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonCloseCreateComment)
        buttonCloseCreateComment.addTarget(self, action: #selector(self.actionCloseSubmitPins(_:)), for: .touchUpInside)
        
        //bottom button
        submitButton = UIButton()
        submitButton.setTitle("Submit!", for: UIControlState())
        submitButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
        submitButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        submitButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        submitButton.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 0.65)
        self.view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(self.submitButtonTapped(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: submitButton)
        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: submitButton)
        
        
        titleImageView = UIImageView(frame: CGRect(x: 166, y: 36, width: 84, height: 91))
        self.view.addSubview(titleImageView)
        
        titleLabel = UILabel(frame: CGRect(x: 109, y: 146, width: 196, height: 27))
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        self.view.addSubview(titleLabel)
        self.view.addConstraintsWithFormat("V:|-36-[v0(91)]-19-[v1(27)]", options: [], views: titleImageView, titleLabel)
        NSLayoutConstraint(item: titleImageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        createAnonymousButton()
    }
    
    func setSubmitButton(withTitle title: String, backgroundColor color: UIColor, isEnabled enabled: Bool)
    {
        submitButton.setTitle(title, for: UIControlState())
        submitButton.backgroundColor = color.withAlphaComponent(enabled ? 1 : 0.65)
        submitButton.isEnabled = enabled
    }
    
    private func loadKeyboardToolBar() {
        inputToolbar = CreatePinInputToolbar()
        inputToolbar.delegate = self
        self.view.addSubview(inputToolbar)
        
        inputToolbar.alpha = 0
        self.view.layoutIfNeeded()
    }
    
    private func loadEmojiView(){
        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
        emojiView.sendStickerDelegate = self
        self.view.addSubview(emojiView)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
//        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
//        tapToDismissKeyboard.cancelsTouchesInView = false
//        self.view.addGestureRecognizer(tapToDismissKeyboard)
    }
    
    //MARK: - button actions
    @objc private func actionBackToPinSelections(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.view.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.backFromCMP(back: true)
            }
        })
    }
    
    @objc private func actionCloseSubmitPins(_ sender: UIButton)
    {
        self.dismiss(animated: false, completion: {
            self.delegate?.closePinMenuCMP(close: true)
        })
    }
    
    @objc private func anonymousButtonTapped(_ sender: UIButton)
    {
        isAnonymous = !isAnonymous
        if isAnonymous {
            anonymousBoxImageView.image = #imageLiteral(resourceName: "anonymousBox_checked")
        }else{
            anonymousBoxImageView.image = #imageLiteral(resourceName: "anonymousBox_unchecked")
        }
    }

    func submitButtonTapped(_ sender: UIButton)
    {
        
    }
    //MARK: - CreatePinInputToolbarDelegate
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
    
    //MARK: - CreatePinTextViewDelegate
    func textView(_ textView:CreatePinTextView, numberOfCharactersEntered num: Int)
    {
        if(inputToolbar != nil){
            inputToolbar.numberOfCharactersEntered = max(0,num)
        }
        self.previousFirstResponder = textView
    }
    
    //MARK: - keyboard show/hide
    
    func keyboardWillShow(_ notification:Notification)
    {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        inputToolbar.alpha = 1
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.inputToolbar.frame.origin.y = screenHeight - keyboardHeight - 100
        }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        if(!isShowingEmoji){
            UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
                Void in
                self.inputToolbar.frame.origin.y = screenHeight - 100
                self.inputToolbar.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }
    
    //MARK: - textfield delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.previousFirstResponder = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - sendSticker Delegate
    
    func sendStickerWithImageName(_ name : String)
    {
        // do nothing here, won't send sticker
    }
    func appendEmojiWithImageName(_ name: String)
    {
        if let previousFirstResponder = previousFirstResponder
        {
            if previousFirstResponder is CreatePinTextView{
                let textView = previousFirstResponder as! CreatePinTextView
                textView.text = textView.text as String + "[\(name)]"
                textView.textViewDidChange(textView)
            }else if previousFirstResponder is UITextField{
                let textField = previousFirstResponder as! UITextField
                textField.text = textField.text! as String + "[\(name)]"
            }
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
            if previousFirstResponder is CreatePinTextView{
                let textView = previousFirstResponder as! CreatePinTextView
                textView.text = finalString
                textView.textViewDidChange(textView)
            }else if previousFirstResponder is UITextField{
                let textField = previousFirstResponder as! UITextField
                textField.text = finalString
            }
        }
    }
    //MARK: - helper
    func showEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = screenHeight - 271 - 100
                self.emojiView.frame.origin.y = screenHeight - 271
            }, completion: { (Completed) in
                self.inputToolbar.switchToEmojiMode()
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 271 - 100
            self.emojiView.frame.origin.y = screenHeight - 271
            self.inputToolbar.switchToEmojiMode()
        }
    }
    
    func hideEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = screenHeight - 100
                self.inputToolbar.alpha = 0
                self.emojiView.frame.origin.y = screenHeight
            }, completion: { (Completed) in
                self.inputToolbar.switchToKeyboardMode()
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 100
            self.inputToolbar.alpha = 0
            self.emojiView.frame.origin.y = screenHeight
            self.inputToolbar.switchToKeyboardMode()
        }
    }
}
