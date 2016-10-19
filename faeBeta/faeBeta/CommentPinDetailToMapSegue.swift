//
//  CommentPinDetailToMapSegue.swift
//  faeBeta
//
//  Created by Yue on 10/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CommentPinDetailToMapSegue: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let commentPinDetailVCView = self.sourceViewController.view as UIView!
        let mapVCView = self.destinationViewController.view as UIView!
        
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(mapVCView, aboveSubview: commentPinDetailVCView)
        
        
        // Animate the transition.
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            commentPinDetailVCView.frame = CGRectOffset(commentPinDetailVCView.frame, 0.0, -screenHeight)
            
        }) { (Finished) -> Void in
            
            self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
