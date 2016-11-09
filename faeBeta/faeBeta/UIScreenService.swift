//
//  UIScreenService.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/8/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

class UIScreenService{
    private class var activityIndicator : UIActivityIndicatorView{
        struct Element
        {
            static var indicator = UIActivityIndicatorView()

        }
        Element.indicator.activityIndicatorViewStyle = .WhiteLarge
        Element.indicator.color = UIColor.faeAppRedColor()
//        Element.indicator.tintColor = UIColor.faeAppRedColor()
        Element.indicator.hidesWhenStopped = true
        Element.indicator.center = UIApplication.sharedApplication().keyWindow!.center
        return Element.indicator
    }
    
    class func showActivityIndicator()
    {
        dispatch_async(dispatch_get_main_queue()) {
            UIScreenService.activityIndicator.startAnimating()
            UIApplication.sharedApplication().keyWindow!.userInteractionEnabled = false
            UIApplication.sharedApplication().keyWindow!.addSubview(UIScreenService.activityIndicator)
        }
    }
    
    class func hideActivityIndicator()
    {
        dispatch_async(dispatch_get_main_queue()) {
            UIScreenService.activityIndicator.color = UIColor.clearColor()
            UIScreenService.activityIndicator.stopAnimating()
            UIScreenService.activityIndicator.hidden = true
            UIScreenService.activityIndicator.removeFromSuperview()

            UIApplication.sharedApplication().keyWindow!.userInteractionEnabled = true
        }
    }
}
