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
            commentThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView, text: "\(self.replyToUser)\(realText)")
        }
        self.replyToUser = ""
        self.textViewInput.text = ""
        self.lblTxtPlaceholder.text = "Write a Comment..."
        self.textViewDidChange(textViewInput)
        endEdit()
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
        boolKeyboardShowed = true
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
        boolKeyboardShowed = false
    }
}
