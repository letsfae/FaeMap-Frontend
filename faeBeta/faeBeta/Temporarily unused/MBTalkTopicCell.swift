//
//  MBTalkTopicCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/30/17.
//  Copyright © 2017 Yue. All rights reserved.
//
/*
import UIKit

class MBTalkTopicCell: UITableViewCell {
    var lblTopics: UILabel!
    var lblPostsCount: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-15-[v0]-15-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent() {
        lblTopics = UILabel(frame: CGRect(x: 23, y: 13, width: screenWidth - 46, height: 25))
        addSubview(lblTopics)
        lblTopics.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblTopics.textColor = UIColor._898989()
        
        lblPostsCount = UILabel(frame: CGRect(x: 23, y: 37, width: screenWidth - 46, height: 18))
        addSubview(lblPostsCount)
        lblPostsCount.font = UIFont(name: "PingFangSC-Medium", size: 13)
        lblPostsCount.textColor = UIColor._155155155()
    }
}
 */
