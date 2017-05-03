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
        if scrollView == tblMain {
            print("[scrollViewDidScroll] offset: \(scrollView.contentOffset.y)")
//            let padding = scrollView.contentOffset.y
//            tblMain.setContentOffset(CGPoint(x: 0, y: padding), animated: false)
            if self.uiviewCtrlBoard != nil {
                let offset: CGFloat = uiviewTblHeader.frame.size.height - 42
                self.uiviewCtrlBoard.isHidden = tblMain.contentOffset.y < offset
            }
//            if scrollView.contentOffset.y > 60 {
//                tblMain.setContentOffset(CGPoint(x: 0, y: uiviewTblHeader.frame.size.height-42), animated: false)
//            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("[scrollViewDidEndDragging] offset: \(scrollView.contentOffset.y)")
    }
}
