//
//  WelcomePageControl.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/17.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class WelcomePageControl: UIView {
    
    // MARK: - Properties
    private let circleRadius: CGFloat = 10 // the radius for the small circle in page control
    private var circleArray: NSMutableArray! // an array to store all the hollow circle views
    private var indicatorCircle: UIView! // the solid circle
    var numberOfPages: Int = 0 {
        willSet {
            initWithPageNumber(newValue)
        }
    }
    var currentPage: Int = 0 {
        willSet {
            indicatorCircle.frame = CGRect(x: CGFloat(newValue) * 20, y: 0, width: circleRadius, height: circleRadius)
        }
    }
    
    // MARK: - Implements
    private func initWithPageNumber(_ pageNumber: Int) {
        // clean up the subviews first
        for sub in self.subviews {
            sub.removeFromSuperview()
        }
        
        circleArray = []
        
        // add & set the solid circle
        indicatorCircle = UIView(frame: CGRect(x: 0, y: 0, width: circleRadius, height: circleRadius))
        insertSubview(indicatorCircle, at: 0)
        indicatorCircle.layer.cornerRadius = circleRadius / 2
        indicatorCircle.layer.backgroundColor = UIColor._2499090().cgColor
        
        // add & set the hollow circles
        for i in 0..<pageNumber {
            let uiviewCircle = UIView(frame: CGRect(x: circleRadius * 2 * CGFloat(i), y: 0, width: circleRadius, height: circleRadius))
            insertSubview(uiviewCircle, at: 0)
            uiviewCircle.layer.cornerRadius = circleRadius / 2
            uiviewCircle.layer.borderColor = UIColor._2499090().cgColor
            uiviewCircle.layer.borderWidth = 1
            circleArray.add(uiviewCircle)
        }
    }
    
    // percent can be -1 ~ 1, 1 means one page width
    func setscrollPercent(_ percent: CGFloat) {
        var xPos = (CGFloat(currentPage) + percent) * circleRadius * 2
        // range limit
        xPos = max(xPos, 0)
        xPos = min(xPos, CGFloat(numberOfPages * 2 - 2) * circleRadius)
        indicatorCircle.transform = CGAffineTransform(translationX: xPos, y: 0)
    }
}
