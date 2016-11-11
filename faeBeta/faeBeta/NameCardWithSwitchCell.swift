//
//  NameCardWithSwitchCell.swift
//  faeBeta
//
//  Created by Yue on 11/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardWithSwitchCell: UITableViewCell {
    
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    var labelDes: UILabel!
    var cellSwitch: UISwitch!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadLabel()
        loadSwitch()
    }
    
    func loadSwitch() {
        cellSwitch = UISwitch()
        self.addSubview(cellSwitch)
        self.addConstraintsWithFormat("H:[v0(39)]-30-|", options: [], views: cellSwitch)
        self.addConstraintsWithFormat("V:|-16-[v0(23)]", options: [], views: cellSwitch)
        cellSwitch.onTintColor = colorFae
        cellSwitch.addTarget(self, action: #selector(self.switchAction(_:)), forControlEvents: .ValueChanged)
    }
    
    func loadLabel() {
        labelDes = UILabel()
        self.addSubview(labelDes)
        labelDes.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelDes.text = ""
        labelDes.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelDes.textAlignment = .Left
        self.addConstraintsWithFormat("H:|-25-[v0(200)]", options: [], views: labelDes)
        self.addConstraintsWithFormat("V:|-18.5-[v0(25)]", options: [], views: labelDes)
    }
    
    func switchAction(sender: AnyObject) {
        var value = true
        if sender.on == true {
            value = true
        } else {
            value = false
        }
        labelDes.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        if labelDes.text == "Show Gender" {
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
