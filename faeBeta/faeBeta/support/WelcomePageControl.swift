//
//  WelcomePageControl.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/17.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class WelcomePageControl: UIView {
    
    // MARK: - Interface
    var circleRadius : CGFloat = 10 // the radius for the small circle in page control
    
    private var _numberOfPages = 0
    var numberOfPages: Int // the total numebr of page
    {
        get{
            return _numberOfPages
        }
        set{
            initWithPageNumber(newValue)
        }
    }
    
    private var _currentPage = 0
    var currentPage: Int // current presenting page
    {
        get{
            return _currentPage
        }
        set{
            _currentPage = newValue
            indicatorCircle.frame = CGRectMake(CGFloat(newValue) * 20,0,circleRadius,circleRadius)
        }
    }
    
    private var circleArray: NSMutableArray! // an array to store all the hollow circle views
    var indicatorCircle : UIView! // the solid circle
    
    // MARK: - Implements
    private func initWithPageNumber(pageNumber:Int)
    {
        // clean up the subviews first
        for sub in self.subviews{
            sub.removeFromSuperview()
        }
        
        circleArray = []
        _numberOfPages = pageNumber
        
        // add & set the solid circle
        indicatorCircle = UIView(frame: CGRectMake(0,0,circleRadius,circleRadius))
        self.insertSubview(indicatorCircle, atIndex: 0)
        indicatorCircle.layer.cornerRadius = circleRadius / 2
        indicatorCircle.layer.backgroundColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1).CGColor
        
        // add & set the hollow circles
        for i in 0..<pageNumber {
            let circle = UIView(frame: CGRectMake(circleRadius * 2 * CGFloat(i),0,circleRadius,circleRadius))
            self.insertSubview(circle, atIndex: 0)
            circle.layer.cornerRadius = circleRadius / 2
            circle.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1).CGColor
            circle.layer.borderWidth = 1
            circleArray.addObject(circle)
        }
    }
    
    // percent can be -1 ~ 1, 1 means one page width
    func setscrollPercent(percent: CGFloat)
    {
        var xPos = (CGFloat(currentPage) + percent) * circleRadius * 2
        // range limit
        xPos = max(xPos, 0)
        xPos = min(xPos, CGFloat(numberOfPages * 2 - 2) * circleRadius)
        indicatorCircle.transform = CGAffineTransformMakeTranslation(xPos, 0)
    }
    
}
