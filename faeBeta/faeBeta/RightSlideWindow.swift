//
//  RightSlideWindow.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

//MARK: Show right slide window
extension FaeMapViewController {
    
    func loadWindBell() {
        dimBackgroundWindBell = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        dimBackgroundWindBell.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        dimBackgroundWindBell.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(dimBackgroundWindBell)
        dimBackgroundWindBell.addTarget(self, action: #selector(FaeMapViewController.animationWindBellHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(FaeMapViewController.animationWindBellHide(_:)))
        rightSwipe.direction = .Right

        uiviewWindBell = UIView(frame: CGRectMake(screenWidth, 0, 311, screenHeight))
        uiviewWindBell.backgroundColor = UIColor.whiteColor()
        uiviewWindBell.addGestureRecognizer(rightSwipe)
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewWindBell)
        
        labelWindbellTableTitle = UILabel(frame: CGRectMake(115,13+navigationBarHeight,82,26))
        labelWindbellTableTitle.text = "Windbell"
        labelWindbellTableTitle.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        uiviewWindBell.addSubview(labelWindbellTableTitle)
        
        //initial tableview
        tableviewWindbell = UITableView(frame: CGRectMake(0, 50+navigationBarHeight, 311, screenHeight))
        tableviewWindbell.delegate = self
        tableviewWindbell.dataSource = self
        tableviewWindbell.registerNib(UINib(nibName: "WindBellTableViewCell",bundle: nil), forCellReuseIdentifier: "windbelltablecell")
        tableviewWindbell.backgroundColor = UIColor.clearColor()
        //tableviewWindbell.separatorStyle = .SingleLine
        tableviewWindbell.separatorInset = UIEdgeInsetsZero
        
        tableviewWindbell.separatorColor = UIColor(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        
        uiviewWindBell.addSubview(tableviewWindbell)
    }
    
    func animationWindBellShow(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewWindBell.center.x = self.uiviewWindBell.center.x - 311
            self.dimBackgroundWindBell.alpha = 0.7
            self.dimBackgroundWindBell.layer.opacity = 0.7
        }))
    }
    
    func animationWindBellHide(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewWindBell.center.x = self.uiviewWindBell.center.x + 311
            self.dimBackgroundWindBell.alpha = 0.0
        }))
    }
    
}
