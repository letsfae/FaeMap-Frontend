//
//  RecentTableViewCell.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
//    let backendless = Backendless.sharedInstance()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(recent : NSDictionary) {
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
        avatarImageView.layer.masksToBounds = true
        
        self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        let withUserId = (recent.objectForKey("withUserUserId") as? String)!
        
        //get the backendless user and download avatar
        
        let whereClause = "objectId = '\(withUserId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (user : BackendlessCollection!) in
            
            let withUser = user.data.first as! BackendlessUser
            
            //use withUser to get our avatar
            
            if let avatarUrl = withUser.getProperty("Avatar") {
                getImageFromURL(avatarUrl as! String, result: { (image) in
                    self.avatarImageView.image = image
                })
            }
            
            
        }) { (fault : Fault!) in
            print("error, couldn't get user avatar: \(fault)")
        }
        
        nameLabel.text = recent["withUserUsername"] as? String
        lastMessageLabel.text = recent["lastMessage"] as? String
        counterLabel.text = ""
        
        if (recent["counter"] as? Int)! != 0 {
            counterLabel.text = "\(recent["counter"]!) New"
        }
        
        
        
        let date = dateFormatter().dateFromString((recent["date"] as? String)!)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        dateLabel.text = TimeElipsed(seconds)
    }
    
    func TimeElipsed(seconds : NSTimeInterval) -> String {
        let elipsed : String?
        if seconds < 60 {
            elipsed = "Just Now"
        } else if (seconds < 60 * 60) {
            let minutes = Int(seconds/60)
            
            var minText = "min"
            if(minutes > 1) {
                minText = "mins"
            }
            elipsed = "\(minutes) \(minText)"
        } else if (seconds < 24 * 60 * 60) {
            let hours = Int(seconds / 3600)
            var hoursText = "hour"
            if hours > 1 {
                hoursText = "hours"
            }
            elipsed = "\(hours) \(hoursText)"
        } else {
            let days = Int(seconds / 86400)
            var dayText = "day"
            if days > 1 {
                dayText = "days"
            }
            elipsed = "\(days) \(dayText)"
        }
        return elipsed!
    }

}
