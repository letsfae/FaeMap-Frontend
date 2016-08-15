//
//  UnreadChatTableView.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

//MARK: Show unread chat tableView
extension FaeMapViewController {
    func loadMapChat() {
        mapChatSubview = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        mapChatSubview.backgroundColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 0.5)
        mapChatSubview.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(mapChatSubview)
        mapChatSubview.addTarget(self, action: #selector(FaeMapViewController.animationMapChatHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        mapChatWindow = UIView(frame: CGRectMake(31, 115, 350, 439))
        mapChatWindow.layer.cornerRadius = 20
        mapChatWindow.backgroundColor = UIColor.whiteColor()
        mapChatWindow.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(mapChatWindow)
        
        mapChatClose = UIButton(frame: CGRectMake(15, 27, 17, 17))
        mapChatClose.setImage(UIImage(named: "mapChatClose"), forState: .Normal)
        mapChatClose.addTarget(self, action: #selector(FaeMapViewController.animationMapChatHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        mapChatClose.clipsToBounds = true
        mapChatWindow.addSubview(mapChatClose)
        
        labelMapChat = UILabel(frame: CGRectMake(128, 27, 97, 20))
        labelMapChat.text = "Map Chats"
        labelMapChat.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelMapChat.textAlignment = .Center
        labelMapChat.clipsToBounds = true
        mapChatWindow.addSubview(labelMapChat)
        
        let mapChatUnderLine = UIView(frame: CGRectMake(0, 59, 350, 1))
        mapChatUnderLine.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        mapChatWindow.addSubview(mapChatUnderLine)
        
        mapChatTable = UITableView(frame: CGRectMake(0, 60, 350, 370))
        mapChatWindow.addSubview(mapChatTable)
        mapChatTable.delegate = self
        mapChatTable.dataSource = self
        mapChatTable.registerClass(MapChatTableCell.self, forCellReuseIdentifier: "mapChatTableCell")
        mapChatTable.layer.cornerRadius = 20
    }
    
    func animationMapChatShow(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.mapChatSubview.alpha = 0.9
            self.mapChatWindow.alpha = 1.0
        }))
    }
    
    func animationMapChatHide(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.mapChatSubview.alpha = 0.0
            self.mapChatWindow.alpha = 0.0
        }))
    }
}