//
//  PDButtonActions.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import SwiftyJSON

extension PinDetailViewController {
    
    func actionGotoPin(_ sender: UIButton) {
        if PinDetailViewController.pinTypeEnum == .place {
            if sender == buttonPrevPin {
                self.delegate?.goTo(nextPin: false)
            } else {
                self.delegate?.goTo(nextPin: true)
            }
            initPlaceBasicInfo()
            manageYelpData()
        }
    }
    
    func actionDoAnony() {
        switchAnony.setOn(!switchAnony.isOn, animated: true)
    }

    // Animation of the red sliding line
    func animationRedSlidingLine(_ sender: UIButton) {
        if sender.tag == 1 {
            tableMode = .talktalk
            tableCommentsForPin.reloadData()
        } else if sender.tag == 3 {
            tableMode = .feelings
            tableCommentsForPin.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableCommentsForPin.scrollToRow(at: indexPath, at: .bottom, animated: false)
        } else if sender.tag == 5 {
            tableMode = .people
            tableCommentsForPin.reloadData()
            tableCommentsForPin.contentOffset.y = 0
        }
        endEdit()
        let tag = CGFloat(sender.tag)
        let centerAtOneSix = screenWidth / 6
        let targetCenter = CGFloat(tag * centerAtOneSix)
        UIView.animate(withDuration: 0.25, animations:({
            self.uiviewRedSlidingLine.center.x = targetCenter
            self.anotherRedSlidingLine.center.x = targetCenter
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    func endEdit() {
        textViewInput.endEditing(true)
        textViewInput.resignFirstResponder()
        boolKeyboardShowed = false
        self.emojiView.tag = 0
        if buttonPinAddComment.tag == 1 || buttonPinDetailDragToLargeSize.tag == 1 {
            UIView.animate(withDuration: 0.3) {
                self.emojiView.frame.origin.y = screenHeight
                if self.uiviewAnonymous.isHidden {
                    if self.tableMode == .talktalk {
                        self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height
                        self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                        self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                        self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                    } else {
                        self.tableCommentsForPin.frame.size.height = screenHeight - 65
                        self.draggingButtonSubview.frame.origin.y = screenHeight
                        self.uiviewToolBar.frame.origin.y = screenHeight
                        self.uiviewAnonymous.frame.origin.y = screenHeight
                    }
                    
                } else {
                    if self.tableMode == .talktalk {
                        self.tableCommentsForPin.frame.size.height = screenHeight - 65 - 51
                        self.draggingButtonSubview.frame.origin.y = screenHeight - 51
                        self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                        self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                    } else {
                        self.tableCommentsForPin.frame.size.height = screenHeight - 65
                        self.draggingButtonSubview.frame.origin.y = screenHeight
                        self.uiviewToolBar.frame.origin.y = screenHeight
                        self.uiviewAnonymous.frame.origin.y = screenHeight
                    }
                }
            }
        }
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        endEdit()
    }
    
    func actionShowHideAnony(_ sender: UIButton) {
        if sender == btnCommentOption {
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - 51 - keyboardHeight
            self.draggingButtonSubview.frame.origin.y = screenHeight - 51 - keyboardHeight
            uiviewAnonymous.isHidden = false
            uiviewToolBar.isHidden = true
        } else if sender == btnHideAnony {
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height - keyboardHeight
            self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - keyboardHeight
            uiviewAnonymous.isHidden = true
            uiviewToolBar.isHidden = false
        }
    }
    
    func actionSwitchKeyboard(_ sender: UIButton) {
        if emojiView.tag == 1 {
            textViewInput.becomeFirstResponder()
            directReplyFromUser = false
            boolKeyboardShowed = true
            actionHideEmojiView()
        } else {
            textViewInput.resignFirstResponder()
            boolKeyboardShowed = false
            actionShowEmojiView()
        }
    }
    
    fileprivate func actionShowEmojiView() {
        boolStickerShowed = true
        buttonSticker.setImage(#imageLiteral(resourceName: "stickerChosen"), for: .normal)
        self.emojiView.tag = 1
        UIView.animate(withDuration: 0.3) { 
            self.emojiView.frame.origin.y = screenHeight - 271
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height - 271
            self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - 271
            self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - 271
        }
    }
    
    func actionHideEmojiView() {
        boolStickerShowed = false
        buttonSticker.setImage(#imageLiteral(resourceName: "sticker"), for: .normal)
        self.emojiView.tag = 0
        UIView.animate(withDuration: 0.3) {
            self.emojiView.frame.origin.y = screenHeight
        }
    }
    
    // Like comment pin
    func actionLikeThisPin(_ sender: UIButton) {
        endEdit()
        
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
        }
        
        if sender.tag == 1 && self.pinIDPinDetailView != "-999" {
            buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
            if animatingHeart != nil {
                animatingHeart.image = nil
            }
            unlikeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
            print("debug animating sender.tag 1")
            print(sender.tag)
            sender.tag = 0
            return
        }
        
        if sender.tag == 0 && self.pinIDPinDetailView != "-999" {
            buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
            self.animateHeart()
            likeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
            print("debug animating sender.tag 0")
            print(sender.tag)
            sender.tag = 1
        }
    }
    
    func actionHoldingLikeButton(_ sender: UIButton) {
        endEdit()
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
        animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.animateHeart), userInfo: nil, repeats: true)
    }
    
    // Upvote comment pin
    func actionUpvoteThisComment(_ sender: UIButton) {
        if isUpVoting {
            return
        }
        
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
        
        if animatingHeart != nil {
            animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        }
        
        if self.pinIDPinDetailView != "-999" {
            likeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
        }
    }
    
    // Down vote comment pin
    func actionDownVoteThisComment(_ sender: UIButton) {
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
        if animatingHeart != nil {
            animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollowNew")
        }
        if self.pinIDPinDetailView != "-999" {
            unlikeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
        }
    }
    
    // Back to pin list window when in detail window
    func actionGoToList(_ sender: UIButton!) {
        endEdit()
        if backJustOnce == true {
            backJustOnce = false
            let openedPinListVC = OpenedPinListViewController()
            openedPinListVC.delegate = self
            openedPinListVC.modalPresentationStyle = .overCurrentContext
            buttonPrevPin.isHidden = true
            btnNextPin.isHidden = true
            pinIcon.isHidden = true
            grayBackButton.isHidden = true
            self.present(openedPinListVC, animated: false, completion: {
                if self.uiviewPlaceDetail != nil {
                    self.uiviewPlaceDetail.center.y -= screenHeight
                }
                self.subviewNavigation.center.y -= self.subviewNavigation.frame.size.height
                self.tableCommentsForPin.center.y -= screenHeight
                self.draggingButtonSubview.center.y -= screenHeight
                self.subviewTable.center.y -= screenHeight
            })
        }
    }
    
    func actionBackToMap(_ sender: UIButton) {
        endEdit()
        controlBoard.removeFromSuperview()
        self.delegate?.backToMainMap()
        if PinDetailViewController.pinTypeEnum != .place {
            UIView.animate(withDuration: 0.2) {
                self.uiviewFeelingBar.frame = CGRect(x: screenWidth/2, y: 461*screenHeightFactor, width: 0, height: 0)
                for btn in self.btnFeelingArray {
                    btn.frame = CGRect.zero
                }
                self.buttonPrevPin.frame = CGRect(x: 41*screenHeightFactor, y: 503*screenHeightFactor, width: 0, height: 0)
                self.btnNextPin.frame = CGRect(x: 373*screenHeightFactor, y: 503*screenHeightFactor, width: 0, height: 0)
            }
        }
        UIView.animate(withDuration: 0.5, animations: ({
            self.subviewNavigation.center.y -= screenHeight
            self.tableCommentsForPin.center.y -= screenHeight
            self.subviewTable.center.y -= screenHeight
            self.draggingButtonSubview.center.y -= screenHeight
            self.grayBackButton.alpha = 0
            self.pinIcon.alpha = 0
            self.buttonPrevPin.alpha = 0
            self.btnNextPin.alpha = 0
            if self.uiviewPlaceDetail != nil {
                self.uiviewPlaceDetail.center.y -= screenHeight
            }
            if PinDetailViewController.pinTypeEnum != .place {
                self.uiviewFeelingBar.alpha = 0
            }
        }), completion: { (finished) in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // When clicking reply button in pin detail window
    func actionReplyToThisPin(_ sender: UIButton) {
        if sender.tag == 1 && sender != buttonPinAddComment {
            replyToUser = ""
            lblTxtPlaceholder.text = "Write a Comment..."
            endEdit()
            buttonPinDetailDragToLargeSize.tag = 0
            buttonPinAddComment.tag = 0
            buttonPinBackToMap.tag = 1
            tableCommentsForPin.isScrollEnabled = false
            UIView.animate(withDuration: 0.5, animations: ({
                self.btnHalfPinToMap.alpha = 1.0
                self.buttonPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 292
                self.tableCommentsForPin.scrollToTop(animated: true)
                self.tableCommentsForPin.frame.size.height = 227
                self.subviewTable.frame.size.height = 255
                self.uiviewPinDetail.frame.size.height = 281
                self.textviewPinDetail.frame.size.height = 100
                self.uiviewPinDetailMainButtons.frame.origin.y = 185
                self.uiviewPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewPinDetailThreeButtons.frame.origin.y = 232
                self.uiviewToolBar.frame.origin.y = screenHeight
            }), completion: {(finished) in
                self.textviewPinDetail.isScrollEnabled = true
            })
            // deal with diff UI according to pinType
            if PinDetailViewController.pinTypeEnum == .media {
                mediaMode = .small
                zoomMedia(.small)
                UIView.animate(withDuration: 0.5, animations: ({
                    self.scrollViewMedia.frame.origin.y = 80
                }), completion: { (done: Bool) in
                    if done {
                        self.textviewPinDetail.isHidden = true
                    }
                })
            }
            return
        }
        
        
        if sender.tag == 1 && sender == buttonPinAddComment {
            self.textViewInput.becomeFirstResponder()
            self.directReplyFromUser = false
            self.boolKeyboardShowed = true
            self.replyToUser = ""
            self.lblTxtPlaceholder.text = "Write a Comment..."
            return
        }
        sender.tag = 1
        let textViewHeight: CGFloat = textviewPinDetail.contentSize.height
        if buttonPinDetailDragToLargeSize.tag == 1 && sender == buttonPinAddComment {
            self.textViewInput.becomeFirstResponder()
            self.directReplyFromUser = false
            boolKeyboardShowed = true
            self.replyToUser = ""
            self.lblTxtPlaceholder.text = "Write a Comment..."
            return
        }
        readThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
        textviewPinDetail.isScrollEnabled = false
        tableCommentsForPin.isScrollEnabled = true
//        tableCommentsForPin.contentSize.height = self.uiviewPinDetail.frame.size.height + screenHeight - 65 - self.uiviewToolBar.frame.size.height
        if PinDetailViewController.pinTypeEnum == .media {
            mediaMode = .large
            zoomMedia(.large)
            textviewPinDetail.isHidden = false
            UIView.animate(withDuration: 0.5, animations: ({
                self.uiviewPinDetail.frame.size.height += 65
                self.textviewPinDetail.frame.size.height += 65
                self.uiviewPinDetailThreeButtons.center.y += 65
                self.uiviewPinDetailGrayBlock.center.y += 65
                self.uiviewPinDetailMainButtons.center.y += 65
                if self.textviewPinDetail.text != "" {
                    self.uiviewPinDetail.frame.size.height += textViewHeight
                    self.textviewPinDetail.frame.size.height += textViewHeight
                    self.uiviewPinDetailThreeButtons.center.y += textViewHeight
                    self.uiviewPinDetailGrayBlock.center.y += textViewHeight
                    self.uiviewPinDetailMainButtons.center.y += textViewHeight
                    self.scrollViewMedia.frame.origin.y += textViewHeight
                }
            }), completion: nil)
            self.scrollViewMedia.scrollToLeft(animated: true)
        }
        else if PinDetailViewController.pinTypeEnum == .comment {
            if textViewHeight > 100.0 {
                let diffHeight: CGFloat = textViewHeight - 100
                UIView.animate(withDuration: 0.5, animations: ({
                    self.uiviewPinDetail.frame.size.height += diffHeight
                    self.textviewPinDetail.frame.size.height += diffHeight
                    self.uiviewPinDetailThreeButtons.center.y += diffHeight
                    self.uiviewPinDetailGrayBlock.center.y += diffHeight
                    self.uiviewPinDetailMainButtons.center.y += diffHeight
                }), completion: {(finished) in
                    
                })
            }
        }
        UIView.animate(withDuration: 0.5, animations: ({
            self.btnHalfPinToMap.alpha = 0.0
            self.buttonPinBackToMap.alpha = 1.0
            var toolbarHeight = self.uiviewToolBar.frame.size.height
            if PinDetailViewController.pinTypeEnum == .chat_room {
                toolbarHeight = 0
            }
            self.draggingButtonSubview.frame.origin.y = screenHeight - toolbarHeight
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - toolbarHeight
            self.subviewTable.frame.size.height = screenHeight - 65 - toolbarHeight
            self.uiviewToolBar.frame.origin.y = screenHeight - toolbarHeight
        }), completion: { (done: Bool) in
            if done {
                if PinDetailViewController.pinTypeEnum != .chat_room {
                    self.tableCommentsForPin.reloadData()
                    if sender == self.buttonPinAddComment {
                        self.textViewInput.becomeFirstResponder()
                        self.directReplyFromUser = false
                        self.boolKeyboardShowed = true
                    }
                }
            }
        })
    }
}
