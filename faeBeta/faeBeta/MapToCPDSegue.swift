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
        let firstVCView = self.source.view as UIView!
        let secondVCView = self.destination.view as UIView!
        
        let firstController = self.source as! FaeMapViewController
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        secondVCView?.frame = CGRect(x: 0.0, y: -320, width: screenWidth, height: screenHeight)
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
        
        UIView.animate(withDuration: 0.633, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
            secondVCView?.frame = (secondVCView?.frame.offsetBy(dx: 0.0, dy: 320))!
        }) { (Finished) -> Void in
            self.source.present(self.destination as UIViewController,
                                                            animated: false,
                                                            completion: nil)
            firstController.canOpenAnotherPin = true
        }
    }
}
