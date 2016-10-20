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
        
        secondVCView.frame = CGRectMake(0.0, -screenHeight, screenWidth, screenHeight)
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, screenHeight)
            
        }) { (Finished) -> Void in
            self.sourceViewController.presentViewController(self.destinationViewController as UIViewController,
                                                            animated: false,
                                                            completion: nil)
        }
    }
}
