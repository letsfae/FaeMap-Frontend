//
//  PinMenuActions.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinMenuViewController {
    func actionCreateCommentPin(_ sender: UIButton) {
        let createCommentPinVC = CreateCommentPinViewController()
        createCommentPinVC.modalPresentationStyle = .overCurrentContext
        createCommentPinVC.delegate = self
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 0.0
        }), completion: { (done: Bool) in
            
            self.present(createCommentPinVC, animated: false, completion: nil)
        })
    }
    
    func actionCreateMediaPin(_ sender: UIButton) {
        let createMediaPinVC = CreateMomentPinViewController()
        createMediaPinVC.modalPresentationStyle = .overCurrentContext
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 0.0
        }), completion: { (done: Bool) in
            createMediaPinVC.delegate = self
            self.present(createMediaPinVC, animated: false, completion: nil)
        })
    }
    
    func actionCreateChatPin(_ sender: UIButton) {
        let createChatPinVC = CreateChatPinViewController()
        createChatPinVC.modalPresentationStyle = .overCurrentContext
        createChatPinVC.delegate = self
        createChatPinVC.modalTransitionStyle = .crossDissolve
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 0.0
        }), completion: { (done: Bool) in
            self.present(createChatPinVC, animated: true, completion: nil)
        })
    }
    
    func actionCloseSubmitPins(_ sender: UIButton!) {
        self.dismiss(animated: false, completion: {
            self.delegate?.whenDismissPinMenu()
        })
    }
}
