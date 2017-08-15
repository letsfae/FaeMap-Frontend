//
//  MBTalkCommentsCell.swift
//  FaeMapBoard
//
//  Created by vicky on 5/1/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBTalkCommentsCell: UITableViewCell {

    var imgAvatar: UIImageView!
    var lblUsrName: UILabel!
    var lblTime: UILabel!
    var lblContent: UILabel!
    var btnUp: UIButton!
    var btnDown: UIButton!
    var lblVoteCount: UILabel!
    var uiviewFav: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor._234234234()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(5)]-0-|", options: [], views: separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgAvatar = UIImageView()
        addSubview(imgAvatar)
        imgAvatar.layer.cornerRadius = 19.5
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        addConstraintsWithFormat("H:|-15-[v0(39)]", options: [], views: imgAvatar)
        
        lblUsrName = UILabel()
        addSubview(lblUsrName)
        lblUsrName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblUsrName.textColor = UIColor._898989()
        addConstraintsWithFormat("H:|-80-[v0]-110-|", options: [], views: lblUsrName)
        
        lblTime = UILabel()
        addSubview(lblTime)
        lblTime.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblTime.textColor = UIColor._107107107()
        addConstraintsWithFormat("H:|-80-[v0]-110-|", options: [], views: lblTime)
        addConstraintsWithFormat("V:|-19-[v0(25)]-1-[v1(18)]", options: [], views: lblUsrName, lblTime)
        
        lblContent = UILabel()
        addSubview(lblContent)
        lblContent.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblContent.textColor = UIColor._898989()
        lblContent.lineBreakMode = .byWordWrapping
        lblContent.numberOfLines = 0
        addConstraintsWithFormat("H:|-27-[v0]-27-|", options: [], views: lblContent)
        
        uiviewFav = UIView()
        addSubview(uiviewFav)
        addConstraintsWithFormat("H:|-15-[v0(124)]", options: [], views: uiviewFav)
        
        btnDown = UIButton()
        btnDown.tag = 0
        uiviewFav.addSubview(btnDown)
        btnDown.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
        uiviewFav.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnDown)
        
        lblVoteCount = UILabel()
        uiviewFav.addSubview(lblVoteCount)
        lblVoteCount.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblVoteCount.textColor = UIColor._107107107()
        lblVoteCount.textAlignment = .center
        uiviewFav.addConstraintsWithFormat("V:|-6-[v0(20)]", options: [], views: lblVoteCount)
        
        btnUp = UIButton()
        btnUp.tag = 1
        uiviewFav.addSubview(btnUp)
        btnUp.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
        uiviewFav.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnUp)
        uiviewFav.addConstraintsWithFormat("H:|-0-[v0(33)]-0-[v1(58)]-0-[v2(33)]", options: [], views: btnDown, lblVoteCount, btnUp)
        
//        btnDown.addTarget(MapBoardViewController(), action: #selector(MapBoardViewController.incDecVoteCount(_:)), for: .touchUpInside)
//        btnUp.addTarget(MapBoardViewController(), action: #selector(MapBoardViewController.incDecVoteCount(_:)), for: .touchUpInside)
        
        addConstraintsWithFormat("V:|-15-[v0(39)]-10-[v1]-7-[v2(32)]-10-|", options: [], views: imgAvatar, lblContent, uiviewFav)
    }
}
