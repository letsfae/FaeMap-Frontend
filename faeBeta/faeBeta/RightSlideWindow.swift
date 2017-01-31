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
        dimBackgroundWindBell = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dimBackgroundWindBell.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        dimBackgroundWindBell.alpha = 0.0
        UIApplication.shared.keyWindow?.addSubview(dimBackgroundWindBell)
        dimBackgroundWindBell.addTarget(self, action: #selector(FaeMapViewController.animationWindBellHide(_:)), for: UIControlEvents.touchUpInside)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(FaeMapViewController.animationWindBellHide(_:)))
        rightSwipe.direction = .right

        uiviewWindBell = UIView(frame: CGRect(x: screenWidth, y: 0, width: 311, height: screenHeight))
        uiviewWindBell.backgroundColor = UIColor.white
        uiviewWindBell.addGestureRecognizer(rightSwipe)
        UIApplication.shared.keyWindow?.addSubview(uiviewWindBell)
        
        labelWindbellTableTitle = UILabel(frame: CGRect(x: 115,y: 13+navigationBarHeight,width: 82,height: 26))
        labelWindbellTableTitle.text = "Windbell"
        labelWindbellTableTitle.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        uiviewWindBell.addSubview(labelWindbellTableTitle)
        
        //initial tableview
        tableviewWindbell = UITableView(frame: CGRect(x: 0, y: 50+navigationBarHeight, width: 311, height: screenHeight))
        tableviewWindbell.delegate = self
        tableviewWindbell.dataSource = self
        tableviewWindbell.register(UINib(nibName: "WindBellTableViewCell",bundle: nil), forCellReuseIdentifier: "windbelltablecell")
        tableviewWindbell.backgroundColor = UIColor.clear
        //tableviewWindbell.separatorStyle = .SingleLine
        tableviewWindbell.separatorInset = UIEdgeInsets.zero
        
        tableviewWindbell.separatorColor = UIColor(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        
        uiviewWindBell.addSubview(tableviewWindbell)
    }
    
    func animationWindBellShow(_ sender: UIButton!) {

    }
    
    func animationWindBellHide(_ sender: UIButton!) {
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewWindBell.center.x = self.uiviewWindBell.center.x + 311
            self.dimBackgroundWindBell.alpha = 0.0
        }))
    }
    
}
