//
//  MBTalkMypostCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/30/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBTalkMytalksCell: UITableViewCell {

    var imgAvatar: UIImageView!
    var lblUsrName: UILabel!
    var lblTime: UILabel!
    var lblReplyCount: UILabel!
    var btnReply: UIButton!
    
    var lblContent: UILabel!
    var btnTalkTopic: UIButton!
    var lblTalkTopic: UILabel!
    var lblVoteCount: UILabel!
    
    var btnUp: UIButton!
    var btnDown: UIButton!
    
    var uiviewFav: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
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
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imgAvatar)
        
        lblUsrName = UILabel()
        addSubview(lblUsrName)
        lblUsrName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblUsrName.textColor = UIColor.faeAppInputTextGrayColor()
        addConstraintsWithFormat("H:|-80-[v0]-110-|", options: [], views: lblUsrName)
        
        lblTime = UILabel()
        addSubview(lblTime)
        lblTime.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblTime.textColor = UIColor.faeAppTimeTextBlackColor()
        addConstraintsWithFormat("H:|-80-[v0]-110-|", options: [], views: lblTime)
        addConstraintsWithFormat("V:|-19-[v0(25)]-1-[v1(18)]", options: [], views: lblUsrName, lblTime)
        
        lblReplyCount = UILabel()
        addSubview(lblReplyCount)
        lblReplyCount.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblReplyCount.textColor = UIColor.faeAppTimeTextBlackColor()
        lblReplyCount.textAlignment = .right
        addConstraintsWithFormat("V:|-17-[v0(20)]", options: [], views: lblReplyCount)
        
        btnReply = UIButton()
        addSubview(btnReply)
        btnReply.setImage(#imageLiteral(resourceName: "mb_comment_reply"), for: .normal)
        addConstraintsWithFormat("V:|-11-[v0(32)]", options: [], views: btnReply)
        addConstraintsWithFormat("H:[v0(60)]-2-[v1(36)]-9-|", options: [], views: lblReplyCount, btnReply)
        
        lblContent = UILabel()
        addSubview(lblContent)
        lblContent.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblContent.textColor = UIColor.faeAppInputTextGrayColor()
        lblContent.lineBreakMode = .byWordWrapping
        lblContent.numberOfLines = 0
        addConstraintsWithFormat("H:|-27-[v0]-27-|", options: [], views: lblContent)
        
        btnTalkTopic = UIButton()
        addSubview(btnTalkTopic)
        addConstraintsWithFormat("H:|-15-[v0(100)]", options: [], views: btnTalkTopic)
        btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_talkTopicMask"), for: .normal)
        btnTalkTopic.imageView?.contentMode = .scaleAspectFill
        //        btnTalkTopic.setTitleColor(UIColor.faeAppInputTextGrayColor(), for: .normal)
        //        btnTalkTopic.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
        //        btnTalkTopic.titleLabel?.lineBreakMode = .byTruncatingTail
        
        uiviewFav = UIView()
        addSubview(uiviewFav)
        addConstraintsWithFormat("H:[v0(124)]-15-|", options: [], views: uiviewFav)
        addConstraintsWithFormat("V:[v0(32)]-16-|", options: [], views: uiviewFav)
        
        btnDown = UIButton()
        btnDown.tag = 0
        uiviewFav.addSubview(btnDown)
        btnDown.setImage(#imageLiteral(resourceName: "mb_inactiveDownArrow"), for: .normal)
        uiviewFav.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnDown)
        
        lblVoteCount = UILabel()
        uiviewFav.addSubview(lblVoteCount)
        lblVoteCount.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblVoteCount.textColor = UIColor.faeAppTimeTextBlackColor()
        lblVoteCount.textAlignment = .center
        uiviewFav.addConstraintsWithFormat("V:|-6-[v0(20)]", options: [], views: lblVoteCount)
        
        btnUp = UIButton()
        btnUp.tag = 1
        uiviewFav.addSubview(btnUp)
        btnUp.setImage(#imageLiteral(resourceName: "mb_inactiveUpArrow"), for: .normal)
        uiviewFav.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnUp)
        uiviewFav.addConstraintsWithFormat("H:[v0(33)]-0-[v1(58)]-0-[v2(33)]-0-|", options: [], views: btnDown, lblVoteCount, btnUp)
        
        btnDown.addTarget(MapBoardViewController(), action: #selector(MapBoardViewController.incDecVoteCount(_:)), for: .touchUpInside)
        btnUp.addTarget(MapBoardViewController(), action: #selector(MapBoardViewController.incDecVoteCount(_:)), for: .touchUpInside)
        
        addConstraintsWithFormat("V:|-15-[v0(50)]-10-[v1]-10-[v2(32)]-15-|", options: [], views: imgAvatar, lblContent, btnTalkTopic)
    }
}
