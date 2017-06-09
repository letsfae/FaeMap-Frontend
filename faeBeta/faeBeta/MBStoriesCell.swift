//
//  MBStoriesCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/12/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBStoriesCell: UITableViewCell, UIScrollViewDelegate {

    var imgAvatar: UIImageView!
    var lblUsrName: UILabel!
    var lblTime: UILabel!
    var lblContent: UILabel!
    var btnStoryLoc: UIButton!
    var lblStoryLoc: UILabel!
    var lblFavCount: UILabel!
    var lblReplyCount: UILabel!
    var btnFav: UIButton!
    var btnReply: UIButton!
    var uiviewCellFooter: UIView!
    var scrollViewMedia: UIScrollView!
    var imgMediaArr = [UIImageView]()
    var imgHotPin: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(5)]-0-|", options: [], views: separatorView)
        loadCellContent()
        selectionStyle = .none
        loadScrollView()
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
        addConstraintsWithFormat("H:|-80-[v0]-15-|", options: [], views: lblUsrName)
        
        lblTime = UILabel()
        addSubview(lblTime)
        lblTime.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblTime.textColor = UIColor.faeAppTimeTextBlackColor()
        addConstraintsWithFormat("H:|-80-[v0]-15-|", options: [], views: lblTime)
        
        
        
        lblContent = UILabel()
        addSubview(lblContent)
        lblContent.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblContent.textColor = UIColor.faeAppInputTextGrayColor()
        lblContent.lineBreakMode = .byWordWrapping
        lblContent.numberOfLines = 0
        addConstraintsWithFormat("H:|-27-[v0]-27-|", options: [], views: lblContent)
        
        btnStoryLoc = UIButton()
        addSubview(btnStoryLoc)
        addConstraintsWithFormat("H:|-19-[v0]-19-|", options: [], views: btnStoryLoc)
        
        lblStoryLoc = UILabel()
        btnStoryLoc.addSubview(lblStoryLoc)
        lblStoryLoc.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblStoryLoc.textColor = UIColor.faeAppInputTextGrayColor()
        lblStoryLoc.lineBreakMode = .byTruncatingTail
        btnStoryLoc.addConstraintsWithFormat("H:|-42-[v0]-2-|", options: [], views: lblStoryLoc)
        btnStoryLoc.addConstraintsWithFormat("V:|-6-[v0(20)]", options: [], views: lblStoryLoc)
        
        uiviewCellFooter = UIView()
        addSubview(uiviewCellFooter)
        uiviewCellFooter.backgroundColor = .clear
        addConstraintsWithFormat("H:|-14-[v0]-14-|", options: [], views: uiviewCellFooter)
        
        btnFav = UIButton()
        uiviewCellFooter.addSubview(btnFav)
        addConstraintsWithFormat("V:|-2-[v0(22)]", options: [], views: btnFav)
        
        btnReply = UIButton()
        uiviewCellFooter.addSubview(btnReply)
        addConstraintsWithFormat("V:|-2-[v0(22)]", options: [], views: btnReply)
        
        lblFavCount = UILabel()
        uiviewCellFooter.addSubview(lblFavCount)
        lblFavCount.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblFavCount.textColor = UIColor.faeAppTimeTextBlackColor()
        lblFavCount.textAlignment = .right
        addConstraintsWithFormat("V:|-3-[v0(20)]", options: [], views: lblFavCount)
        
        lblReplyCount = UILabel()
        uiviewCellFooter.addSubview(lblReplyCount)
        lblReplyCount.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblReplyCount.textColor = UIColor.faeAppTimeTextBlackColor()
        lblReplyCount.textAlignment = .right
        addConstraintsWithFormat("V:|-3-[v0(20)]", options: [], views: lblReplyCount)
        
        addConstraintsWithFormat("H:[v0(41)]-8-[v1(26)]-17-[v2(41)]-8-[v3(26)]-0-|", options: [], views: lblFavCount, btnFav, lblReplyCount, btnReply)
        addConstraintsWithFormat("V:|-19-[v0(25)]-1-[v1(18)]", options: [], views: lblUsrName, lblTime)
        
        imgHotPin = UIImageView()
        addSubview(imgHotPin)
        imgHotPin.clipsToBounds = true
        imgHotPin.contentMode = .scaleAspectFill
        addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: imgHotPin)
        addConstraintsWithFormat("V:|-15-[v0(20)]", options: [], views: imgHotPin)
    }
    
    fileprivate func loadScrollView() {
        scrollViewMedia = UIScrollView()
        scrollViewMedia.delegate = self
        scrollViewMedia.isScrollEnabled = true
        scrollViewMedia.backgroundColor = .clear
        scrollViewMedia.showsHorizontalScrollIndicator = false
        addSubview(scrollViewMedia)
        var insets = scrollViewMedia.contentInset
        insets.left = 15
        insets.right = 15
        scrollViewMedia.contentInset = insets
        scrollViewMedia.scrollToLeft(animated: false)

        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: scrollViewMedia)
        addConstraintsWithFormat("V:|-15-[v0(50)]-10-[v1]-12-[v2(95)]-12-[v3(32)]-17-[v4(27)]-10-|", options: [], views: imgAvatar, lblContent, scrollViewMedia, btnStoryLoc, uiviewCellFooter)
    }
    
}
