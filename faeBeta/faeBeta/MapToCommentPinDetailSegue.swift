//
//  MapToCommentPinDetailSegue.swift
//  faeBeta
//
//  Created by Yue on 10/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MapToCommentPinDetailSegue: UIStoryboardSegue {
    override func perform() {
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        secondVCView.frame = CGRectMake(0.0, -320, screenWidth, screenHeight)
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        UIView.animateWithDuration(0.633, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, 320)
        }) { (Finished) -> Void in
            self.sourceViewController.presentViewController(self.destinationViewController as UIViewController,
                                                            animated: false,
                                                            completion: nil)
        }
    }
}
