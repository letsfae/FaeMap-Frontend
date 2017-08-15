//
//  MBChatBubblesCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/12/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBChatBubblesCell: UITableViewCell {

    var uiviewCell: UIButton!
    var imgAvatar: UIImageView!
    var lblBubbleTitle: UILabel!
    var lblBubbleTime: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 70.5, y: 61, width: screenWidth - 70.5, height: 1))
        separatorView.backgroundColor = UIColor._225225225()
        self.addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        
        imgAvatar = UIImageView(frame: CGRect(x: 15, y: 12, width: 39, height:39))
        addSubview(imgAvatar)
        imgAvatar.layer.cornerRadius = 19.5
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        
        lblBubbleTitle = UILabel(frame: CGRect(x: 72, y: 10, width: 255, height: 25))
        addSubview(lblBubbleTitle)
        lblBubbleTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblBubbleTitle.textColor = UIColor._898989()
        
        lblBubbleTime = UILabel(frame: CGRect(x: 72, y: 34, width: 280, height:  18))
        addSubview(lblBubbleTime)
        lblBubbleTime.font = UIFont(name: "PingFangSC-Medium", size: 13)
        lblBubbleTime.textColor = UIColor._107107107()
        lblBubbleTime.lineBreakMode = .byTruncatingTail
        
    }

}
