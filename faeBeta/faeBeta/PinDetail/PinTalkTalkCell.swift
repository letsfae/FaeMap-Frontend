//
//  PinTalkTalkCell.swift
//  faeBeta
//
//  Created by Yue Shen on 9/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class PinTalkTalkCell: UITableViewCell {
    
    weak var delegate: PinTalkTalkCellDelegate?
    var uiviewCell: UIButton!
    var imgAvatar: FaeAvatarView!
    var lblNickName: UILabel!
    var lblTime: UILabel!
    var lblVoteCount: UILabel!
    var lblLikeCount: UILabel!
    var lblContent: UILabel!
    var btnUpVote: UIButton!
    var btnDownVote: UIButton!
    var btnReply: UIButton!
    var pinID = ""
    var voteType: String = "null"    
    var pinType = ""
    var pinCommentID = ""
    var userID = -1 {
        didSet {
            guard userID != -1 else { return }
            self.imgAvatar.userID = self.userID
        }
    }
    var cellIndex: IndexPath!
    
    static var imgUpVoteSelected = #imageLiteral(resourceName: "pinCommentUpVoteRed")
    static var imgUpVoteUnSelected = #imageLiteral(resourceName: "pinCommentUpVoteGray")
    static var imgDownVoteSelected = #imageLiteral(resourceName: "pinCommentDownVoteRed")
    static var imgDownVoteUnSelected = #imageLiteral(resourceName: "pinCommentDownVoteGray")
    
    static var defaultAvatar = #imageLiteral(resourceName: "defaultMen")
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadUserInfo(id: Int, isAnony: Bool, anonyText: String?) {
        if isAnony {
            imgAvatar.image = PinTalkTalkCell.defaultAvatar
            lblNickName.text = anonyText
            if id == user_id {
                let attri_0 = [NSForegroundColorAttributeName: UIColor._898989(),
                               NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
                let attri_1 = [NSForegroundColorAttributeName: UIColor(r: 146, g: 146, b: 146, alpha: 100),
                               NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 15)!]
                let strAnony = anonyText ?? "Anonymous"
                let attr_0 = NSMutableAttributedString(string: strAnony + " ", attributes: attri_0)
                let attr_1 = NSMutableAttributedString(string: "(me)", attributes: attri_1)
                let attr = NSMutableAttributedString(string:"")
                attr.append(attr_0)
                attr.append(attr_1)
                lblNickName.attributedText = attr
            }
            return
        }
        imgAvatar.userID = id
        imgAvatar.loadAvatar(id: id)
        let fakeView = FaeGenderView(frame: CGRect.zero)
        fakeView.userId = id
        fakeView.loadGenderAge(id: id) { (nikeName, _, _) in
            self.lblNickName.text = nikeName
        }
    }
    
    fileprivate func loadCellContent() {
        
        uiviewCell = UIButton()
        addSubview(uiviewCell)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewCell)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewCell)
        uiviewCell.addTarget(self, action: #selector(self.showActionSheet(_:)), for: .touchUpInside)
        
        imgAvatar = FaeAvatarView(frame: CGRect.zero)
        addSubview(imgAvatar)
        imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
        imgAvatar.layer.cornerRadius = 19.5
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        addConstraintsWithFormat("H:|-15-[v0(39)]", options: [], views: imgAvatar)
        
        lblContent = UILabel()
        addSubview(lblContent)
        lblContent.lineBreakMode = .byWordWrapping
        lblContent.numberOfLines = 0
        lblContent.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblContent.textColor = UIColor._898989()
        addConstraintsWithFormat("H:|-27-[v0]-27-|", options: [], views: lblContent)
        
        lblNickName = UILabel()
        addSubview(lblNickName)
        lblNickName.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblNickName.textColor = UIColor._898989()
        lblNickName.textAlignment = .left
        addConstraintsWithFormat("H:|-69-[v0]-69-|", options: [], views: lblNickName)
        
        lblTime = UILabel()
        addSubview(lblTime)
        lblTime.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblTime.textColor = UIColor._107107107()
        lblTime.textAlignment = .left
        addConstraintsWithFormat("H:|-69-[v0]-69-|", options: [], views: lblTime)
        
        // Label of Vote Count
        lblVoteCount = UILabel()
        lblVoteCount.text = "0"
        lblVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        lblVoteCount.textColor = UIColor._107107107()
        lblVoteCount.textAlignment = .center
        addSubview(lblVoteCount)
        addConstraintsWithFormat("H:|-42-[v0(56)]", options: [], views: lblVoteCount)
        
        // DownVote
        btnDownVote = UIButton()
        btnDownVote.addTarget(self, action: #selector(downVoteThisComment(_:)), for: .touchUpInside)
        addSubview(btnDownVote)
        addConstraintsWithFormat("H:|-0-[v0(53)]", options: [], views: btnDownVote)
        
        // UpVote
        btnUpVote = UIButton()
        btnUpVote.addTarget(self, action: #selector(upVoteThisComment(_:)), for: .touchUpInside)
        addSubview(btnUpVote)
        addConstraintsWithFormat("H:|-91-[v0(53)]", options: [], views: btnUpVote)
        
        // Add Comment
        btnReply = UIButton()
        btnReply.setImage(#imageLiteral(resourceName: "pinCommentReply"), for: UIControlState())
        btnReply.addTarget(self, action: #selector(directReply(_:)), for: .touchUpInside)
        addSubview(btnReply)
        addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: btnReply)
        
        addConstraintsWithFormat("V:|-15-[v0(39)]-10-[v1]-13-[v2(22)]-16-|", options: [], views: imgAvatar, lblContent, lblVoteCount)
        addConstraintsWithFormat("V:|-15-[v0(20)]-1-[v1(20)]", options: [], views: lblNickName, lblTime)
        addConstraintsWithFormat("V:[v0(54)]-0-|", options: [], views: btnDownVote)
        addConstraintsWithFormat("V:[v0(54)]-0-|", options: [], views: btnUpVote)
        addConstraintsWithFormat("V:[v0(54)]-0-|", options: [], views: btnReply)
    }
    
    func directReply(_ sender: UIButton) {
        if let username = lblNickName.text {
            delegate?.directReplyFromPinCell(username, index: cellIndex)
        }
    }
    
    func showActionSheet(_ sender: UIButton) {
        if let username = lblNickName.text {
            delegate?.showActionSheetFromPinCell(username, userid: userID, index: cellIndex)
        }
    }
    
    func upVoteThisComment(_ sender: UIButton) {
        delegate?.upVoteComment(index: cellIndex)
    }
    
    func downVoteThisComment(_ sender: UIButton) {
        delegate?.downVoteComment(index: cellIndex)
    }
//    
//    func cancelVote() {
//        let cancelVote = FaePinAction()
//        cancelVote.cancelVotePinComments(pinId: "\(pinCommentID)") { (status: Int, message: Any?) in
//            if status / 100 == 2 {
//                self.voteType = ""
//                self.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
//                self.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
//                self.updateVoteCount()
//                print("[upVoteThisComment] Successfully cancel vote this pin comment")
//            }
//            else if status == 400 {
//                print("[upVoteThisComment] Already cancel vote this pin comment")
//            }
//            
//        }
//    }
//    
//    func updateVoteCount() {
//        let getPinCommentsDetail = FaePinAction()
//        getPinCommentsDetail.getPinComments(pinType, pinID: pinID) {(status: Int, message: Any?) in
//            let commentsOfCommentJSON = JSON(message!)
//            if commentsOfCommentJSON.count > 0 {
//                for i in 0...(commentsOfCommentJSON.count-1) {
//                    var upVote = -999
//                    var downVote = -999
//                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].int {
//                        if self.pinCommentID != "\(pin_comment_id)" {
//                            continue
//                        }
//                    }
//                    if let vote_up_count = commentsOfCommentJSON[i]["vote_up_count"].int {
//                        print("[getPinComments] upVoteCount: \(vote_up_count)")
//                        upVote = vote_up_count
//                    }
//                    if let vote_down_count = commentsOfCommentJSON[i]["vote_down_count"].int {
//                        print("[getPinComments] downVoteCount: \(vote_down_count)")
//                        downVote = vote_down_count
//                    }
//                    if let _ = commentsOfCommentJSON[i]["pin_comment_operations"]["vote"].string {
//                        
//                    }
//                    if upVote != -999 && downVote != -999 {
//                        self.lblVoteCount.text = "\(upVote - downVote)"
//                    }
//                }
//            }
//        }
//    }

}
