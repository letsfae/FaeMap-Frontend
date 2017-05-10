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
        self.animationRedSlidingLine(self.btnTalkTalk)
        sendMessage(textViewInput.text)
        btnCommentSend.isEnabled = false
        btnCommentSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    // MARK: - send messages
    func sendMessage(_ text : String?) {
        if let realText = text {
            commentThisPin(text: "\(self.strReplyTo)\(realText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))")
        }
        
        self.strReplyTo = ""
        self.textViewInput.text = ""
        self.lblTxtPlaceholder.text = "Write a Comment..."
        self.textViewDidChange(textViewInput)
        endEdit()
    }
    
    // MARK: - add or remove observers
    func addObservers() {
        if PinDetailViewController.pinTypeEnum == .place {
            return
        }
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
                self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - self.keyboardHeight
                self.uiviewAnonymous.frame.origin.y = screenHeight - 51 - self.keyboardHeight
                self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height - self.keyboardHeight
                self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - self.keyboardHeight
            }
        }, completion: {(_) in
            
        })
        if !directReplyFromUser {
            tblMain.setContentOffset(CGPoint(x: 0, y: uiviewTblHeader.frame.size.height - 42), animated: false)
        }
    }
    
    func keyboardDidShow(_ notification: Notification){
        boolKeyboardShowed = true
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        uiviewAnonymous.isHidden = true
        uiviewInputToolBarSub.isHidden = false
        keyboardHeight = 0
        self.uiviewAnonymous.frame.origin.y = screenHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isKeyboardInThisView {
                self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height
                self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
            }
        }, completion: nil)
    }
    
    func keyboardDidHide(_ notification: Notification){
        boolKeyboardShowed = false
    }
}
