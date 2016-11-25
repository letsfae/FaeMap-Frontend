//
//  MapChatTableCell.swift
//  faeBeta
//
//  Created by Yue on 7/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MapChatTableCell: UITableViewCell {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellContent()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelCellContent: UILabel!
    
    func loadCellContent() {
        let imageUserAvatar = UIImageView(frame: CGRect(x: 9, y: 8, width: 60, height: 60))
        addSubview(imageUserAvatar)
        
        let labelUserName = UILabel(frame: CGRect(x: 87, y: 18, width: 133, height: 22))
        labelUserName.text = "Username"
        labelUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelUserName.textAlignment = .left
        addSubview(labelUserName)
        let labelMessage = UILabel(frame: CGRect(x: 87, y: 40, width: 254, height: 20))
        labelMessage.text = "Message"
        labelMessage.font = UIFont(name: "AvenirNext-Regular", size: 15)
        labelMessage.textAlignment = .left
        labelMessage.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        addSubview(labelMessage)
        let labelMessageDate = UILabel(frame: CGRect(x: 257, y: 3, width: 84, height: 20))
        labelMessageDate.text = "9:30 am"
        labelMessageDate.font = UIFont(name: "AvenirNext-Medium", size: 13.5)
        labelMessageDate.textAlignment = .right
        labelMessageDate.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        addSubview(labelMessageDate)
    }
}
