//
//  PDInputToolbar.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController {
    
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
