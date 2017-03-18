//
//  PDInputToolbar.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController {
    
    //MARK: - keyboard input bar tapped event
    func sendMessageButtonTapped() {
        self.animationRedSlidingLine(self.buttonPinDetailViewComments)
        sendMessage(textViewInput.text)
        buttonSend.isEnabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    // MARK: - send messages
    func sendMessage(_ text : String?) {
        if let realText = text {
            commentThisPin("\(self.pinTypeEnum)", pinID: pinIDPinDetailView, text: "\(self.replyToUser)\(realText)")
        }
        self.replyToUser = ""
        self.textViewInput.text = ""
        self.textViewDidChange(textViewInput)
        endEdit()
    }
    
    // set up content of extend view (mingjie jin)
    func loadExtendView() {
        let topBorder: CALayer = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        topBorder.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1).cgColor
        toolBarExtendView = UIView(frame: CGRect(x: 0, y: screenHeight - 141, width: screenWidth, height: 50))
        toolBarExtendView.isHidden = true
        toolBarExtendView.layer.zPosition = 121
        toolBarExtendView.backgroundColor = UIColor.white
        let anonyLabel = UILabel(frame: CGRect(x: screenWidth - 115, y: 14, width: 100, height: 25))
        anonyLabel.text = "Anonymous"
        anonyLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        anonyLabel.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
        anonyLabel.textAlignment = .center
        toolBarExtendView.addSubview(anonyLabel)
        toolBarExtendView.layer.addSublayer(topBorder)
        let checkbutton = UIButton(frame: CGRect(x: screenWidth - 149, y: 14, width: 22, height: 22))
        checkbutton.adjustsImageWhenHighlighted = false
        checkbutton.setImage(UIImage(named: "uncheckBoxGray"), for: UIControlState.normal)
        checkbutton.addTarget(self, action: #selector(checkboxAction(_:)), for: UIControlEvents.touchUpInside)
        toolBarExtendView.addSubview(checkbutton)
        view.addSubview(toolBarExtendView)
    }
    
    // action func for extend button (mingjie jin)
    func extendButtonAction(_ sender: UIButton) {
        if(toolBarExtendView.isHidden) {
            sender.setImage(UIImage(named: "anonymousHighlight"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "anonymousNormal"), for: .normal)
        }
        toolBarExtendView.isHidden = !toolBarExtendView.isHidden
    }
    
    // action func for check box button (mingjie jin)
    
    func checkboxAction(_ sender: UIButton) {
        if(isAnonymous) {
            sender.setImage(UIImage(named: "uncheckBoxGray"), for: UIControlState.normal)
        } else {
            sender.setImage(UIImage(named: "checkBoxGray"), for: UIControlState.normal)
        }
        isAnonymous = !isAnonymous
        //toolBarExtendView.frame.origin.x -= 271
    }
    
    // MARK: - add or remove observers
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name:NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name:NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
    }
    
    func appWillEnterForeground(){
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        actionHideEmojiView()
        
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isKeyboardInThisView {
                self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - self.keyboardHeight
                self.uiviewAnonymous.frame.origin.y = screenHeight - 51 - self.keyboardHeight
                self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height - self.keyboardHeight
                self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - self.keyboardHeight
            }
        }, completion: {(done: Bool) in
            
        })
    }
    
    func keyboardDidShow(_ notification: Notification){
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        uiviewAnonymous.isHidden = true
        uiviewToolBar.isHidden = false
        keyboardHeight = 0
        self.uiviewAnonymous.frame.origin.y = screenHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isKeyboardInThisView {
                self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height
                self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
            }
        }, completion: nil)
    }
    
    func keyboardDidHide(_ notification: Notification){
        
    }
}
