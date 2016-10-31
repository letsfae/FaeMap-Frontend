//
//  TableViewDelegateFile.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == tableviewMore {
            return 1
        }
        else if tableView == tableviewWindbell{
            return 1
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.mapChatTable) {
            return 10
        }
        else if tableView == tableviewMore {
            return 3
        }
        else if tableView == tableviewWindbell {
            return tableWindbellData.count
        }
        else{
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.mapChatTable {
            let cell = tableView.dequeueReusableCellWithIdentifier("mapChatTableCell", forIndexPath: indexPath) as! MapChatTableCell
            cell.layoutMargins = UIEdgeInsetsMake(0, 84, 0, 0)
            return cell
        }
        else if tableView == tableviewMore {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellTableViewMore, forIndexPath: indexPath)as! MoreVisibleTableViewCell
            cell.selectionStyle = .None
            if indexPath.row == 0 {
                cell.switchInvisible.hidden = false
                cell.labelTitle.text = "Go Invisible"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell0")
                
            } else if indexPath.row == 1 {
                cell.labelTitle.text = "Mood Avatar"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell1")
                
            } else if indexPath.row == 2 {
                cell.labelTitle.text = "Log out"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell2")
            }/*else if indexPath.row == 2 {
                cell.labelTitle.text = "My Pins"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell2")
            } else if indexPath.row == 3 {
                cell.labelTitle.text = "Saved"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell3")
            } else if indexPath.row == 4 {
                cell.labelTitle.text = "Name Cards"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell4")
            } else if indexPath.row == 5 {
                cell.labelTitle.text = "Map Board"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell5")
            } else if indexPath.row == 6 {
                cell.labelTitle.text = "Account Settings"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell6")
            }*/
            return cell
            
        }
        else if tableView == self.tableviewWindbell{
            let cell = tableView.dequeueReusableCellWithIdentifier("windbelltablecell", forIndexPath: indexPath)as! WindBellTableViewCell
            cell.selectionStyle = .None
            cell.labelTitle.text = tableWindbellData[indexPath.row]["Title"]
            cell.labelContent.text = tableWindbellData[indexPath.row]["Content"]
            cell.labelTime.text = tableWindbellData[indexPath.row]["Time"]
            return cell
            
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == tableviewMore {
            if indexPath.row == 1 {
                animationMoreHide(nil)
                jumpToMoodAvatar()
            }
            if indexPath.row == 2 {
                let user = FaeUser()
                user.logOut{ (status:Int?, message:AnyObject?) in
                    if ( status! / 100 == 2 ){
                        //success
                        self.animationMoreHide(UIButton())
                        self.jumpToWelcomeView()
                    }
                    else{
                        //failure
                    }
                }
            }
            /*
            if indexPath.row == 2 {
                animationMoreHide(nil)
                jumpToMyPins()
            }
            if indexPath.row == 4 {
                animationMoreHide(nil)
                jumpToNameCard()
            }
            if indexPath.row == 6 {
                animationMoreHide(nil)
                jumpToAccount()
            }*/
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.mapChatTable {
            return 75.0
        }
        else if tableView == tableviewMore {
            return 60
        }
        else if tableView == tableviewWindbell{
            return 82
        }
        else{
            return 0
        }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
