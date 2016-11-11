//
//  CommentPinViewController+InputToolbar.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/27/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CommentPinViewController{
    
    //MARK: - adjust input toolbar textView size
    
    func inputToolbarHasReachedMaximumHeight() -> Bool
    {
        return CGRectGetHeight(self.inputToolbar.frame) >= inputTextViewMaximumHeight // temp
    }
    
    func adjustInputToolbarForComposerTextViewContentSizeChange(dy:CGFloat)
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
        
        let toolbarOriginY = CGRectGetMinY(self.inputToolbar.frame)
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
        let proposedHeight = CGRectGetHeight(self.inputToolbar.frame) + dy
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
    
    func scrollComposerTextViewToBottom(animated:Bool)
    {
        let textView = self.inputToolbar.contentView.textView
        let contentOffsetToShowLastLine = CGPointMake(0, textView.contentSize.height - CGRectGetHeight(textView.bounds))
        if (!animated) {
            textView.contentOffset = contentOffsetToShowLastLine;
            return;
        }
        UIView.animateWithDuration(0.01, delay: 0.01, options: .CurveLinear, animations: {
            textView.contentOffset = contentOffsetToShowLastLine;
            }, completion: nil)
    }

//    func updateKeyboardTriggerPoint()
//    {
//        self.keyboardController.keyboardTriggerPoint = CGPointMake(0, CGRectGetHeight(self.inputToolbar.bounds));
//    }
}
