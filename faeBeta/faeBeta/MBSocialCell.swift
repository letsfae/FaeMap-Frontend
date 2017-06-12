//
//  MBSocialCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/11/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBSocialCell: UITableViewCell {
    
    var uiviewCell: UIButton!
    var imgIcon: UIImageView!
    var lblTitle: UILabel!
    var lblContent: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 80, y: 77, width: screenWidth - 80, height: 1))
        separatorView.backgroundColor = UIColor.faeAppLineBetweenCellGrayColor()
        addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
//        uiviewCell = UIButton()
//        addSubview(uiviewCell)
//        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewCell)
//        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewCell)
//        uiviewCell.addTarget(self, action: #selector(self.showActionSheet(_:)), for: .touchDown)
//        uiviewCell.addTarget(self, action: #selector(self.cancelActionSheet(_:)), for: [.touchUpInside, .touchUpOutside])
        
        imgIcon = UIImageView(frame: CGRect(x: 14, y: 14, width: 50, height: 50))
        addSubview(imgIcon)
        imgIcon.layer.cornerRadius = 25
        imgIcon.clipsToBounds = true
        imgIcon.contentMode = .scaleAspectFill
        
        lblTitle = UILabel()
        addSubview(lblTitle)
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblTitle.textColor = UIColor.faeAppInputTextGrayColor()
        addConstraintsWithFormat("H:|-80-[v0]-15-|", options: [], views: lblTitle)
        
        lblContent = UILabel()
        addSubview(lblContent)
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblContent.textColor = UIColor.faeAppInfoLabelGrayColor()
        lblContent.lineBreakMode = .byTruncatingTail
        addConstraintsWithFormat("H:|-80-[v0]-15-|", options: [], views: lblContent)
        
        addConstraintsWithFormat("V:|-18-[v0(25)]-1-[v1(18)]", options: [], views: lblTitle, lblContent)
    }
}
