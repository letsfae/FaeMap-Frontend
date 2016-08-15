//
//  LeftSlideWindow.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

//MARK: show left slide window
extension FaeMapViewController {
    
    func loadMore() {
        
        dimBackgroundMoreButton = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        dimBackgroundMoreButton.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        dimBackgroundMoreButton.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(dimBackgroundMoreButton)
        dimBackgroundMoreButton.addTarget(self, action: #selector(FaeMapViewController.animationMoreHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        uiviewMoreButton = UIView(frame: CGRectMake(-tableViewWeight, 0, tableViewWeight, screenHeight))
        uiviewMoreButton.backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewMoreButton)
        
        //initial tableview
        tableviewMore = UITableView(frame: CGRectMake(0, 0, tableViewWeight, screenHeight), style: .Grouped)
        tableviewMore.delegate = self
        tableviewMore.dataSource = self
        tableviewMore.registerNib(UINib(nibName: "MoreVisibleTableViewCell",bundle: nil), forCellReuseIdentifier: cellTableViewMore)
        tableviewMore.backgroundColor = UIColor.clearColor()
        tableviewMore.separatorColor = UIColor.clearColor()
        tableviewMore.rowHeight = 60
//        tableviewMore.scrollEnabled = falsey
        
        
        uiviewMoreButton.addSubview(tableviewMore)
        addHeaderViewForMore()
    }
    
    func jumpToMoodAvatar() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("MoodAvatarViewController")as! MoodAvatarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToNameCard() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NameCardViewController")as! NameCardViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func jumpToAccount(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("FaeAccountViewController")as! FaeAccountViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func addHeaderViewForMore(){
        viewHeaderForMore = UIView(frame: CGRectMake(0,0,tableViewWeight,268))
        viewHeaderForMore.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        tableviewMore.tableHeaderView = viewHeaderForMore
        tableviewMore.tableHeaderView?.frame = CGRectMake(0, 0, 311, 268)
        
        imageViewBackgroundMore = UIImageView(frame: CGRectMake(0, 148, tableViewWeight, 120))
        imageViewBackgroundMore.image = UIImage(named: "tableViewMoreBackground")
        viewHeaderForMore.addSubview(imageViewBackgroundMore)
        
        buttonMoreLeft = UIButton(frame: CGRectMake(15,27,33,25))
        buttonMoreLeft.setImage(UIImage(named: "tableViewMoreLeftButton"), forState: .Normal)
        viewHeaderForMore.addSubview(buttonMoreLeft)
        
        buttonMoreRight = UIButton(frame: CGRectMake((tableViewWeight - 27 - 15),26,27,27))
        buttonMoreRight.setImage(UIImage(named: "tableviewMoreRightButton-1"), forState: .Normal)
        viewHeaderForMore.addSubview(buttonMoreRight)
        
        imageViewAvatarMore = UIImageView(frame: CGRectMake((tableViewWeight - 91) / 2,36,91,91))
        imageViewAvatarMore.layer.cornerRadius = 81 / 2
        imageViewAvatarMore.image = UIImage(named: "myAvatorLin")
        viewHeaderForMore.addSubview(imageViewAvatarMore)
        
        labelMoreName = UILabel(frame: CGRectMake((tableViewWeight - 180) / 2,134,180,27))
        labelMoreName.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelMoreName.textAlignment = .Center
        labelMoreName.textColor = UIColor.whiteColor()
        if let name = userFirstname {
            labelMoreName.text = userFirstname! + " " + userLastname!
        }
        labelMoreName.text = "Anynomous"
        viewHeaderForMore.addSubview(labelMoreName)
    }
    
    func animationMoreShow(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewMoreButton.center.x = self.uiviewMoreButton.center.x + self.tableViewWeight
            self.dimBackgroundMoreButton.alpha = 0.7
            self.dimBackgroundMoreButton.layer.opacity = 0.7
        }))
    }
    
    func animationMoreHide(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewMoreButton.center.x = self.uiviewMoreButton.center.x - self.tableViewWeight
            self.dimBackgroundMoreButton.alpha = 0.0
        }))
    }
    
}
