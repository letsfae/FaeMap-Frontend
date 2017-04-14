//
//  PDCVControl.swift
//  faeBeta
//
//  Created by Yue on 12/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableCommentsForPin {
            var offset: CGFloat = 321
            if PinDetailViewController.pinTypeEnum == .comment {
                offset = 232
            }
//            print("[scrollViewDidScroll] offset: \(scrollView.contentOffset.y)")
            if self.controlBoard != nil {
                self.controlBoard.isHidden = tableCommentsForPin.contentOffset.y < offset
            }
        }
    }
}
