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
            print("[scrollViewDidScroll] offset: \(scrollView.contentOffset.y)")
//            let padding = scrollView.contentOffset.y
//            tableCommentsForPin.setContentOffset(CGPoint(x: 0, y: padding), animated: false)
            if self.controlBoard != nil {
                let offset: CGFloat = uiviewPinDetail.frame.size.height - 42
                self.controlBoard.isHidden = tableCommentsForPin.contentOffset.y < offset
            }
        }
    }
}
