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
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 0.0
        }), completion: { (done: Bool) in
            let createCommentPinVC = CreateCommentPinViewController()
            createCommentPinVC.modalPresentationStyle = .overCurrentContext
            createCommentPinVC.currentLatitude = self.currentLatitude
            createCommentPinVC.currentLongitude = self.currentLongitude
            createCommentPinVC.delegate = self
            self.present(createCommentPinVC, animated: false, completion: nil)
        })
    }
    
    func actionCloseSubmitPins(_ sender: UIButton!) {
        self.dismiss(animated: false, completion: nil)
    }
}
