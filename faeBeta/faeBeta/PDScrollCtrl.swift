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
//            print("[scrollViewDidScroll] offset: \(scrollView.contentOffset.y)")
//            if self.uiviewCtrlBoard != nil {
//                let offset: CGFloat = uiviewTblHeader.frame.size.height - 42
//                self.uiviewCtrlBoard.isHidden = tblMain.contentOffset.y < offset
//            }
        }
    }
}
