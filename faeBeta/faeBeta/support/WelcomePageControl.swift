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
    
    fileprivate var _numberOfPages = 0
    var numberOfPages: Int // the total numebr of page
    {
        get{
            return _numberOfPages
        }
        set{
            initWithPageNumber(newValue)
        }
    }
    
    fileprivate var _currentPage = 0
    var currentPage: Int // current presenting page
    {
        get{
            return _currentPage
        }
        set{
            _currentPage = newValue
            indicatorCircle.frame = CGRect(x: CGFloat(newValue) * 20,y: 0,width: circleRadius,height: circleRadius)
        }
    }
    
    fileprivate var circleArray: NSMutableArray! // an array to store all the hollow circle views
    var indicatorCircle : UIView! // the solid circle
    
    // MARK: - Implements
    fileprivate func initWithPageNumber(_ pageNumber:Int)
    {
        // clean up the subviews first
        for sub in self.subviews{
            sub.removeFromSuperview()
        }
        
        circleArray = []
        _numberOfPages = pageNumber
        
        // add & set the solid circle
        indicatorCircle = UIView(frame: CGRect(x: 0,y: 0,width: circleRadius,height: circleRadius))
        self.insertSubview(indicatorCircle, at: 0)
        indicatorCircle.layer.cornerRadius = circleRadius / 2
        indicatorCircle.layer.backgroundColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1).cgColor
        
        // add & set the hollow circles
        for i in 0..<pageNumber {
            let circle = UIView(frame: CGRect(x: circleRadius * 2 * CGFloat(i),y: 0,width: circleRadius,height: circleRadius))
            self.insertSubview(circle, at: 0)
            circle.layer.cornerRadius = circleRadius / 2
            circle.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1).cgColor
            circle.layer.borderWidth = 1
            circleArray.add(circle)
        }
    }
    
    // percent can be -1 ~ 1, 1 means one page width
    func setscrollPercent(_ percent: CGFloat)
    {
        var xPos = (CGFloat(currentPage) + percent) * circleRadius * 2
        // range limit
        xPos = max(xPos, 0)
        xPos = min(xPos, CGFloat(numberOfPages * 2 - 2) * circleRadius)
        indicatorCircle.transform = CGAffineTransform(translationX: xPos, y: 0)
    }
    
}
