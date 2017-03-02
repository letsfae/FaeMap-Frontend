//
//  PDInputToolbar.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController {
    
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
        
        buttonKeyBoard.isHidden = true
        buttonSticker.isHidden = false
        
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isKeyboardInThisView {
                self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - keyboardHeight
            }
        }, completion: {(done: Bool) in
            
        })
    }
    
    func keyboardDidShow(_ notification: Notification){
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            if self.isKeyboardInThisView {
                self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height
                self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
            }
        }, completion: nil)
    }
    
    func keyboardDidHide(_ notification: Notification){
        
    }
}
