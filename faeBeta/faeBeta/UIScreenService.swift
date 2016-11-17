//
//  UIScreenService.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/8/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit


/// This this a public class use to add a loading indicator on the screen, while the indicator is appearing, the userInteraction is disabled
class UIScreenService{
    
    fileprivate class var activityIndicator : UIActivityIndicatorView{
        struct Element
        {
            static var indicator = UIActivityIndicatorView()

        }
        Element.indicator.activityIndicatorViewStyle = .whiteLarge
        Element.indicator.color = UIColor.faeAppRedColor()
        Element.indicator.hidesWhenStopped = true
        Element.indicator.center = UIApplication.shared.keyWindow!.center
        return Element.indicator
    }
    
    class func showActivityIndicator()
    {
        DispatchQueue.main.async {
            UIScreenService.activityIndicator.startAnimating()
            UIApplication.shared.keyWindow!.isUserInteractionEnabled = false
            UIApplication.shared.keyWindow!.addSubview(UIScreenService.activityIndicator)
        }
    }
    
    class func hideActivityIndicator()
    {
        DispatchQueue.main.async {
            UIScreenService.activityIndicator.color = UIColor.clear
            UIScreenService.activityIndicator.stopAnimating()
            UIScreenService.activityIndicator.isHidden = true
            UIScreenService.activityIndicator.removeFromSuperview()

            UIApplication.shared.keyWindow!.isUserInteractionEnabled = true
        }
    }
}
