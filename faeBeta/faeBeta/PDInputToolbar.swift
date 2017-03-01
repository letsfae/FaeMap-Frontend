//
//  PDInputToolbar.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController {
    
    func setupInputToolbar()
    {
        func loadInputBarComponent() {
            
            //        let camera = Camera(delegate_: self)
            let contentView = self.inputToolbar.contentView
            contentView?.backgroundColor = UIColor.white
            let contentOffset = (screenWidth - 42 - 29 * 5) / 4 + 29
            buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
            buttonKeyBoard.addTarget(self, action: #selector(self.showKeyboard(_:)), for: .touchUpInside)
            contentView?.addSubview(buttonKeyBoard)
            
            buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSticker.setImage(UIImage(named: "sticker"), for: .normal)
            buttonSticker.setImage(UIImage(named: "sticker"), for: .highlighted)
            buttonSticker.addTarget(self, action: #selector(self.showStikcer), for: .touchUpInside)
            contentView?.addSubview(buttonSticker)
            
            buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .normal)
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), for: .highlighted)
            contentView?.addSubview(buttonImagePicker)
            
            buttonImagePicker.addTarget(self, action: #selector(self.showLibrary), for: .touchUpInside)
            
            let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonCamera.setImage(UIImage(named: "camera"), for: .normal)
            buttonCamera.setImage(UIImage(named: "camera"), for: .highlighted)
            contentView?.addSubview(buttonCamera)
            buttonCamera.addTarget(self, action: #selector(self.showCamera), for: .touchUpInside)
            
            buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .highlighted)
            contentView?.addSubview(buttonSend)
            buttonSend.isEnabled = false
            buttonSend.addTarget(self, action: #selector(self.sendMessageButtonTapped), for: .touchUpInside)
            
            buttonSet.append(buttonKeyBoard)
            buttonSet.append(buttonSticker)
            buttonSet.append(buttonImagePicker)
            buttonSet.append(buttonCamera)
            buttonSet.append(buttonSend)
            
            for button in buttonSet{
                button.autoresizingMask = [.flexibleTopMargin]
            }
        }
        inputToolbar = JSQMessagesInputToolbarCustom(frame: CGRect(x: 0, y: screenHeight-90, width: screenWidth, height: 90))
        inputToolbar.contentView.textView.delegate = self
        inputToolbar.contentView.textView.tintColor = UIColor.faeAppRedColor()
        inputToolbar.contentView.textView.font = UIFont(name: "AvenirNext-Regular", size: 18)
        inputToolbar.contentView.textView.delaysContentTouches = false
        
        
        //should button to open anonymous extend view (mingjie jin)
        inputToolbar.contentView.heartButton.setImage(UIImage(named: "anonymousNormal"), for: UIControlState.normal)
        inputToolbar.contentView.heartButton.setImage(UIImage(named: "anonymousHighlight"), for: UIControlState.highlighted)
        inputToolbar.contentView.heartButton.addTarget(self, action:#selector(extendButtonAction(_:)), for: UIControlEvents.touchUpInside)
        inputToolbar.contentView.heartButtonHidden = false
        
        
        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 7, y: 3, width: 200, height: 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lableTextViewPlaceholder.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        lableTextViewPlaceholder.text = "Write a Comment..."
        inputToolbar.contentView.textView.addSubview(lableTextViewPlaceholder)
        
        inputToolbar.maximumHeight = 90
        subviewInputToolBar = UIView(frame: CGRect(x: 0, y: screenHeight-90, width: screenWidth, height: 90))
        subviewInputToolBar.backgroundColor = UIColor.white
        self.view.addSubview(subviewInputToolBar)
        subviewInputToolBar.layer.zPosition = 120
        self.view.addSubview(inputToolbar)
        inputToolbar.layer.zPosition = 121
        loadInputBarComponent()
        inputToolbar.isHidden = true
        subviewInputToolBar.isHidden = true
        
    }
    
    func setupToolbarContentView() {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0,y: screenHeight,width: screenWidth, height: 271))
        toolbarContentView.delegate = self
        toolbarContentView.cleanUpSelectedPhotos()
        toolbarContentView.setup(1)
        toolbarContentView.maxPhotos = 1
        UIApplication.shared.keyWindow?.addSubview(toolbarContentView)
    }
    
    // MARK: - add or remove observers
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name:NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name:NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        
        if (self.isObservingInputTextView) {
            return;
        }
        let scrollView = self.inputToolbar.contentView.textView as UIScrollView
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        
        self.isObservingInputTextView = true
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        if (!self.isObservingInputTextView) {
            return;
        }
        
        self.inputToolbar.contentView.textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        self.isObservingInputTextView = false
    }
    
    //MARK: - adjust input toolbar textView size
    
    func inputToolbarHasReachedMaximumHeight() -> Bool
    {
        return self.inputToolbar.frame.minY <= inputTextViewMaximumHeight
    }
    
    func adjustInputToolbarForComposerTextViewContentSizeChange(_ dy:CGFloat)
    {
        var dy = dy
        let contentSizeIsIncreasing = dy > 0
        if self.inputToolbarHasReachedMaximumHeight() {
            let contentOffsetIsPositive = self.inputToolbar.contentView.textView.contentOffset.y > 0
            if contentSizeIsIncreasing || contentOffsetIsPositive {
                self.scrollComposerTextViewToBottom(true)
                return
            }
        }
        
        let toolbarOriginY = self.inputToolbar.frame.minY
        let newToolbarOriginY = toolbarOriginY - dy
        
        
        //  attempted to increase origin.Y above topLayoutGuide
        if newToolbarOriginY <= self.inputTextViewMaximumHeight {
            dy = toolbarOriginY - self.inputTextViewMaximumHeight
            self.scrollComposerTextViewToBottom(true)
        }
        
        self.adjustInputToolbarHeightConstraint(byDelta:dy)
        //        self.updateKeyboardTriggerPoint()
        
        if (dy < 0) {
            self.scrollComposerTextViewToBottom(false)
        }
        
    }
    
    func adjustInputToolbarHeightConstraint(byDelta delta:CGFloat)
    {
        let dy = delta
        let proposedHeight = self.inputToolbar.frame.height + dy
        var finalHeight = max(proposedHeight, self.inputToolbar.preferredDefaultHeight)
        if(self.inputToolbar.maximumHeight != UInt(NSNotFound)){
            finalHeight = min(finalHeight, CGFloat(self.inputToolbar.maximumHeight))
        }
        if self.toolbarHeightConstraint.constant != finalHeight {
            self.toolbarHeightConstraint.constant = finalHeight;
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollComposerTextViewToBottom(_ animated:Bool)
    {
        let textView = self.inputToolbar.contentView.textView
        let contentOffsetToShowLastLine = CGPoint(x: 0, y: (textView?.contentSize.height)! - (textView?.bounds.height)!)
        if (!animated) {
            textView?.contentOffset = contentOffsetToShowLastLine;
            return;
        }
        UIView.animate(withDuration: 0.01, delay: 0.01, options: .curveLinear, animations: {
            textView?.contentOffset = contentOffsetToShowLastLine;
            }, completion: nil)
    }
    
    //    func updateKeyboardTriggerPoint()
    //    {
    //        self.keyboardController.keyboardTriggerPoint = CGPointMake(0, CGRectGetHeight(self.inputToolbar.bounds));
    //    }
}
