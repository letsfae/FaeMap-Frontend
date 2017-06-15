//
//  MBCommentsCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/11/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBCommentsCell: UITableViewCell {
    
    var btnComLoc: UIButton!
    var btnFav: FavReplyButton!
    var btnReply: FavReplyButton!
    var imgAvatar: FaeAvatarView!
    var imgHotPin: UIImageView!
    var lblComLoc: MBAddressLabel!
    var lblContent: UILabel!
    var lblFavCount: UILabel!
    var lblReplyCount: UILabel!
    var lblTime: UILabel!
    var lblUsrName: UILabel!
    var uiviewCellFooter: UIView!
    
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
    
    // Yue 06/11/17
    func setValueForCell(userId: Int) {
        imgAvatar.userID = userId
        imgAvatar.loadAvatar(id: userId)
    }
    
    func setAddressForCell(position: CLLocationCoordinate2D, id: Int, type: String) {
        lblComLoc.pinId = id
        lblComLoc.pinType = type
        lblComLoc.loadAddress(position: position, id: id, type: type)
    }
    // Yue 06/11/17 End
    
    fileprivate func loadCellContent() {
        imgAvatar = FaeAvatarView(frame: CGRect.zero)
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
        
        btnComLoc = UIButton()
        btnComLoc.setImage(#imageLiteral(resourceName: "mb_comment_location"), for: .normal)
        addSubview(btnComLoc)
        addConstraintsWithFormat("H:|-19-[v0]-19-|", options: [], views: btnComLoc)
        
        lblComLoc = MBAddressLabel(frame: CGRect.zero)
        btnComLoc.addSubview(lblComLoc)
        lblComLoc.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblComLoc.textColor = UIColor.faeAppInputTextGrayColor()
        lblComLoc.lineBreakMode = .byTruncatingTail
        btnComLoc.addConstraintsWithFormat("H:|-42-[v0]-2-|", options: [], views: lblComLoc)
        btnComLoc.addConstraintsWithFormat("V:|-6-[v0(20)]", options: [], views: lblComLoc)
        
        uiviewCellFooter = UIView()
        addSubview(uiviewCellFooter)
        uiviewCellFooter.backgroundColor = .clear
        addConstraintsWithFormat("H:|-14-[v0]-14-|", options: [], views: uiviewCellFooter)
        
        btnFav = FavReplyButton(frame: CGRect.zero)
        btnFav.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
        uiviewCellFooter.addSubview(btnFav)
        addConstraintsWithFormat("V:|-2-[v0(22)]", options: [], views: btnFav)
        
        btnReply = FavReplyButton(frame: CGRect.zero)
        btnReply.setImage(#imageLiteral(resourceName: "pinDetailShowCommentsHollow"), for: .normal)
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
        addConstraintsWithFormat("V:|-15-[v0(50)]-10-[v1]-10-[v2(32)]-17-[v3(27)]-10-|", options: [], views: imgAvatar, lblContent, btnComLoc, uiviewCellFooter)
        addConstraintsWithFormat("V:|-19-[v0(25)]-1-[v1(18)]", options: [], views: lblUsrName, lblTime)
        
        imgHotPin = UIImageView()
        addSubview(imgHotPin)
        imgHotPin.clipsToBounds = true
        imgHotPin.contentMode = .scaleAspectFill
        imgHotPin.image = #imageLiteral(resourceName: "pinDetailHotPin")
        imgHotPin.isHidden = true
        addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: imgHotPin)
        addConstraintsWithFormat("V:|-15-[v0(20)]", options: [], views: imgHotPin)
    }
}
