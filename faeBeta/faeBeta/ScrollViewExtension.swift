//
//  ScrollViewExtension.swift
//  faeBeta
//
//  Created by Yue on 11/6/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func scrollToTop(animated: Bool) {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: animated)
    }
    
    func scrollToBottom(animated: Bool) {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.bottom)
        setContentOffset(desiredOffset, animated: animated)
    }
    
    func scrollToRight(animated: Bool) {
        let desiredOffset = CGPoint(x: -contentInset.right, y: 0)
        setContentOffset(desiredOffset, animated: animated)
    }
    
    func scrollToLeft(animated: Bool) {
        let desiredOffset = CGPoint(x: -contentInset.left, y: 0)
        setContentOffset(desiredOffset, animated: animated)
    }
}
