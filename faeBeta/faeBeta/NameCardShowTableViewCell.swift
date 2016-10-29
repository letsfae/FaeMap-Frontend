//
//  NameCardShowTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 9/23/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardShowTableViewCell: UITableViewCell {

    @IBOutlet weak var labelShow: UILabel!
    
    @IBOutlet weak var switchOutlet: UISwitch!

    @IBAction func switchAction(sender: AnyObject) {
        var value = true
        if sender.on == true {
            value = true
        } else {
            value = false
        }
        if labelShow.text == "Show Gender" {
            let user = FaeUser()
            user.whereKey("show_gender", value: String(value))
            user.updateNameCard { (status:Int, objects:AnyObject?) in
                print (status)
                if status / 100 == 2 {
                }
                else {
                        
                }
            }
        } else {
            let user = FaeUser()
            user.whereKey("show_age", value: String(value))
            user.updateNameCard { (status:Int, objects:AnyObject?) in
                print (status)
                if status / 100 == 2 {
                }
                else {

                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        switchOutlet.on = false
        switchOutlet.tintColor = UIColor.redColor()
        switchOutlet.onTintColor = UIColor.redColor()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
