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
            if sender == btnPrevPin {
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
    
    // Animation of the red sliding line (Talk Talk, Feelings, People)
    func animationRedSlidingLine(_ sender: UIButton) {
        if sender == btnTalkTalk {
            tableMode = .talktalk
            tblMain.reloadData()
            UIView.animate(withDuration: 0.3, animations: {
                self.uiviewMain.frame.size.height = screenHeight - self.uiviewInputToolBarSub.frame.size.height
            })
        } else if sender == btnFeelings {
            tableMode = .feelings
            tblMain.reloadData()
            uiviewMain.frame.size.height = screenHeight
        } else if sender == btnPeople {
            tableMode = .people
            tblMain.reloadData()
            tblMain.contentOffset.y = 0
            uiviewMain.frame.size.height = screenHeight
        }
        endEdit()
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewRedSlidingLine.center.x = sender.center.x
        }), completion: nil)
    }
    
    func endEdit() {
        textViewInput.endEditing(true)
        textViewInput.resignFirstResponder()
        boolKeyboardShowed = false
        self.emojiView.tag = 0
        if btnPinComment.tag == 1 || btnToFullPin.tag == 1 {
            UIView.animate(withDuration: 0.3, animations: ({
                self.emojiView.frame.origin.y = screenHeight
                if self.uiviewAnonymous.isHidden {
                    if self.tableMode == .talktalk {
                        self.uiviewMain.frame.size.height = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                        self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height
                        self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                        self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                        self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                    } else {
                        self.uiviewMain.frame.size.height = screenHeight
                        self.tblMain.frame.size.height = screenHeight - 65
                        self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight
                        self.uiviewInputToolBarSub.frame.origin.y = screenHeight
                        self.uiviewAnonymous.frame.origin.y = screenHeight
                    }
                } else {
                    if self.tableMode == .talktalk {
                        self.uiviewMain.frame.size.height = screenHeight - 51
                        self.tblMain.frame.size.height = screenHeight - 65 - 51
                        self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - 51
                        self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height
                        self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                    } else {
                        self.uiviewMain.frame.size.height = screenHeight
                        self.tblMain.frame.size.height = screenHeight - 65
                        self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight
                        self.uiviewInputToolBarSub.frame.origin.y = screenHeight
                        self.uiviewAnonymous.frame.origin.y = screenHeight
                    }
                }
            }), completion: { _ in
                if self.tableMode == .feelings {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tblMain.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.endEdit()
    }
    
    func actionShowHideAnony(_ sender: UIButton) {
        if sender == btnCommentOption {
            self.tblMain.frame.size.height = screenHeight - 65 - 51 - keyboardHeight
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - 51 - keyboardHeight
            uiviewAnonymous.isHidden = false
            uiviewInputToolBarSub.isHidden = true
        } else if sender == btnHideAnony {
            self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height - keyboardHeight
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - keyboardHeight
            uiviewAnonymous.isHidden = true
            uiviewInputToolBarSub.isHidden = false
        }
    }
    
    func actionSwitchKeyboard(_ sender: UIButton) {
        if emojiView.tag == 1 {
            textViewInput.becomeFirstResponder()
            directReplyFromUser = false
            boolKeyboardShowed = true
            self.actionHideEmojiView()
        } else {
            textViewInput.resignFirstResponder()
            boolKeyboardShowed = false
            self.actionShowEmojiView()
        }
    }
    
    func actionShowEmojiView() {
        boolStickerShowed = true
        btnShowSticker.setImage(#imageLiteral(resourceName: "stickerChosen"), for: .normal)
        self.emojiView.tag = 1
        UIView.animate(withDuration: 0.3) {
            self.emojiView.frame.origin.y = screenHeight - 271
            self.tblMain.frame.size.height = screenHeight - 65 - self.uiviewInputToolBarSub.frame.size.height - 271
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - 271
            self.uiviewInputToolBarSub.frame.origin.y = screenHeight - self.uiviewInputToolBarSub.frame.size.height - 271
        }
    }
    
    func actionHideEmojiView() {
        boolStickerShowed = false
        btnShowSticker.setImage(#imageLiteral(resourceName: "sticker"), for: .normal)
        self.emojiView.tag = 0
        UIView.animate(withDuration: 0.3) {
            self.emojiView.frame.origin.y = screenHeight
        }
    }
    
    func actionLikeThisPin(_ sender: UIButton) {
        self.endEdit()
        
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
        }
        
        if sender.tag == 1 && self.strPinId != "-999" {
            btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: UIControlState())
            if animatingHeart != nil {
                animatingHeart.image = nil
            }
            unlikeThisPin()
            print("debug animating sender.tag 1")
            print(sender.tag)
            sender.tag = 0
            return
        }
        
        if sender.tag == 0 && self.strPinId != "-999" {
            btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
            self.animateHeart()
            likeThisPin()
            print("debug animating sender.tag 0")
            print(sender.tag)
            sender.tag = 1
        }
    }
    
    func actionHoldingLikeButton(_ sender: UIButton) {
        self.endEdit()
        btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
        animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.animateHeart), userInfo: nil, repeats: true)
    }
    
    // Back to pin list window when in detail window
    func actionGoToList(_ sender: UIButton!) {
        self.endEdit()
        if backJustOnce == true {
            backJustOnce = false
            let openedPinListVC = OpenedPinListViewController()
            openedPinListVC.delegate = self
            openedPinListVC.modalPresentationStyle = .overCurrentContext
            btnPrevPin.isHidden = true
            btnNextPin.isHidden = true
            imgPinIcon.isHidden = true
            btnGrayBackToMap.isHidden = true
            self.present(openedPinListVC, animated: false, completion: {
                self.uiviewMain.frame.origin.y -= screenHeight
            })
        }
    }
    
    func actionBackToMap(_ sender: UIButton) {
        self.endEdit()
        if enterMode == .collections {
            guard let likes = lblPinLikeCount.text else { return }
            guard let comments = lblCommentCount.text else { return }
            self.boolPinLiked = btnPinLike.currentImage == #imageLiteral(resourceName: "pinDetailLikeHeartFull")
            let isLiked = self.boolPinLiked
            // Vicky 06/20/17
            var feelings = [Int]()
            for i in 0..<feelingArray.count {
                if feelingArray[i] != 0 {
                    feelings.append(i)
                }
            }
            self.colDelegate?.backToCollections(likeCount: likes, commentCount: comments, pinLikeStatus: isLiked, feelingArray: feelings)
            // Vicky 06/20/17 End
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.delegate?.backToMainMap()
        if PinDetailViewController.pinTypeEnum != .place {
            UIView.animate(withDuration: 0.2) {
                self.uiviewFeelingBar.frame = CGRect(x: screenWidth / 2, y: 451 * screenHeightFactor, width: 0, height: 0)
                for btn in self.btnFeelingArray {
                    btn.frame = CGRect.zero
                }
                self.btnPrevPin.frame = CGRect(x: 41 * screenHeightFactor, y: 503 * screenHeightFactor, width: 0, height: 0)
                self.btnNextPin.frame = CGRect(x: 373 * screenHeightFactor, y: 503 * screenHeightFactor, width: 0, height: 0)
            }
        }
        UIView.animate(withDuration: 0.5, animations: ({
            self.uiviewMain.center.y -= screenHeight
            self.btnGrayBackToMap.alpha = 0
            self.imgPinIcon.alpha = 0
            self.btnPrevPin.alpha = 0
            self.btnNextPin.alpha = 0
        }), completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // When clicking reply button in pin detail window
    func actionReplyToThisPin(_ sender: UIButton) {
        
        // Back to half pin view
        if sender.tag == 1 && sender != btnPinComment {
            self.endEdit()
            boolDetailShrinked = true
            btnPinComment.tag = 0
            btnToFullPin.tag = 0
            lblTxtPlaceholder.text = "Write a Comment..."
            strReplyTo = ""
            
            uiviewNavBar.leftBtn.tag = 1
            tblMain.setContentOffset(CGPoint.zero, animated: true)
            
            UIView.animate(withDuration: 0.5, animations: ({
                self.btnHalfPinToMap.alpha = 1.0 // nav bar left btn
                self.uiviewNavBar.leftBtn.alpha = 0.0 // nav bar left btn
                self.textviewPinDetail.frame.size.height = 100 // back to original text height
                
                self.uiviewInteractBtnSub.frame.origin.y = 185
                self.uiviewGrayMidBlock.frame.origin.y = 227
                self.uiviewTableSub.frame.size.height = 255
                self.uiviewTblHeader.frame.size.height = 239
                self.uiviewToFullDragBtnSub.frame.origin.y = 292
                self.uiviewMain.frame.size.height = 320
                self.uiviewInputToolBarSub.frame.origin.y = screenHeight
            }), completion: { _ in
                self.textviewPinDetail.isScrollEnabled = true
                self.tblMain.isScrollEnabled = false
                self.tblMain.frame.size.height = 227
            })
            // deal with diff UI according to pinType
            if PinDetailViewController.pinTypeEnum == .media {
                zoomMedia(.small)
                UIView.animate(withDuration: 0.5, animations: ({
                    self.scrollViewMedia.frame.origin.y = 80
                    self.textviewPinDetail.alpha = 0
                }), completion: nil)
            }
            return
        }
        /*
         -------------------- Below is to Full Pin View --------------------
         */
        self.boolDetailShrinked = false
        if sender.tag == 1 && sender == btnPinComment {
            self.boolKeyboardShowed = true
            self.directReplyFromUser = false
            self.lblTxtPlaceholder.text = "Write a Comment..."
            self.strReplyTo = ""
            self.textViewInput.becomeFirstResponder()
            return
        }
        sender.tag = 1
        let textViewHeight: CGFloat = textviewPinDetail.contentSize.height
        if btnToFullPin.tag == 1 && sender == btnPinComment {
            boolKeyboardShowed = true
            directReplyFromUser = false
            lblTxtPlaceholder.text = "Write a Comment..."
            strReplyTo = ""
            textViewInput.becomeFirstResponder()
            return
        }
        readThisPin()
        textviewPinDetail.isScrollEnabled = false
        tblMain.isScrollEnabled = true
        if PinDetailViewController.pinTypeEnum == .media {
            zoomMedia(.large)
            UIView.animate(withDuration: 0.5, animations: ({
                self.textviewPinDetail.alpha = 1
                self.scrollViewMedia.frame.origin.y += textViewHeight
                self.textviewPinDetail.frame.size.height = textViewHeight
                self.uiviewGrayMidBlock.center.y += 65 + textViewHeight
                self.uiviewInteractBtnSub.center.y += 65 + textViewHeight
                self.uiviewTblHeader.frame.size.height += 65 + textViewHeight
            }), completion: nil)
            self.scrollViewMedia.scrollToLeft(animated: true)
        } else if PinDetailViewController.pinTypeEnum == .comment && textViewHeight > 100.0 {
            let diffHeight: CGFloat = textViewHeight - 100
            UIView.animate(withDuration: 0.5, animations: ({
                self.uiviewTblHeader.frame.size.height += diffHeight
                self.textviewPinDetail.frame.size.height += diffHeight
                self.uiviewGrayMidBlock.center.y += diffHeight
                self.uiviewInteractBtnSub.center.y += diffHeight
            }), completion: nil)
        }
        UIView.animate(withDuration: 0.5, animations: ({
            self.btnHalfPinToMap.alpha = 0.0
            self.uiviewNavBar.leftBtn.alpha = 1.0
            let toolbarHeight = PinDetailViewController.pinTypeEnum == .chat_room ? 0 : self.uiviewInputToolBarSub.frame.size.height
            self.tblMain.frame.size.height = screenHeight - 65 - toolbarHeight
            self.uiviewInputToolBarSub.frame.origin.y = screenHeight - toolbarHeight
            self.uiviewMain.frame.size.height = screenHeight - toolbarHeight
            self.uiviewTableSub.frame.size.height = screenHeight - 65 - toolbarHeight
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - toolbarHeight
        }), completion: { _ in
            if PinDetailViewController.pinTypeEnum != .chat_room {
                self.tblMain.reloadData()
                if sender == self.btnPinComment {
                    self.textViewInput.becomeFirstResponder()
                    self.directReplyFromUser = false
                    self.boolKeyboardShowed = true
                }
            }
        })
    }
    
    func handleFeelingPanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: uiviewFeelingBar)
        
        if location.y < 0 || location.y > 52 {
            if btnSelectedFeeling != nil {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    let yAxis = 11 * screenHeightFactor
                    let width = 32 * screenHeightFactor
                    self.btnSelectedFeeling?.frame = CGRect(x: CGFloat(20 + 52 * self.previousIndex), y: yAxis, width: width, height: width)
                }, completion: nil)
            }
            return
        }
        
        let index = Int((location.x - 20) / 52)
        
        if index > 4 || index < 0 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let yAxis = 11 * screenHeightFactor
                let width = 32 * screenHeightFactor
                self.btnSelectedFeeling?.frame = CGRect(x: CGFloat(20 + 52 * self.previousIndex), y: yAxis, width: width, height: width)
            }, completion: nil)
            return
        }
        
        let button = btnFeelingArray[index]
        
        if btnSelectedFeeling != button {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let yAxis = 11 * screenHeightFactor
                let width = 32 * screenHeightFactor
                self.btnSelectedFeeling?.frame = CGRect(x: CGFloat(20 + 52 * self.previousIndex), y: yAxis, width: width, height: width)
            }, completion: nil)
        }
        
        btnSelectedFeeling = button
        previousIndex = index
        
        uiviewFeelingBar.bringSubview(toFront: button)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let yAxis = -19 * screenHeightFactor
            let width = 46 * screenHeightFactor
            button.frame = CGRect(x: CGFloat(13 + 52 * index), y: yAxis, width: width, height: width)
        }, completion: nil)
        
        if gesture.state == .ended {
            if index == intChosenFeeling {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    let yAxis = 3 * screenHeightFactor
                    let width = 46 * screenHeightFactor
                    button.frame = CGRect(x: CGFloat(13 + 52 * index), y: yAxis, width: width, height: width)
                }, completion: nil)
                return
            }
            postFeeling(button)
        }
    }
}
