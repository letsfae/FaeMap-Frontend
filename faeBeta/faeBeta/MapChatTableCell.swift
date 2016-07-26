//
//  MapChatTableCell.swift
//  faeBeta
//
//  Created by Yue on 7/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MapChatTableCell: UITableViewCell {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellContent()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelCellContent: UILabel!
    
    func loadCellContent() {
        let imageUserAvatar = UIImageView(frame: CGRectMake(9, 8, 60, 60))
        imageUserAvatar.image = UIImage(named: "avatar_expand_no")
        addSubview(imageUserAvatar)
        
        let labelUserName = UILabel(frame: CGRectMake(87, 18, 133, 22))
        labelUserName.text = "Username"
        labelUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelUserName.textAlignment = .Left
        addSubview(labelUserName)
        let labelMessage = UILabel(frame: CGRectMake(87, 40, 254, 20))
        labelMessage.text = "Message"
        labelMessage.font = UIFont(name: "AvenirNext-Regular", size: 15)
        labelMessage.textAlignment = .Left
        labelMessage.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        addSubview(labelMessage)
        let labelMessageDate = UILabel(frame: CGRectMake(257, 3, 84, 20))
        labelMessageDate.text = "9:30 am"
        labelMessageDate.font = UIFont(name: "AvenirNext-Medium", size: 13.5)
        labelMessageDate.textAlignment = .Right
        labelMessageDate.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        addSubview(labelMessageDate)
    }
}
